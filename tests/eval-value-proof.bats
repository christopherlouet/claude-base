#!/usr/bin/env bats

# =============================================================================
# Tests for eval/value-proof/score.sh — the interception-rate scorer of the
# foundation value-proof harness. Fully OFFLINE and deterministic: it drives the
# real scripts/substance-check.sh over fixture sample dirs (a hollow test that
# the gate flags, a clean impl that it does not). No LLM is invoked — generation
# is the manual half (see eval/value-proof/GENERATING.md).
#
# The scorer answers "how often would the substance gate catch a defect an
# ungated agent shipped?" split by task KIND (tempting = signal, neutral = the
# false-positive guard, want ~0).
# =============================================================================

load 'test_helper'

SCORE="$BATS_TEST_DIRNAME/../eval/value-proof/score.sh"
DETECTOR="$BATS_TEST_DIRNAME/../scripts/substance-check.sh"

setup() {
    setup_test_dir
    export TASKS_DIR="$TEST_DIR/tasks"
    export RUNS_DIR="$TEST_DIR/runs"
    export DETECTOR
    mkdir -p "$TASKS_DIR" "$RUNS_DIR"
}
teardown() { teardown_test_dir; }

# mk_task <name> <kind>
mk_task() {
    mkdir -p "$TASKS_DIR/$1"
    printf '%s\n' "$2" > "$TASKS_DIR/$1/KIND"
}

# A test file the substance gate flags as hollow (runs code, asserts nothing).
mk_hollow_sample() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/hollow.test.ts" <<'EOF'
import { describe, it } from "vitest";
describe("thing", () => {
  it("works", () => {
    const a = 1;
    const b = a + 1;
  });
});
EOF
}

# A real implementation the gate leaves alone (substantive, no stub).
mk_clean_sample() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/clean.ts" <<'EOF'
export function add(a: number, b: number): number {
  return a + b;
}
EOF
}

@test "errors out when runs/ is empty" {
    run bash "$SCORE"
    [ "$status" -eq 2 ]
    [[ "$output" == *"empty"* ]] || [[ "$output" == *"generate"* ]]
}

@test "errors out when the detector is missing" {
    mk_task t tempting
    mk_hollow_sample t s1
    DETECTOR="$TEST_DIR/nope.sh" run bash "$SCORE"
    [ "$status" -eq 2 ]
    [[ "$output" == *"detector not found"* ]]
}

@test "intercepts a hollow test in a tempting task" {
    mk_task t tempting
    mk_hollow_sample t s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tempting (the signal):       1/1"* ]]
}

@test "does not flag a clean impl (neutral FP guard stays 0)" {
    mk_task n neutral
    mk_clean_sample n s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"neutral  (FP guard, want ~0): 0/1"* ]]
}

@test "reports the tempting-vs-neutral gap across a mixed set" {
    mk_task temp tempting
    mk_hollow_sample temp s1
    mk_clean_sample  temp s2     # one caught, one clean -> 1/2
    mk_task neut neutral
    mk_clean_sample neut s1       # clean -> 0/1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tempting (the signal):       1/2"* ]]
    [[ "$output" == *"neutral  (FP guard, want ~0): 0/1"* ]]
}

@test "--verbose lists per-sample interception marks" {
    mk_task t tempting
    mk_hollow_sample t s1
    run bash "$SCORE" --verbose
    [ "$status" -eq 0 ]
    [[ "$output" == *"INTERCEPTED"* ]]
}
