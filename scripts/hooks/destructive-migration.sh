#!/usr/bin/env bash
# =============================================================================
# destructive-migration.sh — PreToolUse hook (Edit|Write|MultiEdit).
#
# The existing destructive-ops guard scans Bash COMMANDS; it misses a destructive
# DDL written into a MIGRATION FILE via Write/Edit (e.g. a `0002_*.sql` with a
# `DROP TABLE`). This closes that gap: when a migration file gains destructive
# DDL (DROP TABLE/COLUMN/DATABASE/SCHEMA, TRUNCATE), block with a confirm+backup
# reminder — a speed-bump, not a veto: re-run with the op acknowledged, or set
# SKIP_DESTRUCTIVE_CHECK=1.
#
# Only MIGRATION files are scanned (a numbered *.sql name or a migrations/ path),
# so ordinary code and queries are untouched (zero false positives).
# Payload on STDIN as JSON: .tool_input.file_path + .content/.new_string/edits[].
# =============================================================================
set -euo pipefail

[ "${SKIP_DESTRUCTIVE_CHECK:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || true)
command -v jq >/dev/null 2>&1 || exit 0

FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
[ -z "$FILE" ] && exit 0

# Scope to migration files only: a migrations/migrate path, or a versioned .sql
# name (0001_x.sql, V1__x.sql, 20240101_x.sql, x.up.sql). Otherwise bail (zero-FP).
base=$(basename "$FILE")
is_mig=0
case "/$FILE" in
  */migrations/*|*/migrate/*) is_mig=1 ;;
esac
case "$base" in
  [0-9]*.sql|[Vv][0-9]*__*.sql|*.up.sql) is_mig=1 ;;
esac
[ "$is_mig" -eq 1 ] || exit 0

CONTENT=$(printf '%s' "$INPUT" | jq -r '
  [ .tool_input.content // empty,
    .tool_input.new_string // empty,
    ( .tool_input.edits[]?.new_string // empty ) ] | join("\n")
' 2>/dev/null || true)
[ -z "$CONTENT" ] && exit 0

# Destructive DDL (case-insensitive). ALTER ... DROP COLUMN and bare DROP/TRUNCATE.
hit=$(printf '%s' "$CONTENT" | grep -inE \
  'drop[[:space:]]+(table|column|database|schema)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_]|[[:space:]]drop[[:space:]]+column' \
  2>/dev/null | head -n1 || true)

if [ -n "$hit" ]; then
  echo >&2 "BLOCKED: destructive DDL in a migration ($base)."
  echo >&2 "  $(printf '%s' "$hit" | cut -c1-120)"
  echo >&2 "Destructive migrations drop data irreversibly. Before proceeding: confirm with"
  echo >&2 "the user, back up the affected data, and prefer an expand/contract (deprecate"
  echo >&2 "then drop) over an in-place drop. Acknowledge, or set SKIP_DESTRUCTIVE_CHECK=1."
  exit 2
fi

exit 0
