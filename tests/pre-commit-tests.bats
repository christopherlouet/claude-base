#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/pre-commit-tests.sh — PreToolUse (Bash) hook that
# runs the project's test suite before a `git commit` and blocks (exit 2) on
# failure. Extracted from an inline settings.json `bash -c` gate that had ZERO
# coverage. The npm-path tests skip gracefully where npm is unavailable.
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/pre-commit-tests.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# run_hook_in <dir> <command-string> — feed a Bash PreToolUse envelope on stdin
# with the CWD set to a fixture project dir.
run_hook_in() {
    local dir="$1" cmd="$2" json
    json=$(jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$dir' && bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
}

# mk_npm_project <dir> <test-script> — a minimal package.json with a test script.
mk_npm_project() {
    mkdir -p "$1"
    cat > "$1/package.json" <<EOF
{ "name": "fixture", "version": "1.0.0", "scripts": { "test": "$2" } }
EOF
}

@test "pre-commit-tests: passing npm test → allows the commit (exit 0)" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 0"
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 0 ]
}

@test "pre-commit-tests: failing npm test → blocks the commit (exit 2)" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "pre-commit-tests: non-commit command → no-op (exit 0, tests not run)" {
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'git status'
    [ "$status" -eq 0 ]
    [[ "$output" != *"Running tests"* ]]
}

@test "pre-commit-tests: SKIP_PRE_COMMIT_TESTS=1 bypasses a failing suite" {
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    local json
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"git commit -m x"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR/proj' && SKIP_PRE_COMMIT_TESTS=1 bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

@test "pre-commit-tests: project with no test config → no-op (exit 0)" {
    mkdir -p "$TEST_DIR/bare"
    run_hook_in "$TEST_DIR/bare" 'git commit -m "wip"'
    [ "$status" -eq 0 ]
    [[ "$output" != *"BLOCKED"* ]]
}

@test "pre-commit-tests: self-application — a benign commit in a config-less dir passes" {
    run_hook_in "$TEST_DIR" 'git commit -m "docs: update readme"'
    [ "$status" -eq 0 ]
}
