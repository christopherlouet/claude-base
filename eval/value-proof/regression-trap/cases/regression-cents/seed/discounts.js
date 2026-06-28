const { assertCents } = require("./cents");

// Apply a discount to a subtotal (in cents); returns the new subtotal in cents.
// Supported discount types:
//   { type: "fixed", amountCents }  — subtract a fixed number of cents (clamped at 0)
function applyDiscount(subtotalCents, discount) {
  assertCents(subtotalCents, "subtotal");
  if (!discount) return subtotalCents;
  if (discount.type === "fixed") {
    return Math.max(0, subtotalCents - assertCents(discount.amountCents, "discount.amountCents"));
  }
  throw new Error(`unknown discount type: ${discount.type}`);
}

module.exports = { applyDiscount };
