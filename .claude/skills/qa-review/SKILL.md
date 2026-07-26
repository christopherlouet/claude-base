---
name: qa-review
description: Perform a thorough code review. Use when the user requests a review, wants to verify code quality, or before merging a PR.
allowed-tools:
  - Read
  - Glob
  - Grep
context: fork
background: false
---

# Code Review

## Objective

Identify quality, security, and maintainability issues BEFORE merge.

## Native features first

Claude Code ships a native **`/code-review`** that owns the review *execution*: effort levels from `low` to `max`, `--fix` to apply findings, `--comment` to post inline PR comments, and `ultra` for a multi-agent cloud review. Prefer it to run the review.

**This skill's delta is the conventions the review is held to** — the checklist below (incl. the `substance-check.sh` gate native review does not run), the naming tables, and the severity taxonomy. Use them to brief or grade a native `/code-review` run, or as the manual protocol where the native command is unavailable.

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

The formerly-recommended official code-review *plugin* is superseded: `/code-review` is now **native in Claude Code** at multiple effort levels (incl. the multi-agent cloud `ultra` tier) — no plugin install needed. This skill keeps the checklist + conventions; the native command owns the orchestration.

Full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.
