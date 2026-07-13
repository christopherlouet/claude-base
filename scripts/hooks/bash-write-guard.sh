#!/usr/bin/env bash
# =============================================================================
# bash-write-guard.sh — PreToolUse hook (Bash).
#
# The Bash-side complement to the edit-path file-mutation guards. secret-scan,
# config-protection and main-branch-guard only fire on Edit|Write|MultiEdit, so
# a write routed through the Bash tool (`printf > f`, `tee f`, `sed -i`/
# `--in-place`, `cp`/`mv`/`install` onto the file, `dd of=f`) escaped all of
# them. This guard inspects the WRITE TARGETS of a Bash command
# and blocks (exit 2) only for the high-value, low-false-positive cases:
#
#   1. an EXISTING linter/formatter config  → weakening a gate via a redirect
#      (parity with config-protection.sh; creating a new config is allowed).
#   2. an EXISTING secrets/credentials file → clobbering .env/*.pem/… via Bash.
#   3. a TRACKED repo file while on main/master → parity with main-branch-guard
#      (blocks; create a feature branch. New/untracked files stay allowed).
#
# Deliberately narrow (Option A): only these sensitive TARGETS block; ordinary
# Bash writes (temp files, build output, new files, /dev/*) pass untouched. It
# does NOT scan redirected CONTENT for secrets — that stays secret-scan's job on
# the edit path. Known limit: targets are extracted from a quote-stripped copy,
# so echoing a string that merely LOOKS like `> <sensitive>` may over-block
# (recoverable via SKIP_BASH_WRITE_GUARD=1).
#
# Payload on STDIN as JSON (.tool_input.command). Disable with
# SKIP_BASH_WRITE_GUARD=1 (all cases) or ALLOW_MAIN_EDIT=1 (case 3 only).
# =============================================================================
set -u

[ "${SKIP_BASH_WRITE_GUARD:-0}" = "1" ] && exit 0

# Source the shared sensitive-path classifier from next to this script.
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=scripts/hooks/_sensitive-paths.sh
[ -n "$_dir" ] && [ -f "$_dir/_sensitive-paths.sh" ] && . "$_dir/_sensitive-paths.sh" || exit 0

command -v jq >/dev/null 2>&1 || exit 0
CMD=$(cat 2>/dev/null | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

# Strip message/--file/--grep VALUES before extraction (shared helper): a
# commit message NAMING a file operation (`git commit -m "chore: cp
# .env.example .env"`) is data, not a write. Missing helper → no strip →
# possible over-block, never a bypass.
# shellcheck source=scripts/hooks/_hook-helpers.sh
[ -f "$_dir/_hook-helpers.sh" ] && . "$_dir/_hook-helpers.sh"
declare -F strip_msg_values >/dev/null 2>&1 || strip_msg_values() { printf '%s' "$1"; }

# Quote-stripped, newline-flattened copy for token extraction.
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
    # dd of=FILE  (device targets are handled by command-validator; this catches
    # `dd if=/dev/zero of=.env` clobbering a plain secrets file).
    printf '%s\n' "$CMD_UQ" | grep -oE '(^|[[:space:]])of=[^[:space:]<>|&;()]+' \
      | sed -E 's/^[[:space:]]*of=//'
  } 2>/dev/null | sed '/^[[:space:]]*$/d'
)
[ -z "$targets" ] && exit 0

# Resolve a (possibly relative) path for existence checks.
_exists() { [ -e "$1" ] || { [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -e "$CLAUDE_PROJECT_DIR/$1" ]; }; }

BRANCH=""
command -v git >/dev/null 2>&1 && BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)

while IFS= read -r t; do
  [ -n "$t" ] || continue
  case "$t" in /dev/*|/proc/*|/sys/*) continue ;; esac
  b=$(basename "$t")

  if is_protected_config "$b" && _exists "$t"; then
    echo >&2 "BLOCKED: Bash write to the linter/formatter config '$b' — fix the code instead of relaxing the rules via a shell redirect. (Bypass: SKIP_BASH_WRITE_GUARD=1.)"
    exit 2
  fi
  if is_secret_file "$b" && _exists "$t"; then
    echo >&2 "BLOCKED: Bash write to the secrets file '$b' — manage secrets via env/secret store, not a committed file. (Bypass: SKIP_BASH_WRITE_GUARD=1.)"
    exit 2
  fi
  if [ "${ALLOW_MAIN_EDIT:-0}" != "1" ] && { [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; }; then
    if git ls-files --error-unmatch "$t" >/dev/null 2>&1; then
      echo >&2 "BLOCKED: on $BRANCH — a Bash write to the tracked file '$t' should land on a feature branch (git checkout -b feature/…), or set ALLOW_MAIN_EDIT=1."
      exit 2
    fi
  fi
done <<< "$targets"

exit 0
