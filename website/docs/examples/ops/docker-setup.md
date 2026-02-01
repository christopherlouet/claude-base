---
sidebar_position: 1
title: Setup Docker
description: Exemple de Dockerfile multi-stage et docker-compose
---

# Setup Docker Complet

Cet exemple montre comment containeriser une application avec un Dockerfile multi-stage optimisé et docker-compose.

## Commande utilisée

```bash
/ops:ops-docker "Dockeriser une application Next.js avec PostgreSQL"
```

## Structure générée

```
.
├── Dockerfile              # Build multi-stage
├── docker-compose.yml      # Dev environment
├── docker-compose.prod.yml # Production
├── .dockerignore           # Fichiers exclus
└── scripts/
    └── docker-entrypoint.sh
```

## Dockerfile Multi-Stage

### `Dockerfile`

```dockerfile
# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:20-alpine AS deps

# Dépendances système pour node-gyp
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copier les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer les dépendances
RUN npm ci --only=production

# ============================================
# Stage 2: Builder
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les dépendances du stage précédent
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Variables d'environnement de build
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Désactiver la télémétrie Next.js
ENV NEXT_TELEMETRY_DISABLED=1

# Build l'application
RUN npm run build

# ============================================
# Stage 3: Runner (Production)
# ============================================
FROM node:20-alpine AS runner

WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copier les fichiers nécessaires
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Copier le build Next.js avec les bonnes permissions
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Variables d'environnement runtime
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Changer d'utilisateur
USER nextjs

# Exposer le port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

# Commande de démarrage
CMD ["node", "server.js"]
```

### `.dockerignore`

```
# Dependencies
node_modules
.pnp
.pnp.js

# Build
.next
out
build
dist

# Testing
coverage

# Git
.git
.gitignore

# IDE
.idea
.vscode
*.swp
*.swo

# Logs
*.log
npm-debug.log*

# Environment
.env
.env.*
!.env.example

# Docker
Dockerfile*
docker-compose*
.docker

# Documentation
README.md
docs

# Tests
__tests__
*.test.ts
*.spec.ts
jest.config.*

# Misc
.DS_Store
*.tgz
```

## Docker Compose

### `docker-compose.yml` (Développement)

```yaml
version: '3.8'

services:
  # Application Next.js
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: deps  # Utiliser le stage deps pour le dev
    image: myapp:dev
    container_name: myapp-dev
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/myapp_dev
      - REDIS_URL=redis://redis:6379
    volumes:
      - .:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    command: npm run dev
    networks:
      - myapp-network

  # PostgreSQL
  db:
    image: postgres:16-alpine
    container_name: myapp-db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: myapp_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - myapp-network

  # Redis (cache et sessions)
  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    networks:
      - myapp-network

  # Adminer (interface DB)
  adminer:
    image: adminer:latest
    container_name: myapp-adminer
    ports:
      - "8080:8080"
    environment:
      ADMINER_DEFAULT_SERVER: db
    depends_on:
      - db
    networks:
      - myapp-network
    profiles:
      - debug

volumes:
  postgres_data:
  redis_data:

networks:
  myapp-network:
    driver: bridge
```

### `docker-compose.prod.yml` (Production)

```yaml
version: '3.8'

services:
  app:
    image: ${REGISTRY}/myapp:${VERSION:-latest}
    container_name: myapp-prod
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - myapp-network

  # Nginx reverse proxy (optionnel)
  nginx:
    image: nginx:alpine
    container_name: myapp-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    networks:
      - myapp-network

networks:
  myapp-network:
    driver: bridge
```

## Scripts utiles

### `scripts/docker-entrypoint.sh`

```bash
#!/bin/sh
set -e

echo "🔄 Running database migrations..."
npx prisma migrate deploy

echo "🌱 Seeding database (if needed)..."
npx prisma db seed || true

echo "🚀 Starting application..."
exec "$@"
```

### `Makefile`

```makefile
.PHONY: build dev prod down logs clean

# Build l'image de production
build:
	docker build -t myapp:latest .

# Démarrer l'environnement de développement
dev:
	docker-compose up -d
	docker-compose logs -f app

# Démarrer avec debug tools (Adminer)
dev-debug:
	docker-compose --profile debug up -d
	docker-compose logs -f app

# Démarrer la production
prod:
	docker-compose -f docker-compose.prod.yml up -d

# Arrêter tous les conteneurs
down:
	docker-compose down
	docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Voir les logs
logs:
	docker-compose logs -f

# Nettoyer (volumes inclus)
clean:
	docker-compose down -v
	docker system prune -f

# Rebuild sans cache
rebuild:
	docker-compose build --no-cache
	docker-compose up -d

# Exécuter les migrations
migrate:
	docker-compose exec app npx prisma migrate dev

# Shell dans le conteneur
shell:
	docker-compose exec app sh

# Tests dans le conteneur
test:
	docker-compose exec app npm test
```

## Configuration Next.js

### `next.config.js` (pour standalone output)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Requis pour le Dockerfile optimisé

  // Optimisations de production
  poweredByHeader: false,
  compress: true,

  // Images
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**.example.com',
      },
    ],
  },

  // Environnement
  env: {
    NEXT_PUBLIC_APP_VERSION: process.env.npm_package_version,
  },
};

module.exports = nextConfig;
```

### Endpoint Health Check

```typescript
// pages/api/health.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { prisma } from '@/lib/prisma';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // Vérifier la connexion DB
    await prisma.$queryRaw`SELECT 1`;

    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: process.env.NEXT_PUBLIC_APP_VERSION,
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: 'Database connection failed',
    });
  }
}
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Multi-stage** | 3 stages: deps → builder → runner |
| **Taille image** | ~150MB (vs 1GB+ sans optimisation) |
| **Sécurité** | User non-root, fichiers minimaux |
| **Healthcheck** | Endpoint `/api/health` |
| **Dev/Prod** | docker-compose séparés |

## Commandes associées

- `/ops:ops-ci` - Pipeline CI avec build Docker
- `/ops:ops-k8s` - Déploiement Kubernetes
- `/qa:qa-security` - Scan de vulnérabilités image

---

:::tip Scan de sécurité
Scannez votre image avec Trivy :
```bash
trivy image myapp:latest
```
:::
