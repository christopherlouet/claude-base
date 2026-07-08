#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/bash-write-guard.sh — the Bash-side complement to the
# edit-path file-mutation guards. Blocks a Bash write (>, >>, tee, sed -i) whose
# TARGET is (1) an existing linter/formatter config, (2) an existing secrets
# file, or (3) a tracked repo file while on main/master. Ordinary writes (new
# files, temp, /dev/*, reads) pass. Payload on STDIN as JSON (.tool_input.command).
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/bash-write-guard.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# run_in <dir> <command-string>
run_in() {
    local dir="$1" cmd="$2" json
    json=$(jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$dir' && bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
}

# a plain project dir with existing sensitive files
mk_proj() {
    mkdir -p "$TEST_DIR/proj"
    echo '{}'       > "$TEST_DIR/proj/.eslintrc.json"
    echo '{}'       > "$TEST_DIR/proj/.prettierrc"
    printf 'X=1\n'  > "$TEST_DIR/proj/.env"
}

# a git repo whose current branch is main, with one tracked file
mk_git_main() {
    mkdir -p "$TEST_DIR/repo"
    (
        cd "$TEST_DIR/repo"
        git init -q
        echo hi > tracked.txt
        git add tracked.txt
        git -c user.email=t@e.x -c user.name=t commit -qm init
        git branch -m main
    )
}

# --- Blocking: writes to sensitive targets --------------------------------

@test "bash-write-guard: blocks sed -i on an existing eslint config" {
    mk_proj
    run_in "$TEST_DIR/proj" "sed -i 's/error/off/' .eslintrc.json"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "bash-write-guard: blocks a redirect to an existing prettier config" {
    mk_proj
    run_in "$TEST_DIR/proj" 'echo "{}" > .prettierrc'
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks tee to an existing eslint config" {
    mk_proj
    run_in "$TEST_DIR/proj" 'echo "{}" | tee .eslintrc.json'
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks a redirect that clobbers an existing .env" {
    mk_proj
    run_in "$TEST_DIR/proj" 'echo "SECRET=leaked" > .env'
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: on main, blocks a Bash write to a tracked repo file" {
    mk_git_main
    run_in "$TEST_DIR/repo" 'echo changed > tracked.txt'
    [ "$status" -eq 2 ]
    [[ "$output" == *"main"* ]]
}

# --- Allowing: ordinary / non-sensitive writes ----------------------------

@test "bash-write-guard: allows creating a NEW config (does not exist yet)" {
    mkdir -p "$TEST_DIR/fresh"
    run_in "$TEST_DIR/fresh" 'echo "{}" > .eslintrc.json'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows a redirect to a temp file" {
    mk_proj
    run_in "$TEST_DIR/proj" 'echo hi > /tmp/scratch-xyz'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows READING a config and writing elsewhere" {
    mk_proj
    run_in "$TEST_DIR/proj" 'cat .eslintrc.json > /tmp/backup-xyz'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows a redirect to /dev/null" {
    mk_proj
    run_in "$TEST_DIR/proj" 'some-cmd > /dev/null 2>&1'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows writing .env.example (a template, not a secret)" {
    mkdir -p "$TEST_DIR/tmpl"; printf 'X=\n' > "$TEST_DIR/tmpl/.env.example"
    run_in "$TEST_DIR/tmpl" 'echo "X=" > .env.example'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows a plain command with no write target" {
    mk_proj
    run_in "$TEST_DIR/proj" 'npm run build'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: on a feature branch, a write to a tracked file is allowed" {
    mk_git_main
    ( cd "$TEST_DIR/repo" && git checkout -q -b feature/x )
    run_in "$TEST_DIR/repo" 'echo changed > tracked.txt'
    [ "$status" -eq 0 ]
}

# --- Escape hatch + contract ----------------------------------------------

@test "bash-write-guard: SKIP_BASH_WRITE_GUARD=1 bypasses" {
    mk_proj
    local json
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"echo x > .env"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR/proj' && SKIP_BASH_WRITE_GUARD=1 bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: non-Bash tool (no command) → exit 0" {
    printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"x"}}' > "$TEST_DIR/input.json"
    run bash -c "bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

# --- Self-application: a benign real command on the foundation passes -------

@test "bash-write-guard: self-application — a benign real command passes" {
    run_in "$BATS_TEST_DIRNAME/.." 'npm test && echo done'
    [ "$status" -eq 0 ]
}
