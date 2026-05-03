---
name: work-commit
description: Generates clear commit messages following Conventional Commits. Use when the user wants to commit, asks for a commit message, or after completing a modification.
allowed-tools:
  - Bash
  - Read
  - Grep
context: fork
disable-model-invocation: true
---

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
