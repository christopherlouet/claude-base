---
sidebar_position: 1
title: "Commands"
description: "Catalogue des 108 commandes claude-socle"
---

import Stats from '@site/src/components/Stats';

# Catalogue des Commandes

> **108 commandes** organisees en **10 domaines**

<Stats items={[
  { number: 108, label: 'Commandes' },
  { number: 10, label: 'Domaines' },
]} />

## Comment utiliser les commandes

Les commandes sont declenchees manuellement avec le prefixe `/` :

```bash
/work-explore
/dev-tdd "Description de la feature"
/qa-security
```

## Domaines


### [Autres](/docs/commands/other) (1)

> Commandes diverses et orchestrateurs

- [`/assistant`](/docs/commands/other/assistant)



### [BIZ](/docs/commands/biz) (11)

> Business (model, MVP, pricing, pitch)

- [`/biz-competitor`](/docs/commands/biz/biz-competitor)
- [`/biz-launch`](/docs/commands/biz/biz-launch)
- [`/biz-market`](/docs/commands/biz/biz-market)
- [`/biz-model`](/docs/commands/biz/biz-model)
- [`/biz-mvp`](/docs/commands/biz/biz-mvp)
- [... et 6 autres](/docs/commands/biz)


### [DATA](/docs/commands/data) (3)

> Donnees (pipeline, analytics, modeling)

- [`/data-analytics`](/docs/commands/data/data-analytics)
- [`/data-modeling`](/docs/commands/data/data-modeling)
- [`/data-pipeline`](/docs/commands/data/data-pipeline)



### [DEV](/docs/commands/dev) (16)

> Developpement (TDD, API, composants, debug)

- [`/dev-api`](/docs/commands/dev/dev-api)
- [`/dev-api-versioning`](/docs/commands/dev/dev-api-versioning)
- [`/dev-component`](/docs/commands/dev/dev-component)
- [`/dev-debug`](/docs/commands/dev/dev-debug)
- [`/dev-error-handling`](/docs/commands/dev/dev-error-handling)
- [... et 11 autres](/docs/commands/dev)


### [DOC](/docs/commands/doc) (9)

> Documentation (changelog, README, architecture)

- [`/doc-api-spec`](/docs/commands/doc/doc-api-spec)
- [`/doc-architecture`](/docs/commands/doc/doc-architecture)
- [`/doc-changelog`](/docs/commands/doc/doc-changelog)
- [`/doc-explain`](/docs/commands/doc/doc-explain)
- [`/doc-fix-issue`](/docs/commands/doc/doc-fix-issue)
- [... et 4 autres](/docs/commands/doc)


### [GROWTH](/docs/commands/growth) (9)

> Croissance (SEO, analytics, landing, funnel)

- [`/growth-ab-test`](/docs/commands/growth/growth-ab-test)
- [`/growth-analytics`](/docs/commands/growth/growth-analytics)
- [`/growth-app-store-analytics`](/docs/commands/growth/growth-app-store-analytics)
- [`/growth-email`](/docs/commands/growth/growth-email)
- [`/growth-funnel`](/docs/commands/growth/growth-funnel)
- [... et 4 autres](/docs/commands/growth)


### [LEGAL](/docs/commands/legal) (5)

> Legal (RGPD, CGU, paiement)

- [`/legal-docs`](/docs/commands/legal/legal-docs)
- [`/legal-payment`](/docs/commands/legal/legal-payment)
- [`/legal-privacy-policy`](/docs/commands/legal/legal-privacy-policy)
- [`/legal-rgpd`](/docs/commands/legal/legal-rgpd)
- [`/legal-terms-of-service`](/docs/commands/legal/legal-terms-of-service)



### [OPS](/docs/commands/ops) (25)

> Operations (CI/CD, Docker, monitoring, GitFlow)

- [`/ops-backup`](/docs/commands/ops/ops-backup)
- [`/ops-ci`](/docs/commands/ops/ops-ci)
- [`/ops-cost-optimization`](/docs/commands/ops/ops-cost-optimization)
- [`/ops-database`](/docs/commands/ops/ops-database)
- [`/ops-deps`](/docs/commands/ops/ops-deps)
- [... et 20 autres](/docs/commands/ops)


### [QA](/docs/commands/qa) (11)

> Qualite (review, securite, performance, accessibilite)

- [`/qa-a11y`](/docs/commands/qa/qa-a11y)
- [`/qa-audit`](/docs/commands/qa/qa-audit)
- [`/qa-automation`](/docs/commands/qa/qa-automation)
- [`/qa-coverage`](/docs/commands/qa/qa-coverage)
- [`/qa-kaizen`](/docs/commands/qa/qa-kaizen)
- [... et 6 autres](/docs/commands/qa)


### [WORK](/docs/commands/work) (10)

> Workflow principal (explore, plan, commit, PR)

- [`/work-clarify`](/docs/commands/work/work-clarify)
- [`/work-commit`](/docs/commands/work/work-commit)
- [`/work-explore`](/docs/commands/work/work-explore)
- [`/work-flow-bugfix`](/docs/commands/work/work-flow-bugfix)
- [`/work-flow-feature`](/docs/commands/work/work-flow-feature)
- [... et 5 autres](/docs/commands/work)


## Guide de choix rapide

| Besoin | Commande recommandee |
|--------|---------------------|
| Explorer le code | `/work-explore` |
| Planifier une modification | `/work-plan` |
| Developper en TDD | `/dev-tdd` |
| Creer un commit | `/work-commit` |
| Audit de securite | `/qa-security` |
| Audit complet | `/qa-audit` |
| Creer une PR | `/work-pr` |
| Release | `/ops-release` |

---

Utilisez `/assistant` pour obtenir des recommandations personnalisees.
