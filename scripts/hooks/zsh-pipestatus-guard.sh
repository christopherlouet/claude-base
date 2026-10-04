#!/usr/bin/env bash
# =============================================================================
# zsh-pipestatus-guard.sh — PreToolUse hook (Bash).
#
# Blocks (exit 2) a Bash command that reads `PIPESTATUS` when the Bash tool
# runs it under zsh. zsh has no PIPESTATUS: `${PIPESTATUS[0]}` expands to an
# EMPTY string with no error, so a pipe check written for bash reads "" and a
# failed stage passes for a success.
#
# Provenance — measured 2026-10-05, zsh 5.9:
#   false | true; echo "[${PIPESTATUS[*]}][${pipestatus[*]}]"   ->   [][1 0]
# Replayed on 41 past agent commands naming PIPESTATUS: 15 would block, every
# one a real outer-zsh read of "" (no false block found).
# Expiry — obsolete if the Bash tool stops running commands through the
# user's zsh, or if zsh starts erroring on / aliasing PIPESTATUS. Re-verify
# then by ablation (disable this hook, replay the case above); until that is
# proven, keep it (EF-015/EF-016, specs/guardrail-cleanup/native-coverage.md).
#
# Which shell runs the command — measured on CLI 2.1.288 (binary strings): the
# Bash tool uses CLAUDE_CODE_SHELL when it names bash/zsh and is executable,
# else SHELL when it names bash/zsh, else its own detection. This hook runs as
# a child of the same CLI process and inherits that environment (measured:
# SHELL=/usr/bin/zsh in the CLI's environ). When neither variable names zsh
# the hook stays silent — the detection fallback is not reproduced.
#
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): detection
# lives in _policy-zsh-pipestatus.sh (harness-neutral, directly tested); this
# shell owns the stdin envelope, the shell choice and the exit-2 translation.
#
# A correctness guard, not a security one: a missing core fails OPEN with a
# warning (an unshipped lib must not block every Bash command).
#
# Payload on STDIN as JSON (.tool_input.command). Disable with
# SKIP_ZSH_PIPESTATUS_GUARD=1 in the environment Claude Code runs in.
# =============================================================================
set -u

[ "${SKIP_ZSH_PIPESTATUS_GUARD:-0}" = "1" ] && exit 0

_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=scripts/hooks/_policy-zsh-pipestatus.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-zsh-pipestatus.sh" ]; then
  . "$_dir/_policy-zsh-pipestatus.sh"
else
  echo >&2 "[zsh-pipestatus-guard] policy core _policy-zsh-pipestatus.sh missing - guard DISABLED. Run 'claude-base update' to restore."
  exit 0
fi

# The CLI's own precedence: CLAUDE_CODE_SHELL only counts when it names bash/zsh.
_shell="${SHELL:-}"
case "${CLAUDE_CODE_SHELL:-}" in *bash*|*zsh*) _shell="$CLAUDE_CODE_SHELL" ;; esac
shell_is_zsh "$_shell" || exit 0

command -v jq >/dev/null 2>&1 || exit 0
CMD=$(cat 2>/dev/null | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

has_pipestatus_expansion "$CMD" || exit 0

cat >&2 <<'MSG'
BLOCKED: this command reads PIPESTATUS, but the Bash tool runs it under zsh,
where PIPESTATUS does not exist and expands to an EMPTY string with no error -
a failed pipe stage would read as success.
Use one of:
  - zsh's own array, 1-indexed:  ${pipestatus[1]}
  - run the snippet in bash:     bash -c '... ; echo "${PIPESTATUS[0]}"'
  - or fail the pipe instead:    set -o pipefail
(Bypass: SKIP_ZSH_PIPESTATUS_GUARD=1 in the environment Claude Code runs in.)
MSG
exit 2
