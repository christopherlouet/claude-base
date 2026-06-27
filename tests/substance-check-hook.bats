#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/substance-check.sh — the PostToolUse ADVISORY hook
# (anti-hollow-test / anti-stub). After an Edit/Write/MultiEdit it runs the
# detector on the edited file and surfaces findings as additionalContext.
#
# The contract that matters: it is ADVISORY — exit 0 ALWAYS (never 2), even on a
# finding; it bails to a no-op when disabled, on an unsupported file/tool, or
# when the detector is absent. Input on STDIN as JSON (.tool_input.file_path).
# =============================================================================

load 'test_helper'

HOOK="$BASE_DIR/scripts/hooks/substance-check.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# run_hook <file> [tool] [project_dir] — feed a PostToolUse envelope on stdin.
# project_dir defaults to the real foundation so the detector is found.
run_hook() {
    local f="$1" tool="${2:-Edit}" proj="${3:-$BASE_DIR}"
    jq -n --arg f "$f" --arg t "$tool" \
        '{tool_name:$t, tool_input:{file_path:$f}}' > "$TEST_DIR/in.json"
    run bash -c "CLAUDE_PROJECT_DIR='$proj' bash '$HOOK' < '$TEST_DIR/in.json'"
}

# --- advisory: a hollow edit is surfaced, but NEVER blocks (exit 0) ---------

@test "substance-hook: surfaces a hollow test as additionalContext, exit 0" {
    printf '%s\n' "it('x', () => {" "  doStuff();" "});" > "$TEST_DIR/a.test.ts"
    run_hook "$TEST_DIR/a.test.ts"
    [ "$status" -eq 0 ]
    [[ "$output" == *"SUBSTANCE"* ]]
    [[ "$output" == *"no-assertion"* ]]
    [[ "$output" == *"additionalContext"* ]]
}

@test "substance-hook: NEVER exits 2 (advisory, not a gate)" {
    printf '%s\n' "it('x', () => {" "  doStuff();" "});" > "$TEST_DIR/b.test.ts"
    run_hook "$TEST_DIR/b.test.ts"
    [ "$status" -ne 2 ]
    [ "$status" -eq 0 ]
}

@test "substance-hook: surfaces a stub in delivered code" {
    printf '%s\n' "export function todo() {" "  throw new Error('not implemented');" "}" \
        > "$TEST_DIR/svc.ts"
    run_hook "$TEST_DIR/svc.ts"
    [ "$status" -eq 0 ]
    [[ "$output" == *"stub"* ]]
}

# --- no-op paths -------------------------------------------------------------

@test "substance-hook: a substantive test produces no advisory" {
    printf '%s\n' "it('adds', () => {" "  expect(add(2, 2)).toBe(4);" "});" \
        > "$TEST_DIR/ok.test.ts"
    run_hook "$TEST_DIR/ok.test.ts"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "substance-hook: SKIP_SUBSTANCE_CHECK=1 disables the hook" {
    printf '%s\n' "it('x', () => {" "  doStuff();" "});" > "$TEST_DIR/c.test.ts"
    jq -n --arg f "$TEST_DIR/c.test.ts" \
        '{tool_name:"Edit", tool_input:{file_path:$f}}' > "$TEST_DIR/in.json"
    run bash -c "SKIP_SUBSTANCE_CHECK=1 CLAUDE_PROJECT_DIR='$BASE_DIR' bash '$HOOK' < '$TEST_DIR/in.json'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "substance-hook: an unsupported file extension is a no-op" {
    echo "# notes" > "$TEST_DIR/readme.md"
    run_hook "$TEST_DIR/readme.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "substance-hook: a non-edit tool is a no-op" {
    printf '%s\n' "it('x', () => { doStuff(); });" > "$TEST_DIR/d.test.ts"
    run_hook "$TEST_DIR/d.test.ts" "Read"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "substance-hook: bails to a no-op when the detector is absent" {
    mkdir -p "$TEST_DIR/empty-proj"
    printf '%s\n' "it('x', () => { doStuff(); });" > "$TEST_DIR/e.test.ts"
    run_hook "$TEST_DIR/e.test.ts" "Edit" "$TEST_DIR/empty-proj"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
