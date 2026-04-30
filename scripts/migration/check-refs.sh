#!/usr/bin/env bash
# =============================================================================
# check-refs.sh — verify translated file preserves internal references
#
# Checks (when --src and --dst differ):
#   1. Every blacklist term that appears in src must appear (same count) in dst.
#   2. Same for slash commands and file paths detected in src.
#
# Optional check (--check-anchors):
#   3. Every markdown anchor link [text](#anchor) in dst points to an
#      existing heading in dst (slugified).
#
# Word-boundary matching: a substring like /work:work-explore is not counted
# inside /work:work-explorer (boundary chars: anything not [A-Za-z0-9_-]).
#
# Usage:
#   check-refs.sh --src <file> --dst <file> --blacklist <file>
#   check-refs.sh --src <file> --dst <file> --blacklist <file> --check-anchors
# =============================================================================

set -euo pipefail

SRC=""
DST=""
BLACKLIST=""
CHECK_ANCHORS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --src) SRC="$2"; shift 2 ;;
        --dst) DST="$2"; shift 2 ;;
        --blacklist) BLACKLIST="$2"; shift 2 ;;
        --check-anchors) CHECK_ANCHORS=true; shift ;;
        -h|--help) head -22 "$0" | tail -21; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

if [[ -z "$SRC" || -z "$DST" || -z "$BLACKLIST" ]]; then
    echo "Usage: $0 --src <file> --dst <file> --blacklist <file> [--check-anchors]" >&2
    exit 2
fi

[[ -f "$SRC" ]] || { echo "Source file not found: $SRC" >&2; exit 2; }
[[ -f "$DST" ]] || { echo "Destination file not found: $DST" >&2; exit 2; }
[[ -f "$BLACKLIST" ]] || { echo "Blacklist not found: $BLACKLIST" >&2; exit 2; }

errors=0

# ---------------------------------------------------------------------------
# Word-bounded count of $term in $file. Boundary = not [A-Za-z0-9_-].
# ---------------------------------------------------------------------------
count_term() {
    local file="$1"
    local term="$2"
    local escaped
    escaped=$(printf '%s' "$term" | sed -e 's/[][\.*^$+?(){}|/]/\\&/g')
    # grep -oE: count actual occurrences (not just matching lines).
    # `|| true` shields against grep exit 1 (no match) under set -e + pipefail.
    { grep -oE "(^|[^A-Za-z0-9_-])${escaped}([^A-Za-z0-9_-]|$)" "$file" 2>/dev/null || true; } | wc -l
}

# ---------------------------------------------------------------------------
# 1. Blacklist preservation
# ---------------------------------------------------------------------------
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    term="$line"
    src_count=$(count_term "$SRC" "$term")
    dst_count=$(count_term "$DST" "$term")
    if [[ "$src_count" -gt 0 && "$dst_count" -lt "$src_count" ]]; then
        echo "[check-refs] FAIL: blacklist term '$term' appears $src_count time(s) in src but only $dst_count in dst" >&2
        errors=$((errors + 1))
    fi
done < "$BLACKLIST"

# ---------------------------------------------------------------------------
# 2. Slash command pattern preservation (catches commands not in blacklist).
# ---------------------------------------------------------------------------
src_slash=$(grep -oE '/[a-z]+:[a-z][a-z0-9-]+' "$SRC" 2>/dev/null | sort -u || true)
while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue
    src_n=$(count_term "$SRC" "$cmd")
    dst_n=$(count_term "$DST" "$cmd")
    if [[ "$src_n" -gt 0 && "$dst_n" -lt "$src_n" ]]; then
        echo "[check-refs] FAIL: slash command '$cmd' appears $src_n time(s) in src but only $dst_n in dst" >&2
        errors=$((errors + 1))
    fi
done <<< "$src_slash"

# ---------------------------------------------------------------------------
# 3. File path pattern preservation — only enforce paths that EXIST on disk.
#    FR docs use placeholder paths like 'mon-framework.md' or
#    'chemin/vers/fichier.md' as examples; these legitimately get translated.
#    We only require preservation when the path resolves to a real file at
#    the repo root.
# ---------------------------------------------------------------------------
REPO_ROOT="$(cd "$(dirname "$SRC")" && git rev-parse --show-toplevel 2>/dev/null || pwd)"
src_paths=$(grep -oE '[a-zA-Z0-9._/-]+\.(md|sh|ts|tsx|js|jsx|json|yaml|yml|py|go|rs|dart|astro|svelte|vue|toml)' "$SRC" 2>/dev/null | sort -u || true)
while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    [[ ${#path} -lt 3 ]] && continue
    # Skip placeholder paths that don't exist in the repo.
    if [[ ! -e "$REPO_ROOT/$path" && ! -e "$path" ]]; then
        continue
    fi
    src_n=$(count_term "$SRC" "$path")
    dst_n=$(count_term "$DST" "$path")
    if [[ "$src_n" -gt 0 && "$dst_n" -lt "$src_n" ]]; then
        echo "[check-refs] FAIL: file path '$path' appears $src_n time(s) in src but only $dst_n in dst" >&2
        errors=$((errors + 1))
    fi
done <<< "$src_paths"

# ---------------------------------------------------------------------------
# 4. (Optional) Anchor validation: [text](#anchor) must point to existing
#    heading in dst.
# ---------------------------------------------------------------------------
if $CHECK_ANCHORS; then
    headings=$(grep -E '^#{1,6} ' "$DST" 2>/dev/null \
        | sed -E 's/^#+\s+//' \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9 -]//g' \
        | sed -E 's/ +/-/g' \
        | sort -u || true)

    anchors=$(grep -oE '\]\(#[a-z0-9-]+\)' "$DST" 2>/dev/null \
        | sed -E 's/^\]\(#//; s/\)$//' \
        | sort -u || true)

    while IFS= read -r anchor; do
        [[ -z "$anchor" ]] && continue
        if ! grep -qxF "$anchor" <<< "$headings"; then
            echo "[check-refs] FAIL: anchor '#$anchor' has no matching heading in $DST" >&2
            errors=$((errors + 1))
        fi
    done <<< "$anchors"
fi

if [[ $errors -gt 0 ]]; then
    echo "[check-refs] $errors error(s) detected" >&2
    exit 1
fi

exit 0
