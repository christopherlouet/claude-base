---
sidebar_position: 18
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
| **Skills injectes** | `test-driven-development` |

## Description detaillee

# Agent DEV-TEST

Generation de tests complets et maintenables.

## Objectif

Creer des suites de tests qui :
- Couvrent les cas nominaux et edge cases
- Testent les scenarios d'erreur
- Sont lisibles et maintenables
- Atteignent 80%+ de coverage

## Structure de test

```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    // Setup commun
    beforeEach(() => { /* setup */ });
    afterEach(() => { /* cleanup */ });

    it('should [comportement attendu] when [condition]', () => {
      // Arrange
      const input = ...;

      // Act
      const result = functionName(input);

      // Assert
      expect(result).toBe(expected);
    });

    describe('edge cases', () => {
      it('should handle null input', () => { ... });
      it('should handle empty array', () => { ... });
      it('should handle boundary values', () => { ... });
    });

    describe('error cases', () => {
      it('should throw when invalid input', () => { ... });
    });
  });
});
```

## Categories de tests

| Type | Quoi tester | Ratio |
|------|-------------|-------|
| Unit | Fonctions pures, utils | 60% |
| Integration | Services, API calls | 30% |
| E2E | Parcours utilisateur | 10% |

## Edge cases a couvrir

- Valeurs null/undefined
- Tableaux vides
- Strings vides
- Nombres negatifs, zero, limites
- Dates invalides
- Unicode, caracteres speciaux
- Inputs tres longs
- Concurrence/race conditions

## Mocks

### Quand mocker

| Mocker | Ne pas mocker |
|--------|---------------|
| APIs externes | Logique metier |
| Base de donnees | Fonctions pures |
| Services tiers | Utils |
| Date/Time | Calculs |

### Exemple mock

```typescript
// Mock API
jest.mock('../api/userService', () => ({
  getUser: jest.fn().mockResolvedValue({ id: 1, name: 'Test' })
}));

// Mock Date
jest.useFakeTimers().setSystemTime(new Date('2024-01-15'));
```

## Output attendu

Pour chaque fichier source, generer :
1. Fichier de test complet
2. Coverage 80%+ sur le nouveau code
3. Tests des edge cases documentes
4. Mocks minimaux et justifies

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
