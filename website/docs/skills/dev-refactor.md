---
sidebar_position: 18
title: "dev-refactor"
description: "Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur veut nettoyer, restructurer, ou ameliorer du code existant."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-refactor

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur veut nettoyer, restructurer, ou ameliorer du code existant.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `refactor` |

## Description detaillee

# Code Refactoring

## Principes

1. **Les tests passent AVANT et APRES**
2. **Petites modifications incrementales**
3. **Un seul type de changement a la fois**
4. **Commit apres chaque refactoring**

## Techniques courantes

### Extract Function

```typescript
// Avant
function processOrder(order) {
  // 20 lignes de validation
  // 30 lignes de calcul
  // 10 lignes d'envoi
}

// Apres
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  sendConfirmation(order, total);
}
```

### Extract Variable

```typescript
// Avant
if (user.age >= 18 && user.country === 'FR' && !user.banned) { }

// Apres
const isAdult = user.age >= 18;
const isFrench = user.country === 'FR';
const isActive = !user.banned;
if (isAdult && isFrench && isActive) { }
```

### Replace Conditional with Polymorphism

```typescript
// Avant
function getPrice(type) {
  switch(type) {
    case 'basic': return 10;
    case 'premium': return 20;
  }
}

// Apres
interface Plan { getPrice(): number }
class BasicPlan implements Plan { getPrice() { return 10; } }
class PremiumPlan implements Plan { getPrice() { return 20; } }
```

## Code Smells a detecter

| Smell | Refactoring |
|-------|-------------|
| Long method | Extract Method |
| Large class | Extract Class |
| Duplicate code | Extract + Reuse |
| Long parameter list | Parameter Object |
| Feature envy | Move Method |
| Primitive obsession | Value Object |

## Reducing Entropy (Reduction de complexite)

### Metriques de complexite

| Metrique | Seuil d'alerte | Comment mesurer |
|----------|---------------|-----------------|
| **Complexite cyclomatique** | > 10 par fonction | Nombre de branches (if/else/switch) |
| **Profondeur d'imbrication** | > 3 niveaux | Nesting de if/for/while |
| **Longueur de fonction** | > 50 lignes | Nombre de lignes |
| **Nombre de parametres** | > 4 | Parametres de fonction |
| **Couplage afferent/efferent** | Ratio instable | Dependances entrantes/sortantes |
| **Taille de fichier** | > 300 lignes | Lignes de code |

### Techniques de reduction

#### Early Return (eliminer l'imbrication)

```typescript
// AVANT: imbrication profonde (entropie haute)
function process(user) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        return doWork(user);
      }
    }
  }
  return null;
}

// APRES: early returns (entropie basse)
function process(user) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;
  return doWork(user);
}
```

#### Decomposer les conditions complexes

```typescript
// AVANT
if (user.age >= 18 && user.country === 'FR' && !user.banned && user.email.includes('@')) { }

// APRES
const isEligible = user.age >= 18
  && user.country === 'FR'
  && !user.banned
  && isValidEmail(user.email);
if (isEligible) { }
```

#### Eliminer le code mort

```bash
# Trouver les exports non utilises
# Trouver les fonctions jamais appelees
# Supprimer les imports inutiles
# Retirer les commentaires obsoletes
# Enlever les fichiers orphelins
```

#### Consolider les duplications

```
Regle des 3 : refactorer a la 3eme duplication, pas avant.
- 1ere occurrence : ecrire le code
- 2eme occurrence : noter la duplication (commentaire)
- 3eme occurrence : extraire dans une fonction/module
```

## Workflow

1. MESURER la complexite actuelle (metriques)
2. Identifier le code smell
3. Ecrire/verifier les tests
4. Appliquer le refactoring
5. MESURER la complexite apres (doit diminuer)
6. Verifier les tests
7. Commit
8. Repeter

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux refactor..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Extract Service Refactoring

# Example: Extract Service Refactoring

## Scenario
A controller has grown to handle business logic, validation, and notifications. Extract a service layer.

## Before: Fat Controller

```typescript
// controllers/order.controller.ts (BEFORE - 80+ lines of mixed concerns)
export async function createOrder(req: Request, res: Response) {
  // Validation mixed in controller
  if (!req.body.items || req.body.items.length === 0) {
    return res.status(400).json({ error: 'Items required' });
  }

  // Business logic in controller
  let total = 0;
  for (const item of req.body.items) {
    const product = await db.product.findUnique({ where: { id: item.productId } });
    if (!product) return res.status(404).json({ error: `Product ${item.productId} not found` });
    if (product.stock < item.quantity) return res.status(400).json({ error: 'Insufficient stock' });
    total += product.price * item.quantity;
    await db.product.update({ where: { id: item.productId }, data: { stock: { decrement: item.quantity } } });
  }

  const order = await db.order.create({ data: { userId: req.user.id, total, items: req.body.items } });

  // Side effect in controller
  await sendEmail(req.user.email, `Order ${order.id} confirmed`);
  await notifySlack(`New order: ${order.id} - $${total}`);

  res.status(201).json({ data: order });
}
```

## After: Extracted Service

```typescript
// services/order.service.ts (AFTER - single responsibility)
export class OrderService {
  constructor(
    private db: Database,
    private notifier: NotificationService,
  ) {}

  async create(userId: string, items: OrderItem[]): Promise<Order> {
    if (items.length === 0) throw new ValidationError('Items required');

    const total = await this.calculateAndReserveStock(items);
    const order = await this.db.order.create({
      data: { userId, total, items },
    });

    await this.notifier.orderCreated(order);
    return order;
  }

  private async calculateAndReserveStock(items: OrderItem[]): Promise<number> {
    let total = 0;
    for (const item of items) {
      const product = await this.db.product.findUniqueOrThrow(item.productId);
      if (product.stock < item.quantity) {
        throw new InsufficientStockError(item.productId);
      }
      total += product.price * item.quantity;
      await this.db.product.decrementStock(item.productId, item.quantity);
    }
    return total;
  }
}

// controllers/order.controller.ts (AFTER - thin controller)
export async function createOrder(req: Request, res: Response, next: NextFunction) {
  try {
    const order = await orderService.create(req.user.id, req.body.items);
    res.status(201).json({ data: order });
  } catch (error) {
    next(error);  // Error middleware handles status codes
  }
}
```

## Refactoring Steps

1. **Identify responsibilities**: Validation, business logic, persistence, notifications
2. **Create service class**: Move business logic into `OrderService`
3. **Extract domain errors**: `ValidationError`, `InsufficientStockError` replace inline responses
4. **Inject dependencies**: `Database` and `NotificationService` via constructor
5. **Thin controller**: Only HTTP concerns (parse request, call service, send response)
6. **Run tests**: Existing tests should pass; add unit tests for service

## Key Decisions

- **Constructor injection**: Dependencies explicit, easy to mock in tests
- **Domain errors over HTTP errors**: Service throws `ValidationError`, middleware maps to 400
- **Private helper methods**: `calculateAndReserveStock` keeps `create()` readable
- **Notification abstraction**: `NotificationService` wraps email + Slack (single responsibility)



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
