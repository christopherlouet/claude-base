---
sidebar_position: 11
title: "10 - Projet complet : TaskFlow"
description: "Projet fil rouge : construisez un mini-SaaS de A a Z en utilisant tout le workflow du socle"
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Projet complet : TaskFlow

<DifficultyBadge level="advanced" /> **Duree estimee : 3-4 heures**

Ce tutoriel est le point de convergence de tous les tutoriels precedents. Vous allez construire **TaskFlow**, un mini-SaaS de gestion de taches, de la definition du MVP jusqu'au deploiement en production, en utilisant chaque composant du socle dans son contexte reel.

Ce tutoriel ne vous montre pas "comment coder" une API. Il vous montre **comment utiliser le socle** pour construire un produit complet avec qualite et methode.

## Objectifs

A la fin de ce tutoriel, vous saurez :
- Enchainer les phases **Explore -> Specify -> Plan -> TDD -> Audit -> Commit -> PR -> Deploy** sur un vrai projet
- Choisir la bonne commande au bon moment
- Gerer les decisions d'architecture avec Claude
- Traiter les echecs d'audit et les corriger en boucle
- Produire une release versionnee avec documentation

## Prerequisites

- Tutoriels 01 a 06 completes (workflow de base, TDD, CI/CD)
- Node.js 20+ et npm installe
- Git configure avec un compte GitHub
- Claude Code fonctionnel avec le socle

## Ce que vous allez construire

**TaskFlow** est une application de gestion de taches minimaliste :

```
Backend (Node.js + TypeScript + Express)
  - Authentification JWT (inscription, connexion, logout)
  - CRUD taches (creer, lire, modifier, supprimer)
  - Filtres : statut (todo/in-progress/done), priorite (low/medium/high), date limite

Frontend (React + TypeScript)
  - Page de connexion / inscription
  - Liste des taches avec filtres
  - Formulaire de creation / modification

Qualite
  - Tests unitaires et d'integration (Jest, Supertest)
  - Audit securite OWASP
  - Pipeline GitHub Actions
  - Docker + docker-compose
```

## Vue d'ensemble du workflow

```
Phase 1  Init          (30 min)  -> Projet, CLAUDE.md, .env
Phase 2  Specification (30 min)  -> MVP, User Stories, Personas
Phase 3  Architecture  (30 min)  -> Plan, schema DB, decisions tech
Phase 4  Backend TDD   (60 min)  -> Auth, CRUD, OpenAPI
Phase 5  Frontend TDD  (45 min)  -> Composants, integration
Phase 6  Qualite       (30 min)  -> Audit securite, boucle qa-loop
Phase 7  CI/CD         (30 min)  -> GitHub Actions, Docker, PR
Phase 8  Release       (15 min)  -> README, CHANGELOG, tag v1.0.0
```

---

## Phase 1 : Initialisation (30 min)

### 1.1 Creer le projet et le depot Git

```bash
mkdir taskflow && cd taskflow
git init
git remote add origin https://github.com/votre-username/taskflow.git
```

Initialisez la structure de base du projet :

```bash
mkdir -p backend/src frontend/src
touch backend/package.json frontend/package.json
```

### 1.2 Configurer les variables d'environnement

```bash
/ops:ops-env "Application Node.js avec JWT, base de donnees SQLite pour dev, PostgreSQL pour prod"
```

Claude va generer deux fichiers. D'abord `.env.example` (commite dans Git) :

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
# En production : postgresql://user:password@host:5432/taskflow

# Frontend
VITE_API_URL=http://localhost:3000/api
```

Puis `.env` (dans `.gitignore`, avec vos vraies valeurs de dev).

:::warning Securite
Ne committez jamais `.env`. Verifiez que `.gitignore` contient bien `.env` avant de continuer.
:::

### 1.3 Configurer CLAUDE.md

Creez `CLAUDE.md` a la racine du projet avec les conventions specifiques a TaskFlow :

```markdown
# TaskFlow

API de gestion de taches avec authentification JWT.

## Stack
- Backend : Node.js 20, Express, TypeScript strict, Zod, Prisma, SQLite (dev) / PostgreSQL (prod)
- Frontend : React 18, TypeScript strict, Vite, React Query
- Tests : Jest, Supertest (backend), Vitest, React Testing Library (frontend)

## Conventions
- camelCase pour variables et fonctions
- PascalCase pour classes et composants React
- kebab-case pour noms de fichiers
- Prefixe `I` interdit pour interfaces TypeScript
- Couverture minimum : 80%

## Structure backend
src/
  routes/      # Express routes
  services/    # Logique metier
  models/      # Types et interfaces
  middleware/  # Auth, validation, erreurs
  schemas/     # Validation Zod

## Workflow
Toujours : Explore -> Plan -> TDD -> Audit -> Commit
```

---

## Phase 2 : Specification (30 min)

### 2.1 Definir le MVP

```bash
/biz:biz-mvp "Application SaaS de gestion de taches pour developpeurs individuels et petites equipes"
```

Claude analyse le domaine et propose une priorisation MoSCoW :

```
## MVP TaskFlow

### P1 - Must Have (v1.0)
- Inscription et connexion securisee
- CRUD taches complet
- Statuts : todo / in-progress / done
- Priorites : low / medium / high
- Date limite par tache

### P2 - Should Have (v1.1)
- Filtrage et recherche
- Tags personnalises
- Pagination

### P3 - Could Have (v1.2)
- Notifications email (echeance)
- Partage de taches entre utilisateurs
- Vue kanban

### P4 - Won't Have (v1.0)
- Application mobile native
- Integrations tierces (Jira, Linear)
```

Validez ce perimetre. Le P1 est votre cible pour ce tutoriel.

### 2.2 Generer les User Stories

```bash
/work:work-specify "API de gestion de taches TaskFlow avec authentification JWT et CRUD taches"
```

Claude produit `spec.md` avec les User Stories en format Given/When/Then. Extrait :

```markdown
## User Stories - Authentification

### US-01 : Inscription
**P1** | En tant que nouvel utilisateur, je veux creer un compte
pour acceder a TaskFlow.

**Criteres d'acceptation :**
- Given un email valide et un mot de passe >= 8 caracteres
- When je soumets le formulaire d'inscription
- Then mon compte est cree et je recois un token JWT

- Given un email deja utilise
- When je tente de m'inscrire
- Then je recois une erreur 409 Conflict

### US-02 : Connexion
**P1** | En tant qu'utilisateur inscrit, je veux me connecter
pour acceder a mes taches.

...

## User Stories - Taches

### US-03 : Creer une tache
**P1** | En tant qu'utilisateur connecte, je veux creer une tache
avec titre, description, priorite et date limite.

**Criteres d'acceptation :**
- Given un utilisateur authentifie avec les champs obligatoires (titre)
- When je soumets la creation
- Then la tache est creee avec statut "todo" par defaut

- Given un titre vide
- When je soumets la creation
- Then je recois une erreur 400 avec message explicite

...
```

### 2.3 Creer les personas

```bash
/biz:biz-personas "Utilisateurs de TaskFlow"
```

Claude genere deux personas principaux :

```
## Persona 1 : Alex - Developpeur Solo

Age : 28 ans
Role : Freelance full-stack
Usage : Gere ses projets clients et ses side-projects
Frustration : Les outils existants sont trop complexes pour un usage solo
Besoin : Interface simple, API propre pour integration dans son workflow CLI
Quote : "Je veux juste savoir ce que j'ai a faire aujourd'hui"

## Persona 2 : Sarah - Tech Lead

Age : 35 ans
Role : Lead dev dans une startup (equipe de 8)
Usage : Coordonne les taches de son equipe
Frustration : Trop de friction dans les outils actuels, onboarding difficile
Besoin : Visibilite sur l'avancement, filtres par membre et par sprint
Quote : "Je veux voir en un coup d'oeil ce qui bloque"
```

Ces personas guideront vos decisions UX dans la phase frontend.

---

## Phase 3 : Architecture et Plan (30 min)

### 3.1 Generer le plan d'implementation

```bash
/work:work-plan "Backend Express + TypeScript pour TaskFlow selon spec.md : auth JWT, CRUD taches, validation Zod, tests Jest"
```

Claude produit `plan.md` avec la structure complete :

```
## Plan d'implementation : TaskFlow Backend

### Structure des fichiers a creer
backend/
  src/
    app.ts              # Express app (sans listen)
    server.ts           # Point d'entree (avec listen)
    routes/
      auth.ts           # POST /auth/register, POST /auth/login
      tasks.ts          # CRUD /tasks
    services/
      auth.service.ts   # Logique inscription/connexion
      task.service.ts   # Logique CRUD taches
    middleware/
      auth.middleware.ts # Verification JWT
      error.middleware.ts # Gestion erreurs centralisee
    schemas/
      auth.schema.ts    # Zod : RegisterInput, LoginInput
      task.schema.ts    # Zod : CreateTaskInput, UpdateTaskInput
    models/
      user.model.ts     # Interface User
      task.model.ts     # Interface Task, TaskStatus, TaskPriority
  prisma/
    schema.prisma       # Schema DB
  tests/
    auth.test.ts
    tasks.test.ts

### Dependances
- express, @types/express
- zod (validation)
- prisma, @prisma/client
- jsonwebtoken, bcryptjs
- jest, supertest (tests)
- typescript, ts-node

### Risques identifies
1. Migration SQLite -> PostgreSQL : utiliser Prisma pour l'abstraction
2. Tokens JWT en memoire en dev : prevoir refresh token pour v1.1
3. Race conditions sur les taches partagees : hors scope v1.0
```

### 3.2 Decision technique : framework HTTP

Claude propose les options et leurs compromis :

```
Question : Express ou Fastify pour le backend ?

Express
  Pour : Ecosysteme mature, middleware abondant, connu de tous
  Contre : Moins performant, pas de validation native

Fastify
  Pour : Plus rapide, validation JSON Schema native, TypeScript first
  Contre : Ecosysteme plus petit, moins de ressources communautaires

Recommandation pour TaskFlow :
  Express avec Zod - meilleur choix car :
  - Equipe probablement familiere avec Express
  - Zod offre une validation TypeScript superieure au JSON Schema
  - La performance n'est pas critique pour un MVP
  - Migration vers Fastify possible apres v1.0 si besoin
```

On choisit Express + Zod. Cette decision est documentee dans `plan.md`.

### 3.3 Schema de base de donnees

```bash
/ops:ops-database "Schema Prisma pour TaskFlow : User (email, password hash, timestamps) et Task (title, description, status, priority, dueDate, userId foreign key)"
```

Claude genere `prisma/schema.prisma` :

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = env("DATABASE_PROVIDER") // "sqlite" ou "postgresql"
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

### 3.4 Documenter l'architecture

```bash
/doc:doc-architecture "Architecture TaskFlow : Express backend, React frontend, Prisma ORM, JWT auth"
```

Claude genere `docs/architecture.md` avec un diagramme ASCII :

```
## Architecture TaskFlow

### Vue d'ensemble

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

### Flux d'authentification

  Client -> POST /auth/register -> Hash password (bcrypt) -> Prisma create -> JWT token
  Client -> POST /auth/login    -> Verify password         -> Prisma find  -> JWT token
  Client -> GET  /tasks         -> Verify JWT middleware   -> Prisma query -> JSON
```

---

## Phase 4 : Developpement TDD - Backend (60 min)

### 4.1 Module d'authentification

Commencez par le module le plus critique : l'authentification.

```bash
/dev:dev-tdd "Module d'authentification JWT pour TaskFlow : inscription avec hash bcrypt, connexion avec verification, generation de token"
```

Claude suit le cycle **Red -> Green -> Refactor**.

**RED - Les tests qui echouent d'abord :**

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

Claude lance les tests : **tous echouent** (routes non implementees). C'est normal, c'est le cycle Red.

**GREEN - Implementation minimale :**

Claude cree `src/routes/auth.ts`, `src/services/auth.service.ts` et `src/schemas/auth.schema.ts`. Les tests passent un a un.

**REFACTOR - Ameliorations :**

Apres que tous les tests passent, Claude propose :
- Extraire la generation de token dans un helper `src/lib/jwt.ts`
- Centraliser la gestion des erreurs dans `src/middleware/error.middleware.ts`
- Typer les reponses avec des interfaces dans `src/models/`

Commitez apres le refactoring :

```bash
/work:work-commit
```

Message suggere par Claude :

```
feat(auth): add JWT authentication module

- Add POST /auth/register with bcrypt password hashing
- Add POST /auth/login with credential verification
- Add JWT token generation and validation
- Add Zod validation for auth inputs
- Add auth middleware for protected routes
- Add integration tests (coverage: 94%)
```

### 4.2 CRUD des taches

```bash
/dev:dev-tdd "CRUD complet des taches pour TaskFlow : creer, lire (liste + detail), modifier, supprimer, avec auth middleware"
```

Claude suit le meme cycle. Les tests couvrent les cas d'acces non autorise (tache d'un autre utilisateur) :

```typescript
// tests/tasks.test.ts - extrait
describe('GET /tasks/:id', () => {
  it("should return 403 if task belongs to another user", async () => {
    // Creer deux utilisateurs et une tache pour le premier
    const { token: token1 } = await createUserAndLogin('user1@test.com');
    const { token: token2 } = await createUserAndLogin('user2@test.com');
    const task = await createTask(token1, { title: 'Ma tache privee' });

    // L'utilisateur 2 tente d'acceder a la tache de l'utilisateur 1
    const response = await request(app)
      .get(`/tasks/${task.id}`)
      .set('Authorization', `Bearer ${token2}`)
      .expect(403);

    expect(response.body.error).toMatch(/forbidden/i);
  });
});
```

Ce test d'isolation est crucial pour la securite. Claude l'identifie et l'inclut automatiquement grace a la rule `security` du socle.

Commitez :

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

### 4.3 Documentation OpenAPI

```bash
/doc:doc-api-spec
```

Claude genere `docs/openapi.yaml`. Extrait :

```yaml
openapi: 3.0.3
info:
  title: TaskFlow API
  version: 1.0.0
  description: API de gestion de taches avec authentification JWT

security:
  - bearerAuth: []

paths:
  /auth/register:
    post:
      tags: [Authentication]
      summary: Creer un compte
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
          description: Compte cree
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
      summary: Liste des taches de l'utilisateur connecte
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
          description: Liste des taches
          ...
        '401':
          $ref: '#/components/responses/UnauthorizedError'

# ... (suite des endpoints)

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## Phase 5 : Developpement TDD - Frontend (45 min)

### 5.1 Composant TaskList

```bash
/dev:dev-component "TaskList component pour TaskFlow : affiche la liste des taches avec statut, priorite, date limite. Props : tasks (Task[]), onStatusChange, onDelete"
```

Claude genere le composant avec ses tests :

```typescript
// frontend/src/components/TaskList.test.tsx - extrait
describe('TaskList', () => {
  const mockTasks: Task[] = [
    {
      id: '1',
      title: 'Corriger le bug auth',
      status: 'IN_PROGRESS',
      priority: 'HIGH',
      dueDate: '2026-04-10',
      ...
    },
    // ...
  ];

  it('should render all tasks', () => {
    render(<TaskList tasks={mockTasks} onStatusChange={vi.fn()} onDelete={vi.fn()} />);
    expect(screen.getByText('Corriger le bug auth')).toBeInTheDocument();
  });

  it('should call onStatusChange when status badge is clicked', async () => {
    const onStatusChange = vi.fn();
    render(<TaskList tasks={mockTasks} onStatusChange={onStatusChange} onDelete={vi.fn()} />);

    await userEvent.click(screen.getByText('IN_PROGRESS'));
    expect(onStatusChange).toHaveBeenCalledWith('1', expect.any(String));
  });
});
```

Comme dans le tutoriel 02, Claude genere composant, tests et stories Storybook si detecte.

### 5.2 Composant TaskForm

```bash
/dev:dev-component "TaskForm component : formulaire de creation/modification de tache avec validation client (titre obligatoire, date future)"
```

Claude genere un formulaire avec React Hook Form (ou state natif selon le contexte du projet) et validation cote client.

### 5.3 Integration frontend-backend

```bash
/dev:dev-tdd "Integration frontend TaskFlow : hook useTaskApi qui wrap les appels API avec React Query, gestion des erreurs 401 avec redirect vers login"
```

Claude cree `src/hooks/useTaskApi.ts` en TDD :

```typescript
// Test : redirection vers /login sur 401
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

Commitez le frontend :

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

## Phase 6 : Qualite et Securite (30 min)

### 6.1 Audit de securite OWASP

Comme dans le tutoriel 05, lancez l'audit complet :

```bash
/qa:qa-security
```

Resultat initial (exemple realiste) :

```markdown
## Audit Securite OWASP - TaskFlow

### Critiques (2)

#### A07 - Token JWT sans expiration courte
Fichier : src/lib/jwt.ts:8
Probleme : expiresIn: '30d' - duree excessive
Risque : Token vole utilisable 30 jours
Fix : Reduire a 15m + implementer refresh token

#### A05 - Rate limiting absent
Probleme : Aucun rate limiting sur /auth/login
Risque : Attaque brute force sur les mots de passe
Fix : Installer express-rate-limit, 5 tentatives/15min sur /auth

### Eleves (2)

#### A02 - Mot de passe en log potentiel
Fichier : src/middleware/error.middleware.ts:22
Probleme : console.log(err) peut exposer req.body
Fix : Logger uniquement err.message, jamais req.body

#### A01 - Absence de pagination forcee
Probleme : GET /tasks sans limite retourne toutes les taches
Risque : Enumeration de donnees, DDOS
Fix : Ajouter limit/offset avec maximum de 100 items

### Score initial : 67/100
```

Claude identifie 4 problemes. Corrigez les 2 critiques manuellement ou en demandant a Claude :

```bash
/qa:qa-security "Corriger les problemes critiques identifies : JWT expiration et rate limiting"
```

### 6.2 Boucle d'audit iteratif

```bash
/qa:qa-loop "score 90"
```

La boucle audit-fix-reaudit s'execute automatiquement. Voici le deroulement reel :

**Iteration 1 - Score : 72**

```
Problemes P0 restants :
- Rate limiting non configure sur /auth/login
- JWT expiration encore a 30d dans .env.example

Actions :
1. Ajout express-rate-limit (5 req/15min sur /auth)
2. Mise a jour .env.example : JWT_EXPIRES_IN=15m
3. Ajout commentaire sur la necessite d'un refresh token en v1.1
```

**Iteration 2 - Score : 85**

```
Problemes P1 restants :
- Logging insuffisant (tentatives de connexion echouees non loguees)
- Pagination absente sur GET /tasks
- Headers de securite manquants (X-Content-Type-Options, X-Frame-Options)

Actions :
1. Ajout helmet pour les headers de securite
2. Ajout winston logger pour les evenements auth
3. Ajout parametres limit/offset sur GET /tasks (max 100)
```

**Iteration 3 - Score : 92**

```
Score 92 > 90. Critere atteint.

Problemes P2 restants (non bloquants) :
- HTTPS non configure (normal en dev, a traiter en prod via proxy)
- CSP header restrictif recommande (a fine-tuner selon les assets frontend)
```

La boucle s'arrete. Commitez les corrections :

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

### 6.3 Audit de performance

```bash
/qa:qa-perf
```

Claude identifie deux points d'amelioration :

```
1. Index manquant sur tasks.userId
   Impact : Full scan a chaque GET /tasks
   Fix : Ajouter @index dans le schema Prisma

2. Pas de compression HTTP
   Impact : Reponses non compressees
   Fix : Ajouter compression middleware
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

## Phase 7 : CI/CD et Deploiement (30 min)

### 7.1 Pipeline GitHub Actions

Comme dans le tutoriel 06 :

```bash
/ops:ops-ci "Pipeline CI pour TaskFlow : lint + typecheck, tests backend (Jest), tests frontend (Vitest), audit securite, build Docker"
```

Claude genere `.github/workflows/ci.yml` :

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

### 7.2 Dockeriser l'application

```bash
/ops:ops-docker "Dockeriser TaskFlow : backend Express sur port 3000, frontend React/Vite en build statique servi par Nginx"
```

Claude genere `backend/Dockerfile`, `frontend/Dockerfile` et `docker-compose.yml` :

```yaml
# docker-compose.yml - extrait
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

Testez localement :

```bash
docker-compose up --build
```

### 7.3 Creer la Pull Request

```bash
/work:work-pr
```

Claude analyse tous les commits depuis `main` et genere une PR complete. Extrait du corps genere :

```markdown
## TaskFlow v1.0.0

### Ce que cette PR apporte

Implementation complete du MVP TaskFlow :
authentification JWT, CRUD taches avec validation et isolation par utilisateur,
frontend React avec filtres, pipeline CI/CD et packaging Docker.

### Changements

**Backend**
- Authentification JWT (inscription, connexion)
- CRUD taches avec isolation par utilisateur
- Validation Zod sur tous les inputs
- Rate limiting sur les endpoints auth
- Headers de securite (helmet)
- Pagination sur GET /tasks
- Documentation OpenAPI

**Frontend**
- Page connexion / inscription
- Liste des taches avec filtres statut/priorite
- Formulaire creation / modification
- Gestion des erreurs API (401 redirect)

**Qualite**
- Couverture tests backend : 87%
- Couverture tests frontend : 82%
- Score securite OWASP : 92/100
- Pipeline CI/CD complet

### Tests
- [ ] Backend : `cd backend && npm test`
- [ ] Frontend : `cd frontend && npm test`
- [ ] Docker : `docker-compose up --build`
- [ ] API doc : http://localhost:3000/api-docs
```

---

## Phase 8 : Documentation et Release (15 min)

### 8.1 Generer le README

```bash
/doc:doc-generate
```

Claude produit `README.md` avec badges CI, description, quick start et liens vers la documentation :

```markdown
# TaskFlow

![CI](https://github.com/votre-username/taskflow/workflows/CI/badge.svg)
![Coverage](https://codecov.io/gh/votre-username/taskflow/branch/main/graph/badge.svg)

Mini-SaaS de gestion de taches avec authentification JWT.
Construit avec Express + TypeScript + React.

## Quick Start

# Avec Docker
cp .env.example .env
docker-compose up

# En local (dev)
cd backend && npm install && npm run dev
cd frontend && npm install && npm run dev

## Documentation

- [API Reference](./docs/openapi.yaml)
- [Architecture](./docs/architecture.md)
- [Contributing](./CONTRIBUTING.md)
```

### 8.2 Generer le CHANGELOG

```bash
/doc:doc-changelog
```

Claude analyse l'historique git et genere `CHANGELOG.md` :

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

### 8.3 Taguer la release v1.0.0

```bash
/ops:ops-release "v1.0.0"
```

Claude verifie la checklist pre-release et cree le tag :

```
Checklist pre-release :
[x] Tests passent (CI vert)
[x] CHANGELOG mis a jour
[x] README a jour
[x] Version dans package.json : 1.0.0
[x] Aucun TODO critique ouvert

Creation du tag :
  git tag -a v1.0.0 -m "feat: TaskFlow v1.0.0 - MVP release"
  git push origin v1.0.0
```

---

## Recapitulatif des commandes utilisees

| Phase | Commande | Ce qu'elle a produit |
|-------|----------|---------------------|
| Init | `/ops:ops-env` | `.env.example`, `.gitignore` configure |
| Spec | `/biz:biz-mvp` | Priorisation MoSCoW P1-P4 |
| Spec | `/work:work-specify` | `spec.md` avec User Stories Given/When/Then |
| Spec | `/biz:biz-personas` | 2 personas (Alex, Sarah) |
| Archi | `/work:work-plan` | `plan.md` : structure fichiers, dependances, risques |
| Archi | `/ops:ops-database` | `prisma/schema.prisma` |
| Archi | `/doc:doc-architecture` | `docs/architecture.md` avec diagramme ASCII |
| Dev | `/dev:dev-tdd` | Tests + implementation auth et CRUD (cycle Red/Green/Refactor) |
| Dev | `/dev:dev-api` | Endpoints REST documentes |
| Dev | `/dev:dev-component` | Composants React avec tests |
| Dev | `/doc:doc-api-spec` | `docs/openapi.yaml` |
| Qualite | `/qa:qa-security` | Rapport OWASP (67 -> 92) |
| Qualite | `/qa:qa-loop "score 90"` | 3 iterations audit-fix automatiques |
| Qualite | `/qa:qa-perf` | Index DB + compression HTTP |
| CI/CD | `/ops:ops-ci` | `.github/workflows/ci.yml` |
| CI/CD | `/ops:ops-docker` | `Dockerfile` x2 + `docker-compose.yml` |
| CI/CD | `/work:work-pr` | PR avec description generee |
| Release | `/doc:doc-generate` | `README.md` avec badges |
| Release | `/doc:doc-changelog` | `CHANGELOG.md` |
| Release | `/ops:ops-release` | Tag `v1.0.0` |
| Commits | `/work:work-commit` | 7 commits atomiques Conventional Commits |

**Total : 20 commandes, 8 phases, 1 produit complet.**

---

## Ce que vous avez appris

1. **Le workflow complet en conditions reelles** : Explore -> Specify -> Plan -> TDD -> Audit -> Commit -> PR -> Deploy ne sont pas des etapes optionnelles, elles ont chacune produit quelque chose de concret.

2. **La specification avant le code** : Les User Stories Given/When/Then ont guide les tests (`/work:work-specify`), les personas ont influence l'UX (`/biz:biz-personas`).

3. **L'architecture comme decision documentee** : Le choix Express vs Fastify est trace, le schema Prisma est genere une fois et sert de source de verite.

4. **Le TDD comme filet de securite** : Les tests d'isolation (acces interdit a la tache d'un autre utilisateur) ont ete ecrits avant le code. Sans TDD, ce cas aurait probablement ete oublie.

5. **L'audit iteratif** : Passer de 67 a 92 en 3 iterations avec `/qa:qa-loop` est plus efficace que de tout corriger manuellement apres coup.

6. **Les commits atomiques** : 7 commits lisibles valent mieux qu'un commit geant "feat: add everything". Chaque commit est referencable, revertable, comprehensible.

7. **La documentation generee** : OpenAPI, README, CHANGELOG et architecture sont des sous-produits du workflow, pas une corvee separee.

---

## Pour aller plus loin

TaskFlow v1.0.0 est en production. Voici les prochaines etapes possibles :

**v1.1 - Features manquantes**
- Refresh tokens JWT
- Filtres et recherche avancee
- Tags personnalises

```bash
/work:work-flow-feature "Refresh token JWT pour TaskFlow"
```

**Operations**
- Monitoring et alertes

```bash
/ops:ops-monitoring "TaskFlow API : metriques request rate, error rate, latence p99"
```

- Tests de charge avant mise en production

```bash
/ops:ops-load-testing "TaskFlow API : 100 utilisateurs concurrents sur GET /tasks"
```

**Qualite continue**
- Audit RGPD

```bash
/legal:legal-rgpd "TaskFlow stocke des emails et donnees utilisateur"
```

- Amelioration continue

```bash
/qa:qa-kaizen "TaskFlow v1.0.0 : identifier les axes d'amelioration PDCA prioritaires"
```

---

- [Guide API](/docs/concepts/stack-recipes) - Bonnes pratiques API REST
- [Guide Web](/docs/concepts/stack-recipes) - Architecture frontend avancee
- [Guide Auth](/docs/concepts/stack-recipes) - OAuth2, RBAC, securite avancee
- [Guide Testing](/docs/concepts/stack-recipes) - Strategie de tests au-dela du TDD
- [Guide Database](/docs/concepts/stack-recipes) - Indexation, migrations, optimisation
- [Guide Observabilite](/docs/concepts/stack-recipes) - Logs, metriques, traces en production
- [Etendre le socle](/docs/guides/extending-guide) - Creer vos propres rules, skills et agents
- [Guide Equipe](/docs/guides/team-guide) - Configurer le socle pour une equipe

---

:::tip Le secret du workflow
La valeur du socle n'est pas dans les commandes individuelles - c'est dans leur enchainement. Chaque phase alimente la suivante : la spec guide les tests, les tests guident l'implementation, l'audit valide le tout. Reproduisez ce workflow sur vos prochains projets et ajustez-le a votre contexte.
:::
