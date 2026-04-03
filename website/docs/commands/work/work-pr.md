---
sidebar_position: 12
title: "/work:work-pr"
description: "Cree une Pull Request complete et bien documentee."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-PR

Cree une Pull Request complete et bien documentee.

## Contexte
`&lt;arguments&gt;`

## Objectif

Creer une PR propre avec description claire, tests verifies, et documentation complete.
Format titre : `type(scope): description concise`

## Workflow

- Verifier l'etat du repo et les changements (`git status`, `git diff main...HEAD`)
- Lancer les verifications qualite (tests, lint, build)
- Analyser les commits depuis main et determiner le type (feature/fix/refactor)
- Self-review : relire le diff ligne par ligne, noms explicites, pas de debug code
- Rediger le titre (Conventional Commits) et le corps (description, changements, tests, checklist)
- Pousser la branche (`git push -u origin &lt;branch&gt;`)
- Creer la PR avec `gh pr create` (titre, body, labels, reviewers)

## Output attendu

1. **PR creee** : URL de la PR
2. **Description** : Resume des changements et pourquoi
3. **Tests** : Verification que tout passe
4. **Reviewers** : Assignes si applicable

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-review` | Self-review avant PR |
| `/work:work-commit` | Preparer les commits |
| `/qa:qa-security` | Review securite si applicable |

---

IMPORTANT: Une PR = une seule preoccupation. Si trop divers, suggerer de splitter.

YOU MUST inclure une description claire du "pourquoi" dans la PR.

NEVER creer une PR sans avoir verifie que les tests passent.

Think hard sur la clarte de la description pour les reviewers.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
