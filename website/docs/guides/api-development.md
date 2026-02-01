---
sidebar_position: 4
title: Developpement API
description: Guide pour REST et GraphQL
---

# Guide : Developpement API

Guide complet pour les APIs REST et GraphQL.

## Stack supportee

- **REST** : Express, NestJS, FastAPI
- **GraphQL** : Apollo Server, Prisma
- **Documentation** : OpenAPI/Swagger
- **Tests** : Jest, Supertest

## Commandes recommandees

### Developpement

| Commande | Usage |
|----------|-------|
| `/dev:dev-api` | Creer endpoints REST |
| `/dev:dev-graphql` | API GraphQL |
| `/dev:dev-api-versioning` | Versioning d'API |
| `/dev:dev-error-handling` | Gestion des erreurs |

### Documentation

| Commande | Usage |
|----------|-------|
| `/doc:doc-api-spec` | Spec OpenAPI |
| `/doc:doc-generate` | Documentation |

### Qualite

| Commande | Usage |
|----------|-------|
| `/qa:qa-security` | Audit securite |
| `/qa:qa-perf` | Performance API |
| `/ops:ops-load-testing` | Tests de charge |

## Workflow type

### Nouvel endpoint REST

```bash
# 1. Explorer l'API existante
/work:work-explore "endpoints utilisateurs"

# 2. Planifier
/work:work-plan "Ajouter endpoint PATCH /users/:id"

# 3. Developper
/dev:dev-api "Endpoint de mise a jour partielle utilisateur"

# 4. Documenter
/doc:doc-api-spec

# 5. Tests et PR
/qa:qa-security
/work:work-pr
```

### Nouvelle API GraphQL

```bash
# 1. Planifier le schema
/work:work-plan "Schema GraphQL produits"

# 2. Developper
/dev:dev-graphql "Type Product avec queries et mutations"

# 3. PR
/work:work-pr
```

## Bonnes pratiques

### Endpoint REST

```typescript
// src/routes/users.ts
import { Router } from 'express';
import { validateBody } from '../middleware/validation';
import { UpdateUserDto } from '../dto/user.dto';

const router = Router();

/**
 * @openapi
 * /users/{id}:
 *   patch:
 *     summary: Update user partially
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateUserDto'
 *     responses:
 *       200:
 *         description: User updated
 *       404:
 *         description: User not found
 */
router.patch('/:id',
  validateBody(UpdateUserDto),
  async (req, res, next) => {
    try {
      const user = await userService.update(req.params.id, req.body);
      res.json(user);
    } catch (error) {
      next(error);
    }
  }
);
```

### Schema GraphQL

```graphql
type User {
  id: ID!
  email: String!
  name: String
  createdAt: DateTime!
}

type Query {
  user(id: ID!): User
  users(limit: Int = 10, offset: Int = 0): [User!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

input CreateUserInput {
  email: String!
  name: String
}

input UpdateUserInput {
  email: String
  name: String
}
```

## Securite API

Toujours appliquer :

- ✅ Validation des entrees
- ✅ Authentification (JWT, API keys)
- ✅ Rate limiting
- ✅ CORS configure
- ✅ Requetes parametrees (SQL injection)
- ✅ Headers de securite

```bash
# Audit de securite avant deploy
/qa:qa-security
```

## Status codes HTTP

| Code | Usage |
|------|-------|
| 200 | OK - Succes |
| 201 | Created - Ressource creee |
| 204 | No Content - Succes sans corps |
| 400 | Bad Request - Erreur client |
| 401 | Unauthorized - Non authentifie |
| 403 | Forbidden - Non autorise |
| 404 | Not Found - Ressource non trouvee |
| 422 | Unprocessable - Validation echouee |
| 500 | Internal Error - Erreur serveur |

---

## Voir aussi

- [API](/docs/commands/dev/dev-api)
- [GraphQL](/docs/commands/dev/dev-graphql)
- [Securite](/docs/commands/qa/qa-security)
