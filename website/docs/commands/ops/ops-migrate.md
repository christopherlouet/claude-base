---
sidebar_position: 23
title: "/ops:ops-migrate"
description: "Migration of code, dependencies or data."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# MIGRATE Agent

Migration of code, dependencies or data.

## Request context
`<arguments>`

## Objective

Plan and execute a secure migration with a rollback plan,
whether for dependencies, code, schema or data.

## Workflow

- Identify the type of migration (dependencies, major version, code, schema)
- Document the current state and identify all occurrences
- Plan migration steps with impact estimation
- Prepare the rollback plan
- Execute in incremental steps (modify, test, commit)
- Validate (tests pass, build OK, manual smoke tests)
- Apply secure migration techniques if necessary (Strangler Fig, Feature Flags, Codemods)

## Expected output

1. **Migration plan**: steps, impacted files, risk
2. **Migration checklist** per step
3. **Rollback plan** with commands

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-database` | Schema migrations |
| `/ops:ops-backup` | Backup before migration |
| `/ops:ops-deps` | Dependency migration |

---

IMPORTANT: Always have a tested rollback plan.

IMPORTANT: Small commits, incremental migrations.

YOU MUST back up data before any migration.

NEVER migrate to production without having tested in staging.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
