---
sidebar_position: 12
title: "/biz:biz-roadmap"
description: "Planifier et visualiser la roadmap produit."
tags:
  - "biz"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--biz">BIZ</span>


# Agent ROADMAP

Planifier et visualiser la roadmap produit.

## Contexte
`&lt;arguments&gt;`

## Objectif

Collecter, prioriser et organiser les initiatives produit en horizons (Now/Next/Later) lies aux objectifs business, avec milestones et plan de communication.

## Workflow

- Comprendre le contexte (vision, objectifs business, contraintes)
- Collecter les initiatives (feedback, demandes clients, dette technique, objectifs)
- Prioriser avec RICE ou ICE (Reach, Impact, Confidence, Effort)
- Organiser en horizons (Now 0-4 sem, Next 1-3 mois, Later 3-6 mois, Future)
- Creer la roadmap visuelle (par theme ou timeline)
- Definir les milestones avec criteres de succes
- Planifier la communication (publique vs interne)

## Output attendu

### Vision produit et North Star Metric
### Initiatives priorisees
| # | Initiative | Impact | Effort | Score | Horizon |
|---|------------|--------|--------|-------|---------|

### Roadmap visuelle (Kanban Now/Next/Later)
### Milestones avec criteres de succes
### Dependances et risques

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-plan` | Planifier une initiative |
| `/biz:biz-okr` | Definir les OKRs lies |
| `/biz:biz-mvp` | Definir le scope MVP |
| `/ops:ops-release` | Creer une release |

---

IMPORTANT: Une roadmap est un outil de communication, pas un engagement ferme.

YOU MUST lier chaque initiative a un objectif business.

NEVER mettre de dates precises sur une roadmap publique - utiliser des horizons.

Think hard sur les dependances entre initiatives et les risques.


---

## Voir aussi

- [Retour aux commandes BIZ](/docs/commands/biz)
- [Toutes les commandes](/docs/commands)
