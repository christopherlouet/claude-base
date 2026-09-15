#!/usr/bin/env bash
# =============================================================================
# log-event.sh — lifecycle logging hook (Notification, SubagentStop, SessionEnd,
# PreCompact, PermissionDenied, ...). Appends one line per event.
#
#   log-event.sh <log-name> <TAG> [payload-field ...]
#
# Writes "<UTC timestamp> <TAG> [field=value ...]" to
# ${CLAUDE_BASE_LOG_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/claude-base}/<log-name>.log,
# directory 700 and file 600.
#
# Replaces fourteen inline `echo ... >> /tmp/claude-*.log` hooks: /tmp is
# readable by every account on the machine, and two of them copied the first
# 200 bytes of their payload — the refused command for PermissionDenied, the
# session id and transcript path for a permission notification. So this writer
# records only the fields it is NAMED, only when they are scalars, and squeezes
# each value to one token: a payload can never put free text in the log.
#
# Best effort by design: any failure (no jq, unwritable directory, bad name) is
# silent and exits 0 — a log line is never worth breaking a session.
# Payload on STDIN as JSON. macOS bash 3.2 compatible.
# =============================================================================

set -u

LOG_NAME="${1:-}"
TAG="${2:-}"
[ "$#" -ge 2 ] && shift 2

case "$LOG_NAME" in
    ''|*[!a-z0-9-]*) exit 0 ;;
esac
case "$TAG" in
    ''|*[!A-Z0-9-]*) exit 0 ;;
esac

INPUT=$(cat 2>/dev/null || true)

LINE="$(date -u +%Y-%m-%dT%H:%M:%SZ) $TAG"
if [ "$#" -gt 0 ] && command -v jq >/dev/null 2>&1; then
    for field in "$@"; do
        case "$field" in
            ''|*[!a-z_]*) continue ;;
        esac
        value=$(printf '%s' "$INPUT" \
            | jq -r --arg f "$field" '.[$f] | select(type == "string" or type == "number" or type == "boolean")' 2>/dev/null \
            | head -n 1 | tr -d '\n' | tr -c 'A-Za-z0-9_.:-' '_' | cut -c1-64)
        [ -n "$value" ] && LINE="$LINE $field=$value"
    done
fi

DIR="${CLAUDE_BASE_LOG_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/claude-base}"
(
    umask 077
    mkdir -p "$DIR" && printf '%s\n' "$LINE" >> "$DIR/$LOG_NAME.log"
) 2>/dev/null || true
exit 0
