---
name: doc-changelog
description: Maintenance du CHANGELOG selon Keep a Changelog. Declencher quand l'utilisateur veut documenter les changements ou preparer une release.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Changelog Maintenance

## Format Keep a Changelog

```markdown
# Changelog

All notable changes will be documented here.

## [Unreleased]

### Added
- New feature

### Changed
- Modified behavior

### Fixed
- Bug fix

## [1.2.0] - 2024-01-15

### Added
- User authentication (#123)

### Fixed
- Login timeout (#127)

[Unreleased]: https://github.com/user/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/user/repo/releases/tag/v1.2.0
```

## Categories

| Category | Description |
|----------|-------------|
| Added | New features |
| Changed | Changes in existing functionality |
| Deprecated | Soon-to-be removed features |
| Removed | Removed features |
| Fixed | Bug fixes |
| Security | Security fixes |

## Bonnes pratiques

- Une entree par changement significatif
- Liens vers issues/PRs
- Date format ISO (YYYY-MM-DD)
- [Unreleased] toujours a jour
- Ecrire pour les utilisateurs
