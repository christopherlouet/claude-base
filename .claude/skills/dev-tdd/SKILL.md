---
name: dev-tdd
description: TDD development with Red-Green-Refactor cycle. Use to implement a feature by writing tests BEFORE the code. Trigger automatically when the user asks for TDD, wants to write tests first, mentions "test first", or asks to implement, add, create, fix, correct code, a new feature, a bugfix, or a functionality.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[feature-description]"
---

# Test-Driven Development (TDD)

## Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

If code was written before the test: delete it. Start over with TDD.

- Don't keep it "as a reference"
- Don't "adapt" it by writing the tests
- Don't look at it
- Delete = delete

Implement from scratch starting from the tests. Period.

## TDD Cycle

```
┌─────────┐     ┌─────────┐     ┌──────────┐
│   RED   │ ──▶ │  GREEN  │ ──▶ │ REFACTOR │
│  Test   │     │  Code   │     │  Clean   │
│  fail   │     │  pass   │     │   up     │
└─────────┘     └─────────┘     └──────────┘
      ▲                              │
      └──────────────────────────────┘
```

## Phase 1: RED - Write a failing test

### Write ONE minimal test showing the expected behavior

```typescript
describe('Module', () => {
  describe('function', () => {
    it('should [behavior] when [condition]', () => {
      // Arrange - Prepare
      // Act - Execute
      // Assert - Verify
    });
  });
});
```

### Good test vs Bad test

**Good**: Clear name, tests real behavior, one thing only
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

**Bad**: Vague name, tests the mock instead of the code
```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(3);
});
```

### Verify RED (MANDATORY - never skip)

```bash
npm test path/to/test.test.ts
```

Confirm:
- The test fails (no syntax error)
- The failure message is the expected one
- The failure comes from the missing feature (not a typo)

**Test passes immediately?** You're testing existing behavior. Fix the test.

**Test has a syntax error?** Fix it, rerun until you get a proper failure.

## Phase 2: GREEN - Minimal code

Write the simplest code to pass the test. Nothing more.

**Good**: Just enough to pass
```typescript
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i === 2) throw e;
    }
  }
  throw new Error('unreachable');
}
```

**Bad**: Over-engineering, YAGNI
```typescript
async function retryOperation<T>(
  fn: () => Promise<T>,
  options?: {
    maxRetries?: number;
    backoff?: 'linear' | 'exponential';
    onRetry?: (attempt: number) => void;
  }
): Promise<T> {
  // Features not requested by a test
}
```

Don't add features, refactor other code, or "improve" beyond the test.

### Verify GREEN (MANDATORY)

```bash
npm test path/to/test.test.ts
```

Confirm:
- The test passes
- Other tests still pass
- Clean output (no errors, warnings)

**Test fails?** Fix the code, not the test.

**Other tests fail?** Fix them now.

## Phase 3: REFACTOR - Clean up

After GREEN only:
- Remove duplications
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

### Commit

```bash
git commit -m "test(scope): add tests for [feature]"
git commit -m "feat(scope): implement [feature]"
```

Then start over: next failing test for the next feature.

## Why the order matters

### "I'll write the tests after to verify"

Tests written after the code pass immediately. Passing immediately proves nothing:
- The test may be testing the wrong thing
- The test may be testing the implementation instead of the behavior
- The test may miss forgotten edge cases
- You never saw the test catch the bug

Test-first forces you to see the test fail, proving it tests something.

### "I already manually tested all the cases"

Manual testing is ad-hoc:
- No record of what was tested
- Impossible to rerun when the code changes
- Easy to forget cases under pressure
- "It worked when I tried" ≠ complete test

Automated tests are systematic. They run the same way every time.

### "Deleting X hours of work is a waste"

Sunk cost fallacy. The time is already lost. The choice now:
- Delete and rewrite in TDD (X more hours, high confidence)
- Keep and add tests after (30 min, low confidence, likely bugs)

The "waste" is keeping code you can't trust.

## Common rationalizations

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "I'll write the tests after" | Tests that pass immediately prove nothing. |
| "Tests-after reach the same goal" | Tests-after = "what does it do?" Tests-first = "what should it do?" |
| "I already manually tested" | Ad-hoc ≠ systematic. No record, not replayable. |
| "Deleting X hours of work is a waste" | Sunk cost. Keeping unverified code = technical debt. |
| "I keep it as a reference and write the tests first" | You'll adapt it. It's disguised test-after. Delete = delete. |
| "I need to explore first" | OK. Throw away the exploration, start in TDD. |
| "It's hard to test = unclear design" | Listen to the test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD faster than debugging. Pragmatic = test-first. |
| "Manual testing is faster" | Manual testing doesn't prove edge cases. You retest on every change. |
| "Existing code has no tests" | We're improving it. Add tests for the existing code. |
| "It's different because..." | No. No exception without explicit user permission. |

## Red Flags — STOP and start over

Stop immediately if you find yourself:

- Writing code before the test
- Writing the test after the implementation
- A test that passes immediately
- Unable to explain why the test failed
- Adding tests "later"
- Rationalizing "just this once"
- "I already manually tested"
- "Tests-after reach the same goal"
- "It's the spirit that counts, not the ritual"
- "I keep it as a reference" or "I adapt the existing code"
- "I already spent X hours, deleting is a waste"
- "TDD is dogmatic, I'm pragmatic"
- "It's different because..."

**All these signals mean: delete the code. Start over in TDD.**

## Qualities of a good test

| Quality | Good | Bad |
|---------|-----|---------|
| **Minimal** | One thing only. "and" in the name? Split it. | `test('validates email and domain and whitespace')` |
| **Clear** | The name describes the behavior | `test('test1')` |
| **Intentional** | Demonstrates the desired API | Obscures what the code should do |

## Complete example: Bug Fix

**Bug:** Empty email accepted

**RED**
```typescript
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
```

**Verify RED**
```bash
$ npm test
FAIL: expected 'Email required', got undefined
```

**GREEN**
```typescript
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
  // ...
}
```

**Verify GREEN**
```bash
$ npm test
PASS
```

**REFACTOR**: Extract the validation for other fields if necessary.

## Verification checklist

Before declaring the work done:

- [ ] Each new function/method has a test
- [ ] Each test was seen failing before implementing
- [ ] Each test failed for the right reason (missing feature, not a typo)
- [ ] Minimal code written to pass each test
- [ ] All tests pass
- [ ] Clean output (no errors, warnings)
- [ ] Tests on real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? TDD was skipped. Start over.

## When you're stuck

| Problem | Solution |
|----------|----------|
| Don't know how to test | Write the desired API. Write the assertion first. Ask the user. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Everything must be mocked | Code too coupled. Use dependency injection. |
| Huge test setup | Extract helpers. Still complex? Simplify the design. |

## Useful commands

```bash
# Run the tests
npm test

# Tests in watch mode
npm run test:watch

# With coverage
npm run test:coverage

# A specific file
npm test -- --grep "test name"
```

## Generating tests for existing code

TDD is test-first, but the same discipline applies when back-filling tests on code that
already exists (legacy, coverage gaps).

1. **Analyze** the target: public functions, dependencies, conditional branches, side effects.
2. **Enumerate cases** by category:
   - Nominal (happy path) — valid inputs, expected behavior.
   - Edge — `null`, `undefined`, `""`, `[]`, `{}`, `0`, `-1`, `MAX_INT`, empty/very long strings.
   - Errors — invalid inputs, expected exceptions, impossible states.
   - Boundary — off-by-one, thresholds (just before / exactly / just after), state transitions.
3. **Write** in AAA structure (Arrange-Act-Assert) with descriptive names.
4. **Verify** — run, then check coverage: critical business logic 90%+, services/utils 80%+, UI 70%+.

Same rules as test-first: no mocks except external deps, tests independent and order-free.

## Test infrastructure setup

When a project has no test setup yet:

- **Framework** matched to the stack: Vitest (React/Vue/Node), Pytest (Python), `go test` (Go).
- **Coverage thresholds** configured (new code 80%, critical 90%, utils 100%, UI 70%).
- **Mocks**: MSW for API mocks (preferred over manual mocks); never mock what can be tested for real (pure functions, utils).
- **Layout**: co-located or `__tests__`; global setup + shared mocks.
- **npm scripts**: `test`, `test:watch`, `test:ui`, `test:coverage`, `test:ci`.
- **CI/CD**: GitHub Actions job running the suite with coverage upload (`/ops:ops-ci`).

## Rules

- NEVER write the code before the tests
- A test that passes from the start is a BAD test
- Cover edge cases (null, undefined, empty, limits)
- Mocks ONLY for external dependencies (API, DB, filesystem)
- NEVER modify a test to make it pass — fix the implementation
- Each test MUST be seen failing before writing the code
- Delete code written without a test. No exception.
