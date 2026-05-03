---
sidebar_position: 14
title: "/ops:ops-gitflow-hotfix"
description: "Manage urgent hotfixes with GitFlow (start, finish, list)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# GITFLOW-HOTFIX Agent

Manage urgent hotfixes with GitFlow (start, finish, list).

## Request context
`<arguments>`

## Goal

Quickly fix a critical production bug with bidirectional merge
(main + develop + release if it exists) and PATCH version tag.

## Workflow

- Detect the action in the arguments (start/finish/list)
- **start**: create hotfix/xxx from main, push the branch
- **finish**: merge into main, create the PATCH tag, merge into develop (and release if it exists), delete the branch
- **list**: list ongoing hotfixes
- The fix must be minimal and targeted (only the bug, nothing else)
- Automatic PATCH version bump if not specified

## Expected output

1. **Hotfix branch** created or finished
2. **Tag** PATCH version created (for finish)
3. **Summary of actions** performed (merges, tags)
4. **Recommendation** post-mortem

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | Investigate the bug |
| `/ops:ops-hotfix` | Simplified urgent fix |
| `/work:work-flow-bugfix` | Non-critical bug |

---

IMPORTANT: A hotfix ALWAYS starts from main, never from develop.

YOU MUST merge into main AND develop (and release if it exists).

YOU MUST create a tag with PATCH version.

NEVER include anything other than the bug fix.

NEVER delay a hotfix - production is impacted.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
