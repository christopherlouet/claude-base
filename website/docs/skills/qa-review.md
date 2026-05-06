---
sidebar_position: 42
title: "qa-review"
description: "Perform a thorough code review. Use when the user requests a review, wants to verify code quality, or before merging a PR."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-review

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Perform a thorough code review. Use when the user requests a review, wants to verify code quality, or before merging a PR.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep` |
| **Keywords** | `review` |

## Detailed description

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

#### Typing (TypeScript)
- [ ] No `any`
- [ ] Explicit types on public APIs
- [ ] Well-defined interfaces

#### Tests
- [ ] Tests present and relevant
- [ ] Edge cases covered
- [ ] Mocks limited to I/O

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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to review..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Code review example

# Code review example

## PR analyzed
**Title**: feat(auth): Add Google OAuth authentication
**Modified files**: 8 files, +245 lines, -12 lines

## Review summary

- **Modified files**: 8
- **Added lines**: +245
- **Removed lines**: -12
- **Verdict**: Request Changes

## Positive points

- Good separation of concerns (service/controller)
- Well-defined TypeScript types
- Unit tests present for the service
- Consistent error handling

## Issues identified

### Critical (blocking)

**[CRITICAL] `src/services/auth.ts:45`**
```typescript
// ❌ Issue: Secret exposed in the code
const GOOGLE_CLIENT_SECRET = "GOCSPX-xxxxx";

// ✅ Solution: Use an environment variable
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
```
> Secrets must never be hardcoded. Use environment variables.

---

**[CRITICAL] `src/controllers/auth.ts:23`**
```typescript
// ❌ Issue: No input validation
const { code } = req.body;
const tokens = await googleAuth.getTokens(code);

// ✅ Solution: Validate with Zod
const schema = z.object({ code: z.string().min(1) });
const { code } = schema.parse(req.body);
```
> Always validate user input to prevent injections.

### Important (to fix)

**[IMPORTANT] `src/services/auth.ts:67`**
```typescript
// ❌ Issue: No handling of the error case
const user = await db.user.findUnique({ where: { email } });
return user.id; // Crashes if user is null

// ✅ Solution: Handle the null case
const user = await db.user.findUnique({ where: { email } });
if (!user) {
  throw new NotFoundError(`User not found: ${email}`);
}
return user.id;
```

---

**[IMPORTANT] `src/middleware/auth.ts:15`**
```typescript
// ❌ Issue: Token stored in localStorage (XSS vulnerable)
localStorage.setItem('token', accessToken);

// ✅ Solution: Use an httpOnly cookie
res.cookie('token', accessToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict'
});
```

### Suggestions (optional)

**[SUGGESTION] `src/services/auth.ts:89`**
```typescript
// Current: Verbose logs
console.log('User authenticated:', user);
console.log('Tokens:', tokens);

// Suggestion: Structured logger
logger.info('User authenticated', { userId: user.id });
```

---

**[NITPICK] `src/types/auth.ts:5`**
```typescript
// Prefer interface for extensible objects
type AuthUser = { ... }  // ❌
interface AuthUser { ... }  // ✅
```

## Final checklist

- [ ] Code readable and maintainable
- [x] Sufficient tests
- [ ] **No security issues** ← 2 critical
- [x] Acceptable performance

## Summary for the author

Good overall implementation, but **2 critical security issues** to fix before merge:

1. Hardcoded secret → use env var
2. No input validation → add Zod

Once fixed, approved for merge.



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
