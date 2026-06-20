# QA-TECH-DEBT Agent

Identification and prioritization of technical debt in the codebase.

## Context
$ARGUMENTS

## Objective

Scan the code to identify technical debt (code, architecture, tests, documentation), prioritize it by impact/effort and propose an incremental remediation plan. Covers test-coverage analysis and the Kaizen (PDCA) continuous-improvement angle — see the `qa-tech-debt` skill.

## Workflow

- Scan automatically: TODO/FIXME, any, eslint-disable, ts-ignore, long files
- Evaluate code debt (duplication, long functions, excessive nesting)
- Evaluate architectural debt (coupling, separation of concerns, obsolete patterns)
- Evaluate test debt: measure coverage (statements/branches/functions), categorize gaps by criticality, propose a CI coverage gate
- Evaluate documentation debt (README, API, outdated comments)
- Prioritize with the Impact/Effort matrix (P0 to P4)
- Propose a remediation plan in 3 phases; for incremental fixes, run the PDCA/Kaizen cycle (one change at a time, measure before/after)

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
1. Phase 1 - Quick Wins (< 1 sprint)
2. Phase 2 - Refactoring (1-2 sprints)
3. Phase 3 - Architecture (> 2 sprints)

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Refactoring execution |
| `/dev:dev-tdd` | Generate the missing tests (coverage gaps) |
| `/qa:qa-review` | In-depth code review |
| `/work:work-plan` | Refactoring planning |

---

IMPORTANT: Never ignore security debt.

YOU MUST propose incremental refactorings.

NEVER underestimate the remediation effort.

Think hard about the business context (deadline, criticality) before prioritizing.
