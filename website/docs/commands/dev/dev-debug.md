---
sidebar_position: 6
title: "/dev:dev-debug"
description: "Diagnostic et résolution de bugs de manière méthodique et systématique."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEBUG

Diagnostic et résolution de bugs de manière méthodique et systématique.

## Problème à analyser
`&lt;arguments&gt;`

## Objectif

Identifier la cause racine d'un bug et le corriger de manière définitive,
en ajoutant des protections pour éviter sa réapparition.

Utilise le skill `dev-debug` pour la méthodologie détaillée (4 phases : Observation, Hypothèses, Investigation, Vérification).

## Workflow

1. **Reproduire** : Confirmer, isoler, collecter infos (symptôme, env, fréquence)
2. **Analyser** : Logs, console, network, stack trace, git history
3. **Hypothéser** : Matrice hypothèses (probabilité + test de validation)
4. **Investiguer** : Technique des 5 Whys, git bisect pour régressions
5. **Corriger** : Fix minimal de la cause racine
6. **Prévenir** : Test de non-régression

## Output attendu

### Diagnostic
- **Symptôme** : Description du comportement observé
- **Root cause** : Cause fondamentale identifiée
- **Fichiers impactés** : Liste avec descriptions
- **Commit coupable** : Hash (si trouvé via bisect)

### Solution
- **Fix appliqué** : Description de la correction
- **Test ajouté** : Test de non-régression
- **Vérification** : Bug corrigé, tests passent, pas d'effets de bord

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-explore` | Comprendre le contexte du code |
| `/dev:dev-test` | Ajouter tests de régression |
| `/work:work-commit` | Commiter le fix |

---

IMPORTANT: Ne jamais corriger les symptômes. Toujours trouver la cause racine.

YOU MUST ajouter un test qui aurait détecté ce bug.

YOU MUST documenter la root cause pour éviter la récurrence.

Think hard sur pourquoi ce bug n'a pas été détecté plus tôt.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
