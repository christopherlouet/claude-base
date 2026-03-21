---
sidebar_position: 3
title: "/work:work-commit"
description: "Prepare et effectue un commit propre suivant les conventions."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-COMMIT

Prepare et effectue un commit propre suivant les conventions.

## Contexte
`&lt;arguments&gt;`

## Objectif

Creer un commit atomique, bien documente et conforme aux Conventional Commits.
Le commit est la derniere etape du workflow : **EXPLORE -&gt; PLAN -&gt; CODE -&gt; COMMIT**

## Workflow

- Verifier l'etat du repo (`git status`, `git diff`, `git diff --staged`)
- Lancer les verifications qualite (tests, lint, typecheck, build)
- Verifier la coherence des changements (un seul sujet par commit)
- Verifier l'absence de fichiers sensibles (.env, credentials, secrets)
- Verifier l'absence de console.log de debug et code commente inutile
- Determiner le type : feat, fix, refactor, test, docs, style, perf, chore
- Rediger le message : `type(scope): description` (&lt; 50 chars, imperatif, pas de point)
- Ajouter les fichiers pertinents (`git add &lt;fichiers&gt;`, verifier avant)
- Commiter avec corps explicatif si necessaire

## Output attendu

1. **Verification** : Checklist qualite (tests, lint, types)
2. **Commit** : Message Conventional Commits avec scope pertinent
3. **Confirmation** : `git log --oneline -1` pour verifier

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-pr` | Creer une PR apres commit |
| `/qa:qa-review` | Review avant commit |
| `/doc:doc-changelog` | Mettre a jour le changelog |

---

IMPORTANT: Toujours verifier les tests et le lint avant de commiter.

YOU MUST creer des commits atomiques - un commit = une preoccupation.

NEVER commiter de fichiers sensibles (.env, credentials, secrets).

NEVER utiliser `git add .` sans verifier `git status` d'abord.

Think hard sur le message de commit - il sera lu par d'autres developpeurs.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
