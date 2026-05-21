---
sidebar_position: 25
title: "growth-cro"
description: "Conversion rate optimization (CRO). Trigger when the user wants to optimize conversions, improve a signup form, a checkout, a landing page, or an onboarding."
tags:
  - "skill"
  - "fork"
---

# Skill: growth-cro

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Conversion rate optimization (CRO). Trigger when the user wants to optimize conversions, improve a signup form, a checkout, a landing page, or an onboarding.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep`, `Edit`, `Write` |
| **Keywords** | `growth`, `cro`, `how`, `connect your github repo`, `create your first project`, `start from a template`, `create account` |

## Detailed description

# Conversion Rate Optimization (CRO)

## Goal

Identify and fix friction points in user journeys to maximize the conversion rate.

## CRO Domains

```
┌──────────────────────────────────────────────────────────────────┐
│                    CRO FRAMEWORK                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PAGE CRO           Optimize marketing/landing pages             │
│  ═════════                                                        │
│                                                                   │
│  SIGNUP FLOW CRO    Improve signup and account creation          │
│  ══════════════                                                   │
│                                                                   │
│  ONBOARDING CRO     Reduce time-to-value post-signup             │
│  ═════════════                                                    │
│                                                                   │
│  FORM CRO           Optimize capture forms                        │
│  ════════                                                         │
│                                                                   │
│  POPUP CRO          Improve popups, modals, overlays             │
│  ═════════                                                        │
│                                                                   │
│  PAYWALL CRO        Optimize paywalls and upsells                │
│  ═══════════                                                      │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Page CRO

### Landing page checklist

| # | Element | Best practices |
|---|---------|-----------------|
| 1 | **Headline** | Clear benefit in < 10 words, no jargon |
| 2 | **Sub-headline** | Explain the "how" in 1 sentence |
| 3 | **Primary CTA** | Specific action, visible above-the-fold |
| 4 | **Social proof** | Testimonials, customer logos, numbers |
| 5 | **Objections** | FAQ or sections answering doubts |
| 6 | **Urgency/Scarcity** | Timer, limited spots (if authentic) |
| 7 | **Hero visual** | Product screenshot or demo video |
| 8 | **Navigation** | Minimal (no full menu on landing) |

### Conversion patterns

```
Hero section (benefit + CTA)
    ↓
Social proof (logos, testimonials)
    ↓
Features/Benefits (3-5 max)
    ↓
How it works (3 steps)
    ↓
Pricing (if applicable)
    ↓
FAQ (common objections)
    ↓
Final CTA (same action as the hero)
```

## 2. Signup Flow CRO

### Golden rules

| # | Rule | Impact |
|---|-------|--------|
| 1 | Minimum fields (email only to start) | +20-30% signups |
| 2 | Social login (Google, GitHub) | +15-25% signups |
| 3 | No blocking email confirmation | -40% drop-off |
| 4 | Progress indicator if multi-step | +10% completion |
| 5 | Value proposition visible next to the form | +15% signups |
| 6 | Password strength indicator | +5% completion |
| 7 | Inline error, not at submit | +20% completion |

### Anti-patterns to avoid

- Asking for too much info at signup (name, phone, address)
- CAPTCHA visible for all users
- Confirmation email before product access
- Redirect to login page after signup
- No feedback after form submission

## 3. Onboarding CRO

### Time-to-Value framework

```
Signup → [Activation] → [Aha Moment] → [Habit Formation]
           |                |                |
           v                v                v
    First setup        First value        Regular usage
    (< 2 min)          (< 5 min)         (Day 7+)
```

### Effective patterns

| Pattern | When | Example |
|---------|-------|---------|
| **Checklist** | 3-5 activation steps | "Complete your profile: 3/5" |
| **Wizard** | Technical setup required | "Connect your GitHub repo" |
| **Empty state** | First visit, empty page | "Create your first project" |
| **Template** | Complex product | "Start from a template" |
| **Tour guide** | Complex interface | Discovery tooltips |

## 4. Form CRO

### Form optimization

| # | Technique | Detail |
|---|-----------|--------|
| 1 | One field per line | No multi-column layout on mobile |
| 2 | Labels above fields | No floating labels |
| 3 | Correct input type | `email`, `tel`, `number` for adapted keyboard |
| 4 | HTML autocomplete | `autocomplete="email"`, `"given-name"` |
| 5 | Font size >= 16px | Avoids iOS zoom |
| 6 | Descriptive submit button | "Create account" not "Submit" |
| 7 | Immediate feedback | Validate on blur, not at submit |
| 8 | Easy error recovery | Message + focus on the field in error |

## 5. Popup/Modal CRO

### Rules

| # | Rule | Detail |
|---|-------|--------|
| 1 | Timing: not before 30s or 50% scroll | Let users discover the content |
| 2 | Exit-intent > time-based | Less intrusive |
| 3 | Easy to close | Visible X, click outside, Escape |
| 4 | One popup at a time | No stack of modals |
| 5 | Limited frequency | Max 1x per session or 1x per week |
| 6 | Clear value proposition | Not just "Subscribe" |
| 7 | Mobile: bottom sheet > centered modal | Better mobile UX |

## 6. Paywall/Upgrade CRO

### Strategies

| Strategy | Detail | When |
|----------|--------|-------|
| **Feature gate** | Show the feature, block access | Premium feature requested |
| **Usage limit** | "3/5 projects used" | Free tier limit approached |
| **Trial expiration** | Countdown + demonstrated value | End of trial |
| **Upgrade prompt** | Contextual suggestion | Premium action attempted |
| **Social proof** | "Join 10,000+ teams" | Pricing page |

### Pricing page patterns

```
[ Free ]        [ Pro ★ ]        [ Enterprise ]
  $0              $29/mo           Custom
  3 projects      Unlimited        Unlimited
  1 user          10 users         Unlimited
  Basic support   Priority         Dedicated
                 [Start trial]
```

- Highlight the recommended plan (badge, color)
- Monthly/annual toggle (show the savings)
- Feature comparison table below
- FAQ on billing

## Metrics to track

| Metric | Formula | Target |
|----------|---------|-------|
| **Conversion rate** | Conversions / Visitors | Depends on the domain |
| **Drop-off rate** | Drop-offs per funnel step | < 20% per step |
| **Time to convert** | Visit duration → conversion | Reduce |
| **Bounce rate** | Bounces / Sessions | < 40% landing pages |
| **Activation rate** | Activated users / Signups | > 40% |
| **Trial-to-paid** | Payments / Trials | > 15% |

## Expected output

```markdown
## CRO Audit: [Page/Flow]

### Current estimated conversion rate: X%
### Improvement potential: +Y%

### Quick wins (immediate impact)
1. [Action] - Estimated impact: +X%
2. [Action] - Estimated impact: +X%

### Structural improvements
1. [Action] - Detail and implementation

### Recommended A/B tests
1. [Hypothesis] - Variant A vs B
```

## Rules

- Always base recommendations on data or proven best practices
- Propose quick wins AND structural changes
- Do not sacrifice UX for conversion (dark patterns forbidden)
- Suggest A/B tests to validate important changes

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to growth..."_
- _"I want to cro..."_
- _"I want to how..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: Landing Page A/B Test Optimization

# Example: Landing Page A/B Test Optimization

## Scenario
A SaaS product landing page has a 1.8% signup conversion rate. Goal: reach 3%+ through systematic A/B testing.

## Current State Analysis

| Metric | Value | Benchmark |
|--------|-------|-----------|
| Visitors/month | 25,000 | - |
| Signup rate | 1.8% | 3-5% (SaaS avg) |
| Bounce rate | 72% | < 50% |
| Avg time on page | 18s | > 45s |
| CTA clicks | 3.2% | > 8% |

## Identified Issues

1. **Headline**: Feature-focused ("AI-powered analytics platform") instead of benefit-focused
2. **CTA**: "Get Started" is vague, below the fold on mobile
3. **Social proof**: None visible above the fold
4. **Form friction**: 6-field signup form requiring credit card

## A/B Test Plan

### Test 1: Headline (highest impact)

```
Control (A): "AI-Powered Analytics Platform"
Variant (B): "Cut Your Reporting Time by 75%"
Variant (C): "Stop Wasting 10 Hours/Week on Reports"

Metric: Signup rate
Traffic split: 33/33/33
Min sample: 3,000 per variant (95% confidence, 80% power)
Duration: ~12 days at current traffic
```

### Test 2: CTA Copy + Placement

```
Control (A): "Get Started" (below fold)
Variant (B): "Start Free Trial - No Credit Card" (above fold)

Metric: CTA click rate
Min sample: 2,500 per variant
Duration: ~6 days
```

### Test 3: Social Proof

```
Control (A): No social proof above fold
Variant (B): Logo bar "Trusted by 500+ companies" + 3 logos
Variant (C): Testimonial quote + photo + company name

Metric: Signup rate
Duration: ~12 days
```

### Test 4: Form Simplification

```
Control (A): 6 fields + credit card
Variant (B): Email + password only (2 fields)
Variant (C): "Sign up with Google" single button

Metric: Form completion rate
Duration: ~10 days
```

## Expected Impact Model

```
Test 1 (Headline):     +0.3-0.5% conversion lift
Test 2 (CTA):          +0.2-0.4% conversion lift
Test 3 (Social proof): +0.1-0.3% conversion lift
Test 4 (Form):         +0.4-0.8% conversion lift
Combined (estimated):  1.8% -> 3.0-3.5%
```

## Implementation Checklist

- [ ] Set up analytics events: `page_view`, `cta_click`, `form_start`, `signup_complete`
- [ ] Configure A/B tool (PostHog/LaunchDarkly) with feature flags
- [ ] Run tests sequentially (not simultaneously) to avoid interaction effects
- [ ] Wait for statistical significance before calling winner (p < 0.05)
- [ ] Monitor for novelty effect: check results stable after 2 full weeks
- [ ] Document winning variants and roll forward

## Key Decisions

- **Sequential testing**: Avoids confounding variables from simultaneous changes
- **Benefit-first headlines**: Address pain point, not feature description
- **Reduce friction first**: Removing credit card requirement often gives largest lift
- **Statistical rigor**: Minimum sample sizes calculated upfront, no peeking
- **PostHog over Google Optimize**: Self-hosted, GDPR-friendly, integrates with product analytics



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
