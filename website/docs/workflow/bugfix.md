---
sidebar_position: 4
title: Bug Fix
description: Workflow to fix a bug
---

import WorkflowDiagram, { BUGFIX_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflow: Bug Fix

Guide to diagnose and fix a bug efficiently.

<WorkflowDiagram steps={BUGFIX_WORKFLOW} />

## Quick command

```bash
/work:work-flow-bugfix "Bug description"
```

## Detailed steps

### 1. Debug

```bash
/dev:dev-debug "Problem description"
```

Diagnose the bug:
- Reproduce the problem
- Identify the root cause
- Trace the execution

### 2. Fix

```bash
/dev:dev-tdd "Fix the bug"
```

Fix using TDD:
1. Write a failing test (reproduces the bug)
2. Fix the code
3. Verify that the test passes

### 3. Review

```bash
/qa:qa-review
```

Verify the fix:
- The bug is fixed
- No regression
- Regression tests added

### 4. Commit

```bash
/work:work-commit
```

Recommended format:
```
fix(scope): short description

- Fix detail
- Root cause identified

Fixes #issue-number
```

## Concrete example

```bash
# Bug: "Login fails with uppercase emails"

> /work:work-flow-bugfix "Login fails with uppercase emails"

# Claude:
# 1. Analyzes the login flow
# 2. Identifies the case-sensitive comparison
# 3. Writes a test reproducing the bug
# 4. Fixes by normalizing emails
# 5. Verifies non-regression
# 6. Creates the commit
```

## Urgent production bug

For critical bugs:

```bash
# Hotfix with GitFlow
/ops:ops-gitflow hotfix start "critical-login-bug"

# Fix...

/ops:ops-gitflow hotfix finish "critical-login-bug"
```

This automatically merges into `main` AND `develop`.

## Best practices

### DO
- ✅ Reproduce the bug before fixing
- ✅ Write a regression test
- ✅ Identify the root cause
- ✅ Document the fix

### DON'T
- ❌ Fix without understanding the cause
- ❌ Forget regression tests
- ❌ Make unrelated changes
- ❌ Fix several bugs in one commit

## Commit templates

### Simple bug
```
fix(auth): normalize email before comparison

Fixes case-sensitive email login issue

Fixes #456
```

### Bug with impact
```
fix(api): handle null response from external service

- Add null check before processing
- Add fallback default value
- Add error logging

Root cause: External API changed response format

Fixes #789
```

---

## See also

- [Debug](/docs/commands/dev/dev-debug)
- [Hotfix](/docs/commands/ops/ops-hotfix)
- [GitFlow](/docs/commands/ops/ops-gitflow)
