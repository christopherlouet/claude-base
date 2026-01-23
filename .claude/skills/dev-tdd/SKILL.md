---
name: dev-tdd
description: Développement TDD avec cycle Red-Green-Refactor. Utiliser pour implémenter une fonctionnalité en écrivant les tests AVANT le code. Déclencher automatiquement quand l'utilisateur demande du TDD, veut écrire des tests d'abord, mentionne "test first", ou demande d'implémenter, ajouter, créer, fixer, corriger du code, une nouvelle feature, un bugfix, ou une fonctionnalité.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Test-Driven Development (TDD)

## Cycle TDD

```
┌─────────┐     ┌─────────┐     ┌──────────┐
│   RED   │ ──▶ │  GREEN  │ ──▶ │ REFACTOR │
│  Test   │     │  Code   │     │  Clean   │
│  fail   │     │  pass   │     │   up     │
└─────────┘     └─────────┘     └──────────┘
      ▲                              │
      └──────────────────────────────┘
```

## Instructions

### Phase 1: RED - Écrire les tests qui échouent

1. **Identifier les cas de test**:
   - Cas nominal (comportement attendu)
   - Edge cases (null, undefined, vide, limites)
   - Cas d'erreur (exceptions)

2. **Écrire les tests** avec structure AAA:
   ```typescript
   describe('Module', () => {
     describe('fonction', () => {
       it('should [comportement] when [condition]', () => {
         // Arrange - Préparer
         // Act - Exécuter
         // Assert - Vérifier
       });
     });
   });
   ```

3. **Vérifier l'échec**: `npm test` DOIT échouer

4. **Commiter les tests**: `git commit -m "test(scope): add tests for [feature]"`

### Phase 2: GREEN - Implémenter le minimum

1. **Code minimal**: Juste assez pour passer les tests
2. **Pas d'optimisation**: On optimise après
3. **Pas de généralisation**: YAGNI
4. **Vérifier**: `npm test` DOIT passer

### Phase 3: REFACTOR - Améliorer

1. **Tests passent AVANT et APRÈS**
2. **Axes d'amélioration**:
   - Lisibilité (noms clairs)
   - DRY (extraire duplications)
   - SOLID (single responsibility)
3. **Petites modifications incrémentales**
4. **Commiter**: `git commit -m "feat(scope): implement [feature]"`

## Règles strictes

- JAMAIS écrire le code avant les tests
- Un test qui passe dès le début est un MAUVAIS test
- Couvrir les edge cases (null, undefined, empty, limites)
- Mocks UNIQUEMENT pour dépendances externes (API, DB)
- Ne JAMAIS modifier un test pour le faire passer

## Commandes utiles

```bash
# Lancer les tests
npm test

# Tests en watch mode
npm run test:watch

# Avec couverture
npm run test:coverage

# Un fichier spécifique
npm test -- --grep "nom du test"
```
