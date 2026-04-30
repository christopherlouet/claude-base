---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/tests/**"
  - "**/test/**"
  - "**/__tests__/**"
---

# Testing Rules

## Coverage

- IMPORTANT: Minimum 80% coverage on new code
- Cover critical paths first
- Do not aim for 100% at the expense of quality

## Mocking

- IMPORTANT: No mocks except for external dependencies (API, DB)
- Prefer stubs over full mocks
- Avoid mocking internal modules
- Use factories for test data

## Edge Cases

- YOU MUST test edge cases:
  - `null` and `undefined`
  - Empty strings and whitespace
  - Empty arrays
  - Boundary values (0, -1, MAX_INT)
  - Errors and exceptions

## Test Structure (AAA)

```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Prepare the data
      const input = createTestData();

      // Act - Execute the action
      const result = functionToTest(input);

      // Assert - Verify the result
      expect(result).toEqual(expected);
    });
  });
});
```

## Naming Conventions

- Descriptive and readable test names
- Format: `should [behavior] when [condition]`
- Group by functionality with `describe`

## Best Practices

- Independent tests (no execution order)
- Deterministic tests (no random without seed)
- Fast tests (< 100ms per unit test)
- One test = one logical assertion
- Readable tests = living documentation
