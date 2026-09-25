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
#   gate_run_tail <n> <cmd…>    same, output to a file, then its last n lines.
#                               The gate never waits on a pipe: a grandchild
#                               that ignores TERM (npm dies, its worker lives)
#                               held `cmd | tail` open past the budget — measured
#                               30 s for 2, i.e. the fail-open again past 1800.
#   gate_block_if_timed_out <rc> <gate>
#                               124 (TERM) or 137 (KILL after -k) AND the budget
#                               really elapsed: print why and exit 2. A suite that
#                               exits 124 by itself is an ordinary failure.
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
    # -k: a DIRECT child that ignores TERM is KILLed 10 s later (exit 137). A
    # grandchild escaping both no longer holds the gate: see gate_run_tail.
    "$GATE_TIMEOUT_BIN" -k 10 "$left" "$@"
}

gate_run_tail() {
    local n="$1" log rc; shift
    log=$(mktemp 2>/dev/null) || { gate_run "$@" 2>&1 | tail -"$n"; return "${PIPESTATUS[0]}"; }
    gate_run "$@" > "$log" 2>&1 < /dev/null
    rc=$?
    tail -"$n" "$log"
    rm -f "$log"
    return "$rc"
}

gate_block_if_timed_out() {
    case "$1" in 124|137) ;; *) return 0 ;; esac
    [ $((SECONDS - ${GATE_START:-$SECONDS})) -ge "${GATE_SECONDS:-1500}" ] || return 0
    echo "BLOCKED: $2 did not finish within ${GATE_SECONDS} s (CLAUDE_BASE_GATE_SECONDS). A gate cut by Claude Code's hook timeout lets the action through, so it blocks instead. Raise the budget, or bypass once with the gate's SKIP_ variable."
    exit 2
}
