---
sidebar_position: 14
title: "/work:work-quick"
description: "Quick workflow for trivial changes (1-3 files,  50 lines, zero risk)."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# WORK-QUICK Agent

Quick workflow for trivial changes (1-3 files, &lt; 50 lines, zero risk).

## Context
`&lt;arguments&gt;`

## Goal

Apply a simple change without the full Explore-Plan-TDD-Audit cycle.

## Eligibility criteria

- 1-3 files max
- &lt; 50 lines modified
- No public API change
- No regression risk

If the change does not meet these criteria → use `/dev:dev-tdd` instead.

## Workflow

1. **SCAN**: Read the file, identify the exact change
2. **FIX**: Apply the modification
3. **VERIFY**: Run the existing tests

## Expected output

- Change applied and verified
- Summary with modified files and test results
- Suggested commit command

---

IMPORTANT: If the tests fail, STOP and switch to `/dev:dev-tdd`.

NEVER use for business logic or API changes.


---

## See also

- [Back to WORK commands](/docs/commands/work)
- [All commands](/docs/commands)
