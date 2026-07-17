#!/usr/bin/env bats

# =============================================================================
# Fresh-install self-application for the agnostic-core split
# (specs/agnostic-core/ US-3): after a real `new-project.sh --simple` install,
# the policy cores must ship alongside their shells and the INSTALLED guards
# must return the same verdicts as the foundation's own — no orphan shell
# (a shell whose core did not ship would either fail closed on every command
# [command-validator] or silently no-op [gates]).
#
# This is the guard against the known install gotcha: init copies hooks with a
# FLAT `cp scripts/hooks/*.sh` — a core lib placed anywhere else would
# silently not ship.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# run_installed_hook <hook-basename> <command-string> — feed a PreToolUse Bash
# envelope to the hook AS INSTALLED in the fresh project.
run_installed_hook() {
    local hook="$TEST_DIR/scripts/hooks/$1"
    local json
    json=$(jq -n --arg c "$2" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "cd '$TEST_DIR' && bash '$hook' < '$TEST_DIR/input.json' 2>&1"
}

@test "fresh install ships every policy core next to its shell" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    for lib in _core-helpers.sh _policy-dangerous-commands.sh \
               _policy-destructive-sql.sh _policy-secrets.sh \
               _policy-triggers.sh _policy-write-targets.sh; do
        [ -f "$TEST_DIR/scripts/hooks/$lib" ]
    done
}

@test "fresh install: installed command-validator still blocks and allows" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null
    [ "$status" -eq 0 ]

    run_installed_hook command-validator.sh "sudo rm /tmp/x"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]

    run_installed_hook command-validator.sh 'git commit -m "wip" --no-verify'
    [ "$status" -eq 2 ]

    run_installed_hook command-validator.sh "npm test"
    [ "$status" -eq 0 ]

    # Payload class: a trigger token inside a message value must not block.
    run_installed_hook command-validator.sh 'git commit -m "document mkfs usage"'
    [ "$status" -eq 0 ]
}

@test "fresh install: installed destructive-ops still blocks and allows" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null
    [ "$status" -eq 0 ]

    run_installed_hook destructive-ops.sh 'psql -c "DROP TABLE users"'
    [ "$status" -eq 2 ]

    run_installed_hook destructive-ops.sh 'psql -c "DELETE FROM users WHERE id = 1"'
    [ "$status" -eq 0 ]
}

@test "fresh install: installed secret-scan still blocks a runtime-assembled secret" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR" >/dev/null
    [ "$status" -eq 0 ]

    local a="AKIA"; a="${a}1234567890ABCDEF"
    local json
    json=$(jq -n --arg c "key='$a'" '{tool_name:"Write", tool_input:{content:$c}}')
    run bash -c "cd '$TEST_DIR' && printf '%s' '$json' | bash '$TEST_DIR/scripts/hooks/secret-scan.sh' 2>&1"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}
