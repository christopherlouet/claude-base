#!/usr/bin/env bash
# =============================================================================
# preflight.sh — run the foundation's OWN CI gates locally, BEFORE a push, so the
# dev loop catches what CI catches instead of finding out post-push. Wired into
# .husky/pre-push (git-native, runs for human AND agent pushes; reuses the
# core.hooksPath=.husky from the counts self-heal).
#
# The existing "Local pre-push CI" Claude hook only runs npm lint/test for
# DOWNSTREAM user projects; for claude-base itself (a bash/bats foundation) it is
# a no-op — which is why counts/manifest drift kept being discovered in CI. This
# closes that local↔CI gap.
#
# Gates mirror .github/workflows/ci.yml "Lint & Test":
#   fast (default): shellcheck · validate-counts.sh · manifest-hooks-coverage
#   --full:         + scripts/test.sh (the complete bats suite)
#
# Each gate command is overridable via env (PREFLIGHT_GATE_*) for testing.
# Disable everything with SKIP_PREFLIGHT=1.
#
# Usage: preflight.sh [--fast|--full] [--quiet]
# Exit: 0 all gates pass · 1 a gate failed · 2 usage error.
# =============================================================================

# NOTE: deliberately NOT `set -u`. On macOS's bash 3.2 an empty/edge expansion can
# trip `set -u` in ways that differ from bash 5 (the CI macOS column caught this);
# the script controls all its own variables, so `set -o pipefail` alone is safer
# and portable. Keep it this way unless every var is provably bound on bash 3.2.
set -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

MODE=fast
QUIET=0
while [ $# -gt 0 ]; do
    case "$1" in
        --fast) MODE=fast; shift ;;
        --full) MODE=full; shift ;;
        --quiet) QUIET=1; shift ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -nE '/^preflight/,/^Exit/p'; exit 0 ;;
        *) echo "preflight: unknown option: $1" >&2; exit 2 ;;
    esac
done

[ "${SKIP_PREFLIGHT:-0}" = "1" ] && exit 0

# Gate commands. Each external tool is GUARDED: a missing tool SKIPS the gate (so
# a dev machine, or the macOS CI runner which ships no shellcheck, is never blocked
# on a tool it lacks; CI's Linux job is the authoritative run). Built with plain
# if/elif (NOT a complex `${VAR:-...}` default — that mis-parses on macOS bash 3.2).
# All overridable via env for tests.
if [ -n "${PREFLIGHT_GATE_SHELLCHECK:-}" ]; then GATE_SHELLCHECK="$PREFLIGHT_GATE_SHELLCHECK"
elif command -v shellcheck >/dev/null 2>&1; then GATE_SHELLCHECK='shellcheck -S warning scripts/*.sh scripts/hooks/*.sh scripts/lib/*.sh'
else GATE_SHELLCHECK='echo "shellcheck absent - gate skipped"'; fi

GATE_COUNTS="${PREFLIGHT_GATE_COUNTS:-bash scripts/validate-counts.sh}"

if [ -n "${PREFLIGHT_GATE_MANIFEST:-}" ]; then GATE_MANIFEST="$PREFLIGHT_GATE_MANIFEST"
elif command -v bats >/dev/null 2>&1; then GATE_MANIFEST='bats tests/manifest-hooks-coverage.bats'
else GATE_MANIFEST='echo "bats absent - gate skipped"'; fi

if [ -n "${PREFLIGHT_GATE_FULL:-}" ]; then GATE_FULL="$PREFLIGHT_GATE_FULL"
elif command -v bats >/dev/null 2>&1; then GATE_FULL='bash scripts/test.sh'
else GATE_FULL='echo "bats absent - gate skipped"'; fi

say() { [ "$QUIET" = 1 ] || echo "$@"; }

# Array-free failure tracking — portable to bash 3.2 (macOS) under `set -u`, where
# expanding an empty array errors. Counter + space-separated names instead.
fail_count=0
fail_names=""
run_gate() {
    local name="$1" cmd="$2" out
    say "[preflight] $name..."
    if out=$(bash -c "$cmd" 2>&1); then
        return 0
    fi
    fail_count=$((fail_count + 1))
    fail_names="$fail_names $name"
    echo "[preflight] FAILED: $name" >&2
    [ "$QUIET" = 1 ] || printf '%s\n' "$out" | tail -15 >&2
    return 0
}

run_gate "shellcheck" "$GATE_SHELLCHECK"
run_gate "counts"     "$GATE_COUNTS"
run_gate "manifest"   "$GATE_MANIFEST"
[ "$MODE" = full ] && run_gate "bats (full)" "$GATE_FULL"

if [ "$fail_count" -gt 0 ]; then
    echo "[preflight] x $fail_count gate(s) failed:$fail_names" >&2
    echo "[preflight] fix locally, or bypass once with SKIP_PREFLIGHT=1" >&2
    exit 1
fi
say "[preflight] OK all $MODE gates passed"
exit 0
