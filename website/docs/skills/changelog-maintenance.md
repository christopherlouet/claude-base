---
sidebar_position: 4
title: "changelog-maintenance"
description: "Maintenance du CHANGELOG selon Keep a Changelog. Declencher quand l'utilisateur veut documenter les changements ou preparer une release."
tags:
  - "skill"
  - "fork"
---

# Skill: changelog-maintenance

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Maintenance du CHANGELOG selon Keep a Changelog. Declencher quand l'utilisateur veut documenter les changements ou preparer une release.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Mots-cles** | `changelog`, `maintenance` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux changelog..."_
- _"Je veux maintenance..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
