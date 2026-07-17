#!/usr/bin/env bash
# Command Validator - PreToolUse hook for runtime security enforcement
# Blocks dangerous commands that bypass static deny lists
# Disable with SKIP_COMMAND_VALIDATOR=1
#
# Claude Code SHELL of the core/shell split (specs/agnostic-core/): all
# decision logic lives in _policy-dangerous-commands.sh (harness-neutral,
# directly tested by tests/policy-dangerous-commands.bats). This shell only
# (1) reads the Claude Code stdin envelope, (2) calls validate_command, and
# (3) translates a deny into the Claude Code convention (stderr + exit 2).

set -euo pipefail

[ "${SKIP_COMMAND_VALIDATOR:-0}" = "1" ] && exit 0

# Read the PreToolUse payload from STDIN as JSON. The Claude Code CLI passes
# hook input on stdin (.tool_input.command), NOT via a TOOL_INPUT env var
# (see https://code.claude.com/docs/en/hooks). Reading the old env var made
# this guard a silent no-op. Fall back to the raw payload when jq is missing
# so an absent jq cannot silently bypass the security screen — note the
# fallback greps the whole JSON envelope, so anchored rules (e.g. ^sudo)
# degrade and a benign command merely *mentioning* a trigger phrase may block;
# that fails safe (extra blocks, never a silent bypass). jq is the documented
# default path and is exact.
INPUT=$(cat 2>/dev/null || true)
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
else
  CMD="$INPUT"
fi
[ -z "$CMD" ] && exit 0

# Source the policy core from next to this script. This guard is fail-CLOSED:
# a missing policy core must never become a silent bypass, so we block with a
# recovery hint instead of no-op'ing (mirrors the jq-fallback philosophy above;
# recoverable via `claude-base update` or SKIP_COMMAND_VALIDATOR=1).
_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
# shellcheck source=_policy-dangerous-commands.sh
if [ -n "$_dir" ] && [ -f "$_dir/_policy-dangerous-commands.sh" ]; then
  . "$_dir/_policy-dangerous-commands.sh"
else
  echo >&2 "BLOCKED: command-validator policy core missing (_policy-dangerous-commands.sh)."
  echo >&2 "Reinstall the foundation hooks (claude-base update), or set SKIP_COMMAND_VALIDATOR=1 to bypass."
  exit 2
fi

# Verdict translation: deny (return 1, reason on stdout) → stderr + exit 2.
if _reason=$(validate_command "$CMD"); then
  exit 0
else
  printf '%s\n' "$_reason" >&2
  exit 2
fi
