# Agent OPS-COST-OPTIMIZATION

Analyser et optimiser les coûts d'infrastructure cloud.

## Contexte
$ARGUMENTS

## Objectif

Identifier les opportunités de réduction des coûts cloud sans impacter
les performances ni la disponibilité.

## Framework d'analyse des coûts

```
┌─────────────────────────────────────────────────────────────┐
│                    COST OPTIMIZATION                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. VISIBILITY    → Comprendre où va l'argent              │
│  ═══════════                                                │
│                                                             │
│  2. RIGHT-SIZING  → Ajuster les ressources                 │
│  ══════════════                                             │
│                                                             │
│  3. SCHEDULING    → Éteindre quand non utilisé             │
│  ═══════════                                                │
│                                                             │
│  4. COMMITMENT    → Reserved/Spot instances                │
│  ════════════                                               │
│                                                             │
│  5. ARCHITECTURE  → Optimiser le design                    │
│  ══════════════                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Visibilité des coûts

### Outils par provider

| Provider | Outil natif | Alternatives |
|----------|-------------|--------------|
| **AWS** | Cost Explorer, Budgets | Kubecost, Infracost |
| **GCP** | Billing Reports | CloudHealth |
| **Azure** | Cost Management | Spot.io |
| **Multi-cloud** | - | Finops.org tools |

### Tags essentiels

```yaml
# Tagging standard pour tracking des coûts
required_tags:
  - Environment: [prod, staging, dev, test]
  - Project: [project-name]
  - Team: [team-name]
  - Owner: [email]
  - CostCenter: [budget-code]

optional_tags:
  - Application: [app-name]
  - ExpirationDate: [YYYY-MM-DD]  # Pour ressources temporaires
```

### Script d'audit des tags (AWS)

```bash
#!/bin/bash
# Trouver les ressources sans tags requis
aws resourcegroupstaggingapi get-resources \
  --tags-per-page 100 \
  --output json | jq '.ResourceTagMappingList[] |
    select(.Tags | map(.Key) |
    contains(["Environment", "Project", "Team"]) | not)'
```

## Étape 2 : Right-sizing

### Analyse de l'utilisation

| Métrique | Seuil sous-utilisé | Action |
|----------|-------------------|--------|
| CPU moyen | < 20% | Réduire la taille |
| CPU max | < 50% | Réduire la taille |
| Mémoire | < 40% | Réduire la taille |
| Disque | < 30% utilisé | Réduire le volume |
| Network | < 10% capacité | Revoir le sizing |

### Recommandations AWS

```bash
# Obtenir les recommandations de right-sizing
aws compute-optimizer get-ec2-instance-recommendations \
  --filters name=Finding,values=OVER_PROVISIONED

# Analyser les instances sous-utilisées
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time $(date -d '7 days ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 3600 \
  --statistics Average Maximum
```

### Matrice de sizing

```
┌─────────────────────────────────────────────────────────────┐
│  Usage Pattern        │  Recommandation                     │
├───────────────────────┼─────────────────────────────────────┤
│  Constant & prévisible│  Reserved Instances (1-3 ans)      │
│  Variable & prévisible│  Savings Plans + On-demand          │
│  Sporadic             │  Spot Instances + On-demand         │
│  Dev/Test             │  Spot + Auto-stop scheduling        │
│  Batch processing     │  Spot Fleet                         │
└─────────────────────────────────────────────────────────────┘
```

## Étape 3 : Scheduling

### Auto-stop des environnements non-prod

```yaml
# Exemple avec AWS Instance Scheduler
schedules:
  office-hours:
    timezone: Europe/Paris
    periods:
      - begintime: "08:00"
        endtime: "20:00"
        weekdays: "mon-fri"

  dev-environment:
    timezone: Europe/Paris
    periods:
      - begintime: "09:00"
        endtime: "19:00"
        weekdays: "mon-fri"
```

### Script de scheduling simple

```bash
#!/bin/bash
# stop-dev-instances.sh (à exécuter via cron)
ENVIRONMENT="dev"

# Arrêter les instances dev
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=$ENVIRONMENT" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text | xargs -r aws ec2 stop-instances --instance-ids

# Économie estimée
echo "Économie: ~70% sur environnements dev (16h/jour arrêtés)"
```

### Kubernetes scaling

```yaml
# Scaled Object pour KEDA
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: api-scaler
spec:
  scaleTargetRef:
    name: api-deployment
  minReplicaCount: 1    # Minimum pendant heures creuses
  maxReplicaCount: 10   # Maximum pendant pic
  triggers:
    - type: cron
      metadata:
        timezone: Europe/Paris
        start: 0 8 * * 1-5   # Scale up à 8h
        end: 0 20 * * 1-5    # Scale down à 20h
        desiredReplicas: "5"
```

## Étape 4 : Engagements (Reserved/Savings)

### Comparatif des options

| Option | Économie | Flexibilité | Engagement |
|--------|----------|-------------|------------|
| On-Demand | 0% | Maximum | Aucun |
| Spot | 60-90% | Faible | Aucun |
| Reserved (1 an) | 30-40% | Faible | 1 an |
| Reserved (3 ans) | 50-60% | Très faible | 3 ans |
| Savings Plans | 30-50% | Moyenne | 1-3 ans |

### Stratégie recommandée

```
┌─────────────────────────────────────────────────────────────┐
│                    COVERAGE STRATEGY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ████████████████████████░░░░░░░░░░░░░░░░  Reserved/SP     │
│  ░░░░░░░░░░░░░░░░░░░░░░░░████████░░░░░░░░  Spot            │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████  On-Demand       │
│                                                             │
│  Baseline (60-70%) → Reserved/Savings Plans                 │
│  Variable (20-30%) → Spot instances                         │
│  Pics (10%)        → On-Demand                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 5 : Optimisation architecturale

### Quick wins

| Action | Économie potentielle |
|--------|---------------------|
| Supprimer ressources orphelines | 5-15% |
| Compresser les logs S3 | 20-40% stockage |
| Utiliser CDN pour assets statiques | 30-50% bandwidth |
| Migrer vers ARM (Graviton) | 20-40% compute |
| Utiliser Spot pour workers | 60-90% compute |

### Ressources orphelines à vérifier

```bash
# Volumes EBS non attachés
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query 'Volumes[*].[VolumeId,Size,CreateTime]'

# Elastic IPs non utilisées
aws ec2 describe-addresses \
  --query 'Addresses[?AssociationId==null].[PublicIp,AllocationId]'

# Snapshots anciens
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<`2023-01-01`].[SnapshotId,VolumeSize,StartTime]'

# Load Balancers sans targets
aws elbv2 describe-target-groups \
  --query 'TargetGroups[?length(TargetHealthDescriptions)==`0`].TargetGroupArn'
```

### Optimisation stockage

```yaml
# Lifecycle policy S3
lifecycle_rules:
  - id: "archive-old-logs"
    prefix: "logs/"
    transitions:
      - days: 30
        storage_class: STANDARD_IA
      - days: 90
        storage_class: GLACIER
      - days: 365
        storage_class: DEEP_ARCHIVE
    expiration:
      days: 730  # Supprimer après 2 ans
```

## Rapport d'optimisation

### Template de rapport

```markdown
# Cost Optimization Report

## Executive Summary
- **Dépense mensuelle actuelle**: $X,XXX
- **Économies identifiées**: $X,XXX (XX%)
- **Effort requis**: [Faible/Moyen/Élevé]

## Quick Wins (< 1 semaine)

| Action | Économie/mois | Effort |
|--------|---------------|--------|
| Supprimer 5 EBS orphelins | $150 | 1h |
| Arrêter instances dev la nuit | $800 | 4h |
| Compresser logs S3 | $100 | 2h |

## Optimisations moyen terme (1-4 semaines)

| Action | Économie/mois | Effort |
|--------|---------------|--------|
| Right-size 10 instances | $500 | 2j |
| Acheter Reserved Instances | $1,200 | 1j |
| Migrer vers Graviton | $400 | 1 sem |

## Optimisations long terme (1-3 mois)

| Action | Économie/mois | Effort |
|--------|---------------|--------|
| Refactoring serverless | $2,000 | 1 mois |
| Multi-region optimization | $800 | 2 sem |

## Recommandations prioritaires

1. **Immédiat**: [Action #1]
2. **Cette semaine**: [Action #2]
3. **Ce mois**: [Action #3]
```

## Métriques à suivre

### Dashboard FinOps

| Métrique | Cible | Fréquence |
|----------|-------|-----------|
| Coût / requête | Baseline -10% | Hebdo |
| Reserved coverage | > 70% | Mensuel |
| Waste (ressources inutilisées) | < 5% | Hebdo |
| Tag compliance | > 95% | Quotidien |
| Cost variance vs budget | < 10% | Mensuel |

## Checklist

### Audit initial
- [ ] Tags en place sur toutes les ressources
- [ ] Dashboard de coûts configuré
- [ ] Alertes budget configurées
- [ ] Inventaire des ressources complet

### Optimisations
- [ ] Ressources orphelines supprimées
- [ ] Right-sizing effectué
- [ ] Scheduling configuré (non-prod)
- [ ] Reserved/Savings analysés

### Gouvernance
- [ ] Politique de tagging documentée
- [ ] Processus de review mensuel
- [ ] Ownership des coûts défini
- [ ] Formation équipes effectuée

## Agents liés

| Agent | Usage |
|-------|-------|
| `/ops-monitoring` | Métriques d'utilisation |
| `/ops-load-testing` | Valider le sizing |
| `/ops-disaster-recovery` | Coûts de DR |

---

IMPORTANT: Ne jamais optimiser au détriment de la disponibilité ou sécurité.

YOU MUST avoir des alertes budget AVANT d'optimiser.

NEVER supprimer des ressources sans vérifier leur utilisation réelle.

Think hard sur l'impact business avant de réduire les ressources.
