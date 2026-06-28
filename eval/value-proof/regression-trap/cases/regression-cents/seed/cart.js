const { applyDiscount } = require("./discounts");
const { orderTotal } = require("./pricing");
const { assertCents } = require("./cents");

// Summarize a cart: items [{ priceCents, qty }] and an optional discount.
function cartSummary(items, discount) {
  let subtotal = 0;
  for (const it of items) subtotal += it.priceCents * it.qty;
  const afterDiscount = applyDiscount(subtotal, discount);
  const total = orderTotal(items, discount, 0, 0);
  return {
    subtotalCents: assertCents(subtotal, "subtotal"),
    afterDiscountCents: assertCents(afterDiscount, "afterDiscount"),
    totalCents: assertCents(total, "total"),
  };
}

module.exports = { cartSummary };
