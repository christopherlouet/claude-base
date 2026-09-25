#!/usr/bin/env bats
# =============================================================================
# Tests for scripts/hooks/_gate-budget.sh and its use by the three blocking
# gates (pre-commit-tests, pre-push-ci, pre-deploy-build).
#
# Why (2026-09-25): a PreToolUse hook that outlives its settings.json timeout
# does NOT block — measured, the command runs. The gates run whole suites, so
# their hook timeout is 1800 s; a suite still running at that point would have
# let the commit / push / deploy through, silently. Each gate now spends ONE
# budget (CLAUDE_BASE_GATE_SECONDS, default 1500, below the hook timeout) across
# all its steps and BLOCKS when it runs out: the gate decides, not the harness.
# Where no timeout(1)/gtimeout exists the gate runs unbounded, as before.
# =============================================================================

load 'test_helper'

HOOKS="$BATS_TEST_DIRNAME/../scripts/hooks"

setup() {
    skip_if_no_jq
    setup_test_dir
    command -v timeout >/dev/null 2>&1 || command -v gtimeout >/dev/null 2>&1 || skip "no timeout(1) here"
}
teardown() { teardown_test_dir; }

# run_gate <hook> <dir> <command> [VAR=value…]
run_gate() {
    local hook="$1" dir="$2" cmd="$3"; shift 3
    jq -n --arg c "$cmd" '{tool_name:"Bash", tool_input:{command:$c}}' > "$TEST_DIR/input.json"
    run env "$@" bash -c "cd '$dir' && bash '$HOOKS/$hook' < '$TEST_DIR/input.json' 2>&1"
}

# npm_project <dir> <scripts-json>
npm_project() {
    command -v npm >/dev/null 2>&1 || skip "npm not available"
    mkdir -p "$1"
    printf '{ "name": "fixture", "version": "1.0.0", "scripts": %s }\n' "$2" > "$1/package.json"
}

# --- the helper ---------------------------------------------------------------

@test "gate-budget: gate_run returns 124 when the command outlives the budget" {
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=1 gate_budget_init; gate_run sleep 5; echo rc=\$?"
    [[ "$output" == *"rc=124"* ]]
}

@test "gate-budget: gate_run passes a fast command's exit status through" {
    run bash -c ". '$HOOKS/_gate-budget.sh'; gate_budget_init; gate_run sh -c 'exit 3'; echo rc=\$?"
    [[ "$output" == *"rc=3"* ]]
}

@test "gate-budget: the budget is shared — a second step gets only what is left" {
    # Each step alone fits in 3 s; together they do not. A per-step budget would
    # let both finish (rc=0).
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=3 gate_budget_init; gate_run sleep 2; gate_run sleep 2; echo rc=\$?"
    [[ "$output" == *"rc=124"* ]]
}

@test "gate-budget: a non-numeric or leading-zero budget falls back sanely" {
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=lots gate_budget_init; echo \$GATE_SECONDS"
    [ "$output" = "1500" ]
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=08 gate_budget_init; echo \$GATE_SECONDS"
    [ "$output" = "8" ]
}

# --- the three gates block instead of letting a hung suite through ----------------

@test "pre-commit-tests: a suite that outlives the budget BLOCKS the commit" {
    npm_project "$TEST_DIR/p" '{"test": "sleep 20"}'
    run_gate pre-commit-tests.sh "$TEST_DIR/p" 'git commit -m wip' CLAUDE_BASE_GATE_SECONDS=2
    [ "$status" -eq 2 ]
    [[ "$output" == *"did not finish within 2 s"* ]]
    [[ "$output" == *"CLAUDE_BASE_GATE_SECONDS"* ]]
    # It is the budget that blocked, not a red suite: the gate stops right there.
    [[ "$output" != *"Tests failed"* ]]
}

@test "pre-push-ci: the budget spans lint and tests, and blocks the push" {
    # Each step fits in the budget alone; only their sum outlives it.
    npm_project "$TEST_DIR/p" '{"lint": "sleep 2", "test": "sleep 2"}'
    run_gate pre-push-ci.sh "$TEST_DIR/p" 'git push origin HEAD' CLAUDE_BASE_GATE_SECONDS=3
    [ "$status" -eq 2 ]
    [[ "$output" == *"did not finish within 3 s"* ]]
    [[ "$output" != *"Local CI failed"* ]]
}

@test "pre-deploy-build: a build that outlives the budget BLOCKS the deploy" {
    npm_project "$TEST_DIR/p" '{"build": "sleep 20"}'
    run_gate pre-deploy-build.sh "$TEST_DIR/p" 'vercel deploy --prod' CLAUDE_BASE_GATE_SECONDS=2
    [ "$status" -eq 2 ]
    [[ "$output" == *"did not finish within 2 s"* ]]
}

@test "gates: a fast green suite within budget still passes (no false block)" {
    npm_project "$TEST_DIR/p" '{"test": "exit 0"}'
    run_gate pre-commit-tests.sh "$TEST_DIR/p" 'git commit -m wip' CLAUDE_BASE_GATE_SECONDS=30
    [ "$status" -eq 0 ]
}

@test "gates: the default budget stays below each gate's hook timeout" {
    # The gate must decide before Claude Code cancels the hook (which lets the
    # action through). Read both numbers from their real sources.
    local budget
    budget=$(bash -c ". '$HOOKS/_gate-budget.sh'; gate_budget_init; echo \$GATE_SECONDS")
    for h in pre-commit-tests pre-push-ci pre-deploy-build; do
        local t
        t=$(jq -r --arg h "$h" '[.hooks.PreToolUse[].hooks[] | select(.command | test($h)) | .timeout][0]' "$BASE_DIR/.claude/settings.json")
        [ "$budget" -lt "$t" ] || { echo "$h: budget $budget >= hook timeout $t" >&2; return 1; }
    done
}

# --- Independent review of #592: what the pipe let through --------------------
# `gate_run cmd | tail` ended only at the pipe's EOF: a grandchild that ignores
# TERM (npm dies, its worker lives) kept stdout open, `tail` waited, and the
# hook ran past its budget — measured 30 s for a 2 s budget; past the 1800 s
# hook timeout that is the fail-open again. Output now goes to a file.

@test "gates: a grandchild that ignores TERM does not hold the gate past its budget" {
    npm_project "$TEST_DIR/p" '{"test": "bash -c \"trap '"''"' TERM; sleep 40\""}'
    local start=$SECONDS
    run_gate pre-commit-tests.sh "$TEST_DIR/p" 'git commit -m wip' CLAUDE_BASE_GATE_SECONDS=2
    [ "$status" -eq 2 ]
    [[ "$output" == *"did not finish within 2 s"* ]]
    [ $((SECONDS - start)) -lt 25 ] || { echo "gate held for $((SECONDS - start)) s" >&2; return 1; }
}

@test "gate-budget: a command KILLed after ignoring TERM (137) reads as budget spent" {
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=1 gate_budget_init; gate_run_tail 5 bash -c \"trap '' TERM; sleep 40\"; gate_block_if_timed_out \$? probe; echo not-blocked"
    [ "$status" -eq 2 ]
    [[ "$output" == *"did not finish within 1 s"* ]]
}

@test "gate-budget: a suite that exits 124 by itself is a failure, not a budget overrun" {
    run bash -c ". '$HOOKS/_gate-budget.sh'; CLAUDE_BASE_GATE_SECONDS=60 gate_budget_init; gate_run_tail 5 sh -c 'exit 124'; rc=\$?; gate_block_if_timed_out \$rc probe; echo rc=\$rc"
    [ "$status" -eq 0 ]
    [[ "$output" == *"rc=124"* ]]
    [[ "$output" != *"did not finish"* ]]
}
