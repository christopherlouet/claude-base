#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/pre-push-ci.sh — the pre-push local-CI gate,
# extracted from the last untested inline settings.json `bash -c` hook.
# Pass-3 audit: the inline form matched `git push` ANYWHERE in the command,
# so a commit message naming "git push" ran (and could block on) the full
# local CI. The script must trigger only on a command-position `git push`.
# Payload on STDIN as JSON (.tool_input.command); block = exit 2.
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/pre-push-ci.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# run_in <dir> <command-string>
run_in() {
    local dir="$1" cmd="$2" json
    json=$(jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$dir' && bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
}

# A Node project whose test suite ALWAYS fails: if the gate runs the local CI
# here, it must exit 2 — and if a payload-only mention triggers it, the
# assertion catches the over-trigger.
mk_red_project() {
    mkdir -p "$TEST_DIR/proj"
    cat > "$TEST_DIR/proj/package.json" <<'JSON'
{ "name": "fixture", "version": "1.0.0",
  "scripts": { "test": "exit 1" } }
JSON
}

mk_empty_project() { mkdir -p "$TEST_DIR/empty"; }

# --- Real pushes trigger the gate -------------------------------------------

@test "pre-push-ci: a real git push runs local CI and blocks on red" {
    mk_red_project
    run_in "$TEST_DIR/proj" "git push origin main"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "pre-push-ci: git push chained after a commit still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "git commit -m 'wip' && git push"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: git with global options before push still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "git -C . push origin main"
    [ "$status" -eq 2 ]
}

# --- pass-4 F3: real-push forms the extracted matcher used to miss ----------
# All fail-OPEN (the local gate silently skipped), so no security impact —
# but the convenience check must fire on the forms people actually type.

@test "pre-push-ci: git push directly followed by ; still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "git push;echo done"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: env-assignment-prefixed git push still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "GIT_TRACE=1 git push origin main"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: env with assignment before git push still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "env FOO=1 git push"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: absolute-path git push still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "/usr/bin/git push origin main"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: sudo git push still triggers" {
    mk_red_project
    run_in "$TEST_DIR/proj" "sudo git push"
    [ "$status" -eq 2 ]
}

@test "pre-push-ci: a message naming 'git push;' does not trigger" {
    mk_red_project
    run_in "$TEST_DIR/proj" "git commit -m 'docs: what git push; does'"
    [ "$status" -eq 0 ]
}

@test "pre-push-ci: a real push in a stackless project passes (nothing to run)" {
    mk_empty_project
    run_in "$TEST_DIR/empty" "git push"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Local CI OK"* ]]
}

# --- Payload mentions must NOT trigger the gate ------------------------------

@test "pre-push-ci: a commit message naming git push does not run CI" {
    mk_red_project
    run_in "$TEST_DIR/proj" 'git commit -m "docs: explain the git push flow"'
    [ "$status" -eq 0 ]
    [[ "$output" != *"Pre-push CI check"* ]]
}

@test "pre-push-ci: a --grep payload naming git push does not run CI" {
    mk_red_project
    run_in "$TEST_DIR/proj" 'git log --grep "git push failures"'
    [ "$status" -eq 0 ]
}

@test "pre-push-ci: an echo mentioning git push mid-sentence does not run CI" {
    mk_red_project
    run_in "$TEST_DIR/proj" "echo now run git push manually"
    [ "$status" -eq 0 ]
}

@test "pre-push-ci: unrelated commands exit 0 fast" {
    mk_red_project
    run_in "$TEST_DIR/proj" "npm test"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Pre-push CI check"* ]]
}

# --- Opt-out and robustness ---------------------------------------------------

@test "pre-push-ci: SKIP_PRE_PUSH_CI=1 disables the gate" {
    mk_red_project
    local json
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"git push"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR/proj' && SKIP_PRE_PUSH_CI=1 bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

@test "pre-push-ci: empty payload exits 0" {
    mk_empty_project
    printf '{}' > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR/empty' && bash '$HOOK' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}
