---
sidebar_position: 52
title: "work-pr"
description: "Create a complete and well-documented Pull Request. Use when the user wants to create a PR, submit their changes, or prepare a merge request."
tags:
  - "skill"
  - "fork"
---

# Skill: work-pr

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Create a complete and well-documented Pull Request. Use when the user wants to create a PR, submit their changes, or prepare a merge request.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Bash`, `Grep`, `Glob` |
| **Keywords** | `work`, `fix bug` |

## Detailed description

# Create a Pull Request

## Objective

Create a complete, well-documented PR, ready for review.

## Instructions

### 1. Check the state

```bash
# State of changes
git status --short

# Differences with the target branch
git diff main...HEAD --stat

# Commit history
git log main...HEAD --oneline
```

### 2. Prepare the branch

```bash
# Make sure to be up to date
git fetch origin
git rebase origin/main  # or merge depending on convention

# Check the tests
npm test

# Check the lint
npm run lint
```

### 3. PR Template

```markdown
## Description

[Clear summary of what this PR does in 2-3 sentences]

## Type of change

- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Refactoring (refactor)
- [ ] Documentation (docs)
- [ ] Other: [specify]

## Changes

### Additions
- [Added file/function]

### Modifications
- [Modified file/function]

### Removals
- [Removed file/function]

## How to test

1. [Test step 1]
2. [Test step 2]
3. Check that [expected result]

## Checklist

- [ ] Code self-reviewed
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No forgotten console.log
- [ ] Lint passes
- [ ] Build passes

## Screenshots (if UI)

[Before/After if applicable]

## Related issues

Fixes #[number] (or Refs #[number])
```

### 4. Create the PR

```bash
# Push the branch
git push -u origin $(git branch --show-current)

# Create the PR with GitHub CLI
gh pr create \
  --title "type(scope): description" \
  --body "$(cat PR_BODY.md)" \
  --base main
```

## Best practices

| Do | Don't |
|-------|--------------|
| Descriptive title | "Fix bug" |
| Complete description | Empty PR |
| Small focused PRs | Giant PRs |
| Tests included | PR without tests |
| UI screenshots | Undocumented UI changes |

## Rules

- ONE PR = ONE topic
- Always include tests
- Respond to comments quickly
- Squash if history is noisy

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to work..."_
- _"I want to fix bug..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Pull Request Example

# Pull Request Example

## Context
Adding a pagination system for the product list.

## Pre-PR checks

```bash
# State
git status
# On branch feature/pagination
# nothing to commit, working tree clean

# Differences
git diff main...HEAD --stat
# src/components/ProductList.tsx  | 45 ++++++++--
# src/hooks/usePagination.ts      | 32 +++++++
# src/services/products.ts        | 15 ++-
# src/types/pagination.ts         |  8 ++
# tests/usePagination.test.ts     | 67 ++++++++++++++
# 5 files changed, 158 insertions(+), 9 deletions(-)

# Tests
npm test
# ✅ All tests passed

# Lint
npm run lint
# ✅ No errors

# Build
npm run build
# ✅ Build successful
```

## PR created

### Title
```
feat(products): add pagination to the product list
```

### PR body

```markdown
## Description

Adds a server-side pagination system for the product list,
enabling efficient handling of large catalogs (+10k products).

## Type of change

- [x] New feature (non-breaking change that adds functionality)
- [ ] Bug fix
- [ ] Breaking change
- [ ] Refactoring

## Changes

### Additions
- `src/hooks/usePagination.ts` - Reusable pagination hook
- `src/types/pagination.ts` - TypeScript types for pagination
- `tests/usePagination.test.ts` - Unit tests for the hook

### Modifications
- `src/components/ProductList.tsx` - Pagination integration
- `src/services/products.ts` - Support for page/limit parameters

## How to test

1. Start the application: `npm run dev`
2. Go to `/products`
3. Verify that:
   - The list shows 20 products per page
   - The "Previous/Next" buttons work
   - The URL updates with `?page=X`
   - The total counter is displayed

## Tests

- [x] Unit tests added (coverage: 94%)
- [x] Manual tests performed
- [ ] E2E tests (to be added in a follow-up PR)

## Checklist

- [x] My code follows the project conventions
- [x] I did a self-review of my code
- [x] Variable names are explicit
- [x] No leftover `console.log`
- [x] Tests pass locally
- [x] Build successful

## Screenshots

### Before
![List without pagination](before.png)
*Full list loaded at once (slow)*

### After
![List with pagination](after.png)
*20 products per page with navigation*

## Performance

| Metric | Before | After |
|----------|-------|-------|
| Time to First Byte | 2.3s | 0.4s |
| Largest Contentful Paint | 3.1s | 0.8s |
| Data transferred | 2.4MB | 45KB |

## Notes for reviewers

- The `usePagination` hook is generic and can be reused
  for other lists (orders, users, etc.)
- I chose 20 items per page based on UX best practices
- Pagination is server-side for performance

Fixes #234
```

### Creation command

```bash
gh pr create \
  --title "feat(products): add pagination to the product list" \
  --body-file PR_BODY.md \
  --base main \
  --head feature/pagination \
  --reviewer "@team/frontend" \
  --label "feature,frontend,needs-review" \
  --milestone "v2.1.0"
```

## Result

```
Creating pull request for feature/pagination into main

https://github.com/example/app/pull/456
```

**PR #456 created successfully.**



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
