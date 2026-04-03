# Guide Infrastructure & Operations

> Workflow complet pour infrastructure, deploiement et operations

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Conteneurs | Docker, Docker Compose, Podman |
| Orchestration | Kubernetes, Helm, K3s |
| IaC | Terraform, Pulumi, Ansible |
| CI/CD | GitHub Actions, GitLab CI, Jenkins |
| Monitoring | Prometheus, Grafana, Loki, Datadog |
| Cloud | AWS, GCP, Azure, Vercel, Railway |
| Homelab | Proxmox, OPNsense, VPS |

## Architecture Recommandee

```
infra/
├── docker/              # Dockerfiles et compose
├── k8s/                 # Manifests Kubernetes
│   ├── base/            # Kustomize base
│   └── overlays/        # Overlays par env (dev, staging, prod)
├── terraform/           # Infrastructure as Code
│   ├── modules/
│   └── environments/
├── ci/                  # Pipelines CI/CD
├── monitoring/          # Dashboards et alertes
└── scripts/             # Scripts d'operations
```

## Workflow Recommande

```
/ops:ops-env → /ops:ops-docker → /ops:ops-ci → /ops:ops-k8s → /ops:ops-monitoring → /ops:ops-backup
```

## Matrice de Decision: Quelle Technologie Choisir

### Orchestration

| Critere | Docker Compose | K3s (Kubernetes leger) | Kubernetes complet |
|---------|---------------|----------------------|-------------------|
| Equipe de 1-3 devs | Recommande | Acceptable | Surdimensionne |
| Applications multiples | Limite | Recommande | Recommande |
| Multi-noeud | Non | Oui | Oui |
| Homelab / VPS single | Ideal | Ideal | Excessif |
| Production critique | Non recommande | Acceptable | Recommande |
| Complexite operationnelle | Faible | Moyenne | Elevee |

### Infrastructure as Code

| Critere | Terraform | Ansible | Pulumi |
|---------|-----------|---------|--------|
| Provisioning cloud | Ideal | Secondaire | Ideal |
| Configuration serveurs | Non recommande | Ideal | Non recommande |
| Equipe DevOps experiente | Recommande | Recommande | Recommande |
| Langage familier (Python/TS) | Non | Non | Oui |
| State management | Remote state | Stateless | Remote state |

---

## Phase 1: Setup Environnement

| Commande | Description |
|----------|-------------|
| `/ops:ops-env` | Gestion variables d'environnement |
| `/ops:ops-deps` | Audit et mise a jour des dependances |
| `/ops:ops-secrets-management` | Gestion securisee des secrets (Vault, SOPS) |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform/Pulumi) |

### Gestion des secrets

Ne jamais stocker de secrets en clair. Utiliser SOPS pour chiffrer les fichiers de configuration ou un gestionnaire dedier.

```bash
# Chiffrement avec SOPS + Age
sops --encrypt --age $(cat ~/.config/sops/age/keys.txt | grep public | awk '{print $4}') \
  .env.production > .env.production.enc

# Dechiffrement
sops --decrypt .env.production.enc > .env.production
```

### Module Terraform type

```hcl
# terraform/modules/app/main.tf
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" {
  description = "Environnement de deploiement (staging, production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment doit etre staging ou production."
  }
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name        = "app-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

### Checklist Phase 1

| Etape | Verification |
|-------|-------------|
| Variables d'environnement | `.env.example` avec placeholders, pas de valeurs reelles |
| Secrets | Aucun secret dans le depot, SOPS ou Vault configure |
| Terraform state | Remote state sur S3/GCS avec chiffrement et verrou |
| Versions | `required_version` fixe dans `versions.tf` |
| `.gitignore` | `.env`, `*.tfstate`, `*.tfstate.backup`, `.terraform/` exclus |

### Bonnes pratiques Phase 1

| A faire | A eviter |
|---------|---------|
| Remote state Terraform avec backend chiffre | State local commite dans git |
| Variables avec `description` et `type` | Variables sans documentation |
| Un repertoire par environnement | Un seul fichier `.tf` pour tout |
| `terraform validate` avant chaque `plan` | Apply sans plan prealable |

---

## Phase 2: Conteneurisation et Deploy

| Commande | Description |
|----------|-------------|
| `/ops:ops-docker` | Dockerfile multi-stage, compose, optimisation |
| `/ops:ops-k8s` | Deploiement Kubernetes (manifests, Helm) |
| `/ops:ops-ci` | Pipeline CI/CD (build, test, deploy) |
| `/ops:ops-vercel` | Deploiement serverless Vercel |
| `/ops:ops-serverless` | Architecture serverless (Lambda, Cloud Functions) |
| `/ops:ops-vps` | Configuration et deploiement VPS |

### Dockerfile multi-stage (Node.js)

```dockerfile
# Stage 1: dependances
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Stage 2: build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: image de production
FROM node:20-alpine AS runner
WORKDIR /app

# Securite: utilisateur non-root
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

USER nextjs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
```

### Docker Compose production

```yaml
# docker-compose.prod.yml
version: "3.9"

services:
  app:
    image: ghcr.io/org/app:${IMAGE_TAG}
    restart: unless-stopped
    environment:
      NODE_ENV: production
      DATABASE_URL: ${DATABASE_URL}
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
  redis_data:
```

### Manifest Kubernetes (Deployment)

```yaml
# k8s/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
      containers:
        - name: app
          image: ghcr.io/org/app:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 30
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
```

### Pipeline GitHub Actions

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - run: npm run lint && npm run typecheck
      - run: npm test -- --coverage

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    steps:
      - run: |
          ssh deploy@${{ secrets.SERVER_IP }} \
            "IMAGE_TAG=${{ github.sha }} docker compose -f docker-compose.prod.yml up -d"
```

### Checklist Phase 2

| Etape | Verification |
|-------|-------------|
| Dockerfile | Multi-stage, Alpine, utilisateur non-root, HEALTHCHECK |
| .dockerignore | `node_modules`, `.git`, `.env*`, `coverage` exclus |
| Compose | `depends_on` avec conditions, volumes nommes, logging configure |
| CI | Secrets via GitHub Secrets, versions d'actions fixees (`@v4`) |
| CD | Deploy production avec `environment` et approbation manuelle |

### Bonnes pratiques Phase 2

| A faire | A eviter |
|---------|---------|
| Images Alpine ou slim | Images `latest` non taggees |
| Utilisateur non-root dans le container | `USER root` en production |
| HEALTHCHECK dans chaque Dockerfile | Container sans health check |
| Cache layers de build dans CI | Rebuild complet a chaque push |

---

## Phase 3: Gestion des Releases

| Commande | Description |
|----------|-------------|
| `/ops:ops-gitflow-init` | Initialiser le workflow GitFlow |
| `/ops:ops-gitflow-feature` | Feature branch GitFlow |
| `/ops:ops-gitflow-release` | Release branch GitFlow |
| `/ops:ops-gitflow-hotfix` | Hotfix branch GitFlow |
| `/ops:ops-release` | Creer une release (tag, changelog) |
| `/ops:ops-hotfix` | Deployer un correctif urgent |
| `/ops:ops-rollback` | Rollback vers version precedente |
| `/ops:ops-mobile-release` | Release mobile (App Store, Play Store) |

### Strategie de versioning

Semantic Versioning (`MAJOR.MINOR.PATCH`) : `MAJOR` pour breaking changes, `MINOR` pour nouvelles fonctionnalites, `PATCH` pour correctifs.

```bash
# Tag et push d'une release
git tag -a v2.1.0 -m "feat: ajout authentification OAuth"
git push origin v2.1.0

# Rollback rapide vers version precedente
docker compose -f docker-compose.prod.yml pull
IMAGE_TAG=v2.0.3 docker compose -f docker-compose.prod.yml up -d
```

### Checklist Phase 3

| Etape | Verification |
|-------|-------------|
| Tag versionne | Format `vMAJOR.MINOR.PATCH` |
| CHANGELOG | Entrees generees pour chaque release |
| Rollback teste | Procedure de rollback validee en staging |
| Hotfix branch | Merge sur `main` ET `develop` |

---

## Phase 4: Monitoring et Maintenance

| Commande | Description |
|----------|-------------|
| `/ops:ops-monitoring` | Metriques, alertes, logs |
| `/ops:ops-observability-stack` | Stack observabilite complete (traces, metriques, logs) |
| `/ops:ops-grafana-dashboard` | Creer dashboards Grafana |
| `/ops:ops-health` | Health checks et readiness probes |
| `/ops:ops-load-testing` | Tests de charge (k6, Artillery) |
| `/ops:ops-cost-optimization` | Optimisation des couts cloud |

### Configuration Prometheus

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

rule_files:
  - "alerts/*.yml"

scrape_configs:
  - job_name: "app"
    static_configs:
      - targets: ["app:3000"]
    metrics_path: /metrics
    scrape_interval: 10s

  - job_name: "postgres"
    static_configs:
      - targets: ["postgres-exporter:9187"]

  - job_name: "node"
    static_configs:
      - targets: ["node-exporter:9100"]
```

### Alertes Prometheus (regles de base)

```yaml
# monitoring/alerts/app.yml
groups:
  - name: app
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Taux d'erreur 5xx eleve (> 5%)"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "P95 latence > 1s"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} indisponible"
```

### Les 3 piliers de l'observabilite

| Pilier | Outil | Ce qu'il mesure |
|--------|-------|----------------|
| Metriques | Prometheus + Grafana | Counters, histogrammes, jauges (latence, throughput, saturation) |
| Logs | Loki + Grafana | Evenements structures JSON, traces d'erreurs |
| Traces | OpenTelemetry + Jaeger | Duree par operation, appels inter-services |

### Checklist Phase 4

| Etape | Verification |
|-------|-------------|
| Endpoint `/health` | Liveness check (retourne 200 si le process est vivant) |
| Endpoint `/ready` | Readiness check (DB + Redis accessibles) |
| Metriques Prometheus | `http_requests_total`, `http_request_duration_seconds` exposes |
| Alertes | Au moins HighErrorRate + ServiceDown configures |
| Logs | Format JSON, sans donnees sensibles |

### Bonnes pratiques Phase 4

| A faire | A eviter |
|---------|---------|
| Logs structures JSON avec `service`, `level`, `trace_id` | Logs texte libres non parsables |
| Separer `/health` (liveness) et `/ready` (readiness) | Un seul endpoint health pour tout |
| Alertes avec seuils calibres sur le trafic reel | Alertes au seuil arbitraire |
| Dashboards par domaine (infra, app, business) | Un seul dashboard monolithique |

---

## Phase 5: Resilience et Migration

| Commande | Description |
|----------|-------------|
| `/ops:ops-database` | Operations base de donnees (migrations, backups) |
| `/ops:ops-backup` | Strategie de backup (3-2-1) |
| `/ops:ops-disaster-recovery` | Plan de reprise d'activite (RTO/RPO) |
| `/ops:ops-migrate` | Migration d'infrastructure ou de donnees |

### Strategie backup 3-2-1

La regle 3-2-1 : 3 copies, sur 2 supports differents, dont 1 hors site.

```bash
#!/bin/bash
# scripts/backup-db.sh
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql.gz"

# Dump + compression
pg_dump "$DATABASE_URL" | gzip > "/backups/local/${BACKUP_FILE}"

# Upload vers stockage distant (S3, Backblaze B2...)
aws s3 cp "/backups/local/${BACKUP_FILE}" "s3://${BACKUP_BUCKET}/db/${BACKUP_FILE}"

# Rotation : garder 7 jours en local, 30 jours sur S3
find /backups/local -mtime +7 -name "*.gz" -delete

echo "Backup termine: ${BACKUP_FILE}"
```

### Patterns Disaster Recovery

| Strategie | RTO | RPO | Cout | Usage |
|-----------|-----|-----|------|-------|
| Backup & Restore | Heures | Heures | Faible | Projets non critiques |
| Pilot Light | 30-60 min | Minutes | Moyen | Staging toujours allume |
| Warm Standby | 5-15 min | Secondes | Eleve | Applications importantes |
| Multi-site Active/Active | Secondes | 0 | Tres eleve | Critique (paiement, sante) |

RTO (Recovery Time Objective) : temps max acceptable avant retour en service.
RPO (Recovery Point Objective) : perte de donnees max acceptable.

### Checklist Phase 5

| Etape | Verification |
|-------|-------------|
| Backup automatise | Cron quotidien, alertes si echec |
| Restore teste | Restauration testee en staging chaque mois |
| RTO/RPO definis | Documentes et valides par l'equipe |
| Migrations reversibles | Chaque migration possede un `down` |
| Runbook incident | Procedure ecrite et accessible hors prod |

---

## Phase 6: Homelab et Reseau

| Commande | Description |
|----------|-------------|
| `/ops:ops-proxmox` | Gestion hyperviseur Proxmox (VMs, LXC) |
| `/ops:ops-opnsense` | Configuration firewall OPNsense |

### Checklist Phase 6

| Etape | Verification |
|-------|-------------|
| Firewall | Regles par defaut `deny all`, ouverture explicite |
| VLANs | Segmentation reseau (IoT, LAN, DMZ separes) |
| Acces SSH | Cle uniquement, `PasswordAuthentication no` |
| Snapshots | Avant toute mise a jour majeure |

---

## Securite: Checklist Complete

### Secrets et credentials

| Verification | Outil |
|-------------|-------|
| Aucun secret dans les images Docker | `docker history`, `trivy image` |
| Variables d'environnement via secrets manager | Vault, AWS SSM, SOPS |
| Rotation des credentials | Automatisee (< 90 jours) |
| `.gitignore` couvre tous les fichiers sensibles | `git-secrets`, `gitleaks` |
| Scan pre-commit pour secrets | `gitleaks` hook |

### Reseau et acces

| Verification | Niveau |
|-------------|--------|
| TLS obligatoire en production | Obligatoire |
| Pare-feu avec whitelist IP admin | Obligatoire |
| Ports non necessaires fermes | Obligatoire |
| Service mesh ou mTLS entre microservices | Recommande |
| Ingress avec WAF (AWS WAF, Cloudflare) | Recommande |

### RBAC et identites

| Verification | Niveau |
|-------------|--------|
| Principe du moindre privilege | Obligatoire |
| Service accounts dedies par application | Obligatoire |
| MFA pour acces cloud et VPN | Obligatoire |
| Audit logs des acces privilegies | Obligatoire |
| Review des permissions tous les 6 mois | Recommande |

### Securite des images

```bash
# Scanner l'image avant deploiement
trivy image ghcr.io/org/app:latest

# Verifier les secrets dans l'historique
docker history --no-trunc ghcr.io/org/app:latest

# Signature d'image avec Cosign
cosign sign --key cosign.key ghcr.io/org/app:latest@sha256:<digest>
cosign verify --key cosign.pub ghcr.io/org/app:latest
```

---

## Optimisation des Couts

### Patterns de reduction

| Pattern | Economie estimee | Complexite |
|---------|-----------------|-----------|
| Right-sizing instances | 20-40% | Faible |
| Spot/Preemptible instances (workloads tolerants) | 60-90% | Moyenne |
| Reserved instances (1-3 ans) | 30-60% | Faible |
| Auto-scaling horizontal | Variable | Moyenne |
| Caching (CDN, Redis) | Reduit trafic DB | Faible |
| Lifecycle policies S3 (archivage Glacier) | 70-90% stockage | Faible |

### Right-sizing en pratique

```bash
# Identifier les instances sous-utilisees (CPU < 10% sur 2 semaines)
# AWS Cost Explorer -> Resource Optimization
# Ou via CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time 2024-01-01T00:00:00 \
  --end-time 2024-01-14T00:00:00 \
  --period 86400 \
  --statistics Average
```

### Bonnes pratiques couts

| A faire | A eviter |
|---------|---------|
| Taguer toutes les ressources (`env`, `team`, `project`) | Ressources sans tags (impossible a imputer) |
| Budget alerts Cloud | Decouvrir la facture en fin de mois |
| Supprimer les ressources inutilisees (EBS, IPs elastiques) | "On verra plus tard" |
| Logs : politique de retention (30-90 jours) | Logs indefinis dans CloudWatch |

---

## Commandes par Use Case

### Nouveau projet

```bash
1. /ops:ops-env                # Variables d'environnement
2. /ops:ops-docker             # Conteneurisation
3. /ops:ops-ci                 # Pipeline CI/CD
4. /ops:ops-monitoring         # Observabilite
```

### Mise en production

```bash
1. /ops:ops-k8s                # Deploiement K8s
2. /ops:ops-health             # Health checks
3. /ops:ops-backup             # Strategie backup
4. /ops:ops-disaster-recovery  # Plan de reprise
5. /ops:ops-release            # Release
```

### Incident en production

```bash
1. /ops:ops-monitoring         # Diagnostiquer (metriques, logs)
2. /ops:ops-hotfix             # Corriger
3. /ops:ops-rollback           # Rollback si necessaire
```

### Audit securite infrastructure

```bash
1. /ops:ops-secrets-management # Verifier gestion secrets
2. /qa:qa-security             # Audit applicatif
3. /ops:ops-infra-code         # Audit IaC (trivy, checkov)
```

---

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Dockerise l'app" | ops-docker | Dockerfile multi-stage + compose |
| "Configure le CI" | ops-ci | Pipeline GitHub Actions complet |
| "Deploie sur K8s" | ops-k8s | Manifests + Helm |
| "Ajoute du monitoring" | ops-monitoring | Prometheus + Grafana + alertes |
| "Infrastructure as Code" | ops-infra-code | Modules Terraform, audit, securite |
| "Optimise les couts" | ops-cost | Analyse couts, right-sizing |

---

## Anti-patterns a Eviter

| Anti-pattern | Solution |
|-------------|---------|
| Secrets en dur dans le code ou les images | `/ops:ops-secrets-management` |
| Pas de health checks | `/ops:ops-health` |
| Deploy sans rollback possible | `/ops:ops-rollback` |
| Monitoring ajoute apres coup | Configurer des le debut avec `/ops:ops-monitoring` |
| Images Docker trop lourdes (`latest`, non-Alpine) | Multi-stage builds + Alpine |
| Pas de backup teste | Strategie 3-2-1 + test de restore mensuel |
| Infrastructure manuelle (ClickOps) | Tout en IaC avec `/ops:ops-infra-code` |
| Un seul environnement (pas de staging) | Overlay Kustomize ou workspace Terraform |
| Logs non structures | JSON avec `level`, `service`, `trace_id` |
| Pas de budget alerts | Alertes cloud configures avant le premier deploy |

## Ressources

- [Terraform Best Practices](https://terraform-best-practices.com)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Google SRE Book](https://sre.google/sre-book/table-of-contents/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/naming/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
