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

# Build the SCAN string the matchers run against, in this order:
#   1. Strip SQL line-comments introduced by "-- " (dash-dash-SPACE) PER LINE so
#      a commented-out "where" cannot fake a scope on an unscoped DELETE, while a
#      "--flag" (dash-dash-LETTER) and a verb on a LATER line both survive.
#   2. Flatten newlines to spaces so a multi-line construct is one line for the
#      value-strip and WHERE tests (a multi-line DELETE's WHERE is now adjacent).
#   3. Strip message VALUES (the quoted/next token after -m/-am/--message) so a
#      commit message that merely NAMES a verb ("explain the DROP TABLE
#      migration", even across lines) is not treated as the operation itself
#      (mirrors command-validator.sh's message-stripping).
SCAN=$(printf '%s' "$CMD_LOWER" \
  | sed -E 's/--[[:space:]].*$//' \
  | tr '\n' ' ' \
  | sed -E "s/[[:space:]]-[a-z]*m([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g" \
  | sed -E "s/[[:space:]]--message([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:]]+)//g")

DESTRUCTIVE=0

# Explicit destructive verbs, unsafe resets, and data-directory wipes.
# - drop/truncate use [[:space:]]+ so `DROP  TABLE` (irregular whitespace) can't slip past.
# - `truncate[[:space:]]+[^-[:space:]]` matches SQL `TRUNCATE [TABLE] name` but NOT
#   coreutils `truncate -s 0 file` (a flag, i.e. a dash, follows the command).
if printf '%s' "$SCAN" | grep -qE '(drop[[:space:]]+table|drop[[:space:]]+database|truncate[[:space:]]+[^-[:space:]]|rm -rf .*/uploads|rm -rf .*/media|rm -rf .*/storage|prisma migrate reset|prisma db push --force|--force-reset)'; then
  DESTRUCTIVE=1
fi

# DELETE FROM without a scoping WHERE (full-table wipe), or a tautological
# `WHERE 1=1`. A real `delete from t where <col>…` is left untouched. The WHERE
# test accepts a clause at line start ((^|space)) so a multi-line statement
# (`DELETE FROM t\nWHERE …`) is not misread as unscoped, and runs on the
# comment-stripped SCAN so a `-- where` comment cannot fake the scope.
if printf '%s' "$SCAN" | grep -qE 'delete[[:space:]]+from[[:space:]]'; then
  if printf '%s' "$SCAN" | grep -qE 'where[[:space:]]+1[[:space:]]*(=|;|$)'; then
    DESTRUCTIVE=1
  elif ! printf '%s' "$SCAN" | grep -qE '(^|[[:space:]])where([[:space:]]|\()'; then
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
