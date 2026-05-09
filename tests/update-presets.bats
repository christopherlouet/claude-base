#!/usr/bin/env bats

# =============================================================================
# Tests for preset-aware updates (specs/presets-update-aware/).
# Verifies that scripts/update.sh respects an active preset's skill filter:
#   - --preset NAME explicit override
#   - --no-preset opt-out
#   - auto-detection via scan_presets (PR #160)
#   - multi-match refusal
#   - dry-run lists skipped skills
#   - orphan detection excludes preset-dropped skills
# =============================================================================

load 'test_helper'

NEW_PROJECT="$BASE_DIR/scripts/new-project.sh"
UPDATE="$BASE_DIR/scripts/update.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Test cases land in Phases 2+ (T003-T030). This file is the skeleton.

@test "update-presets: helper scripts exist" {
    [ -x "$UPDATE" ]
    [ -x "$NEW_PROJECT" ]
}
