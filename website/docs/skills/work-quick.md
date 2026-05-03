---
sidebar_position: 54
title: "work-quick"
description: "Quick workflow for trivial changes (single-file fix, rename, typo). Skip the full Explore-Plan-TDD-Audit cycle. Trigger when the user wants a quick fix, a simple change, or mentions \"quick\", \"fast\", \"rapid\"."
tags:
  - "skill"
  - "fork"
---

# Skill: work-quick

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Quick workflow for trivial changes (single-file fix, rename, typo). Skip the full Explore-Plan-TDD-Audit cycle. Trigger when the user wants a quick fix, a simple change, or mentions "quick", "fast", "rapid".

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `work`, `quick` |

## Detailed description

# Quick Fix Workflow

Quick mode for trivial changes that do not require the full cycle.

## Eligibility criteria

This workflow is reserved for changes that meet ALL these criteria:

| Criterion | Threshold |
|-----------|-----------|
| Files modified | 1-3 maximum |
| Lines changed | < 50 lines |
| Impact | No public API change |
| Risk | No regression risk |
| Existing tests | Already pass (or no tests concerned) |

Eligible examples: typo, variable rename, import fix, comment addition, CSS correction, version update.

NON eligible examples: new feature, refactoring, logic bug fix, interface change.

## Workflow (3 steps)

### 1. SCAN - Quick check (30 seconds)

- Read the target file
- Identify the exact change
- Verify that no existing test is impacted

### 2. FIX - Apply the change

- Modify the file(s)
- Verify the syntax (lint/typecheck if available)

### 3. VERIFY - Minimal validation

- Run the existing tests: `npm test` / `pytest` / `go test`
- If the tests pass: OK
- If the tests fail: STOP, switch to `/dev:dev-tdd`

## Expected output

```
## Quick Fix Applied

**Change**: [description]
**File(s)**: [list]
**Lines**: [+X / -Y]
**Tests**: PASS ✓

Ready for commit: `git add [files] && git commit -m "fix(scope): description"`
```

## Guardrails

- If the change exceeds the criteria → recommend `/dev:dev-tdd`
- If the tests fail → STOP and switch to the full TDD workflow
- NEVER make a public API change in quick mode
- NEVER create a new file in quick mode (except a test)

---

IMPORTANT: This mode is a shortcut, not a workaround. When in doubt, use the full workflow.

NEVER use this mode for changes that impact business logic.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to work..."_
- _"I want to quick..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
