---
name: qa-review
description: Perform a thorough code review. Use when the user requests a review, wants to verify code quality, or before merging a PR.
allowed-tools:
  - Read
  - Glob
  - Grep
context: fork
---

# Code Review

## Objective

Identify quality, security, and maintainability issues BEFORE merge.

## Instructions

### 1. Overview

```bash
# View the changes
git diff main...HEAD --stat
git log main...HEAD --oneline
```

### 2. Review checklist

#### Code quality
- [ ] Readability (clear names, short functions)
- [ ] DRY (no duplication)
- [ ] SOLID (single responsibility)
- [ ] Reasonable complexity
- [ ] No over-engineering (YAGNI: no speculative options/abstraction; could a stdlib/native/one-liner replace custom code?)

#### Typing (TypeScript)
- [ ] No `any`
- [ ] Explicit types on public APIs
- [ ] Well-defined interfaces

#### Tests
- [ ] Tests present and relevant
- [ ] Edge cases covered
- [ ] Mocks limited to I/O
- [ ] Substance: no hollow tests / stubs — run `./scripts/substance-check.sh <changed-files>` (flags no-assertion / always-true / skipped / empty / stub; a green suite over hollow tests is not "done")

#### Security
- [ ] Inputs validated
- [ ] No hardcoded secrets
- [ ] No injection possible

#### Performance
- [ ] No N+1 queries
- [ ] No possible infinite loops
- [ ] Memory managed correctly

### 3. Comment format

```
[TYPE] file:line - comment

Types:
- [CRITICAL] - Blocking, must be fixed
- [IMPORTANT] - Should be fixed
- [SUGGESTION] - Optional improvement
- [QUESTION] - Clarification needed
- [NITPICK] - Minor detail
```

## Expected output

```markdown
## Review: [PR Title]

### Summary
- **Files modified**: X
- **Lines added**: +Y
- **Lines removed**: -Z
- **Verdict**: Approve / Request Changes / Comment

### Positive points
- [Point 1]
- [Point 2]

### Issues identified

#### Critical
- [CRITICAL] `file.ts:42` - Description

#### Important
- [IMPORTANT] `file.ts:87` - Description

### Suggestions
- [SUGGESTION] `file.ts:123` - Description

### Final checklist
- [ ] Code readable and maintainable
- [ ] Sufficient tests
- [ ] No security issue
- [ ] Acceptable performance
```

## Naming analysis

### Naming rules to verify

| Element | Convention | Good examples | Bad examples |
|---------|-----------|---------------|------------------|
| Variables | Descriptive, camelCase | `userCount`, `isActive` | `x`, `tmp`, `data` |
| Functions | Verb + noun, camelCase | `getUserById`, `validateEmail` | `process`, `handle`, `do` |
| Booleans | Prefix is/has/can/should | `isValid`, `hasPermission` | `valid`, `permission` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` | `maxRetry` |
| Classes | PascalCase, noun | `UserService`, `OrderRepository` | `Manager`, `Helper` |
| Interfaces | PascalCase, descriptive | `UserProfile`, `PaymentMethod` | `IUser`, `DataType` |

### Naming smells to detect

| Smell | Problem | Fix |
|-------|----------|------------|
| **Generic name** | `data`, `result`, `temp`, `info` | Name based on content |
| **Abbreviation** | `usr`, `btn`, `msg`, `idx` | Write in full |
| **Double negation** | `!isNotValid`, `!disableButton` | `isValid`, `enableButton` |
| **Type in the name** | `userArray`, `nameString` | `users`, `name` |
| **Inappropriate length** | Short global variable, long local | Reverse: long global, short local |
| **Misleading name** | `getUser` that modifies | `fetchAndUpdateUser` |

### Patterns to look for

```
# Single-character variables (except i, j in loops)
\b[a-z]\b\s*[=:]

# Generic names
\b(data|result|temp|tmp|info|item|obj|val|res)\b\s*[=:]

# Booleans without prefix
\b(active|valid|visible|enabled|disabled|open|closed)\b\s*[=:]
```

## Rules

- Be constructive, not destructive
- Explain the WHY
- Propose alternatives
- Distinguish blocking vs nice-to-have
- Verify naming consistency in the code review

## See also

Anthropic ships an official **multi-agent code-review plugin** at [`anthropics/claude-plugins-official/plugins/code-review`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) (18,629★, last commit 2026-05-06). It runs 4 parallel sub-agents and applies confidence scoring (default 80%). Different format from this skill (plugin vs SKILL.md) but same intent.

When working on a project where multi-agent parallel review is preferred, install the official plugin alongside this skill. This skill captures the **review checklist + workflow conventions** (security, performance, quality, atomic feedback); the plugin handles the parallel-agent orchestration. Both can coexist.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.
