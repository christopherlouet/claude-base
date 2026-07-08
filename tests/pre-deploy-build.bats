#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/pre-deploy-build.sh — PreToolUse (Bash) hook that runs
# the production build before a deploy command and blocks (exit 2) on failure.
# Extracted from an inline settings.json `bash -c` gate that had ZERO coverage
# and whose Go branch ignored the build's exit status. The npm/go-path tests
# skip gracefully where the toolchain is unavailable.
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/pre-deploy-build.sh"

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

# mk_npm_project <dir> <build-script> — a minimal package.json with a build script.
mk_npm_project() {
    mkdir -p "$1"
    cat > "$1/package.json" <<EOF
{ "name": "fixture", "version": "1.0.0", "scripts": { "build": "$2" } }
EOF
}

# mk_go_project <dir> <main-body> — a minimal Go module; the body is dropped
# verbatim into main()'s file so tests can make it valid or broken.
mk_go_project() {
    mkdir -p "$1"
    cat > "$1/go.mod" <<EOF
module fixture

go 1.21
EOF
    cat > "$1/main.go" <<EOF
package main

$2
EOF
}

@test "pre-deploy-build: passing npm build → allows the deploy (exit 0)" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 0"
    run_hook_in "$TEST_DIR/proj" './deploy.sh production'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Build OK"* ]]
}

@test "pre-deploy-build: failing npm build → blocks the deploy (exit 2)" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" './deploy.sh production'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

# The bug this extraction fixes: the inline gate's Go branch ignored the build's
# exit status, letting a broken Go build reach the deploy. This must now block.
@test "pre-deploy-build: failing go build → blocks the deploy (exit 2)" {
    command -v go >/dev/null 2>&1 || skip "go not available"
    mk_go_project "$TEST_DIR/proj" 'func main() { this is not valid go }'
    run_hook_in "$TEST_DIR/proj" './deploy.sh production'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "pre-deploy-build: passing go build → allows the deploy (exit 0)" {
    command -v go >/dev/null 2>&1 || skip "go not available"
    mk_go_project "$TEST_DIR/proj" 'func main() {}'
    run_hook_in "$TEST_DIR/proj" './deploy.sh production'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Build OK"* ]]
}

@test "pre-deploy-build: non-deploy command → no-op (exit 0, build not run)" {
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'git status'
    [ "$status" -eq 0 ]
    [[ "$output" != *"Pre-deploy build check"* ]]
}

# --- Trigger reach: the gate was inert on the common deploy invocations -------

@test "pre-deploy-build: recognizes 'npm run deploy' as a deploy" {
    mkdir -p "$TEST_DIR/bare"
    run_hook_in "$TEST_DIR/bare" 'npm run deploy'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pre-deploy build check"* ]]
}

@test "pre-deploy-build: recognizes 'vercel deploy' as a deploy" {
    mkdir -p "$TEST_DIR/bare"
    run_hook_in "$TEST_DIR/bare" 'vercel deploy --prod'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Pre-deploy build check"* ]]
}

@test "pre-deploy-build: a failing build blocks 'npm run deploy'" {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'npm run deploy'
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "pre-deploy-build: 'npm run build' does NOT trigger (only deploys do)" {
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    run_hook_in "$TEST_DIR/proj" 'npm run build'
    [ "$status" -eq 0 ]
    [[ "$output" != *"Pre-deploy build check"* ]]
}

@test "pre-deploy-build: SKIP_PRE_DEPLOY_BUILD=1 bypasses a failing build" {
    mk_npm_project "$TEST_DIR/proj" "exit 1"
    local json
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"./deploy.sh production"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR/proj' && SKIP_PRE_DEPLOY_BUILD=1 bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

@test "pre-deploy-build: project with no build config → no-op (exit 0)" {
    mkdir -p "$TEST_DIR/bare"
    run_hook_in "$TEST_DIR/bare" './deploy.sh production'
    [ "$status" -eq 0 ]
    [[ "$output" != *"BLOCKED"* ]]
}

@test "pre-deploy-build: self-application — a deploy command in a config-less dir passes" {
    run_hook_in "$TEST_DIR" './deploy.sh production'
    [ "$status" -eq 0 ]
    [[ "$output" != *"BLOCKED"* ]]
}
