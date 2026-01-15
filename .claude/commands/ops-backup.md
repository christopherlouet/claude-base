# Agent OPS-BACKUP

Stratégie de backup et restore pour les données critiques.

## Contexte
$ARGUMENTS

## Processus d'analyse

### 1. Identifier les données à sauvegarder

| Catégorie | Données | Criticité | Fréquence |
|-----------|---------|-----------|-----------|
| Base de données | Tables principales | Critique | Quotidien |
| Fichiers utilisateurs | Uploads, avatars | Haute | Quotidien |
| Configuration | .env, secrets | Haute | À chaque changement |
| Logs | Application logs | Moyenne | Hebdomadaire |
| Code | Repository | Critique | Continue (Git) |

### 2. Stratégie de backup (3-2-1)

```
3 copies de vos données
├── 1× Production (live)
├── 1× Backup local/cloud
└── 1× Backup offsite

2 types de médias différents
├── 1× Stockage principal (SSD/HDD)
└── 1× Cloud storage (S3, GCS, etc.)

1 copie hors site
└── Géographiquement séparée (autre région/provider)
```

### 3. Types de backup

| Type | Description | Espace | Temps restore |
|------|-------------|--------|---------------|
| **Full** | Copie complète | Élevé | Rapide |
| **Incrémental** | Changements depuis dernier backup | Faible | Moyen |
| **Différentiel** | Changements depuis dernier full | Moyen | Moyen |
| **Snapshot** | Point-in-time | Variable | Très rapide |

### 4. Backup PostgreSQL

#### Script de backup
```bash
#!/bin/bash
# backup-postgres.sh

DB_NAME="myapp"
BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Créer le backup
pg_dump -Fc $DB_NAME > "$BACKUP_DIR/${DB_NAME}_${DATE}.dump"

# Compresser
gzip "$BACKUP_DIR/${DB_NAME}_${DATE}.dump"

# Upload vers S3
aws s3 cp "$BACKUP_DIR/${DB_NAME}_${DATE}.dump.gz" \
  "s3://my-backups/postgres/${DB_NAME}_${DATE}.dump.gz"

# Nettoyer les anciens backups locaux
find $BACKUP_DIR -name "*.dump.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: ${DB_NAME}_${DATE}.dump.gz"
```

#### Restore PostgreSQL
```bash
#!/bin/bash
# restore-postgres.sh

BACKUP_FILE=$1
DB_NAME="myapp"

# Télécharger depuis S3 si nécessaire
# aws s3 cp "s3://my-backups/postgres/$BACKUP_FILE" .

# Décompresser
gunzip -k "$BACKUP_FILE"

# Restore
pg_restore -d $DB_NAME --clean "${BACKUP_FILE%.gz}"
```

### 5. Backup MongoDB

```bash
#!/bin/bash
# backup-mongo.sh

DB_NAME="myapp"
BACKUP_DIR="/backups/mongo"
DATE=$(date +%Y%m%d_%H%M%S)

# Dump
mongodump --db $DB_NAME --out "$BACKUP_DIR/${DATE}"

# Compress
tar -czf "$BACKUP_DIR/${DB_NAME}_${DATE}.tar.gz" -C "$BACKUP_DIR" "${DATE}"
rm -rf "$BACKUP_DIR/${DATE}"

# Upload
aws s3 cp "$BACKUP_DIR/${DB_NAME}_${DATE}.tar.gz" \
  "s3://my-backups/mongo/"
```

### 6. Backup fichiers (S3 sync)

```bash
#!/bin/bash
# backup-files.sh

# Sync uploads vers S3
aws s3 sync /app/uploads s3://my-backups/uploads \
  --delete \
  --exclude "*.tmp"

# Sync avec versioning
aws s3api put-bucket-versioning \
  --bucket my-backups \
  --versioning-configuration Status=Enabled
```

### 7. Configuration cron

```bash
# /etc/cron.d/backups

# Backup DB quotidien à 2h du matin
0 2 * * * root /scripts/backup-postgres.sh >> /var/log/backup.log 2>&1

# Backup fichiers toutes les 6h
0 */6 * * * root /scripts/backup-files.sh >> /var/log/backup.log 2>&1

# Backup full hebdomadaire (dimanche 3h)
0 3 * * 0 root /scripts/backup-full.sh >> /var/log/backup.log 2>&1
```

### 8. Monitoring des backups

```yaml
# docker-compose.monitoring.yml
services:
  backup-monitor:
    image: prom/alertmanager
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml

# alertmanager.yml
groups:
  - name: backup-alerts
    rules:
      - alert: BackupFailed
        expr: backup_last_success_timestamp < (time() - 86400)
        labels:
          severity: critical
        annotations:
          summary: "Backup not completed in 24h"
```

### 9. Test de restore (CRUCIAL)

```bash
#!/bin/bash
# test-restore.sh - À exécuter régulièrement !

echo "=== Test de restore ==="

# 1. Récupérer le dernier backup
LATEST=$(aws s3 ls s3://my-backups/postgres/ | sort | tail -n 1 | awk '{print $4}')
aws s3 cp "s3://my-backups/postgres/$LATEST" /tmp/

# 2. Créer une DB de test
createdb myapp_restore_test

# 3. Restore
gunzip -c "/tmp/$LATEST" | pg_restore -d myapp_restore_test

# 4. Vérifier l'intégrité
psql -d myapp_restore_test -c "SELECT COUNT(*) FROM users;"

# 5. Nettoyer
dropdb myapp_restore_test
rm "/tmp/$LATEST"

echo "=== Restore test completed ==="
```

### 10. Solutions managées

| Provider | Service | Coût approx |
|----------|---------|-------------|
| AWS | RDS Automated Backups | Inclus |
| GCP | Cloud SQL Backups | Inclus |
| Vercel | Postgres (avec Neon) | Plan dépendant |
| PlanetScale | Automatic backups | Inclus |
| MongoDB Atlas | Continuous backup | Plan dépendant |

## Output attendu

### Stratégie recommandée

```
Type: [Full + Incremental]
Fréquence: [Quotidien + Hebdomadaire]
Rétention: [30 jours local, 90 jours cloud]
Stockage: [S3 + Glacier]
```

### Scripts générés

1. `scripts/backup-db.sh`
2. `scripts/backup-files.sh`
3. `scripts/restore-db.sh`
4. `scripts/test-restore.sh`

### Configuration cron
```
[Configuration cron recommandée]
```

### Documentation

```markdown
## Procédure de restore

### En cas d'incident
1. Identifier le backup à restaurer
2. Télécharger depuis S3
3. Exécuter le script de restore
4. Vérifier l'intégrité
5. Redémarrer les services

### Contact urgence
- DBA: [email]
- DevOps: [email]
```

### Checklist backup

- [ ] Backups automatisés
- [ ] Upload vers stockage distant
- [ ] Rétention configurée
- [ ] Chiffrement activé
- [ ] Tests de restore réguliers
- [ ] Monitoring/alerting
- [ ] Documentation à jour
- [ ] Procédure de restore testée

### Matrice de restore

| Scénario | RPO | RTO | Procédure |
|----------|-----|-----|-----------|
| Corruption data | 24h | 2h | Restore depuis backup quotidien |
| Suppression accidentelle | 1h | 30min | Restore depuis snapshot |
| Disaster (région down) | 24h | 4h | Restore depuis backup offsite |

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/disaster-recovery` | Plan de reprise complet |
| `/database` | Migrations et schéma DB |
| `/infra-code` | Infrastructure backup |
| `/monitoring` | Alertes sur backups |
| `/security` | Audit sécurité des backups |

---

IMPORTANT: Un backup non testé n'est pas un backup. Tester régulièrement les restores.

YOU MUST avoir au moins une copie des données hors site (autre région/provider).

NEVER oublier de chiffrer les backups contenant des données sensibles.

Think hard sur le RPO (Recovery Point Objective) et RTO (Recovery Time Objective) acceptables.
