#!/usr/bin/env bats

# =============================================================================
# Tests for eval/value-proof/score.sh — the process-defect scorer of the
# foundation value-proof harness. Fully OFFLINE and deterministic: it drives the
# real scripts/substance-check.sh plus a static untested-module check over
# fixture sample dirs. No LLM is invoked — generation is the manual half (see
# eval/value-proof/GENERATING.md).
#
# Two defect signals, reported by tier x kind:
#   intercept — substance gate flags a hollow test / a shipped stub.
#   gaps      — a logic-bearing source module no test references (only counted
#               when the task actually asked for tests).
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

# mk_task <name> <kind> <tier> <outputs-lines>
mk_task() {
    mkdir -p "$TASKS_DIR/$1"
    printf '%s\n' "$2" > "$TASKS_DIR/$1/KIND"
    printf '%s\n' "$3" > "$TASKS_DIR/$1/TIER"
    printf '%s\n' "${4:-}" > "$TASKS_DIR/$1/OUTPUTS"
}

# A test file the substance gate flags as hollow (runs code, asserts nothing).
mk_hollow_sample() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/hollow.test.ts" <<'EOF'
import { describe, it } from "vitest";
describe("thing", () => { it("works", () => { const a = 1; const b = a + 1; }); });
EOF
}

# A logic-bearing module with NO test referencing it.
mk_untested_module() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/mod.ts" <<'EOF'
export function add(a: number, b: number): number { return a + b; }
EOF
}

# A logic-bearing module WITH a substantive test referencing it.
mk_tested_module() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/mod.ts" <<'EOF'
export function add(a: number, b: number): number { return a + b; }
EOF
    cat > "$RUNS_DIR/$1/$2/mod.test.ts" <<'EOF'
import { expect, it } from "vitest";
import { add } from "./mod";
it("adds", () => { expect(add(1, 2)).toBe(3); });
EOF
}

# A pure type/constant module (no logic) with no test — must NOT count as a gap.
mk_pure_type_module() {
    mkdir -p "$RUNS_DIR/$1/$2"
    cat > "$RUNS_DIR/$1/$2/types.ts" <<'EOF'
export type Order = { id: string; total: number };
EOF
}

@test "errors out when runs/ is empty" {
    run bash "$SCORE"
    [ "$status" -eq 2 ]
    [[ "$output" == *"empty"* ]] || [[ "$output" == *"generate"* ]]
}

@test "errors out when the detector is missing" {
    mk_task t tempting simple $'a.ts\na.test.ts'
    mk_hollow_sample t s1
    DETECTOR="$TEST_DIR/nope.sh" run bash "$SCORE"
    [ "$status" -eq 2 ]
    [[ "$output" == *"detector not found"* ]]
}

@test "intercepts a hollow test (intercept signal fires)" {
    mk_task t tempting simple $'a.ts\na.test.ts'
    mk_hollow_sample t s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"simple / tempting"* ]]
    [[ "$output" == *"intercept 1"* ]]
}

@test "clean tested module is no defect (neutral FP guard stays 0)" {
    mk_task n neutral simple $'mod.ts\nmod.test.ts'
    mk_tested_module n s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"simple / neutral     defect 0/1"* ]]
}

@test "untested logic module counts as a gap when tests were requested" {
    mk_task c neutral complex $'mod.ts\nmod.test.ts'
    mk_untested_module c s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"complex / neutral    defect 1/1"* ]]
    [[ "$output" == *"gaps 1"* ]]
}

@test "untested module is NOT a gap when the task did not ask for tests" {
    mk_task c neutral complex 'mod.ts'   # OUTPUTS has no test file
    mk_untested_module c s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"complex / neutral    defect 0/1"* ]]
    [[ "$output" == *"gaps 0"* ]]
}

@test "a pure type/constant module never counts as a gap" {
    mk_task c neutral complex $'types.ts\ntypes.test.ts'
    mk_pure_type_module c s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"complex / neutral    defect 0/1"* ]]
}

@test "reports the simple-vs-complex key comparison line" {
    mk_task sn neutral simple  $'mod.ts\nmod.test.ts'
    mk_tested_module sn s1
    mk_task cn neutral complex $'mod.ts\nmod.test.ts'
    mk_untested_module cn s1
    run bash "$SCORE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"simple/neutral 0%  ->  complex/neutral 100%"* ]]
}
