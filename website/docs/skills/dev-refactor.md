---
sidebar_position: 18
title: "dev-refactor"
description: "Code refactoring to improve quality. Trigger when the user wants to clean up, restructure, or improve existing code."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-refactor

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Code refactoring to improve quality. Trigger when the user wants to clean up, restructure, or improve existing code.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `dev`, `refactor` |

## Detailed description

# Code Refactoring

## Principles

1. **Tests pass BEFORE and AFTER**
2. **Small incremental changes**
3. **One type of change at a time**
4. **Commit after each refactoring**

## Common techniques

### Extract Function

```typescript
// Before
function processOrder(order) {
  // 20 lines of validation
  // 30 lines of calculation
  // 10 lines of sending
}

// After
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  sendConfirmation(order, total);
}
```

### Extract Variable

```typescript
// Before
if (user.age >= 18 && user.country === 'FR' && !user.banned) { }

// After
const isAdult = user.age >= 18;
const isFrench = user.country === 'FR';
const isActive = !user.banned;
if (isAdult && isFrench && isActive) { }
```

### Replace Conditional with Polymorphism

```typescript
// Before
function getPrice(type) {
  switch(type) {
    case 'basic': return 10;
    case 'premium': return 20;
  }
}

// After
interface Plan { getPrice(): number }
class BasicPlan implements Plan { getPrice() { return 10; } }
class PremiumPlan implements Plan { getPrice() { return 20; } }
```

## Code Smells to detect

| Smell | Refactoring |
|-------|-------------|
| Long method | Extract Method |
| Large class | Extract Class |
| Duplicate code | Extract + Reuse |
| Long parameter list | Parameter Object |
| Feature envy | Move Method |
| Primitive obsession | Value Object |

## Reducing Entropy (Complexity reduction)

### Complexity metrics

| Metric | Alert threshold | How to measure |
|--------|----------------|----------------|
| **Cyclomatic complexity** | > 10 per function | Number of branches (if/else/switch) |
| **Nesting depth** | > 3 levels | Nesting of if/for/while |
| **Function length** | > 50 lines | Number of lines |
| **Number of parameters** | > 4 | Function parameters |
| **Afferent/efferent coupling** | Unstable ratio | Incoming/outgoing dependencies |
| **File size** | > 300 lines | Lines of code |

### Reduction techniques

#### Early Return (eliminate nesting)

```typescript
// BEFORE: deep nesting (high entropy)
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

// AFTER: early returns (low entropy)
function process(user) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;
  return doWork(user);
}
```

#### Break down complex conditions

```typescript
// BEFORE
if (user.age >= 18 && user.country === 'FR' && !user.banned && user.email.includes('@')) { }

// AFTER
const isEligible = user.age >= 18
  && user.country === 'FR'
  && !user.banned
  && isValidEmail(user.email);
if (isEligible) { }
```

#### Eliminate dead code

```bash
# Find unused exports
# Find functions never called
# Remove unused imports
# Remove obsolete comments
# Remove orphan files
```

#### Consolidate duplications

```
Rule of 3: refactor on the 3rd duplication, not before.
- 1st occurrence: write the code
- 2nd occurrence: note the duplication (comment)
- 3rd occurrence: extract into a function/module
```

## Workflow

1. MEASURE current complexity (metrics)
2. Identify the code smell
3. Write/verify tests
4. Apply the refactoring
5. MEASURE complexity after (must decrease)
6. Verify tests
7. Commit
8. Repeat

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to refactor..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


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

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
