---
sidebar_position: 10
title: "/work:work-flow-launch"
description: "Workflow technique pour developper et lancer un produit, du setup au go-live."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-FLOW-LAUNCH

Workflow technique pour developper et lancer un produit, du setup au go-live.

## Contexte
`&lt;arguments&gt;`

## Objectif

Couvrir le workflow technique de developpement et deploiement d'un produit.
Pour l'analyse business prealable, utiliser `/biz:biz-launch`.
Prerequis : analyse business completee, MVP defini, budget et timeline approuves.

## Workflow

### Phase 1 : Setup
- Setup projet et stack technique (repo, structure, linter, CI/CD, env vars)
- Configuration CI/CD et environnements

### Phase 2 : Developpement
- Core features par User Story (tests -&gt; code -&gt; review -&gt; merge)
- Tests et QA : unitaires &gt; 80%, integration, E2E critiques, security review
- Responsive et accessibilite

### Phase 3 : Lancement
- Landing page optimisee (hero, CTA, social proof, pricing)
- Analytics et SEO (events tracking, meta tags, sitemap, Core Web Vitals)
- Go-live : domain, SSL, DNS, emails, paiements, legal (CGU, CGV, RGPD)
- Monitoring post-launch : uptime, erreurs, performance, feedback

## Output attendu

1. **Setup** : Projet initialise avec CI/CD
2. **MVP** : Features core implementees et testees
3. **Launch** : Produit en ligne avec analytics et monitoring

## Agents lies

| Agent | Usage |
|-------|-------|
| `/biz:biz-launch` | Analyse business prealable |
| `/dev:dev-testing-setup` | Configurer les tests |
| `/ops:ops-ci` | CI/CD avancee |
| `/qa:qa-security` | Audit de securite |
| `/growth:growth-seo` | SEO avance |

---

IMPORTANT: Faire d'abord l'analyse business avec `/biz:biz-launch` avant ce workflow.

YOU MUST avoir le legal en place avant le go-live (CGU, CGV, RGPD).

NEVER sacrifier la qualite pour aller plus vite - mieux vaut reporter.

Think hard sur ce qui est vraiment MVP vs nice-to-have.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
