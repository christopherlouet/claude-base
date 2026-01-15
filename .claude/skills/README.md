# Claude Code Skills

Ce dossier contient des **Skills** - des connaissances domaine réutilisables qui enseignent à Claude les patterns et conventions du projet.

## Différence entre Commands et Skills

| Aspect | Commands (`.claude/commands/`) | Skills (`.claude/skills/`) |
|--------|-------------------------------|---------------------------|
| **Invocation** | Explicite: `/project:nom` | Automatique ou `/nom` |
| **Format** | Un fichier `.md` | Dossier avec `SKILL.md` + ressources |
| **Déclenchement** | Manuel uniquement | Basé sur la description (sémantique) |
| **Ressources** | Non | Oui (examples/, scripts/, references/) |

## Structure d'un Skill

```
skill-name/
├── SKILL.md           # Instructions principales (requis)
├── examples/          # Exemples concrets (optionnel)
│   └── example-1.md
├── references/        # Documentation additionnelle (optionnel)
└── scripts/           # Scripts helper (optionnel)
```

## Format SKILL.md

```yaml
---
name: nom-du-skill
description: Description claire de ce que fait le skill et QUAND l'utiliser.
allowed-tools:        # Optionnel - limite les outils disponibles
  - Read
  - Edit
  - Bash
---

# Titre du Skill

## Instructions
[Instructions détaillées pour Claude]

## Exemples
[Exemples d'utilisation]
```

## Skills disponibles

| Skill | Description | Déclencheurs |
|-------|-------------|--------------|
| `exploring-codebase` | Explorer et comprendre un codebase | "explorer", "comprendre le code", "découvrir" |
| `planning-implementation` | Planifier une implémentation | "planifier", "architecture", "plan" |
| `test-driven-development` | Cycle TDD Red-Green-Refactor | "TDD", "test first", "écrire les tests" |
| `reviewing-code` | Revue de code approfondie | "review", "relire", "vérifier le code" |
| `debugging-issues` | Déboguer et résoudre des problèmes | "debug", "bug", "erreur", "ne fonctionne pas" |
| `generating-commit-messages` | Messages Conventional Commits | "commit", "message de commit" |
| `creating-pull-requests` | Créer une PR complète | "PR", "pull request", "merger" |
| `api-development` | Développer une API REST/GraphQL | "API", "endpoint", "route", "REST" |
| `security-audit` | Audit de sécurité OWASP | "sécurité", "audit", "vulnérabilité", "OWASP" |

## Créer un nouveau Skill

1. Créer le dossier: `mkdir .claude/skills/mon-skill`
2. Créer `SKILL.md` avec frontmatter YAML
3. Ajouter des exemples dans `examples/` (recommandé)
4. La description doit inclure les déclencheurs (quand utiliser)

## Bonnes pratiques

- **Description riche**: Inclure tous les mots-clés déclencheurs
- **SKILL.md < 500 lignes**: Détails dans `references/`
- **Exemples concrets**: Montrer le bon ET le mauvais pattern
- **Noms en gerund**: `generating-`, `testing-`, `debugging-`
