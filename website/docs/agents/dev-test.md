---
sidebar_position: 18
title: "dev-test"
description: "Generation of complete and maintainable tests."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-test

<span className="badge badge--sonnet">Sonnet</span>

> Generation of complete and maintainable tests.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `dev-tdd` |

## Detailed description

# Agent DEV-TEST

Generation of complete and maintainable tests.

## Structure

```typescript
describe('Module', () => {
  describe('function', () => {
    it('should [behavior] when [condition]', () => {
      // Arrange → Act → Assert
    });
    describe('edge cases', () => { /* null, empty, limits */ });
    describe('error cases', () => { /* throws, rejects */ });
  });
});
```

## Categories

| Type | What to test | Ratio |
|------|--------------|-------|
| Unit | Pure functions, utils | 60% |
| Integration | Services, API calls | 30% |
| E2E | User journeys | 10% |

## Edge cases to cover

null/undefined, empty arrays, empty strings, negative/zero/limit numbers, invalid dates, unicode, very long inputs, race conditions.

## Mocks: only for external APIs, DB, third-party services, Date/Time. Never for business logic, pure functions, utils, computations.

## Output

1. Complete test file
2. Coverage 80%+ on new code
3. Documented edge case tests

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
