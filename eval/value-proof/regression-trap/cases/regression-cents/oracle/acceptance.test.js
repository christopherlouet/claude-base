// Hidden acceptance + invariant oracle for the percentage-discount task.
// Copied into a solution's tests/ dir as _acceptance.test.js by score-regression.sh,
// so its requires are relative to tests/ (one level up = the solution root).
const assert = require("node:assert");
const { applyDiscount } = require("../discounts");
const { cartSummary } = require("../cart");

module.exports = {
  "percentage discount reduces subtotal correctly": () =>
    assert.strictEqual(applyDiscount(2000, { type: "percentage", percent: 10 }), 1800),

  "percentage discount stays integer cents (rounding)": () => {
    // 10% off 1999 = 199.9 cents off -> the result must be an integer number of cents.
    const r = applyDiscount(1999, { type: "percentage", percent: 10 });
    assert.ok(Number.isInteger(r), `discount result must be integer cents, got ${r}`);
  },

  "percentage flows through the cart as integer cents": () => {
    const s = cartSummary([{ priceCents: 1999, qty: 1 }], { type: "percentage", percent: 10 });
    assert.ok(Number.isInteger(s.totalCents), `cart total must be integer cents, got ${s.totalCents}`);
  },

  "fixed discount still works (no regression)": () =>
    assert.strictEqual(applyDiscount(1000, { type: "fixed", amountCents: 300 }), 700),
};
