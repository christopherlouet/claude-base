# Agent WORK-FLOW-FEATURE

Complete workflow for developing a new feature, from exploration to merge.

## Context
$ARGUMENTS

## Goal

Execute the complete development cycle of a feature:
branch, exploration, planning, TDD, audit, commit, PR.

## Workflow

- **BRANCH**: Create branch `feature/[name]` from up-to-date main
- **EXPLORE**: Analyze existing code, identify patterns and dependencies
- **PLAN**: Define files to create/modify, tests to write, risks
- **TDD**: Red-Green-Refactor cycle, tests before code, 80%+ coverage
- **AUDIT**: Adaptive audit + fix loop until score 90 (critical → `/qa:qa-loop "score 90"`, standard → `/qa:qa-loop "score 90"`, UI → `/qa:qa-design` + `/qa:wcag-audit`)
- **COMMIT**: Format `feat(scope): description`, atomic changes
- **PR**: Push + `gh pr create` with description, tests, checklist

## Expected output

1. **Feature**: Implemented code with tests
2. **Quality**: 80%+ coverage, lint OK, strict types
3. **PR**: URL with complete description and checklist

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Exploration |
| `/work:work-plan` | Planning |
| `/dev:dev-tdd` | TDD development |
| `/qa:qa-loop` | Audit + fix loop (score 90) |
| `/qa:qa-review` | Auto-review |
| `/work:work-commit` | Commit |
| `/work:work-pr` | Pull Request |

---

IMPORTANT: Each step must be validated before moving to the next.

YOU MUST follow the order of steps — do not skip exploration or planning.

NEVER commit code without tests.

Think hard at each step about the quality of the deliverable.
