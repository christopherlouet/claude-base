---
sidebar_position: 1
title: "Commands"
description: "Catalogue des 119 commandes claude-socle"
---

import Stats from '@site/src/components/Stats';

# Catalogue des Commandes

> **119 commandes** organisees en **10 domaines**

<Stats items={[
  { number: 119, label: 'Commandes' },
  { number: 10, label: 'Domaines' },
]} />

## Comment utiliser les commandes

Les commandes sont declenchees manuellement avec le prefixe `/` :

```bash
/work:work-explore
/dev:dev-tdd "Description de la feature"
/qa:qa-security
```

## Domaines


### [Autres](/docs/commands/other) (2)

> Commandes diverses et orchestrateurs

- [`/assistant`](/docs/commands/other/assistant)
- [`/assistant-auto`](/docs/commands/other/assistant-auto)



### [BIZ](/docs/commands/biz) (11)

> Business (model, MVP, pricing, pitch)

- [`/biz:biz-competitor`](/docs/commands/biz/biz-competitor)
- [`/biz:biz-launch`](/docs/commands/biz/biz-launch)
- [`/biz:biz-market`](/docs/commands/biz/biz-market)
- [`/biz:biz-model`](/docs/commands/biz/biz-model)
- [`/biz:biz-mvp`](/docs/commands/biz/biz-mvp)
- [... et 6 autres](/docs/commands/biz)


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
- [... et 18 autres](/docs/commands/dev)


### [DOC](/docs/commands/doc) (9)

> Documentation (changelog, README, architecture)

- [`/doc:doc-api-spec`](/docs/commands/doc/doc-api-spec)
- [`/doc:doc-architecture`](/docs/commands/doc/doc-architecture)
- [`/doc:doc-changelog`](/docs/commands/doc/doc-changelog)
- [`/doc:doc-explain`](/docs/commands/doc/doc-explain)
- [`/doc:doc-fix-issue`](/docs/commands/doc/doc-fix-issue)
- [... et 4 autres](/docs/commands/doc)


### [GROWTH](/docs/commands/growth) (11)

> Croissance (SEO, analytics, landing, funnel)

- [`/growth:growth-ab-test`](/docs/commands/growth/growth-ab-test)
- [`/growth:growth-analytics`](/docs/commands/growth/growth-analytics)
- [`/growth:growth-app-store-analytics`](/docs/commands/growth/growth-app-store-analytics)
- [`/growth:growth-cro`](/docs/commands/growth/growth-cro)
- [`/growth:growth-email`](/docs/commands/growth/growth-email)
- [... et 6 autres](/docs/commands/growth)


### [LEGAL](/docs/commands/legal) (5)

> Legal (RGPD, CGU, paiement)

- [`/legal:legal-docs`](/docs/commands/legal/legal-docs)
- [`/legal:legal-payment`](/docs/commands/legal/legal-payment)
- [`/legal:legal-privacy-policy`](/docs/commands/legal/legal-privacy-policy)
- [`/legal:legal-rgpd`](/docs/commands/legal/legal-rgpd)
- [`/legal:legal-terms-of-service`](/docs/commands/legal/legal-terms-of-service)



### [OPS](/docs/commands/ops) (30)

> Operations (CI/CD, Docker, monitoring, GitFlow)

- [`/ops:ops-backup`](/docs/commands/ops/ops-backup)
- [`/ops:ops-ci`](/docs/commands/ops/ops-ci)
- [`/ops:ops-cost-optimization`](/docs/commands/ops/ops-cost-optimization)
- [`/ops:ops-database`](/docs/commands/ops/ops-database)
- [`/ops:ops-deps`](/docs/commands/ops/ops-deps)
- [... et 25 autres](/docs/commands/ops)


### [QA](/docs/commands/qa) (14)

> Qualite (review, securite, performance, accessibilite)

- [`/qa:qa-a11y`](/docs/commands/qa/qa-a11y)
- [`/qa:qa-audit`](/docs/commands/qa/qa-audit)
- [`/qa:qa-automation`](/docs/commands/qa/qa-automation)
- [`/qa:qa-coverage`](/docs/commands/qa/qa-coverage)
- [`/qa:qa-design`](/docs/commands/qa/qa-design)
- [... et 9 autres](/docs/commands/qa)


### [WORK](/docs/commands/work) (10)

> Workflow principal (explore, plan, commit, PR)

- [`/work:work-clarify`](/docs/commands/work/work-clarify)
- [`/work:work-commit`](/docs/commands/work/work-commit)
- [`/work:work-explore`](/docs/commands/work/work-explore)
- [`/work:work-flow-bugfix`](/docs/commands/work/work-flow-bugfix)
- [`/work:work-flow-feature`](/docs/commands/work/work-flow-feature)
- [... et 5 autres](/docs/commands/work)


## Guide de choix rapide

| Besoin | Commande recommandee |
|--------|---------------------|
| Explorer le code | `/work:work-explore` |
| Planifier une modification | `/work:work-plan` |
| Developper en TDD | `/dev:dev-tdd` |
| Creer un commit | `/work:work-commit` |
| Audit de securite | `/qa:qa-security` |
| Audit complet | `/qa:qa-audit` |
| Creer une PR | `/work:work-pr` |
| Release | `/ops:ops-release` |

---

Utilisez `/assistant` pour obtenir des recommandations personnalisees.
