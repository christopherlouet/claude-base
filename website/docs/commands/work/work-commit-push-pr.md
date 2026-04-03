---
sidebar_position: 5
title: "/work:work-commit-push-pr"
description: "Workflow complet: commit + push + PR en une seule commande."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-COMMIT-PUSH-PR

Workflow complet: commit + push + PR en une seule commande.

## Contexte
`&lt;arguments&gt;`

## Objectif

Executer le cycle complet de livraison en une seule commande :
verifier qualite, creer un commit propre, push, creer une PR documentee.

## Workflow

- Verifier l'etat du repo (`git status`, `git diff --stat`)
- Lancer les verifications qualite (tests, lint, typecheck)
- Verifier : pas sur main/master, pas de fichiers sensibles, pas de console.log
- Analyser les changements et determiner le type (feat/fix/refactor/etc.)
- Creer un commit Conventional Commits (`type(scope): description`)
- Push avec upstream (`git push -u origin &lt;branch&gt;`)
- Creer la PR avec `gh pr create` : titre, summary, test plan
- Verifier le statut CI post-creation

## Output attendu

1. **Verification** : Rapport qualite (tests, lint, types)
2. **Commit** : Message Conventional Commits
3. **Push** : Branche poussee
4. **PR** : URL de la PR creee avec description complete

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Comprendre avant de commiter |
| `/work:work-plan` | Planifier avant d'implementer |
| `/qa:qa-review` | Self-review avant PR |

---

IMPORTANT: Toujours verifier les tests avant de commit-push-pr.

YOU MUST utiliser Conventional Commits pour le message.

NEVER commiter sur main/master directement.

NEVER inclure de fichiers sensibles (.env, secrets).

Think hard sur le message de commit et le titre de la PR - ils seront lus par d'autres.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
