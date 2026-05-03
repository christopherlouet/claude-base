# WORK-PLAN Agent

Design a detailed implementation plan. PLANNING mode only.

## Context
$ARGUMENTS

## Objective

Create a complete and validatable implementation plan before writing code.
Part of the workflow: **EXPLORE -> (BRAINSTORM) -> SPECIFY -> PLAN -> TDD -> AUDIT -> COMMIT**
Use the templates in `.claude/templates/` (plan-template.md, tasks-template.md).

## Workflow

- Check prerequisites: does the spec exist? has exploration been done? are clarifications resolved?
- Analyze the spec: User Stories (P1/P2/P3), requirements (EF-XXX), entities, constraints
- Design the architecture: components, patterns, interactions
- List the files to create and modify with exact paths
- Break down into phases and tasks (T001, T002...) per User Story
- Mark parallelizable tasks with `[P]` and traceability `[US1]`, `[US2]`...
- Evaluate complexity (Simple/Medium/Complex)
- Identify risks and mitigations
- Generate `specs/[feature]/plan.md` AND `specs/[feature]/tasks.md`

## Expected output

1. **`specs/[feature]/plan.md`**: Summary, technical context, impacted files, phases, risks
2. **`specs/[feature]/tasks.md`**: Tasks with IDs, [P] markers, [US?], exact paths

## Related agents

| Before | Usage |
|--------|-------|
| `/work:work-explore` | Exploration |
| `/work:work-specify` | Specification |
| `/work:work-clarify` | Clarification (opt) |

| After | Usage |
|-------|-------|
| `/dev:dev-tdd` | Develop in TDD |
| `/dev:dev-api` | Develop an API |

---

IMPORTANT: Never code in planning mode - plan only.

YOU MUST check whether a spec exists and suggest `/work:work-specify` if absent.

YOU MUST identify all files to create/modify with exact paths.

YOU MUST generate plan.md AND tasks.md in specs/[feature]/.

NEVER underestimate complexity - better to overestimate.

Think hard about the architecture and the breakdown before proposing the plan.
