---
sidebar_position: 1
title: "Commands"
description: "Catalog of 131 claude-base commands"
---

import Stats from '@site/src/components/Stats';

# Commands Catalog

> **131 commands** organized in **10 domains**

<Stats items={[
  { number: 131, label: 'Commands' },
  { number: 10, label: 'Domains' },
]} />

## How to use commands

Commands are triggered manually with the `/` prefix:

```bash
/work:work-explore
/dev:dev-tdd "Feature description"
/qa:qa-security
```

## Domains


### [Autres](/docs/commands/other) (4)

> Commandes diverses et orchestrateurs

- [`/assistant`](/docs/commands/other/assistant)
- [`/assistant-auto`](/docs/commands/other/assistant-auto)
- [`/git-rename`](/docs/commands/other/git-rename)
- [`/lessons`](/docs/commands/other/lessons)



### [BIZ](/docs/commands/biz) (11)

> Business (model, MVP, pricing, pitch)

- [`/biz:biz-competitor`](/docs/commands/biz/biz-competitor)
- [`/biz:biz-launch`](/docs/commands/biz/biz-launch)
- [`/biz:biz-market`](/docs/commands/biz/biz-market)
- [`/biz:biz-model`](/docs/commands/biz/biz-model)
- [`/biz:biz-mvp`](/docs/commands/biz/biz-mvp)
- [... and 6 more](/docs/commands/biz)


### [DATA](/docs/commands/data) (3)

> Donnees (pipeline, analytics, modeling)

- [`/data:data-analytics`](/docs/commands/data/data-analytics)
- [`/data:data-modeling`](/docs/commands/data/data-modeling)
- [`/data:data-pipeline`](/docs/commands/data/data-pipeline)



### [DEV](/docs/commands/dev) (23)

> Developpement (TDD, API, composants, debug)

- [`/dev:dev-ai-integration`](/docs/commands/dev/dev-ai-integration)
- [`/dev:dev-api`](/docs/commands/dev/dev-api)
- [`/dev:dev-api-versioning`](/docs/commands/dev/dev-api-versioning)
- [`/dev:dev-component`](/docs/commands/dev/dev-component)
- [`/dev:dev-debug`](/docs/commands/dev/dev-debug)
- [... and 18 more](/docs/commands/dev)


### [DOC](/docs/commands/doc) (9)

> Documentation (changelog, README, architecture)

- [`/doc:doc-api-spec`](/docs/commands/doc/doc-api-spec)
- [`/doc:doc-architecture`](/docs/commands/doc/doc-architecture)
- [`/doc:doc-changelog`](/docs/commands/doc/doc-changelog)
- [`/doc:doc-explain`](/docs/commands/doc/doc-explain)
- [`/doc:doc-fix-issue`](/docs/commands/doc/doc-fix-issue)
- [... and 4 more](/docs/commands/doc)


### [GROWTH](/docs/commands/growth) (11)

> Croissance (SEO, analytics, landing, funnel)

- [`/growth:growth-ab-test`](/docs/commands/growth/growth-ab-test)
- [`/growth:growth-analytics`](/docs/commands/growth/growth-analytics)
- [`/growth:growth-app-store-analytics`](/docs/commands/growth/growth-app-store-analytics)
- [`/growth:growth-cro`](/docs/commands/growth/growth-cro)
- [`/growth:growth-email`](/docs/commands/growth/growth-email)
- [... and 6 more](/docs/commands/growth)


### [LEGAL](/docs/commands/legal) (5)

> Legal (RGPD, CGU, paiement)

- [`/legal:legal-docs`](/docs/commands/legal/legal-docs)
- [`/legal:legal-payment`](/docs/commands/legal/legal-payment)
- [`/legal:legal-privacy-policy`](/docs/commands/legal/legal-privacy-policy)
- [`/legal:legal-rgpd`](/docs/commands/legal/legal-rgpd)
- [`/legal:legal-terms-of-service`](/docs/commands/legal/legal-terms-of-service)



### [OPS](/docs/commands/ops) (34)

> Operations (CI/CD, Docker, monitoring, GitFlow)

- [`/ops:ops-backup`](/docs/commands/ops/ops-backup)
- [`/ops:ops-ci`](/docs/commands/ops/ops-ci)
- [`/ops:ops-ci-fix`](/docs/commands/ops/ops-ci-fix)
- [`/ops:ops-cost`](/docs/commands/ops/ops-cost)
- [`/ops:ops-cost-optimization`](/docs/commands/ops/ops-cost-optimization)
- [... and 29 more](/docs/commands/ops)


### [QA](/docs/commands/qa) (16)

> Qualite (review, securite, performance, accessibilite)

- [`/qa:qa-audit`](/docs/commands/qa/qa-audit)
- [`/qa:qa-automation`](/docs/commands/qa/qa-automation)
- [`/qa:qa-chrome`](/docs/commands/qa/qa-chrome)
- [`/qa:qa-coverage`](/docs/commands/qa/qa-coverage)
- [`/qa:qa-design`](/docs/commands/qa/qa-design)
- [... and 11 more](/docs/commands/qa)


### [WORK](/docs/commands/work) (15)

> Workflow principal (explore, plan, commit, PR)

- [`/work:work-batch`](/docs/commands/work/work-batch)
- [`/work:work-brainstorm`](/docs/commands/work/work-brainstorm)
- [`/work:work-clarify`](/docs/commands/work/work-clarify)
- [`/work:work-commit`](/docs/commands/work/work-commit)
- [`/work:work-commit-push-pr`](/docs/commands/work/work-commit-push-pr)
- [... and 10 more](/docs/commands/work)


## Quick choice guide

| Need | Recommended command |
|--------|---------------------|
| Explore the code | `/work:work-explore` |
| Specify the need | `/work:work-specify` |
| Plan a change | `/work:work-plan` |
| Develop with TDD | `/dev:dev-tdd` |
| Create a commit | `/work:work-commit` |
| Security audit | `/qa:qa-security` |
| Full audit | `/qa:qa-audit` |
| Create a PR | `/work:work-pr` |
| Release | `/ops:ops-release` |

---

Use `/assistant` to get personalized recommendations.
