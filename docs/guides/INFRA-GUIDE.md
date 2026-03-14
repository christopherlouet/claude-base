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

## Phase 1: Setup Environnement

| Commande | Description |
|----------|-------------|
| `/ops:ops-env` | Gestion variables d'environnement |
| `/ops:ops-deps` | Audit et mise a jour des dependances |
| `/ops:ops-secrets-management` | Gestion securisee des secrets (Vault, SOPS) |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform/Pulumi) |

## Phase 2: Conteneurisation et Deploy

| Commande | Description |
|----------|-------------|
| `/ops:ops-docker` | Dockerfile multi-stage, compose, optimisation |
| `/ops:ops-k8s` | Deploiement Kubernetes (manifests, Helm) |
| `/ops:ops-ci` | Pipeline CI/CD (build, test, deploy) |
| `/ops:ops-vercel` | Deploiement serverless Vercel |
| `/ops:ops-serverless` | Architecture serverless (Lambda, Cloud Functions) |
| `/ops:ops-vps` | Configuration et deploiement VPS |

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

## Phase 4: Monitoring et Maintenance

| Commande | Description |
|----------|-------------|
| `/ops:ops-monitoring` | Metriques, alertes, logs |
| `/ops:ops-observability-stack` | Stack observabilite complete (traces, metriques, logs) |
| `/ops:ops-grafana-dashboard` | Creer dashboards Grafana |
| `/ops:ops-health` | Health checks et readiness probes |
| `/ops:ops-load-testing` | Tests de charge (k6, Artillery) |
| `/ops:ops-cost-optimization` | Optimisation des couts cloud |

## Phase 5: Resilience et Migration

| Commande | Description |
|----------|-------------|
| `/ops:ops-database` | Operations base de donnees (migrations, backups) |
| `/ops:ops-backup` | Strategie de backup (3-2-1) |
| `/ops:ops-disaster-recovery` | Plan de reprise d'activite (RTO/RPO) |
| `/ops:ops-migrate` | Migration d'infrastructure ou de donnees |

## Phase 6: Homelab et Reseau

| Commande | Description |
|----------|-------------|
| `/ops:ops-proxmox` | Gestion hyperviseur Proxmox (VMs, LXC) |
| `/ops:ops-opnsense` | Configuration firewall OPNsense |

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
1. /ops:ops-monitoring         # Diagnostiquer
2. /ops:ops-hotfix             # Corriger
3. /ops:ops-rollback           # Rollback si necessaire
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Dockerise l'app" | ops-docker | Dockerfile + compose |
| "Configure le CI" | ops-ci | Pipeline GitHub Actions |
| "Deploie sur K8s" | ops-k8s | Manifests + Helm |
| "Ajoute du monitoring" | ops-monitoring | Prometheus + Grafana |

## Anti-patterns a Eviter

- Secrets en dur dans le code → `/ops:ops-secrets-management`
- Pas de health checks → `/ops:ops-health`
- Deploy sans rollback possible → `/ops:ops-rollback`
- Monitoring ajoute apres coup → Configurer des le debut
- Images Docker trop lourdes → Multi-stage builds
- Pas de backup → Strategie 3-2-1 obligatoire
- Infrastructure manuelle → Tout en IaC
