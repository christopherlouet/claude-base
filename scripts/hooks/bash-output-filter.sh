#!/usr/bin/env bash
# =============================================================================
# bash-output-filter.sh — PostToolUse Bash hook
# =============================================================================
# Trims noisy outputs of allowlisted package-manager / build / test commands
# before Claude reads them. Keeps the actionable lines (errors, warnings,
# severity counts, totals, exit code), drops progress/spinner/banner noise.
#
# Allowlist-only: any command not on the list passes through untouched.
# Outputs below a configurable threshold (default 30 lines) also pass through.
#
# Disable: SKIP_BASH_OUTPUT_FILTER=1
# Verbose (keep both views): BASH_OUTPUT_FILTER_VERBOSE=1
# Custom threshold: BASH_OUTPUT_FILTER_THRESHOLD=<N>
# =============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_hook-helpers.sh
source "$SCRIPT_DIR/_hook-helpers.sh"

# Bail-out chain
hook_bail_if_unsupported
hook_bail_if_disabled SKIP_BASH_OUTPUT_FILTER
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$CMD" ] && exit 0

OUTPUT=$(printf '%s' "$INPUT" | jq -r '.tool_response.output // .tool_response.stdout // .tool_response.content // empty' 2>/dev/null)
EXIT_CODE=$(printf '%s' "$INPUT" | jq -r '.tool_response.exit_code // .tool_response.exitCode // 0' 2>/dev/null)

# -----------------------------------------------------------------------------
# Allowlist
# -----------------------------------------------------------------------------
is_allowlisted() {
    case "$1" in
        "npm install"*|"npm ci"*|"npm audit"*|"npm test"*|"npm run build"*) return 0 ;;
        "pnpm install"*|"pnpm audit"*|"pnpm test"*|"pnpm run build"*) return 0 ;;
        "yarn install"*|"yarn add"*|"yarn test"*|"yarn run build"*) return 0 ;;
        "bun install"*|"bun add"*|"bun test"*|"bun run build"*) return 0 ;;
        "pytest"*) return 0 ;;
        "go test"*|"go build"*) return 0 ;;
        "cargo build"*|"cargo test"*|"cargo check"*) return 0 ;;
    esac
    return 1
}

is_allowlisted "$CMD" || exit 0

# -----------------------------------------------------------------------------
# Threshold guard
# -----------------------------------------------------------------------------
THRESHOLD="${BASH_OUTPUT_FILTER_THRESHOLD:-30}"
LINE_COUNT=$(printf '%s\n' "$OUTPUT" | wc -l | tr -d ' ')
if [ "$LINE_COUNT" -lt "$THRESHOLD" ]; then
    exit 0
fi

# -----------------------------------------------------------------------------
# ANSI strip
# -----------------------------------------------------------------------------
CLEAN=$(printf '%s' "$OUTPUT" | hook_strip_ansi)

# -----------------------------------------------------------------------------
# Per-shape extraction
# -----------------------------------------------------------------------------
append_fail_context() {
    # Append last 20 lines as "Failure context" if exit_code != 0.
    local output="$1" exit_code="$2"
    if [ "$exit_code" != "0" ]; then
        echo ""
        echo "--- Failure context (last 20 lines) ---"
        printf '%s\n' "$output" | tail -20
    fi
}

extract_install() {
    {
        printf '%s\n' "$1" | grep -E '^(npm warn |npm err|added [0-9]+|removed [0-9]+|changed [0-9]+|added [0-9]+ packages|removed [0-9]+ packages|.*audited [0-9]+|.*found [0-9]+ vulnerab|error |warning )' | head -10
        append_fail_context "$1" "$2"
    }
}

extract_audit() {
    {
        printf '%s\n' "$1" | head -1 | grep -E '#|npm audit report' || true
        printf '%s\n' "$1" | grep -E '^Severity:' | head -10
        printf '%s\n' "$1" | grep -E '[0-9]+ vulnerabilit' | head -3
    }
}

extract_test_or_build() {
    {
        printf '%s\n' "$1" | grep -E '^(FAIL |ERROR |error |TypeError|SyntaxError|✗|×|  ●)' | head -20
        printf '%s\n' "$1" | grep -E '(Test Suites:|Tests:|Snapshots:|Time:|[0-9]+ passing|[0-9]+ failing|[0-9]+ pending)' | head -10
        append_fail_context "$1" "$2"
    }
}

extract_pytest() {
    {
        printf '%s\n' "$1" | grep -E '(=== FAILURES ===|FAILED |ERROR |AssertionError|^E   |^>   |==================)' | head -25
        printf '%s\n' "$1" | grep -E '^[0-9]+ (passed|failed|error|warning|skipped)' | head -3
    }
}

extract_go() {
    {
        printf '%s\n' "$1" | grep -E '(--- FAIL|^FAIL|^ok |^PASS|^panic:|\.go:[0-9]+)' | head -25
        append_fail_context "$1" "$2"
    }
}

extract_cargo() {
    {
        printf '%s\n' "$1" | grep -E '(error\[E[0-9]+\]:|^warning:|^error:|^  --> |^test result:|running [0-9]+ tests)' | head -25
    }
}

dispatch_extract() {
    local cmd="$1" output="$2" exit_code="$3"
    case "$cmd" in
        "npm install"*|"npm ci"*|"pnpm install"*|"yarn install"*|"yarn add"*|"bun install"*|"bun add"*)
            extract_install "$output" "$exit_code" ;;
        "npm audit"*|"pnpm audit"*)
            extract_audit "$output" "$exit_code" ;;
        "npm test"*|"npm run build"*|"pnpm test"*|"pnpm run build"*|"yarn test"*|"yarn run build"*|"bun test"*|"bun run build"*)
            extract_test_or_build "$output" "$exit_code" ;;
        "pytest"*)
            extract_pytest "$output" "$exit_code" ;;
        "go test"*|"go build"*)
            extract_go "$output" "$exit_code" ;;
        "cargo build"*|"cargo test"*|"cargo check"*)
            extract_cargo "$output" "$exit_code" ;;
        *)
            printf '%s\n' "$output" ;;
    esac
}

TRIMMED=$(dispatch_extract "$CMD" "$CLEAN" "$EXIT_CODE")
TRIMMED="${TRIMMED}
(exit code: $EXIT_CODE)"

# -----------------------------------------------------------------------------
# Verbose mode: keep both views
# -----------------------------------------------------------------------------
if [ "${BASH_OUTPUT_FILTER_VERBOSE:-0}" = "1" ]; then
    TRIMMED=$(printf '%s\n\n--- Original output ---\n%s' "$TRIMMED" "$CLEAN")
fi

# -----------------------------------------------------------------------------
# Emit envelope
# -----------------------------------------------------------------------------
hook_emit_envelope "PostToolUse" "updatedToolOutput" "$TRIMMED"

# -----------------------------------------------------------------------------
# Metric log (best effort)
# -----------------------------------------------------------------------------
ORIG_LINES=$(printf '%s\n' "$CLEAN" | wc -l | tr -d ' ')
NEW_LINES=$(printf '%s\n' "$TRIMMED" | wc -l | tr -d ' ')
SHORT_CMD=$(printf '%s' "$CMD" | head -c 50)
{
    printf '%s tool=Bash cmd=%s orig=%s filtered=%s\n' \
        "$(date -u +%FT%TZ)" "$SHORT_CMD" "$ORIG_LINES" "$NEW_LINES" \
        >> "$HOOK_REWRITER_METRIC_LOG"
} 2>/dev/null || true

exit 0
