---
sidebar_position: 12
title: "/biz:biz-roadmap"
description: "Plan and visualize the product roadmap."
tags:
  - "biz"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--biz">BIZ</span>


# ROADMAP Agent

Plan and visualize the product roadmap.

## Context
`&lt;arguments&gt;`

## Objective

Collect, prioritize and organize product initiatives in horizons (Now/Next/Later) tied to business objectives, with milestones and a communication plan.

## Workflow

- Understand the context (vision, business objectives, constraints)
- Collect initiatives (feedback, customer requests, technical debt, objectives)
- Prioritize with RICE or ICE (Reach, Impact, Confidence, Effort)
- Organize in horizons (Now 0-4 weeks, Next 1-3 months, Later 3-6 months, Future)
- Create the visual roadmap (by theme or timeline)
- Define milestones with success criteria
- Plan the communication (public vs internal)

## Expected output

### Product vision and North Star Metric
### Prioritized initiatives
| # | Initiative | Impact | Effort | Score | Horizon |
|---|------------|--------|--------|-------|---------|

### Visual roadmap (Kanban Now/Next/Later)
### Milestones with success criteria
### Dependencies and risks

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/work:work-plan` | Plan an initiative |
| `/biz:biz-okr` | Define the related OKRs |
| `/biz:biz-mvp` | Define the MVP scope |
| `/ops:ops-release` | Create a release |

---

IMPORTANT: A roadmap is a communication tool, not a firm commitment.

YOU MUST tie each initiative to a business objective.

NEVER put precise dates on a public roadmap - use horizons.

Think hard about the dependencies between initiatives and the risks.


---

## See also

- [Back to BIZ commands](/docs/commands/biz)
- [All commands](/docs/commands)
