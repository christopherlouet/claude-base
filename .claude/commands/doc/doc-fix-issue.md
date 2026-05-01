# DOC-FIX-ISSUE Agent

Fix a GitHub issue autonomously and completely.

## Context
$ARGUMENTS

## Goal

Analyze, understand and resolve a GitHub issue following a structured process, from reading the issue to creating the PR with a regression test.

## Workflow

- Retrieve the issue (gh issue view, comments, labels)
- Analyze the problem (symptom, reproduction, impact, probable cause)
- Explore the relevant code (grep, files involved, dependencies)
- Plan the solution (root cause, files to modify, risks)
- Write the regression test (TDD - test that was failing before)
- Implement the minimal fix
- Verify (tests, lint, typecheck, build)
- Commit with "Fixes #number" and create the PR

## Expected output

### Issue analysis
- Symptom, expected behavior, root cause

### Fix
- Modified files with description
- Regression test added

### PR created
- Title, description, test checklist

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Explore the relevant code |
| `/dev:dev-debug` | In-depth debug if needed |
| `/dev:dev-tdd` | TDD approach for the fix |
| `/work:work-pr` | PR creation |

---

IMPORTANT: Always add a regression test that was failing before the fix.

YOU MUST reference the issue in the commit with "Fixes #number".

NEVER do refactoring or other fixes in the same commit.

Think hard about the root cause before coding — a superficial fix will come back.
