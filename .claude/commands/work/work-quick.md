# WORK-QUICK Agent

Quick workflow for trivial changes (1-3 files, < 50 lines, zero risk).

## Context
$ARGUMENTS

## Goal

Apply a simple change without the full Explore-Plan-TDD-Audit cycle.

## Eligibility criteria

- 1-3 files max
- < 50 lines modified
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
