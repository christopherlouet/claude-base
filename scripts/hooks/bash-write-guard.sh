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
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): target
# EXTRACTION lives in _policy-write-targets.sh, target CLASSIFICATION in
# _sensitive-paths.sh (both harness-neutral, directly tested); this shell owns
# the stdin envelope, the ENVIRONMENT checks (existence, branch, git-tracked)
# and the exit-2 translation.
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

# Source the shared sensitive-path classifier and the target-extraction core
# from next to this script. Fail-open lineage preserved: this guard has always
# no-op'd when its classifier lib is missing (shipping is guarded by the
# install manifest + the fresh-install self-application test).
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=scripts/hooks/_sensitive-paths.sh
[ -n "$_dir" ] && [ -f "$_dir/_sensitive-paths.sh" ] && . "$_dir/_sensitive-paths.sh" || exit 0
# shellcheck source=scripts/hooks/_policy-write-targets.sh
[ -f "$_dir/_policy-write-targets.sh" ] && . "$_dir/_policy-write-targets.sh" || exit 0

command -v jq >/dev/null 2>&1 || exit 0
CMD=$(cat 2>/dev/null | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

targets=$(extract_write_targets "$CMD")
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
