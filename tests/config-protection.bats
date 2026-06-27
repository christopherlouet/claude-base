#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/config-protection.sh (PreToolUse on Edit|Write|
# MultiEdit). Blocks (exit 2) modifying an EXISTING linter/formatter config —
# agents weaken these to make checks pass instead of fixing the code. First-time
# creation is allowed. Payload on STDIN as JSON (.tool_input.file_path), same
# field for Edit/Write/MultiEdit. Block = exit 2.
# =============================================================================

load 'test_helper'

HOOK="$BASE_DIR/scripts/hooks/config-protection.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# run_cp <abs-file-path> [tool_name] — feed a PreToolUse edit envelope on stdin.
run_cp() {
    local json
    json=$(jq -n --arg f "$1" --arg t "${2:-Edit}" \
        '{tool_name:$t, tool_input:{file_path:$f}}')
    printf '%s' "$json" > "$TEST_DIR/in.json"
    run bash -c "bash '$HOOK' < '$TEST_DIR/in.json' 2>&1"
}

# --- Blocking: editing an EXISTING config (exit 2) --------------------------

@test "config-protection: blocks editing an existing .eslintrc.json" {
    touch "$TEST_DIR/.eslintrc.json"
    run_cp "$TEST_DIR/.eslintrc.json"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "config-protection: blocks editing eslint.config.mjs (flat config)" {
    touch "$TEST_DIR/eslint.config.mjs"
    run_cp "$TEST_DIR/eslint.config.mjs"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks .prettierrc" {
    touch "$TEST_DIR/.prettierrc"
    run_cp "$TEST_DIR/.prettierrc"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks biome.json" {
    touch "$TEST_DIR/biome.json"
    run_cp "$TEST_DIR/biome.json"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks ruff.toml" {
    touch "$TEST_DIR/ruff.toml"
    run_cp "$TEST_DIR/ruff.toml"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks .markdownlint.json" {
    touch "$TEST_DIR/.markdownlint.json"
    run_cp "$TEST_DIR/.markdownlint.json"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks prettier.config.js (config-file form)" {
    touch "$TEST_DIR/prettier.config.js"
    run_cp "$TEST_DIR/prettier.config.js"
    [ "$status" -eq 2 ]
}

@test "config-protection: blocks a config edit via MultiEdit payload" {
    touch "$TEST_DIR/.eslintrc.json"
    run_cp "$TEST_DIR/.eslintrc.json" MultiEdit
    [ "$status" -eq 2 ]
}

# --- Allowing -----------------------------------------------------------------

@test "config-protection: ALLOWS first-time creation (config does not exist)" {
    run_cp "$TEST_DIR/.eslintrc.json"   # not touched → absent
    [ "$status" -eq 0 ]
}

@test "config-protection: ignores a normal source file" {
    touch "$TEST_DIR/index.ts"
    run_cp "$TEST_DIR/index.ts"
    [ "$status" -eq 0 ]
}

@test "config-protection: SKIP_CONFIG_PROTECTION=1 bypasses even a config" {
    touch "$TEST_DIR/.eslintrc.json"
    local json; json=$(jq -n --arg f "$TEST_DIR/.eslintrc.json" \
        '{tool_name:"Edit", tool_input:{file_path:$f}}')
    printf '%s' "$json" > "$TEST_DIR/in.json"
    run bash -c "SKIP_CONFIG_PROTECTION=1 bash '$HOOK' < '$TEST_DIR/in.json' 2>&1"
    [ "$status" -eq 0 ]
}

# --- US-4: false-positive resistance -----------------------------------------

@test "config-protection: does NOT block a doc named eslint-config-guide.md" {
    touch "$TEST_DIR/eslint-config-guide.md"
    run_cp "$TEST_DIR/eslint-config-guide.md"
    [ "$status" -eq 0 ]
}

@test "config-protection: does NOT block a config fixture under tests/" {
    mkdir -p "$TEST_DIR/tests"
    touch "$TEST_DIR/tests/.eslintrc.json"
    run_cp "$TEST_DIR/tests/.eslintrc.json"
    [ "$status" -eq 0 ]
}

@test "config-protection: does NOT block a config under fixtures/" {
    mkdir -p "$TEST_DIR/pkg/fixtures"
    touch "$TEST_DIR/pkg/fixtures/biome.json"
    run_cp "$TEST_DIR/pkg/fixtures/biome.json"
    [ "$status" -eq 0 ]
}

# --- Out of scope (must NOT block) -------------------------------------------

@test "config-protection: does NOT block pyproject.toml" {
    touch "$TEST_DIR/pyproject.toml"
    run_cp "$TEST_DIR/pyproject.toml"
    [ "$status" -eq 0 ]
}

@test "config-protection: does NOT block tsconfig.json" {
    touch "$TEST_DIR/tsconfig.json"
    run_cp "$TEST_DIR/tsconfig.json"
    [ "$status" -eq 0 ]
}

# --- Fail-safe ----------------------------------------------------------------

@test "config-protection: empty file_path → exit 0" {
    printf '%s' '{"tool_name":"Edit","tool_input":{}}' > "$TEST_DIR/in.json"
    run bash -c "bash '$HOOK' < '$TEST_DIR/in.json' 2>&1"
    [ "$status" -eq 0 ]
}
