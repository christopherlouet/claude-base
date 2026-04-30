#!/usr/bin/env bash
# =============================================================================
# recovery.sh — checkpoint state for translate-batch.sh
#
# Subcommands:
#   init           Create state.json from inventory.json (status: todo).
#   list-pending   List paths still needing translation (status != draft).
#   mark-done      Mark a file as draft (translated successfully).
#
# State format (state.json):
#   {
#     "tier": 1,
#     "files": [
#       { "path": "README.md", "status": "todo|draft|reviewed|merged",
#         "checksum_source": "<sha256>" }
#     ]
#   }
#
# Usage:
#   recovery.sh init --tier <N> --inventory <file> --state <file> [--root <dir>]
#   recovery.sh list-pending --state <file>
#   recovery.sh mark-done --state <file> --file <path>
# =============================================================================

set -euo pipefail

require_jq() {
    command -v jq >/dev/null 2>&1 || { echo "jq is required for $1" >&2; exit 2; }
}

cmd_init() {
    local tier="" inventory="" state="" root=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --tier) tier="$2"; shift 2 ;;
            --inventory) inventory="$2"; shift 2 ;;
            --state) state="$2"; shift 2 ;;
            --root) root="$2"; shift 2 ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$tier" || -z "$inventory" || -z "$state" ]] && {
        echo "Usage: recovery.sh init --tier <N> --inventory <file> --state <file> [--root <dir>]" >&2
        exit 2
    }
    require_jq "init"
    [[ -f "$inventory" ]] || { echo "Inventory not found: $inventory" >&2; exit 2; }

    # Build files array with checksums
    local tmpf
    tmpf=$(mktemp)
    {
        echo "{"
        echo "  \"tier\": $tier,"
        echo "  \"files\": ["
        local first=true
        while IFS= read -r path; do
            [[ -z "$path" ]] && continue
            local checksum=""
            if [[ -n "$root" && -f "$root/$path" ]]; then
                checksum=$(sha256sum "$root/$path" | awk '{print $1}')
            elif [[ -f "$path" ]]; then
                checksum=$(sha256sum "$path" | awk '{print $1}')
            fi
            if $first; then first=false; else echo ","; fi
            printf '    {"path": "%s", "status": "todo", "checksum_source": "%s"}' "$path" "$checksum"
        done < <(jq -r ".tiers[\"$tier\"].files[]" "$inventory")
        echo
        echo "  ]"
        echo "}"
    } > "$tmpf"
    mv "$tmpf" "$state"
    echo "[recovery] Initialized $state for tier $tier with $(jq '.files | length' "$state") files"
}

cmd_list_pending() {
    local state=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$state" ]] && { echo "Usage: recovery.sh list-pending --state <file>" >&2; exit 2; }
    require_jq "list-pending"
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }
    jq -r '.files[] | select(.status == "todo" or .status == "in-progress") | .path' "$state"
}

cmd_mark_done() {
    local state="" file=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            --file) file="$2"; shift 2 ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$state" || -z "$file" ]] && {
        echo "Usage: recovery.sh mark-done --state <file> --file <path>" >&2
        exit 2
    }
    require_jq "mark-done"
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }

    local tmpf
    tmpf=$(mktemp)
    jq --arg p "$file" '.files |= map(if .path == $p then .status = "draft" else . end)' "$state" > "$tmpf"
    mv "$tmpf" "$state"
    echo "[recovery] Marked $file as draft in $state"
}

cmd_mark_todo() {
    local state="" file=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            --file) file="$2"; shift 2 ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$state" || -z "$file" ]] && {
        echo "Usage: recovery.sh mark-todo --state <file> --file <path>" >&2
        exit 2
    }
    require_jq "mark-todo"
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }

    local tmpf
    tmpf=$(mktemp)
    jq --arg p "$file" '.files |= map(if .path == $p then .status = "todo" else . end)' "$state" > "$tmpf"
    mv "$tmpf" "$state"
    echo "[recovery] Reset $file to todo in $state (will be re-translated next run)"
}

cmd_mark_reviewed() {
    local state="" file="" all=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            --file) file="$2"; shift 2 ;;
            --all) all=true; shift ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$state" ]] && { echo "--state is required" >&2; exit 2; }
    require_jq "mark-reviewed"
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }

    if $all; then
        local tmpf
        tmpf=$(mktemp)
        jq '.files |= map(if .status == "draft" then .status = "reviewed" else . end)' "$state" > "$tmpf"
        mv "$tmpf" "$state"
        local n
        n=$(jq '[.files[] | select(.status == "reviewed")] | length' "$state")
        echo "[recovery] Bumped all draft files to reviewed (total reviewed: $n)"
        return 0
    fi

    [[ -z "$file" ]] && { echo "Either --file or --all required" >&2; exit 2; }

    # Refuse if file is not currently draft
    local cur
    cur=$(jq -r --arg p "$file" '.files[] | select(.path == $p) | .status' "$state")
    if [[ "$cur" != "draft" ]]; then
        echo "[recovery] FAIL: $file has status '$cur', expected 'draft' (reviewed only follows draft)" >&2
        exit 1
    fi

    local tmpf
    tmpf=$(mktemp)
    jq --arg p "$file" '.files |= map(if .path == $p then .status = "reviewed" else . end)' "$state" > "$tmpf"
    mv "$tmpf" "$state"
    echo "[recovery] Bumped $file to reviewed in $state"
}

cmd_mark_merged() {
    local state="" file="" all=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            --file) file="$2"; shift 2 ;;
            --all) all=true; shift ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done
    [[ -z "$state" ]] && { echo "--state is required" >&2; exit 2; }
    require_jq "mark-merged"
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }

    if $all; then
        local tmpf
        tmpf=$(mktemp)
        jq '.files |= map(if .status == "reviewed" then .status = "merged" else . end)' "$state" > "$tmpf"
        mv "$tmpf" "$state"
        local n
        n=$(jq '[.files[] | select(.status == "merged")] | length' "$state")
        echo "[recovery] Bumped all reviewed files to merged (total merged: $n)"
        return 0
    fi

    [[ -z "$file" ]] && { echo "Either --file or --all required" >&2; exit 2; }

    local cur
    cur=$(jq -r --arg p "$file" '.files[] | select(.path == $p) | .status' "$state")
    if [[ "$cur" != "reviewed" ]]; then
        echo "[recovery] FAIL: $file has status '$cur', expected 'reviewed' (merged only follows reviewed)" >&2
        exit 1
    fi

    local tmpf
    tmpf=$(mktemp)
    jq --arg p "$file" '.files |= map(if .path == $p then .status = "merged" else . end)' "$state" > "$tmpf"
    mv "$tmpf" "$state"
    echo "[recovery] Bumped $file to merged in $state"
}

cmd_stats() {
    local state=""
    local all_tiers=false
    local dir=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --state) state="$2"; shift 2 ;;
            --all-tiers) all_tiers=true; shift ;;
            --dir) dir="$2"; shift 2 ;;
            *) echo "Unknown arg: $1" >&2; exit 2 ;;
        esac
    done

    require_jq "stats"

    if $all_tiers; then
        # Default dir: specs/migration-fr-en
        if [[ -z "$dir" ]]; then
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            dir="$script_dir/../../specs/migration-fr-en"
        fi
        [[ -d "$dir" ]] || { echo "Directory not found: $dir" >&2; exit 2; }

        local total=0 todo=0 draft=0 reviewed=0 merged=0
        for f in "$dir"/state-tier-*.json; do
            [[ -f "$f" ]] || continue
            total=$((total + $(jq '.files | length' "$f")))
            todo=$((todo + $(jq '[.files[] | select(.status == "todo")] | length' "$f")))
            draft=$((draft + $(jq '[.files[] | select(.status == "draft")] | length' "$f")))
            reviewed=$((reviewed + $(jq '[.files[] | select(.status == "reviewed")] | length' "$f")))
            merged=$((merged + $(jq '[.files[] | select(.status == "merged")] | length' "$f")))
        done

        echo "[recovery] stats (all tiers): total=$total todo=$todo draft=$draft reviewed=$reviewed merged=$merged"
        return 0
    fi

    [[ -z "$state" ]] && { echo "Usage: recovery.sh stats --state <file> | --all-tiers [--dir <dir>]" >&2; exit 2; }
    [[ -f "$state" ]] || { echo "State not found: $state" >&2; exit 2; }

    local total
    total=$(jq '.files | length' "$state")
    local todo draft reviewed merged
    todo=$(jq '[.files[] | select(.status == "todo")] | length' "$state")
    draft=$(jq '[.files[] | select(.status == "draft")] | length' "$state")
    reviewed=$(jq '[.files[] | select(.status == "reviewed")] | length' "$state")
    merged=$(jq '[.files[] | select(.status == "merged")] | length' "$state")
    echo "[recovery] stats: total=$total todo=$todo draft=$draft reviewed=$reviewed merged=$merged"
}

# Main dispatcher
[[ $# -lt 1 ]] && { echo "Usage: recovery.sh <init|list-pending|mark-done|mark-todo|mark-reviewed|mark-merged|stats> [args...]" >&2; exit 2; }
subcmd="$1"; shift
case "$subcmd" in
    init) cmd_init "$@" ;;
    list-pending) cmd_list_pending "$@" ;;
    mark-done) cmd_mark_done "$@" ;;
    mark-todo) cmd_mark_todo "$@" ;;
    mark-reviewed) cmd_mark_reviewed "$@" ;;
    mark-merged) cmd_mark_merged "$@" ;;
    stats) cmd_stats "$@" ;;
    -h|--help) head -28 "$0" | tail -27; exit 0 ;;
    *) echo "Unknown subcommand: $subcmd" >&2; exit 2 ;;
esac
