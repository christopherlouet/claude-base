const { assertCents } = require("./cents");
const { applyDiscount } = require("./discounts");

// items: [{ priceCents, qty }]; taxRateBps in basis points (e.g. 800 = 8%).
// Returns the order grand total in integer cents.
function orderTotal(items, discount, taxRateBps, shippingCents) {
  let subtotal = 0;
  for (const it of items) subtotal += assertCents(it.priceCents, "priceCents") * it.qty;
  const discounted = applyDiscount(subtotal, discount);
  const tax = Math.round(discounted * taxRateBps / 10000);
  const total = discounted + tax + assertCents(shippingCents, "shippingCents");
  return assertCents(total, "total");
}

module.exports = { orderTotal };
