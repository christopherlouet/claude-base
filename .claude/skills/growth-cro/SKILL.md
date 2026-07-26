---
name: growth-cro
description: Conversion rate optimization (CRO) and funnel analysis. Trigger when the user wants to optimize conversions, map/analyze a conversion funnel, improve a signup form, a checkout, a landing page, or an onboarding/activation flow.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
context: fork
background: false
---

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

## 7. Funnel mapping & analysis

Before optimizing a single step, map and measure the whole funnel.

1. **Map the steps** — events, pages, actions from entry to conversion.
2. **Measure** — conversion per step and the global rate.

| Step | Users | Conv. | Drop-off | Trend |
|------|-------|-------|----------|-------|
| ...  | ...   | ...   | ...      | ...   |

3. **Segment** — device, source, country, cohort (drop-offs often hide in a segment).
4. **Diagnose drop-offs** — friction (effort), anxiety (trust), clarity (confusion) — ask *why*, not just *how much*.
5. **Prioritize** — score opportunities with ICE (Impact × Confidence × Ease); optimize one step at a time.
6. **Monitor** — continuous tracking + alerts on step regressions.

Reliable tracking is a prerequisite — never analyze a funnel on unreliable data.

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
