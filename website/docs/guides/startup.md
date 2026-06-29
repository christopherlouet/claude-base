---
sidebar_position: 6
title: Startup
description: Guide for entrepreneurs and SaaS
---

# Guide: Startup

Complete guide to launch and grow a product.

## Launch phases

```
Idea → Validation → MVP → Launch → Growth
```

## Commands by phase

### Phase 1: Validation

| Command | Usage |
|---------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-competitor` | Market study |
| `/biz:biz-personas` | User personas |
| `/biz:biz-competitor` | Competitive analysis |

### Phase 2: MVP

| Command | Usage |
|---------|-------|
| `/biz:biz-mvp` | MVP definition |
| `/biz:biz-pricing` | Pricing strategy |
| `/work:work-plan` | Technical plan |

### Phase 3: Launch

| Command | Usage |
|---------|-------|
| `/legal:legal-rgpd` | GDPR compliance |
| `/legal:legal-terms-of-service` | Terms of Service |
| `/legal:legal-privacy-policy` | Privacy policy |
| `/growth:growth-landing` | Landing page |
| `/growth:growth-seo` | SEO |

### Phase 4: Growth

| Command | Usage |
|---------|-------|
| `/growth:growth-analytics` | Analytics |
| `/growth:growth-cro` | Funnel optimization |
| `/growth:growth-cro` | User journey |
| `/growth:growth-email` | Email marketing |
| `/growth:growth-retention` | Retention |

## Full workflow

### 1. Validate the idea

```bash
# Create the Lean Canvas
/biz:biz-model "My project management SaaS"

# Analyze the market
/biz:biz-competitor

# Define personas
/biz:biz-personas

# Analyze competitors
/biz:biz-competitor
```

### 2. Define the MVP

```bash
# MVP scope
/biz:biz-mvp

# Pricing strategy
/biz:biz-pricing
```

### 3. Prepare the legal side

```bash
# GDPR
/legal:legal-rgpd

# Terms of Service
/legal:legal-terms-of-service

# Privacy Policy
/legal:legal-privacy-policy
```

### 4. Prepare the launch

```bash
# Landing page
/growth:growth-landing

# SEO
/growth:growth-seo

# Analytics
/growth:growth-analytics
```

### 5. Launch

```bash
# Full workflow
/work:work-flow-launch "My SaaS"
```

## Lean Canvas

```
┌─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│   PROBLEM   │  SOLUTION   │   UNIQUE    │  UNFAIR     │  CUSTOMER   │
│             │             │   VALUE     │  ADVANTAGE  │  SEGMENTS   │
│  - Prob 1   │  - Sol 1    │  PROPOSITION│             │             │
│  - Prob 2   │  - Sol 2    │             │  What can't │  - Segment 1│
│  - Prob 3   │  - Sol 3    │  Why us?    │  be copied  │  - Segment 2│
│             │             │             │             │             │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│  KEY        │             │             │             │  CHANNELS   │
│  METRICS    │             │             │             │             │
│             │             │             │             │  How to     │
│  Main KPIs  │             │             │             │  reach      │
│             │             │             │             │  customers  │
├─────────────┴─────────────┴─────────────┴─────────────┴─────────────┤
│                         COST STRUCTURE                              │
│                                                                     │
│  - Fixed costs      - Variable costs      - Burn rate              │
├─────────────────────────────────────────────────────────────────────┤
│                         REVENUE STREAMS                             │
│                                                                     │
│  - Subscriptions    - One-time      - Freemium                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Launch checklist

### Business
- [ ] Lean Canvas validated
- [ ] Personas defined
- [ ] MVP scope clear
- [ ] Pricing set

### Legal
- [ ] GDPR compliant
- [ ] Terms of Service / Terms of Sale
- [ ] Privacy Policy
- [ ] Legal notices

### Tech
- [ ] MVP working
- [ ] Automated tests
- [ ] CI/CD in place
- [ ] Active monitoring

### Growth
- [ ] Optimized landing page
- [ ] Technical SEO
- [ ] Analytics configured
- [ ] Funnel defined

### Launch
- [ ] Domain configured
- [ ] Support ready
- [ ] Communication planned

## KPIs to track

| Phase | KPIs |
|-------|------|
| Pre-launch | Waitlist signups, landing page conversion rate |
| Launch | Signups, activations, first payment |
| Growth | MRR, churn, LTV, CAC, NPS |

---

## See also

- [Business Model](/docs/commands/biz/biz-model)
- [Launch](/docs/workflow/launch)
- [Growth](/docs/commands/growth)
