#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/destructive-ops.sh — PreToolUse (Bash) guard that
# blocks destructive DB/filesystem operations. Extracted from an inline
# settings.json `bash -c` gate (which had ZERO test coverage) and hardened:
#   - a bare `DELETE FROM t;` (no WHERE = full-table wipe) is now caught;
#   - missing jq no longer silently disables the guard (scan the raw payload).
# Payload arrives on STDIN as JSON (.tool_input.command). Block = exit 2.
# =============================================================================

load 'test_helper'

GUARD="$BATS_TEST_DIRNAME/../scripts/hooks/destructive-ops.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# run_guard <command-string> — feed a PreToolUse Bash envelope on stdin.
run_guard() {
    local json
    json=$(jq -n --arg c "$1" '{tool_name:"Bash", tool_input:{command:$c}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "bash '$GUARD' < '$TEST_DIR/input.json' 2>&1"
}

# --- Blocking: destructive operations must exit 2 --------------------------

@test "destructive-ops: blocks DROP TABLE" {
    run_guard "psql -c 'DROP TABLE users'"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "destructive-ops: blocks DROP DATABASE" {
    run_guard "mysql -e 'DROP DATABASE prod'"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks TRUNCATE" {
    run_guard "psql -c 'TRUNCATE users'"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks a tautological DELETE ... WHERE 1=1" {
    run_guard "psql -c 'DELETE FROM users WHERE 1=1'"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks a bare DELETE FROM with no WHERE (full-table wipe)" {
    run_guard "psql -c 'DELETE FROM users;'"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks DELETE FROM with no WHERE at end of string" {
    run_guard "psql -c 'DELETE FROM users'"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks rm -rf of an uploads directory" {
    run_guard "rm -rf /app/public/uploads"
    [ "$status" -eq 2 ]
}

@test "destructive-ops: blocks prisma migrate reset" {
    run_guard "npx prisma migrate reset"
    [ "$status" -eq 2 ]
}

# --- Allowing: safe / targeted operations must exit 0 ----------------------

@test "destructive-ops: does NOT block a targeted DELETE with a real WHERE" {
    run_guard "psql -c 'DELETE FROM users WHERE id = 5'"
    [ "$status" -eq 0 ]
}

@test "destructive-ops: does NOT block a SELECT" {
    run_guard "psql -c 'SELECT * FROM users'"
    [ "$status" -eq 0 ]
}

@test "destructive-ops: does NOT block a safe command" {
    run_guard "npm test"
    [ "$status" -eq 0 ]
}

@test "destructive-ops: non-Bash tool (no command) → exit 0" {
    printf '%s' '{"tool_name":"Read","tool_input":{"file_path":"x"}}' > "$TEST_DIR/input.json"
    run bash -c "bash '$GUARD' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

# --- Escape hatch + fail-safe ----------------------------------------------

@test "destructive-ops: SKIP_DESTRUCTIVE_CHECK=1 bypasses" {
    local json
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"DROP TABLE users"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    run bash -c "SKIP_DESTRUCTIVE_CHECK=1 bash '$GUARD' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 0 ]
}

@test "destructive-ops: fails SAFE without jq (scans raw payload, still blocks)" {
    local json fakebin b
    json=$(jq -n '{tool_name:"Bash", tool_input:{command:"DROP TABLE users"}}')
    printf '%s' "$json" > "$TEST_DIR/input.json"
    # Build a PATH that has the coreutils the hook needs but NO jq, so
    # `command -v jq` fails and the raw-payload fallback is exercised.
    fakebin="$TEST_DIR/nojq"; mkdir -p "$fakebin"
    for b in bash cat tr grep sed; do ln -sf "$(command -v "$b")" "$fakebin/$b"; done
    run bash -c "PATH='$fakebin' bash '$GUARD' < '$TEST_DIR/input.json' 2>&1"
    [ "$status" -eq 2 ]
}

# --- Self-application: the real hook on a real safe command ------------------

@test "destructive-ops: self-application — a benign real command passes" {
    run_guard "git status && npm run build"
    [ "$status" -eq 0 ]
}
