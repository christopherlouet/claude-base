---
sidebar_position: 3
title: "/growth:growth-analytics"
description: "Tracking setup and KPI definition for a project."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# ANALYTICS Agent

Tracking setup and KPI definition for a project.

## Context
`&lt;arguments&gt;`

## Objective

Define the North Star Metric, AARRR KPIs, events to track, and set up the analytics infrastructure in compliance with GDPR.

## Workflow

- Understand business objectives and define the North Star Metric
- Define KPIs per AARRR category (Acquisition, Activation, Retention, Revenue, Referral)
- Identify events to track (auth, onboarding, core actions, conversion, engagement)
- Choose tools (PostHog, Plausible, Sentry recommended)
- Implement the type-safe analytics wrapper (TypeScript)
- Configure dashboards and reporting frequency
- Verify GDPR compliance (consent, anonymization)

## Expected output

### North Star Metric
### KPIs per AARRR category
### Events to implement (with priority)
### Recommended analytics stack
### Implementation code (snippets)

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/growth:growth-funnel` | Analyze conversions |
| `/growth:growth-retention` | Measure retention |
| `/growth:growth-ab-test` | Test hypotheses |
| `/legal:legal-rgpd` | GDPR compliance |

---

IMPORTANT: Start simple - 5-10 key events are worth more than 100 never analyzed.

YOU MUST define a single North Star Metric aligned with business value.

NEVER track personal data without consent - respect GDPR.

Think hard about what truly drives the product's value.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
