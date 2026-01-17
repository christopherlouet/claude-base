# Agent GITFLOW-HOTFIX

Gérer les hotfixes urgents avec GitFlow.

## Contexte
$ARGUMENTS

## Objectif

Corriger rapidement un bug critique en production avec merge bidirectionnel (main + develop).

## Workflow Hotfix

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   main (v1.0.0) ────────────────────────────────────────────▶   │
│       │                                      ▲                  │
│       │ checkout -b                          │ merge + tag      │
│       ▼                                      │ (v1.0.1)         │
│   hotfix/xxx ────────────────────────────────┤                  │
│       │                                      │                  │
│       ├── fix bug                            │                  │
│       └── bump patch version                 │                  │
│                                              │                  │
│   develop ◀──────────────────────────────────┘ merge            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Actions disponibles

### START - Créer un hotfix

**Syntaxe**: `/ops-gitflow-hotfix start "nom-du-hotfix"`

```bash
# 1. Partir de main (production)
git checkout main
git pull origin main

# 2. Créer la branche hotfix
git checkout -b hotfix/nom-du-hotfix

# 3. Pousser la branche
git push -u origin hotfix/nom-du-hotfix
```

**Output attendu**:
```markdown
## Hotfix créé

**Branche**: `hotfix/nom-du-hotfix`
**Base**: `main` (production)
**Urgence**: HAUTE

### Checklist rapide
- [ ] Identifier la cause root du bug
- [ ] Corriger le bug (commit minimal)
- [ ] Bump version PATCH (ex: 1.0.0 → 1.0.1)
- [ ] Tester la correction
- [ ] Finish le hotfix

### Règles du hotfix
- UNIQUEMENT le fix du bug, rien d'autre
- Commits minimaux et ciblés
- Tests obligatoires avant merge
- Ne pas attendre - c'est urgent

### Commandes
- `/dev-debug` - Investiguer le bug
- `/ops-gitflow-hotfix finish "nom-du-hotfix"` - Terminer
```

### FINISH - Terminer un hotfix

**Syntaxe**: `/ops-gitflow-hotfix finish "nom-du-hotfix" "vX.X.X"`

La version est optionnelle. Si non fournie, le patch version sera incrémenté automatiquement.

```bash
# 1. S'assurer que tout est commité
git status --porcelain

# 2. Merger dans main
git checkout main
git pull origin main
git merge --no-ff hotfix/nom-du-hotfix -m "Hotfix: nom-du-hotfix"

# 3. Créer le tag (version patch)
git tag -a vX.X.X -m "Hotfix vX.X.X: nom-du-hotfix"

# 4. Pousser main et le tag
git push origin main
git push origin vX.X.X

# 5. Merger dans develop (CRITIQUE!)
git checkout develop
git pull origin develop
git merge --no-ff hotfix/nom-du-hotfix -m "Merge hotfix/nom-du-hotfix into develop"
git push origin develop

# 6. Si une release est en cours, merger aussi dans release/*
RELEASE_BRANCH=$(git branch -a | grep "release/" | head -1 | tr -d ' ')
if [ -n "$RELEASE_BRANCH" ]; then
  git checkout "$RELEASE_BRANCH"
  git merge --no-ff hotfix/nom-du-hotfix -m "Merge hotfix into release"
  git push
fi

# 7. Supprimer la branche hotfix
git branch -d hotfix/nom-du-hotfix
git push origin --delete hotfix/nom-du-hotfix
```

**Output attendu**:
```markdown
## Hotfix terminé

**Hotfix**: nom-du-hotfix
**Version**: vX.X.X
**Tag**: vX.X.X

### Actions effectuées
- [x] Merge dans main
- [x] Tag vX.X.X créé
- [x] Merge dans develop
- [x] Merge dans release/* (si existante)
- [x] Branche hotfix supprimée

### Déploiement URGENT
Le hotfix est prêt pour déploiement immédiat en production.

```bash
# Déployer maintenant
./deploy.sh production
```

### Post-mortem recommandé
- Documenter l'incident
- Identifier comment éviter ce bug à l'avenir
- Ajouter des tests de régression
```

### LIST - Lister les hotfixes en cours

**Syntaxe**: `/ops-gitflow-hotfix list`

```bash
git branch -a | grep hotfix/
```

## Détection de l'action

| Pattern | Action |
|---------|--------|
| `start "xxx"` | Créer hotfix/xxx depuis main |
| `finish "xxx"` | Terminer hotfix/xxx |
| `finish "xxx" "v1.0.1"` | Terminer avec version spécifique |
| `list` | Lister les hotfixes |

## Différence Hotfix vs Bugfix

| Aspect | Hotfix | Bugfix (feature) |
|--------|--------|------------------|
| **Urgence** | Critique, immédiat | Normal, planifié |
| **Base** | main (production) | develop |
| **Destination** | main + develop | develop |
| **Version** | Patch (x.x.+1) | Minor (x.+1.0) |
| **Review** | Optionnelle (urgence) | Obligatoire |

## Checklist avant finish

### Obligatoire
- [ ] Bug corrigé et testé
- [ ] Version PATCH bump
- [ ] Pas d'autres modifications que le fix
- [ ] Tests de non-régression

### Recommandé
- [ ] Test en staging si possible
- [ ] Notification de l'équipe
- [ ] Documentation de l'incident

## Cas spécial : Release en cours

Si une branche `release/*` existe pendant le hotfix :

```
main ◀─────── hotfix ───────▶ develop
                  │
                  └──────────▶ release/* (si existe)
```

Le hotfix doit être mergé dans les 3 branches pour éviter les régressions.

## Gestion des conflits

Les conflits sont rares sur les hotfixes (commits minimaux), mais si :

```bash
# Résoudre manuellement
git add .
git commit -m "Resolve conflicts"
# Continuer le merge
```

## Commandes liées

| Urgence | Commande | Usage |
|---------|----------|-------|
| HAUTE | **HOTFIX** | Bug critique production |
| Normale | `/ops-hotfix` | Correction urgente (simplifié) |
| Basse | `/work-flow-bugfix` | Bug non critique |

---

IMPORTANT: Un hotfix part TOUJOURS de main, jamais de develop.

YOU MUST merger dans main ET develop (et release/* si existe).

YOU MUST créer un tag avec version PATCH.

NEVER inclure autre chose que le fix du bug.

NEVER retarder un hotfix - la production est impactée.
