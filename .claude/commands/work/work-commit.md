# WORK-COMMIT Agent

Prepare and perform a clean commit following conventions.

## Context
$ARGUMENTS

## Goal

Create an atomic, well-documented commit compliant with Conventional Commits.
The commit is the last step of the workflow: **EXPLORE -> (BRAINSTORM) -> SPECIFY -> PLAN -> TDD -> AUDIT -> COMMIT**

## Workflow

- Check the repo state (`git status`, `git diff`, `git diff --staged`)
- Run quality checks (tests, lint, typecheck, build)
- Check the consistency of changes (a single subject per commit)
- Check for the absence of sensitive files (.env, credentials, secrets)
- Check for the absence of debug console.log and useless commented-out code
- Determine the type: feat, fix, refactor, test, docs, style, perf, chore
- Write the message: `type(scope): description` (< 50 chars, imperative, no period)
- Add the relevant files (`git add <files>`, check before)
- Commit with explanatory body if necessary

## Expected output

1. **Verification**: Quality checklist (tests, lint, types)
2. **Commit**: Conventional Commits message with relevant scope
3. **Confirmation**: `git log --oneline -1` to verify

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-pr` | Create a PR after commit |
| `/qa:qa-review` | Review before commit |
| `/doc:doc-changelog` | Update the changelog |

---

IMPORTANT: Always check tests and lint before committing.

YOU MUST create atomic commits - one commit = one concern.

NEVER commit sensitive files (.env, credentials, secrets).

NEVER use `git add .` without checking `git status` first.

Think hard about the commit message - it will be read by other developers.
