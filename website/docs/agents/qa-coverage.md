---
sidebar_position: 52
title: "qa-coverage"
description: "Analysis of test coverage and quality of existing tests."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-coverage

<span className="badge badge--haiku">Haiku</span>

> Analysis of test coverage and quality of existing tests.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | `Edit`, `Write`, `NotebookEdit` |
| **Injected skills** | _None_ |

## Detailed description

# Agent QA-COVERAGE

Analysis of test coverage and quality of existing tests.

## Workflow

1. **Collect** metrics: `npm run test:coverage`
2. **Evaluate**: Statements >= 80%, Branches >= 75%, Functions >= 80%, Lines >= 80%
3. **Identify critical areas**: files < 50%, high complexity, business logic, bug history
4. **Analyze quality**: isolation, readability, assertion relevance, skipped tests
5. **Red flags**: files without tests, too many mocks, tests without assertions, commented tests

## Expected output

1. Coverage summary (Statements/Branches/Functions/Lines with thresholds)
2. Critical uncovered files (file, coverage, criticality)
3. Recommended missing tests (nominal case, edge cases, errors)
4. Quality of existing tests (isolation, readability, assertions)
5. Prioritized improvement plan

## Guidelines

- NEVER rely solely on the coverage percentage
- IMPORTANT: Verify the quality of assertions, not just their presence
- YOU MUST identify tests that pass without actually testing
- IMPORTANT: Prioritize coverage of critical paths (business logic)
- NEVER ignore skipped or commented tests

Think hard about critical untested areas.

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
