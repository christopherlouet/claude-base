#!/usr/bin/env bash
# =============================================================================
# _hook-helpers.sh — Sourceable helpers for the output rewriter hooks
# =============================================================================
# Sourced by: bash-output-filter.sh, post-edit-typecheck-and-lint.sh,
#             check-cli-version.sh
#
# NOT a hook by itself. Do not register in settings.json.
#
# Cross-hook signal: a sentinel file at $HOOK_REWRITER_SENTINEL holds "1" if
# the running CLI supports `hookSpecificOutput.updatedToolOutput` for non-MCP
# tools (Claude Code 2.1.121+), "0" otherwise. SessionStart writes it,
# downstream PostToolUse hooks read it.
#
# Why a file and not an env var: env vars set in a hook process do not
# propagate to other hook invocations (each hook is its own subshell). A
# sentinel file is fast (~1ms read) and OS-portable. Limitation: concurrent
# Claude sessions on the same host share the sentinel; acceptable for v1.
#
# Path overrides (used by tests for per-process isolation under
# $BATS_TEST_TMPDIR — production defaults are the documented /tmp paths):
#   HOOK_REWRITER_SENTINEL       — capability sentinel (default /tmp/claude-rewriter-supported)
#   HOOK_REWRITER_METRIC_LOG     — bash-output-filter metric log (default
#                                  ${XDG_STATE_HOME:-~/.local/state}/claude-base/rewriter.log: it holds
#                                  the first 50 bytes of each command, so not world-readable /tmp)
#   HOOK_LEGACY_NOTICE_SENTINEL  — legacy notice sentinel base, suffixed with .PPID by post-edit
#                                  (default /tmp/claude-base-legacy-warned)
# =============================================================================

# Avoid double-sourcing
[ -n "${HOOK_HELPERS_LOADED:-}" ] && return 0
HOOK_HELPERS_LOADED=1

HOOK_REWRITER_SENTINEL="${HOOK_REWRITER_SENTINEL:-/tmp/claude-rewriter-supported}"
# ${HOME:-/nonexistent}: an unset HOME under `set -u` must not abort the hook;
# the write then simply fails, and it is best effort.
HOOK_REWRITER_METRIC_LOG="${HOOK_REWRITER_METRIC_LOG:-${XDG_STATE_HOME:-${HOME:-/nonexistent}/.local/state}/claude-base/rewriter.log}"
HOOK_LEGACY_NOTICE_SENTINEL="${HOOK_LEGACY_NOTICE_SENTINEL:-/tmp/claude-base-legacy-warned}"

# hook_bail_if_disabled <ENV_VAR_NAME>
# Exits the calling script with code 0 if the named env var equals "1".
hook_bail_if_disabled() {
    local var="$1"
    if [ "${!var:-0}" = "1" ]; then
        exit 0
    fi
}

# hook_bail_if_unsupported
# Exits 0 if the rewriter sentinel is missing or its content is not "1".
hook_bail_if_unsupported() {
    [ -f "$HOOK_REWRITER_SENTINEL" ] || exit 0
    [ "$(cat "$HOOK_REWRITER_SENTINEL" 2>/dev/null)" = "1" ] || exit 0
}

# hook_strip_ansi
# Reads stdin, writes stdout with ANSI escape sequences removed.
hook_strip_ansi() {
    sed -E $'s/\x1b\\[[0-9;]*[a-zA-Z]//g'
}

# hook_emit_envelope <event_name> <key> <value>
# Writes a hookSpecificOutput JSON envelope to stdout:
#   {"hookSpecificOutput":{"hookEventName":<event>,<key>:<value>}}
# <value> is treated as a string (jq -Rs): for string-valued fields such as
# additionalContext. It REFUSES updatedToolOutput: that value must match the
# tool's own result shape, and Claude Code drops a mismatch silently — the
# string this helper used to emit there was ignored for every tool (#685).
# Use hook_emit_updated_output instead.
hook_emit_envelope() {
    local event="$1" key="$2" value="$3"
    if [ "$key" = "updatedToolOutput" ]; then
        echo "hook_emit_envelope: updatedToolOutput needs the tool's shape; use hook_emit_updated_output" >&2
        return 1
    fi
    printf '%s' "$value" | jq -Rs --arg event "$event" --arg key "$key" \
        '{hookSpecificOutput: ({hookEventName: $event} + {($key): .})}'
}

# hook_emit_updated_output <hook-input-json> <text>
# Replaces a PostToolUse tool result with <text>, in the result's OWN shape —
# the only form Claude Code applies (a mismatch is dropped without an error):
#   - an object with a `stdout` field (Bash: stdout, stderr, interrupted,
#     isImage, noOutputExpected) -> the same object, stdout replaced, every
#     other field kept as received;
#   - a string -> the string.
# Any other shape (Edit's structured result has no text field) is never
# guessed: nothing is printed and it returns 1, so the caller can tell that
# no replacement happened. To add to such a result, use additionalContext.
#
# A third argument `clear-stderr` also empties a `stderr` field: for a caller
# whose <text> already digests stdout AND stderr together.
# Both values reach jq on stdin — the hook input, then <text> encoded as one
# JSON string — never argv (one argument is capped at 128 KB on Linux; past
# it nothing was emitted), never a temp file (a hook cut by its timeout would
# leave the command's output behind), and without --rawfile (jq >= 1.6).
hook_emit_updated_output() {
    local input="$1" text="$2" clear="${3:-}"
    {
        printf '%s' "$input"
        printf '\n'
        printf '%s' "$text" | jq -Rs .
    } | jq -cse --arg clear "$clear" '
        .[0].tool_response as $r
        | .[1] as $text
        | if ($r | type) == "string" then $text
          elif ($r | type) == "object" and ($r | has("stdout")) then
            $r + {stdout: $text}
              + (if $clear == "clear-stderr" and ($r | has("stderr")) then {stderr: ""} else {} end)
          else empty end
        | {hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: .}}' 2>/dev/null
}

# strip_msg_values now lives in _core-helpers.sh — the harness-neutral CORE
# side of the core/shell split (specs/agnostic-core/). Sourced here so every
# existing consumer of _hook-helpers.sh keeps the same single canonical copy
# (divergent per-guard copies are how the pass-3 F1/F3 bugs shipped). Missing
# core file → strip stays undefined and each guard's own `declare -F` fallback
# takes over (no strip: possible over-block, never a silent bypass).
_hh_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)
# shellcheck source=_core-helpers.sh
if [ -n "$_hh_dir" ] && [ -f "$_hh_dir/_core-helpers.sh" ]; then . "$_hh_dir/_core-helpers.sh"; fi
