#!/usr/bin/env bash
# =============================================================================
# _policy-write-targets.sh — Harness-neutral write-target extraction core
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/) for
# bash-write-guard.sh: given a raw shell command, print the candidate WRITE
# TARGET paths (redirections, tee, sed -i/--in-place, cp/mv/install DEST,
# dd of=plain-file), one per line, after:
#   - message/--file/--grep VALUE strip (a commit message NAMING a file
#     operation is data, not a write);
#   - quote-strip + newline-flatten for token extraction;
#   - package-manager `install` neutralization (pip/npm/apt/… install is not
#     a file write; coreutils `install SRC DST` is and still matches).
#
# No verdict here: target CLASSIFICATION lives in _sensitive-paths.sh
# (is_protected_config / is_secret_file), and ENVIRONMENT checks (existence,
# current branch, git-tracked) stay in the shell — they depend on the machine,
# not on the policy.
#
# NOT a hook by itself. Do not register in settings.json.
# macOS bash 3.2 compatible; functions only, no top-level side effects beyond
# sourcing the shared strip helper.
# =============================================================================

# Avoid double-sourcing
if [ -n "${POLICY_WRITE_TARGETS_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
POLICY_WRITE_TARGETS_LOADED=1

# Shared message-value strip (single canonical copy in _core-helpers.sh).
# Missing helper → no strip → possible over-extraction, never a bypass.
_pwt_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=_core-helpers.sh
if [ -n "$_pwt_dir" ] && [ -f "$_pwt_dir/_core-helpers.sh" ]; then . "$_pwt_dir/_core-helpers.sh"; fi
declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }

extract_write_targets() {
  local CMD="$1"
  [ -z "$CMD" ] && return 0

  # Quote-stripped, newline-flattened copy for token extraction.
  local CMD_UQ CMD_UQ_CPMV targets
  CMD_UQ=$(printf '%s' "$(strip_msg_values "$CMD")" | tr -d "\"'" | tr '\n' ' ')

  # Package-manager `install` subcommands (pip/npm/apt/cargo/…) are not file
  # writes: without this, the (cp|mv|install) DEST extraction below reads
  # `pip install -r requirements.txt` as a write to requirements.txt and
  # hard-blocks routine installs on main. Neutralize `[sudo] <pm> [flags]
  # install` for that ONE extractor; the coreutils `install SRC DST` (a real
  # file write) has no such prefix and still matches. Redirect/tee/sed/dd
  # extraction keeps the untouched CMD_UQ (a `pip install x > file` redirect
  # must still be seen).
  CMD_UQ_CPMV=$(printf '%s' "$CMD_UQ" | sed -E 's/(^|[[:space:]|&;(])(sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*)?(pip[0-9]*|pipx|pipenv|npm|pnpm|yarn|bun|apt|apt-get|dnf|yum|zypper|pacman|apk|brew|port|cargo|gem|bundle|composer|poetry|uv|conda|mamba|mvn|gradle|make|cmake|go|helm|snap|flatpak|choco|winget|scoop)([[:space:]]+-[^[:space:]]+)*[[:space:]]+install([[:space:]]|$)/\1/g')

  # Collect write targets from redirections, tee, and sed -i.
  targets=$(
    {
      # redirections: >, >>, &>, 2>  (fd-dup >&N produces no file token)
      printf '%s\n' "$CMD_UQ" | grep -oE '[0-9]*&?>>?[[:space:]]*[^[:space:]<>|&;()]+' \
        | sed -E 's/^[0-9]*&?>>?[[:space:]]*//'
      # tee [-opts] file...
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]|&;(])tee([[:space:]]+-[a-zA-Z]+)*([[:space:]]+[^<>|&;()]+)' \
        | sed -E 's/^.*tee([[:space:]]+-[a-zA-Z]+)*[[:space:]]+//' | tr ' ' '\n'
      # sed -i / --in-place … <file>  (best-effort: last token of the invocation)
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]|&;(])sed[[:space:]]+[^|&;()]*(-i[a-zA-Z0-9.]*|--in-place[=a-zA-Z0-9.]*)[[:space:]][^|&;()]+' \
        | awk '{ print $NF }'
      # cp / mv / install [opts] SRC… DEST  (DEST = last token) — the common
      # copy verbs are just as capable of clobbering an existing .env / config.
      # Runs on the PM-install-neutralized copy (see CMD_UQ_CPMV above).
      printf '%s\n' "$CMD_UQ_CPMV" | grep -oE '(^|[[:space:]|&;(])(cp|mv|install)([[:space:]]+-[a-zA-Z0-9=]+)*([[:space:]]+[^<>|&;()[:space:]]+)+' \
        | awk '{ print $NF }'
      # dd of=FILE  (device targets are handled by the dangerous-commands core;
      # this catches `dd if=/dev/zero of=.env` clobbering a plain secrets file).
      printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]])of=[^[:space:]<>|&;()]+' \
        | sed -E 's/^[[:space:]]*of=//'
    } 2>/dev/null | sed '/^[[:space:]]*$/d'
  )
  if [ -n "$targets" ]; then
    printf '%s\n' "$targets"
  fi
  return 0
}
