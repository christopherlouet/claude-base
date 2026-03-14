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
