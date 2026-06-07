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

# resolve_preset_file <name>
#
# Resolve a preset name to its JSON manifest path. Lookup order:
#   1. PRESETS_DIR_OVERRIDE (tests inject synthetic presets without touching
#      the official tree)
#   2. official presets dir ($BASE_DIR/.claude/presets/)
#   3. community/ subdirectory
# Output: path to the .json file, or empty if not found (status 0 either
# way — callers test output non-emptiness).
resolve_preset_file() {
    local name="$1"
    if [[ -n "${PRESETS_DIR_OVERRIDE:-}" ]]; then
        local override_file="$PRESETS_DIR_OVERRIDE/$name.json"
        if [[ -f "$override_file" ]]; then
            echo "$override_file"
            return
        fi
    fi
    local official="$BASE_DIR/.claude/presets/$name.json"
    local community="$BASE_DIR/.claude/presets/community/$name.json"
    if [[ -f "$official" ]]; then
        echo "$official"
    elif [[ -f "$community" ]]; then
        echo "$community"
    else
        echo ""
    fi
}

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

    # depFiles signals (file exists AND case-insensitive substring match).
    # Dogfood finding #8 (specs/dogfood-v2-findings/spec.md): use `find
    # -maxdepth 3` (one level deeper than the `files` signal above) to
    # cover common IaC layouts like `infrastructure/proxmox/versions.tf`
    # — IaC projects routinely place .tf files at depth 3 under
    # infrastructure/<provider>/, while .config files in `files` stay
    # near the root (depth 2 is enough). A subdir file with non-matching
    # content correctly produces a miss (the content grep is still
    # authoritative — see the friction-#8 regression test).
    local deps_n
    deps_n=$(jq -r '(.detect.depFiles // []) | length' "$file" 2>/dev/null)
    if [[ -n "$deps_n" && "$deps_n" -gt 0 ]]; then
        local di dpath dcontains dfound dmatched
        for di in $(seq 0 $((deps_n - 1))); do
            dpath=$(jq -r ".detect.depFiles[$di].path // empty" "$file")
            dcontains=$(jq -r ".detect.depFiles[$di].contains // empty" "$file")
            [[ -z "$dpath" || -z "$dcontains" ]] && continue
            dmatched=0
            # Locate candidate files by basename at depth ≤2, then content-
            # check each. -print0 + read -d for filenames with spaces.
            while IFS= read -r -d '' dfound; do
                if grep -qiF -- "$dcontains" "$dfound" 2>/dev/null; then
                    dmatched=1
                    break
                fi
            done < <(find "$target_dir" -maxdepth 3 -name "$dpath" -type f -print0 2>/dev/null)
            if [[ "$dmatched" -eq 1 ]]; then
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
