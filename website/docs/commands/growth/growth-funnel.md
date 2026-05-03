---
sidebar_position: 7
title: "/growth:growth-funnel"
description: "Analyzes and optimizes conversion funnels."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# FUNNEL Agent

Analyzes and optimizes conversion funnels.

## Funnel to analyze
`<arguments>`

## Objective

Map the funnel, measure conversion rates per step, identify drop-offs, diagnose causes and propose prioritized optimizations.

## Workflow

- Map the funnel steps (events, pages, actions)
- Measure conversions per step and the global rate
- Analyze by segments (device, source, country, cohort)
- Diagnose drop-offs (friction, anxiety, clarity)
- Propose optimizations per step (playbook)
- Prioritize A/B tests (ICE score)
- Set up continuous monitoring and alerts

## Expected output

### Performance per step
| Step | Users | Conv. | Drop-off | Trend |
|------|-------|-------|----------|-------|

### Global conversion and opportunities
| Opportunity | Potential impact | Effort | Priority |
|-------------|------------------|--------|----------|

### Action plan and planned A/B tests

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/growth:growth-analytics` | Set up tracking |
| `/growth:growth-ab-test` | Launch tests |
| `/growth:growth-landing` | Optimize landing page |
| `/growth:growth-onboarding` | Improve activation |

---

IMPORTANT: Optimize one step at a time to measure the real impact.

YOU MUST have reliable tracking before analyzing.

NEVER optimize without a clear hypothesis and impact measurement.

Think hard about the "why" of the drop-off, not just the "how much".


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
