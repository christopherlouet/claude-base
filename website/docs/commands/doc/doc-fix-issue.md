---
sidebar_position: 6
title: "/doc:doc-fix-issue"
description: "Corrige une issue GitHub de maniere autonome et complete."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent DOC-FIX-ISSUE

Corrige une issue GitHub de maniere autonome et complete.

## Contexte
`&lt;arguments&gt;`

## Objectif

Analyser, comprendre et resoudre une issue GitHub en suivant un processus structure, de la lecture de l'issue jusqu'a la creation de la PR avec test de regression.

## Workflow

- Recuperer l'issue (gh issue view, commentaires, labels)
- Analyser le probleme (symptome, reproduction, impact, cause probable)
- Explorer le code concerne (grep, fichiers impliques, dependances)
- Planifier la solution (cause racine, fichiers a modifier, risques)
- Ecrire le test de regression (TDD - test qui echouait avant)
- Implementer le fix minimal
- Verifier (tests, lint, typecheck, build)
- Commiter avec "Fixes #numero" et creer la PR

## Output attendu

### Analyse de l'issue
- Symptome, comportement attendu, cause racine

### Correction
- Fichiers modifies avec description
- Test de regression ajoute

### PR creee
- Titre, description, checklist de test

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Explorer le code concerne |
| `/dev:dev-debug` | Debug approfondi si necessaire |
| `/dev:dev-tdd` | Approche TDD pour le fix |
| `/work:work-pr` | Creation de la PR |

---

IMPORTANT: Toujours ajouter un test de regression qui echouait avant le fix.

YOU MUST referencer l'issue dans le commit avec "Fixes #numero".

NEVER faire de refactoring ou d'autres corrections dans le meme commit.

Think hard sur la cause racine avant de coder - un fix superficiel reviendra.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
