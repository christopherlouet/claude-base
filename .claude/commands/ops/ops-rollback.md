# Agent ROLLBACK

Procedure de rollback securisee pour revenir a une version stable.

## Contexte du Rollback
$ARGUMENTS

## Classification du Rollback

| Type | Description | Temps | Risque |
|------|-------------|-------|--------|
| **Urgent** | Production cassee, utilisateurs impactes | < 15 min | Eleve |
| **Planifie** | Regression detectee, impact limite | < 1h | Moyen |
| **Preventif** | Metriques anormales, pas d'impact visible | < 4h | Faible |

## Strategies de Rollback

### 1. Rollback Git (Code)

```bash
# Identifier la version stable
git log --oneline -10

# Option A: Revert du dernier commit
git revert HEAD --no-edit

# Option B: Reset vers un commit specifique (si branche non partagee)
git reset --hard <commit-hash>

# Option C: Revert d'un merge
git revert -m 1 <merge-commit-hash>
```

### 2. Rollback Deploiement

#### Vercel

```bash
# Lister les deployments
vercel list

# Rollback vers deployment precedent
vercel rollback [deployment-url]

# Ou via alias
vercel alias [old-deployment] [production-domain]
```

#### Kubernetes

```bash
# Voir l'historique
kubectl rollout history deployment/[app-name]

# Rollback vers revision precedente
kubectl rollout undo deployment/[app-name]

# Rollback vers revision specifique
kubectl rollout undo deployment/[app-name] --to-revision=2

# Verifier le statut
kubectl rollout status deployment/[app-name]
```

#### Docker/Docker Compose

```bash
# Identifier l'image precedente
docker images | grep [app-name]

# Mettre a jour le tag dans docker-compose.yml
# image: app:v1.2.3 → image: app:v1.2.2

# Redemarrer
docker-compose up -d
```

#### AWS ECS

```bash
# Lister les task definitions
aws ecs list-task-definitions --family-prefix [family]

# Mettre a jour le service avec l'ancienne version
aws ecs update-service \
  --cluster [cluster] \
  --service [service] \
  --task-definition [family:revision]
```

### 3. Rollback Base de Donnees

```bash
# Identifier la migration a annuler
npm run migrate:status

# Rollback de la derniere migration
npm run migrate:down

# Ou avec Prisma
npx prisma migrate resolve --rolled-back [migration-name]
```

## Procedure de Rollback

### Phase 1: Evaluation (< 2 min)

- [ ] Identifier le probleme
- [ ] Confirmer que le rollback est la solution
- [ ] Identifier la version cible
- [ ] Verifier que la version cible etait stable

### Phase 2: Communication (< 1 min)

```markdown
🔄 ROLLBACK EN COURS - [Service]
Statut: Preparation du rollback
Raison: [Description courte]
Impact: [Utilisateurs affectes]
ETA: [X minutes]
```

### Phase 3: Execution (< 5 min)

```bash
# 1. Creer un point de sauvegarde
git tag rollback-checkpoint-$(date +%Y%m%d-%H%M%S)

# 2. Executer le rollback
[commande selon la strategie]

# 3. Verifier le deploiement
curl -s https://[url]/health | jq .

# 4. Valider les metriques
[verifier dashboards]
```

### Phase 4: Verification (< 5 min)

| Check | Commande | Attendu |
|-------|----------|---------|
| Health | `curl /health` | 200 OK |
| Logs | `kubectl logs -f` | Pas d'erreurs |
| Metriques | Dashboard | Normal |
| Smoke test | Test manuel | Fonctionnel |

### Phase 5: Communication Post-Rollback

```markdown
✅ ROLLBACK TERMINE - [Service]
Duree: [X minutes]
Version actuelle: [v1.2.2]
Services affectes: [Liste]
Prochaines etapes: [Investigation]
```

## Checklist Pre-Rollback

- [ ] Backup des donnees si necessaire
- [ ] Communication equipe
- [ ] Acces aux credentials de deploiement
- [ ] Monitoring pret
- [ ] Plan de communication externe (si impact utilisateur)

## Checklist Post-Rollback

- [ ] Service stable
- [ ] Metriques normales
- [ ] Communication envoyee
- [ ] Incident documente
- [ ] Post-mortem planifie
- [ ] Issue creee pour la correction

## Eviter les Erreurs Courantes

| Erreur | Solution |
|--------|----------|
| Rollback sur mauvaise branche | Verifier `git branch` avant |
| Oublier les migrations DB | Toujours verifier le schema |
| Pas de verification post-rollback | Smoke test obligatoire |
| Communication tardive | Informer AVANT de commencer |

## Quand NE PAS Rollback

- Le probleme est dans les donnees, pas le code
- La version precedente a aussi le bug
- Le rollback causerait une perte de donnees
- Un fix forward est plus rapide et sur

## Template Post-Mortem

```markdown
## Incident: [Titre]
**Date**: [YYYY-MM-DD HH:MM UTC]
**Duree**: [X minutes/heures]
**Impact**: [Description]

### Timeline
- HH:MM - [Evenement]
- HH:MM - [Evenement]

### Cause racine
[Description]

### Actions
- [ ] Fix definitif
- [ ] Amelioration monitoring
- [ ] Mise a jour runbook

### Lecons apprises
[Ce qu'on a appris]
```

## Agents Lies

| Agent | Usage |
|-------|-------|
| `/ops-hotfix` | Correction rapide apres rollback |
| `/ops-monitoring` | Verifier les metriques |
| `/ops-health` | Health check rapide |
| `/dev-debug` | Investigation post-incident |

---

IMPORTANT: Un rollback reussi est un rollback RAPIDE. Ne pas hesiter a rollback d'abord, investiguer ensuite.

IMPORTANT: Toujours documenter les rollbacks pour ameliorer les processus.

YOU MUST verifier que le service est stable apres rollback.

NEVER rollback sans avoir un plan de verification.
