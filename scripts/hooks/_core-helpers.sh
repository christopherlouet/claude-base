#!/usr/bin/env bash
# =============================================================================
# _core-helpers.sh — Harness-neutral core helpers shared by the guard hooks
# =============================================================================
# CORE side of the core/shell split (specs/agnostic-core/): pure functions a
# guard shell for ANY harness can source. Hard rules for this file:
#   - functions only — no top-level commands, no stdin reads, no exits;
#   - no harness plumbing: no stdin-envelope field parsing, no hook JSON
#     output, no block exit codes, no harness-specific env vars;
#   - macOS bash 3.2 compatible (no assoc arrays, ASCII in executed strings).
#
# NOT a hook by itself. Do not register in settings.json.
#
# Consumers: command-validator.sh, bash-write-guard.sh, destructive-ops.sh,
# pre-push-ci.sh (directly or via _hook-helpers.sh, which sources this file so
# its existing consumers keep the same single canonical copy).
# =============================================================================

# Avoid double-sourcing
if [ -n "${CORE_HELPERS_LOADED:-}" ]; then return 0 2>/dev/null || true; fi
CORE_HELPERS_LOADED=1

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
#
# Value arms mirror the SHELL's own word rules (pass-4 F1/F2 false-blocks):
#   _q  — '…' plus the '…'\''…' apostrophe idiom. The continuation is anchored
#         on the literal `\''` the shell itself uses, so it can only extend
#         across quote-balanced text, never across an unquoted separator.
#   _dq — "…" with \-escapes ("she said \"x\"" is ONE shell word).
#   bare — unquoted token, stopping at whitespace/;&| where the shell would.
# A quoted value may also be SQUISHED onto a short-flag cluster (`-am"msg"`,
# no space/`=` — valid git); the bare arm stays space/`=`-separated only, so
# the flag cluster itself (`-nm`) is never eaten as its own "value".
# DO NOT add a `(seg)+` repetition or a lone `\\.` escape arm here: both let
# leftmost-longest stitch segments across a REAL separator (`-m 'a'; sudo …`
# with a later quote, or `x\\;cmd`) — the two bypass classes that killed
# earlier drafts in RED.
strip_msg_values() {
    local s="$1" out="" _m _keep
    local _q="'[^']*'(\\\\''[^']*')*"
    local _dq='"([^"\\]|\\.)*"'
    local _re="([[:space:]](-[A-Za-z]*m|--message|--file|--grep|-F))(([[:space:]]+|=)($_q|$_dq|[^[:space:];&|]+)|($_q|$_dq))"
    while [[ "$s" =~ $_re ]]; do
        _m="${BASH_REMATCH[0]}"
        _keep="${BASH_REMATCH[1]}"
        out+="${s%%"$_m"*}${_keep} "
        s=${s#*"$_m"}
    done
    printf '%s' "$out$s"
}
