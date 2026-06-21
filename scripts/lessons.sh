#!/usr/bin/env bash

# =============================================================================
# scripts/lessons.sh — deterministic helpers for the personal lessons referential
#
# The model-judgment parts (generalize / sanitize / confirm a lesson) live in the
# /lessons command. This script only does the deterministic file work so it can
# be tested and reused:
#
#   bootstrap-scan [MEMORY_ROOT]    List feedback memories across all projects as
#                                   promotion candidates (TSV: project<TAB>name<TAB>description).
#                                   MEMORY_ROOT defaults to ~/.claude.
#   prune-check    [STORE] [BUDGET] Check the lessons store against a byte budget;
#                                   prints "OK size/budget" or "OVER size/budget"
#                                   (non-zero), plus "DUP: <line>" for duplicate
#                                   lesson lines. STORE defaults to
#                                   ~/.claude/rules/lessons.md, BUDGET to 2000.
# =============================================================================

set -euo pipefail

DEFAULT_MEMORY_ROOT="${HOME}/.claude"
DEFAULT_STORE="${HOME}/.claude/rules/lessons.md"
DEFAULT_BUDGET=2000

# Extract a top-level frontmatter scalar (e.g. name:, description:), unquoted.
_fm() {
    local file="$1" key="$2"
    # Strip a trailing CR (CRLF files) before unquoting, so it never leaks into TSV.
    sed -n "s/^${key}:[[:space:]]*//p" "$file" | head -n1 | sed -e 's/\r$//' -e 's/^"//' -e 's/"$//'
}

cmd_bootstrap_scan() {
    local root="${1:-$DEFAULT_MEMORY_ROOT}"
    local projects="$root/projects"
    [ -d "$projects" ] || return 0

    local mem proj name desc
    while IFS= read -r mem; do
        [ -e "$mem" ] || continue
        # The MEMORY.md index is not a lesson; skip it.
        case "$(basename "$mem")" in MEMORY.md) continue ;; esac
        # Keep only feedback-type memories (a real "type: feedback" frontmatter line).
        grep -qE '^[[:space:]]*type:[[:space:]]*feedback[[:space:]]*$' "$mem" || continue
        # Project slug = the dir two levels up: …/<slug>/memory/<file>.
        proj="$(basename "$(dirname "$(dirname "$mem")")")"
        name="$(_fm "$mem" name)"
        desc="$(_fm "$mem" description)"
        printf '%s\t%s\t%s\n' "$proj" "$name" "$desc"
    done < <(find "$projects" -type f -name '*.md' 2>/dev/null | sort)
}

cmd_prune_check() {
    local store="${1:-$DEFAULT_STORE}"
    local budget="${2:-$DEFAULT_BUDGET}"

    local size=0
    [ -f "$store" ] && size=$(wc -c < "$store" | tr -d '[:space:]')

    # Duplicate lesson lines (normalized: trim + lowercase), reported once each.
    if [ -f "$store" ]; then
        local dups
        dups=$(grep -vE '^[[:space:]]*$' "$store" \
            | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
            | awk '{ key=tolower($0); seen[key]++; if (seen[key]==2) print $0 }')
        if [ -n "$dups" ]; then
            while IFS= read -r d; do
                [ -z "$d" ] && continue
                printf 'DUP: %s\n' "$d"
            done <<< "$dups"
        fi
    fi

    if [ "$size" -gt "$budget" ]; then
        printf 'OVER %s/%s\n' "$size" "$budget"
        return 1
    fi
    printf 'OK %s/%s\n' "$size" "$budget"
}

usage() {
    printf 'Usage: lessons.sh {bootstrap-scan [MEMORY_ROOT] | prune-check [STORE] [BUDGET]}\n'
}

main() {
    local sub="${1:-}"
    shift || true
    case "$sub" in
        bootstrap-scan) cmd_bootstrap_scan "$@" ;;
        prune-check)    cmd_prune_check "$@" ;;
        -h|--help)      usage ;;
        "")             usage >&2; return 1 ;;
        *)              printf 'Unknown subcommand: %s\n' "$sub" >&2; usage >&2; return 2 ;;
    esac
}

main "$@"
