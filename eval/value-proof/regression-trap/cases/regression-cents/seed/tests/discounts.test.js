const assert = require("node:assert");
const { applyDiscount } = require("../discounts");

module.exports = {
  "fixed discount subtracts cents": () =>
    assert.strictEqual(applyDiscount(1000, { type: "fixed", amountCents: 300 }), 700),
  "fixed discount clamps at zero": () =>
    assert.strictEqual(applyDiscount(500, { type: "fixed", amountCents: 900 }), 0),
  "no discount returns subtotal": () =>
    assert.strictEqual(applyDiscount(1000, null), 1000),
};
