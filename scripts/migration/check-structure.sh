#!/usr/bin/env bash
# =============================================================================
# check-structure.sh — verify translated file preserves structural elements
#
# Compares src vs dst:
#   1. Heading counts per level (H1, H2, H3, H4, H5, H6)
#   2. Code fence count (``` and ~~~)
#   3. Frontmatter keys (top-level only) identical
#
# Usage:
#   check-structure.sh --src <file> --dst <file>
# =============================================================================

set -euo pipefail

SRC=""
DST=""
CHECK_LENGTH=false
LENGTH_TOLERANCE=25  # percent

while [[ $# -gt 0 ]]; do
    case "$1" in
        --src) SRC="$2"; shift 2 ;;
        --dst) DST="$2"; shift 2 ;;
        --check-length) CHECK_LENGTH=true; shift ;;
        --length-tolerance) LENGTH_TOLERANCE="$2"; shift 2 ;;
        -h|--help) head -13 "$0" | tail -12; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

[[ -z "$SRC" || -z "$DST" ]] && { echo "Usage: $0 --src <file> --dst <file>" >&2; exit 2; }
[[ -f "$SRC" ]] || { echo "Source file not found: $SRC" >&2; exit 2; }
[[ -f "$DST" ]] || { echo "Destination file not found: $DST" >&2; exit 2; }

errors=0

count_heading() {
    local file="$1"
    local level="$2"
    { grep -cE "^#{$level} " "$file" 2>/dev/null || true; } | tail -1
}

count_codefences() {
    local file="$1"
    { grep -cE '^(```|~~~)' "$file" 2>/dev/null || true; } | tail -1
}

extract_frontmatter_keys() {
    local file="$1"
    awk '
        BEGIN { in_fm = 0; lines = 0 }
        NR == 1 && /^---$/ { in_fm = 1; next }
        in_fm && /^---$/ { in_fm = 0; exit }
        in_fm {
            # Match top-level keys (no leading whitespace, key followed by colon)
            if (match($0, /^[A-Za-z_][A-Za-z0-9_-]*:/)) {
                key = substr($0, RSTART, RLENGTH - 1)
                print key
            }
        }
    ' "$file" | sort -u
}

# ---------------------------------------------------------------------------
# 1. Heading counts per level
# ---------------------------------------------------------------------------
for level in 1 2 3 4 5 6; do
    src_n=$(count_heading "$SRC" "$level")
    dst_n=$(count_heading "$DST" "$level")
    if [[ "$src_n" != "$dst_n" ]]; then
        echo "[check-structure] FAIL: H$level count differs (src=$src_n, dst=$dst_n)" >&2
        errors=$((errors + 1))
    fi
done

# ---------------------------------------------------------------------------
# 2. Code fence count
# ---------------------------------------------------------------------------
src_fences=$(count_codefences "$SRC")
dst_fences=$(count_codefences "$DST")
if [[ "$src_fences" != "$dst_fences" ]]; then
    echo "[check-structure] FAIL: code fence count differs (src=$src_fences, dst=$dst_fences)" >&2
    errors=$((errors + 1))
fi

# ---------------------------------------------------------------------------
# 3. Frontmatter keys identical
# ---------------------------------------------------------------------------
src_fm=$(extract_frontmatter_keys "$SRC")
dst_fm=$(extract_frontmatter_keys "$DST")

if [[ "$src_fm" != "$dst_fm" ]]; then
    echo "[check-structure] FAIL: frontmatter keys differ" >&2
    if [[ -n "$src_fm" || -n "$dst_fm" ]]; then
        diff <(echo "$src_fm") <(echo "$dst_fm") | sed 's/^/  /' >&2 || true
    fi
    errors=$((errors + 1))
fi

# ---------------------------------------------------------------------------
# 4. (Optional) Length sanity check (detect Claude truncation or expansion)
# ---------------------------------------------------------------------------
if $CHECK_LENGTH; then
    src_size=$(wc -c < "$SRC")
    dst_size=$(wc -c < "$DST")
    # Skip empty files (zero-length comparisons are noisy)
    if [[ $src_size -gt 0 ]]; then
        # Compute percent diff: |dst - src| / src * 100
        diff_pct=$(( (dst_size - src_size) * 100 / src_size ))
        abs_diff_pct=${diff_pct#-}
        if [[ $abs_diff_pct -gt $LENGTH_TOLERANCE ]]; then
            echo "[check-structure] FAIL: length differs by ${diff_pct}% (src=$src_size, dst=$dst_size, tolerance=${LENGTH_TOLERANCE}%)" >&2
            errors=$((errors + 1))
        fi
    fi
fi

if [[ $errors -gt 0 ]]; then
    echo "[check-structure] $errors error(s) detected" >&2
    exit 1
fi

exit 0
