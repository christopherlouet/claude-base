---
sidebar_position: 50
title: "work-commit"
description: "Generates clear commit messages following Conventional Commits. Use when the user wants to commit, asks for a commit message, or after completing a modification."
tags:
  - "skill"
  - "fork"
---

# Skill: work-commit

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Generates clear commit messages following Conventional Commits. Use when the user wants to commit, asks for a commit message, or after completing a modification.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Bash`, `Read`, `Grep` |
| **Keywords** | `work`, `commit`, `add`, `added`, `adds` |

## Detailed description

# Commit Message Generation

## Conventional Commits Format

```
type(scope): short description (< 50 characters)

[optional body - details on the "what" and "why"]

[optional footer - issue references, breaking changes]
```

## Instructions

### 1. Analyze the changes

```bash
# View modified files
git status --short

# View detailed diff
git diff --staged

# If nothing is staged, view non-staged changes
git diff
```

### 2. Determine the type

| Type | Usage |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactoring without functional change |
| `test` | Adding or modifying tests |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `chore` | Maintenance, dependencies |
| `perf` | Performance improvement |

### 3. Identify the scope

The scope indicates the part of the code affected:
- Module name: `auth`, `api`, `ui`
- Component name: `button`, `modal`
- Feature: `login`, `checkout`

### 4. Write the description

- **Imperative present**: "add" not "added" or "adds"
- **Lowercase**: no capital at the start
- **No trailing period**
- **< 50 characters**

### 5. Commit

```bash
git add [files]
git commit -m "type(scope): description"
```

Or with body:
```bash
git commit -m "type(scope): description

- Detail 1
- Detail 2

Refs: #123"
```

## Rules

- ONE commit = ONE logical change
- Clear message for someone unfamiliar with the context
- Explain the WHY, not the HOW (the code shows the how)
- Reference issues if applicable

## Examples

### Good messages
```
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
refactor(utils): extract date formatting to separate module
test(cart): add unit tests for price calculation
docs(readme): update installation instructions
```

### Bad messages
```
❌ "fix bug"                    → Too vague
❌ "Update code"                → Not informative
❌ "WIP"                        → Don't commit WIP
❌ "feat: Add new feature..."   → Redundant
```

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to work..."_
- _"I want to commit..."_
- _"I want to add..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Commit Message Examples

# Commit Message Examples

## New feature

**Change**: Add a logout button in the header

```bash
git diff --staged
# src/components/Header.tsx | 15 ++++++
# src/services/auth.ts      |  8 +++
```

**Message**:
```
feat(auth): add logout button to header

- Add LogoutButton component
- Implement logout service method
- Clear session on logout

Refs: #234
```

---

## Bug fix

**Change**: Fix a crash when email is null

```bash
git diff --staged
# src/utils/validation.ts | 3 ++-
```

**Message**:
```
fix(validation): handle null email in validateUser

Previously crashed when email was null.
Now returns false for null/undefined inputs.

Fixes: #456
```

---

## Refactoring

**Change**: Extract pricing logic into a separate module

```bash
git diff --staged
# src/services/order.ts       | 45 --------
# src/utils/pricing.ts        | 50 +++++++++
# src/utils/pricing.test.ts   | 30 ++++++
```

**Message**:
```
refactor(pricing): extract price calculation to dedicated module

- Move calculateTotal from order service
- Add unit tests for edge cases
- No functional changes
```

---

## Tests

**Change**: Add tests for the Button component

```bash
git diff --staged
# src/components/Button.test.tsx | 45 +++++++++
```

**Message**:
```
test(ui): add unit tests for Button component

- Test all variants (primary, secondary, outline)
- Test disabled state
- Test click handler
```

---

## Documentation

**Change**: Update the README with new instructions

```bash
git diff --staged
# README.md | 25 +++++-----
```

**Message**:
```
docs(readme): update installation and usage instructions

- Add Docker setup instructions
- Update environment variables section
- Fix outdated npm commands
```

---

## Breaking Change

**Change**: Change the authentication API

```bash
git diff --staged
# src/services/auth.ts | 50 ++++++------
# src/types/auth.ts    | 20 ++---
```

**Message**:
```
feat(auth)!: change authentication to use JWT tokens

BREAKING CHANGE: The login response format has changed.

Before: { token: string, user: User }
After:  { accessToken: string, refreshToken: string, user: User }

Migration: Update all login handlers to destructure new response format.

Refs: #789
```



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
