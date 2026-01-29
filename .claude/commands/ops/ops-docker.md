# Agent DOCKER

Dockerisation et containerisation de projets.

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Créer un Dockerfile
Génère un Dockerfile optimisé pour le projet.

### Mode 2 : Créer un docker-compose
Génère une configuration multi-containers.

### Mode 3 : Optimiser un Dockerfile existant
Analyse et améliore un Dockerfile existant.

---

## Dockerfile par Type de Projet

### Node.js (Production)
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies first (cache optimization)
COPY package*.json ./
RUN npm ci --only=production

# Copy source and build
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS production
WORKDIR /app

# Security: non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy only necessary files
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./

USER nodejs
EXPOSE 3000

CMD ["node", "dist/index.js"]
```

### Python (FastAPI/Django)
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.12-slim
WORKDIR /app

# Security: non-root user
RUN useradd --create-home --shell /bin/bash appuser

# Copy dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

# Copy application
COPY --chown=appuser:appuser . .

USER appuser
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Go
```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

# Production stage
FROM scratch
COPY --from=builder /app/main /main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080
ENTRYPOINT ["/main"]
```

### React/Frontend (avec Nginx)
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## Docker Compose

### Application Web + Base de données
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgres://user:pass@db:5432/app
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    networks:
      - app-network

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:?required}
      - POSTGRES_DB=app
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d app"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### Développement local
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - /app/node_modules  # Exclude node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: npm run dev
```

---

## Bonnes Pratiques

### Sécurité
- IMPORTANT: Ne jamais utiliser `root` en production
- IMPORTANT: Ne jamais inclure de secrets dans l'image
- Utiliser des images de base minimales (alpine, slim, distroless)
- Scanner les vulnérabilités avec `docker scout` ou `trivy`

### Performance
- IMPORTANT: Optimiser l'ordre des layers pour le cache
- Multi-stage builds pour réduire la taille
- Utiliser `.dockerignore` pour exclure les fichiers inutiles

### .dockerignore
```
node_modules
npm-debug.log
.git
.gitignore
.env
.env.*
Dockerfile*
docker-compose*
.dockerignore
README.md
.vscode
.idea
coverage
.nyc_output
dist
build
*.log
```

---

## Checklist Dockerfile

### Sécurité
- [ ] User non-root
- [ ] Pas de secrets hardcodés
- [ ] Image de base à jour
- [ ] Scan de vulnérabilités passé

### Performance
- [ ] Multi-stage build
- [ ] .dockerignore configuré
- [ ] Layers optimisés pour le cache
- [ ] Taille d'image minimale

### Production-ready
- [ ] Healthcheck configuré
- [ ] Logs vers stdout/stderr
- [ ] Graceful shutdown (SIGTERM)
- [ ] Variables d'environnement pour config

---

## Commandes Utiles

```bash
# Build
docker build -t myapp:latest .

# Build sans cache
docker build --no-cache -t myapp:latest .

# Run
docker run -d -p 3000:3000 --name myapp myapp:latest

# Logs
docker logs -f myapp

# Shell dans le container
docker exec -it myapp sh

# Taille de l'image
docker images myapp

# Scanner les vulnérabilités
docker scout cves myapp:latest

# Compose
docker compose up -d
docker compose logs -f
docker compose down
```

## Output attendu

### Fichiers générés
- `Dockerfile` - Image de production
- `Dockerfile.dev` - Image de développement (optionnel)
- `docker-compose.yml` - Orchestration
- `.dockerignore` - Exclusions

### Informations
- Taille estimée de l'image
- Commandes pour build/run
- Variables d'environnement requises

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ci` | Configurer CI/CD avec Docker |
| `/infra-code` | Infrastructure as Code |
| `/env` | Gestion des environnements |
| `/secrets-management` | Gestion des secrets |
| `/monitoring` | Monitoring des containers |

---

IMPORTANT: Toujours utiliser des tags spécifiques pour les images de base (pas `latest`).

IMPORTANT: Les secrets doivent être passés via variables d'environnement ou secrets manager.

YOU MUST scanner l'image pour les vulnérabilités avant déploiement.

NEVER inclure de secrets ou credentials dans l'image Docker.
