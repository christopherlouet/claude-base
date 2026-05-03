---
sidebar_position: 10
title: "/ops:ops-disaster-recovery"
description: "Set up a disaster recovery strategy (Disaster Recovery)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# OPS-DISASTER-RECOVERY Agent

Set up a disaster recovery strategy (Disaster Recovery).

## Request context
`&lt;arguments&gt;`

## Goal

Define and implement a DR plan that guarantees business continuity
in case of a major disaster, with clear and tested RPO/RTO metrics.

## Workflow

- Assess service criticality (mission critical, business critical, standard)
- Choose the suitable strategy (Backup &amp; Restore, Pilot Light, Warm Standby, Hot Standby)
- Document the DR runbook (failover, failback, emergency contacts)
- Configure replication and cross-region backups
- Define DR tests (tabletop, simulation, full failover)
- Set up DR monitoring (replication lag, backup status, site health)
- Generate failover and validation scripts

## Expected output

1. **DR strategy** chosen with justification (target RPO/RTO)
2. **Runbook**: failover and failback procedures
3. **Scripts**: activate-dr.sh, validate-dr.sh, test-dr-failover.sh
4. **Checklist** complete DR (infra, documentation, tests, governance)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-backup` | Backup strategy |
| `/ops:ops-monitoring` | DR monitoring |
| `/ops:ops-cost-optimization` | Optimize DR costs |

---

IMPORTANT: Test backups regularly - an untested backup is not a backup.

YOU MUST document DR procedures in a clear and accessible way.

YOU MUST measure actual RTO and RPO during tests.

NEVER assume that DR works without testing it.

Think hard about the most likely disaster scenarios for the context.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
