---
sidebar_position: 24
title: "ops-docker"
description: "Containerisation Docker et Docker Compose. Declencher quand l'utilisateur veut dockeriser une application ou creer des containers."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-docker

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Containerisation Docker et Docker Compose. Declencher quand l'utilisateur veut dockeriser une application ou creer des containers.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `ops`, `docker`, `node`, `dist/index.js`, `3000:3000`, `cmd-shell`, `pg_isready -u user -d app` |

## Description detaillee

# Docker Containerization

## Dockerfile Multi-Stage

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules

EXPOSE 3000
HEALTHCHECK CMD wget -q --spider http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

## Docker Compose

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/app
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?required}
      POSTGRES_DB: app
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

## Bonnes pratiques

- Multi-stage builds pour reduire la taille
- Non-root user pour la securite
- .dockerignore pour exclure les fichiers inutiles
- Health checks pour la disponibilite
- Labels pour les metadonnees

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux ops..."_
- _"Je veux docker..."_
- _"Je veux node..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Multi-stage Dockerfile with Docker Compose

# Example: Multi-stage Dockerfile with Docker Compose

## Scenario
A Node.js API with PostgreSQL needs an optimized production image and a local dev setup.

## Multi-stage Dockerfile

```dockerfile
# Dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

# Stage 2: Build
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build
RUN npm prune --production

# Stage 3: Production
FROM node:20-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/main.js"]
```

## Docker Compose (local dev)

```yaml
# docker-compose.yml
services:
  api:
    build:
      context: .
      target: deps
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://app:secret@db:5432/myapp
      NODE_ENV: development
    depends_on:
      db:
        condition: service_healthy
    command: npm run dev

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d myapp"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  pgdata:
```

## Key Decisions

- **Multi-stage**: Final image ~150MB vs ~900MB with full build deps
- **Non-root user**: `appuser` for security (no root in production)
- **Healthcheck**: Docker monitors container health automatically
- **Volume mount**: Dev gets live-reload via bind mount, node_modules excluded
- **Service dependency**: `condition: service_healthy` ensures DB is ready before API starts



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
