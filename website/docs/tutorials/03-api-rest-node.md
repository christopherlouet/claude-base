---
sidebar_position: 4
title: "03 - Node.js REST API"
description: Develop a complete REST API with TDD, validation and OpenAPI documentation
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Create a REST API with TDD

<DifficultyBadge level="intermediate" /> **Estimated duration: 45 minutes**

This tutorial shows you how to develop a professional REST API using TDD (Test-Driven Development).

## Objectives

By the end of this tutorial, you will know how to:
- Use `/work:work-specify` to define endpoints and acceptance criteria
- Use `/dev:dev-api` to create endpoints
- Use `/dev:dev-tdd` for test-driven development
- Use `/doc:doc-api-spec` to generate OpenAPI documentation
- Use `/qa:qa-loop` to audit and reach the target quality score
- Structure a Node.js API professionally

## Prerequisites

- Node.js 18+ installed
- An Express or Fastify project
- Basic knowledge of REST APIs

## Context

We will create a **tasks (todos)** management API with:
- Full CRUD (Create, Read, Update, Delete)
- Data validation
- OpenAPI documentation
- Integration tests

## Step 1: Explore the existing structure

```bash
/work:work-explore "Analyze the structure of the existing API and the patterns used"
```

Claude will identify:
- The framework used (Express, Fastify, Nest...)
- The route structure
- The middlewares in place
- The validation patterns

## Step 2: Specify the API

Before designing the routes, lock the user stories and acceptance criteria.

```bash
/work:work-specify "CRUD API for tasks (todos) with validation and documentation"
```

**Example output:**

```
## US-1 (P1) — Create a task
As a client, I want to POST a task with title + description
so that I can persist work to do.

Given a valid payload, when I POST /api/todos,
then a 201 is returned with the new id and the task is persisted.

## US-2 (P1) — List tasks
## US-3 (P2) — Update / delete tasks
## Edge cases
- Missing title → 400 with error details
- Title > 200 chars → 400
- DB unavailable → 503
```

## Step 3: Plan the API

```bash
/work:work-plan
```

**Expected plan:**

```
## Plan: Todos API

### Endpoints to create
- GET    /api/todos      - List of tasks
- GET    /api/todos/:id  - Task details
- POST   /api/todos      - Create a task
- PUT    /api/todos/:id  - Update a task
- DELETE /api/todos/:id  - Delete a task

### Files
- src/routes/todos.ts    - Routes
- src/services/todos.ts  - Business logic
- src/schemas/todos.ts   - Zod validation
- tests/todos.test.ts    - Integration tests
```

## Step 4: Develop with TDD

Let's use TDD to guarantee quality.

### Start TDD development

```bash
/dev:dev-tdd "Create the POST /api/todos endpoint to create a new task"
```

### TDD cycle

Claude will follow the **Red → Green → Refactor** cycle:

**1. Red - Write the failing test**

```typescript
// tests/todos.test.ts
import request from 'supertest';
import { app } from '../src/app';

describe('POST /api/todos', () => {
  it('should create a new todo', async () => {
    const newTodo = {
      title: 'Learn TDD',
      description: 'Follow the claude-base tutorial',
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
      .send({ description: 'No title' })
      .expect(400);

    expect(response.body.error).toContain('title');
  });
});
```

**2. Green - Implement the minimum**

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

**3. Refactor - Improve the code**

After the tests pass, Claude proposes improvements:
- Extract the validation into a middleware
- Add centralized error handling
- Type the responses

## Step 5: Create the other endpoints

Continue with the other endpoints:

```bash
/dev:dev-api "GET /api/todos - Paginated list of tasks with filters"
```

```bash
/dev:dev-api "GET /api/todos/:id - Get a task by its ID"
```

```bash
/dev:dev-api "PUT /api/todos/:id - Update a task"
```

```bash
/dev:dev-api "DELETE /api/todos/:id - Delete a task"
```

### Final result

```typescript
// src/routes/todos.ts
import { Router } from 'express';
import { validate } from '../middleware/validate';
import { createTodoSchema, updateTodoSchema, querySchema } from '../schemas/todos';
import { todoService } from '../services/todos';

const router = Router();

// List of tasks
router.get('/', validate(querySchema, 'query'), async (req, res) => {
  const { page = 1, limit = 10, completed } = req.query;
  const todos = await todoService.findAll({ page, limit, completed });
  res.json(todos);
});

// Task details
router.get('/:id', async (req, res) => {
  const todo = await todoService.findById(req.params.id);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// Create a task
router.post('/', validate(createTodoSchema), async (req, res) => {
  const todo = await todoService.create(req.body);
  res.status(201).json(todo);
});

// Update a task
router.put('/:id', validate(updateTodoSchema), async (req, res) => {
  const todo = await todoService.update(req.params.id, req.body);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// Delete a task
router.delete('/:id', async (req, res) => {
  const deleted = await todoService.delete(req.params.id);
  if (!deleted) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.status(204).send();
});

export default router;
```

## Step 6: Generate the OpenAPI documentation

```bash
/doc:doc-api-spec
```

Claude will generate a complete OpenAPI specification:

```yaml
# openapi.yaml
openapi: 3.0.3
info:
  title: Todos API
  version: 1.0.0
  description: Tasks management API

paths:
  /api/todos:
    get:
      summary: List of tasks
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
          description: Paginated list of tasks
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/TodoList'

    post:
      summary: Create a task
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateTodo'
      responses:
        '201':
          description: Task created
        '400':
          description: Invalid data

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

## Step 7: Audit + fix loop

Run the adaptive audit + fix loop until the target score.

```bash
/qa:qa-loop "score 90"
```

Claude audits security (OWASP), input validation, error handling, rate limiting, authentication, performance and code quality, then fixes P0/P1 issues automatically and re-audits in a loop until the target score is reached.

For a security-only audit, use `/qa:qa-security`.

## Step 8: Run the tests

```bash
npm test
```

Verify that all tests pass.

## Step 9: Commit

```bash
/work:work-commit
```

**Suggested message:**

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

## Recap

You have created a complete REST API:

```
src/
├── routes/
│   └── todos.ts           # Express routes
├── services/
│   └── todos.ts           # Business logic
├── schemas/
│   └── todos.ts           # Zod validation
├── middleware/
│   └── validate.ts        # Validation middleware
└── openapi.yaml           # API documentation

tests/
└── todos.test.ts          # Integration tests
```

| Command | What it does |
|---------|--------------|
| `/work:work-specify` | Defines user stories and acceptance criteria |
| `/dev:dev-tdd` | Test-Driven development |
| `/dev:dev-api` | Creates an endpoint with validation |
| `/doc:doc-api-spec` | Generates the OpenAPI doc |
| `/qa:qa-loop` | Adaptive audit + fix loop until target score |

## Next steps

- [Tutorial 04: Flutter + Supabase](/docs/tutorials/flutter-supabase) - Mobile backend
- [API Guide](/docs/concepts/stack-recipes) - API best practices
- [Command /dev:dev-graphql](/docs/commands/dev/dev-graphql) - GraphQL API

---

:::tip TDD in practice
TDD may seem slower at first, but it guarantees better test coverage and more maintainable code. Use `/dev:dev-tdd` for critical features.
:::
