#!/usr/bin/env bats

# =============================================================================
# Direct tests for scripts/hooks/_policy-destructive-sql.sh — the
# harness-neutral core shared by destructive-ops.sh (Bash commands) and
# destructive-migration.sh (migration files).
#
# Verdicts on plain strings, no envelope:
#   check_destructive_command <cmd>       — 0 allow / 1 deny + reason
#   is_migration_file <path>              — 0 yes / 1 no
#   check_migration_content <content> <basename> — 0 clean / 1 deny + reason
# =============================================================================

load 'test_helper'

POLICY="$BASE_DIR/scripts/hooks/_policy-destructive-sql.sh"

run_cmd() {
    run bash -c ". '$POLICY'; check_destructive_command \"\$1\"" _ "$1"
}

run_mig_file() {
    run bash -c ". '$POLICY'; is_migration_file \"\$1\"" _ "$1"
}

run_mig_content() {
    run bash -c ". '$POLICY'; check_migration_content \"\$1\" \"\$2\"" _ "$1" "$2"
}

@test "policy-sql: core file exists, sourceable, functions defined" {
    [ -f "$POLICY" ]
    run bash -c "set -euo pipefail; . '$POLICY'; declare -F check_destructive_command >/dev/null && declare -F is_migration_file >/dev/null && declare -F check_migration_content >/dev/null"
    [ "$status" -eq 0 ]
}

# --- Command variant (destructive-ops) ---------------------------------------

@test "policy-sql: denies DROP TABLE in a command" {
    run_cmd 'psql -c "DROP TABLE users"'
    [ "$status" -eq 1 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "policy-sql: denies irregular-whitespace DROP  TABLE" {
    run_cmd 'psql -c "DROP  TABLE users"'
    [ "$status" -eq 1 ]
}

@test "policy-sql: denies TRUNCATE of a table" {
    run_cmd 'mysql -e "TRUNCATE users"'
    [ "$status" -eq 1 ]
}

@test "policy-sql: allows coreutils truncate -s 0" {
    run_cmd "truncate -s 0 logfile.txt"
    [ "$status" -eq 0 ]
}

@test "policy-sql: denies an unscoped DELETE FROM" {
    run_cmd 'psql -c "DELETE FROM users"'
    [ "$status" -eq 1 ]
}

@test "policy-sql: denies DELETE with tautological WHERE 1=1" {
    run_cmd 'psql -c "DELETE FROM users WHERE 1=1"'
    [ "$status" -eq 1 ]
}

@test "policy-sql: allows a scoped DELETE" {
    run_cmd 'psql -c "DELETE FROM users WHERE id = 42"'
    [ "$status" -eq 0 ]
}

@test "policy-sql: multi-line DELETE with WHERE on the next line is allowed" {
    run_cmd $'psql -c "DELETE FROM users\nWHERE id = 42"'
    [ "$status" -eq 0 ]
}

@test "policy-sql: a commented-out where does not fake a scope" {
    run_cmd $'psql -c "DELETE FROM users -- where id = 1"'
    [ "$status" -eq 1 ]
}

@test "policy-sql: denies prisma migrate reset" {
    run_cmd "npx prisma migrate reset --force"
    [ "$status" -eq 1 ]
}

@test "policy-sql: denies rm -rf of an uploads tree" {
    run_cmd "rm -rf ./public/uploads"
    [ "$status" -eq 1 ]
}

@test "policy-sql: allows a message payload naming DROP TABLE" {
    run_cmd 'git commit -m "explain the DROP TABLE migration"'
    [ "$status" -eq 0 ]
}

@test "policy-sql: real chained command after a message value still denies" {
    run_cmd "git commit -m 'wip';prisma migrate reset"
    [ "$status" -eq 1 ]
}

@test "policy-sql: empty command is allowed" {
    run_cmd ""
    [ "$status" -eq 0 ]
}

# --- Migration-file variant (destructive-migration) --------------------------

@test "policy-sql: classifies migrations/ paths as migration files" {
    run_mig_file "db/migrations/0002_drop.sql"
    [ "$status" -eq 0 ]
}

@test "policy-sql: classifies versioned sql names as migration files" {
    run_mig_file "0001_init.sql"
    [ "$status" -eq 0 ]
    run_mig_file "V2__cleanup.sql"
    [ "$status" -eq 0 ]
    run_mig_file "changes.up.sql"
    [ "$status" -eq 0 ]
}

@test "policy-sql: ordinary files are NOT migration files" {
    run_mig_file "src/queries.sql"
    [ "$status" -eq 1 ]
    run_mig_file "src/app.ts"
    [ "$status" -eq 1 ]
}

@test "policy-sql: denies DROP TABLE in migration content" {
    run_mig_content "DROP TABLE users;" "0002_drop.sql"
    [ "$status" -eq 1 ]
    [[ "$output" == *"BLOCKED"* ]]
}

@test "policy-sql: denies ALTER ... DROP COLUMN in migration content" {
    run_mig_content "ALTER TABLE users DROP COLUMN email;" "0003_x.sql"
    [ "$status" -eq 1 ]
}

@test "policy-sql: allows an additive migration" {
    run_mig_content "ALTER TABLE users ADD COLUMN age integer;" "0004_add.sql"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
