---
sidebar_position: 16
title: "/ops:ops-gitflow-release"
description: "Manage release branches with GitFlow (start, finish, list)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# GITFLOW-RELEASE Agent

Manage release branches with GitFlow (start, finish, list).

## Request context
`&lt;arguments&gt;`

## Goal

Create, prepare, and finalize releases following the GitFlow workflow
with bidirectional merge (main + develop) and version tag.

## Workflow

- Detect the action in the arguments (start/finish/list)
- **start**: create release/vX.X.X from develop, push the branch
- **finish**: merge into main, create the tag, merge into develop, delete the branch
- **list**: list release branches and existing tags
- Check the prerequisites before each action (clean repo, up-to-date branches)
- Follow semantic versioning (MAJOR.MINOR.PATCH)

## Expected output

1. **Release branch** created or finished
2. **Checklist** for preparation (bump version, changelog, tests)
3. **Summary of actions** performed
4. **Next steps** (deployment, GitHub release notes)

## Related agents

| Before | Usage |
|--------|-------|
| `/ops:ops-gitflow-feature` | Finished features |
| `/doc:doc-changelog` | Generate the changelog |

| After | Usage |
|-------|-------|
| `/qa:qa-audit` | Quality audit before release |

---

IMPORTANT: A release MUST be merged into main AND develop.

YOU MUST create a tag on main after the merge.

YOU MUST backport the changes into develop.

NEVER add new features on a release branch.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
