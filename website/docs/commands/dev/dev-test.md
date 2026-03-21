---
sidebar_position: 22
title: "/dev:dev-test"
description: "Genere des tests complets et de qualite pour du code existant."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TEST

Genere des tests complets et de qualite pour du code existant.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Creer une suite de tests exhaustive qui couvre les cas nominaux,
les edge cases et les cas d'erreur pour garantir la fiabilite du code.

## Workflow

- **Analyser** le code : fonctions publiques, dependances, branches conditionnelles, effets de bord
- **Identifier** les cas de test par categorie :
  - Nominal (happy path) : comportement attendu avec entrees valides
  - Edge cases : null, undefined, "", [], \{\}, 0, -1, MAX_INT, string vide/tres long
  - Erreurs : entrees invalides, exceptions attendues, etats impossibles
  - Boundary : off-by-one, seuils (juste avant/exactement/juste apres), transitions d'etat
- **Generer** les tests en structure AAA (Arrange-Act-Assert) avec noms descriptifs
- **Verifier** : lancer les tests, valider la couverture (&gt;80%)

## Seuils de couverture

- Logique metier critique : 90%+
- Services et utils : 80%+
- Composants UI : 70%+

## Output attendu

Fichiers de tests generes avec statistiques (nombre de tests, couverture estimee),
cas couverts par fonction (nominal, edge cases, erreurs) et commande pour lancer.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-explore` | Comprendre le code a tester |
| `/dev:dev-tdd` | Developper en TDD |
| `/dev:dev-testing-setup` | Configurer l'infrastructure de tests |
| `/qa:qa-review` | Review des tests |

---

IMPORTANT: Pas de mocks sauf pour les dependances externes (API, DB, filesystem).

IMPORTANT: Tests independants les uns des autres.

YOU MUST viser une couverture &gt; 80% sur le code cible.

YOU MUST tester les edge cases (null, undefined, empty, limites).

NEVER ecrire des tests qui dependent de l'ordre d'execution.

Think hard sur les cas limites avant de coder les tests.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
