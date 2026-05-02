---
name: work-plan
description: Plan the implementation of a feature. Use when the user wants to plan, architect, define an approach, or before coding a complex feature.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
disable-model-invocation: true
---

# Plan an Implementation

## Objective

Define an action plan BEFORE coding. The plan must be validated before implementation.

## Instructions

### 1. Understand the request

**Questions to clarify:**
- What is the business objective?
- What are the acceptance criteria?
- Are there any technical constraints?
- What is the priority/deadline?

### 2. Analyze the existing code

```bash
# Search for similar code
grep -rn "similar_pattern" --include="*.ts" | head -20

# Identify dependencies
cat package.json | grep -A 20 '"dependencies"'
```

### 3. Define the architecture

**Decisions to make:**
- Where to place the new code?
- Which patterns to use?
- Which interfaces to create?
- How to handle errors?

### 4. List the tasks

Break down into atomic tasks of 1-2h max.

## Plan template

```markdown
## Plan: [Feature name]

### Objective
[Description in 1-2 sentences]

### Files to create
| File | Description |
|---------|-------------|
| `src/xxx.ts` | [Role] |

### Files to modify
| File | Modifications |
|---------|---------------|
| `src/yyy.ts` | [Changes] |

### Tests to write
- [ ] Nominal case test
- [ ] Edge cases test
- [ ] Error test

### Implementation steps
1. [ ] [Task 1]
2. [ ] [Task 2]
3. [ ] [Task 3]

### Identified risks
| Risk | Mitigation |
|--------|------------|
| [Risk 1] | [Solution] |

### Dependencies
- [ ] [Prerequisite 1]
```

## Rules

- NEVER code without a validated plan
- One plan = one feature
- Estimate complexity, not time
- Identify risks BEFORE
