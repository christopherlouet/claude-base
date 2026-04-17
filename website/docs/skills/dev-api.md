---
sidebar_position: 5
title: "dev-api"
description: "Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur veut créer un endpoint, une route, ou structurer une API."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-api

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur veut créer un endpoint, une route, ou structurer une API.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Edit`, `Write`, `Bash`, `Grep`, `Glob` |
| **Mots-cles** | `dev`, `api`, `field1`, `string`, `field2`, `success`, `data` |

## Description detaillee

# Développer une API

## Objectif

Créer des APIs bien structurées, documentées et testables.

## Instructions

### 1. Définir le contrat

Avant de coder, définir:
- Endpoint (URL, méthode HTTP)
- Request (body, query params, headers)
- Response (status codes, body)
- Erreurs possibles

### 2. Structure RESTful

```
GET    /resources          → Liste (avec pagination)
GET    /resources/:id      → Détail
POST   /resources          → Création
PUT    /resources/:id      → Mise à jour complète
PATCH  /resources/:id      → Mise à jour partielle
DELETE /resources/:id      → Suppression
```

### 3. Format de réponse standard

```typescript
// Succès
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}

// Erreur
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

### 4. Validation des entrées

```typescript
// Avec Zod
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user')
});

// Dans le handler
const data = createUserSchema.parse(req.body);
```

### 5. Documentation OpenAPI

```yaml
paths:
  /users:
    post:
      summary: Créer un utilisateur
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: Utilisateur créé
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
```

### 6. Tests d'API

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

## Checklist API

- [ ] Endpoint RESTful
- [ ] Validation des entrées (Zod/Joi)
- [ ] Gestion des erreurs centralisée
- [ ] Status codes appropriés
- [ ] Documentation OpenAPI
- [ ] Tests d'intégration
- [ ] Rate limiting (si public)
- [ ] Authentification (si privé)

## Output attendu

```markdown
## API: [Nom de l'endpoint]

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

### Erreurs
| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Données invalides |
| NOT_FOUND | 404 | Ressource introuvable |
| UNAUTHORIZED | 401 | Non authentifié |
```

## Règles

- IMPORTANT: Toujours valider les entrées
- IMPORTANT: Documenter avec OpenAPI
- YOU MUST retourner des codes HTTP appropriés
- NEVER exposer les erreurs internes en production

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux api..."_
- _"Je veux field1..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple de développement d'API

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
    "description": "Smartphone Apple dernière génération",
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



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
