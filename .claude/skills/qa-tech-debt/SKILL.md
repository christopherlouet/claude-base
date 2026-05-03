---
name: qa-tech-debt
description: Technical debt management and prioritization. Trigger when the user wants to identify, prioritize, or plan the repayment of technical debt.
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

## Workflow

1. **Identify** - Scan the codebase
2. **Categorize** - Impact and effort
3. **Prioritize** - Decision matrix
4. **Plan** - Integrate into the backlog
5. **Execute** - Incremental refactoring
6. **Validate** - Tests and metrics
