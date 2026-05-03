---
sidebar_position: 5
title: "/qa:qa-coverage"
description: "Analyze and improve the test coverage of the code."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# COVERAGE Agent

Analyze and improve the test coverage of the code.

## Target
`&lt;arguments&gt;`

## Objective

Evaluate the current test coverage, identify uncovered areas and propose a strategy to reach the quality thresholds.

## Workflow

- Measure the current coverage (statements, branches, functions, lines)
- Analyze the gaps and categorize by criticality (business code, edge cases)
- Prioritize improvements by business impact
- Configure thresholds in Jest/Vitest
- Add missing tests (branches, boundary conditions, error paths)
- Integrate continuous monitoring into CI/CD

## Expected output

### Current metrics
| Metric | Value | Threshold | Status |
|----------|--------|-------|--------|
| Statements | | 80% | |
| Branches | | 75% | |
| Functions | | 80% | |

### Top files to improve
| File | Coverage | Gap | Priority |
|---------|------------|-----|----------|

### Action plan
1. [Tests for critical P1 files]
2. [Tests for missing P2 branches]
3. [CI/CD coverage gate]

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-test` | Generate the missing tests |
| `/dev:dev-tdd` | Develop with TDD |
| `/qa:qa-review` | Review the tests |
| `/ops:ops-ci` | Configure CI with coverage |

---

IMPORTANT: Coverage is not an end in itself. 100% coverage != 100% quality.

YOU MUST prioritize critical business code.

NEVER sacrifice test quality to reach a percentage.

Think hard about what really deserves to be tested in priority.


---

## See also

- [Back to QA commands](/docs/commands/qa)
- [All commands](/docs/commands)
