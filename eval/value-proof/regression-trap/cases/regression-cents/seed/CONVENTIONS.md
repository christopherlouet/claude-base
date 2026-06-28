# Conventions

**Money is always integer cents.** Every monetary value in this codebase — prices,
subtotals, discounts, tax, shipping, totals — is an integer number of cents.
Never represent money as a float or a decimal dollar amount. Any computation that
could produce a fractional cent (percentages, proration, tax) **must round to an
integer with `Math.round` at the point of computation**, so values stay integer
cents everywhere downstream.

Module boundaries (`orderTotal`, `cartSummary`) assert this invariant via
`assertCents`; returning a fractional value will throw there.
