#!/usr/bin/env bash
# =============================================================================
# curation-safety.sh — pin-time integrity screen for the marketplace curation
# engine (Slice 3b, specs/marketplace-curation-engine). EF-006 / US-4.
#
# A DETERMINISTIC, LLM-free scan of a candidate's OWN content for obviously-
# dangerous instructions — kept STRICTLY SEPARATE from the trust criterion
# (popularity ≠ safety). It gates the engine's automated actions: in discover it
# is Gate 2 (a non-pass rejects the candidate); in watch a pass lets a drift
# auto-draft a re-pin, a flag demotes it to propose-only (human re-screens via
# the digest). It never auto-installs and never copies third-party content
# (EF-010) — it only reads.
#
# Scan surface (#3): NOT just the SKILL.md/README.md doc — also the candidate's
# REAL executable surface, where a benign-looking doc could otherwise hide
# hostile code: script files (*.sh/.bash/.zsh/.py/.js/.mjs/.cjs/.rb/.pl/.php),
# anything with the git executable bit (mode 100755, e.g. an extensionless
# `bin/install`), Claude settings hook command blocks (settings*.json) and MCP
# server configs (.mcp.json / mcp.json). The same high-signal danger patterns
# apply to every file. (Limitations, all fail toward human review: a command
# split across a JSON args[] array, a download executed in a separate statement,
# and a hook command referencing a script outside the scanned surface are not
# caught — see _curation_scan_text. A flag only ever routes to review.)
#
# Fail-safe (EF-012): anything that cannot be confirmed safe is FLAGGED, never
# silently passed. Reasons: content-unfetchable (no doc), exec-surface-unfetchable
# (tree unlistable), exec-file-unfetchable (a listed exec file unreadable),
# exec-surface-truncated (more exec files than the cap; the rest went unscanned).
#
# API:  curation_safety_screen <owner/repo> <ref>
#   stdout: one JSON object {repo, ref, verdict:"pass"|"flag", reasons[]}
#   exit:   0 always (a verdict is always produced; failures become a flag).
#   env:    CURATION_SAFETY_MAX_FILES — exec-surface file cap (default 25).
# =============================================================================

_SAFETY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_SAFETY_DIR/curation-common.sh"

# _curation_b64decode — decode base64 from stdin, portable across GNU (`-d` /
# `--decode`) and BSD/macOS (`-D`). GitHub wraps contents in newlines, which all
# variants tolerate. The decoder's exit status is PROPAGATED (no blanket
# swallow): a decode that fails must be visible to the caller so it can fail safe
# rather than treat undecodable bytes as "empty = clean".
_curation_b64decode() {
    if printf '' | base64 --decode >/dev/null 2>&1; then
        base64 --decode 2>/dev/null
    else
        base64 -D 2>/dev/null
    fi
}

# _curation_fetch_one <repo> <ref> <path> — echo the decoded text of one file at
# <ref> via the contents API (base64 body, mockable offline); return non-zero if
# the file is absent, unfetchable, or undecodable. A present-but-undecodable /
# empty-after-decode body is treated as NOT fetched — never as clean text — so
# corrupt base64 or a wrong-decoder pick fails SAFE instead of false-passing.
_curation_fetch_one() {
    local repo="$1" ref="$2" file="$3" body content decoded
    body=$(curation_gh_api "repos/$repo/contents/$file?ref=$ref" 2>/dev/null) || return 1
    content=$(printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null)
    [ -n "$content" ] || return 1
    decoded=$(printf '%s' "$content" | _curation_b64decode) || return 1
    [ -n "$decoded" ] || return 1
    printf '%s' "$decoded"
}

# _curation_fetch_content <repo> <ref> — echo the decoded text of the skill's
# primary doc (SKILL.md, else README.md) at <ref>; return non-zero if neither is
# fetchable OR decodable.
_curation_fetch_content() {
    local repo="$1" ref="$2" file
    for file in SKILL.md README.md; do
        _curation_fetch_one "$repo" "$ref" "$file" && return 0
    done
    return 1
}

# _curation_scan_text — read text on stdin, echo (one per line) the danger
# CATEGORIES it matches. Shared by the doc scan AND the exec-surface scan so both
# apply exactly the same high-signal, deterministic, case-insensitive patterns:
#   remote-exec      — a downloaded payload reaching an interpreter (curl|sh,
#                      curl|node, bash <(curl), eval "$(curl …)")
#   obfuscated-exec  — decode (base64/xxd) then execute / eval "$(base64 …)"
#   destructive-rm   — recursive+force delete of a root/home path (either flag order)
#   prompt-injection — overriding the operator's / system instructions
# The exec sink is NOT just POSIX shells: a hostile script in the exec surface
# commonly pipes a payload into node/deno/bun/python/perl/ruby/php/env, so those
# are recognized too. Emitting a category twice is harmless: the caller dedups.
#
# KNOWN line-based blind spot (#3 follow-up): a download SAVED to a file and then
# executed in a SEPARATE statement (`curl -o p …` then `sh p`) is not correlated
# across lines, nor is a hook command that references a script file outside the
# scanned surface. These need filename correlation; until then they evade the
# grep. The screen fails toward human review (a clean verdict only enables an
# auto-DRAFT, still human-merged), so this is a coverage gap, never a silent risk.
_INTERP='sh|bash|zsh|node|deno|bun|python[0-9.]*|perl|ruby|php|env'
_curation_scan_text() {
    local text; text=$(cat)
    grep -Eiq "(curl|wget).*\|[[:space:]]*(sudo[[:space:]]+)?($_INTERP)\b" <<<"$text" \
        && printf 'remote-exec\n'
    grep -Eiq "($_INTERP)[[:space:]]+(-[a-z]+[[:space:]]+)*(-c[[:space:]]+)?[\"']?[\$<]\(?(curl|wget)" <<<"$text" \
        && printf 'remote-exec\n'
    grep -Eiq 'eval[^=]*\$\([^)]*(curl|wget)' <<<"$text" \
        && printf 'remote-exec\n'
    grep -Eiq "(base64|xxd)[^|]*(--decode|-d|-D|-r)?[^|]*\|.*\b(sudo[[:space:]]+)?($_INTERP|eval)\b" <<<"$text" \
        && printf 'obfuscated-exec\n'
    grep -Eiq 'eval[^=]*\$\([^)]*(base64|xxd)' <<<"$text" \
        && printf 'obfuscated-exec\n'
    grep -Eiq 'rm[[:space:]]+(-[a-z]*(rf|fr)[a-z]*|-[rf][[:space:]]+-[rf]|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)[[:space:]]+(/|~|\$\{?HOME)' <<<"$text" \
        && printf 'destructive-rm\n'
    grep -Eiq 'ignore[[:space:]]+(all|the|any|your)?[[:space:]]*(previous|prior|above)[[:space:]]+(system[[:space:]]+)?instructions?|ignore[[:space:]]+(the|your)?[[:space:]]*system[[:space:]]+prompt|disregard[[:space:]]+(the|your)?[[:space:]]*(system[[:space:]]+)?(prompt|instructions?)' <<<"$text" \
        && printf 'prompt-injection\n'
    return 0
}

# _curation_list_exec_surface <repo> <ref> — echo the candidate's executable-
# surface paths (one per line) from the recursive git tree at <ref>: shell
# scripts (*.sh), Claude settings hook blocks (settings*.json) and MCP server
# configs (.mcp.json / mcp.json) — the files that can actually run code in a
# user's session, which the SKILL.md/README.md doc cannot reveal. Capped at
# CURATION_SAFETY_MAX_FILES (default 25) to bound API calls on large repos.
# Exit: 0 = listed OK (paths on stdout, possibly none);
#       1 = the tree could not be listed/parsed (caller fails safe);
#       3 = listed but capped/truncated (caller flags + scans the partial list).
_curation_list_exec_surface() {
    local repo="$1" ref="$2" body
    local cap="${CURATION_SAFETY_MAX_FILES:-25}"
    body=$(curation_gh_api "repos/$repo/git/trees/$ref?recursive=1" 2>/dev/null) || return 1
    # A response without a .tree array (e.g. an error object) is unusable.
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    local truncated all count
    truncated=$(printf '%s' "$body" | jq -r '.truncated // false')
    all=$(printf '%s' "$body" | jq -r '
        .tree[] | select(.type == "blob")
        | select(
            (.path | test("\\.(sh|bash|zsh|py|js|mjs|cjs|rb|pl|php)$"))
            or (.mode == "100755")
            or (.path | split("/")[-1] | (test("^settings.*\\.json$") or test("^\\.?mcp\\.json$")))
          )
        | .path')
    count=$(printf '%s' "$all" | grep -c . || true)
    if [ "$truncated" = "true" ] || [ "$count" -gt "$cap" ]; then
        printf '%s\n' "$all" | grep . | head -n "$cap" || true
        return 3
    fi
    printf '%s' "$all" | grep . || true
    return 0
}

# curation_safety_screen <owner/repo> <ref>
curation_safety_screen() {
    local repo="$1" ref="$2"
    local reasons=() text r

    # The primary doc must be fetchable — fail safe otherwise (unchanged EF-012).
    if ! text=$(_curation_fetch_content "$repo" "$ref"); then
        _curation_safety_emit "$repo" "$ref" "flag" "content-unfetchable"
        return 0
    fi

    # 1. Scan the primary doc (SKILL.md/README.md).
    while IFS= read -r r; do [ -n "$r" ] && reasons+=("$r"); done \
        < <(printf '%s' "$text" | _curation_scan_text)

    # 2. Scan the REAL executable surface (*.sh, settings*.json hooks, .mcp.json).
    # A benign doc must not let a hostile hook/script/MCP command through.
    local surface rc
    surface=$(_curation_list_exec_surface "$repo" "$ref"); rc=$?
    if [ "$rc" -eq 1 ]; then
        # Can't confirm the surface is safe → fail safe (never silently pass).
        reasons+=("exec-surface-unfetchable")
    else
        [ "$rc" -eq 3 ] && reasons+=("exec-surface-truncated")
        local path ftext
        while IFS= read -r path; do
            [ -n "$path" ] || continue
            if ftext=$(_curation_fetch_one "$repo" "$ref" "$path"); then
                while IFS= read -r r; do [ -n "$r" ] && reasons+=("$r"); done \
                    < <(printf '%s' "$ftext" | _curation_scan_text)
            else
                # A listed exec file we cannot read → fail safe.
                reasons+=("exec-file-unfetchable")
            fi
        done <<< "$surface"
    fi

    # 3. Dedup reason categories (order-preserving) and decide the verdict.
    local verdict="pass" seen=" " out=()
    for r in ${reasons[@]+"${reasons[@]}"}; do
        [ -n "$r" ] || continue
        [[ "$seen" == *" $r "* ]] && continue
        seen+="$r "; out+=("$r")
    done
    if [ "${#out[@]}" -gt 0 ]; then
        verdict="flag"
    else
        out+=("clean")
    fi
    _curation_safety_emit "$repo" "$ref" "$verdict" "${out[@]}"
    return 0
}

# _curation_safety_emit <repo> <ref> <verdict> <reason...>
_curation_safety_emit() {
    local repo="$1" ref="$2" verdict="$3"; shift 3
    jq -cn --arg repo "$repo" --arg ref "$ref" --arg verdict "$verdict" \
        '{repo:$repo, ref:$ref, verdict:$verdict, reasons:$ARGS.positional}' \
        --args "$@"
}

# CLI: curation-safety.sh <owner/repo> <ref>
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    [ $# -eq 2 ] || { echo "Usage: $(basename "$0") <owner/repo> <ref>" >&2; exit 2; }
    curation_safety_screen "$1" "$2"
    exit $?
fi
