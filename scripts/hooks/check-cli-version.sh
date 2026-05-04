#!/usr/bin/env bash
# =============================================================================
# check-cli-version.sh — SessionStart capability probe
# =============================================================================
# Invoked by Claude Code at SessionStart.
# Reads `claude --version`, parses semver, compares to the minimum required
# (2.1.121, the version that introduced hookSpecificOutput.updatedToolOutput
# for non-MCP tools).
#
# Writes "1" or "0" into the sentinel file consumed by downstream rewriter
# hooks. On unsupported version, also prints a one-line notice to stdout so
# the user knows the rewriter is inactive.
#
# Always exits 0 — never blocks a session.
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_hook-helpers.sh
source "$SCRIPT_DIR/_hook-helpers.sh"

MIN_MAJOR=2
MIN_MINOR=1
MIN_PATCH=121

write_sentinel() {
    local value="$1"
    echo "$value" > "$HOOK_REWRITER_SENTINEL" 2>/dev/null || true
}

# Probe `claude --version` (best-effort)
VERSION_OUTPUT=""
if command -v claude >/dev/null 2>&1; then
    VERSION_OUTPUT=$(claude --version 2>/dev/null || true)
fi

# Extract the first MAJOR.MINOR.PATCH triple, if any
SEMVER=$(printf '%s' "$VERSION_OUTPUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

if [ -z "$SEMVER" ]; then
    # Garbage or no claude binary — silent fallback
    write_sentinel "0"
    exit 0
fi

MAJOR=$(echo "$SEMVER" | cut -d. -f1)
MINOR=$(echo "$SEMVER" | cut -d. -f2)
PATCH=$(echo "$SEMVER" | cut -d. -f3)

is_supported() {
    if [ "$MAJOR" -gt "$MIN_MAJOR" ]; then return 0; fi
    if [ "$MAJOR" -lt "$MIN_MAJOR" ]; then return 1; fi
    if [ "$MINOR" -gt "$MIN_MINOR" ]; then return 0; fi
    if [ "$MINOR" -lt "$MIN_MINOR" ]; then return 1; fi
    if [ "$PATCH" -ge "$MIN_PATCH" ]; then return 0; fi
    return 1
}

if is_supported; then
    write_sentinel "1"
    exit 0
fi

# Unsupported — visible notice + sentinel = 0
write_sentinel "0"
echo "[INFO] Hook output rewriter requires Claude Code ${MIN_MAJOR}.${MIN_MINOR}.${MIN_PATCH}+ (current: ${SEMVER}) — feature disabled, sessions will work as before. Upgrade: npm install -g @anthropic-ai/claude-code@latest"
exit 0
