# WORK-FLOW-LAUNCH Agent

Technical workflow to develop and launch a product, from setup to go-live.

## Context
$ARGUMENTS

## Objective

Cover the technical workflow of product development and deployment.
For the prior business analysis, use `/biz:biz-launch`.
Prerequisites: business analysis completed, MVP defined, budget and timeline approved.

## Workflow

### Phase 1: Setup
- Project setup and technical stack (repo, structure, linter, CI/CD, env vars)
- CI/CD configuration and environments

### Phase 2: Development
- Core features per User Story (tests -> code -> review -> merge)
- Tests and QA: unit > 80%, integration, critical E2E, security review
- Responsive and accessibility

### Phase 3: Launch
- Optimized landing page (hero, CTA, social proof, pricing)
- Analytics and SEO (events tracking, meta tags, sitemap, Core Web Vitals)
- Go-live: domain, SSL, DNS, emails, payments, legal (ToS, Sales Terms, GDPR)
- Post-launch monitoring: uptime, errors, performance, feedback

## Expected output

1. **Setup**: Project initialized with CI/CD
2. **MVP**: Core features implemented and tested
3. **Launch**: Product online with analytics and monitoring

## Related agents

| Agent | Usage |
|-------|-------|
| `/biz:biz-launch` | Prior business analysis |
| `/dev:dev-tdd` | Configure tests |
| `/ops:ops-ci` | Advanced CI/CD |
| `/qa:qa-security` | Security audit |
| `/growth:growth-seo` | Advanced SEO |

---

IMPORTANT: First do the business analysis with `/biz:biz-launch` before this workflow.

YOU MUST have legal in place before go-live (ToS, Sales Terms, GDPR).

NEVER sacrifice quality to move faster - better to postpone.

Think hard about what is truly MVP vs nice-to-have.
