---
sidebar_position: 15
title: "/ops:ops-gitflow-init"
description: "Initialize GitFlow on the repository with the appropriate branches and conventions."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# GITFLOW-INIT Agent

Initialize GitFlow on the repository with the appropriate branches and conventions.

## Request context
`&lt;arguments&gt;`

## Goal

Configure the repository to use GitFlow with main/develop branches,
branch prefixes and recommended protections.

## Workflow

- Check prerequisites (git repo, current branch, uncommitted changes)
- Create the develop branch from main if it does not exist
- Push develop to the remote
- Display a summary of available branches and commands
- Recommend protection for the main and develop branches

## Expected output

1. **Configured branches**: main (production), develop (integration)
2. **Prefixes**: feature/, release/, hotfix/
3. **Table of available** gitflow commands
4. **Recommended workflow** (feature → develop → release → main)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-gitflow-feature` | Manage feature branches |
| `/ops:ops-gitflow-release` | Manage release branches |
| `/ops:ops-gitflow-hotfix` | Manage hotfixes |

---

IMPORTANT: Check that the repo is clean before initializing.

YOU MUST create the develop branch if it does not exist.

YOU MUST display a clear summary of the available branches and commands.

NEVER force push or delete branches without confirmation.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
