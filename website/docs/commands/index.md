---
sidebar_position: 1
title: Commands
description: Catalogue des 100 commandes claude-socle
---

import Stats from '@site/src/components/Stats';

# Catalogue des Commandes

> **100 commandes** organisees en **10 domaines**

<Stats items={[
  { number: 100, label: 'Commandes' },
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

### [WORK](/docs/commands/work) (10)

> Workflow principal (explore, plan, commit, PR)

- [`/work-explore`](/docs/commands/work/work-explore)
- [`/work-plan`](/docs/commands/work/work-plan)
- [`/work-commit`](/docs/commands/work/work-commit)
- [`/work-pr`](/docs/commands/work/work-pr)
- [... et 6 autres](/docs/commands/work)

### [DEV](/docs/commands/dev) (16)

> Developpement (TDD, API, composants, debug)

- [`/dev-tdd`](/docs/commands/dev/dev-tdd)
- [`/dev-api`](/docs/commands/dev/dev-api)
- [`/dev-component`](/docs/commands/dev/dev-component)
- [`/dev-debug`](/docs/commands/dev/dev-debug)
- [... et 12 autres](/docs/commands/dev)

### [QA](/docs/commands/qa) (11)

> Qualite (review, securite, performance, accessibilite)

- [`/qa-review`](/docs/commands/qa/qa-review)
- [`/qa-security`](/docs/commands/qa/qa-security)
- [`/qa-audit`](/docs/commands/qa/qa-audit)
- [... et 8 autres](/docs/commands/qa)

### [OPS](/docs/commands/ops) (24)

> Operations (CI/CD, Docker, monitoring, GitFlow)

- [`/ops-release`](/docs/commands/ops/ops-release)
- [`/ops-ci`](/docs/commands/ops/ops-ci)
- [`/ops-docker`](/docs/commands/ops/ops-docker)
- [`/ops-gitflow-init`](/docs/commands/ops/ops-gitflow-init)
- [... et 20 autres](/docs/commands/ops)

### [DOC](/docs/commands/doc) (9)

> Documentation (changelog, README, architecture)

- [`/doc-changelog`](/docs/commands/doc/doc-changelog)
- [`/doc-readme`](/docs/commands/doc/doc-readme)
- [`/doc-api-spec`](/docs/commands/doc/doc-api-spec)
- [... et 6 autres](/docs/commands/doc)

### [BIZ](/docs/commands/biz) (11)

> Business (model, MVP, pricing, pitch)

- [`/biz-model`](/docs/commands/biz/biz-model)
- [`/biz-mvp`](/docs/commands/biz/biz-mvp)
- [`/biz-pricing`](/docs/commands/biz/biz-pricing)
- [... et 8 autres](/docs/commands/biz)

### [GROWTH](/docs/commands/growth) (9)

> Croissance (SEO, analytics, landing, funnel)

- [`/growth-landing`](/docs/commands/growth/growth-landing)
- [`/growth-seo`](/docs/commands/growth/growth-seo)
- [`/growth-analytics`](/docs/commands/growth/growth-analytics)
- [... et 6 autres](/docs/commands/growth)

### [DATA](/docs/commands/data) (3)

> Donnees (pipeline, analytics, modeling)

- [`/data-pipeline`](/docs/commands/data/data-pipeline)
- [`/data-analytics`](/docs/commands/data/data-analytics)
- [`/data-modeling`](/docs/commands/data/data-modeling)

### [LEGAL](/docs/commands/legal) (5)

> Legal (RGPD, CGU, paiement)

- [`/legal-rgpd`](/docs/commands/legal/legal-rgpd)
- [`/legal-terms-of-service`](/docs/commands/legal/legal-terms-of-service)
- [`/legal-privacy-policy`](/docs/commands/legal/legal-privacy-policy)
- [... et 2 autres](/docs/commands/legal)

### [ASSISTANT](/docs/commands/assistant) (1)

> Orchestrateur (point d'entree unique)

- [`/assistant`](/docs/commands/assistant)

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
