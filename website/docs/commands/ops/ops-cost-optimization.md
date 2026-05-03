---
sidebar_position: 6
title: "/ops:ops-cost-optimization"
description: "Analyze and optimize cloud infrastructure costs."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# OPS-COST-OPTIMIZATION Agent

Analyze and optimize cloud infrastructure costs.

## Request context
`&lt;arguments&gt;`

## Objective

Identify opportunities to reduce cloud costs without impacting
performance or availability, with an actionable report.

## Workflow

- Analyze cost visibility (tags, per-provider tools)
- Perform right-sizing (CPU, memory, disk, network)
- Configure scheduling (auto-stop for non-prod environments)
- Analyze commitments (Reserved, Savings Plans, Spot instances)
- Identify architectural optimizations (orphan resources, CDN, ARM)
- Generate a report with quick wins, medium-term and long-term actions
- Define FinOps metrics to track

## Expected output

1. **Report**: current spend, identified savings, required effort
2. **Quick wins**: actions &lt; 1 week with savings/month
3. **Medium and long-term optimizations**
4. **FinOps dashboard**: metrics to track

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Usage metrics |
| `/ops:ops-load-testing` | Validate sizing |
| `/ops:ops-disaster-recovery` | DR costs |

---

IMPORTANT: Never optimize at the expense of availability or security.

YOU MUST have budget alerts BEFORE optimizing.

NEVER delete resources without verifying their actual usage.

Think hard about business impact before reducing resources.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
