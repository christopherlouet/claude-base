# Agent WORK-FLOW-BUGFIX

Complete workflow to fix a bug, from diagnosis to deployment.

## Context
$ARGUMENTS

## Objective

Execute the full fix cycle: branch, diagnosis, regression test,
minimal fix, verification, commit with issue reference, PR or hotfix.

## Workflow

- **ISSUE (if applicable)**: When fixing a GitHub issue, start by retrieving it (`gh issue view <n>`, comments, labels) to ground the diagnosis; the commit/PR will close it via `Fixes #<n>`
- **BRANCH**: Create branch `fix/[name]` from up-to-date main
- **DIAGNOSIS**: Reproduce the bug, isolate the problem, identify the root cause
- **TEST**: Write a failing test that proves the bug (MUST fail before the fix)
- **FIX**: Implement the minimal fix (no opportunistic refactoring)
- **VERIFY**: Run all tests, lint, typecheck, build, manual test
- **AUDIT**: Quick review for simple bugfix (`/qa:qa-review`), full audit + fix loop for critical bug (`/qa:qa-loop "score 90"`)
- **COMMIT**: Format `fix(scope): description` with cause, solution, `Fixes #issue`
- **PR/HOTFIX**: Normal PR or hotfix depending on urgency (critical prod bug = hotfix)

## Expected output

1. **Diagnosis**: Symptom, expected behavior, root cause, affected files
2. **Test**: Regression test file added
3. **Fix**: Minimal fix applied
4. **PR**: PR URL with full description (issue, cause, solution, tests)

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | In-depth diagnosis |
| `/dev:dev-tdd` | Generate regression tests |
| `/qa:qa-review` | Quick review (simple bugfix) |
| `/qa:qa-loop` | Audit + fix loop (critical bug, score 90) |
| `/ops:ops-hotfix` | Critical bug in production |
| `/work:work-commit` | Commit format |

---

IMPORTANT: Always write a test that reproduces the bug BEFORE fixing it.

YOU MUST reference the issue in the commit and the PR.

NEVER refactor in a bug fix - one fix = one bug.

Think hard about the potential side effects of the fix.
