---
sidebar_position: 11
title: "10 - Complete project: TaskFlow"
description: "Capstone project: build a mini-SaaS from A to Z using the full foundation workflow"
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Complete project: TaskFlow

<DifficultyBadge level="advanced" /> **Estimated duration: 3-4 hours**

This tutorial is the convergence point of all the previous tutorials. You will build **TaskFlow**, a mini-SaaS for task management, from MVP definition through to production deployment, using each component of the foundation in its real context.

This tutorial does not show you "how to code" an API. It shows you **how to use the foundation** to build a complete product with quality and method.

## Objectives

By the end of this tutorial, you will know how to:
- Chain the **Explore -> Specify -> Plan -> TDD -> Audit -> Commit -> PR -> Deploy** phases on a real project
- Choose the right command at the right time
- Manage architecture decisions with Claude
- Handle audit failures and fix them in a loop
- Produce a versioned release with documentation

## Prerequisites

- Tutorials 01 to 06 completed (basic workflow, TDD, CI/CD)
- Node.js 20+ and npm installed
- Git configured with a GitHub account
- Claude Code working with the foundation

## What you will build

**TaskFlow** is a minimalist task management application:

```
Backend (Node.js + TypeScript + Express)
  - JWT authentication (signup, login, logout)
  - Task CRUD (create, read, update, delete)
  - Filters: status (todo/in-progress/done), priority (low/medium/high), due date

Frontend (React + TypeScript)
  - Login / signup page
  - Task list with filters
  - Create / edit form

Quality
  - Unit and integration tests (Jest, Supertest)
  - OWASP security audit
  - GitHub Actions pipeline
  - Docker + docker-compose
```

## Workflow overview

```
Phase 1  Init          (30 min)  -> Project, CLAUDE.md, .env
Phase 2  Specification (30 min)  -> MVP, User Stories, Personas
Phase 3  Architecture  (30 min)  -> Plan, DB schema, tech decisions
Phase 4  Backend TDD   (60 min)  -> Auth, CRUD, OpenAPI
Phase 5  Frontend TDD  (45 min)  -> Components, integration
Phase 6  Quality       (30 min)  -> Security audit, qa-loop loop
Phase 7  CI/CD         (30 min)  -> GitHub Actions, Docker, PR
Phase 8  Release       (15 min)  -> README, CHANGELOG, tag v1.0.0
```

---

## Phase 1: Initialization (30 min)

### 1.1 Create the project and the Git repository

```bash
mkdir taskflow && cd taskflow
git init
git remote add origin https://github.com/your-username/taskflow.git
```

Initialize the project's basic structure:

```bash
mkdir -p backend/src frontend/src
touch backend/package.json frontend/package.json
```

### 1.2 Configure environment variables

```bash
/ops:ops-env "Node.js application with JWT, SQLite database for dev, PostgreSQL for prod"
```

Claude will generate two files. First `.env.example` (committed in Git):

```bash
# Application
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# Authentication
JWT_SECRET=your-super-secret-key-change-in-production
JWT_EXPIRES_IN=7d

# Database
DATABASE_URL=./taskflow.db
# In production: postgresql://user:password@host:5432/taskflow

# Frontend
VITE_API_URL=http://localhost:3000/api
```

Then `.env` (in `.gitignore`, with your real dev values).

:::warning Security
Never commit `.env`. Verify that `.gitignore` does contain `.env` before continuing.
:::

### 1.3 Configure CLAUDE.md

Create `CLAUDE.md` at the root of the project with the conventions specific to TaskFlow:

```markdown
# TaskFlow

Task management API with JWT authentication.

## Stack
- Backend: Node.js 20, Express, TypeScript strict, Zod, Prisma, SQLite (dev) / PostgreSQL (prod)
- Frontend: React 18, TypeScript strict, Vite, React Query
- Tests: Jest, Supertest (backend), Vitest, React Testing Library (frontend)

## Conventions
- camelCase for variables and functions
- PascalCase for classes and React components
- kebab-case for file names
- `I` prefix forbidden for TypeScript interfaces
- Minimum coverage: 80%

## Backend structure
src/
  routes/      # Express routes
  services/    # Business logic
  models/      # Types and interfaces
  middleware/  # Auth, validation, errors
  schemas/     # Zod validation

## Workflow
Always: Explore -> Specify -> Plan -> TDD -> Audit -> Commit
```

---

## Phase 2: Specification (30 min)

### 2.1 Define the MVP

```bash
/biz:biz-mvp "SaaS task management application for individual developers and small teams"
```

Claude analyzes the domain and proposes a MoSCoW prioritization:

```
## TaskFlow MVP

### P1 - Must Have (v1.0)
- Secure signup and login
- Complete task CRUD
- Statuses: todo / in-progress / done
- Priorities: low / medium / high
- Due date per task

### P2 - Should Have (v1.1)
- Filtering and search
- Custom tags
- Pagination

### P3 - Could Have (v1.2)
- Email notifications (deadline)
- Task sharing between users
- Kanban view

### P4 - Won't Have (v1.0)
- Native mobile app
- Third-party integrations (Jira, Linear)
```

Validate this scope. The P1 is your target for this tutorial.

### 2.2 Generate the User Stories

```bash
/work:work-specify "TaskFlow task management API with JWT authentication and task CRUD"
```

Claude produces `spec.md` with the User Stories in Given/When/Then format. Excerpt:

```markdown
## User Stories - Authentication

### US-01: Signup
**P1** | As a new user, I want to create an account
to access TaskFlow.

**Acceptance criteria:**
- Given a valid email and a password >= 8 characters
- When I submit the signup form
- Then my account is created and I receive a JWT token

- Given an email already in use
- When I try to sign up
- Then I receive a 409 Conflict error

### US-02: Login
**P1** | As a registered user, I want to log in
to access my tasks.

...

## User Stories - Tasks

### US-03: Create a task
**P1** | As a logged-in user, I want to create a task
with title, description, priority and due date.

**Acceptance criteria:**
- Given an authenticated user with the required fields (title)
- When I submit the creation
- Then the task is created with status "todo" by default

- Given an empty title
- When I submit the creation
- Then I receive a 400 error with an explicit message

...
```

### 2.3 Create the personas

```bash
/biz:biz-personas "TaskFlow users"
```

Claude generates two main personas:

```
## Persona 1: Alex - Solo Developer

Age: 28
Role: Full-stack freelancer
Usage: Manages client projects and side-projects
Frustration: Existing tools are too complex for solo use
Need: Simple interface, clean API for integration into CLI workflow
Quote: "I just want to know what I have to do today"

## Persona 2: Sarah - Tech Lead

Age: 35
Role: Lead dev in a startup (team of 8)
Usage: Coordinates her team's tasks
Frustration: Too much friction in current tools, hard onboarding
Need: Visibility on progress, filters by member and by sprint
Quote: "I want to see at a glance what's blocked"
```

These personas will guide your UX decisions in the frontend phase.

---

## Phase 3: Architecture and Plan (30 min)

### 3.1 Generate the implementation plan

```bash
/work:work-plan "Express + TypeScript backend for TaskFlow following spec.md: JWT auth, task CRUD, Zod validation, Jest tests"
```

Claude produces `plan.md` with the complete structure:

```
## Implementation plan: TaskFlow Backend

### File structure to create
backend/
  src/
    app.ts              # Express app (without listen)
    server.ts           # Entry point (with listen)
    routes/
      auth.ts           # POST /auth/register, POST /auth/login
      tasks.ts          # CRUD /tasks
    services/
      auth.service.ts   # Signup/login logic
      task.service.ts   # Task CRUD logic
    middleware/
      auth.middleware.ts # JWT verification
      error.middleware.ts # Centralized error handling
    schemas/
      auth.schema.ts    # Zod: RegisterInput, LoginInput
      task.schema.ts    # Zod: CreateTaskInput, UpdateTaskInput
    models/
      user.model.ts     # User interface
      task.model.ts     # Task, TaskStatus, TaskPriority interfaces
  prisma/
    schema.prisma       # DB schema
  tests/
    auth.test.ts
    tasks.test.ts

### Dependencies
- express, @types/express
- zod (validation)
- prisma, @prisma/client
- jsonwebtoken, bcryptjs
- jest, supertest (tests)
- typescript, ts-node

### Identified risks
1. SQLite -> PostgreSQL migration: use Prisma for the abstraction
2. In-memory JWT tokens in dev: plan refresh token for v1.1
3. Race conditions on shared tasks: out of scope v1.0
```

### 3.2 Technical decision: HTTP framework

Claude proposes the options and their tradeoffs:

```
Question: Express or Fastify for the backend?

Express
  Pro: Mature ecosystem, abundant middleware, known by everyone
  Con: Less performant, no native validation

Fastify
  Pro: Faster, native JSON Schema validation, TypeScript first
  Con: Smaller ecosystem, fewer community resources

Recommendation for TaskFlow:
  Express with Zod - best choice because:
  - Team likely familiar with Express
  - Zod offers TypeScript validation superior to JSON Schema
  - Performance is not critical for an MVP
  - Migration to Fastify possible after v1.0 if needed
```

We choose Express + Zod. This decision is documented in `plan.md`.

### 3.3 Database schema

```bash
/ops:ops-database "Prisma schema for TaskFlow: User (email, password hash, timestamps) and Task (title, description, status, priority, dueDate, userId foreign key)"
```

Claude generates `prisma/schema.prisma`:

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = env("DATABASE_PROVIDER") // "sqlite" or "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  tasks     Task[]
}

model Task {
  id          String       @id @default(cuid())
  title       String
  description String?
  status      TaskStatus   @default(TODO)
  priority    TaskPriority @default(MEDIUM)
  dueDate     DateTime?
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt
  userId      String
  user        User         @relation(fields: [userId], references: [id], onDelete: Cascade)
}

enum TaskStatus {
  TODO
  IN_PROGRESS
  DONE
}

enum TaskPriority {
  LOW
  MEDIUM
  HIGH
}
```

### 3.4 Document the architecture

```bash
/doc:doc-generate "TaskFlow architecture: Express backend, React frontend, Prisma ORM, JWT auth"
```

Claude generates `docs/architecture.md` with an ASCII diagram:

```
## TaskFlow Architecture

### Overview

  [React Frontend]
        |
        | HTTP/JSON (port 5173 -> 3000)
        |
  [Express API]
    |         |
    |         |
[Auth]    [Tasks]
    |         |
    +----+----+
         |
    [Prisma ORM]
         |
    [SQLite / PostgreSQL]

### Authentication flow

  Client -> POST /auth/register -> Hash password (bcrypt) -> Prisma create -> JWT token
  Client -> POST /auth/login    -> Verify password         -> Prisma find  -> JWT token
  Client -> GET  /tasks         -> Verify JWT middleware   -> Prisma query -> JSON
```

---

## Phase 4: TDD Development - Backend (60 min)

### 4.1 Authentication module

Start with the most critical module: authentication.

```bash
/dev:dev-tdd "JWT authentication module for TaskFlow: signup with bcrypt hash, login with verification, token generation"
```

Claude follows the **Red -> Green -> Refactor** cycle.

**RED - The tests that fail first:**

```typescript
// tests/auth.test.ts
import request from 'supertest';
import { app } from '../src/app';
import { prisma } from '../src/lib/prisma';

describe('POST /auth/register', () => {
  afterEach(async () => {
    await prisma.user.deleteMany();
  });

  it('should register a new user and return a JWT token', async () => {
    const response = await request(app)
      .post('/auth/register')
      .send({ email: 'alex@test.com', password: 'password123' })
      .expect(201);

    expect(response.body).toMatchObject({
      token: expect.any(String),
      user: {
        id: expect.any(String),
        email: 'alex@test.com',
      },
    });
    expect(response.body.user.password).toBeUndefined();
  });

  it('should return 409 if email already exists', async () => {
    await request(app)
      .post('/auth/register')
      .send({ email: 'alex@test.com', password: 'password123' });

    const response = await request(app)
      .post('/auth/register')
      .send({ email: 'alex@test.com', password: 'other123' })
      .expect(409);

    expect(response.body.error).toMatch(/already exists/i);
  });

  it('should return 400 if password is less than 8 characters', async () => {
    const response = await request(app)
      .post('/auth/register')
      .send({ email: 'alex@test.com', password: 'short' })
      .expect(400);

    expect(response.body.error).toBeDefined();
  });
});
```

Claude runs the tests: **all fail** (routes not implemented). That's normal, it's the Red part of the cycle.

**GREEN - Minimal implementation:**

Claude creates `src/routes/auth.ts`, `src/services/auth.service.ts` and `src/schemas/auth.schema.ts`. The tests pass one by one.

**REFACTOR - Improvements:**

After all the tests pass, Claude proposes:
- Extract token generation into a helper `src/lib/jwt.ts`
- Centralize error handling in `src/middleware/error.middleware.ts`
- Type the responses with interfaces in `src/models/`

Commit after the refactoring:

```bash
/work:work-commit
```

Message suggested by Claude:

```
feat(auth): add JWT authentication module

- Add POST /auth/register with bcrypt password hashing
- Add POST /auth/login with credential verification
- Add JWT token generation and validation
- Add Zod validation for auth inputs
- Add auth middleware for protected routes
- Add integration tests (coverage: 94%)
```

### 4.2 Task CRUD

```bash
/dev:dev-tdd "Complete task CRUD for TaskFlow: create, read (list + detail), update, delete, with auth middleware"
```

Claude follows the same cycle. The tests cover unauthorized access cases (task belonging to another user):

```typescript
// tests/tasks.test.ts - excerpt
describe('GET /tasks/:id', () => {
  it("should return 403 if task belongs to another user", async () => {
    // Create two users and a task for the first one
    const { token: token1 } = await createUserAndLogin('user1@test.com');
    const { token: token2 } = await createUserAndLogin('user2@test.com');
    const task = await createTask(token1, { title: 'My private task' });

    // User 2 tries to access user 1's task
    const response = await request(app)
      .get(`/tasks/${task.id}`)
      .set('Authorization', `Bearer ${token2}`)
      .expect(403);

    expect(response.body.error).toMatch(/forbidden/i);
  });
});
```

This isolation test is crucial for security. Claude identifies it and includes it automatically thanks to the foundation's `security` rule.

Commit:

```bash
/work:work-commit
```

```
feat(tasks): add CRUD endpoints with ownership validation

- Add GET /tasks (list, filtered by userId)
- Add GET /tasks/:id (with ownership check)
- Add POST /tasks with Zod validation
- Add PUT /tasks/:id with partial update support
- Add DELETE /tasks/:id
- Add integration tests (coverage: 87%)
```

### 4.3 OpenAPI documentation

```bash
/doc:doc-api-spec
```

Claude generates `docs/openapi.yaml`. Excerpt:

```yaml
openapi: 3.0.3
info:
  title: TaskFlow API
  version: 1.0.0
  description: Task management API with JWT authentication

security:
  - bearerAuth: []

paths:
  /auth/register:
    post:
      tags: [Authentication]
      summary: Create an account
      security: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/RegisterInput'
            example:
              email: alex@example.com
              password: password123
      responses:
        '201':
          description: Account created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthResponse'
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/ConflictError'

  /tasks:
    get:
      tags: [Tasks]
      summary: List tasks of the logged-in user
      parameters:
        - name: status
          in: query
          schema:
            $ref: '#/components/schemas/TaskStatus'
        - name: priority
          in: query
          schema:
            $ref: '#/components/schemas/TaskPriority'
      responses:
        '200':
          description: Task list
          ...
        '401':
          $ref: '#/components/responses/UnauthorizedError'

# ... (remaining endpoints)

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## Phase 5: TDD Development - Frontend (45 min)

### 5.1 TaskList component

```bash
/dev:dev-component "TaskList component for TaskFlow: displays the task list with status, priority, due date. Props: tasks (Task[]), onStatusChange, onDelete"
```

Claude generates the component with its tests:

```typescript
// frontend/src/components/TaskList.test.tsx - excerpt
describe('TaskList', () => {
  const mockTasks: Task[] = [
    {
      id: '1',
      title: 'Fix the auth bug',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: '2026-04-10',
      ...
    },
    // ...
  ];

  it('should render all tasks', () => {
    render(<TaskList tasks={mockTasks} onStatusChange={vi.fn()} onDelete={vi.fn()} />);
    expect(screen.getByText('Fix the auth bug')).toBeInTheDocument();
  });

  it('should call onStatusChange when status badge is clicked', async () => {
    const onStatusChange = vi.fn();
    render(<TaskList tasks={mockTasks} onStatusChange={onStatusChange} onDelete={vi.fn()} />);

    await userEvent.click(screen.getByText('IN_PROGRESS'));
    expect(onStatusChange).toHaveBeenCalledWith('1', expect.any(String));
  });
});
```

As in tutorial 02, Claude generates component, tests and Storybook stories if detected.

### 5.2 TaskForm component

```bash
/dev:dev-component "TaskForm component: task create/edit form with client-side validation (title required, future date)"
```

Claude generates a form with React Hook Form (or native state depending on the project context) and client-side validation.

### 5.3 Frontend-backend integration

```bash
/dev:dev-tdd "TaskFlow frontend integration: useTaskApi hook that wraps the API calls with React Query, 401 error handling with redirect to login"
```

Claude creates `src/hooks/useTaskApi.ts` in TDD:

```typescript
// Test: redirect to /login on 401
it('should redirect to login when API returns 401', async () => {
  server.use(
    http.get('/api/tasks', () => HttpResponse.json({ error: 'Unauthorized' }, { status: 401 }))
  );

  const { result } = renderHook(() => useTaskApi(), { wrapper });

  await act(async () => {
    await result.current.fetchTasks();
  });

  expect(mockNavigate).toHaveBeenCalledWith('/login');
});
```

Commit the frontend:

```bash
/work:work-commit
```

```
feat(frontend): add task management UI

- Add TaskList component with status/priority display
- Add TaskForm component with client-side validation
- Add useTaskApi hook with React Query integration
- Add 401 redirect to login page
- Add unit tests for all components (coverage: 82%)
```

---

## Phase 6: Quality and Security (30 min)

### 6.1 OWASP security audit

As in tutorial 05, run the full audit:

```bash
/qa:qa-security
```

Initial result (realistic example):

```markdown
## OWASP Security Audit - TaskFlow

### Critical (2)

#### A07 - JWT token without short expiration
File: src/lib/jwt.ts:8
Issue: expiresIn: '30d' - excessive duration
Risk: Stolen token usable for 30 days
Fix: Reduce to 15m + implement refresh token

#### A05 - Rate limiting absent
Issue: No rate limiting on /auth/login
Risk: Brute force attack on passwords
Fix: Install express-rate-limit, 5 attempts/15min on /auth

### High (2)

#### A02 - Password potentially logged
File: src/middleware/error.middleware.ts:22
Issue: console.log(err) may expose req.body
Fix: Log only err.message, never req.body

#### A01 - Missing forced pagination
Issue: GET /tasks without limit returns all tasks
Risk: Data enumeration, DDOS
Fix: Add limit/offset with maximum of 100 items

### Initial score: 67/100
```

Claude identifies 4 issues. Fix the 2 critical ones manually or by asking Claude:

```bash
/qa:qa-security "Fix the critical issues identified: JWT expiration and rate limiting"
```

### 6.2 Iterative audit loop

```bash
/qa:qa-loop "score 90"
```

The audit-fix-reaudit loop runs automatically. Here is the actual flow:

**Iteration 1 - Score: 72**

```
Remaining P0 issues:
- Rate limiting not configured on /auth/login
- JWT expiration still at 30d in .env.example

Actions:
1. Add express-rate-limit (5 req/15min on /auth)
2. Update .env.example: JWT_EXPIRES_IN=15m
3. Add comment about the need for a refresh token in v1.1
```

**Iteration 2 - Score: 85**

```
Remaining P1 issues:
- Insufficient logging (failed login attempts not logged)
- Pagination missing on GET /tasks
- Missing security headers (X-Content-Type-Options, X-Frame-Options)

Actions:
1. Add helmet for security headers
2. Add winston logger for auth events
3. Add limit/offset parameters on GET /tasks (max 100)
```

**Iteration 3 - Score: 92**

```
Score 92 > 90. Criterion met.

Remaining P2 issues (non-blocking):
- HTTPS not configured (normal in dev, to handle in prod via proxy)
- Restrictive CSP header recommended (to fine-tune based on frontend assets)
```

The loop stops. Commit the fixes:

```bash
/work:work-commit
```

```
fix(security): address OWASP audit findings

- Add express-rate-limit on auth endpoints (5 req/15min)
- Reduce JWT expiration to 15 minutes
- Add helmet for security headers
- Add structured logging for auth events
- Add pagination to GET /tasks (limit/offset, max 100)
- Security score: 67 -> 92
```

### 6.3 Performance audit

```bash
/qa:qa-perf
```

Claude identifies two improvement points:

```
1. Missing index on tasks.userId
   Impact: Full scan on every GET /tasks
   Fix: Add @index in the Prisma schema

2. No HTTP compression
   Impact: Uncompressed responses
   Fix: Add compression middleware
```

```bash
/work:work-commit
```

```
perf(api): add database index and HTTP compression

- Add index on tasks.userId in Prisma schema
- Add compression middleware
```

---

## Phase 7: CI/CD and Deployment (30 min)

### 7.1 GitHub Actions pipeline

As in tutorial 06:

```bash
/ops:ops-ci "CI pipeline for TaskFlow: lint + typecheck, backend tests (Jest), frontend tests (Vitest), security audit, Docker build"
```

Claude generates `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck

  test-backend:
    name: Backend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: cd backend && npm ci
      - run: cd backend && npm run test:coverage
      - uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          flags: backend

  test-frontend:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: cd frontend && npm ci
      - run: cd frontend && npm run test:coverage

  security:
    name: Security Audit
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      - run: cd backend && npm audit --audit-level=high
      - run: cd frontend && npm audit --audit-level=high

  build:
    name: Build Docker
    runs-on: ubuntu-latest
    needs: [lint, test-backend, test-frontend, security]
    steps:
      - uses: actions/checkout@v4
      - name: Build backend image
        run: docker build -t taskflow-api ./backend
      - name: Build frontend image
        run: docker build -t taskflow-web ./frontend
```

### 7.2 Dockerize the application

```bash
/ops:ops-docker "Dockerize TaskFlow: Express backend on port 3000, React/Vite frontend as static build served by Nginx"
```

Claude generates `backend/Dockerfile`, `frontend/Dockerfile` and `docker-compose.yml`:

```yaml
# docker-compose.yml - excerpt
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  web:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - api

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: taskflow
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Test locally:

```bash
docker-compose up --build
```

### 7.3 Create the Pull Request

```bash
/work:work-pr
```

Claude analyzes all the commits since `main` and generates a complete PR. Excerpt of the generated body:

```markdown
## TaskFlow v1.0.0

### What this PR brings

Complete implementation of the TaskFlow MVP:
JWT authentication, task CRUD with validation and per-user isolation,
React frontend with filters, CI/CD pipeline and Docker packaging.

### Changes

**Backend**
- JWT authentication (signup, login)
- Task CRUD with per-user isolation
- Zod validation on all inputs
- Rate limiting on auth endpoints
- Security headers (helmet)
- Pagination on GET /tasks
- OpenAPI documentation

**Frontend**
- Login / signup page
- Task list with status/priority filters
- Create / edit form
- API error handling (401 redirect)

**Quality**
- Backend test coverage: 87%
- Frontend test coverage: 82%
- OWASP security score: 92/100
- Complete CI/CD pipeline

### Tests
- [ ] Backend: `cd backend && npm test`
- [ ] Frontend: `cd frontend && npm test`
- [ ] Docker: `docker-compose up --build`
- [ ] API doc: http://localhost:3000/api-docs
```

---

## Phase 8: Documentation and Release (15 min)

### 8.1 Generate the README

```bash
/doc:doc-generate
```

Claude produces `README.md` with CI badges, description, quick start and links to the documentation:

```markdown
# TaskFlow

![CI](https://github.com/your-username/taskflow/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/your-username/taskflow/branch/main/graph/badge.svg)

Mini-SaaS for task management with JWT authentication.
Built with Express + TypeScript + React.

## Quick Start

# With Docker
cp .env.example .env
docker-compose up

# Locally (dev)
cd backend && npm install && npm run dev
cd frontend && npm install && npm run dev

## Documentation

- [API Reference](./docs/openapi.yaml)
- [Architecture](./docs/architecture.md)
- [Contributing](./CONTRIBUTING.md)
```

### 8.2 Generate the CHANGELOG

```bash
/doc:doc-changelog
```

Claude analyzes the git history and generates `CHANGELOG.md`:

```markdown
# Changelog

## [1.0.0] - 2026-04-03

### Added
- JWT authentication (register, login)
- Task CRUD with user isolation
- Status and priority management
- Due date support
- React frontend with filters
- OpenAPI documentation
- GitHub Actions CI/CD pipeline
- Docker and docker-compose support

### Security
- Rate limiting on auth endpoints
- Security headers via helmet
- Parameterized queries via Prisma ORM
- Input validation via Zod
```

### 8.3 Tag the release v1.0.0

```bash
/ops:ops-release "v1.0.0"
```

Claude verifies the pre-release checklist and creates the tag:

```
Pre-release checklist:
[x] Tests pass (CI green)
[x] CHANGELOG updated
[x] README up to date
[x] Version in package.json: 1.0.0
[x] No critical TODO open

Tag creation:
  git tag -a v1.0.0 -m "feat: TaskFlow v1.0.0 - MVP release"
  git push origin v1.0.0
```

---

## Recap of commands used

| Phase | Command | What it produced |
|-------|---------|------------------|
| Init | `/ops:ops-env` | `.env.example`, `.gitignore` configured |
| Spec | `/biz:biz-mvp` | MoSCoW prioritization P1-P4 |
| Spec | `/work:work-specify` | `spec.md` with Given/When/Then User Stories |
| Spec | `/biz:biz-personas` | 2 personas (Alex, Sarah) |
| Archi | `/work:work-plan` | `plan.md`: file structure, dependencies, risks |
| Archi | `/ops:ops-database` | `prisma/schema.prisma` |
| Archi | `/doc:doc-generate` | `docs/architecture.md` with ASCII diagram |
| Dev | `/dev:dev-tdd` | Tests + auth and CRUD implementation (Red/Green/Refactor cycle) |
| Dev | `/dev:dev-api` | Documented REST endpoints |
| Dev | `/dev:dev-component` | React components with tests |
| Dev | `/doc:doc-api-spec` | `docs/openapi.yaml` |
| Quality | `/qa:qa-security` | OWASP report (67 -> 92) |
| Quality | `/qa:qa-loop "score 90"` | 3 automatic audit-fix iterations |
| Quality | `/qa:qa-perf` | DB index + HTTP compression |
| CI/CD | `/ops:ops-ci` | `.github/workflows/ci.yml` |
| CI/CD | `/ops:ops-docker` | `Dockerfile` x2 + `docker-compose.yml` |
| CI/CD | `/work:work-pr` | PR with generated description |
| Release | `/doc:doc-generate` | `README.md` with badges |
| Release | `/doc:doc-changelog` | `CHANGELOG.md` |
| Release | `/ops:ops-release` | Tag `v1.0.0` |
| Commits | `/work:work-commit` | 7 atomic Conventional Commits |

**Total: 20 commands, 8 phases, 1 complete product.**

---

## What you have learned

1. **The complete workflow in real conditions**: Explore -> Specify -> Plan -> TDD -> Audit -> Commit -> PR -> Deploy are not optional steps, each one produced something concrete.

2. **Specification before code**: The Given/When/Then User Stories guided the tests (`/work:work-specify`), the personas influenced the UX (`/biz:biz-personas`).

3. **Architecture as a documented decision**: The Express vs Fastify choice is traced, the Prisma schema is generated once and serves as the source of truth.

4. **TDD as a safety net**: The isolation tests (forbidden access to another user's task) were written before the code. Without TDD, this case would probably have been forgotten.

5. **Iterative audit**: Going from 67 to 92 in 3 iterations with `/qa:qa-loop` is more efficient than fixing everything manually after the fact.

6. **Atomic commits**: 7 readable commits are worth more than one giant "feat: add everything" commit. Each commit is referenceable, revertable, understandable.

7. **Generated documentation**: OpenAPI, README, CHANGELOG and architecture are by-products of the workflow, not a separate chore.

---

## Going further

TaskFlow v1.0.0 is in production. Here are the possible next steps:

**v1.1 - Missing features**
- JWT refresh tokens
- Advanced filters and search
- Custom tags

```bash
/work:work-flow-feature "JWT refresh token for TaskFlow"
```

**Operations**
- Monitoring and alerts

```bash
/ops:ops-monitoring "TaskFlow API: request rate, error rate, p99 latency metrics"
```

- Load testing before production rollout

```bash
/ops:ops-load-testing "TaskFlow API: 100 concurrent users on GET /tasks"
```

**Continuous quality**
- GDPR audit

```bash
/legal:legal-rgpd "TaskFlow stores emails and user data"
```

- Continuous improvement

```bash
/qa:qa-tech-debt "TaskFlow v1.0.0: identify priority PDCA improvement axes"
```

---

- [API Guide](/docs/concepts/stack-recipes) - REST API best practices
- [Web Guide](/docs/concepts/stack-recipes) - Advanced frontend architecture
- [Auth Guide](/docs/concepts/stack-recipes) - OAuth2, RBAC, advanced security
- [Testing Guide](/docs/concepts/stack-recipes) - Testing strategy beyond TDD
- [Database Guide](/docs/concepts/stack-recipes) - Indexing, migrations, optimization
- [Observability Guide](/docs/concepts/stack-recipes) - Logs, metrics, traces in production
- [Extend the foundation](/docs/guides/extending-guide) - Create your own rules, skills and agents
- [Team Guide](/docs/guides/team-guide) - Configure the foundation for a team

---

:::tip The secret of the workflow
The value of the foundation is not in the individual commands - it is in their chaining. Each phase feeds the next: the spec guides the tests, the tests guide the implementation, the audit validates everything. Reproduce this workflow on your next projects and adjust it to your context.
:::
