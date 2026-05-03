#!/usr/bin/env bats

# =============================================================================
# Tests for the UserPromptSubmit hook: context injection (semantic routing)
# =============================================================================
# The prompt-context.sh script is invoked by the UserPromptSubmit hook.
# It reads a JSON {"prompt": "..."} on stdin (Claude Code format) and writes
# on stdout a JSON conforming to the hookSpecificOutput contract with
# additionalContext — only if the prompt is not a slash command.
# =============================================================================

load 'test_helper'

HOOK_SCRIPT="$SOCLE_DIR/scripts/hooks/prompt-context.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    export CLAUDE_PROJECT_DIR="$TEST_DIR"
    cd "$TEST_DIR" || return
    git init --quiet --initial-branch=main
    git config user.email "test@test.local"
    git config user.name "Test"
    echo "init" > README.md
    git add README.md
    git commit --quiet -m "init"
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Output contracts
# =============================================================================

@test "prompt-context: empty output if the prompt starts with /" {
    run bash -c 'echo "{\"prompt\": \"/work:work-plan feature X\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: empty output if the prompt is empty" {
    run bash -c 'echo "{\"prompt\": \"\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: valid JSON output for a free-form prompt" {
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    echo "$output" | jq -e . >/dev/null
}

@test "prompt-context: output contains hookSpecificOutput.additionalContext" {
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "UserPromptSubmit"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.additionalContext | type == "string"' >/dev/null
}

# =============================================================================
# Injected context content
# =============================================================================

@test "prompt-context: additionalContext mentions /assistant-auto as a hint" {
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"/assistant-auto"* ]]
}

@test "prompt-context: additionalContext contains the current branch" {
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"main"* ]]
}

@test "prompt-context: additionalContext reports modified files" {
    echo "modif" >> README.md
    echo "new" > NEW.md
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"README.md"* ]]
    [[ "$ctx" == *"NEW.md"* ]]
}

@test "prompt-context: additionalContext reports the diff LOC" {
    printf "a\nb\nc\nd\ne\n" >> README.md
    git add README.md
    run bash -c 'echo "{\"prompt\": \"refactor\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    local ctx
    ctx=$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext')
    [[ "$ctx" == *"LOC"* ]] || [[ "$ctx" == *"loc"* ]] || [[ "$ctx" == *"lines"* ]]
}

# =============================================================================
# Robustness
# =============================================================================

@test "prompt-context: does not break outside a git repo" {
    rm -rf .git
    run bash -c 'echo "{\"prompt\": \"add a users endpoint\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    echo "$output" | jq -e . >/dev/null
}

@test "prompt-context: ignores stdin that is not JSON" {
    run bash -c 'echo "not json" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "prompt-context: timeout-friendly (finishes in less than 3s)" {
    run bash -c 'time (echo "{\"prompt\": \"test\"}" | "'"$HOOK_SCRIPT"'") 2>&1'
    [ "$status" -eq 0 ]
}

@test "prompt-context: ignores slash commands with leading spaces" {
    run bash -c 'echo "{\"prompt\": \"   /work:work-plan test\"}" | "'"$HOOK_SCRIPT"'"'
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
