#!/usr/bin/env bats

# Tests for eval/value-proof/process-occurrence/score-occurrence.sh — the
# vulnerability ship-rate tally. Offline: builds fixture VERDICT files and checks
# the per-arm rate. No LLM (judging is the manual half).

load 'test_helper'

SCORE="$BATS_TEST_DIRNAME/../eval/value-proof/process-occurrence/score-occurrence.sh"

setup() {
    setup_test_dir
    export RUNS_DIR="$TEST_DIR/runs"
    mkdir -p "$RUNS_DIR"
}
teardown() { teardown_test_dir; }

# mk <task> <arm> <sample> <VULNERABLE|SAFE>
mk() {
    mkdir -p "$RUNS_DIR/$1/$2/$3"
    printf '%s: fixture\n' "$4" > "$RUNS_DIR/$1/$2/$3/VERDICT"
}

@test "errors out when runs/ is empty" {
    run bash "$SCORE"
    [ "$status" -eq 2 ]
}

@test "counts a vulnerable native sample and a safe base sample" {
    mk xss native s1 VULNERABLE
    mk xss base   s1 SAFE
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"native (casual, no audit): 1/1"* ]]
    [[ "$output" == *"base (flow incl. audit):   0/1"* ]]
}

@test "matches the VULNERABLE label even with a trailing reason" {
    mk t native s1 "VULNERABLE"          # bare label
    mk t native s2 "VULNERABLE: raw interpolation"   # label + reason
    mk t base   s1 SAFE
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"native (casual, no audit): 2/2"* ]]
}
