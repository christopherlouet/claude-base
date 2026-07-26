#!/usr/bin/env bash
# =============================================================================
# _policy-destructive-sql.sh — Harness-neutral core of the destructive-data
# guards
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/), shared by TWO
# shells: destructive-ops.sh (Bash commands) and destructive-migration.sh
# (migration files written via the edit path). One representation of the
# destructive-DDL policy — divergent copies are how guard bugs ship.
#
# Verdict contract (plain strings in, data verdicts out, no harness plumbing):
#   check_destructive_command <cmd>                 0 allow / 1 deny + reason on stdout
#   is_migration_file <path>                        0 yes   / 1 no
#   check_migration_content <content> <basename>    0 clean / 1 deny + reason on stdout
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only, no top-level side effects beyond
# sourcing the shared strip helper.
# =============================================================================

# Avoid double-sourcing
if [ -n "${POLICY_DESTRUCTIVE_SQL_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
POLICY_DESTRUCTIVE_SQL_LOADED=1

# --- policy bootstrap (keep byte-identical across _policy-*.sh; guarded by policy-structure.bats) ---
# Shared message/--grep/--file value strip (single canonical copy in
# _core-helpers.sh). Missing helper file → no-op strip fallback: message
# payloads may then over-block, but a missing file can never turn into a
# silent bypass. POLICY_HAVE_CORE_STRIP keys on CORE_HELPERS_LOADED, NOT on
# `declare -F` alone: a sibling policy lib's no-op fallback also satisfies
# declare -F, and mistaking it for the real strip would skip the per-segment
# defenses that assume values were really stripped (pass-3 false-block class).
_policy_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=_core-helpers.sh
if [ -n "$_policy_dir" ] && [ -f "$_policy_dir/_core-helpers.sh" ]; then . "$_policy_dir/_core-helpers.sh"; fi
# shellcheck disable=SC2034  # consumed by dangerous-commands Category 9; set in every copy so the bootstrap stays byte-identical
if [ -n "${CORE_HELPERS_LOADED:-}" ] && declare -F strip_msg_values >/dev/null 2>&1; then
  POLICY_HAVE_CORE_STRIP=1
else
  POLICY_HAVE_CORE_STRIP=0
  declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }
fi
# --- end policy bootstrap ---

check_destructive_command() {
  local CMD="$1"
  [ -z "$CMD" ] && return 0

  local CMD_LOWER SCAN
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
  #      (shared strip_msg_values — its bare-value arm stops at ;&| so
  #      `-m 'wip';prisma migrate reset` keeps the separator and the REAL chained
  #      command; the old inline sed ate both).
  # Scope note: inline-comment obfuscation (`DROP/**/TABLE`) is deliberately NOT
  # defended — a well-meaning agent writes `DROP TABLE`, not the split form; this
  # is a best-effort anti-accident guard, not an anti-evasion boundary.
  SCAN=$(printf '%s' "$CMD_LOWER" \
    | sed -E 's/--[[:space:]].*$//' \
    | tr '\n' ' ')
  SCAN=$(strip_msg_values "$SCAN")

  local DESTRUCTIVE=0

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
    printf '%s\n' "BLOCKED: Destructive operation detected."
    printf '%s\n' "Command: $(printf '%s' "$CMD" | head -c 200)"
    printf '%s\n' "Ask the user for confirmation before proceeding (or SKIP_DESTRUCTIVE_CHECK=1)."
    return 1
  fi
  return 0
}

# is_migration_file <path> — scope the migration guard to migration files only:
# a migrations/migrate path, or a versioned .sql name (0001_x.sql, V1__x.sql,
# 20240101_x.sql, x.up.sql). Anything else is not a migration (zero-FP).
is_migration_file() {
  local FILE="$1"
  [ -z "$FILE" ] && return 1
  local base
  base=$(basename "$FILE")
  case "/$FILE" in
    */migrations/*|*/migrate/*) return 0 ;;
  esac
  case "$base" in
    [0-9]*.sql|[Vv][0-9]*__*.sql|*.up.sql) return 0 ;;
  esac
  return 1
}

# check_migration_content <content> <basename> — destructive DDL
# (case-insensitive): ALTER ... DROP COLUMN and bare DROP/TRUNCATE.
check_migration_content() {
  local CONTENT="$1" base="$2"
  [ -z "$CONTENT" ] && return 0

  local hit
  hit=$(printf '%s' "$CONTENT" | grep -inE \
    'drop[[:space:]]+(table|column|database|schema)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_]|[[:space:]]drop[[:space:]]+column' \
    2>/dev/null | head -n1 || true)

  if [ -n "$hit" ]; then
    printf '%s\n' "BLOCKED: destructive DDL in a migration ($base)."
    printf '%s\n' "  $(printf '%s' "$hit" | cut -c1-120)"
    printf '%s\n' "Destructive migrations drop data irreversibly. Before proceeding: confirm with"
    printf '%s\n' "the user, back up the affected data, and prefer an expand/contract (deprecate"
    printf '%s\n' "then drop) over an in-place drop. Acknowledge, or set SKIP_DESTRUCTIVE_CHECK=1."
    return 1
  fi
  return 0
}
