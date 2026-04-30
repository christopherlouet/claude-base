#!/usr/bin/env bash
# =============================================================================
# check-glossary.sh — verify translated files respect the glossary.
#
# Two modes:
#   1. Default: scan EN files, fail if any forbidden translation appears.
#   2. --detect-drift: in addition, fail if same FR term has been translated
#      differently across files (drift detection).
#
# Code blocks (fenced ``` or ~~~) and inline backticks are excluded from
# the scan to avoid false positives on technical identifiers.
#
# Usage:
#   check-glossary.sh --glossary <yaml> --dir <dir> [--detect-drift]
#   check-glossary.sh --glossary <yaml> --file <file>
# =============================================================================

set -euo pipefail

GLOSSARY=""
SCAN_DIR=""
SCAN_FILE=""
DETECT_DRIFT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --glossary) GLOSSARY="$2"; shift 2 ;;
        --dir) SCAN_DIR="$2"; shift 2 ;;
        --file) SCAN_FILE="$2"; shift 2 ;;
        --detect-drift) DETECT_DRIFT=true; shift ;;
        -h|--help) head -16 "$0" | tail -15; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

[[ -z "$GLOSSARY" ]] && { echo "--glossary required" >&2; exit 2; }
[[ -f "$GLOSSARY" ]] || { echo "Glossary not found: $GLOSSARY" >&2; exit 2; }
[[ -z "$SCAN_DIR" && -z "$SCAN_FILE" ]] && { echo "--dir or --file required" >&2; exit 2; }

errors=0

# ---------------------------------------------------------------------------
# Build file list
# ---------------------------------------------------------------------------
files=()
if [[ -n "$SCAN_FILE" ]]; then
    [[ -f "$SCAN_FILE" ]] || { echo "File not found: $SCAN_FILE" >&2; exit 2; }
    files+=("$SCAN_FILE")
elif [[ -n "$SCAN_DIR" ]]; then
    [[ -d "$SCAN_DIR" ]] || { echo "Directory not found: $SCAN_DIR" >&2; exit 2; }
    while IFS= read -r f; do files+=("$f"); done < <(find "$SCAN_DIR" -type f \( -name "*.md" -o -name "*.mdx" \))
fi

[[ ${#files[@]} -eq 0 ]] && { exit 0; }

# ---------------------------------------------------------------------------
# Strip code blocks and inline code from a file (write to stdout).
# Removes:
#   - Lines between ``` and next ``` (or ~~~)
#   - Inline backtick spans `...`
# ---------------------------------------------------------------------------
strip_code() {
    local file="$1"
    awk '
        /^(```|~~~)/ {
            in_code = !in_code
            next
        }
        !in_code {
            # Remove inline code spans `...`
            gsub(/`[^`]*`/, "")
            print
        }
    ' "$file"
}

# ---------------------------------------------------------------------------
# Parse glossary with python (yaml is reliable). Output format:
#   <fr_term>\t<en_term>\t<forbidden_terms_csv>\t<locked>
# ---------------------------------------------------------------------------
parse_glossary() {
    python3 <<EOF
import yaml
with open("$GLOSSARY") as f:
    d = yaml.safe_load(f) or {}
locked_at = d.get('locked_at')
for t in d.get('terms', []):
    fr = t.get('fr', '')
    en = t.get('en', '')
    forbidden = ','.join(t.get('forbidden', []))
    locked = 'true' if (t.get('locked') or locked_at) else 'false'
    if fr and en:
        print(f"{fr}\t{en}\t{forbidden}\t{locked}")
EOF
}

# ---------------------------------------------------------------------------
# Word-bounded count of $term in stripped content of $file.
# ---------------------------------------------------------------------------
count_term_stripped() {
    local file="$1"
    local term="$2"
    local escaped
    escaped=$(printf '%s' "$term" | sed -e 's/[][\.*^$+?(){}|/]/\\&/g')
    { strip_code "$file" | grep -ioE "(^|[^A-Za-z0-9_-])${escaped}([^A-Za-z0-9_-]|$)" 2>/dev/null || true; } | wc -l
}

# ---------------------------------------------------------------------------
# 1. Forbidden translation detection (per file, per term)
# ---------------------------------------------------------------------------
while IFS=$'\t' read -r fr en forbidden locked; do
    [[ -z "$forbidden" ]] && continue
    IFS=',' read -ra forbidden_arr <<< "$forbidden"
    for forb in "${forbidden_arr[@]}"; do
        [[ -z "$forb" ]] && continue
        for f in "${files[@]}"; do
            n=$(count_term_stripped "$f" "$forb")
            if [[ "$n" -gt 0 ]]; then
                lock_label=""
                [[ "$locked" == "true" ]] && lock_label=" (LOCKED)"
                echo "[check-glossary] FAIL${lock_label}: forbidden translation '$forb' found in $f (canonical: '$fr' -> '$en')" >&2
                errors=$((errors + 1))
            fi
        done
    done
done < <(parse_glossary)

# ---------------------------------------------------------------------------
# 2. Drift detection (same FR term, different EN translations across files)
#    For each (fr, en) entry, scan files and ensure that whenever forbidden
#    terms appear, they're flagged. Drift detection is a refinement: when
#    multiple forbidden terms appear in different files, that's a stronger
#    signal of drift.
# ---------------------------------------------------------------------------
if $DETECT_DRIFT; then
    while IFS=$'\t' read -r fr en forbidden locked; do
        [[ -z "$forbidden" ]] && continue
        IFS=',' read -ra forbidden_arr <<< "$forbidden"

        # Collect files containing canonical en + each forbidden form
        canonical_files=()
        forbidden_files=()
        for f in "${files[@]}"; do
            if [[ $(count_term_stripped "$f" "$en") -gt 0 ]]; then
                canonical_files+=("$f")
            fi
            for forb in "${forbidden_arr[@]}"; do
                [[ -z "$forb" ]] && continue
                if [[ $(count_term_stripped "$f" "$forb") -gt 0 ]]; then
                    forbidden_files+=("$f")
                fi
            done
        done

        # Drift = canonical AND forbidden both appear (different files)
        if [[ ${#canonical_files[@]} -gt 0 && ${#forbidden_files[@]} -gt 0 ]]; then
            echo "[check-glossary] DRIFT: '$fr' translated as '$en' in ${#canonical_files[@]} file(s) but as forbidden form in ${#forbidden_files[@]} file(s)" >&2
            errors=$((errors + 1))
        fi
    done < <(parse_glossary)
fi

if [[ $errors -gt 0 ]]; then
    echo "[check-glossary] $errors error(s) detected" >&2
    exit 1
fi

exit 0
