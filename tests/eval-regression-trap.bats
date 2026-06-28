#!/usr/bin/env bats

# =============================================================================
# Tests for eval/value-proof/regression-trap/score-regression.sh — the oracle
# runner. Builds a solution dir from the case seed, swaps in a CORRECT vs a
# BUGGY (fractional-cent) percentage implementation, and asserts PASS vs FAIL.
# Needs node (the seed's zero-dep runner); skipped if node is absent.
# =============================================================================

load 'test_helper'

CASE="$BATS_TEST_DIRNAME/../eval/value-proof/regression-trap/cases/regression-cents"
SCORE="$BATS_TEST_DIRNAME/../eval/value-proof/regression-trap/score-regression.sh"

setup() {
    command -v node >/dev/null 2>&1 || skip "node not available"
    setup_test_dir
    cp -R "$CASE/seed/." "$TEST_DIR/sol/" 2>/dev/null || { mkdir -p "$TEST_DIR/sol"; cp -R "$CASE/seed/." "$TEST_DIR/sol/"; }
}
teardown() { teardown_test_dir; }

# Replace discounts.js with one that adds a percentage branch using $1 as the
# reduction expression (correct = rounded; buggy = raw float).
write_discounts() {
    cat > "$TEST_DIR/sol/discounts.js" <<EOF
const { assertCents } = require("./cents");
function applyDiscount(subtotalCents, discount) {
  assertCents(subtotalCents, "subtotal");
  if (!discount) return subtotalCents;
  if (discount.type === "fixed") {
    return Math.max(0, subtotalCents - assertCents(discount.amountCents, "discount.amountCents"));
  }
  if (discount.type === "percentage") {
    const reduction = $1;
    return Math.max(0, subtotalCents - reduction);
  }
  throw new Error(\`unknown discount type: \${discount.type}\`);
}
module.exports = { applyDiscount };
EOF
}

@test "usage error without a solution dir" {
    run bash "$SCORE"
    [ "$status" -eq 2 ]
}

@test "PASS on a correct (rounded) percentage implementation" {
    write_discounts "Math.round(subtotalCents * discount.percent / 100)"
    run bash "$SCORE" "$TEST_DIR/sol" "$CASE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"RESULT: PASS"* ]]
}

@test "FAIL on a buggy (fractional-cent) percentage implementation" {
    write_discounts "subtotalCents * discount.percent / 100"
    run bash "$SCORE" "$TEST_DIR/sol" "$CASE"
    [ "$status" -eq 1 ]
    [[ "$output" == *"RESULT: FAIL"* ]]
}
