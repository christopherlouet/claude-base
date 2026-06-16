#!/usr/bin/env bats

# =============================================================================
# Tests for the preset_pivot_notice helper (specs/stack-pivot-redetect, CS-205).
#
# When a project bootstrapped with a recorded preset is updated, the project's
# actual stack may have pivoted (e.g. react-vite-spa → nextjs). These tests
# verify that preset_pivot_notice <recorded_preset> <target_dir> produces a
# non-blocking, non-mutating notice when the detected set diverges from the
# recorded one. Pure (jq + scan_presets), offline.
#
# Mirrors the recommendation-drift.bats test style:
#   - synthetic presets via PRESETS_DIR env override
#   - fixture project dirs in TEST_DIR
#   - helper functions for setup
#   - call() wrapper to invoke functions in a subshell
# =============================================================================

load 'test_helper'

LIB="$BATS_TEST_DIRNAME/../scripts/lib/preset-recommendations.sh"
DETECT_LIB="$BATS_TEST_DIRNAME/../scripts/lib/preset-detect.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    mkdir -p "$TEST_DIR/.claude"
    mkdir -p "$TEST_DIR/presets-dir"
    mkdir -p "$TEST_DIR/proj"
}

teardown() { teardown_test_dir; }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# make_preset <name> <detect_json>
# Writes a minimal synthetic preset into $TEST_DIR/presets-dir.
make_preset() {
    local name="$1"
    local detect_json="$2"
    cat > "$TEST_DIR/presets-dir/$name.json" <<EOF
{
  "name": "$name",
  "displayName": "$name",
  "description": "Synthetic preset for pivot tests",
  "status": "draft",
  "appliesToTypes": ["generic"],
  "defaults": {"ci": false, "hooks": false, "mcp": false, "docker": false},
  "detect": $detect_json,
  "foundation": {"skills": {"drop": [], "keep": []}},
  "marketplacePlugins": [],
  "recommendedVendorSkills": []
}
EOF
}

# call <function_and_args>
# Sources libs + overrides in a subshell, then calls the function.
call() {
    run env bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$DETECT_LIB'
        source '$LIB'
        PRESETS_DIR='$TEST_DIR/presets-dir' $*
    "
}

# ---------------------------------------------------------------------------
# T001 — Unit test suite for preset_pivot_notice (RED: helper is absent)
# ---------------------------------------------------------------------------

# Case 1: divergence, R ∉ D — recorded react-vite-spa no longer matches; dir now
# matches only nextjs (single detected preset → adoption command names it).
@test "pivot-notice: divergence (recorded no longer detected) → names recorded + detected, suggests the single preset" {
    # Arrange: two synthetic presets with distinct detect markers
    make_preset "react-vite-spa" '{"combinator":"anyOf","files":["vite.config.ts"]}'
    make_preset "nextjs" '{"combinator":"anyOf","files":["next.config.js"]}'

    # Dir now only has next.config.js (pivoted to nextjs)
    touch "$TEST_DIR/proj/next.config.js"

    call "preset_pivot_notice 'react-vite-spa' '$TEST_DIR/proj'"

    [ "$status" -eq 0 ]
    # Output must be non-empty
    [ -n "$output" ]
    # Must mention both the recorded preset and the detected one
    [[ "$output" == *"react-vite-spa"* ]]
    [[ "$output" == *"nextjs"* ]]
    # Must contain the exact suggested adoption command
    [[ "$output" == *"claude-base update --preset nextjs"* ]]
}

# Case 2: steady-state — recorded nextjs, dir still matches only nextjs → silent
@test "pivot-notice: steady-state → output empty" {
    make_preset "nextjs" '{"combinator":"anyOf","files":["next.config.js"]}'

    touch "$TEST_DIR/proj/next.config.js"

    call "preset_pivot_notice 'nextjs' '$TEST_DIR/proj'"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# Case 3 (was a duplicate of Case 1: same arrange/call, R ∉ D) removed — Case 1
# already covers the recorded-no-longer-detected single-preset path, and Case 4
# below covers the multi-detected path. The two divergence shapes are distinct
# and each has exactly one test.

# Case 4: multi-match — recorded react-vite-spa still matches AND nextjs also
# matches (R ∈ D, |D| > 1) → lists both, and the adoption hint uses the generic
# `<name>` placeholder (NOT a single concrete preset), exercising the else-branch
# of the count logic that Case 1 does not.
@test "pivot-notice: multi-match → lists all detected presets, suggests generic --preset <name>, exit 0" {
    make_preset "react-vite-spa" '{"combinator":"anyOf","files":["vite.config.ts"]}'
    make_preset "nextjs" '{"combinator":"anyOf","files":["next.config.js"]}'

    # Both markers present
    touch "$TEST_DIR/proj/next.config.js"
    touch "$TEST_DIR/proj/vite.config.ts"

    call "preset_pivot_notice 'react-vite-spa' '$TEST_DIR/proj'"

    [ "$status" -eq 0 ]
    [ -n "$output" ]
    # Must list both detected presets
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"react-vite-spa"* ]]
    # Multi-match → generic placeholder, not a single concrete --preset <one>
    [[ "$output" == *"claude-base update --preset <name>"* ]]
}

# Case 5: empty-detection — dir matches nothing → output empty (silent per FR-3 decision)
@test "pivot-notice: empty detection → output empty, exit 0" {
    make_preset "react-vite-spa" '{"combinator":"anyOf","files":["vite.config.ts"]}'
    make_preset "nextjs" '{"combinator":"anyOf","files":["next.config.js"]}'

    # No marker files: detection returns empty
    # (neither preset matches)

    call "preset_pivot_notice 'react-vite-spa' '$TEST_DIR/proj'"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# Case 6: jq absent (PATH shim) → output empty, exit 0
@test "pivot-notice: jq absent → output empty, exit 0" {
    make_preset "react-vite-spa" '{"combinator":"anyOf","files":["vite.config.ts"]}'
    make_preset "nextjs" '{"combinator":"anyOf","files":["next.config.js"]}'

    touch "$TEST_DIR/proj/next.config.js"

    # Shim out jq: create an executable wrapper that always exits 127 so
    # `command -v jq` finds it but the function bails via the exit-code guard.
    # We need the shim directory to also contain 'true', 'bash', 'mktemp', etc.
    # so the subshell can boot. Instead of restricting PATH, we shadow just jq
    # by placing the fake_bin first — the real system tools remain accessible.
    local fake_bin="$TEST_DIR/fakebin"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/jq" <<'FAKEJQ'
#!/usr/bin/env bash
# Shim: simulates jq absent by behaving as "command not found"
exit 127
FAKEJQ
    chmod +x "$fake_bin/jq"

    # The PATH variable must expand at test-write time (double quotes) so the
    # subshell receives the literal path strings, not unexpanded shell words.
    local fake_path="${fake_bin}:${PATH}"
    run env PATH="$fake_path" bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$DETECT_LIB'
        source '$LIB'
        PRESETS_DIR='$TEST_DIR/presets-dir' \
        preset_pivot_notice 'react-vite-spa' '$TEST_DIR/proj'
    "

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# Case 7: fail-safe — malformed/junk input never returns non-zero
@test "pivot-notice: fail-safe — detector or junk input never returns non-zero" {
    # No presets dir, no proj dir — both entirely absent
    call "preset_pivot_notice 'nonexistent-preset' '/tmp/no-such-dir-bats-$$'"

    [ "$status" -eq 0 ]
}
