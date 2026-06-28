// All monetary amounts in this codebase are INTEGER CENTS. See CONVENTIONS.md.
function assertCents(n, label) {
  if (typeof n !== "number" || !Number.isInteger(n)) {
    throw new Error(`${label || "amount"} must be integer cents, got ${n}`);
  }
  return n;
}

module.exports = { assertCents };
