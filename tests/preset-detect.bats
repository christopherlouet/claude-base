#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/preset-detect.sh
# Covers data-driven preset detection (see specs/presets-detection-and-e2e/).
# =============================================================================

load 'test_helper'

PRESET_DETECT_LIB="$BASE_DIR/scripts/lib/preset-detect.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Source the library inside a subshell at call sites; here we just verify
    # the file is present so failures surface early.
    [ -f "$PRESET_DETECT_LIB" ]
}

teardown() {
    teardown_test_dir
}

# Test cases land in Phase 3 (T011-T023). This file is the skeleton.

@test "preset-detect: library file exists and is sourceable" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$PRESET_DETECT_LIB'"
    [ "$status" -eq 0 ]
}

@test "preset-detect: scan_presets is defined after sourcing" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$PRESET_DETECT_LIB' && declare -f scan_presets >/dev/null"
    [ "$status" -eq 0 ]
}
