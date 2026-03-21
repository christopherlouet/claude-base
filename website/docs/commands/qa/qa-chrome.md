---
sidebar_position: 4
title: "/qa:qa-chrome"
description: "Tests visuels et debugging navigateur via l'integration Chrome de Claude Code."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-CHROME (Tests visuels Chrome)

Tests visuels et debugging navigateur via l'integration Chrome de Claude Code.

## Prerequis

- Lancer Claude Code avec: `claude --chrome`
- Extension "Claude in Chrome" installee (v1.0.36+)

## Utilisation

Effectue un audit visuel de la page ou URL specifiee: `&lt;arguments&gt;`

## Capacites

- Navigation et interaction avec les pages web
- Lecture des erreurs console et logs
- Inspection DOM et styles CSS
- Monitoring requetes reseau
- Screenshots et enregistrement GIF
- Test responsive (mobile, tablet, desktop)

## Workflow

1. Verifier la connexion Chrome (`/chrome`)
2. Ouvrir la page cible
3. Inspecter: console, erreurs, layout
4. Tester responsive: 375px, 768px, 1440px
5. Parcours utilisateur: interactions principales
6. Capturer les anomalies
7. Generer le rapport

## Output

Rapport structure:
- Erreurs critiques avec captures
- Warnings et suggestions
- Score global (/10)
- Recommandations d'amelioration


---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
