---
sidebar_position: 7
title: TDD
description: Test-driven development (mandatory)
---

# Workflow: TDD (Test-Driven Development)

Test-driven development with the Red-Green-Refactor cycle.

:::tip TDD is mandatory and proactive
Since version 1.11, **TDD is mandatory** in the main workflow.
The cycle Explore → Specify → Plan → **TDD** → Audit → Commit requires writing tests BEFORE the code.

**New (v1.12+)**: The [`tdd-enforcement` rule](/docs/rules/tdd-enforcement) automatically triggers TDD when you ask to implement, add, create, or fix code.
:::

## Command

```bash
/dev:dev-tdd "Feature description"
```

## The Red-Green-Refactor cycle

```
┌─────────────────────────────────────┐
│                                     │
│    ┌─────┐                          │
│    │ RED │ Write a test that        │
│    └──┬──┘ fails                    │
│       │                             │
│       ▼                             │
│   ┌───────┐                         │
│   │ GREEN │ Write the minimal       │
│   └───┬───┘ code to pass            │
│       │                             │
│       ▼                             │
│  ┌──────────┐                       │
│  │ REFACTOR │ Improve the code      │
│  └────┬─────┘ without breaking tests│
│       │                             │
│       └─────────────────────────────┘
│                                     │
└─────────────────────────────────────┘
```

## Detailed steps

### 1. RED - Write the test

```typescript
// test/user.service.spec.ts
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid email', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User',
      });

      expect(user.id).toBeDefined();
      expect(user.email).toBe('test@example.com');
    });
  });
});
```

The test must fail because `createUser` does not exist yet.

### 2. GREEN - Implement the minimum

```typescript
// src/user.service.ts
export class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    return {
      id: generateId(),
      email: data.email,
      name: data.name,
    };
  }
}
```

Write the minimal code to pass the test.

### 3. REFACTOR - Improve

```typescript
// Add validation, repository, etc.
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async createUser(data: CreateUserDto): Promise<User> {
    this.validateEmail(data.email);
    return this.userRepository.create(data);
  }

  private validateEmail(email: string): void {
    if (!email.includes('@')) {
      throw new InvalidEmailError(email);
    }
  }
}
```

Improve the code without breaking the tests.

## Example with Claude

```bash
> /dev:dev-tdd "Create an email validation service"

# Claude:
# 1. Proposes the test cases
#    - Valid email
#    - Invalid email (no @)
#    - Empty email
#    - Null email
#
# 2. Writes the tests
#
# 3. Implements the service
#
# 4. Refactors if necessary
```

## Best practices

### DO
- ✅ One test at a time
- ✅ Independent tests
- ✅ Descriptive test names
- ✅ Test edge cases

### DON'T
- ❌ Write code before tests
- ❌ Tests dependent on each other
- ❌ Ignore edge cases
- ❌ Excessive mocks

## Recommended test structure

```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Prepare the data
      const input = { ... };

      // Act - Execute the action
      const result = fonction(input);

      // Assert - Verify the result
      expect(result).toEqual(expected);
    });
  });
});
```

## Edge cases to test

| Type | Examples |
|------|----------|
| Boundary values | 0, -1, MAX_INT |
| Null/Undefined | null, undefined |
| Empty strings | '', ' ' |
| Empty collections | [], {} |
| Errors | Exceptions, timeouts |

---

## See also

- [Rule tdd-enforcement](/docs/rules/tdd-enforcement) - Proactive TDD triggering
- [Skill dev-tdd](/docs/skills/dev-tdd) - Auto-triggered skill
- [Skill qa-tech-debt](/docs/skills/qa-tech-debt) - Coverage & tech-debt analysis
