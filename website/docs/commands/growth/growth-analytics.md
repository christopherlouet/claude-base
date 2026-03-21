---
sidebar_position: 3
title: "/growth:growth-analytics"
description: "Mise en place du tracking et definition des KPIs pour un projet."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# Agent ANALYTICS

Mise en place du tracking et definition des KPIs pour un projet.

## Contexte
`&lt;arguments&gt;`

## Objectif

Definir la North Star Metric, les KPIs AARRR, les evenements a tracker, et mettre en place l'infrastructure analytics avec respect du RGPD.

## Workflow

- Comprendre les objectifs business et definir la North Star Metric
- Definir les KPIs par categorie AARRR (Acquisition, Activation, Retention, Revenue, Referral)
- Identifier les evenements a tracker (auth, onboarding, core actions, conversion, engagement)
- Choisir les outils (PostHog, Plausible, Sentry recommandes)
- Implementer le wrapper analytics type-safe (TypeScript)
- Configurer les dashboards et la frequence de reporting
- Verifier la conformite RGPD (consentement, anonymisation)

## Output attendu

### North Star Metric
### KPIs par categorie AARRR
### Evenements a implementer (avec priorite)
### Stack analytics recommandee
### Code d'implementation (snippets)

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-funnel` | Analyser les conversions |
| `/growth:growth-retention` | Mesurer la retention |
| `/growth:growth-ab-test` | Tester les hypotheses |
| `/legal:legal-rgpd` | Conformite RGPD |

---

IMPORTANT: Commencer simple - 5-10 evenements cles valent mieux que 100 jamais analyses.

YOU MUST definir une North Star Metric unique alignee avec la valeur business.

NEVER tracker des donnees personnelles sans consentement - respecter le RGPD.

Think hard sur ce qui drive vraiment la valeur du produit.


---

## Voir aussi

- [Retour aux commandes GROWTH](/docs/commands/growth)
- [Toutes les commandes](/docs/commands)
