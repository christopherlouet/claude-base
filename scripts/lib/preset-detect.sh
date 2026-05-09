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
# Iterates over every preset manifest under <BASE_DIR>/.claude/presets/
# (including community/), evaluates each manifest's `detect` block against
# <target_dir>, and prints the names of matching presets to stdout (one per
# line, alphabetical order).
#
# A preset without a `detect` block is silent (never auto-suggested).
# When jq is unavailable, the function exits 0 with no output (graceful).
#
# Arguments:
#   $1 - Target directory to scan (absolute path expected)
# Outputs:
#   stdout: matching preset names, one per line
# Returns:
#   0 always (errors degrade to silent no-match)
scan_presets() {
    local target_dir="$1"
    [[ -d "$target_dir" ]] || return 0
    command -v jq >/dev/null 2>&1 || return 0

    # TODO: implementation lands in Phase 3 (T024).
    return 0
}
