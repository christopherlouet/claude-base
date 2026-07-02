#!/usr/bin/env bash
# =============================================================================
# destructive-ops.sh — PreToolUse hook (Bash).
#
# Blocks destructive database / filesystem operations run via the Bash tool
# (DROP TABLE/DATABASE, TRUNCATE, an unscoped DELETE, wiping an uploads/media/
# storage tree, `prisma migrate reset`, …). Extracted verbatim from an inline
# settings.json `bash -c` gate — which shipped with ZERO test coverage — and
# hardened in two ways:
#   1. a bare `DELETE FROM t;` / `DELETE FROM t` (no WHERE = full-table wipe)
#      is now caught, not only the tautological `... WHERE 1=1` form;
#   2. a missing jq no longer silently disables the guard: it falls back to
#      scanning the raw stdin payload (fail SAFE), matching command-validator.sh
#      (the two Bash security guards now agree on fail-closed behaviour).
#
# Payload arrives on STDIN as JSON; the command is .tool_input.command.
# Block = exit 2 with a stderr reason. Disable with SKIP_DESTRUCTIVE_CHECK=1.
# A companion hook (destructive-migration.sh) covers destructive DDL written
# into migration FILES via Write/Edit, which this Bash-only guard cannot see.
# =============================================================================
set -euo pipefail

[ "${SKIP_DESTRUCTIVE_CHECK:-0}" = "1" ] && exit 0

# Read the PreToolUse payload from STDIN. jq is the exact, documented path;
# when absent, fall back to the raw envelope so an absent jq cannot silently
# bypass the guard (the raw fallback errs toward extra blocks, never a bypass).
INPUT=$(cat 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
else
  CMD="$INPUT"
fi
[ -z "$CMD" ] && exit 0

CMD_LOWER=$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')

DESTRUCTIVE=0

# Explicit destructive verbs, unsafe resets, and data-directory wipes.
if printf '%s' "$CMD_LOWER" | grep -qE '(drop table|drop database|truncate |rm -rf .*/uploads|rm -rf .*/media|rm -rf .*/storage|prisma migrate reset|prisma db push --force|--force-reset)'; then
  DESTRUCTIVE=1
fi

# DELETE FROM without a scoping WHERE (full-table wipe), or a tautological
# `WHERE 1=1`. A real `delete from t where <col>…` is left untouched. The
# space/paren-anchored WHERE test is robust to quotes and statement terminators
# (`delete from t;`, `delete from t'`), which a single table-name regex is not.
if printf '%s' "$CMD_LOWER" | grep -qE 'delete[[:space:]]+from[[:space:]]'; then
  if printf '%s' "$CMD_LOWER" | grep -qE 'where[[:space:]]+1[[:space:]]*(=|;|$)'; then
    DESTRUCTIVE=1
  elif ! printf '%s' "$CMD_LOWER" | grep -qE '[[:space:]]where([[:space:]]|\()'; then
    DESTRUCTIVE=1
  fi
fi

if [ "$DESTRUCTIVE" = "1" ]; then
  echo >&2 "BLOCKED: Destructive operation detected."
  echo >&2 "Command: $(printf '%s' "$CMD" | head -c 200)"
  echo >&2 "Ask the user for confirmation before proceeding (or SKIP_DESTRUCTIVE_CHECK=1)."
  exit 2
fi

exit 0
