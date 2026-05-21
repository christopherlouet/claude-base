---
sidebar_position: 26
title: "growth-cro"
description: "Conversion rate audit and optimization."
tags:
  - "agent"
  - "haiku"
---

# Agent: growth-cro

<span className="badge badge--haiku">Haiku</span>

> Conversion rate audit and optimization.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | `["Edit"`, `"Write"`, `"Bash"]` |
| **Injected skills** | _None_ |

## Detailed description

# Agent GROWTH-CRO

Conversion rate audit and optimization.

## Objective

Analyze and optimize conversions:
- Landing pages
- Signup forms
- Onboarding flows
- Checkouts and payments
- Popups and modals
- Paywalls and upgrades

## Analysis areas

| Area | Key metrics |
|------|-------------|
| Landing | Bounce rate, scroll depth, CTA clicks |
| Signup | Form completion, drop-off fields |
| Onboarding | Activation rate, time to value |
| Forms | Error rate, abandonment rate |
| Popups | Display-to-close ratio, conversion |
| Paywall | Trial-to-paid, upgrade rate |

## Methodology

1. Identify the main funnel
2. Locate friction points
3. Score each step (heuristic)
4. Prioritize quick wins
5. Propose A/B tests

## Expected output

- Funnel mapping with conversion rates
- Identified and prioritized friction points
- Implementable quick wins
- Recommended A/B test plan

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
