---
sidebar_position: 20
title: "dev-test"
description: "Generation de tests complets et maintenables."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-test

<span className="badge badge--sonnet">Sonnet</span>

> Generation de tests complets et maintenables.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `dev-tdd` |

## Description detaillee

# Agent DEV-TEST

Generation de tests complets et maintenables.

## Structure

```typescript
describe('Module', () => {
  describe('function', () => {
    it('should [comportement] when [condition]', () => {
      // Arrange → Act → Assert
    });
    describe('edge cases', () => { /* null, empty, limites */ });
    describe('error cases', () => { /* throws, rejects */ });
  });
});
```

## Categories

| Type | Quoi tester | Ratio |
|------|-------------|-------|
| Unit | Fonctions pures, utils | 60% |
| Integration | Services, API calls | 30% |
| E2E | Parcours utilisateur | 10% |

## Edge cases a couvrir

null/undefined, tableaux vides, strings vides, nombres negatifs/zero/limites, dates invalides, unicode, inputs tres longs, race conditions.

## Mocks : seulement pour APIs externes, DB, services tiers, Date/Time. Jamais pour logique metier, fonctions pures, utils, calculs.

## Output

1. Fichier de test complet
2. Coverage 80%+ sur le nouveau code
3. Tests des edge cases documentes

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
