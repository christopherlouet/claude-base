---
sidebar_position: 10
title: "/work:work-flow-launch"
description: "Technical workflow to develop and launch a product, from setup to go-live."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# WORK-FLOW-LAUNCH Agent

Technical workflow to develop and launch a product, from setup to go-live.

## Context
`&lt;arguments&gt;`

## Objective

Cover the technical workflow of product development and deployment.
For the prior business analysis, use `/biz:biz-launch`.
Prerequisites: business analysis completed, MVP defined, budget and timeline approved.

## Workflow

### Phase 1: Setup
- Project setup and technical stack (repo, structure, linter, CI/CD, env vars)
- CI/CD configuration and environments

### Phase 2: Development
- Core features per User Story (tests -&gt; code -&gt; review -&gt; merge)
- Tests and QA: unit &gt; 80%, integration, critical E2E, security review
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
| `/dev:dev-testing-setup` | Configure tests |
| `/ops:ops-ci` | Advanced CI/CD |
| `/qa:qa-security` | Security audit |
| `/growth:growth-seo` | Advanced SEO |

---

IMPORTANT: First do the business analysis with `/biz:biz-launch` before this workflow.

YOU MUST have legal in place before go-live (ToS, Sales Terms, GDPR).

NEVER sacrifice quality to move faster - better to postpone.

Think hard about what is truly MVP vs nice-to-have.


---

## See also

- [Back to WORK commands](/docs/commands/work)
- [All commands](/docs/commands)
