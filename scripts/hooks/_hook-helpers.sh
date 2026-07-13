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

# strip_msg_values <command-string>
# Prints the string with git message / --grep / --file VALUES removed (the
# quoted string or bare token after -m/-am/--message/-F/--file/--grep, space or
# `=` separated). A trigger token appearing only as message PAYLOAD is data,
# never executed, so the Bash guards must not scan it. Single canonical copy —
# command-validator, bash-write-guard and destructive-ops all source this;
# divergent per-guard copies are how the pass-3 F1/F3 bugs shipped.
#
# Implemented with bash =~ instead of sed, for two audited reasons:
#   1. sed is line-based: a quoted value spanning NEWLINES leaked its tail into
#      the flag/verb scans (multiline `-m` false-blocks, and the inverse — a
#      real --no-verify after a multiline -m going UNSEEN). [^']* / [^"]* in
#      one =~ match crosses newlines, so the whole value goes at once.
#   2. POSIX alternation is leftmost-longest: a bare [^[:space:]]+ value arm
#      consumed `'done';` INCLUDING the separator, un-anchoring the next
#      command from every (^|[;&|])-anchored check (sudo-bypass). The bare arm
#      excludes ;&| — exactly where the shell itself would end the word.
# The FLAG token is kept and only its VALUE is dropped: Category 9 must still
# see a `-nm`/`-anm` cluster (the n IS --no-verify) after the strip. The scan
# is a single left-to-right pass — after each match we continue in the SUFFIX
# only. Re-scanning the whole string would rematch the now-value-less flag and
# swallow the NEXT token as its "value", one real flag per iteration.
strip_msg_values() {
    local s="$1" out="" _m _keep
    local _re="([[:space:]](-[A-Za-z]*m|--message|--file|--grep|-F))([[:space:]]+|=)('[^']*'|\"[^\"]*\"|[^[:space:];&|]+)"
    while [[ "$s" =~ $_re ]]; do
        _m="${BASH_REMATCH[0]}"
        _keep="${BASH_REMATCH[1]}"
        out+="${s%%"$_m"*}${_keep} "
        s=${s#*"$_m"}
    done
    printf '%s' "$out$s"
}
