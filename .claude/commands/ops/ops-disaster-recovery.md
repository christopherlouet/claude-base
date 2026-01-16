# Agent OPS-DISASTER-RECOVERY

Mettre en place une stratégie de reprise après sinistre (Disaster Recovery).

## Contexte
$ARGUMENTS

## Objectif

Définir et implémenter un plan de DR qui garantit la continuité d'activité
en cas de sinistre majeur (panne datacenter, cyberattaque, catastrophe naturelle).

## Concepts clés

```
┌─────────────────────────────────────────────────────────────┐
│                    MÉTRIQUES DR                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  RPO (Recovery Point Objective)                             │
│  ═══════════════════════════════                            │
│  Quantité de données qu'on accepte de perdre                │
│  → Détermine la fréquence des sauvegardes                   │
│                                                             │
│  RTO (Recovery Time Objective)                              │
│  ═══════════════════════════════                            │
│  Temps acceptable pour restaurer le service                 │
│  → Détermine l'architecture de DR                           │
│                                                             │
│  ────────────────────────────────────────────────────────   │
│  Dernière     │◄── RPO ──►│ Sinistre │◄── RTO ──►│ Reprise │
│  sauvegarde   │  (perte)   │          │  (downtime)│         │
│  ────────────────────────────────────────────────────────   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Stratégies de DR

### Comparatif des approches

| Stratégie | RTO | RPO | Coût | Complexité |
|-----------|-----|-----|------|------------|
| **Backup & Restore** | Heures/Jours | Heures | $ | Faible |
| **Pilot Light** | Minutes/Heures | Minutes | $$ | Moyenne |
| **Warm Standby** | Minutes | Secondes | $$$ | Haute |
| **Hot Standby (Active-Active)** | Secondes | ~0 | $$$$ | Très haute |

### Choix selon criticité

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Criticité    │ Stratégie          │ RTO/RPO typiques      │
│  ═════════════│════════════════════│═══════════════════════│
│  Mission      │ Hot Standby        │ RTO < 1min            │
│  Critical     │ (Active-Active)    │ RPO ~ 0               │
│               │                    │                       │
│  Business     │ Warm Standby       │ RTO < 30min           │
│  Critical     │                    │ RPO < 5min            │
│               │                    │                       │
│  Important    │ Pilot Light        │ RTO < 4h              │
│               │                    │ RPO < 1h              │
│               │                    │                       │
│  Standard     │ Backup & Restore   │ RTO < 24h             │
│               │                    │ RPO < 24h             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Implémentation par stratégie

### 1. Backup & Restore

```yaml
# Configuration de backup automatisé
backup_config:
  databases:
    - name: production-db
      schedule: "0 */6 * * *"  # Toutes les 6h
      retention: 30  # jours
      destination: s3://backups-dr/databases/
      encryption: AES-256

  storage:
    - name: user-uploads
      schedule: "0 2 * * *"  # Quotidien à 2h
      retention: 90
      destination: s3://backups-dr/uploads/

  configs:
    - name: application-configs
      schedule: "0 * * * *"  # Horaire
      retention: 7
      destination: s3://backups-dr/configs/
```

#### Script de backup PostgreSQL

```bash
#!/bin/bash
# backup-postgres.sh
set -euo pipefail

DB_NAME="production"
BACKUP_DIR="s3://backups-dr/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${DB_NAME}_${DATE}.sql.gz"

# Backup avec compression
pg_dump $DB_NAME | gzip > /tmp/$BACKUP_FILE

# Upload vers S3
aws s3 cp /tmp/$BACKUP_FILE $BACKUP_DIR/$BACKUP_FILE \
  --storage-class STANDARD_IA

# Cleanup local
rm /tmp/$BACKUP_FILE

# Vérification
aws s3 ls $BACKUP_DIR/$BACKUP_FILE
echo "Backup completed: $BACKUP_FILE"
```

### 2. Pilot Light

```yaml
# Infrastructure minimale en DR
# terraform/dr-pilot-light/main.tf

# Base de données répliquée (read replica cross-region)
resource "aws_db_instance" "dr_replica" {
  replicate_source_db = aws_db_instance.primary.arn
  instance_class      = "db.t3.medium"  # Taille minimale

  # Pas de multi-AZ pour économiser
  multi_az = false
}

# AMIs pré-configurées (pas d'instances running)
resource "aws_ami_copy" "app_dr" {
  name              = "app-ami-dr"
  source_ami_id     = data.aws_ami.app_latest.id
  source_ami_region = "eu-west-1"
}

# Launch template prêt
resource "aws_launch_template" "app_dr" {
  name          = "app-dr-template"
  image_id      = aws_ami_copy.app_dr.id
  instance_type = "t3.large"
}
```

### 3. Warm Standby

```yaml
# Infrastructure scaled-down mais running
# terraform/dr-warm-standby/main.tf

# Auto Scaling Group minimal
resource "aws_autoscaling_group" "app_dr" {
  name                = "app-dr-asg"
  min_size            = 1  # Minimum d'instances
  max_size            = 10
  desired_capacity    = 1  # Scaled down

  launch_template {
    id      = aws_launch_template.app_dr.id
    version = "$Latest"
  }
}

# Base de données synchronisée
resource "aws_db_instance" "dr_standby" {
  replicate_source_db = aws_db_instance.primary.arn
  instance_class      = "db.r5.large"  # Prêt pour la prod
  multi_az            = true
}
```

### 4. Hot Standby (Active-Active)

```yaml
# Multi-region active-active
# terraform/dr-hot-standby/main.tf

# Global Accelerator pour routing
resource "aws_globalaccelerator_accelerator" "main" {
  name            = "app-global"
  ip_address_type = "IPV4"
  enabled         = true
}

# Endpoints dans les deux régions
resource "aws_globalaccelerator_endpoint_group" "primary" {
  listener_arn = aws_globalaccelerator_listener.main.id
  endpoint_configuration {
    endpoint_id = aws_lb.primary.arn
    weight      = 50
  }
}

resource "aws_globalaccelerator_endpoint_group" "dr" {
  listener_arn = aws_globalaccelerator_listener.main.id
  endpoint_configuration {
    endpoint_id = aws_lb.dr.arn
    weight      = 50
  }
}

# DynamoDB Global Tables
resource "aws_dynamodb_table" "main" {
  name             = "app-data"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica {
    region_name = "eu-west-3"  # DR region
  }
}
```

## Plan de DR documenté

### Template de runbook

```markdown
# Disaster Recovery Runbook

## Informations générales
- **Application**: [Nom]
- **Criticité**: [Mission Critical / Business Critical / Important / Standard]
- **RTO cible**: [X heures/minutes]
- **RPO cible**: [X heures/minutes]

## Contacts d'urgence

| Rôle | Nom | Téléphone | Email |
|------|-----|-----------|-------|
| DR Lead | ... | ... | ... |
| DBA | ... | ... | ... |
| DevOps | ... | ... | ... |
| Management | ... | ... | ... |

## Procédure de failover

### Étape 1: Évaluation (15 min max)
- [ ] Confirmer l'indisponibilité de la région primaire
- [ ] Évaluer l'impact (données, services affectés)
- [ ] Décision GO/NO-GO pour le failover

### Étape 2: Activation DR (variable selon stratégie)
```bash
# Commande de failover
./scripts/activate-dr.sh --region eu-west-3 --confirm
```

### Étape 3: Validation
- [ ] Services accessibles
- [ ] Données cohérentes
- [ ] Monitoring actif

### Étape 4: Communication
- [ ] Équipes internes notifiées
- [ ] Clients notifiés (si applicable)
- [ ] Status page mise à jour

## Procédure de failback

### Prérequis
- [ ] Région primaire restaurée
- [ ] Données synchronisées
- [ ] Tests de validation passés

### Étapes
1. Activer la réplication inverse
2. Vérifier la synchronisation complète
3. Basculer le trafic progressivement
4. Désactiver le mode DR
```

## Tests de DR

### Types de tests

| Type | Fréquence | Impact |
|------|-----------|--------|
| **Tabletop** | Trimestriel | Aucun |
| **Walkthrough** | Trimestriel | Aucun |
| **Simulation** | Semestriel | Faible |
| **Failover complet** | Annuel | Moyen |

### Script de test de failover

```bash
#!/bin/bash
# test-dr-failover.sh
set -euo pipefail

echo "=== DR Failover Test ==="
echo "Date: $(date)"
echo "Region cible: eu-west-3"

# 1. Vérifier l'état de la réplication
echo "Checking replication status..."
./scripts/check-replication.sh

# 2. Créer un snapshot avant le test
echo "Creating pre-test snapshot..."
./scripts/create-snapshot.sh --tag "dr-test-$(date +%Y%m%d)"

# 3. Simuler le failover (sans couper le primaire)
echo "Initiating failover simulation..."
./scripts/activate-dr.sh --region eu-west-3 --simulation

# 4. Tests de validation
echo "Running validation tests..."
./scripts/validate-dr.sh

# 5. Rapport
echo "Generating report..."
./scripts/generate-dr-report.sh

echo "=== Test completed ==="
```

### Checklist de test DR

```markdown
## DR Test Checklist

### Préparation
- [ ] Fenêtre de maintenance planifiée
- [ ] Équipes notifiées
- [ ] Rollback plan prêt
- [ ] Monitoring renforcé

### Pendant le test
- [ ] RPO mesuré (données perdues)
- [ ] RTO mesuré (temps de reprise)
- [ ] Toutes les fonctionnalités testées
- [ ] Performance acceptable

### Après le test
- [ ] Failback effectué
- [ ] Données vérifiées
- [ ] Rapport généré
- [ ] Améliorations identifiées
```

## Monitoring DR

### Métriques essentielles

```yaml
# Alertes DR (exemple Prometheus)
groups:
  - name: disaster-recovery
    rules:
      - alert: ReplicationLagHigh
        expr: mysql_slave_lag_seconds > 300
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Database replication lag > 5 minutes"

      - alert: BackupFailed
        expr: backup_last_success_timestamp < (time() - 86400)
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "No successful backup in 24 hours"

      - alert: DRSiteUnhealthy
        expr: probe_success{job="dr-site"} == 0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "DR site health check failing"
```

## Checklist DR complète

### Infrastructure
- [ ] Backups automatisés et testés
- [ ] Réplication cross-region configurée
- [ ] Infrastructure DR provisionnée
- [ ] DNS/Load balancing prêt pour failover

### Documentation
- [ ] Runbook DR documenté
- [ ] Contacts d'urgence à jour
- [ ] Procédures testées et validées
- [ ] Diagrammes d'architecture DR

### Tests
- [ ] Tests de restauration réguliers
- [ ] Tests de failover planifiés
- [ ] RTO/RPO mesurés et validés
- [ ] Améliorations documentées

### Gouvernance
- [ ] SLA DR définis
- [ ] Budget DR approuvé
- [ ] Formation équipes effectuée
- [ ] Révision annuelle planifiée

## Agents liés

| Agent | Usage |
|-------|-------|
| `/ops-monitoring` | Monitoring du DR |
| `/ops-cost-optimization` | Optimiser les coûts DR |
| `/security` | Sécurité des backups |

---

IMPORTANT: Tester les backups régulièrement - un backup non testé n'est pas un backup.

YOU MUST documenter les procédures de DR de façon claire et accessible.

YOU MUST mesurer RTO et RPO réels lors des tests.

NEVER supposer que le DR fonctionne sans le tester.

Think hard sur les scénarios de sinistre les plus probables pour votre contexte.
