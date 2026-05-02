---
sidebar_position: 6
title: Product Launch
description: Workflow to launch a new product
---

# Workflow: Product Launch

Complete guide to launch a new product or SaaS.

## Quick command

```bash
/work:work-flow-launch "My new SaaS"
```

## Overview

The launch workflow covers:

1. **Business** - Model, pricing, MVP
2. **Legal** - GDPR, ToS, legal notices
3. **Tech** - Infrastructure, security, performance
4. **Growth** - Landing, SEO, analytics
5. **Launch** - Go-live and monitoring

## Detailed steps

### 1. Business

```bash
/biz:biz-model "My project management SaaS"
```

Define:
- Value proposition
- Business model (Lean Canvas)
- Pricing strategy
- MVP scope

### 2. Legal

```bash
/legal:legal-rgpd
/legal:legal-terms-of-service
/legal:legal-privacy-policy
```

Prepare:
- GDPR compliance
- ToS/T&Cs
- Privacy policy
- Legal notices

### 3. Infrastructure

```bash
/ops:ops-ci
/ops:ops-monitoring
/ops:ops-backup
```

Configure:
- CI/CD pipeline
- Monitoring and alerts
- Backup and recovery
- Secrets management

### 4. Security

```bash
/qa:qa-security
/qa:qa-audit
```

Verify:
- OWASP Top 10
- Secure authentication
- Data protection
- Penetration tests

### 5. Performance

```bash
/qa:qa-perf
/ops:ops-load-testing
```

Optimize:
- Core Web Vitals
- API response times
- Load tests
- CDN and caching

### 6. Growth

```bash
/growth:growth-landing
/growth:growth-seo
/growth:growth-analytics
```

Prepare:
- Optimized landing page
- Technical SEO
- Analytics and tracking
- Conversion funnel

### 7. Go-Live

```bash
/ops:ops-release
```

Deploy:
- Production deployment
- DNS and certificates
- Active monitoring
- Support ready

## Launch checklist

### Business
- [ ] Business model validated
- [ ] Pricing defined
- [ ] MVP scope clear
- [ ] Personas documented

### Legal
- [ ] GDPR compliant
- [ ] ToS/T&Cs drafted
- [ ] Privacy policy
- [ ] Legal notices

### Tech
- [ ] CI/CD operational
- [ ] Monitoring active
- [ ] Backups configured
- [ ] Security audited

### Growth
- [ ] Landing optimized
- [ ] SEO in place
- [ ] Analytics configured
- [ ] Email ready

### Launch
- [ ] Domain configured
- [ ] SSL active
- [ ] Support ready
- [ ] Communication planned

## Concrete example

```bash
> /work:work-flow-launch "TaskFlow - Simplified project management"

# Claude automatically chains:
# 1. Analyzes the project
# 2. Proposes the business model
# 3. Prepares the legal documents
# 4. Configures the infrastructure
# 5. Audits security
# 6. Optimizes performance
# 7. Prepares growth
# 8. Guides the go-live
```

---

## See also

- [Business Model](/docs/commands/biz/biz-model)
- [Landing Page](/docs/commands/growth/growth-landing)
- [GDPR](/docs/commands/legal/legal-rgpd)
