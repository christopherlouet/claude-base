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
