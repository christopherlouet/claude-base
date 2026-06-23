# Workflow Rules

## Workflow Choice

| Complexity | Workflow | Command |
|------------|----------|---------|
| Trivial (typo, rename, 1-3 files) | Quick | `/work:work-quick` |
| Standard (feature, bugfix) | Full | Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit |
| Batch (backlog of stories) | Batch | `/work:work-batch "prd.json"` |

## Mandatory Cycle: Explore -> (Brainstorm) -> Specify -> Plan -> TDD -> Audit -> Commit

### 0. CI BASELINE (recommended)

Before starting work on an existing project:

- Run lint, type-check and tests to know the current CI state
- Note PRE-EXISTING errors so as not to confuse them with new ones
- If CI is already failing, flag it to the user before starting

### 1. EXPLORE (mandatory)

- Read and understand the existing code BEFORE modifying
- Identify the patterns and conventions in place
- NEVER code without having explored
- Use `/work:work-explore` or the `work-explore` agent

### 2. SPECIFY (mandatory for new features)

- Define user stories and acceptance criteria (Given/When/Then) BEFORE designing
- Prioritize stories: P1 = MVP, P2, P3
- List functional requirements and edge cases
- State out-of-scope explicitly
- Use `/work:work-specify`

### 3. PLAN (mandatory for complex features)

- Propose an architecture BEFORE implementing
- List the files to create/modify
- Identify potential risks
- Wait for validation before coding
- Use `/work:work-plan`

### 4. TDD (mandatory)

- IMPORTANT: Always write tests BEFORE the code
- Mandatory Red-Green-Refactor cycle:
  1. RED: Write a test that fails
  2. GREEN: Write the minimal code to pass the test
  3. REFACTOR: Improve the code without breaking the tests (if it breaks → `/rewind` to return to the last stable state)
- Use `/dev:dev-tdd` for the full cycle
- Atomic and frequent commits
- Respect the project's conventions
- Minimum 80% coverage on new code

### 5. AUDIT (adaptive based on criticality)

Quality audit after TDD, with fix loop until the target score of 90.

| Type of change | Audit level | Command |
|----------------|-------------|---------|
| Critical (auth, payment, sensitive data) | Full audit + fix loop | `/qa:qa-loop "score 90"` |
| UI/UX feature | Design + accessibility | `/qa:qa-design` + `/qa:wcag-audit` |
| Standard feature | Review + fix loop | `/qa:qa-loop "score 90"` |
| Simple bugfix | Quick review | `/qa:qa-review` |

- IMPORTANT: Do not commit without having reached the target score (90)
- TDD validates behavior, the audit validates overall quality (security, perf, a11y)
- If the score is insufficient, fix and re-audit in a loop
- Use `/qa:qa-loop "score 90"` by default

### 6. COMMIT

- Descriptive commit message (Conventional Commits)
- Reference issues if applicable
- PR with full description
- Use `/work:work-commit` or `/work:work-pr`

## Scope Management

Sessions with too large a scope (15+ tasks) systematically generate regressions. Prefer focused sessions:

| Scope | Recommended approach |
|-------|---------------------|
| 1-5 tasks | Single session, standard workflow |
| 6-10 tasks | Split into 2-3 logical commits |
| 10-15 tasks | Split into separate sessions by domain |
| 15+ tasks | STOP — split into independent features, one PR per feature |

Warning signals:
- More than 10 files modified without an intermediate commit → commit now
- A fix introduces a regression → revert, commit what works, handle the rest separately
- The scope grows during work → stop, commit the stable state, replan

## Context Management

| Situation | Action | Command |
|-----------|--------|---------|
| Between Explore and Plan | Compact if exploration was long | `/compact` |
| Between Plan and TDD | Compact if plan is detailed | `/compact` |
| Between TDD and Audit | Compact if TDD was long | `/compact` |
| Return after a break | Recover the context | `/recap` |
| Total topic change | Clear the context | `/clear` |
| Normal session | Let auto-compaction handle it | _(nothing)_ |
| Refactoring breaks everything | Return to the last stable state | `/rewind` (or `/undo`) |

Prefer `/compact` over `/clear`: compaction keeps the essence of the context (decisions, learned conventions) whereas `/clear` erases everything. Use `/recap` after `/compact` to check what was kept.

## Anti-patterns to Avoid

- Coding without understanding the existing code
- Implementing without a validated plan
- Coding BEFORE writing the tests (violating TDD)
- Committing without an audit (skipping the Audit phase)
- Giant multi-feature commits
- Tests with too many mocks
- `any` everywhere in TypeScript
- Copy-pasting without adapting
- Optimizing prematurely
- Over-engineering: building beyond the stated requirement (speculative options, abstraction for one call site) — walk the `research` minimal-code ladder
- Ignoring lint/type warnings
- Overly ambitious sessions (15+ tasks in one session)
- Confusing pre-existing CI errors with new errors

## Recommended Workflows

### New feature
```
/work:work-flow-feature "description"
# or manually (TDD mandatory):
/work:work-explore -> /work:work-specify -> /work:work-plan -> /dev:dev-tdd -> /qa:qa-loop "score 90" -> /work:work-pr
```

### Bug fix
```
/work:work-flow-bugfix "bug description"
```

### New release
```
/work:work-flow-release "v2.0.0"
```

### Full audit
```
/qa:qa-audit  # Security + RGPD + A11y + Perf (read-only)
```

### Audit + fix loop
```
/qa:qa-loop                  # Audit + fix P0/P1 until score 90 (default)
/qa:qa-loop "score 95"       # Custom target score
```

### Safe deployment
```
/ops:ops-deploy              # Pre-deploy checklist + deploy + post-deploy
```
