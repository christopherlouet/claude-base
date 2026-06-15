---
sidebar_position: 2
title: "/growth:growth-ab-test"
description: "Plan and analyze an A/B test."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# GROWTH-AB-TEST Agent

Plan and analyze an A/B test.

## Context
`<arguments>`

## Objective

Define the hypothesis, calculate sample size, configure the test, and analyze the results with statistical rigor.

## Workflow

- Define the hypothesis (If [change], then [metric] [changes] by [X%], because [reason])
- Identify the metrics (primary, secondary, guardrails)
- Calculate sample size and duration (95% significance, 80% power)
- Design the test (type, variants, traffic allocation)
- Implement (feature flags, tracking)
- Verify the pre-launch checklist
- Analyze the results (p-value, confidence interval)
- Document the learnings and decide

## Expected output

### Test plan
- Hypothesis, primary metric, duration, sample, allocation
- Description of variants
- Success criteria

### Results
| Metric | Control | Treatment | Lift | p-value | Significant |
|--------|---------|-----------|------|---------|-------------|

### Decision and learnings

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/growth:growth-analytics` | Define the metrics |
| `/growth:growth-landing` | Optimize the landing pages |
| `/growth:growth-funnel` | Analyze the impact on the funnel |

## See also

For deeper A/B-test methodology (hypothesis templates, sample-size calculators, segmentation playbooks), pair this with [`coreyhaines31/marketingskills`](https://github.com/coreyhaines31/marketingskills) (`ab-testing` sub-skill) — install per [`docs/recipes/recommended-vendor-skills.md`](https://github.com/christopherlouet/claude-base/blob/main/docs/recipes/recommended-vendor-skills.md) §"Corey Haines — `coreyhaines31/marketingskills`". Use the vendor for the deep execution layer; keep this command for the foundation workflow orchestration.

---

IMPORTANT: Never stop a test prematurely based on partial results.

YOU MUST reach the calculated sample size before concluding.

NEVER test several changes at once without a multivariate design.

Think hard about what you will do with the results before launching the test.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
