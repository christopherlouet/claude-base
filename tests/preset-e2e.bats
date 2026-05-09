#!/usr/bin/env bats

# =============================================================================
# End-to-end tests per preset.
# For each preset under .claude/presets/, bootstrap a project, run validate.sh
# and doctor.sh, then assert every hook script referenced by the bootstrapped
# settings.json exists on disk (drift-guard against v1.36.1-style regressions).
# See specs/presets-detection-and-e2e/spec.md US-3 (EF-012, EF-013, EF-014).
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"
VALIDATE="$BASE_DIR/scripts/validate.sh"
DOCTOR="$BASE_DIR/scripts/doctor.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Test cases land in Phase 4 (T033-T042). This file is the skeleton.

@test "preset-e2e: helper scripts exist" {
    [ -x "$NEW_PROJECT" ]
    [ -x "$VALIDATE" ]
    [ -x "$DOCTOR" ]
}
