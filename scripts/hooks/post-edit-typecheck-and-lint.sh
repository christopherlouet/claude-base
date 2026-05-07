#!/usr/bin/env bash
# =============================================================================
# post-edit-typecheck-and-lint.sh — PostToolUse Edit|Write hook
# =============================================================================
# Replaces the foundation's two former inline tsc + eslint hooks with a single
# script that ANNOTATES the Edit/Write tool result envelope (hookSpecificOutput
# .updatedToolOutput, CLI 2.1.121+) instead of emitting tsc/eslint output as
# separate side messages.
#
# Status semantics: the rewriter never downgrades the tool result to FAILURE;
# the edit happened on disk, errors are co-located annotations Claude can act on
# in the next turn (per spec FR-6 / clarification Q2).
#
# Routing:
#   - .ts / .tsx  -> tsc + eslint
#   - .js / .jsx  -> eslint only
#   - other       -> bail-out (FR-9 deferred follow-up for py/go/rust/dart)
#
# Disable: SKIP_INLINE_EDIT_ERRORS=1
# Legacy detection: if .claude/settings.json still references the old inline
# tsc/eslint blocks (signal of a partial update), emit one notice per session
# (sentinel: $HOOK_LEGACY_NOTICE_SENTINEL.<PPID>, default base
# /tmp/claude-base-legacy-warned).
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_hook-helpers.sh
source "$SCRIPT_DIR/_hook-helpers.sh"

# Bail-out chain
hook_bail_if_unsupported
hook_bail_if_disabled SKIP_INLINE_EDIT_ERRORS
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -z "$FILE_PATH" ] && exit 0

# Routing by extension
EXT="${FILE_PATH##*.}"
case "$EXT" in
    ts|tsx) RUN_TSC=1; RUN_ESLINT=1 ;;
    js|jsx|mjs|cjs) RUN_TSC=0; RUN_ESLINT=1 ;;
    *) exit 0 ;;
esac

# -----------------------------------------------------------------------------
# Legacy state detection (FR-22)
# -----------------------------------------------------------------------------
LEGACY_SENTINEL="${HOOK_LEGACY_NOTICE_SENTINEL}.${PPID}"
if [ ! -f "$LEGACY_SENTINEL" ] && [ -f ".claude/settings.json" ]; then
    if grep -q 'npx tsc --noEmit' .claude/settings.json 2>/dev/null; then
        echo "[INFO] claude-base: settings.json appears to predate the output rewriter — re-run ./scripts/update.sh -f --all to enable. Continuing with legacy behavior." >&2
        : > "$LEGACY_SENTINEL"
    fi
fi

# -----------------------------------------------------------------------------
# Run tsc + eslint and grep for the just-edited file
# -----------------------------------------------------------------------------
TSC_OUTPUT=""
ESLINT_OUTPUT=""

# tsc and eslint may output paths in either absolute or cwd-relative form.
# We grep for both so the file-match works regardless of how the tool resolves paths.
REL_PATH="${FILE_PATH#"$PWD"/}"

if [ "$RUN_TSC" = "1" ] && [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
    RAW_TSC=$(node_modules/.bin/tsc --noEmit 2>&1 || true)
    TSC_OUTPUT=$(printf '%s\n' "$RAW_TSC" | grep -F -e "$FILE_PATH" -e "$REL_PATH" | head -20 || true)
fi

if [ "$RUN_ESLINT" = "1" ] && [ -x node_modules/.bin/eslint ]; then
    RAW_ESLINT=$(node_modules/.bin/eslint "$FILE_PATH" --max-warnings 0 2>&1 || true)
    ESLINT_OUTPUT=$(printf '%s\n' "$RAW_ESLINT" | grep -B1 -A2 -e "$FILE_PATH" -e "$REL_PATH" 2>/dev/null | head -20 || true)
    if [ -z "$ESLINT_OUTPUT" ]; then
        ESLINT_OUTPUT=$(printf '%s\n' "$RAW_ESLINT" | grep -E '(error|warning|problem|^[[:space:]]+[0-9]+:[0-9]+)' | head -20 || true)
    fi
fi

# -----------------------------------------------------------------------------
# If neither found anything, pass through (no envelope)
# -----------------------------------------------------------------------------
if [ -z "$TSC_OUTPUT" ] && [ -z "$ESLINT_OUTPUT" ]; then
    exit 0
fi

# -----------------------------------------------------------------------------
# Build annotated tool_response
# -----------------------------------------------------------------------------
ORIG_RESPONSE=$(printf '%s' "$INPUT" | jq -r '.tool_response // "" | if type == "string" then . else tojson end' 2>/dev/null)

ANNOTATED="$ORIG_RESPONSE"

if [ -n "$TSC_OUTPUT" ]; then
    ANNOTATED="$ANNOTATED

--- Type errors (tsc) ---
$TSC_OUTPUT"
fi

if [ -n "$ESLINT_OUTPUT" ]; then
    ANNOTATED="$ANNOTATED

--- Lint errors (eslint) ---
$ESLINT_OUTPUT"
fi

# -----------------------------------------------------------------------------
# Emit envelope (status stays SUCCESS — co-located annotations only)
# -----------------------------------------------------------------------------
hook_emit_envelope "PostToolUse" "updatedToolOutput" "$ANNOTATED"

exit 0
