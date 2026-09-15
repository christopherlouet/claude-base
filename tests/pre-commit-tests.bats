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

@test "pre-commit-tests: read-only 'git log --grep \"git commit\"' is not treated as a commit" {
    # A substring matcher over-blocked this read-only command; the gate must
    # only fire on an actual `git … commit` at command position.
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'git log --grep "git commit"'
    [ "$status" -eq 0 ]
    [[ "$output" != *"Running tests"* ]]
}

@test "pre-commit-tests: 'git -c core.hooksPath=... commit' still runs the gate (no bypass)" {
    # A substring matcher missed this form (no literal 'git commit'), letting the
    # commit skip the suite. The gate must still fire.
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'git -c core.hooksPath=/dev/null commit -m x'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
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

# --- npm's placeholder test script -------------------------------------------
# `npm init -y` writes a test script that ALWAYS exits 1. Running it blocked
# every commit of a freshly initialised project, before it had a single test.

# mk_npm_project_json <dir> <test-script> — like mk_npm_project, but the script
# is JSON-encoded by jq, so it may carry the placeholder's embedded quotes.
mk_npm_project_json() {
    mkdir -p "$1"
    jq -n --arg t "$2" '{name:"fixture", version:"1.0.0", scripts:{test:$t}}' > "$1/package.json"
}

NPM_PLACEHOLDER='echo "Error: no test specified" && exit 1'

@test "pre-commit-tests: npm's placeholder test script → commit allowed, gate says why" {
    mk_npm_project_json "$TEST_DIR/proj" "$NPM_PLACEHOLDER"
    run_hook_in "$TEST_DIR/proj" 'git commit -m "chore: init"'
    [ "$status" -eq 0 ]
    [[ "$output" != *"BLOCKED"* ]]
    [[ "$output" == *"placeholder"* ]]
}

@test "pre-commit-tests: the placeholder written by the real 'npm init -y' is recognised" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mkdir -p "$TEST_DIR/proj"
    (cd "$TEST_DIR/proj" && npm init -y >/dev/null 2>&1)
    run_hook_in "$TEST_DIR/proj" 'git commit -m "chore: init"'
    [ "$status" -eq 0 ]
    [[ "$output" == *"placeholder"* ]]
}

@test "pre-commit-tests: a failing script that merely CONTAINS the placeholder still blocks" {
    # Exact match only: a real script that happens to start the same way is a
    # real suite, and a red real suite must block.
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project_json "$TEST_DIR/proj" "$NPM_PLACEHOLDER && echo more"
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

# The placeholder means "no npm suite", NOT "no suite": a Python or Go project
# often carries a package.json only for husky/commitlint. Skipping out of the
# hook there let its red pytest / go test through (found in review).

# fake_red_tool <name> — put a <name> that always fails first on PATH.
fake_red_tool() {
    mkdir -p "$TEST_DIR/bin"
    printf '#!/bin/sh\necho "FAKE %s RED"\nexit 1\n' "$1" > "$TEST_DIR/bin/$1"
    chmod +x "$TEST_DIR/bin/$1"
    export PATH="$TEST_DIR/bin:$PATH"
}

@test "pre-commit-tests: placeholder package.json in a Python project still runs the red pytest" {
    mk_npm_project_json "$TEST_DIR/proj" "$NPM_PLACEHOLDER"
    touch "$TEST_DIR/proj/pyproject.toml"
    fake_red_tool pytest
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 2 ]
    [[ "$output" == *"FAKE pytest RED"* ]]
}

@test "pre-commit-tests: placeholder package.json in a Go project still runs the red go test" {
    mk_npm_project_json "$TEST_DIR/proj" "$NPM_PLACEHOLDER"
    printf 'module x\n' > "$TEST_DIR/proj/go.mod"
    fake_red_tool go
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 2 ]
    [[ "$output" == *"FAKE go RED"* ]]
}

@test "pre-commit-tests: a placeholder test with a real pretest is a real suite" {
    # `npm test` runs pretest/posttest too; only a bare placeholder is no suite.
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mkdir -p "$TEST_DIR/proj"
    jq -n --arg t "$NPM_PLACEHOLDER" '{name:"fixture", version:"1.0.0", scripts:{pretest:"exit 3", test:$t}}' \
        > "$TEST_DIR/proj/package.json"
    run_hook_in "$TEST_DIR/proj" 'git commit -m "wip"'
    [ "$status" -eq 2 ]
}
