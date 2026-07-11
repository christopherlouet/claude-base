# WORK-COMMIT-PUSH-PR Agent

Pointer: Claude Code ships a native `/commit-push-pr` that owns the commit + push + PR macro. This command adds the foundation's pre-flight gate and convention sources on top — it does not re-implement the macro.

## Context
$ARGUMENTS

## Workflow

1. **Pre-flight gate (foundation delta)** — before anything ships: run the quality checks
   (tests, lint, typecheck), verify not on `main`/`master`, no sensitive files
   (`.env`, secrets), no stray debug (`console.log`). Stop if anything fails.
2. **Delegate the macro to native `/commit-push-pr`** — it commits, pushes to the
   configured remote, and opens the PR. Hold it to the foundation's conventions:
   the commit message follows `/work:work-commit` (Conventional Commits, atomic),
   the PR body follows `/work:work-pr` (title, summary, test plan).
3. **Check CI status** after the PR is created.

## Expected output

1. **Verification**: quality report (tests, lint, types)
2. **PR**: URL of the created PR with full description

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-commit` | Commit conventions (message, atomicity) — source of record |
| `/work:work-pr` | PR conventions (description, test plan) — source of record |
| `/qa:qa-review` | Self-review before PR |

---

IMPORTANT: Always run the quality gate before the native macro.

NEVER commit on `main`/`master` directly, and NEVER include sensitive files (.env, secrets).
