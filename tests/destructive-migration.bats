#!/usr/bin/env bats

# Tests for scripts/hooks/destructive-migration.sh — blocks destructive DDL
# written into a MIGRATION file (the existing destructive guard only scans Bash
# commands). Scoped to migration files only (zero-FP on ordinary code/queries).
# Requires jq (the hook fails open without it). Input = PreToolUse payload stdin.

load 'test_helper'

HOOK="$BATS_TEST_DIRNAME/../scripts/hooks/destructive-migration.sh"

setup() { command -v jq >/dev/null 2>&1 || skip "jq not available"; }

@test "blocks DROP TABLE in a numbered migration file" {
    run bash "$HOOK" <<<'{"tool_input":{"file_path":"0002_drop_legacy.sql","content":"DROP TABLE IF EXISTS audit_log_v1;"}}'
    [ "$status" -eq 2 ]
    [[ "$output" == *"destructive"* ]]
}

@test "blocks DROP COLUMN under a migrations/ path" {
    run bash "$HOOK" <<<'{"tool_input":{"file_path":"db/migrate/20240101_change.sql","new_string":"ALTER TABLE users DROP COLUMN email;"}}'
    [ "$status" -eq 2 ]
}

@test "blocks TRUNCATE in a migration" {
    run bash "$HOOK" <<<'{"tool_input":{"file_path":"migrations/0005_wipe.sql","content":"TRUNCATE TABLE sessions;"}}'
    [ "$status" -eq 2 ]
}

@test "allows a create-only migration" {
    run bash "$HOOK" <<<'{"tool_input":{"file_path":"0003_add_index.sql","content":"CREATE INDEX idx ON users(email);"}}'
    [ "$status" -eq 0 ]
}

@test "ignores destructive SQL in a NON-migration file (out of scope, zero-FP)" {
    run bash "$HOOK" <<<'{"tool_input":{"file_path":"src/query.js","content":"db.query(\"DROP TABLE staging\")"}}'
    [ "$status" -eq 0 ]
}

@test "respects SKIP_DESTRUCTIVE_CHECK" {
    SKIP_DESTRUCTIVE_CHECK=1 run bash "$HOOK" <<<'{"tool_input":{"file_path":"0002_drop_legacy.sql","content":"DROP TABLE x;"}}'
    [ "$status" -eq 0 ]
}

@test "empty payload exits cleanly" {
    run bash "$HOOK" <<<'{"tool_input":{}}'
    [ "$status" -eq 0 ]
}
