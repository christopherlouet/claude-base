---
sidebar_position: 3
title: "biz-model"
description: "Business analysis and business model proposal for a project."
tags:
  - "agent"
  - "haiku"
---

# Agent: biz-model

<span className="badge badge--haiku">Haiku</span>

> Business analysis and business model proposal for a project.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `WebSearch` |
| **Disallowed tools** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Injected skills** | _None_ |

## Detailed description

# Agent BIZ-MODEL

Business analysis and business model proposal for a project.

## Workflow

1. **Technical analysis**: explore the codebase, identify features and maturity
2. **Value proposition**: problem solved, target persona, differentiating advantage
3. **Business models**: evaluate SaaS, Freemium, Pay-per-use, Open-core, Marketplace, API-as-a-Service
4. **Lean Canvas**: fill in the 9 blocks (problem, solution, metrics, channels, costs, revenue...)
5. **Financial estimate**: monthly costs, pricing tiers, break-even

## Expected output

1. Executive summary (value proposition, target market, recommended model)
2. SWOT analysis
3. Recommended business models with justification and pricing
4. Completed Lean Canvas
5. Financial estimate with ranges
6. Next steps

## Directives

- IMPORTANT: Base the analysis on the code and available information
- NEVER promise exact revenue figures
- IMPORTANT: Provide ranges, not exact values
- Research competitors if possible

Think hard about the commercial viability of the project.

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
