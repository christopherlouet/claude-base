# Exemple de développement d'API

## Contexte
Créer un endpoint pour gérer les produits d'un e-commerce.

## Contrat défini

### Endpoint
`POST /api/v1/products`

### Request
```json
{
  "name": "iPhone 15 Pro",
  "description": "Smartphone Apple dernière génération",
  "price": 1199.99,
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
    "description": "Smartphone Apple dernière génération",
    "price": 1199.99,
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

## Implémentation

### 1. Schema de validation (Zod)

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

### 5. Documentation OpenAPI

```yaml
# openapi/products.yaml
paths:
  /api/v1/products:
    post:
      summary: Créer un produit
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
          description: Produit créé
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

## Résultat

Endpoint créé avec:
- Validation Zod
- Gestion d'erreurs
- Documentation OpenAPI
- Tests d'intégration
- Authentification requise
