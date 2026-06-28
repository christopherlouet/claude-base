#!/usr/bin/env bats

# Tests for eval/cold-start/coldstart.sh — scores the method gates by which
# process artifacts a session left behind (spec/plan/tests/audit/commit/pr).
# Offline, deterministic.

load 'test_helper'

CS="$BATS_TEST_DIRNAME/../eval/cold-start/coldstart.sh"

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

@test "usage error without a dir" {
    run bash "$CS"
    [ "$status" -eq 2 ]
}

@test "a bare session (code only) has no method artifacts" {
    mkdir -p "$TEST_DIR/bare"
    printf 'function validateCoupon(c){ return /^[A-Z0-9]{8,12}$/.test(c); }\n' > "$TEST_DIR/bare/validateCoupon.js"
    run bash "$CS" "$TEST_DIR/bare"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Method artifacts present: 0 / 6"* ]]
}

@test "a full workflow trail scores every method artifact" {
    mkdir -p "$TEST_DIR/base"
    printf '# Spec\nUser story: as a user...\nGiven a code When invalid Then reject\nacceptance criteria\n' > "$TEST_DIR/base/SPEC.md"
    printf '# Plan\n## Plan\nimplementation plan + architecture\n' > "$TEST_DIR/base/PLAN.md"
    printf 'describe("coupon", () => { it("x", () => {}); });\n' > "$TEST_DIR/base/coupon.test.js"
    printf 'export function validateCoupon(c){ return true; }\n' > "$TEST_DIR/base/coupon.js"
    printf '# Audit\nsecurity review: no OWASP issues\n' > "$TEST_DIR/base/AUDIT.md"
    printf 'feat(coupon): add validator\n' > "$TEST_DIR/base/COMMIT_MSG.txt"
    printf '# PR\n## Summary\nadds the coupon validator\n' > "$TEST_DIR/base/PR.md"
    run bash "$CS" "$TEST_DIR/base"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Method artifacts present: 6 / 6"* ]]
}

@test "tests detection is by file convention, not the words it/test in code" {
    mkdir -p "$TEST_DIR/c"
    # ordinary code that contains the words "it" and "test" but no test file
    printf 'function commit(){ /* it runs the latest test path */ return 1; }\n' > "$TEST_DIR/c/x.js"
    run bash "$CS" "$TEST_DIR/c"
    [[ "$output" == *"tests          | absent"* ]]
}
