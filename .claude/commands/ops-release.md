# Agent RELEASE

Workflow de release avec changelog et versioning.

## Version ou contexte
$ARGUMENTS

## Workflow de Release

### 1. Préparation
```bash
# S'assurer d'être à jour
git checkout develop
git pull origin develop

# Vérifier l'état
git status
npm test
npm run build
```

### 2. Déterminer la version

#### Semantic Versioning (SemVer)
| Type | Quand | Exemple |
|------|-------|---------|
| MAJOR (X.0.0) | Breaking changes | 1.0.0 → 2.0.0 |
| MINOR (0.X.0) | Nouvelles features backward-compatible | 1.0.0 → 1.1.0 |
| PATCH (0.0.X) | Bug fixes backward-compatible | 1.0.0 → 1.0.1 |

### 3. Générer le Changelog

#### Format
```markdown
# Changelog

## [X.Y.Z] - YYYY-MM-DD

### Added
- Nouvelle fonctionnalité A (#123)
- Nouvelle fonctionnalité B (#124)

### Changed
- Amélioration de X (#125)

### Fixed
- Correction du bug Y (#126)
- Correction du bug Z (#127)

### Deprecated
- Fonction X sera supprimée en v3.0

### Removed
- Suppression de la fonction obsolète Y

### Security
- Correction de vulnérabilité CVE-XXXX
```

### 4. Créer la release

```bash
# Créer branche release
git checkout -b release/vX.Y.Z

# Mettre à jour la version
npm version X.Y.Z --no-git-tag-version

# Mettre à jour CHANGELOG.md
# ... éditer le fichier ...

# Commit
git add package.json package-lock.json CHANGELOG.md
git commit -m "chore(release): prepare vX.Y.Z"
```

### 5. Finaliser

```bash
# Merger dans main
git checkout main
git merge release/vX.Y.Z

# Tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# Push
git push origin main --tags

# Merger dans develop
git checkout develop
git merge main
git push origin develop

# Créer GitHub Release
gh release create vX.Y.Z --title "vX.Y.Z" --notes-file CHANGELOG.md
```

### 6. Post-release
- [ ] Vérifier le déploiement
- [ ] Annoncer la release (si public)
- [ ] Mettre à jour la documentation
- [ ] Supprimer la branche release

## Checklist pré-release

- [ ] Tous les tests passent
- [ ] Build de production OK
- [ ] Documentation à jour
- [ ] CHANGELOG complet
- [ ] Breaking changes documentés
- [ ] Migration guide si nécessaire
- [ ] Dépendances à jour (npm audit clean)

## Template de release notes

```markdown
# Release vX.Y.Z

## Highlights
[Résumé des changements majeurs en 2-3 phrases]

## What's New
- Feature 1: [description]
- Feature 2: [description]

## Bug Fixes
- Fix 1: [description] (#issue)

## Breaking Changes
- [Description du breaking change et comment migrer]

## Upgrade Guide
[Instructions de mise à jour si nécessaire]

## Contributors
@contributor1, @contributor2
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/changelog` | Générer le changelog |
| `/ci` | Automatiser la release |
| `/test` | Tests pré-release |
| `/security` | Audit avant release |
| `/monitoring` | Vérifier post-release |

---

IMPORTANT: Tester la release en staging avant production.

IMPORTANT: Toujours avoir un plan de rollback.

YOU MUST mettre à jour le changelog.

NEVER release un vendredi soir (sauf urgence).
