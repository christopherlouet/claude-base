const assert = require("node:assert");
const { cartSummary } = require("../cart");

module.exports = {
  "cart totals are integer cents": () => {
    const s = cartSummary([{ priceCents: 1999, qty: 3 }], { type: "fixed", amountCents: 1000 });
    assert.ok(Number.isInteger(s.totalCents), "total must be integer cents");
    assert.strictEqual(s.subtotalCents, 5997);
    assert.strictEqual(s.totalCents, 4997);
  },
};
