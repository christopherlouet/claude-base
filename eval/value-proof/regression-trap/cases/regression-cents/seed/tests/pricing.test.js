const assert = require("node:assert");
const { orderTotal } = require("../pricing");

module.exports = {
  "totals with fixed discount, tax and shipping": () =>
    // subtotal 2000, -500 = 1500, +8% tax = 120, +599 shipping = 2219
    assert.strictEqual(
      orderTotal([{ priceCents: 1000, qty: 2 }], { type: "fixed", amountCents: 500 }, 800, 599),
      2219,
    ),
  "no discount, no tax, no shipping": () =>
    assert.strictEqual(orderTotal([{ priceCents: 999, qty: 1 }], null, 0, 0), 999),
};
