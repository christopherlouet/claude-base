#!/usr/bin/env bash
# =============================================================================
# validate-translation.sh — orchestrator: runs check-refs, check-structure,
# and (per-file) check-glossary on a single translated file.
#
# Exit codes:
#   0 — all checks pass
#   1 — at least one check failed
#   2 — invalid arguments
#
# Usage:
#   validate-translation.sh --src <file> --dst <file>
#   validate-translation.sh --src <file> --dst <file> --check-anchors
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_DIR="$SCRIPT_DIR/../../specs/migration-fr-en"

CHECK_REFS="$SCRIPT_DIR/check-refs.sh"
CHECK_STRUCT="$SCRIPT_DIR/check-structure.sh"
CHECK_GLOSSARY="$SCRIPT_DIR/check-glossary.sh"
BLACKLIST="$SPEC_DIR/blacklist.txt"
GLOSSARY="$SPEC_DIR/glossary.yaml"

SRC=""
DST=""
CHECK_ANCHORS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --src) SRC="$2"; shift 2 ;;
        --dst) DST="$2"; shift 2 ;;
        --check-anchors) CHECK_ANCHORS="--check-anchors"; shift ;;
        -h|--help) head -13 "$0" | tail -12; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

[[ -z "$SRC" || -z "$DST" ]] && {
    echo "Usage: $0 --src <file> --dst <file> [--check-anchors]" >&2
    exit 2
}

[[ -x "$CHECK_REFS" ]] || { echo "Missing: $CHECK_REFS" >&2; exit 2; }
[[ -x "$CHECK_STRUCT" ]] || { echo "Missing: $CHECK_STRUCT" >&2; exit 2; }
[[ -x "$CHECK_GLOSSARY" ]] || { echo "Missing: $CHECK_GLOSSARY" >&2; exit 2; }
[[ -f "$BLACKLIST" ]] || { echo "Missing: $BLACKLIST" >&2; exit 2; }
[[ -f "$GLOSSARY" ]] || { echo "Missing: $GLOSSARY" >&2; exit 2; }

failures=0

echo "[validate] $DST"

# -----------------------------------------------------------------------------
# 0. Prompt-marker leakage check: Claude must not echo the BEGIN/END markers.
# -----------------------------------------------------------------------------
if grep -qE '<<<(BEGIN|END)_SOURCE_FILE>>>' "$DST"; then
    echo "[validate] FAIL: prompt markers leaked into the output (BEGIN/END_SOURCE_FILE)" >&2
    failures=$((failures + 1))
fi

if ! "$CHECK_REFS" --src "$SRC" --dst "$DST" --blacklist "$BLACKLIST" $CHECK_ANCHORS; then
    failures=$((failures + 1))
fi

if ! "$CHECK_STRUCT" --src "$SRC" --dst "$DST" --check-length; then
    failures=$((failures + 1))
fi

if ! "$CHECK_GLOSSARY" --glossary "$GLOSSARY" --file "$DST"; then
    failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
    echo "[validate] FAIL: $failures validator(s) failed for $DST" >&2
    exit 1
fi

echo "[validate] OK"
exit 0
