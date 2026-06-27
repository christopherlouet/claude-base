#!/usr/bin/env bash
# =============================================================================
# substance-check.sh — PostToolUse advisory hook (anti-hollow-test / anti-stub)
# =============================================================================
# After an Edit / Write / MultiEdit on a test or source file, runs the substance
# detector (scripts/substance-check.sh) on that ONE file and surfaces any hollow-
# test / stub finding as additionalContext, at the moment the work is claimed.
#
# ADVISORY ONLY: exit 0 ALWAYS (never 2) — a static signal must not block a
# legitimate edit. Findings are a nudge ("coverage % won't catch these"), not a
# gate. Disable: SKIP_SUBSTANCE_CHECK=1.
#
# The detector lives at scripts/substance-check.sh (a CLI, not under hooks/). When
# it is absent (e.g. a downstream project that has the hook but not yet the
# detector), the hook is a silent no-op. Input arrives on STDIN as JSON; the
# target is .tool_input.file_path. jq absent -> bail (no-op).
# =============================================================================

set -u

[ "${SKIP_SUBSTANCE_CHECK:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
case "$TOOL_NAME" in
    Edit|Write|MultiEdit) ;;
    *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -z "$FILE_PATH" ] && exit 0

# Cheap pre-filter on extension (the detector re-checks and fail-safes anyway).
case "$FILE_PATH" in
    *.bats|*.sh|*.bash|*.ts|*.tsx|*.js|*.jsx|*.mts|*.cts|*.py|*.go) ;;
    *) exit 0 ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
DETECTOR="$PROJECT_DIR/scripts/substance-check.sh"
[ -x "$DETECTOR" ] || exit 0

FINDINGS=$(bash "$DETECTOR" --quiet -- "$FILE_PATH" 2>/dev/null || true)
[ -z "$FINDINGS" ] && exit 0

{
    echo "[SUBSTANCE] Advisory: possible non-substantive work in the file just edited:"
    printf '%s\n' "$FINDINGS"
    echo ""
    echo "Each line is 'file:line: kind: hint' (a hollow test or an implementation"
    echo "stub). Coverage % and a green suite do not catch these. Add a real assertion"
    echo "/ implement the stub, or add an inline 'substance:ignore' if intentional."
    echo "Advisory only - the edit was applied. Disable: SKIP_SUBSTANCE_CHECK=1."
} | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}' 2>/dev/null || true

exit 0
