#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/log-event.sh — the one writer behind the lifecycle
# logging hooks (Notification, SubagentStop, SessionEnd, PreCompact, ...).
#
# Fourteen inline `bash -c 'echo ... >> /tmp/claude-*.log'` hooks wrote to
# /tmp, which every account on the machine can read, with files created
# world-readable. Two copied the first 200 bytes of their payload: for
# PermissionDenied that is the refused command itself, for a permission
# notification the session id and transcript path. Some also logged in French
# into an English product ("Permission demandee", "Fin de session").
#
# The writer logs to a private per-user directory and records only fields that
# cannot carry free text: the tag the hook passes, a timestamp, and named
# scalar fields read from the payload (tool_name, notification_type, ...).
# =============================================================================

load 'test_helper'

LOGGER="$BASE_DIR/scripts/hooks/log-event.sh"
SETTINGS="$BASE_DIR/.claude/settings.json"

setup() {
    setup_test_dir
    export CLAUDE_BASE_LOG_DIR="$TEST_DIR/state/claude-base"
}

teardown() {
    teardown_test_dir
}

mode_of() {
    stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1"
}

@test "log-event: appends one tagged, timestamped line to the named log" {
    run bash -c "printf '{}' | bash '$LOGGER' sessions SESSION-END"
    [ "$status" -eq 0 ]
    [ -f "$CLAUDE_BASE_LOG_DIR/sessions.log" ]
    run cat "$CLAUDE_BASE_LOG_DIR/sessions.log"
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z\ SESSION-END$ ]]
}

@test "log-event: the directory and the log are private to the user" {
    printf '{}' | bash "$LOGGER" sessions SESSION-END
    [ "$(mode_of "$CLAUDE_BASE_LOG_DIR")" = "700" ]
    [ "$(mode_of "$CLAUDE_BASE_LOG_DIR/sessions.log")" = "600" ]
}

@test "log-event: records a named scalar field from the payload" {
    skip_if_no_jq
    printf '{"tool_name":"Bash"}' | bash "$LOGGER" failures TOOL-FAIL tool_name
    grep -qE ' TOOL-FAIL tool_name=Bash$' "$CLAUDE_BASE_LOG_DIR/failures.log"
}

@test "log-event: never writes the payload's free text" {
    skip_if_no_jq
    local payload
    payload=$(jq -n '{notification_type:"permission_prompt",
        message:"SENTINEL-MESSAGE", transcript_path:"/home/x/SENTINEL-PATH",
        tool_input:{command:"echo SENTINEL-COMMAND"}}')
    printf '%s' "$payload" | bash "$LOGGER" notifications PERMISSION-PROMPT notification_type
    grep -q 'notification_type=permission_prompt' "$CLAUDE_BASE_LOG_DIR/notifications.log"
    ! grep -q 'SENTINEL' "$CLAUDE_BASE_LOG_DIR/notifications.log"
}

@test "log-event: a field that is not a scalar is not written" {
    skip_if_no_jq
    printf '{"tool_input":{"command":"echo SENTINEL"}}' | bash "$LOGGER" failures TOOL-FAIL tool_input
    ! grep -q 'SENTINEL' "$CLAUDE_BASE_LOG_DIR/failures.log"
    # Not even a mangled remnant of the object.
    ! grep -q 'tool_input=' "$CLAUDE_BASE_LOG_DIR/failures.log"
}

@test "log-event: a field value cannot inject a newline or spaces" {
    skip_if_no_jq
    printf '{"tool_name":"Bash\\nFORGED-LINE x"}' | bash "$LOGGER" failures TOOL-FAIL tool_name
    run cat "$CLAUDE_BASE_LOG_DIR/failures.log"
    [ "${#lines[@]}" -eq 1 ]
    [[ "$output" != *" x"* ]]
}

@test "log-event: an unwritable log directory is silent and exits 0" {
    export CLAUDE_BASE_LOG_DIR="/proc/claude-base-cannot-exist"
    run bash -c "printf '{}' | bash '$LOGGER' sessions SESSION-END"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "log-event: defaults to XDG_STATE_HOME, not /tmp" {
    unset CLAUDE_BASE_LOG_DIR
    run bash -c "printf '{}' | XDG_STATE_HOME='$TEST_DIR/xdg' bash '$LOGGER' sessions SESSION-END"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/xdg/claude-base/sessions.log" ]
}

@test "log-event: refuses a log name that would leave the directory" {
    run bash -c "printf '{}' | bash '$LOGGER' '../escape' SESSION-END"
    [ "$status" -eq 0 ]
    [ ! -e "$TEST_DIR/state/escape.log" ]
}

# =============================================================================
# settings.json — every lifecycle logging hook goes through the writer.
# =============================================================================

@test "settings.json: no hook command writes to /tmp" {
    skip_if_no_jq
    run jq -r '[.hooks[][] | .hooks[]? | .command // empty | select(test(">>?\\s*/tmp/"))] | .[]' "$SETTINGS"
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}

@test "settings.json: no hook command copies its raw payload into a log" {
    skip_if_no_jq
    # `head -c N` of stdin was how the payload (command text, paths) got logged.
    run jq -r '[.hooks[][] | .hooks[]? | .command // empty | select(test("head -c"))] | .[]' "$SETTINGS"
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}

@test "settings.json: the lifecycle logging hooks call log-event.sh" {
    skip_if_no_jq
    run jq -r '[.hooks[][] | .hooks[]? | .command // empty | select(test("log-event\\.sh"))] | length' "$SETTINGS"
    [ "$output" -ge 14 ]
}

@test "settings.json: hook messages are English (no French left)" {
    skip_if_no_jq
    run bash -c "jq -r '.. | strings' '$SETTINGS' | grep -niE '\\b(demandee|termine|fin de session|du contexte|personnalises|detectes|verifiez|depot)\\b'"
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}
