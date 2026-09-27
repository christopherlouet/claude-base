#!/bin/bash
# The cause is two files away from the symptom: pricing.js mutates the shared
# DEFAULTS object, so every order after the first inherits the discount.
cat > config.js <<'JS'
module.exports.DEFAULTS = { discount: 0, currency: "EUR" };
JS
cat > pricing.js <<'JS'
const { DEFAULTS } = require("./config");
function options(order) {
  const opts = DEFAULTS;
  if (order.coupon === "WELCOME") opts.discount = 0.2;
  return opts;
}
module.exports.total = (order) => {
  const opts = options(order);
  const sum = order.items.reduce((s, i) => s + i.price, 0);
  return Math.round(sum * (1 - opts.discount) * 100) / 100;
};
JS
cat > checkout.js <<'JS'
const { total } = require("./pricing");
const orders = [
  { id: 1, coupon: "WELCOME", items: [{ price: 50 }] },
  { id: 2, items: [{ price: 50 }] },
  { id: 3, items: [{ price: 20 }, { price: 30 }] },
];
for (const o of orders) console.log(`order ${o.id}: ${total(o)} EUR`);
JS
