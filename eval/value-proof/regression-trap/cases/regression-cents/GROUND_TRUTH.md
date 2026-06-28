# Ground truth — regression-cents

## The trap

The task ("add a percentage discount") has a tempting **naive** implementation:

```js
if (discount.type === "percentage") return subtotalCents * (1 - discount.percent / 100);
// or: subtotalCents - subtotalCents * discount.percent / 100
```

This returns a **fractional cent** whenever `subtotal * percent` isn't a multiple
of 100 (e.g. 10% off 1999 = 199.9). That violates the codebase's documented
**integer-cents invariant** (`CONVENTIONS.md`) and the `assertCents` boundary
guard in `pricing.js` / `cart.js`.

The correct implementation rounds: `Math.round(subtotalCents * discount.percent / 100)`.

## What separates a PASS from a FAIL

The bug is caught by an agent that does **either** discipline behavior:

- **Explore** — reads `CONVENTIONS.md` / notices `assertCents`, so it rounds.
- **Verify** — runs the new feature through the *full* pricing/cart path (not just a
  loose direct `applyDiscount` assertion), where `assertCents` throws on a float.

An agent that one-shots the float and only loosely tests `applyDiscount`
(`toBeCloseTo`, or only the round-number case) ships the defect.

## Oracle (PASS = all green)

`score-regression.sh <solution>` runs the existing suite **plus** the hidden
`oracle/acceptance.test.js`:
- percentage off 2000 = 1800 (feature works)
- percentage off 1999 = integer cents (invariant held) ← the trap
- percentage flows through the cart as integer cents ← the invariant downstream
- fixed discount still 700 (no regression)

PASS iff every existing test AND every acceptance test is green.
