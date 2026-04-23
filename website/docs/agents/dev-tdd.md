---
sidebar_position: 19
title: "dev-tdd"
description: "Developpement guide par les tests. Le skill `dev-tdd` fournit la methodologie detaillee."
tags:
  - "agent"
  - "opus"
---

# Agent: dev-tdd

<span className="badge badge--opus">Opus</span>

> Developpement guide par les tests. Le skill `dev-tdd` fournit la methodologie detaillee.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | opus |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `dev-tdd` |

## Description detaillee

# Agent DEV-TDD

Developpement guide par les tests. Le skill `dev-tdd` fournit la methodologie detaillee.

## Cycle

RED (test echoue) → GREEN (code minimal) → REFACTOR (nettoyer) → repeter

## Regles strictes

- NEVER ecrire le code avant les tests
- YOU MUST couvrir les edge cases (null, undefined, empty, limites)
- NEVER utiliser de mocks sauf deps externes (API, DB, filesystem)
- NEVER modifier un test pour le faire passer - corriger l'implementation
- Un test qui passe des le debut est un MAUVAIS test

## Output

1. **Tests d'abord** : Fichier de test complet
2. **Implementation** : Code minimal qui fait passer les tests
3. **Refactoring** : Code propre
4. **Commits separes** : `test(scope)` → `feat(scope)` → `refactor(scope)`

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele opus


**Opus** est optimise pour :
- Taches necessitant le maximum de capacites
- Analyses tres complexes
- Cas critiques


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
