# Agent CHANGELOG

Génération et maintenance du changelog du projet.

## Contexte
$ARGUMENTS

## Standards de Changelog

### Format Keep a Changelog
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Vulnerability fixes

## [1.0.0] - 2024-01-15

### Added
- Initial release
```

## Workflow de Génération

### 1. Analyser l'historique Git
```bash
# Commits depuis la dernière release
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Ou depuis une date/tag spécifique
git log v1.0.0..HEAD --oneline --pretty=format:"%s (%h)"
```

### 2. Catégoriser les commits

#### Mapping Conventional Commits → Changelog
| Type de commit | Section Changelog |
|----------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `docs:` | Changed (si significatif) |
| `refactor:` | Changed |
| `perf:` | Changed |
| `security:` | Security |
| `deprecate:` | Deprecated |
| `remove:` | Removed |
| `breaking:` | Changed (avec note ⚠️) |

### 3. Rédiger les entrées

#### Bonnes pratiques
- IMPORTANT: Écrire pour les utilisateurs, pas pour les développeurs
- IMPORTANT: Expliquer l'impact, pas l'implémentation
- Commencer par un verbe d'action
- Inclure les références aux issues/PRs

#### Exemples
```markdown
### Added
- Add user authentication via OAuth2 (#123)
- Add dark mode toggle in settings (#145)

### Changed
- Improve search performance by 50% (#156)
- Update API response format for pagination (#167)

### Fixed
- Fix memory leak in image processing (#178)
- Fix incorrect date formatting in exports (#189)

### Security
- Fix XSS vulnerability in comment section (#190)
```

### 4. Gérer les Breaking Changes

```markdown
## [2.0.0] - 2024-03-01

### ⚠️ Breaking Changes
- Remove deprecated `getUserById()` function. Use `users.get(id)` instead.
- Change authentication flow to OAuth2. See migration guide.

### Migration Guide
1. Update API calls from `getUserById(id)` to `users.get(id)`
2. Configure OAuth2 credentials in `.env`
3. Update client SDK to version 2.x
```

## Modes d'utilisation

### Mode 1 : Générer depuis les commits
```
Analyse les commits depuis la dernière release et génère
les entrées de changelog appropriées.
```

### Mode 2 : Mettre à jour pour une release
```
Déplace les entrées [Unreleased] vers une nouvelle version
avec la date du jour.
```

### Mode 3 : Ajouter une entrée manuellement
```
Ajoute une entrée spécifique dans la section appropriée
de [Unreleased].
```

## Output attendu

### Analyse des commits
```
Commits analysés: 25
- feat: 8
- fix: 10
- refactor: 4
- docs: 3

Entrées générées:
```

### Changelog généré
```markdown
## [Unreleased]

### Added
- [entrée 1]
- [entrée 2]

### Fixed
- [entrée 1]
...
```

## Automatisation

### Script de release
```bash
# 1. Mettre à jour CHANGELOG.md
# 2. Bump version dans package.json
# 3. Commit et tag
npm version [major|minor|patch]
```

### GitHub Release Notes
```bash
# Générer release notes depuis changelog
gh release create v1.2.0 --notes-file CHANGELOG.md
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/release` | Workflow complet de release |
| `/commit` | Commits conventionnels |
| `/pr` | Pull requests avec changelog |

---

IMPORTANT: Le changelog est pour les UTILISATEURS, pas les développeurs.

IMPORTANT: Chaque release doit avoir une date au format ISO (YYYY-MM-DD).

YOU MUST inclure les breaking changes de manière visible.

NEVER oublier de lier les issues/PRs dans les entrées.

Think hard sur l'impact utilisateur de chaque changement.
