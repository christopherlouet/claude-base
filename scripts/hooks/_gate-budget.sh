#!/usr/bin/env bash
# =============================================================================
# _gate-budget.sh — one time budget per blocking gate (sourced, not a hook)
# =============================================================================
# A PreToolUse hook that outlives its settings.json `timeout` does NOT block:
# measured 2026-09-25, the command runs anyway. The three gates that run whole
# suites (pre-commit-tests, pre-push-ci, pre-deploy-build) get 1800 s there; a
# suite still running at that point would let the commit, push or deploy
# through, silently. So each gate spends ONE budget across all its steps and
# BLOCKS when it runs out: the gate decides before the harness cancels it.
#
#   gate_budget_init            read CLAUDE_BASE_GATE_SECONDS (default 1500,
#                               below the 1800 s hook timeout; a test pins that)
#   gate_run <cmd…>             run within what is left; 124 = budget spent
#   gate_block_if_timed_out <rc> <gate>
#                               on 124: print why and exit 2
#
# Without timeout(1) or gtimeout (stock macOS) commands run unbounded, as
# before; the hook timeout is then the only bound. NOT a hook: do not register
# in settings.json. bash 3.2 compatible; no top-level side effects.
# =============================================================================

gate_budget_init() {
    GATE_SECONDS="${CLAUDE_BASE_GATE_SECONDS:-1500}"
    case "$GATE_SECONDS" in ''|*[!0-9]*) GATE_SECONDS=1500 ;; esac
    GATE_SECONDS=$((10#$GATE_SECONDS))
    GATE_START=$SECONDS
    GATE_TIMEOUT_BIN=""
    if command -v timeout >/dev/null 2>&1; then GATE_TIMEOUT_BIN=timeout
    elif command -v gtimeout >/dev/null 2>&1; then GATE_TIMEOUT_BIN=gtimeout
    fi
}

gate_run() {
    [ -n "${GATE_START:-}" ] || gate_budget_init
    [ -n "$GATE_TIMEOUT_BIN" ] || { "$@"; return $?; }
    local left=$((GATE_SECONDS - (SECONDS - GATE_START)))
    [ "$left" -gt 0 ] || return 124
    # -k: a suite that ignores TERM (test runners with workers) is still stopped.
    "$GATE_TIMEOUT_BIN" -k 10 "$left" "$@"
}

gate_block_if_timed_out() {
    [ "$1" = 124 ] || return 0
    echo "BLOCKED: $2 did not finish within ${GATE_SECONDS} s (CLAUDE_BASE_GATE_SECONDS). A gate cut by Claude Code's hook timeout lets the action through, so it blocks instead. Raise the budget, or bypass once with the gate's SKIP_ variable."
    exit 2
}
