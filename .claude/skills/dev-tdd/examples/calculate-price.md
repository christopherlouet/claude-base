# TDD Example: Price calculation function with discount

## User request
> "Create a calculatePrice function that applies a percentage discount"

---

## Phase 1: RED - Tests

```typescript
// src/__tests__/calculatePrice.test.ts

describe('calculatePrice', () => {
  // Nominal case
  it('should return original price when no discount', () => {
    expect(calculatePrice(100, 0)).toBe(100);
  });

  it('should apply percentage discount correctly', () => {
    expect(calculatePrice(100, 20)).toBe(80);
  });

  // Edge cases
  it('should handle decimal prices', () => {
    expect(calculatePrice(99.99, 10)).toBeCloseTo(89.99);
  });

  it('should return 0 when price is 0', () => {
    expect(calculatePrice(0, 50)).toBe(0);
  });

  // Error cases
  it('should throw when discount > 100', () => {
    expect(() => calculatePrice(100, 150)).toThrow('Discount must be between 0 and 100');
  });

  it('should throw when discount < 0', () => {
    expect(() => calculatePrice(100, -10)).toThrow('Discount must be between 0 and 100');
  });
});
```

**Expected result**: 6 tests fail

---

## Phase 2: GREEN - Minimal implementation

```typescript
// src/utils/calculatePrice.ts

export function calculatePrice(price: number, discountPercent: number): number {
  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }
  return price * (1 - discountPercent / 100);
}
```

**Expected result**: 6 tests pass

---

## Phase 3: REFACTOR - Improvement

```typescript
// src/utils/calculatePrice.ts

const MIN_DISCOUNT = 0;
const MAX_DISCOUNT = 100;

function validateDiscount(discount: number): void {
  if (discount < MIN_DISCOUNT || discount > MAX_DISCOUNT) {
    throw new Error(`Discount must be between ${MIN_DISCOUNT} and ${MAX_DISCOUNT}`);
  }
}

export function calculatePrice(price: number, discountPercent: number): number {
  validateDiscount(discountPercent);
  const discountMultiplier = 1 - discountPercent / 100;
  return price * discountMultiplier;
}
```

**Expected result**: 6 tests still pass

---

## Commits

```bash
# After RED phase
git commit -m "test(pricing): add tests for calculatePrice function

- Test nominal cases (no discount, with discount)
- Test edge cases (decimal prices, zero price)
- Test error handling (invalid discount range)"

# After GREEN + REFACTOR phase
git commit -m "feat(pricing): implement calculatePrice with discount

- Add price calculation with percentage discount
- Validate discount range (0-100)
- Extract validation to separate function"
```
