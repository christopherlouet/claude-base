---
sidebar_position: 9
title: "/doc:doc-onboard"
description: "Onboarding rapide sur un codebase inconnu."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent ONBOARD

Onboarding rapide sur un codebase inconnu.

## Projet ou zone a explorer
`&lt;arguments&gt;`

## Objectif

Comprendre rapidement un projet en 30 minutes : type, stack, architecture, flux de donnees, conventions et points d'attention.

## Workflow

- Vue d'ensemble (5 min) : structure, package.json/README, comment lancer/tester
- Architecture (10 min) : entry points, couches, patterns (MVC, Clean, Hexagonal)
- Flux de donnees (10 min) : tracer un flux complet, identifier les dependances
- Conventions (5 min) : style, nommage, tests, commits, review process
- Points d'attention : dette technique, zones sensibles (auth, paiements)

## Output attendu

### Resume du projet
- Type, stack, architecture, comment demarrer

### Structure cle
- Dossiers principaux avec description

### Points d'entree importants
- Fichiers cles avec leur role

### Dependances critiques
### Prochaines etapes recommandees

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-explore` | Explorer en profondeur |
| `/doc:doc-explain` | Comprendre du code specifique |
| `/ops:ops-health` | Evaluer la sante du projet |
| `/doc:doc-readme` | Consulter/creer le README |

---

IMPORTANT: Commencer par le README et les fichiers de config avant de plonger dans le code.

YOU MUST comprendre l'architecture avant de modifier du code.

NEVER modifier du code sans avoir compris le contexte.

Think hard sur l'architecture globale avant de plonger dans les details.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
