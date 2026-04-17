---
sidebar_position: 26
title: "testing"
description: "// Act - Executer l'action const result = functionToTest(input);"
tags:
  - "rule"
  - "testing"
---

# Regles: testing

> // Act - Executer l'action const result = functionToTest(input);

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/*.test.ts`
- `**/*.test.tsx`
- `**/*.spec.ts`
- `**/*.spec.tsx`
- `**/tests/**`
- `**/test/**`
- `**/__tests__/**`

## Regles detaillees

# Testing Rules

## Coverage

- IMPORTANT: Couverture minimum 80% sur nouveau code
- Couvrir les chemins critiques en priorite
- Ne pas viser 100% au detriment de la qualite

## Mocking

- IMPORTANT: Pas de mocks sauf dependances externes (API, DB)
- Preferer les stubs aux mocks complets
- Eviter de mocker les modules internes
- Utiliser des factories pour les donnees de test

## Edge Cases

- YOU MUST tester les edge cases:
  - `null` et `undefined`
  - Chaines vides et espaces
  - Tableaux vides
  - Valeurs limites (0, -1, MAX_INT)
  - Erreurs et exceptions

## Test Structure (AAA)

```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Preparer les donnees
      const input = createTestData();

      // Act - Executer l'action
      const result = functionToTest(input);

      // Assert - Verifier le resultat
      expect(result).toEqual(expected);
    });
  });
});
```

## Naming Conventions

- Noms de tests descriptifs et lisibles
- Format: `should [behavior] when [condition]`
- Grouper par fonctionnalite avec `describe`

## Best Practices

- Tests independants (pas d'ordre d'execution)
- Tests deterministes (pas de random sans seed)
- Tests rapides (&lt; 100ms par test unitaire)
- Un test = une assertion logique
- Tests lisibles = documentation vivante

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
