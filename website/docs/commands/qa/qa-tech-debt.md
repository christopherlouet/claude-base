---
sidebar_position: 16
title: "/qa:qa-tech-debt"
description: "Identification and prioritization of technical debt in the codebase."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# QA-TECH-DEBT Agent

Identification and prioritization of technical debt in the codebase.

## Context
`&lt;arguments&gt;`

## Objective

Scan the code to identify technical debt (code, architecture, tests, documentation), prioritize it by impact/effort and propose an incremental remediation plan.

## Workflow

- Scan automatically: TODO/FIXME, any, eslint-disable, ts-ignore, long files
- Evaluate code debt (duplication, long functions, excessive nesting)
- Evaluate architectural debt (coupling, separation of concerns, obsolete patterns)
- Evaluate test debt (coverage, fragile tests, excessive mocks)
- Evaluate documentation debt (README, API, outdated comments)
- Prioritize with the Impact/Effort matrix (P0 to P4)
- Propose a remediation plan in 3 phases

## Expected output

### Debt score: [1-10]
| Category | Items | Effort |
|-----------|-------|--------|
| Code | | |
| Architecture | | |
| Tests | | |
| Documentation | | |

### Detailed debt
| Priority | Type | File:Line | Description | Effort | Impact |
|----------|------|---------------|-------------|--------|--------|

### Remediation plan
1. Phase 1 - Quick Wins (&lt; 1 sprint)
2. Phase 2 - Refactoring (1-2 sprints)
3. Phase 3 - Architecture (&gt; 2 sprints)

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Refactoring execution |
| `/qa:qa-coverage` | Test coverage analysis |
| `/qa:qa-review` | In-depth code review |
| `/work:work-plan` | Refactoring planning |

---

IMPORTANT: Never ignore security debt.

YOU MUST propose incremental refactorings.

NEVER underestimate the remediation effort.

Think hard about the business context (deadline, criticality) before prioritizing.


---

## See also

- [Back to QA commands](/docs/commands/qa)
- [All commands](/docs/commands)
