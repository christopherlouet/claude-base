#!/usr/bin/env bash

# =============================================================================
# Claude-Base Preset Detection Library
# Data-driven scan of preset manifests against a target directory.
# See specs/presets-detection-and-e2e/spec.md for the rule schema.
# =============================================================================

# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

# scan_presets <target_dir>
#
# Iterates over every preset manifest under PRESETS_DIR (default
# $BASE_DIR/.claude/presets/, including community/), evaluates each manifest's
# `detect` block against <target_dir>, and prints the names of matching
# presets to stdout (one per line, alphabetical order).
#
# A preset without a `detect` block is silent (never auto-suggested).
# A preset with a malformed `detect` block is skipped (does not break the scan).
# When jq is unavailable, the function exits 0 with no output (graceful).
#
# Arguments:
#   $1 - Target directory to scan (absolute path expected)
# Environment:
#   PRESETS_DIR - override the default presets directory (used by tests)
# Outputs:
#   stdout: matching preset names, one per line, sorted alphabetically
# Returns:
#   0 always (errors degrade to silent no-match)
scan_presets() {
    local target_dir="$1"
    [[ -d "$target_dir" ]] || return 0
    command -v jq >/dev/null 2>&1 || return 0

    local presets_dir="${PRESETS_DIR:-$BASE_DIR/.claude/presets}"
    [[ -d "$presets_dir" ]] || return 0

    local file
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        _evaluate_preset "$file" "$target_dir"
    done < <(find "$presets_dir" -maxdepth 2 -name "*.json" -type f 2>/dev/null | sort)
}

# Internal: evaluate a single preset manifest against a target dir.
# Prints the preset's name to stdout if its detect rule matches.
# Returns 0 always (any error degrades to silent skip).
_evaluate_preset() {
    local file="$1"
    local target_dir="$2"

    # Skip if the manifest has no detect block.
    jq -e '.detect' "$file" >/dev/null 2>&1 || return 0
    # Skip if detect is not an object (malformed).
    [[ "$(jq -r '.detect | type' "$file" 2>/dev/null)" = "object" ]] || return 0

    local name
    name=$(jq -r '.name // empty' "$file")
    [[ -n "$name" ]] || return 0

    local combinator
    combinator=$(jq -r '.detect.combinator // "anyOf"' "$file")
    case "$combinator" in
        allOf|anyOf) ;;
        *) return 0 ;;
    esac

    # Collect per-signal results into a flat array of "match" / "miss".
    local results=()

    # Files signals
    local files_n
    files_n=$(jq -r '(.detect.files // []) | length' "$file" 2>/dev/null)
    if [[ -n "$files_n" && "$files_n" -gt 0 ]]; then
        local i fname
        for i in $(seq 0 $((files_n - 1))); do
            fname=$(jq -r ".detect.files[$i] // empty" "$file")
            [[ -z "$fname" ]] && continue
            if find "$target_dir" -maxdepth 2 -name "$fname" -type f 2>/dev/null | head -1 | grep -q .; then
                results+=("match")
            else
                results+=("miss")
            fi
        done
    fi

    # depFiles signals (file exists AND case-insensitive substring match)
    local deps_n
    deps_n=$(jq -r '(.detect.depFiles // []) | length' "$file" 2>/dev/null)
    if [[ -n "$deps_n" && "$deps_n" -gt 0 ]]; then
        local di dpath dcontains
        for di in $(seq 0 $((deps_n - 1))); do
            dpath=$(jq -r ".detect.depFiles[$di].path // empty" "$file")
            dcontains=$(jq -r ".detect.depFiles[$di].contains // empty" "$file")
            [[ -z "$dpath" || -z "$dcontains" ]] && continue
            if [[ -f "$target_dir/$dpath" ]] && grep -qiF -- "$dcontains" "$target_dir/$dpath" 2>/dev/null; then
                results+=("match")
            else
                results+=("miss")
            fi
        done
    fi

    # No usable signals → skip (the validator should have caught this; guard
    # here for malformed presets that slipped through).
    [[ "${#results[@]}" -eq 0 ]] && return 0

    local matched=0
    local r
    if [[ "$combinator" = "allOf" ]]; then
        matched=1
        for r in "${results[@]}"; do
            [[ "$r" = "miss" ]] && { matched=0; break; }
        done
    else  # anyOf
        for r in "${results[@]}"; do
            [[ "$r" = "match" ]] && { matched=1; break; }
        done
    fi

    [[ "$matched" = "1" ]] && echo "$name"
    return 0
}
