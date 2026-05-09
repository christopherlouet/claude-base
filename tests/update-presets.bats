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

@test "update-presets: helper scripts exist" {
    [ -x "$UPDATE" ]
    [ -x "$NEW_PROJECT" ]
}

# =============================================================================
# Phase 2 — Foundation: argument parsing + resolve_active_preset
# =============================================================================

@test "update-presets: --preset bogus_xyz fails with clear error naming the preset (T003)" {
    local proj="$TEST_DIR/proj-bogus-preset"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    [ -d "$proj/.claude" ]
    run "$UPDATE" -y --dry-run --preset bogus_xyz_no_such_preset "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"bogus_xyz_no_such_preset"* ]]
    [[ "$output" == *"preset"* ]]
}

@test "update-presets: --preset and --no-preset are mutually exclusive (T004)" {
    local proj="$TEST_DIR/proj-mutex"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --no-preset "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"mutually exclusive"* ]]
}

@test "update-presets: multi-match without flag refuses with disambiguation message (T005)" {
    local proj="$TEST_DIR/proj-multi"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    # Make the project match BOTH nextjs and astro detect rules.
    touch "$proj/next.config.js"
    touch "$proj/astro.config.mjs"
    echo '{"dependencies":{"next":"^15","astro":"^4"}}' > "$proj/package.json"
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"astro"* ]]
    [[ "$output" == *"--preset"* ]] || [[ "$output" == *"--no-preset"* ]]
}

@test "update-presets: --preset nextjs resolves and update proceeds (T006)" {
    local proj="$TEST_DIR/proj-resolve-ok"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    run "$UPDATE" -y --dry-run --preset nextjs --skills "$proj"
    [ "$status" -eq 0 ]
}

@test "update-presets: no preset match and no flag prints no Active preset line (T007/CS-006)" {
    local proj="$TEST_DIR/proj-no-match"
    "$NEW_PROJECT" -y --simple "$proj" >/dev/null 2>&1
    # Bare simple project — no detect markers exist for any preset.
    run "$UPDATE" -y --dry-run --skills "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Active preset:"* ]]
}
