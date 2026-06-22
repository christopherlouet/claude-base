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
#                                   lessons and "RECUR N: <line>" for lessons that
#                                   carry a "(seen N times)" recurrence marker.
#                                   Section-aware: "## " topic headings are never
#                                   treated as lessons, and "foo" / "foo (seen N
#                                   times)" dedupe to the same lesson. STORE
#                                   defaults to ~/.claude/rules/lessons.md, BUDGET
#                                   to 2000.
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

    if [ -f "$store" ]; then
        # Recurrence signal (US-9): surface lessons carrying a "(seen N times)"
        # marker so the most-repeated ones are easy to spot and prioritize.
        local recur
        recur=$(awk '{
            if (match($0, /\(seen[[:space:]]+[0-9]+[[:space:]]+times\)/)) {
                seg=substr($0, RSTART, RLENGTH); gsub(/[^0-9]/, "", seg)
                line=$0; sub(/^[[:space:]]+/, "", line); sub(/[[:space:]]+$/, "", line)
                printf "RECUR %s: %s\n", seg, line
            }
        }' "$store" || true)
        [ -n "$recur" ] && printf '%s\n' "$recur"

        # Duplicate lessons, SECTION- and RECURRENCE-aware: skip "## " topic
        # headings (US-8 — only lessons are deduped, never headings), and
        # normalize away the list marker and any "(seen N times)" marker so that
        # "foo" and "foo (seen 2 times)" are the SAME lesson (the user merges
        # them into one recurrence-bumped line). Reported once each.
        local dups
        dups=$(grep -vE '^[[:space:]]*$' "$store" \
            | grep -vE '^[[:space:]]*#{1,6}[[:space:]]' \
            | awk '{
                disp=$0; sub(/^[[:space:]]+/, "", disp); sub(/[[:space:]]+$/, "", disp)
                key=tolower(disp)
                sub(/^[-*+][[:space:]]+/, "", key)
                sub(/[[:space:]]*\(seen[[:space:]]+[0-9]+[[:space:]]+times\)$/, "", key)
                seen[key]++
                if (seen[key]==2) print disp
              }' || true)
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
