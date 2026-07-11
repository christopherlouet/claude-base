#!/usr/bin/env bash
# =============================================================================
# check-conflict-markers.sh — fail when git merge-conflict markers survive in
# tracked files. Born from the 2026-07-08 P0 incident: a conflict block landed
# on main because nothing between the editor and CI ever looked for one.
#
# Scans TRACKED files only (git grep), so throwaway sandboxes never false-trip.
# Detects the `<<<<<<< `, `>>>>>>> ` and diff3 `|||||||` marker lines. The bare
# `=======` separator is deliberately NOT matched on its own — it is a common
# Markdown/ASCII underline, and a real conflict always carries the two anchor
# markers this script does catch.
#
# The marker patterns are ASSEMBLED at runtime (never written literally here),
# so the script can scan itself, and fixture-hungry scanners never flag it.
#
# Usage: check-conflict-markers.sh [DIR]   (default: repo of the CWD)
# Exit:  0 clean · 1 markers found (listed file:line) · 2 not a git repo.
# =============================================================================
set -euo pipefail

DIR="${1:-.}"
cd "$DIR"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "check-conflict-markers: not a git repository: $DIR" >&2
    exit 2
}

# The diff3 pipe must be a LITERAL in ERE — as a bare char '|' is alternation
# and "^|||||||" matches every line; a [|] character class keeps it literal.
l='<'; r='>'; p='[|]'
open="^${l}${l}${l}${l}${l}${l}${l} "
close="^${r}${r}${r}${r}${r}${r}${r} "
base="^${p}${p}${p}${p}${p}${p}${p}"

# git grep exits 1 on no match — that's the clean case, not an error.
found=$(git grep -nE -e "$open" -e "$close" -e "$base" -- . 2>/dev/null || true)

if [ -n "$found" ]; then
    echo "Merge-conflict markers found in tracked files:" >&2
    printf '%s\n' "$found" >&2
    exit 1
fi
exit 0
