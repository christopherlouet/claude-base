#!/usr/bin/env bash
# =============================================================================
# status.sh — show migration progress dashboard.
#
# Reads:
#   - specs/migration-fr-en/inventory.json (per-tier file lists)
#   - specs/migration-fr-en/state-tier-N.json (per-tier progress, if exists)
#   - git log on migration-en/tier-N branches (recent commit timestamps)
#
# Usage:
#   status.sh                   # all tiers
#   status.sh --tier <N>        # one tier
#   status.sh --watch           # refresh every 30s
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$REPO_ROOT/specs/migration-fr-en"

TIER=""
WATCH=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier) TIER="$2"; shift 2 ;;
        --watch) WATCH=true; shift ;;
        -h|--help) head -14 "$0" | tail -13; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 2; }
[[ -f "$SPEC_DIR/inventory.json" ]] || { echo "Inventory missing: $SPEC_DIR/inventory.json" >&2; exit 2; }

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

show_tier() {
    local tier="$1"
    local label
    local total_files
    local total_words
    label=$(jq -r ".tiers[\"$tier\"].label" "$SPEC_DIR/inventory.json")
    total_files=$(jq -r ".tiers[\"$tier\"].files_count" "$SPEC_DIR/inventory.json")
    total_words=$(jq -r ".tiers[\"$tier\"].words" "$SPEC_DIR/inventory.json")

    echo -e "${BOLD}Tier $tier${NC} — $label"
    echo "  Inventory: $total_files files, $total_words words"

    local state_file="$SPEC_DIR/state-tier-$tier.json"
    if [[ ! -f "$state_file" ]]; then
        echo -e "  Status: ${YELLOW}not started${NC} (no state file)"
        echo ""
        return
    fi

    local todo draft reviewed merged total
    todo=$(jq '[.files[] | select(.status == "todo")] | length' "$state_file")
    draft=$(jq '[.files[] | select(.status == "draft")] | length' "$state_file")
    reviewed=$(jq '[.files[] | select(.status == "reviewed")] | length' "$state_file")
    merged=$(jq '[.files[] | select(.status == "merged")] | length' "$state_file")
    total=$(jq '.files | length' "$state_file")

    local pct=0
    if [[ $total -gt 0 ]]; then
        pct=$(( (draft + reviewed + merged) * 100 / total ))
    fi

    # Progress bar (20 chars wide)
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    local bar=""
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    for ((i = 0; i < empty; i++)); do bar+="░"; done

    local color="$YELLOW"
    [[ $pct -ge 100 ]] && color="$GREEN"
    [[ $pct -lt 25 ]] && color="$RED"

    echo -e "  Progress: ${color}${bar} ${pct}%${NC}"
    echo "  todo=$todo  draft=$draft  reviewed=$reviewed  merged=$merged  total=$total"

    # Latest commit on the corresponding branch
    local branch="migration-en/tier-$tier"
    local latest_commit
    latest_commit=$(cd "$REPO_ROOT" && git log -1 --format="%h %s (%cr)" "$branch" 2>/dev/null || echo "")
    if [[ -n "$latest_commit" ]]; then
        echo "  Latest: $latest_commit"
    fi

    echo ""
}

show_overall() {
    local total_drafts=0
    local total_files=0
    for t in 1 2 3 4; do
        local state_file="$SPEC_DIR/state-tier-$t.json"
        if [[ -f "$state_file" ]]; then
            local d
            local n
            d=$(jq '[.files[] | select(.status == "draft" or .status == "reviewed" or .status == "merged")] | length' "$state_file")
            n=$(jq '.files | length' "$state_file")
            total_drafts=$((total_drafts + d))
            total_files=$((total_files + n))
        else
            local n
            n=$(jq -r ".tiers[\"$t\"].files_count" "$SPEC_DIR/inventory.json")
            total_files=$((total_files + n))
        fi
    done

    local pct=0
    [[ $total_files -gt 0 ]] && pct=$((total_drafts * 100 / total_files))

    echo -e "${BOLD}${BLUE}=== Migration FR→EN — Overall ===${NC}"
    echo "  Translated: $total_drafts / $total_files files (${pct}%)"
    echo ""
}

run_once() {
    show_overall
    if [[ -n "$TIER" ]]; then
        show_tier "$TIER"
    else
        for t in 1 2 3 4; do
            show_tier "$t"
        done
    fi
}

if $WATCH; then
    while true; do
        clear
        run_once
        echo "Refreshing every 30s. Ctrl-C to exit."
        sleep 30
    done
else
    run_once
fi
