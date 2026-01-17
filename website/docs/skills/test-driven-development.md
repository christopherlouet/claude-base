---
sidebar_position: 28
title: "test-driven-development"
description: "Développement TDD avec cycle Red-Green-Refactor. Utiliser pour implémenter une fonctionnalité en écrivant les tests AVANT le code. Déclencher quand l'utilisateur demande du TDD, veut écrire des tests d'abord, ou mentionne \"test first\"."
tags:
  - "skill"
  - "fork"
---

# Skill: test-driven-development

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Développement TDD avec cycle Red-Green-Refactor. Utiliser pour implémenter une fonctionnalité en écrivant les tests AVANT le code. Déclencher quand l'utilisateur demande du TDD, veut écrire des tests d'abord, ou mentionne "test first".

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `test`, `driven`, `development`, `nom du test` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux test..."_
- _"Je veux driven..."_
- _"Je veux development..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple TDD : Fonction de calcul de prix avec remise

# Exemple TDD : Fonction de calcul de prix avec remise

## Demande utilisateur
> "Créer une fonction calculatePrice qui applique une remise en pourcentage"

---

## Phase 1: RED - Tests

```typescript
// src/__tests__/calculatePrice.test.ts

describe('calculatePrice', () => {
  // Cas nominal
  it('should return original price when no discount', () => {
    expect(calculatePrice(100, 0)).toBe(100);
  });

  it('should apply percentage discount correctly', () => {
    expect(calculatePrice(100, 20)).toBe(80);
  });

  // Edge cases
  it('should handle decimal prices', () => {
    expect(calculatePrice(99.99, 10)).toBeCloseTo(89.99);
  });

  it('should return 0 when price is 0', () => {
    expect(calculatePrice(0, 50)).toBe(0);
  });

  // Cas d'erreur
  it('should throw when discount > 100', () => {
    expect(() => calculatePrice(100, 150)).toThrow('Discount must be between 0 and 100');
  });

  it('should throw when discount < 0', () => {
    expect(() => calculatePrice(100, -10)).toThrow('Discount must be between 0 and 100');
  });
});
```

**Résultat attendu**: 6 tests échouent

---

## Phase 2: GREEN - Implémentation minimale

```typescript
// src/utils/calculatePrice.ts

export function calculatePrice(price: number, discountPercent: number): number {
  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }
  return price * (1 - discountPercent / 100);
}
```

**Résultat attendu**: 6 tests passent

---

## Phase 3: REFACTOR - Amélioration

```typescript
// src/utils/calculatePrice.ts

const MIN_DISCOUNT = 0;
const MAX_DISCOUNT = 100;

function validateDiscount(discount: number): void {
  if (discount < MIN_DISCOUNT || discount > MAX_DISCOUNT) {
    throw new Error(`Discount must be between ${MIN_DISCOUNT} and ${MAX_DISCOUNT}`);
  }
}

export function calculatePrice(price: number, discountPercent: number): number {
  validateDiscount(discountPercent);
  const discountMultiplier = 1 - discountPercent / 100;
  return price * discountMultiplier;
}
```

**Résultat attendu**: 6 tests passent toujours

---

## Commits

```bash
# Après Phase RED
git commit -m "test(pricing): add tests for calculatePrice function

- Test nominal cases (no discount, with discount)
- Test edge cases (decimal prices, zero price)
- Test error handling (invalid discount range)"

# Après Phase GREEN + REFACTOR
git commit -m "feat(pricing): implement calculatePrice with discount

- Add price calculation with percentage discount
- Validate discount range (0-100)
- Extract validation to separate function"
```



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
