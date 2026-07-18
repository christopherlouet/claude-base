#!/usr/bin/env bash
# =============================================================================
# destructive-ops.sh — PreToolUse hook (Bash).
#
# Blocks destructive database / filesystem operations run via the Bash tool
# (DROP TABLE/DATABASE, TRUNCATE, an unscoped DELETE, wiping an uploads/media/
# storage tree, `prisma migrate reset`, …).
#
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): the whole
# destructive-DDL policy lives in _policy-destructive-sql.sh (shared with
# destructive-migration.sh, directly tested by tests/policy-destructive-sql.bats).
# This shell reads the stdin envelope, calls check_destructive_command, and
# translates a deny into stderr + exit 2.
#
# Fail-closed lineage (matching command-validator.sh — the two Bash security
# guards agree on fail-closed behaviour):
#   - a missing jq falls back to scanning the raw stdin payload (extra blocks
#     possible, never a bypass);
#   - a missing policy core BLOCKS with a recovery hint instead of no-op'ing.
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

_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-destructive-sql.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-destructive-sql.sh" ]; then
  . "$_dir/_policy-destructive-sql.sh"
else
  echo >&2 "BLOCKED: destructive-ops policy core missing (_policy-destructive-sql.sh)."
  echo >&2 "Run 'claude-base update' to restore the hook libs. To bypass instead, set"
  echo >&2 "SKIP_DESTRUCTIVE_CHECK=1 in the hook environment (the \"env\" block of"
  echo >&2 ".claude/settings.local.json) - an inline VAR=1 prefix on the command does"
  echo >&2 "NOT reach this hook."
  exit 2
fi

# Verdict translation: deny (return 1, reason on stdout) → stderr + exit 2.
if _reason=$(check_destructive_command "$CMD"); then
  exit 0
else
  printf '%s\n' "$_reason" >&2
  exit 2
fi
