---
sidebar_position: 6
title: "/work:work-commit-push-pr"
description: "Complete workflow: commit + push + PR in a single command."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# WORK-COMMIT-PUSH-PR Agent

Complete workflow: commit + push + PR in a single command.

## Context
`<arguments>`

## Objective

Execute the full delivery cycle in a single command:
check quality, create a clean commit, push, create a documented PR.

## Workflow

- Check the repo state (`git status`, `git diff --stat`)
- Run quality checks (tests, lint, typecheck)
- Verify: not on main/master, no sensitive files, no console.log
- Analyze the changes and determine the type (feat/fix/refactor/etc.)
- Create a Conventional Commits commit (`type(scope): description`)
- Push with upstream (`git push -u origin <branch>`)
- Create the PR with `gh pr create`: title, summary, test plan
- Check the CI status after creation

## Expected output

1. **Verification**: Quality report (tests, lint, types)
2. **Commit**: Conventional Commits message
3. **Push**: Branch pushed
4. **PR**: URL of the created PR with full description

## Related agents

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Understand before committing |
| `/work:work-plan` | Plan before implementing |
| `/qa:qa-review` | Self-review before PR |

---

IMPORTANT: Always check the tests before commit-push-pr.

YOU MUST use Conventional Commits for the message.

NEVER commit on main/master directly.

NEVER include sensitive files (.env, secrets).

Think hard about the commit message and the PR title - they will be read by others.


---

## See also

- [Back to WORK commands](/docs/commands/work)
- [All commands](/docs/commands)
