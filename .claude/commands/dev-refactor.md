# Agent REFACTOR

Refactoring de code avec préservation du comportement et amélioration de la qualité.

## Cible du refactoring
$ARGUMENTS

## Objectif

Améliorer la structure, la lisibilité et la maintenabilité du code
SANS changer son comportement externe.

## Principes fondamentaux

```
┌─────────────────────────────────────────────────────────────┐
│                    RÈGLES D'OR DU REFACTORING                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Le comportement externe NE DOIT PAS changer            │
│  2. Les tests existants DOIVENT continuer à passer         │
│  3. Un changement à la fois, test après chaque changement  │
│  4. Commits atomiques pour chaque transformation           │
│  5. Si les tests manquent, les ajouter AVANT de refactorer │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Workflow de refactoring

```
┌─────────────────────────────────────────────────────────────┐
│                  REFACTORING WORKFLOW                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. PRÉPARER    → Vérifier tests, couverture               │
│  ══════════                                                 │
│        ↓                                                    │
│  2. ANALYSER    → Identifier les code smells               │
│  ══════════                                                 │
│        ↓                                                    │
│  3. PLANIFIER   → Lister transformations par priorité      │
│  ═══════════                                                │
│        ↓                                                    │
│  ┌─────────────────────────────────────────┐               │
│  │  4. POUR CHAQUE TRANSFORMATION :        │               │
│  │     a. Appliquer UNE transformation     │  ← BOUCLE    │
│  │     b. Lancer les tests                 │               │
│  │     c. Si OK → commit                   │               │
│  │     d. Si KO → revert et analyser       │               │
│  └─────────────────────────────────────────┘               │
│        ↓                                                    │
│  5. VALIDER     → Tests finaux, review                     │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Préparation

### Vérifications préalables

```bash
# 1. Lancer tous les tests
npm test

# 2. Vérifier la couverture
npm run test:coverage

# 3. Vérifier le lint
npm run lint

# 4. Créer une branche de refactoring
git checkout -b refactor/description-courte
```

### Seuils de couverture

| Couverture | Action |
|------------|--------|
| > 80% | ✅ Refactoring sûr |
| 60-80% | ⚠️ Ajouter quelques tests d'abord |
| < 60% | 🛑 Ajouter tests avant tout refactoring |

## Étape 2 : Analyse - Code Smells

### Catalogue des code smells

| Smell | Description | Sévérité | Solution |
|-------|-------------|----------|----------|
| **Long Method** | Fonction > 20 lignes | Haute | Extract Method |
| **Large Class** | Classe > 200 lignes | Haute | Extract Class |
| **Long Parameter List** | > 3 paramètres | Moyenne | Parameter Object |
| **Duplicate Code** | Code répété | Haute | Extract et réutiliser |
| **Dead Code** | Code jamais exécuté | Moyenne | Supprimer |
| **Magic Numbers** | Valeurs sans nom | Basse | Constantes nommées |
| **Deep Nesting** | > 3 niveaux | Moyenne | Early return, extract |
| **Feature Envy** | Méthode utilise trop autre classe | Moyenne | Move Method |
| **Data Clumps** | Groupes de données répétés | Moyenne | Extract Class |
| **Primitive Obsession** | Primitifs au lieu d'objets | Basse | Value Objects |
| **Switch Statements** | Switch répétés | Moyenne | Polymorphisme |
| **Speculative Generality** | Code "au cas où" | Basse | YAGNI - Supprimer |
| **Comments** | Commentaires excessifs | Basse | Code auto-documenté |

### Checklist d'identification

```markdown
## Code Smells Identifiés

### Haute priorité
- [ ] [Fichier:ligne] - [Description du smell]
- [ ] [Fichier:ligne] - [Description du smell]

### Moyenne priorité
- [ ] [Fichier:ligne] - [Description du smell]

### Basse priorité
- [ ] [Fichier:ligne] - [Description du smell]
```

## Étape 3 : Plan de refactoring

### Template de plan

```markdown
## Plan de Refactoring

### Objectif
[Ce que le refactoring doit accomplir]

### Transformations planifiées

| # | Transformation | Fichier | Risque | Priorité |
|---|----------------|---------|--------|----------|
| 1 | [Description] | [file.ts] | Faible | Haute |
| 2 | [Description] | [file.ts] | Moyen | Moyenne |

### Ordre d'exécution
1. [Transformation la plus sûre d'abord]
2. [Puis les dépendantes]
3. [Puis les risquées]

### Critères de succès
- [ ] Tous les tests passent
- [ ] Couverture maintenue ou améliorée
- [ ] Pas de régression fonctionnelle
```

## Étape 4 : Techniques de refactoring

### Extract Method

```typescript
// ❌ Avant: fonction longue
function processOrder(order: Order) {
  // Validation
  if (!order.items || order.items.length === 0) {
    throw new Error('Order must have items');
  }
  if (!order.customer) {
    throw new Error('Order must have customer');
  }

  // Calcul du total
  let total = 0;
  for (const item of order.items) {
    total += item.price * item.quantity;
  }

  // Application des remises
  if (order.customer.isPremium) {
    total *= 0.9;
  }

  return total;
}

// ✅ Après: fonctions extraites
function validateOrder(order: Order): void {
  if (!order.items?.length) {
    throw new Error('Order must have items');
  }
  if (!order.customer) {
    throw new Error('Order must have customer');
  }
}

function calculateSubtotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

function applyDiscount(total: number, customer: Customer): number {
  return customer.isPremium ? total * 0.9 : total;
}

function processOrder(order: Order): number {
  validateOrder(order);
  const subtotal = calculateSubtotal(order.items);
  return applyDiscount(subtotal, order.customer);
}
```

### Replace Conditional with Polymorphism

```typescript
// ❌ Avant: switch statement
function calculateShipping(order: Order): number {
  switch (order.shippingType) {
    case 'standard':
      return order.weight * 0.5;
    case 'express':
      return order.weight * 1.5 + 10;
    case 'overnight':
      return order.weight * 3 + 25;
    default:
      throw new Error('Unknown shipping type');
  }
}

// ✅ Après: polymorphisme
interface ShippingStrategy {
  calculate(weight: number): number;
}

class StandardShipping implements ShippingStrategy {
  calculate(weight: number): number {
    return weight * 0.5;
  }
}

class ExpressShipping implements ShippingStrategy {
  calculate(weight: number): number {
    return weight * 1.5 + 10;
  }
}

class OvernightShipping implements ShippingStrategy {
  calculate(weight: number): number {
    return weight * 3 + 25;
  }
}

const shippingStrategies: Record<string, ShippingStrategy> = {
  standard: new StandardShipping(),
  express: new ExpressShipping(),
  overnight: new OvernightShipping(),
};

function calculateShipping(order: Order): number {
  const strategy = shippingStrategies[order.shippingType];
  if (!strategy) throw new Error('Unknown shipping type');
  return strategy.calculate(order.weight);
}
```

### Introduce Parameter Object

```typescript
// ❌ Avant: trop de paramètres
function createUser(
  firstName: string,
  lastName: string,
  email: string,
  phone: string,
  address: string,
  city: string,
  country: string
) {
  // ...
}

// ✅ Après: parameter object
interface CreateUserParams {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  address: Address;
}

interface Address {
  street: string;
  city: string;
  country: string;
}

function createUser(params: CreateUserParams) {
  // ...
}
```

### Replace Magic Numbers

```typescript
// ❌ Avant: magic numbers
function calculatePrice(quantity: number): number {
  if (quantity > 100) {
    return quantity * 0.8;
  } else if (quantity > 50) {
    return quantity * 0.9;
  }
  return quantity * 1.0;
}

// ✅ Après: constantes nommées
const BULK_THRESHOLD = 100;
const MEDIUM_THRESHOLD = 50;
const BULK_DISCOUNT = 0.8;
const MEDIUM_DISCOUNT = 0.9;
const NO_DISCOUNT = 1.0;

function calculatePrice(quantity: number): number {
  if (quantity > BULK_THRESHOLD) {
    return quantity * BULK_DISCOUNT;
  }
  if (quantity > MEDIUM_THRESHOLD) {
    return quantity * MEDIUM_DISCOUNT;
  }
  return quantity * NO_DISCOUNT;
}
```

### Simplify Conditionals

```typescript
// ❌ Avant: conditions complexes
function canAccess(user: User, resource: Resource): boolean {
  if (user.role === 'admin') {
    return true;
  } else if (user.role === 'editor' && resource.type === 'article') {
    return true;
  } else if (user.id === resource.ownerId) {
    return true;
  }
  return false;
}

// ✅ Après: early returns et fonctions dédiées
function canAccess(user: User, resource: Resource): boolean {
  if (isAdmin(user)) return true;
  if (isEditorOfArticle(user, resource)) return true;
  if (isOwner(user, resource)) return true;
  return false;
}

const isAdmin = (user: User) => user.role === 'admin';
const isEditorOfArticle = (user: User, resource: Resource) =>
  user.role === 'editor' && resource.type === 'article';
const isOwner = (user: User, resource: Resource) =>
  user.id === resource.ownerId;
```

## Étape 5 : Validation

### Checklist de validation

```markdown
## Validation Post-Refactoring

### Tests
- [ ] Tous les tests unitaires passent
- [ ] Tous les tests d'intégration passent
- [ ] Couverture >= couverture initiale
- [ ] Pas de nouveaux warnings

### Qualité
- [ ] Lint passe sans erreur
- [ ] TypeScript compile sans erreur
- [ ] Complexité cyclomatique réduite

### Review
- [ ] Code plus lisible
- [ ] Noms plus explicites
- [ ] Fonctions plus courtes
- [ ] Moins de duplication
```

## Output attendu

### Analyse initiale

```markdown
## Analyse Refactoring

**Fichier(s) ciblé(s):** [liste]
**Lignes de code:** [avant] → [après estimé]
**Couverture actuelle:** [X%]

### Code smells identifiés
1. [Smell] - [Fichier:ligne] - Sévérité: [Haute/Moyenne/Basse]
2. [Smell] - [Fichier:ligne] - Sévérité: [Haute/Moyenne/Basse]

### Risques
- [Risque 1] → [Mitigation]
- [Risque 2] → [Mitigation]
```

### Transformations appliquées

```markdown
## Transformations Effectuées

| # | Transformation | Commit | Tests |
|---|----------------|--------|-------|
| 1 | [Description] | [hash] | ✅ |
| 2 | [Description] | [hash] | ✅ |

### Résultat
- **Tests:** Tous passent ✅
- **Couverture:** [X%] → [Y%]
- **Lignes:** [avant] → [après]
- **Complexité:** Réduite de [X%]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Comprendre le code avant refactoring |
| `/test` | Ajouter tests manquants |
| `/review` | Review post-refactoring |
| `/commit` | Commits atomiques |
| `/explain` | Comprendre du code complexe |

---

IMPORTANT: Le comportement externe NE DOIT PAS changer.

IMPORTANT: Small steps. Un changement à la fois. Test après chaque changement.

YOU MUST avoir une couverture de tests suffisante AVANT de refactorer.

YOU MUST faire des commits atomiques à chaque transformation.

NEVER refactorer et ajouter des fonctionnalités en même temps.

Think hard sur l'ordre des transformations pour minimiser les risques.
