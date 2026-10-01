#!/usr/bin/env bash
# =============================================================================
# refresh-template-pins.sh — re-pin the GitHub Actions in the workflow TEMPLATES
# the foundation ships to projects, to the latest release of each major line.
#
# Why: those templates run in a project's CI with its token (and, for the
# claude-review ones, its ANTHROPIC_API_KEY), so each action is pinned to a
# commit SHA: a tag is a pointer its owner can move. But Dependabot only reads
# /.github/workflows and a root action.yml (GitHub docs, checked 2026-10-01),
# so nothing keeps these pins fresh in the foundation. Run this at each release
# (scripts/bump-version.sh lists it); between releases, the dependabot.yml that
# `init --ci` seeds in the project bumps them there.
#
# Scanned: templates/github-workflows/*.yml and .claude/templates/github-actions/*.yml.
# Each `uses: owner/repo@<ref> [# <version>]` line becomes
# `uses: owner/repo@<40-hex sha> # <tag>`, where <tag> is the highest release
# X.Y.Z (tag style kept: v-prefixed or not) in the line's major — read from the
# version comment, else from a vN / N.N.N ref. Local (./) and docker:// actions
# are left alone. An action that cannot be resolved keeps its line untouched and
# makes the run exit 1; the others are still refreshed.
#
# Needs `gh` (authenticated). Test seam: PINS_ROOT (repo root; default: this
# script's parent dir). macOS bash 3.2 compatible.
# =============================================================================

set -euo pipefail

ROOT="${PINS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Groups: 1 prefix, 2 owner/repo (what the API is asked), 3 optional /sub/path
# (github/codeql-action/init), 4 ref, 6 version comment.
USES_RE='^([[:space:]-]*uses:[[:space:]]*)([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)(/[^@[:space:]]+)?@([^[:space:]#]+)([[:space:]]+#[[:space:]]*([^[:space:]]+))?[[:space:]]*$'
# Any `uses:` naming a remote ref, in a shape USES_RE may not read (quoted value,
# quoted key): the guard in tests/ci-workflows.bats flags those too, so this
# script must fail on them rather than exit 0 with the line untouched.
ANY_USES_RE='^[[:space:]-]*"?uses"?[[:space:]]*:[[:space:]]*"?[^.[:space:]"][^[:space:]]*@'
SHA_RE='^[0-9a-f]{40}$'

CACHE="$(mktemp)"
ERRF="$(mktemp)"
trap 'rm -f "$CACHE" "$ERRF"' EXIT
FAILED=0

# major_of <ref> <version-comment> — the major line, empty when unknown.
major_of() {
    local v
    for v in "$2" "$1"; do
        # A SHA is never a version, even an all-digit one.
        [[ "$v" =~ $SHA_RE ]] && continue
        if [[ "$v" =~ ^v?([0-9]+)(\.[0-9]+)*$ ]]; then
            printf '%s' "${BASH_REMATCH[1]}"
            return 0
        fi
    done
}

# resolve <owner/repo> <major> — prints "<tag> <sha>", or nothing on failure.
# Memoised per run in $CACHE ("<repo> <major> <tag> <sha>", or
# "<repo> <major> FAIL <reason>": gh's own last error line, so a rate limit or
# an expired login is named, not reduced to "could not resolve").
resolve() {
    local repo="$1" major="$2" hit tag sha
    hit=$(awk -v r="$repo" -v m="$major" '$1 == r && $2 == m { print $3, $4; exit }' "$CACHE")
    if [ -n "$hit" ]; then
        [ "${hit#FAIL}" = "$hit" ] && printf '%s\n' "$hit"
        return 0
    fi
    : > "$ERRF"
    tag=$(gh api "repos/$repo/tags" --paginate --jq '.[].name' 2>"$ERRF" \
        | awk -v m="$major" '
            { n = $0; sub(/^v/, "", n) }
            n ~ /^[0-9]+\.[0-9]+\.[0-9]+$/ {
                split(n, p, "."); if (p[1] == m) printf "%d %d %s\n", p[2], p[3], $0
            }' \
        | sort -k1,1n -k2,2n | tail -n 1 | cut -d' ' -f3) || tag=""
    sha=""
    if [ -n "$tag" ]; then
        sha=$(gh api "repos/$repo/commits/$tag" --jq '.sha' 2>>"$ERRF") || sha=""
    fi
    if [ -n "$tag" ] && [[ "$sha" =~ $SHA_RE ]]; then
        printf '%s %s %s %s\n' "$repo" "$major" "$tag" "$sha" >> "$CACHE"
        printf '%s %s\n' "$tag" "$sha"
    else
        local reason
        reason=$(awk 'NF { l = $0 } END { print l }' "$ERRF")
        [ -n "$reason" ] || reason="no X.Y.Z release in major $major"
        printf '%s %s FAIL %s\n' "$repo" "$major" "$reason" >> "$CACHE"
    fi
}

refresh_file() {
    local file="$1" tmp line prefix repo sub ref ver major got tag sha why
    tmp="$(mktemp)"
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ $USES_RE ]]; then
            prefix="${BASH_REMATCH[1]}" repo="${BASH_REMATCH[2]}" sub="${BASH_REMATCH[3]:-}"
            ref="${BASH_REMATCH[4]}" ver="${BASH_REMATCH[6]:-}"
            major=$(major_of "$ref" "$ver")
            got=""
            [ -n "$major" ] && got=$(resolve "$repo" "$major")
            if [ -n "$got" ]; then
                tag="${got%% *}" sha="${got#* }"
                line="${prefix}${repo}${sub}@${sha} # ${tag}"
            else
                why=$(awk -v r="$repo" -v m="$major" '$1 == r && $2 == m && $3 == "FAIL" { $1 = $2 = $3 = ""; sub(/^ +/, ""); print; exit }' "$CACHE")
                echo "[template-pins] could not resolve $repo$sub@$ref${ver:+ ($ver)} in ${file#"$ROOT"/}${why:+: $why}; line kept" >&2
                FAILED=1
            fi
        elif [[ "$line" =~ $ANY_USES_RE ]] && [[ "$line" != *docker://* ]]; then
            echo "[template-pins] unreadable uses line in ${file#"$ROOT"/} (quoted?): ${line#"${line%%[![:space:]]*}"}; write it as uses: owner/repo@ref" >&2
            FAILED=1
        fi
        printf '%s\n' "$line"
    done < "$file" > "$tmp"
    if cmp -s "$tmp" "$file"; then rm -f "$tmp"; else mv "$tmp" "$file"; fi
}

for f in "$ROOT"/templates/github-workflows/*.yml "$ROOT"/.claude/templates/github-actions/*.yml; do
    [ -f "$f" ] || continue
    refresh_file "$f"
done

exit "$FAILED"
