# WORK-COMMIT-PUSH-PR Agent

Macro: commit + push + PR in a single command, by delegating to the dedicated commands.

## Context
$ARGUMENTS

## Objective

Run the full delivery cycle end to end. This command is a **thin orchestrator** — it does
not re-specify how to commit or open a PR; it chains the two commands of record and adds
the quality gate + push between them.

## Workflow

1. **Pre-flight gate** — check the repo state (`git status`, `git diff --stat`), run the
   quality checks (tests, lint, typecheck), and verify: not on `main`/`master`, no sensitive
   files (`.env`, secrets), no stray debug (`console.log`). Stop if anything fails.
2. **Commit** — delegate to `/work:work-commit` (Conventional Commits message, atomic change).
3. **Push** — `git push -u origin <branch>`.
4. **PR** — delegate to `/work:work-pr` (documented PR: title, summary, test plan), then check
   the CI status after creation.

## Expected output

1. **Verification**: quality report (tests, lint, types)
2. **PR**: URL of the created PR with full description (commit + push handled by the delegated steps)

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-commit` | Commit step (message conventions, atomicity) — source of record |
| `/work:work-pr` | PR step (description, test plan) — source of record |
| `/qa:qa-review` | Self-review before PR |

---

IMPORTANT: Always run the quality gate before commit-push-pr.

NEVER commit on `main`/`master` directly, and NEVER include sensitive files (.env, secrets).

The commit-message and PR conventions live in `/work:work-commit` and `/work:work-pr` — follow those, don't restate them here.
