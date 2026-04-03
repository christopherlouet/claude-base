---
sidebar_position: 37
title: "ops-cost"
description: "Analyse de la consommation de tokens et recommandations d'optimisation des couts."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-cost

<span className="badge badge--haiku">Haiku</span>

> Analyse de la consommation de tokens et recommandations d'optimisation des couts.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent OPS-COST

Analyse de la consommation de tokens et recommandations d'optimisation des couts.

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
