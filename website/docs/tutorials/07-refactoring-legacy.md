---
sidebar_position: 8
title: "07 - Legacy Refactoring"
description: Refactor a legacy project using TDD and a methodical approach
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Legacy Project Refactoring

<DifficultyBadge level="advanced" /> **Estimated duration: 60 minutes**

This tutorial shows you how to methodically refactor a legacy project using TDD and the claude-socle tools.

## Objectives

By the end of this tutorial, you will know how to:
- Use `/work:work-explore` to map a legacy codebase
- Use `/qa:qa-tech-debt` to prioritize refactoring
- Use `/dev:dev-tdd` to refactor safely
- Apply progressive refactoring patterns

## Prerequisites

- A "legacy" project to refactor
- Development experience
- Patience and method

## Context

Refactoring a legacy codebase is risky. Without tests, every change can introduce bugs. The strategy:

1. **Understand** before touching
2. **Test** existing behavior
3. **Refactor** little by little
4. **Validate** after each change

## Step 1: Map the project

```bash
/work:work-explore "Analyze this legacy project: architecture, dependencies, pain points"
```

Claude will identify:
- The project structure
- The technologies used
- The most modified files (hotspots)
- Dependencies between modules
- Patterns used (or their absence)

**Example output:**

```markdown
## Legacy project analysis

### Structure
```
src/
├── controllers/     # 15 files, mixed business logic
├── models/          # 8 files, validation in controllers
├── routes/          # 3 files, everything in index.js
├── utils/           # 12 files, lots of duplication
└── index.js         # Entry point, 500 lines
```

### Technologies
- Node.js 12 (EOL)
- Express 4.16 (old)
- MySQL with raw SQL queries
- No TypeScript
- No tests

### Hotspots (problematic files)
1. `src/controllers/orderController.js` (800 lines)
2. `src/utils/helpers.js` (400 lines, mixed functions)
3. `src/routes/index.js` (all routes in one file)

### Critical dependencies
- lodash used everywhere (4.17.4, vulnerable)
- moment.js (deprecated)
- mysql (no connection pool)

### Estimated technical debt
- 🔴 Critical: SQL injection, Node EOL
- 🟠 High: No tests, tight coupling
- 🟡 Medium: Duplication, inconsistent naming
```

## Step 2: Prioritize technical debt

```bash
/qa:qa-tech-debt
```

Claude will prioritize the items to address:

```markdown
## Technical debt prioritization

### 🔴 Priority 1 - Security (Sprint 1)
| Item | Risk | Effort | Action |
|------|------|--------|--------|
| SQL Injection | Critical | Medium | Migrate to prepared statements |
| Node 12 EOL | High | Low | Upgrade to Node 20 |
| Vulnerable lodash | High | Low | npm audit fix |

### 🟠 Priority 2 - Testability (Sprint 2)
| Item | Risk | Effort | Action |
|------|------|--------|--------|
| orderController.js | High | High | Extract services, add tests |
| No tests | High | Medium | Add tests on critical paths |

### 🟡 Priority 3 - Maintainability (Sprint 3+)
| Item | Risk | Effort | Action |
|------|------|--------|--------|
| TypeScript | Medium | High | Progressive migration |
| moment.js | Low | Medium | Migrate to date-fns |
| Duplication | Medium | Medium | Extract common functions |
```

## Step 3: Secure first

Before any refactoring, let's fix the security issues.

### Update Node.js

```bash
# Check compatibility
nvm install 20
nvm use 20
npm test  # If there are tests
npm start # Verify it works
```

### Fix dependencies

```bash
/ops:ops-deps
```

```bash
npm audit fix
npm update lodash
```

### Fix SQL injection

**Before (vulnerable):**
```javascript
// src/controllers/orderController.js
const getOrder = async (req, res) => {
  const sql = `SELECT * FROM orders WHERE id = ${req.params.id}`;
  const [rows] = await db.query(sql);
  res.json(rows[0]);
};
```

**After (secure):**
```javascript
const getOrder = async (req, res) => {
  const sql = 'SELECT * FROM orders WHERE id = ?';
  const [rows] = await db.query(sql, [req.params.id]);
  res.json(rows[0]);
};
```

## Step 4: Add tests for existing behavior

Before refactoring, we capture the current behavior with tests.

```bash
/dev:dev-tdd "Add characterization tests for orderController"
```

**Characterization tests:**

```javascript
// tests/orderController.test.js
const request = require('supertest');
const app = require('../src/app');

describe('OrderController - Existing behavior', () => {
  // These tests document the CURRENT behavior
  // even if it is incorrect

  describe('GET /orders/:id', () => {
    it('should return order with products', async () => {
      const response = await request(app)
        .get('/orders/1')
        .expect(200);

      // Document the current structure
      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('customer_id');
      expect(response.body).toHaveProperty('products');
    });

    it('should return 500 for invalid id (current bug)', async () => {
      // Document the current bug
      // Should be 404 but returns 500
      const response = await request(app)
        .get('/orders/invalid')
        .expect(500);
    });
  });

  describe('POST /orders', () => {
    it('should create order with current validation', async () => {
      const response = await request(app)
        .post('/orders')
        .send({
          customer_id: 1,
          products: [{ id: 1, quantity: 2 }]
        })
        .expect(201);

      expect(response.body.id).toBeDefined();
    });
  });
});
```

:::tip Characterization tests
Characterization tests capture the current behavior, **bugs included**. They serve as a safety net during refactoring.
:::

## Step 5: Refactor with the "Strangler Fig" pattern

The Strangler Fig pattern allows you to progressively replace the legacy code.

### Create the new structure

```bash
mkdir -p src/features/orders/{domain,application,infrastructure}
```

### Extract the domain

```bash
/dev:dev-refactor "Extract the business logic from orderController to a dedicated service"
```

**New service:**

```typescript
// src/features/orders/application/OrderService.ts
import { Order, OrderItem } from '../domain/Order';
import { OrderRepository } from '../domain/OrderRepository';

export class OrderService {
  constructor(private readonly orderRepository: OrderRepository) {}

  async getOrder(id: string): Promise<Order | null> {
    return this.orderRepository.findById(id);
  }

  async createOrder(customerId: string, items: OrderItem[]): Promise<Order> {
    const order = Order.create(customerId, items);
    await this.orderRepository.save(order);
    return order;
  }

  async calculateTotal(orderId: string): Promise<number> {
    const order = await this.orderRepository.findById(orderId);
    if (!order) throw new Error('Order not found');
    return order.calculateTotal();
  }
}
```

### Replace progressively

```javascript
// src/controllers/orderController.js (progressive migration)
const { OrderService } = require('../features/orders/application/OrderService');
const { MySQLOrderRepository } = require('../features/orders/infrastructure/MySQLOrderRepository');

// New code
const orderService = new OrderService(new MySQLOrderRepository(db));

// Old routes point to the new service
const getOrder = async (req, res) => {
  try {
    const order = await orderService.getOrder(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

## Step 6: Migrate to TypeScript progressively

```bash
/ops:ops-migrate "Progressively migrate to TypeScript"
```

### Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "allowJs": true,           // Allows existing JS
    "checkJs": false,          // Does not check JS
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### File-by-file migration

1. Rename `.js` to `.ts`
2. Add types
3. Run the tests
4. Move to the next file

## Step 7: Validate the refactoring

```bash
# Run all tests
npm test

# Check coverage
npm run test:coverage

# Final security audit
/qa:qa-security
```

## Step 8: Commit by steps

Each refactoring step should be a separate commit:

```bash
# Commit 1 - Security
git add -A && git commit -m "fix(security): parameterize SQL queries"

# Commit 2 - Tests
git add -A && git commit -m "test: add characterization tests for orders"

# Commit 3 - Service extraction
git add -A && git commit -m "refactor(orders): extract OrderService"

# Commit 4 - TypeScript
git add -A && git commit -m "refactor: migrate orders to TypeScript"
```

## Refactoring strategies

| Pattern | When to use it |
|---------|----------------|
| **Strangler Fig** | Progressive replacement of a system |
| **Branch by Abstraction** | Change an implementation without breaking the API |
| **Extract Method/Class** | Reduce the complexity of a function/class |
| **Characterization Tests** | Capture behavior before modifying |

## Refactoring checklist

- [ ] Characterization tests in place
- [ ] No regression after each change
- [ ] Atomic and descriptive commits
- [ ] Code review for each PR
- [ ] Documentation updated

## Next steps

- [Tutorial 08: Proxmox Infrastructure](/docs/tutorials/proxmox-infra)
- [qa-tech-debt agent](/docs/agents/qa-tech-debt)
- [/dev:dev-refactor command](/docs/commands/dev/dev-refactor)

---

:::warning Golden rule
**Never refactor without tests.** If the code has no tests, add some first.
:::
