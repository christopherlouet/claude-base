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
#   HOOK_REWRITER_METRIC_LOG     — bash-output-filter metric log (default /tmp/claude-rewriter.log)
#   HOOK_LEGACY_NOTICE_SENTINEL  — legacy notice sentinel base, suffixed with .PPID by post-edit
#                                  (default /tmp/claude-base-legacy-warned)
# =============================================================================

# Avoid double-sourcing
[ -n "${HOOK_HELPERS_LOADED:-}" ] && return 0
HOOK_HELPERS_LOADED=1

HOOK_REWRITER_SENTINEL="${HOOK_REWRITER_SENTINEL:-/tmp/claude-rewriter-supported}"
HOOK_REWRITER_METRIC_LOG="${HOOK_REWRITER_METRIC_LOG:-/tmp/claude-rewriter.log}"
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
# <value> is treated as a string (jq -Rs).
hook_emit_envelope() {
    local event="$1" key="$2" value="$3"
    printf '%s' "$value" | jq -Rs --arg event "$event" --arg key "$key" \
        '{hookSpecificOutput: ({hookEventName: $event} + {($key): .})}'
}
