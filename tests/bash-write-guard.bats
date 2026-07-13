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

# =============================================================================
# Regression: alternate write verbs found in the 2026-07-12 audit. The guard
# used to cover only >, >>, tee and `sed -i`; sed --in-place and the copy verbs
# clobbered a secrets file untouched. Each blocks an EXISTING .env.
# =============================================================================

@test "bash-write-guard: blocks sed --in-place on an existing secrets file" {
    mk_proj
    run_in "$TEST_DIR/proj" "sed --in-place 's/X/Y/' .env"
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks sed --in-place on an existing config" {
    mk_proj
    run_in "$TEST_DIR/proj" "sed --in-place 's/error/off/' .eslintrc.json"
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks cp onto an existing .env" {
    mk_proj
    echo 'LEAK=1' > "$TEST_DIR/proj/other.txt"
    run_in "$TEST_DIR/proj" "cp other.txt .env"
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks mv onto an existing .env" {
    mk_proj
    echo 'LEAK=1' > "$TEST_DIR/proj/other.txt"
    run_in "$TEST_DIR/proj" "mv other.txt .env"
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks install -m600 onto an existing .env" {
    mk_proj
    echo 'LEAK=1' > "$TEST_DIR/proj/other.txt"
    run_in "$TEST_DIR/proj" "install -m600 other.txt .env"
    [ "$status" -eq 2 ]
}

@test "bash-write-guard: blocks dd of= onto an existing .env" {
    mk_proj
    run_in "$TEST_DIR/proj" "dd if=/dev/zero of=.env bs=1 count=1"
    [ "$status" -eq 2 ]
}

# --- Controls: the same verbs onto a NON-sensitive / new target still pass ----

@test "bash-write-guard: allows cp onto a normal new file" {
    mk_proj
    echo 'ok' > "$TEST_DIR/proj/src.txt"
    run_in "$TEST_DIR/proj" "cp src.txt build.txt"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows mv onto a normal new file" {
    mk_proj
    echo 'ok' > "$TEST_DIR/proj/src.txt"
    run_in "$TEST_DIR/proj" "mv src.txt renamed.txt"
    [ "$status" -eq 0 ]
}

# --- pass-3 F2: package-manager `install` is NOT a file write ----------------
# The (cp|mv|install) DEST extraction read `pip install -r requirements.txt` as
# a write to requirements.txt and hard-blocked routine installs on main. A
# `<pm> [flags] install` subcommand must be exempt; the coreutils
# `install SRC DST` (a real file write) must still block.

# tracked requirements.txt in a main-branch repo
mk_git_main_reqs() {
    mk_git_main
    (
        cd "$TEST_DIR/repo"
        echo 'flask' > requirements.txt
        mkdir -p packages/foo && echo '{}' > packages/foo/package.json
        git add requirements.txt packages
        git -c user.email=t@e.x -c user.name=t commit -qm deps
    )
}

@test "bash-write-guard: allows pip install -r requirements.txt on main" {
    mk_git_main_reqs
    run_in "$TEST_DIR/repo" "pip install -r requirements.txt"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows pip install -e . on main" {
    mk_git_main_reqs
    run_in "$TEST_DIR/repo" "pip install -e ."
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows npm install of a tracked local package dir on main" {
    mk_git_main_reqs
    run_in "$TEST_DIR/repo" "npm install ./packages/foo"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows sudo apt-get install on main" {
    mk_git_main_reqs
    run_in "$TEST_DIR/repo" "sudo apt-get install -y jq"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows a chained cargo install after another command" {
    mk_git_main_reqs
    run_in "$TEST_DIR/repo" "git pull && cargo install ripgrep"
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: still blocks coreutils install onto a tracked file on main" {
    mk_git_main
    run_in "$TEST_DIR/repo" "install -m 755 /tmp/x tracked.txt"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "bash-write-guard: still blocks flagless coreutils install onto a tracked file" {
    mk_git_main
    run_in "$TEST_DIR/repo" "install /tmp/x tracked.txt"
    [ "$status" -eq 2 ]
}

# --- pass-3 F3: message payloads are stripped before target extraction -------
# The guard had no message-value strip (unlike command-validator since #469),
# so a commit message NAMING a file operation was scanned as the operation.

@test "bash-write-guard: allows a commit message naming cp onto .env" {
    mk_proj
    echo 'X=1' > "$TEST_DIR/proj/.env.example"
    run_in "$TEST_DIR/proj" 'git commit -m "chore: cp .env.example .env"'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: allows a commit message naming tee onto the eslint config" {
    mk_proj
    run_in "$TEST_DIR/proj" 'git commit -m "docs: tee .eslintrc.json is blocked"'
    [ "$status" -eq 0 ]
}

@test "bash-write-guard: control — a real cp onto .env still blocks" {
    mk_proj
    echo 'X=1' > "$TEST_DIR/proj/.env.example"
    run_in "$TEST_DIR/proj" "cp .env.example .env"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "bash-write-guard: control — a real write AFTER a -m message still blocks" {
    mk_proj
    run_in "$TEST_DIR/proj" 'git commit -m "safe note" && echo x > .env'
    [ "$status" -eq 2 ]
}
