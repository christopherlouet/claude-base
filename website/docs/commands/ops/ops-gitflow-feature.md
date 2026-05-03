---
sidebar_position: 13
title: "/ops:ops-gitflow-feature"
description: "Manage feature branches with GitFlow (start, finish, list, publish, pull)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# GITFLOW-FEATURE Agent

Manage feature branches with GitFlow (start, finish, list, publish, pull).

## Request context
`<arguments>`

## Objective

Create, develop and finalize feature branches following the GitFlow workflow,
with merge --no-ff into develop to preserve history.

## Workflow

- Detect the action in the arguments (start/finish/list/publish/pull)
- **start**: create feature/xxx from up-to-date develop, push the branch
- **finish**: merge --no-ff into develop, delete the local and remote branch
- **list**: list ongoing feature branches
- **publish**: push the feature branch to the remote
- **pull**: fetch a remote feature branch
- Check prerequisites (develop up-to-date, no uncommitted changes)
- Use kebab-case for branch naming

## Expected output

1. **Feature branch** created, finished or listed
2. **Summary of commits** merged (for finish)
3. **Suggested next steps**

## Related agents

| Before | Usage |
|--------|-------|
| `/ops:ops-gitflow-init` | Initialize GitFlow |

| After | Usage |
|-------|-------|
| `/ops:ops-gitflow-release` | Prepare a release |
| `/work:work-commit` | Commit cleanly |

---

IMPORTANT: Always start from develop to create a feature.

YOU MUST use --no-ff for the merge to preserve history.

NEVER delete a feature branch without having merged the changes.

NEVER force push to develop.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
