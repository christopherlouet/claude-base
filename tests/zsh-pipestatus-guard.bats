#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/zsh-pipestatus-guard.sh — the Claude Code shell over
# _policy-zsh-pipestatus.sh (core cases: tests/policy-zsh-pipestatus.bats).
# Blocks (exit 2) a Bash command that reads PIPESTATUS when the Bash tool's
# shell is zsh (CLAUDE_CODE_SHELL, else SHELL); silent under bash.
# =============================================================================

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/zsh-pipestatus-guard.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# hook_with <shell-path> <command-string> — run the shell hook with the payload
# on stdin and SHELL set; CLAUDE_CODE_SHELL cleared.
hook_with() {
    local sh="$1" cmd="$2"
    jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}' > "$TEST_DIR/input.json"
    run env -u CLAUDE_CODE_SHELL -u SKIP_ZSH_PIPESTATUS_GUARD SHELL="$sh" \
        bash "$HOOK" < "$TEST_DIR/input.json"
}

# --- Shell hook --------------------------------------------------------------

@test "hook: blocks under zsh with an actionable message" {
    hook_with /usr/bin/zsh 'false | true; echo ${PIPESTATUS[0]}'
    [ "$status" -eq 2 ]
    [[ "$output" == *"pipestatus"* ]]
    [[ "$output" == *"bash -c"* ]]
    [[ "$output" == *"SKIP_ZSH_PIPESTATUS_GUARD"* ]]
}

@test "hook: allows the same command when the outer shell is bash" {
    hook_with /bin/bash 'false | true; echo ${PIPESTATUS[0]}'
    [ "$status" -eq 0 ]
}

@test "hook: CLAUDE_CODE_SHELL (the CLI's override) wins over SHELL" {
    jq -n --arg c 'a | b; echo ${PIPESTATUS[0]}' '{tool_input:{command:$c}}' > "$TEST_DIR/input.json"
    run env -u SKIP_ZSH_PIPESTATUS_GUARD SHELL=/usr/bin/zsh CLAUDE_CODE_SHELL=/bin/bash \
        bash "$HOOK" < "$TEST_DIR/input.json"
    [ "$status" -eq 0 ]
    run env -u SKIP_ZSH_PIPESTATUS_GUARD SHELL=/bin/bash CLAUDE_CODE_SHELL=/usr/bin/zsh \
        bash "$HOOK" < "$TEST_DIR/input.json"
    [ "$status" -eq 2 ]
}

@test "hook: allows a clean command under zsh" {
    hook_with /usr/bin/zsh 'ls -la | head'
    [ "$status" -eq 0 ]
}

@test "hook: SKIP_ZSH_PIPESTATUS_GUARD=1 bypasses" {
    jq -n --arg c 'echo ${PIPESTATUS[0]}' '{tool_input:{command:$c}}' > "$TEST_DIR/input.json"
    run env SHELL=/usr/bin/zsh SKIP_ZSH_PIPESTATUS_GUARD=1 bash "$HOOK" < "$TEST_DIR/input.json"
    [ "$status" -eq 0 ]
}

@test "hook: degraded (core missing) fails OPEN with a warning" {
    mkdir -p "$TEST_DIR/hooks"
    cp "$HOOK" "$TEST_DIR/hooks/"
    jq -n --arg c 'echo ${PIPESTATUS[0]}' '{tool_input:{command:$c}}' > "$TEST_DIR/input.json"
    run env -u SKIP_ZSH_PIPESTATUS_GUARD SHELL=/usr/bin/zsh \
        bash "$TEST_DIR/hooks/zsh-pipestatus-guard.sh" < "$TEST_DIR/input.json"
    [ "$status" -eq 0 ]
    [[ "$output" == *"_policy-zsh-pipestatus.sh"* ]]
}
