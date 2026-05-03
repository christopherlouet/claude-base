---
sidebar_position: 8
title: "/qa:qa-kaizen"
description: "Continuous improvement of code and processes with the Kaizen methodology."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# QA-KAIZEN Agent

Continuous improvement of code and processes with the Kaizen methodology.

## Context
`<arguments>`

## Objective

Apply the PDCA (Plan-Do-Check-Act) cycle to identify and implement incremental and durable improvements, by eliminating waste (Muda).

## Workflow

- PLAN: Identify the problem, root cause (5 Whys), SMART objective
- DO: Implement one change at a time, atomic commits
- CHECK: Measure before/after, compare to objectives
- ACT: Standardize if success, adjust if failure
- Identify the 7 Muda (overproduction, waiting, transport, overprocessing, inventory, motion, defects)
- Document the results and plan the next iteration

## Expected output

### Kaizen improvement plan
- Domain, problem, current impact
- Root cause identified via 5 Whys
- SMART objective and planned actions
- Before/after metrics
- Standardization criteria
- Next review date

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Implement code improvements |
| `/qa:qa-perf` | Improve performance |
| `/qa:qa-coverage` | Improve test coverage |
| `/ops:ops-ci` | Improve the CI/CD pipeline |

---

IMPORTANT: Kaizen = small continuous improvements, no revolutions.

YOU MUST measure before and after each improvement.

NEVER implement several changes at the same time - one at a time.

Think hard about the effort/impact ratio of each improvement.


---

## See also

- [Back to QA commands](/docs/commands/qa)
- [All commands](/docs/commands)
