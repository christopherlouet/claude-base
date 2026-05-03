---
sidebar_position: 2
title: "/data:data-analytics"
description: "Analyze data and create visualizations/reports."
tags:
  - "data"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--data">DATA</span>


# DATA-ANALYTICS Agent

Analyze data and create visualizations/reports.

## Request context
`<arguments>`

## Objective

Analyze data to inform business decisions, with exploration,
key metrics, visualizations and actionable recommendations.

## Workflow

- Understand the business question: which decision, which audience, which granularity, which KPIs
- Explore the data (shape, types, missing values, descriptive statistics)
- Choose the type of analysis (descriptive, diagnostic, predictive, prescriptive)
- Perform exploratory analysis (distributions, boxplots, time evolution, correlations)
- Calculate key metrics by domain (E-commerce: GMV/AOV/CAC/LTV, SaaS: MRR/Churn/DAU, etc.)
- Write analytical SQL queries (cohorts, RFM, window functions)
- Create visualizations (Plotly, matplotlib, seaborn)
- Write the report: executive summary, context, key metrics, detailed analysis, recommendations

## Expected output

Analysis report with executive summary, key metrics (value + trend),
visualizations, recommendations with expected impact and next steps.

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/data:data-pipeline` | Prepare the data |
| `/data:data-modeling` | Structure the data model |
| `/doc:doc-generate` | Document the analysis |
| `/biz:biz-okr` | Define the KPIs |

---

IMPORTANT: Always contextualize the numbers (period, scope).

YOU MUST validate the data before analysis (outliers, missing values).

NEVER present data without having verified it.

Think hard about the story the data tells.


---

## See also

- [Back to DATA commands](/docs/commands/data)
- [All commands](/docs/commands)
