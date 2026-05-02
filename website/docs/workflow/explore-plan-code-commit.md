---
sidebar_position: 2
title: Explore → Specify → Plan → TDD → Audit → Commit
description: The main claude-socle workflow with mandatory TDD
---

import WorkflowDiagram, { MAIN_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Main workflow: Explore → Specify → Plan → TDD → Audit → Commit

The fundamental workflow that guarantees quality code with mandatory TDD.

<WorkflowDiagram steps={MAIN_WORKFLOW} />

## Sequence diagram

```mermaid
sequenceDiagram
    participant U as User
    participant C as Claude
    participant R as Repository

    Note over U,R: Phase 1 - EXPLORE
    U->>C: /work:work-explore "auth system"
    C->>R: Read files
    R-->>C: Source code
    C-->>U: Analyze structure and patterns

    Note over U,R: Phase 2 - SPECIFY (optional)
    U->>C: /work:work-specify "Add 2FA"
    C-->>U: Functional specification
    U->>C: Validation ✓

    Note over U,R: Phase 3 - PLAN
    U->>C: /work:work-plan
    C-->>U: Implementation plan
    U->>C: Validation ✓

    Note over U,R: Phase 4 - TDD (mandatory)
    U->>C: /dev:dev-tdd
    loop Red-Green-Refactor cycle
        C->>R: RED: Write failing test
        C->>R: GREEN: Minimal code to pass
        C->>R: REFACTOR: Improvement
    end

    Note over U,R: Phase 5 - COMMIT
    U->>C: /work:work-commit
    C->>R: git add + commit
    R-->>U: Commit created ✓
```

## Why this workflow?

### Without a structured workflow

```
❌ Coding without understanding → Bugs and regressions
❌ Implementing without a plan → Constant refactoring
❌ Coding before tests → Untested code
❌ Giant commits → Unreadable history
```

### With the workflow

```
✅ Explore first → Understand the context
✅ Plan ahead → Solid architecture
✅ Mandatory TDD → Tested and reliable code
✅ Atomic commits → Clear history
```

## Step 1: Explore

**Command**: `/work:work-explore`

**Goal**: Understand the existing code before modifying.

```bash
/work:work-explore

# Or with a specific focus
/work:work-explore "the authentication system"
```

**Claude will analyze**:
- Project structure
- Patterns and conventions
- Dependencies
- Points of attention

**Expected output**:
```markdown
## Project analysis

### Structure
- /src/auth/ - Authentication module
- /src/api/ - REST endpoints

### Identified patterns
- Repository pattern
- Dependency injection

### Points of attention
- Missing tests on AuthService
```

## Step 2: Plan

**Command**: `/work:work-plan`

**Goal**: Plan changes before implementing.

```bash
/work:work-plan "Add 2FA authentication"
```

**Claude will propose**:
- Recommended architecture
- Files to create/modify
- Identified risks
- Tests to write

**Expected output**:
```markdown
## Implementation plan

### Files to create
- src/auth/two-factor.service.ts
- src/auth/two-factor.controller.ts

### Files to modify
- src/auth/auth.module.ts

### Risks
- Impact on existing login

### Required tests
- test/two-factor.spec.ts
```

:::caution Important
Wait for plan validation before coding!
:::

## Step 3: TDD (Mandatory)

**Command**: `/dev:dev-tdd`

**Goal**: Implement following the Red-Green-Refactor cycle.

```bash
/dev:dev-tdd "Implement the 2FA service"
```

**Mandatory TDD cycle**:
1. **RED**: Write a failing test
2. **GREEN**: Write the minimal code to pass the test
3. **REFACTOR**: Improve the code without breaking the tests

**Best practices**:
- Always write tests BEFORE the code
- Follow the plan strictly
- One commit per logical change
- Minimum 80% coverage on new code

## Step 4: Commit

**Command**: `/work:work-commit` or `/work:work-pr`

**Goal**: Create clean and descriptive commits.

```bash
# Simple commit
/work:work-commit

# Or full Pull Request
/work:work-pr
```

**Commit format**:
```
type(scope): description

[optional body]

[optional footer]
```

**Example**:
```
feat(auth): add two-factor authentication

- Add TwoFactorService with TOTP support
- Add verification endpoint
- Add tests for 2FA flow

Closes #123
```

## Full example

```bash
# 1. Explore the existing auth code
> /work:work-explore "authentication system"

# Claude analyzes and explains the structure

# 2. Plan the 2FA addition
> /work:work-plan "Add 2FA authentication"

# Claude proposes a detailed plan
# You validate or request changes

# 3. Implement in TDD (mandatory)
> /dev:dev-tdd "Implement the 2FA service per the plan"

# Claude follows the Red-Green-Refactor cycle:
# - RED: Writes failing tests
# - GREEN: Writes minimal code to pass
# - REFACTOR: Improves the code

# 4. Create the PR
> /work:work-pr

# Claude creates a complete PR with description
```

## Shortcut: Full workflow

For a new feature, use directly:

```bash
/work:work-flow-feature "Add 2FA authentication"
```

This command automatically chains the full workflow.

---

## See also

- [New Feature](/docs/workflow/feature) - Full feature workflow
- [TDD](/docs/workflow/tdd) - Test-driven development
- [WORK Commands](/docs/commands/work) - All workflow commands
