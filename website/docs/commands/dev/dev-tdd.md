---
sidebar_position: 20
title: "/dev:dev-tdd"
description: "Implements a feature by following the TDD (Test-Driven Development) cycle."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TDD

Implements a feature by following the TDD (Test-Driven Development) cycle.

## Context
`<arguments>`

## Goal

Develop robust code by writing tests BEFORE the implementation.
TDD guarantees complete test coverage and emergent design.

Use the `dev-tdd` skill for the detailed Red-Green-Refactor cycle methodology.

## TDD Cycle

RED (test fails) → GREEN (minimal code) → REFACTOR (clean up) → repeat

## Expected output

1. **Tests first**: Complete test file (nominal cases, edge cases, errors)
2. **Implementation**: Minimal code that makes the tests pass
3. **Refactoring**: Clean, readable, SOLID code
4. **Separate commits**: `test(scope)` → `feat(scope)` → `refactor(scope)`

## Related agents

| Before | Usage |
|--------|-------|
| `/work:work-plan` | Plan before coding |
| `/work:work-explore` | Understand the context |

| After | Usage |
|-------|-------|
| `/qa:qa-review` | Code review |
| `/work:work-commit` | Commit cleanly |

---

IMPORTANT: Never write the code before the tests.

IMPORTANT: A test that passes from the start is a BAD test.

YOU MUST cover edge cases (null, undefined, empty, boundaries).

NEVER use mocks except for external dependencies (API, DB, filesystem).

NEVER modify a test to make it pass — fix the implementation.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
