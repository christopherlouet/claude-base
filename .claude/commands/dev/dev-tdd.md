# Agent DEV-TDD

Implements a feature by following the TDD (Test-Driven Development) cycle.

## Context
$ARGUMENTS

## Goal

Develop robust code by writing tests BEFORE the implementation.
TDD guarantees complete test coverage and emergent design.

This command is the single entry point for the test lifecycle. Besides the test-first
cycle, it also: **generates an exhaustive test suite for existing code** (nominal, edge,
error, boundary — AAA structure) and **sets up the test infrastructure** (framework,
coverage thresholds, MSW mocks, npm scripts, CI). Use the `dev-tdd` skill for the
detailed methodology of all three.

## TDD Cycle

RED (test fails) → GREEN (minimal code) → REFACTOR (clean up) → repeat

## Expected output

1. **Tests first**: Complete test file (nominal cases, edge cases, errors)
2. **Implementation**: Minimal code that makes the tests pass
3. **Refactoring**: Clean, readable, SOLID code
4. **Separate commits**: `test(scope)` → `feat(scope)` → `refactor(scope)`

## Other modes

- **Generate tests for existing code**: analyze public functions/branches/side-effects, generate nominal + edge (null/undefined/""/[]/{}/0/-1/MAX_INT) + error + boundary cases in AAA structure with descriptive names; target coverage >80% (critical 90%+, utils 80%+, UI 70%+). No mocks except external deps; independent, order-free tests.
- **Set up test infrastructure**: pick the framework for the stack (Vitest for JS/TS, Pytest for Python, `go test` for Go), configure coverage thresholds, MSW for API mocks (preferred over manual mocks), npm scripts (`test`, `test:watch`, `test:coverage`, `test:ci`), and the CI workflow.

## Related agents

| Before | Usage |
|--------|-------|
| `/work:work-plan` | Plan before coding |
| `/work:work-explore` | Understand the code/context |

| After | Usage |
|-------|-------|
| `/qa:qa-review` | Review the tests / code |
| `/ops:ops-ci` | Wire coverage into CI/CD |
| `/work:work-commit` | Commit cleanly |

---

IMPORTANT: Never write the code before the tests.

IMPORTANT: A test that passes from the start is a BAD test.

YOU MUST cover edge cases (null, undefined, empty, boundaries).

NEVER use mocks except for external dependencies (API, DB, filesystem).

NEVER modify a test to make it pass — fix the implementation.
