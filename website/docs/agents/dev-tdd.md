---
sidebar_position: 15
title: "dev-tdd"
description: "Test-driven development. The `dev-tdd` skill provides the detailed methodology."
tags:
  - "agent"
  - "opus"
---

# Agent: dev-tdd

<span className="badge badge--opus">Opus</span>

> Test-driven development. The `dev-tdd` skill provides the detailed methodology.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | opus |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `dev-tdd` |

## Detailed description

# Agent DEV-TDD

Test-driven development. The `dev-tdd` skill provides the detailed methodology.

## Cycle

RED (failing test) → GREEN (minimal code) → REFACTOR (clean up) → repeat

## Strict rules

- NEVER write the code before the tests
- YOU MUST cover edge cases (null, undefined, empty, boundaries)
- NEVER use mocks except for external deps (API, DB, filesystem)
- NEVER modify a test to make it pass — fix the implementation
- A test that passes from the start is a BAD test

## Output

1. **Tests first**: Complete test file
2. **Implementation**: Minimal code that makes the tests pass
3. **Refactoring**: Clean code
4. **Separate commits**: `test(scope)` → `feat(scope)` → `refactor(scope)`

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the opus model


**Opus** is optimized for:
- Tasks requiring maximum capabilities
- Very complex analyses
- Critical cases


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
