---
sidebar_position: 6
title: "/dev:dev-debug"
description: "Methodical and systematic bug diagnostic and resolution."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEBUG

Methodical and systematic bug diagnostic and resolution.

## Problem to analyze
`<arguments>`

## Goal

Identify the root cause of a bug and fix it definitively,
adding protections to prevent its recurrence.

Use the `dev-debug` skill for the detailed methodology (4 phases: Observation, Hypotheses, Investigation, Verification).

## Workflow

1. **Reproduce**: Confirm, isolate, collect info (symptom, env, frequency)
2. **Analyze**: Logs, console, network, stack trace, git history
3. **Hypothesize**: Hypothesis matrix (probability + validation test)
4. **Investigate**: 5 Whys technique, git bisect for regressions
5. **Fix**: Minimal fix at the root cause
6. **Prevent**: Regression test

## Expected output

### Diagnostic
- **Symptom**: Description of the observed behavior
- **Root cause**: Identified fundamental cause
- **Impacted files**: List with descriptions
- **Culprit commit**: Hash (if found via bisect)

### Solution
- **Applied fix**: Description of the correction
- **Added test**: Regression test
- **Verification**: Bug fixed, tests pass, no side effects

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/work:work-explore` | Understand the code context |
| `/dev:dev-test` | Add regression tests |
| `/work:work-commit` | Commit the fix |

---

IMPORTANT: Never fix symptoms. Always find the root cause.

YOU MUST add a test that would have caught this bug.

YOU MUST document the root cause to prevent recurrence.

Think hard about why this bug was not detected earlier.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
