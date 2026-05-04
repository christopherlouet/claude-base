#!/usr/bin/env bats

# =============================================================================
# Tests for the hook output rewriter (Phase 1 — Foundation)
# =============================================================================
# Covers:
#  - scripts/hooks/_hook-helpers.sh   (sourceable helpers)
#  - scripts/hooks/check-cli-version.sh   (SessionStart capability probe)
#
# Phase 2 (bash-output-filter) and Phase 3 (post-edit-typecheck-and-lint)
# tests will be added later in this same file.
# =============================================================================

load 'test_helper'

HELPERS="$SOCLE_DIR/scripts/hooks/_hook-helpers.sh"
CHECK_VERSION="$SOCLE_DIR/scripts/hooks/check-cli-version.sh"
SENTINEL_FILE="/tmp/claude-rewriter-supported"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Ensure sentinel cleanup before each test
    rm -f "$SENTINEL_FILE"
    # Build a fake `claude` binary path that tests can prepend to PATH
    FAKE_BIN="$TEST_DIR/fake-bin"
    mkdir -p "$FAKE_BIN"
    export FAKE_BIN
}

teardown() {
    rm -f "$SENTINEL_FILE"
    teardown_test_dir
}

# Helper: install a fake `claude` that prints a given version string
install_fake_claude() {
    local version_string="$1"
    cat > "$FAKE_BIN/claude" <<EOF
#!/usr/bin/env bash
echo "$version_string"
EOF
    chmod +x "$FAKE_BIN/claude"
}

# =============================================================================
# Phase 1: _hook-helpers.sh
# =============================================================================

@test "Phase 1: _hook-helpers.sh exists and is sourceable" {
    [ -f "$HELPERS" ]
    run bash -c "source '$HELPERS' && type hook_bail_if_disabled hook_bail_if_unsupported hook_strip_ansi hook_emit_envelope"
    [ "$status" -eq 0 ]
}

@test "Phase 1: hook_bail_if_disabled exits 0 when env var = 1" {
    run bash -c "
        source '$HELPERS'
        export FOO_FLAG=1
        hook_bail_if_disabled FOO_FLAG
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_disabled does not bail when env var unset" {
    run bash -c "
        source '$HELPERS'
        unset FOO_FLAG
        hook_bail_if_disabled FOO_FLAG
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_bail_if_disabled does not bail when env var = 0" {
    run bash -c "
        source '$HELPERS'
        export FOO_FLAG=0
        hook_bail_if_disabled FOO_FLAG
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_bail_if_unsupported exits 0 when sentinel missing" {
    rm -f "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_unsupported exits 0 when sentinel content != 1" {
    echo "0" > "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'should not reach'
    "
    [ "$status" -eq 0 ]
    [[ "$output" != *"should not reach"* ]]
}

@test "Phase 1: hook_bail_if_unsupported returns when sentinel content = 1" {
    echo "1" > "$SENTINEL_FILE"
    run bash -c "
        source '$HELPERS'
        hook_bail_if_unsupported
        echo 'reached'
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"reached"* ]]
}

@test "Phase 1: hook_strip_ansi removes ANSI escape sequences" {
    run bash -c "
        source '$HELPERS'
        printf '\x1b[31mred text\x1b[0m and \x1b[1;32mgreen\x1b[0m' | hook_strip_ansi
    "
    [ "$status" -eq 0 ]
    [ "$output" = "red text and green" ]
}

@test "Phase 1: hook_strip_ansi passes plain text unchanged" {
    run bash -c "
        source '$HELPERS'
        echo 'plain text' | hook_strip_ansi
    "
    [ "$status" -eq 0 ]
    [ "$output" = "plain text" ]
}

@test "Phase 1: hook_emit_envelope produces valid JSON with hookSpecificOutput" {
    run bash -c "
        source '$HELPERS'
        hook_emit_envelope 'PostToolUse' 'updatedToolOutput' 'hello world'
    "
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.updatedToolOutput == "hello world"' >/dev/null
}

@test "Phase 1: hook_emit_envelope handles multi-line values" {
    run bash -c "
        source '$HELPERS'
        printf 'line1\nline2\nline3' | xargs -I {} echo {} > /dev/null  # no-op, keeps subshell
        hook_emit_envelope 'PostToolUse' 'updatedToolOutput' \"\$(printf 'line1\nline2')\"
    "
    [ "$status" -eq 0 ]
    local val
    val=$(echo "$output" | jq -r '.hookSpecificOutput.updatedToolOutput')
    [ "$val" = "$(printf 'line1\nline2')" ]
}

@test "Phase 1: hook_emit_envelope handles UserPromptSubmit + additionalContext" {
    run bash -c "
        source '$HELPERS'
        hook_emit_envelope 'UserPromptSubmit' 'additionalContext' 'some context'
    "
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "UserPromptSubmit"' >/dev/null
    echo "$output" | jq -e '.hookSpecificOutput.additionalContext == "some context"' >/dev/null
}

# =============================================================================
# Phase 1: check-cli-version.sh (SessionStart probe)
# =============================================================================

@test "Phase 1: check-cli-version exists and is executable" {
    [ -x "$CHECK_VERSION" ]
}

@test "Phase 1: check-cli-version writes sentinel = 1 on supported version (2.1.121)" {
    install_fake_claude "2.1.121 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version writes sentinel = 1 on supported version (2.1.126)" {
    install_fake_claude "2.1.126 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version writes sentinel = 0 on unsupported version (2.1.120)" {
    install_fake_claude "2.1.120 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version emits notice on unsupported version" {
    install_fake_claude "2.1.100 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [[ "$output" == *"2.1.121"* ]]
    [[ "$output" == *"disabled"* ]] || [[ "$output" == *"requires"* ]]
}

@test "Phase 1: check-cli-version handles minor version above 1 (2.2.0)" {
    install_fake_claude "2.2.0 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version handles major version above 2 (3.0.0)" {
    install_fake_claude "3.0.0 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "1" ]
}

@test "Phase 1: check-cli-version handles older major (1.99.999)" {
    install_fake_claude "1.99.999 (Claude Code)"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version falls back silently on garbage version output" {
    install_fake_claude "this is not a version"
    PATH="$FAKE_BIN:$PATH" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version falls back silently when claude binary is missing" {
    # Empty PATH still needs /usr/bin for env+bash. Use an empty fake-bin dir.
    local empty_dir="$TEST_DIR/empty-bin"
    mkdir -p "$empty_dir"
    PATH="$empty_dir:/usr/bin:/bin" run "$CHECK_VERSION"
    [ "$status" -eq 0 ]
    [ -f "$SENTINEL_FILE" ]
    [ "$(cat "$SENTINEL_FILE")" = "0" ]
}

@test "Phase 1: check-cli-version completes in less than 2 seconds" {
    install_fake_claude "2.1.126 (Claude Code)"
    local start_ns end_ns
    start_ns=$(date +%s%N)
    PATH="$FAKE_BIN:$PATH" "$CHECK_VERSION" >/dev/null 2>&1
    end_ns=$(date +%s%N)
    local elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
    [ "$elapsed_ms" -lt 2000 ]
}
