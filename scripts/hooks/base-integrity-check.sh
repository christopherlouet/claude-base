#!/usr/bin/env bash
# =============================================================================
# base-integrity-check.sh — PostToolUse hook
# =============================================================================
# Invoked by Claude Code after each Edit / Write / NotebookEdit.
# If the modified file is in .claude/skills|agents|commands|rules/
# or is .claude/settings.json, triggers validate-counts.sh in warning mode
# (non-blocking) to remind about updating counters / catalog / hook
# message.
#
# IMPORTANT: non-blocking. A warning appears in the session but the
# modification goes through. The goal is to remind, not to prevent.
#
# Disable: SKIP_BASE_INTEGRITY=1
# =============================================================================

set -u

# Quick bail-outs
[ "${SKIP_BASE_INTEGRITY:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
case "$TOOL_NAME" in
    Edit|Write|NotebookEdit|MultiEdit) ;;
    *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null) || exit 0
[ -z "$FILE_PATH" ] && exit 0

# Only files from the foundation matter to us
case "$FILE_PATH" in
    */.claude/skills/*|*/.claude/agents/*|*/.claude/commands/*|*/.claude/rules/*|*/.claude/settings.json)
        ;;
    *)
        exit 0
        ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
VALIDATE="$PROJECT_DIR/scripts/validate-counts.sh"
[ -x "$VALIDATE" ] || exit 0

# We only run validate-counts if the project is the foundation itself
# (avoids false positives in projects that consume the foundation without
# maintaining the counters).
[ -f "$PROJECT_DIR/scripts/audit-base.sh" ] || exit 0

# Silent execution, we only capture the return code
if ! OUTPUT=$("$VALIDATE" 2>&1); then
    # Warning visible in the session without blocking
    {
        echo "[BASE-INTEGRITY] Inconsistent counters after modification of:"
        echo "  $FILE_PATH"
        echo ""
        echo "Summary:"
        printf '%s\n' "$OUTPUT" | grep -E "(inconsistencies|expected|found)" | head -5
        echo ""
        echo "Run './scripts/validate-counts.sh' for the details and update the affected files before committing."
    } | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}' 2>/dev/null || true
fi

exit 0
