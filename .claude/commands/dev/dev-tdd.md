# Agent DEV-TDD

Implémente une fonctionnalité en suivant le cycle TDD (Test-Driven Development).

## Contexte
$ARGUMENTS

## Objectif

Développer du code robuste en écrivant les tests AVANT l'implémentation.
Le TDD garantit une couverture de tests complète et un design émergent.

Utilise le skill `dev-tdd` pour la méthodologie détaillée du cycle Red-Green-Refactor.

## Cycle TDD

RED (test échoue) → GREEN (code minimal) → REFACTOR (nettoyer) → répéter

## Output attendu

1. **Tests d'abord** : Fichier de test complet (cas nominaux, edge cases, erreurs)
2. **Implémentation** : Code minimal qui fait passer les tests
3. **Refactoring** : Code propre, lisible, SOLID
4. **Commits séparés** : `test(scope)` → `feat(scope)` → `refactor(scope)`

## Agents liés

| Avant | Usage |
|-------|-------|
| `/work:work-plan` | Planifier avant de coder |
| `/work:work-explore` | Comprendre le contexte |

| Après | Usage |
|-------|-------|
| `/qa:qa-review` | Review du code |
| `/work:work-commit` | Commiter proprement |

---

IMPORTANT: Ne jamais écrire le code avant les tests.

IMPORTANT: Un test qui passe dès le début est un MAUVAIS test.

YOU MUST couvrir les edge cases (null, undefined, empty, limites).

NEVER utiliser de mocks sauf pour les dépendances externes (API, DB, filesystem).

NEVER modifier un test pour le faire passer - corriger l'implémentation.
