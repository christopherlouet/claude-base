---
sidebar_position: 5
title: "dev-api"
description: "Develop and document a REST or GraphQL API. Use when the user wants to create an endpoint, a route, or structure an API."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-api

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Develop and document a REST or GraphQL API. Use when the user wants to create an endpoint, a route, or structure an API.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Edit`, `Write`, `Bash`, `Grep`, `Glob` |
| **Keywords** | `dev`, `api`, `field1`, `string`, `field2`, `success`, `data` |

## Detailed description

# Develop an API

## Objective

Create well-structured, documented and testable APIs.

## Instructions

### 1. Define the contract

Before coding, define:
- Endpoint (URL, HTTP method)
- Request (body, query params, headers)
- Response (status codes, body)
- Possible errors

### 2. RESTful structure

```
GET    /resources          → List (with pagination)
GET    /resources/:id      → Detail
POST   /resources          → Create
PUT    /resources/:id      → Full update
PATCH  /resources/:id      → Partial update
DELETE /resources/:id      → Delete
```

### 3. Standard response format

```typescript
// Success
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Required" }
    ]
  }
}
```

### 4. Input validation

```typescript
// With Zod
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user')
});

// In the handler
const data = createUserSchema.parse(req.body);
```

### 5. OpenAPI documentation

```yaml
paths:
  /users:
    post:
      summary: Create a user
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
```

### 6. API tests

```typescript
describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test' })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe('test@example.com');
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Test' })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

## API Checklist

- [ ] RESTful endpoint
- [ ] Input validation (Zod/Joi)
- [ ] Centralized error handling
- [ ] Appropriate status codes
- [ ] OpenAPI documentation
- [ ] Integration tests
- [ ] Rate limiting (if public)
- [ ] Authentication (if private)

## Expected output

```markdown
## API: [Endpoint name]

### Endpoint
`POST /api/v1/resources`

### Request
```json
{
  "field1": "string",
  "field2": 123
}
```

### Response (201)
```json
{
  "success": true,
  "data": { ... }
}
```

### Errors
| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Invalid data |
| NOT_FOUND | 404 | Resource not found |
| UNAUTHORIZED | 401 | Not authenticated |
```

## Rules

- IMPORTANT: Always validate inputs
- IMPORTANT: Document with OpenAPI
- YOU MUST return appropriate HTTP status codes
- NEVER expose internal errors in production

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to api..."_
- _"I want to field1..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. API development example

# API development example

## Context
Create an endpoint to manage products of an e-commerce.

## Defined contract

### Endpoint
`POST /api/v1/products`

### Request
```json
{
  "name": "iPhone 15 Pro",
  "description": "Latest generation Apple smartphone",
  "price": 1209.99,
  "category": "electronics",
  "stock": 50
}
```

### Responses

**201 Created**
```json
{
  "success": true,
  "data": {
    "id": "prod_abc123",
    "name": "iPhone 15 Pro",
    "description": "Latest generation Apple smartphone",
    "price": 1209.99,
    "category": "electronics",
    "stock": 50,
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

**400 Bad Request**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data",
    "details": [
      { "field": "price", "message": "Must be a positive number" }
    ]
  }
}
```

## Implementation

### 1. Validation schema (Zod)

```typescript
// src/schemas/product.ts
import { z } from 'zod';

export const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().max(2000).optional(),
  price: z.number().positive(),
  category: z.enum(['electronics', 'clothing', 'food', 'other']),
  stock: z.number().int().min(0).default(0)
});

export type CreateProductInput = z.infer<typeof createProductSchema>;
```

### 2. Service

```typescript
// src/services/product.service.ts
import { db } from '@/lib/db';
import { CreateProductInput } from '@/schemas/product';

export class ProductService {
  async create(input: CreateProductInput) {
    const product = await db.product.create({
      data: {
        ...input,
        id: `prod_${generateId()}`
      }
    });
    return product;
  }
}
```

### 3. Controller

```typescript
// src/controllers/product.controller.ts
import { Request, Response, NextFunction } from 'express';
import { createProductSchema } from '@/schemas/product';
import { ProductService } from '@/services/product.service';

const productService = new ProductService();

export async function createProduct(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    const data = createProductSchema.parse(req.body);
    const product = await productService.create(data);

    res.status(201).json({
      success: true,
      data: product
    });
  } catch (error) {
    next(error);
  }
}
```

### 4. Route

```typescript
// src/routes/products.ts
import { Router } from 'express';
import { createProduct } from '@/controllers/product.controller';
import { authenticate } from '@/middleware/auth';

const router = Router();

router.post('/', authenticate, createProduct);

export default router;
```

### 5. OpenAPI documentation

```yaml
# openapi/products.yaml
paths:
  /api/v1/products:
    post:
      summary: Create a product
      tags: [Products]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [name, price, category]
              properties:
                name:
                  type: string
                  minLength: 1
                  maxLength: 200
                description:
                  type: string
                  maxLength: 2000
                price:
                  type: number
                  minimum: 0.01
                category:
                  type: string
                  enum: [electronics, clothing, food, other]
                stock:
                  type: integer
                  minimum: 0
                  default: 0
      responses:
        '201':
          description: Product created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProductResponse'
        '400':
          $ref: '#/components/responses/ValidationError'
        '401':
          $ref: '#/components/responses/Unauthorized'
```

### 6. Tests

```typescript
// tests/products.test.ts
import request from 'supertest';
import { app } from '@/app';
import { db } from '@/lib/db';

describe('POST /api/v1/products', () => {
  const validProduct = {
    name: 'Test Product',
    price: 99.99,
    category: 'electronics'
  };

  it('should create product with valid data', async () => {
    const response = await request(app)
      .post('/api/v1/products')
      .set('Authorization', `Bearer ${testToken}`)
      .send(validProduct)
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.name).toBe('Test Product');
    expect(response.body.data.id).toMatch(/^prod_/);
  });

  it('should return 400 for negative price', async () => {
    const response = await request(app)
      .post('/api/v1/products')
      .set('Authorization', `Bearer ${testToken}`)
      .send({ ...validProduct, price: -10 })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('should return 401 without auth', async () => {
    await request(app)
      .post('/api/v1/products')
      .send(validProduct)
      .expect(401);
  });
});
```

## Result

Endpoint created with:
- Zod validation
- Error handling
- OpenAPI documentation
- Integration tests
- Authentication required



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
