---
sidebar_position: 1
title: Setup Docker
description: Multi-stage Dockerfile and docker-compose example
---

# Complete Docker Setup

This example shows how to containerize an application with an optimized multi-stage Dockerfile and docker-compose.

## Command used

```bash
/ops:ops-docker "Dockerize a Next.js application with PostgreSQL"
```

## Generated structure

```
.
├── Dockerfile              # Multi-stage build
├── docker-compose.yml      # Dev environment
├── docker-compose.prod.yml # Production
├── .dockerignore           # Excluded files
└── scripts/
    └── docker-entrypoint.sh
```

## Multi-Stage Dockerfile

### `Dockerfile`

```dockerfile
# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:20-alpine AS deps

# System dependencies for node-gyp
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy dependency files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci --only=production

# ============================================
# Stage 2: Builder
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies from previous stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build environment variables
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

# Disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN npm run build

# ============================================
# Stage 3: Runner (Production)
# ============================================
FROM node:20-alpine AS runner

WORKDIR /app

# Create a non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy required files
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Copy the Next.js build with the right permissions
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Runtime environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Switch user
USER nextjs

# Expose the port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

# Start command
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

### `docker-compose.yml` (Development)

```yaml
version: '3.8'

services:
  # Next.js application
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: deps  # Use the deps stage for dev
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

  # Redis (cache and sessions)
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

  # Adminer (DB interface)
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

  # Nginx reverse proxy (optional)
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

## Useful scripts

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

# Build the production image
build:
	docker build -t myapp:latest .

# Start the development environment
dev:
	docker-compose up -d
	docker-compose logs -f app

# Start with debug tools (Adminer)
dev-debug:
	docker-compose --profile debug up -d
	docker-compose logs -f app

# Start production
prod:
	docker-compose -f docker-compose.prod.yml up -d

# Stop all containers
down:
	docker-compose down
	docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# View logs
logs:
	docker-compose logs -f

# Clean up (volumes included)
clean:
	docker-compose down -v
	docker system prune -f

# Rebuild without cache
rebuild:
	docker-compose build --no-cache
	docker-compose up -d

# Run migrations
migrate:
	docker-compose exec app npx prisma migrate dev

# Shell into the container
shell:
	docker-compose exec app sh

# Tests in the container
test:
	docker-compose exec app npm test
```

## Next.js Configuration

### `next.config.js` (for standalone output)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Required for the optimized Dockerfile

  // Production optimizations
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

  // Environment
  env: {
    NEXT_PUBLIC_APP_VERSION: process.env.npm_package_version,
  },
};

module.exports = nextConfig;
```

### Health Check Endpoint

```typescript
// pages/api/health.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { prisma } from '@/lib/prisma';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // Check the DB connection
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

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Multi-stage** | 3 stages: deps → builder → runner |
| **Image size** | ~150MB (vs 1GB+ without optimization) |
| **Security** | Non-root user, minimal files |
| **Healthcheck** | `/api/health` endpoint |
| **Dev/Prod** | Separate docker-compose files |

## Related commands

- `/ops:ops-ci` - CI pipeline with Docker build
- `/ops:ops-k8s` - Kubernetes deployment
- `/qa:qa-security` - Image vulnerability scan

---

:::tip Security scan
Scan your image with Trivy:
```bash
trivy image myapp:latest
```
:::
