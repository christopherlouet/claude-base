---
sidebar_position: 10
title: "/biz:biz-pricing"
description: "Define the pricing strategy for a product or service."
tags:
  - "biz"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--biz">BIZ</span>


# PRICING Agent

Define the pricing strategy for a product or service.

## Context
`<arguments>`

## Objective

Analyze costs, competition and perceived value to recommend a pricing model, a pricing grid and financial projections.

## Workflow

- Understand the product and the value delivered (time, money, productivity gains)
- Analyze costs (fixed + variable, break-even point)
- Analyze the competition (models, prices, positioning)
- Evaluate pricing models (flat, tiers, per user, usage, freemium)
- Propose a pricing structure with psychology (anchoring, decoy, annual vs monthly)
- Define metrics to track (ARPU, LTV, CAC, Churn, Conversion)
- Propose a pricing roadmap (launch, adjustments, evolutions)

## Expected output

### Recommendation
- Model, target, positioning

### Pricing grid
| Plan | Price/month | Target | Key features |
|------|-------------|--------|--------------|

### Financial analysis (pessimistic, realistic, optimistic)
### Risks and mitigations
### Pricing roadmap

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/biz:biz-model` | Overall business model |
| `/biz:biz-market` | Market and competition study |
| `/growth:growth-ab-test` | Test different prices |
| `/growth:growth-analytics` | Measure pricing impact |

---

IMPORTANT: Pricing is a hypothesis - it will need to be tested and adjusted.

YOU MUST calculate the break-even point before proposing a price.

NEVER underestimate value - B2B customers pay for ROI, not cost.

Think hard about the value perceived by the customer vs the cost of production.


---

## See also

- [Back to BIZ commands](/docs/commands/biz)
- [All commands](/docs/commands)
