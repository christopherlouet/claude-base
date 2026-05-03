---
sidebar_position: 22
title: "/dev:dev-test"
description: "Generates complete, high-quality tests for existing code."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TEST

Generates complete, high-quality tests for existing code.

## Request context
`&lt;arguments&gt;`

## Objective

Create an exhaustive test suite that covers nominal cases,
edge cases and error cases to guarantee code reliability.

## Workflow

- **Analyze** the code: public functions, dependencies, conditional branches, side effects
- **Identify** test cases by category:
  - Nominal (happy path): expected behavior with valid inputs
  - Edge cases: null, undefined, "", [], \{\}, 0, -1, MAX_INT, empty/very long string
  - Errors: invalid inputs, expected exceptions, impossible states
  - Boundary: off-by-one, thresholds (just before/exactly/just after), state transitions
- **Generate** tests in AAA structure (Arrange-Act-Assert) with descriptive names
- **Verify**: run the tests, validate coverage (&gt;80%)

## Coverage thresholds

- Critical business logic: 90%+
- Services and utils: 80%+
- UI components: 70%+

## Expected output

Generated test files with statistics (number of tests, estimated coverage),
cases covered per function (nominal, edge cases, errors) and command to run them.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/work:work-explore` | Understand the code to test |
| `/dev:dev-tdd` | Develop with TDD |
| `/dev:dev-testing-setup` | Configure the test infrastructure |
| `/qa:qa-review` | Review the tests |

---

IMPORTANT: No mocks except for external dependencies (API, DB, filesystem).

IMPORTANT: Tests must be independent of each other.

YOU MUST aim for coverage &gt; 80% on the target code.

YOU MUST test edge cases (null, undefined, empty, limits).

NEVER write tests that depend on execution order.

Think hard about edge cases before coding the tests.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
