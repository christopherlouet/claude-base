---
name: qa-tech-debt
description: Technical debt management and prioritization, including test-coverage analysis and Kaizen continuous improvement. Trigger when the user wants to identify, prioritize or plan the repayment of technical debt, analyse/improve test coverage, or run a PDCA continuous-improvement cycle.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
---

# Tech Debt Management

## Triggers

- "technical debt"
- "tech debt"
- "refactoring priority"
- "legacy code"
- "code quality"

## Identification

### Code Smells to Detect

```bash
# TODOs and FIXMEs
grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" src/

# Large files
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -n | tail -20

# Complexity (nesting)
grep -r "if.*if.*if" --include="*.ts" src/

# any in TypeScript
grep -r ": any" --include="*.ts" --include="*.tsx" src/
```

### Metrics

| Metric | Threshold | Command |
|----------|-------|----------|
| LOC/file | < 500 | `wc -l` |
| Functions/file | < 15 | grep |
| Nesting depth | < 4 | analysis |
| Test coverage | > 70% | `npm test -- --coverage` |

## Categorization

### Impact

| Level | Description | Examples |
|--------|-------------|----------|
| Critical | Blocks development | Circular coupling |
| High | Significantly slows down | Massive duplication |
| Medium | Hinders maintenance | Confusing naming |
| Low | Cosmetic | Inconsistent style |

### Effort

| Level | Time | Examples |
|--------|-------|----------|
| Trivial | < 1h | Rename variable |
| Low | < 1 day | Extract function |
| Medium | 1-5 days | Restructure module |
| High | > 1 week | Rewrite component |

## Prioritization

### Impact/Effort Matrix

```
Impact
  ^
  |  Quick Wins  |  Strategic
  |     (P1)     |    (P2)
  +--------------+-------------
  |   Fill-in    |   Avoid
  |     (P3)     |    (P4)
  +-------------------------> Effort
```

## Remediation Plan

### Template

```markdown
## Item: [Name]

**Priority**: P[1-4]
**Impact**: [Critical/High/Medium/Low]
**Effort**: [Trivial/Low/Medium/High]

### Description
[Description of the problem]

### Files concerned
- path/to/file.ts:L42

### Proposed solution
[Refactoring approach]

### Success criteria
- [ ] Tests pass
- [ ] No regression
- [ ] Improved metrics
```

## Test coverage analysis

Test debt is a first-class category of technical debt. Measure and close the gaps.

```bash
# Current coverage (statements / branches / functions / lines)
npm test -- --coverage          # Jest / Vitest
```

| Metric | Threshold | Notes |
|--------|-----------|-------|
| Statements | > 80% | |
| Branches | > 75% | Hardest and highest-value gap |
| Functions | > 80% | |

- Categorise gaps by criticality (business code and edge cases first), not by raw %.
- Prioritise critical business code; 100% coverage != 100% quality — never sacrifice test
  quality to hit a number.
- Add missing tests for branches, boundary conditions and error paths; wire a coverage
  gate into CI (`/ops:ops-ci`). Generate the tests via `/dev:dev-tdd` or `/dev:dev-tdd`.

## Continuous improvement (Kaizen)

For incremental, durable improvement of code and process, run the PDCA cycle instead of a
big-bang rewrite.

- **PLAN**: identify the problem and root cause (5 Whys), set a SMART objective.
- **DO**: implement one change at a time, atomic commits.
- **CHECK**: measure before/after, compare to the objective.
- **ACT**: standardise on success, adjust on failure; plan the next iteration.
- Eliminate the 7 Muda (overproduction, waiting, transport, over-processing, inventory,
  motion, defects). Always measure before and after; one change at a time, no revolutions.

## Workflow

1. **Identify** - Scan the codebase (smells, coverage gaps, Muda)
2. **Categorize** - Impact and effort
3. **Prioritize** - Decision matrix
4. **Plan** - Integrate into the backlog
5. **Execute** - Incremental refactoring (one change at a time, PDCA)
6. **Validate** - Tests, coverage and metrics (before/after)
