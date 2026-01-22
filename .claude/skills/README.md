# Claude Code Skills

Ce dossier contient des **Skills** - des connaissances domaine réutilisables qui enseignent à Claude les patterns et conventions du projet.

## Différence entre Commands et Skills

| Aspect | Commands (`.claude/commands/`) | Skills (`.claude/skills/`) |
|--------|-------------------------------|---------------------------|
| **Invocation** | Explicite: `/nom` | Automatique ou `/nom` |
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
name: domaine-action
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

## Convention de nommage

Les skills suivent la même convention que les commandes : `domaine-action`

| Domaine | Exemples |
|---------|----------|
| `work-` | `work-explore`, `work-plan`, `work-commit`, `work-pr` |
| `dev-` | `dev-tdd`, `dev-debug`, `dev-api`, `dev-flutter` |
| `qa-` | `qa-review`, `qa-security`, `qa-perf`, `qa-e2e` |
| `ops-` | `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring` |
| `doc-` | `doc-generate`, `doc-changelog` |
| `data-` | `data-pipeline` |

## Skills disponibles

| Skill | Description | Déclencheurs |
|-------|-------------|--------------|
| `work-explore` | Explorer et comprendre un codebase | "explorer", "comprendre le code", "découvrir" |
| `work-plan` | Planifier une implémentation | "planifier", "architecture", "plan" |
| `work-commit` | Messages Conventional Commits | "commit", "message de commit" |
| `work-pr` | Créer une PR complète | "PR", "pull request", "merger" |
| `dev-tdd` | Cycle TDD Red-Green-Refactor | "TDD", "test first", "écrire les tests" |
| `dev-debug` | Déboguer et résoudre des problèmes | "debug", "bug", "erreur", "ne fonctionne pas" |
| `dev-api` | Développer une API REST/GraphQL | "API", "endpoint", "route", "REST" |
| `qa-review` | Revue de code approfondie | "review", "relire", "vérifier le code" |
| `qa-security` | Audit de sécurité OWASP | "sécurité", "audit", "vulnérabilité", "OWASP" |

## Créer un nouveau Skill

1. Créer le dossier: `mkdir .claude/skills/domaine-action`
2. Créer `SKILL.md` avec frontmatter YAML
3. Ajouter des exemples dans `examples/` (recommandé)
4. La description doit inclure les déclencheurs (quand utiliser)

## Bonnes pratiques

- **Nommage cohérent**: Utiliser le format `domaine-action` (ex: `dev-tdd`, `qa-security`)
- **Description riche**: Inclure tous les mots-clés déclencheurs
- **SKILL.md < 500 lignes**: Détails dans `references/`
- **Exemples concrets**: Montrer le bon ET le mauvais pattern
