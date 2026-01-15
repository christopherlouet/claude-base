# Agent DEV-TDD

Implémente une fonctionnalité en suivant le cycle TDD (Test-Driven Development).

## Contexte
$ARGUMENTS

## Objectif

Développer du code robuste en écrivant les tests AVANT l'implémentation.
Le TDD garantit une couverture de tests complète et un design émergent.

## Le cycle TDD

```
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │         ┌─────────┐                                         │
    │         │         │                                         │
    │         │   RED   │  ← Écrire un test qui échoue            │
    │         │         │                                         │
    │         └────┬────┘                                         │
    │              │                                              │
    │              ▼                                              │
    │         ┌─────────┐                                         │
    │         │         │                                         │
    │         │  GREEN  │  ← Écrire le minimum de code            │
    │         │         │    pour faire passer le test            │
    │         └────┬────┘                                         │
    │              │                                              │
    │              ▼                                              │
    │         ┌─────────┐                                         │
    │         │         │                                         │
    │         │REFACTOR │  ← Améliorer le code                    │
    │         │         │    sans changer le comportement         │
    │         └────┬────┘                                         │
    │              │                                              │
    │              └──────────────────────────────────────────────┘
    │                        Répéter le cycle
    │
    └─────────────────────────────────────────────────────────────┘
```

## Phase 1 : RED - Écrire les tests

### 1.1 Identifier les cas de test

#### Cas nominaux
- Comportement attendu avec entrées valides
- Flux principal de la fonctionnalité

#### Edge cases
- Entrées vides (null, undefined, "", [], {})
- Entrées aux limites (0, -1, MAX_INT)
- Entrées invalides

#### Cas d'erreur
- Exceptions attendues
- Messages d'erreur appropriés

### 1.2 Structure des tests

```typescript
describe('NomDuModule', () => {
  describe('nomDeLaFonction', () => {
    // Cas nominal
    it('should [comportement attendu] when [condition]', () => {
      // Arrange - Préparer les données
      const input = { /* ... */ };
      const expected = { /* ... */ };

      // Act - Exécuter la fonction
      const result = nomDeLaFonction(input);

      // Assert - Vérifier le résultat
      expect(result).toEqual(expected);
    });

    // Edge case
    it('should handle empty input gracefully', () => {
      expect(nomDeLaFonction(null)).toBeNull();
    });

    // Cas d'erreur
    it('should throw error when input is invalid', () => {
      expect(() => nomDeLaFonction(-1)).toThrow('Invalid input');
    });
  });
});
```

### 1.3 Bonnes pratiques pour les tests

| ✅ Faire | ❌ Ne pas faire |
|----------|-----------------|
| Tests indépendants | Tests qui dépendent d'autres tests |
| Noms descriptifs | Noms vagues (`test1`, `test2`) |
| Une assertion par test | Plusieurs assertions non liées |
| Données de test explicites | Données magiques |
| Mocks uniquement pour I/O | Mocks partout |

### 1.4 Vérifier l'échec

```bash
npm test
```

**Les tests DOIVENT échouer à ce stade.**
- Si les tests passent → ils sont mal écrits
- L'échec prouve que le test vérifie bien quelque chose

### 1.5 Commit des tests

```bash
git add src/__tests__/
git commit -m "test(scope): add tests for [feature]

- Test nominal case
- Test edge cases (empty, null)
- Test error handling"
```

## Phase 2 : GREEN - Implémenter le minimum

### 2.1 Principes

- **Code minimal** : juste assez pour faire passer les tests
- **Pas d'optimisation** : on optimise après
- **Pas de généralisation** : on généralise si nécessaire plus tard
- **Simple et direct** : éviter l'over-engineering

### 2.2 Implémentation

```typescript
// Exemple d'implémentation minimale
export function validateEmail(email: string): boolean {
  // Implémentation simple et directe
  if (!email) return false;
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
```

### 2.3 Vérifier le succès

```bash
npm test
```

**TOUS les tests doivent passer.**
- Si un test échoue → corriger l'implémentation
- Ne pas modifier les tests (sauf s'ils sont incorrects)

## Phase 3 : REFACTOR - Améliorer le code

### 3.1 Axes d'amélioration

| Aspect | Actions |
|--------|---------|
| **Lisibilité** | Noms clairs, fonctions courtes |
| **DRY** | Extraire les duplications |
| **SOLID** | Single responsibility, etc. |
| **Performance** | Optimiser si nécessaire |

### 3.2 Règles du refactoring

- [ ] Les tests passent AVANT le refactoring
- [ ] Les tests passent APRÈS le refactoring
- [ ] Pas de changement de comportement
- [ ] Petites modifications incrémentales

### 3.3 Patterns de refactoring courants

```typescript
// Avant : fonction longue
function processUser(user) {
  // validation
  // transformation
  // sauvegarde
}

// Après : fonctions séparées
function validateUser(user) { /* ... */ }
function transformUser(user) { /* ... */ }
function saveUser(user) { /* ... */ }

function processUser(user) {
  validateUser(user);
  const transformed = transformUser(user);
  return saveUser(transformed);
}
```

### 3.4 Commit du code

```bash
git add src/
git commit -m "feat(scope): implement [feature]

- Add [function/class]
- Handle edge cases
- Include input validation"
```

## Checklist TDD complète

### Phase RED
- [ ] Cas nominaux identifiés et testés
- [ ] Edge cases couverts
- [ ] Cas d'erreur testés
- [ ] Tests échouent (npm test montre des échecs)
- [ ] Tests commités

### Phase GREEN
- [ ] Implémentation minimale
- [ ] Tous les tests passent
- [ ] Pas d'over-engineering

### Phase REFACTOR
- [ ] Code lisible
- [ ] Pas de duplication
- [ ] Tests passent toujours
- [ ] Code commité

## Exemple complet

### Demande : Fonction de calcul de prix avec remise

#### 1. RED - Tests
```typescript
describe('calculatePrice', () => {
  it('should return original price when no discount', () => {
    expect(calculatePrice(100, 0)).toBe(100);
  });

  it('should apply percentage discount correctly', () => {
    expect(calculatePrice(100, 20)).toBe(80);
  });

  it('should handle decimal prices', () => {
    expect(calculatePrice(99.99, 10)).toBeCloseTo(89.99);
  });

  it('should return 0 when price is 0', () => {
    expect(calculatePrice(0, 50)).toBe(0);
  });

  it('should throw when discount > 100', () => {
    expect(() => calculatePrice(100, 150)).toThrow();
  });

  it('should throw when discount < 0', () => {
    expect(() => calculatePrice(100, -10)).toThrow();
  });
});
```

#### 2. GREEN - Implémentation
```typescript
export function calculatePrice(price: number, discountPercent: number): number {
  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }
  return price * (1 - discountPercent / 100);
}
```

#### 3. REFACTOR
```typescript
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

## Agents liés

| Avant | Usage |
|-------|-------|
| `/work-plan` | Planifier avant de coder |
| `/work-explore` | Comprendre le contexte |

| Après | Usage |
|-------|-------|
| `/qa-review` | Review du code |
| `/work-commit` | Commiter proprement |

---

IMPORTANT: Ne jamais écrire le code avant les tests.

IMPORTANT: Un test qui passe dès le début est un MAUVAIS test.

YOU MUST couvrir les edge cases (null, undefined, empty, limites).

NEVER utiliser de mocks sauf pour les dépendances externes (API, DB, filesystem).

NEVER modifier un test pour le faire passer - corriger l'implémentation.

Think hard sur les cas de test avant de coder.
