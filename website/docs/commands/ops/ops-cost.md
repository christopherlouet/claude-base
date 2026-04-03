---
sidebar_position: 4
title: "/ops:ops-cost"
description: "Suivi de la consommation de tokens et des couts Claude Code."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-COST

Suivi de la consommation de tokens et des couts Claude Code.

## Contexte
`&lt;arguments&gt;`

## Objectif

Analyser et afficher les metriques de consommation de tokens pour optimiser les couts.

## Outils de mesure

### ccusage (recommande)

```bash
# Installation
pip install ccusage

# Consommation totale
ccusage

# Par projet
ccusage --project

# Par jour
ccusage --daily

# Periode specifique
ccusage --since 2026-03-01 --until 2026-03-23
```

### RTK (optimisation)

```bash
# Installation
brew install rtk

# Voir les economies realisees
rtk gain

# Decouvrir les commandes non optimisees
rtk discover
```

Activer RTK : ajouter `ENABLE_RTK=1` dans `env` de `.claude/settings.json`.

## Strategies de reduction

| Strategie | Economie | Comment |
|-----------|----------|---------|
| RTK rewrite | 60-90% | Active automatiquement via hook PreToolUse |
| `/compact` entre phases | 20-40% | Reduire le contexte accumule |
| Agents Haiku pour taches simples | 50-70% | Exploration, lecture, recherche |
| Scope sessions focalisees | 30-50% | 1-5 taches par session max |
| Fichiers CLAUDE.md legers | 10-20% | Moins de contexte charge au demarrage |

## Output attendu

1. **Metriques** : Tokens consommes (input/output), cout estime
2. **Tendances** : Evolution par jour/semaine
3. **Recommandations** : Strategies d'optimisation applicables

---

IMPORTANT: ccusage lit les logs locaux de Claude Code, aucune donnee n'est envoyee a l'exterieur.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
