---
sidebar_position: 3
title: New Feature
description: Workflow to add a new feature
---

import WorkflowDiagram, { FEATURE_WORKFLOW } from '@site/src/components/WorkflowDiagram';

# Workflow: New Feature

Complete guide to add a new feature.

<WorkflowDiagram steps={FEATURE_WORKFLOW} />

## Quick command

```bash
/work:work-flow-feature "Feature description"
```

This command automatically launches the complete workflow.

## Detailed steps

### 1. Explore

```bash
/work:work-explore
```

Understand the existing code and identify:
- Where to add the feature
- The patterns to follow
- The potential impacts

### 2. Specify (optional)

```bash
/work:work-specify "Feature description"
```

Create a formal specification if the feature is complex:
- User stories
- Acceptance criteria
- Edge cases

### 3. Plan

```bash
/work:work-plan
```

Plan the implementation:
- Files to create
- Files to modify
- Required tests
- Identified risks

### 4. Code

```bash
/dev:dev-tdd "Implement the feature"
```

Develop with TDD:
1. Write the tests
2. Implement the code
3. Refactor if necessary

### 5. Review

```bash
/qa:qa-review
```

Verify the quality:
- Clean code
- Complete tests
- Up-to-date documentation

### 6. PR

```bash
/work:work-pr
```

Create a Pull Request:
- Descriptive title
- Complete description
- Test checklist

## Concrete example

```bash
# Add a notification system

> /work:work-flow-feature "Add a push notification system"

# Claude chains automatically:
# 1. Explores the existing code
# 2. Proposes a specification
# 3. Plans the implementation
# 4. Implements with TDD
# 5. Reviews the code
# 6. Creates the PR
```

## Best practices

### DO
- ✅ Always explore before coding
- ✅ Validate the plan before implementation
- ✅ Tests at every step
- ✅ Atomic commits

### DON'T
- ❌ Code without a validated plan
- ❌ Giant multi-feature commits
- ❌ Ignore tests
- ❌ Force the PR without review

## GitFlow Integration

With GitFlow enabled:

```bash
# Create the feature branch
/ops:ops-gitflow-feature start "notification-system"

# Develop...

# Finish the feature
/ops:ops-gitflow-feature finish "notification-system"
```

---

## See also

- [Main workflow](/docs/workflow/explore-plan-code-commit)
- [TDD](/docs/workflow/tdd)
- [GitFlow Feature](/docs/commands/ops/ops-gitflow-feature)
