#!/usr/bin/env bash
# =============================================================================
# destructive-migration.sh — PreToolUse hook (Edit|Write|MultiEdit).
#
# The destructive-ops guard scans Bash COMMANDS; it misses a destructive DDL
# written into a MIGRATION FILE via Write/Edit (e.g. a `0002_*.sql` with a
# `DROP TABLE`). This closes that gap: when a migration file gains destructive
# DDL (DROP TABLE/COLUMN/DATABASE/SCHEMA, TRUNCATE), block with a confirm+backup
# reminder — a speed-bump, not a veto: re-run with the op acknowledged, or set
# SKIP_DESTRUCTIVE_CHECK=1.
#
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): the
# migration-file scoping and DDL policy live in _policy-destructive-sql.sh
# (shared with destructive-ops.sh). This shell reads the stdin envelope, calls
# the core, and translates a deny into stderr + exit 2. Fail-open lineage
# (matching the missing-jq behaviour below): a missing policy core no-ops.
#
# Only MIGRATION files are scanned (a numbered *.sql name or a migrations/ path),
# so ordinary code and queries are untouched (zero false positives).
# Payload on STDIN as JSON: .tool_input.file_path + .content/.new_string/edits[].
# =============================================================================
set -euo pipefail

[ "${SKIP_DESTRUCTIVE_CHECK:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || true)
command -v jq >/dev/null 2>&1 || exit 0

# NotebookEdit sends .notebook_path / .new_source instead of .file_path /
# .new_string (matcher covers NotebookEdit since pass-3).
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)
[ -z "$FILE" ] && exit 0

_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-destructive-sql.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-destructive-sql.sh" ]; then
  . "$_dir/_policy-destructive-sql.sh"
else
  exit 0
fi

is_migration_file "$FILE" || exit 0

CONTENT=$(printf '%s' "$INPUT" | jq -r '
  [ .tool_input.content // empty,
    .tool_input.new_string // empty,
    .tool_input.new_source // empty,
    ( .tool_input.edits[]?.new_string // empty ) ] | join("\n")
' 2>/dev/null || true)
[ -z "$CONTENT" ] && exit 0

# Verdict translation: deny (return 1, reason on stdout) → stderr + exit 2.
if _reason=$(check_migration_content "$CONTENT" "$(basename "$FILE")"); then
  exit 0
else
  printf '%s\n' "$_reason" >&2
  exit 2
fi
