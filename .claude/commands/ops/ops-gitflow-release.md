# Agent GITFLOW-RELEASE

Gérer les branches release avec GitFlow.

## Contexte
$ARGUMENTS

## Objectif

Créer, préparer et finaliser des releases selon le workflow GitFlow avec merge bidirectionnel (main + develop).

## Workflow Release

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   main ─────────────────────────────────────────────────────▶   │
│                                          ▲                      │
│                                          │ merge + tag          │
│                                          │                      │
│   develop ──────────────────────────────▶├─────────────────────▶│
│       │                                  │         ▲            │
│       │ checkout -b                      │         │ merge      │
│       ▼                                  │         │            │
│   release/vX.X.X ────────────────────────┴─────────┘            │
│       │                                                         │
│       ├── bump version                                          │
│       ├── update changelog                                      │
│       └── fix bugs mineurs                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Actions disponibles

### START - Créer une nouvelle release

**Syntaxe**: `/ops-gitflow-release start "vX.X.X"`

```bash
# 1. S'assurer d'être à jour sur develop
git checkout develop
git pull origin develop

# 2. Créer la branche release
git checkout -b release/vX.X.X

# 3. Pousser la branche
git push -u origin release/vX.X.X
```

**Tâches de préparation** :
1. Bump de version dans package.json / pubspec.yaml
2. Mise à jour du CHANGELOG.md
3. Tests de non-régression
4. Corrections de bugs mineurs uniquement

**Output attendu**:
```markdown
## Release créée

**Branche**: `release/vX.X.X`
**Base**: `develop`

### Checklist de préparation
- [ ] Bump version dans package.json / pubspec.yaml
- [ ] Mettre à jour CHANGELOG.md
- [ ] Vérifier que tous les tests passent
- [ ] Corriger les bugs mineurs si nécessaire
- [ ] Pas de nouvelles features (features = develop)

### Commandes utiles
- `/doc-changelog` - Générer le changelog
- `/qa-audit` - Audit qualité avant release
- `/ops-gitflow-release finish "vX.X.X"` - Terminer la release

### Règles importantes
- Seuls les bugfixes sont autorisés sur cette branche
- Toute nouvelle feature doit attendre la prochaine release
```

### FINISH - Terminer une release

**Syntaxe**: `/ops-gitflow-release finish "vX.X.X"`

```bash
# 1. S'assurer que tout est commité
git status --porcelain

# 2. Mettre à jour main et merger
git checkout main
git pull origin main
git merge --no-ff release/vX.X.X -m "Release vX.X.X"

# 3. Créer le tag
git tag -a vX.X.X -m "Release vX.X.X"

# 4. Pousser main et le tag
git push origin main
git push origin vX.X.X

# 5. Merger dans develop (important!)
git checkout develop
git pull origin develop
git merge --no-ff release/vX.X.X -m "Merge release/vX.X.X into develop"
git push origin develop

# 6. Supprimer la branche release
git branch -d release/vX.X.X
git push origin --delete release/vX.X.X
```

**Output attendu**:
```markdown
## Release terminée

**Version**: vX.X.X
**Tag**: vX.X.X
**Mergée dans**: main + develop

### Actions effectuées
- [x] Merge dans main
- [x] Tag vX.X.X créé
- [x] Merge dans develop (backport)
- [x] Branche release/vX.X.X supprimée

### Déploiement
La release est prête pour le déploiement en production.

### Prochaines étapes
- Déployer en production
- Annoncer la release
- Créer les release notes sur GitHub : `gh release create vX.X.X`
```

### LIST - Lister les releases en cours

**Syntaxe**: `/ops-gitflow-release list`

```bash
# Branches release en cours
git branch -a | grep release/

# Tags existants
git tag -l "v*" | tail -10
```

## Détection de l'action

| Pattern | Action |
|---------|--------|
| `start "vX.X.X"` | Créer release/vX.X.X |
| `finish "vX.X.X"` | Terminer release/vX.X.X |
| `list` | Lister releases et tags |

## Versioning Sémantique

| Type de changement | Version | Exemple |
|-------------------|---------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| Nouvelles features | MINOR | 1.0.0 → 1.1.0 |
| Bugfixes | PATCH | 1.0.0 → 1.0.1 |

## Checklist avant finish

### Obligatoire
- [ ] Version bump effectué
- [ ] CHANGELOG.md à jour
- [ ] Tous les tests passent
- [ ] Pas de modifications non commitées
- [ ] Code review de la release

### Recommandé
- [ ] Documentation à jour
- [ ] Audit de sécurité (`/qa-security`)
- [ ] Tests de performance (`/qa-perf`)
- [ ] Notes de release préparées

## Gestion des conflits

Si des conflits surviennent lors du merge dans develop :

```bash
# Les changements de la release ont priorité
# Résoudre manuellement puis :
git add .
git commit -m "Resolve merge conflicts from release/vX.X.X"
git push origin develop
```

## Création de release GitHub

Après le finish, créer la release GitHub :

```bash
gh release create vX.X.X \
  --title "Release vX.X.X" \
  --notes-file CHANGELOG.md \
  --latest
```

## Commandes liées

| Avant | Commande | Après |
|-------|----------|-------|
| `/ops-gitflow-feature` (features terminées) | | |
| | **RELEASE** | |
| | | `/doc-changelog` |
| | | `/qa-audit` |
| | | Déploiement production |

---

IMPORTANT: Une release DOIT être mergée dans main ET develop.

YOU MUST créer un tag sur main après le merge.

YOU MUST backporter les changements dans develop.

NEVER ajouter de nouvelles features sur une branche release.

NEVER oublier le merge dans develop (risque de perdre les bugfixes).
