---
name: work-pr
description: Create a complete and well-documented Pull Request. Use when the user wants to create a PR, submit their changes, or prepare a merge request.
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
context: fork
disable-model-invocation: true
---

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
