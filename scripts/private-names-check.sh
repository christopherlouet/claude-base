#!/usr/bin/env bash
# =============================================================================
# private-names-check.sh — pre-commit gate: keep an end user's PRIVATE project
# names out of this PUBLIC repository.
#
# This foundation is developed against real personal projects, so their names
# leak into docs, specs and test fixtures by accident — usually in the very
# checklists meant to prevent it. A checklist only fires when someone
# remembers; this gate fires on every commit.
#
# THE LIST LIVES OUTSIDE THE REPO. Default ~/.claude/private-names, one name
# per line (# comments and blank lines ignored), overridable with
# CLAUDE_BASE_PRIVATE_NAMES. Committing the list here would publish exactly
# what it protects. No list → silent no-op, so anyone cloning the public
# foundation is never blocked by a list they do not have.
#
# Scans only what the commit ADDS — added diff lines and staged file paths — so
# a pre-existing occurrence in an untouched region never blocks an unrelated
# commit, and REMOVING an occurrence is always allowed. Names are matched as
# FIXED strings (grep -F): a name is data, never a pattern.
#
# FAIL-OPEN IS THE ONLY FAILURE MODE THAT MATTERS HERE. A gate people trust
# must not pass silently, so the details below are load-bearing, each pinned by
# a regression test:
#   - paths are read NUL-delimited with quotepath off: git C-quotes non-ASCII
#     paths ("d/caf\303\251.md"), and the quoted form matches no pathspec;
#   - added lines are taken only after the first @@ hunk header, never by
#     excluding '^+++', which also drops content lines starting with '++';
#   - the scan runs from the repo root, so a manual run from a subdirectory
#     still sees every staged path;
#   - --text so a name inside a staged binary is still seen;
#   - HOME may be unset (cron, CI): that is "no list", not a hard error.
#
# Blocks with exit 1 and lists each offending name and file.
# Disable with SKIP_PRIVATE_NAMES=1.
# Tested by tests/private-names-check.bats.
# =============================================================================
set -euo pipefail

[ "${SKIP_PRIVATE_NAMES:-0}" = "1" ] && exit 0

# Resolve the list path. An unset HOME means "no list", never a crash that
# would block every commit.
LIST="${CLAUDE_BASE_PRIVATE_NAMES:-}"
if [ -z "$LIST" ]; then
    [ -n "${HOME:-}" ] || exit 0
    LIST="$HOME/.claude/private-names"
fi
[ -f "$LIST" ] || exit 0

# Run from the repo root: --name-only yields root-relative paths, so a manual
# invocation from a subdirectory would otherwise scan nothing.
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT"

NAMES_FILE=$(mktemp)
STAGED_FILE=$(mktemp)
PATHS_FILE=$(mktemp)
CONTENT_FILE=$(mktemp)
FINDINGS=$(mktemp)
trap 'rm -f "$NAMES_FILE" "$STAGED_FILE" "$PATHS_FILE" "$CONTENT_FILE" "$FINDINGS"' EXIT

# Shortest entry that can be searched as a substring without taxing ordinary
# text. A one- or two-letter name matches inside unrelated words ("K" inside
# `const kilo = 1000;`), so it would refuse a large share of honest commits --
# and the answer to a gate like that is SKIP_PRIVATE_NAMES=1, which disarms the
# ENTIRE list. Losing one name loudly beats losing all of them silently.
#
# Widening the match is NOT the alternative: `grep -Fiw` would stop the false
# blocks by trading them for false NEGATIVES (a name would slip through inside
# `monprojetApi` or `monprojet_api`, which is exactly how a project name appears
# in code) -- the wrong direction for a privacy gate, where the miss is the
# failure that costs something. A short name needs a longer distinctive form
# instead, and this says so rather than matching it badly.
MIN_NAME_LEN=4

# Collect the protected names: strip comments, trim surrounding whitespace,
# drop blanks. bash 3.2 safe (no mapfile, no associative arrays).
while IFS= read -r raw || [ -n "$raw" ]; do
    case "$raw" in \#*) continue ;; esac
    name="${raw#"${raw%%[![:space:]]*}"}"
    name="${name%"${name##*[![:space:]]}"}"
    [ -n "$name" ] || continue
    if [ "${#name}" -lt "$MIN_NAME_LEN" ]; then
        printf 'private-names: "%s" is shorter than %d characters -- searched as a substring it would block ordinary text. THIS ENTRY IS NOT protected; use a longer distinctive form.\n' \
            "$name" "$MIN_NAME_LEN" >&2
        continue
    fi
    printf '%s\n' "$name" >> "$NAMES_FILE"
done < "$LIST"

[ -s "$NAMES_FILE" ] || exit 0

# Staged, non-deleted paths, NUL-delimited so no path is mangled or quoted.
#
# This read fails CLOSED, exactly like the staged-diff read below. It used to be
# `... || true` followed by "empty means nothing staged": that made a git FAILURE
# indistinguishable from an empty index, and because this check sits BEFORE the
# content scan, a failure skipped the WHOLE gate rather than only the path check.
if ! git -c core.quotepath=off diff --cached --name-only -z \
         --diff-filter=ACMR > "$STAGED_FILE" 2>/dev/null; then
    echo "private-names-check: cannot read the staged paths — refusing to pass silently." >&2
    exit 1
fi
# Reaching here, the read SUCCEEDED, so an empty result really is an empty index.
[ -s "$STAGED_FILE" ] || exit 0

# ONE diff for the whole index, not one per file: a per-file diff costs a git
# process per staged file and dominates hook latency (measured: 200 files went
# from ~12s to well under a second). Added lines are attributed to their file
# by tracking the '+++ b/<path>' headers.
#
# A swallowed git error would read as "no added lines" — a silent pass — so the
# diff must succeed, or the gate fails CLOSED.
if ! raw=$(git -c core.quotepath=off diff --cached -U0 --no-color --text \
               --diff-filter=ACMR 2>&1); then
    echo "private-names-check: cannot read the staged diff — refusing to pass silently." >&2
    printf '%s\n' "$raw" >&2
    exit 1
fi

# '<path>\t<added line>' per added line. The '+++' header is only taken while
# outside a hunk, so a content line that itself starts with '++' is never
# mistaken for it.
printf '%s\n' "$raw" | awk '
    /^diff --git / { inhunk = 0; next }
    !inhunk && /^\+\+\+ / { f = substr($0, 5); sub(/^b\//, "", f); file = f; next }
    /^@@/ { inhunk = 1; next }
    inhunk && /^\+/ { print file "\t" substr($0, 2) }
' > "$CONTENT_FILE"

# Staged paths, one per line, for the path-name check.
tr '\0' '\n' < "$STAGED_FILE" > "$PATHS_FILE"

# One grep per NAME (not per name per file) over each of the two haystacks.
# NOTE: pipefail is on, and grep exits 1 when it matches nothing — the common
# case. Without '|| true' a clean commit would abort the script and read as a
# block. Pinned by the "clean staged content: exits 0" test.
while IFS= read -r name; do
    [ -n "$name" ] || continue
    { grep -Fi -- "$name" "$PATHS_FILE" || true; } \
        | while IFS= read -r p; do [ -n "$p" ] && printf '%s\t%s\n' "$name" "$p"; done >> "$FINDINGS"
    { grep -Fi -- "$name" "$CONTENT_FILE" || true; } | cut -f1 | sort -u \
        | while IFS= read -r p; do [ -n "$p" ] && printf '%s\t%s\n' "$name" "$p"; done >> "$FINDINGS"
done < "$NAMES_FILE"

[ -s "$FINDINGS" ] || exit 0

{
    echo "BLOCKED: a protected private name would be committed to this public repo."
    echo
    sort -u "$FINDINGS" | while IFS="$(printf '\t')" read -r name file; do
        printf '  %-24s %s\n' "$name" "$file"
    done
    echo
    echo "Use a neutral placeholder instead (e.g. <project-a>, 'a personal project')."
    echo "List: $LIST   Bypass (deliberate): SKIP_PRIVATE_NAMES=1 git commit ..."
} >&2

exit 1
