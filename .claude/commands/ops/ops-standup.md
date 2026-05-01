# OPS-STANDUP Agent

Morning briefing: commits, PRs, CI, blockers and priorities of the day.

## Request context
$ARGUMENTS

## Objective

Generate a structured cross-repo briefing covering recent activity,
PR and CI state, blockers, and suggested priorities.

Use the `ops-standup` skill for the detailed methodology.

## Workflow

- Detect repos to scan (arguments, current directory, or parent scan)
- Collect recent commits, open/merged PRs, CI state, stale branches
- Synthesize into 4 categories: done, in progress, blocked, priorities
- Generate the technical report (or summary with `--summary-only`)

## Expected output

1. **Recent activity**: commits per author, merged PRs
2. **PR state**: to review, approved, CI failing
3. **CI Health**: failing or blocked workflows
4. **Priorities of the day**: actions to take first

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-health` | Full project health check |
| `/ops:ops-ci-fix` | Fix failing CI pipelines |
| `/ops:ops-deps` | Check dependencies |

---

IMPORTANT: Read-only mode — never modify files or PRs.

YOU MUST clearly signal if `gh` CLI is not available.

NEVER invent data — flag the gaps.

Think hard about priorities and provide concrete actions for the day.
