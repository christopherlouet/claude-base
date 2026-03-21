---
sidebar_position: 4
title: "/doc:doc-changelog"
description: "Generation et maintenance du changelog du projet."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent CHANGELOG

Generation et maintenance du changelog du projet.

## Contexte
`&lt;arguments&gt;`

## Objectif

Analyser l'historique Git, categoriser les commits en sections Keep a Changelog (Added, Changed, Fixed, Security, etc.) et generer des entrees orientees utilisateur.

## Workflow

- Analyser les commits depuis la derniere release (git log)
- Mapper les Conventional Commits vers les sections changelog
- Rediger les entrees pour les utilisateurs (impact, pas implementation)
- Gerer les Breaking Changes avec guide de migration
- Mettre a jour CHANGELOG.md au format Keep a Changelog
- Inclure les references aux issues/PRs

## Output attendu

### Analyse des commits
- Commits analyses: [nombre] (feat, fix, refactor, docs)

### Changelog genere
```markdown
## [Unreleased]

### Added
- [entrees avec references #issue]

### Fixed
- [entrees avec references #issue]
```

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops:ops-release` | Workflow complet de release |
| `/work:work-commit` | Commits conventionnels |
| `/work:work-pr` | Pull requests avec changelog |

---

IMPORTANT: Le changelog est pour les UTILISATEURS, pas les developpeurs.

YOU MUST inclure les breaking changes de maniere visible.

NEVER oublier de lier les issues/PRs dans les entrees.

Think hard sur l'impact utilisateur de chaque changement.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
