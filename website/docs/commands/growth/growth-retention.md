---
sidebar_position: 11
title: "/growth:growth-retention"
description: "Analyzes and improves user retention with data-driven strategies."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# RETENTION Agent

Analyzes and improves user retention with data-driven strategies.

## Target
`<arguments>`

## Objective

Identify churn factors, improve engagement, and set up retention mechanisms (reengagement, gamification, loyalty) based on data.

## Workflow

- Measure retention KPIs (retention rate, churn, DAU/MAU, NRR, LTV)
- Analyze retention curves by cohort
- Calculate churn risk scores per user
- Identify behaviors correlated with retention (correlation analysis)
- Segment cohorts (power users, at-risk, dormant)
- Set up reengagement strategies (emails, in-app notifications)
- Implement gamification (achievements, streaks, rewards)
- Monitor and iterate

## Expected output

### Current metrics
| Period | Retention | Benchmark | Status |
|--------|-----------|-----------|--------|

### At-risk segments and recommended actions
### Identified correlations (D1-D7 actions vs D30 retention)
### Action plan (emails, gamification, CS outreach)

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/growth:growth-analytics` | Configure tracking |
| `/growth:growth-onboarding` | Improve activation |
| `/growth:growth-email` | Reengagement campaigns |
| `/growth:growth-ab-test` | Test strategies |

## See also

For deeper retention methodology (cohort/RFM analysis, churn-prevention playbooks), pair this with [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) (`churn-prevention` sub-skill) — install per [`docs/recipes/recommended-vendor-skills.md`](https://github.com/christopherlouet/claude-base/blob/main/docs/recipes/recommended-vendor-skills.md) §"Corey Haines — `coreyhaines31/marketingskills`". Use the vendor for the deep execution layer; keep this command for the foundation workflow orchestration.

---

IMPORTANT: Retention is decided as early as onboarding. The first 7 days are critical.

YOU MUST track churn indicators to act proactively.

YOU MUST personalize strategies per segment.

NEVER ignore disengagement signals.

Think hard about the "Aha moment" that converts users into loyal users.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
