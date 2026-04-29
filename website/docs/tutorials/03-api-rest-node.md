---
sidebar_position: 4
title: "03 - API REST Node.js"
description: Développez une API REST complète avec TDD, validation et documentation OpenAPI
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Créer une API REST avec TDD

<DifficultyBadge level="intermediate" /> **Durée estimée : 45 minutes**

Ce tutoriel vous montre comment développer une API REST professionnelle en utilisant le TDD (Test-Driven Development).

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/dev:dev-api` pour créer des endpoints
- Utiliser `/dev:dev-tdd` pour le développement piloté par les tests
- Utiliser `/doc:doc-api-spec` pour générer la documentation OpenAPI
- Structurer une API Node.js de manière professionnelle

## Prérequis

- Node.js 18+ installé
- Un projet Express ou Fastify
- Connaissances de base en API REST

## Contexte

Nous allons créer une API de gestion de **tâches (todos)** avec :
- CRUD complet (Create, Read, Update, Delete)
- Validation des données
- Documentation OpenAPI
- Tests d'intégration

## Étape 1 : Explorer la structure existante

```bash
/work:work-explore "Analyser la structure de l'API existante et les patterns utilisés"
```

Claude va identifier :
- Le framework utilisé (Express, Fastify, Nest...)
- La structure des routes
- Les middlewares en place
- Les patterns de validation

## Étape 2 : Planifier l'API

```bash
/work:work-plan "API CRUD pour les tâches (todos) avec validation et documentation"
```

**Plan attendu :**

```
## Plan : API Todos

### Endpoints à créer
- GET    /api/todos      - Liste des tâches
- GET    /api/todos/:id  - Détail d'une tâche
- POST   /api/todos      - Créer une tâche
- PUT    /api/todos/:id  - Modifier une tâche
- DELETE /api/todos/:id  - Supprimer une tâche

### Fichiers
- src/routes/todos.ts    - Routes
- src/services/todos.ts  - Logique métier
- src/schemas/todos.ts   - Validation Zod
- tests/todos.test.ts    - Tests d'intégration
```

## Étape 3 : Développer en TDD

Utilisons le TDD pour garantir la qualité.

### Lancez le développement TDD

```bash
/dev:dev-tdd "Créer l'endpoint POST /api/todos pour créer une nouvelle tâche"
```

### Cycle TDD

Claude va suivre le cycle **Red → Green → Refactor** :

**1. Red - Écrire le test qui échoue**

```typescript
// tests/todos.test.ts
import request from 'supertest';
import { app } from '../src/app';

describe('POST /api/todos', () => {
  it('should create a new todo', async () => {
    const newTodo = {
      title: 'Apprendre TDD',
      description: 'Suivre le tutoriel claude-socle',
    };

    const response = await request(app)
      .post('/api/todos')
      .send(newTodo)
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(String),
      title: newTodo.title,
      description: newTodo.description,
      completed: false,
      createdAt: expect.any(String),
    });
  });

  it('should return 400 if title is missing', async () => {
    const response = await request(app)
      .post('/api/todos')
      .send({ description: 'Sans titre' })
      .expect(400);

    expect(response.body.error).toContain('title');
  });
});
```

**2. Green - Implémenter le minimum**

```typescript
// src/schemas/todos.ts
import { z } from 'zod';

export const createTodoSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100),
  description: z.string().optional(),
});

export type CreateTodoInput = z.infer<typeof createTodoSchema>;
```

```typescript
// src/routes/todos.ts
import { Router } from 'express';
import { createTodoSchema } from '../schemas/todos';
import { todoService } from '../services/todos';

const router = Router();

router.post('/', async (req, res) => {
  const result = createTodoSchema.safeParse(req.body);

  if (!result.success) {
    return res.status(400).json({
      error: result.error.errors.map(e => e.message).join(', '),
    });
  }

  const todo = await todoService.create(result.data);
  res.status(201).json(todo);
});

export default router;
```

**3. Refactor - Améliorer le code**

Après que les tests passent, Claude propose des améliorations :
- Extraire la validation dans un middleware
- Ajouter la gestion d'erreurs centralisée
- Typer les réponses

## Étape 4 : Créer les autres endpoints

Continuez avec les autres endpoints :

```bash
/dev:dev-api "GET /api/todos - Liste paginée des tâches avec filtres"
```

```bash
/dev:dev-api "GET /api/todos/:id - Récupérer une tâche par son ID"
```

```bash
/dev:dev-api "PUT /api/todos/:id - Mettre à jour une tâche"
```

```bash
/dev:dev-api "DELETE /api/todos/:id - Supprimer une tâche"
```

### Résultat final

```typescript
// src/routes/todos.ts
import { Router } from 'express';
import { validate } from '../middleware/validate';
import { createTodoSchema, updateTodoSchema, querySchema } from '../schemas/todos';
import { todoService } from '../services/todos';

const router = Router();

// Liste des tâches
router.get('/', validate(querySchema, 'query'), async (req, res) => {
  const { page = 1, limit = 10, completed } = req.query;
  const todos = await todoService.findAll({ page, limit, completed });
  res.json(todos);
});

// Détail d'une tâche
router.get('/:id', async (req, res) => {
  const todo = await todoService.findById(req.params.id);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// Créer une tâche
router.post('/', validate(createTodoSchema), async (req, res) => {
  const todo = await todoService.create(req.body);
  res.status(201).json(todo);
});

// Modifier une tâche
router.put('/:id', validate(updateTodoSchema), async (req, res) => {
  const todo = await todoService.update(req.params.id, req.body);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// Supprimer une tâche
router.delete('/:id', async (req, res) => {
  const deleted = await todoService.delete(req.params.id);
  if (!deleted) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.status(204).send();
});

export default router;
```

## Étape 5 : Générer la documentation OpenAPI

```bash
/doc:doc-api-spec
```

Claude va générer une spécification OpenAPI complète :

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: Todos API
  version: 1.0.0
  description: API de gestion de tâches

paths:
  /api/todos:
    get:
      summary: Liste des tâches
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
        - name: completed
          in: query
          schema:
            type: boolean
      responses:
        '200':
          description: Liste paginée des tâches
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/TodoList'

    post:
      summary: Créer une tâche
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateTodo'
      responses:
        '201':
          description: Tâche créée
        '400':
          description: Données invalides

components:
  schemas:
    Todo:
      type: object
      properties:
        id:
          type: string
        title:
          type: string
        description:
          type: string
        completed:
          type: boolean
        createdAt:
          type: string
          format: date-time
```

## Étape 6 : Vérifier la sécurité

```bash
/qa:qa-security
```

Claude va vérifier :
- Validation des entrées (injection)
- Gestion des erreurs (pas de leak d'info)
- Rate limiting
- Authentification (si nécessaire)

## Étape 7 : Lancer les tests

```bash
npm test
```

Vérifiez que tous les tests passent.

## Étape 8 : Commiter

```bash
/work:work-commit
```

**Message suggéré :**

```
feat(api): add todos CRUD endpoints with TDD

- Add POST /api/todos with Zod validation
- Add GET /api/todos with pagination and filters
- Add GET /api/todos/:id for single todo
- Add PUT /api/todos/:id for updates
- Add DELETE /api/todos/:id
- Add OpenAPI documentation
- Add comprehensive integration tests
```

## Récapitulatif

Vous avez créé une API REST complète :

```
src/
├── routes/
│   └── todos.ts           # Routes Express
├── services/
│   └── todos.ts           # Logique métier
├── schemas/
│   └── todos.ts           # Validation Zod
├── middleware/
│   └── validate.ts        # Middleware validation
└── openapi.yaml           # Documentation API

tests/
└── todos.test.ts          # Tests d'intégration
```

| Commande | Ce qu'elle fait |
|----------|-----------------|
| `/dev:dev-tdd` | Développement Test-Driven |
| `/dev:dev-api` | Crée un endpoint avec validation |
| `/doc:doc-api-spec` | Génère la doc OpenAPI |
| `/qa:qa-security` | Audit de sécurité |

## Prochaines étapes

- [Tutoriel 04 : Flutter + Supabase](/docs/tutorials/flutter-supabase) - Backend mobile
- [Guide API](/docs/concepts/stack-recipes) - Bonnes pratiques API
- [Commande /dev:dev-graphql](/docs/commands/dev/dev-graphql) - API GraphQL

---

:::tip TDD en pratique
Le TDD peut sembler plus lent au début, mais il garantit une meilleure couverture de tests et un code plus maintenable. Utilisez `/dev:dev-tdd` pour les fonctionnalités critiques.
:::
