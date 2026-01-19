---
sidebar_position: 4
title: Skills
description: Comprendre les skills Claude Code
---

# Skills

> Comportements auto-declenches par detection de mots-cles

## Qu'est-ce qu'un Skill ?

Un **skill** est un ensemble d'instructions qui s'activent automatiquement quand certains mots-cles sont detectes dans la conversation.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  User: "Je veux faire du TDD pour cette feature"               │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Detection de mots-cles                 │                    │
│  │                                        │                    │
│  │ "TDD" detecte → Skill TDD active       │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Instructions TDD injectees             │                    │
│  │                                        │                    │
│  │ - Ecrire le test d'abord (RED)         │                    │
│  │ - Implementer le minimum (GREEN)       │                    │
│  │ - Refactorer (REFACTOR)                │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  Claude suit automatiquement le cycle TDD                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Structure des fichiers

Les skills sont dans `.claude/skills/`, chacun dans son propre dossier:

```
.claude/skills/
├── test-driven-development/
│   ├── SKILL.md              # Instructions du skill
│   └── examples/             # Exemples pratiques (optionnel)
│       └── example.md
├── generating-commit-messages/
│   └── SKILL.md
├── debugging-issues/
│   └── SKILL.md
├── security-audit/
│   └── SKILL.md
└── ...
```

## Anatomie d'un skill

### Fichier SKILL.md

```markdown
---
name: test-driven-development
description: Developpement TDD avec cycle Red-Green-Refactor
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Test Driven Development Skill

## Declencheurs

Ce skill s'active quand l'utilisateur mentionne:
- "TDD", "test first", "test driven"
- "ecrire les tests d'abord"
- "red green refactor"

## Instructions

### Cycle TDD

1. **RED** - Ecrire un test qui echoue
2. **GREEN** - Implementer le minimum pour passer
3. **REFACTOR** - Ameliorer sans casser les tests

### Regles

IMPORTANT: Toujours commencer par le test.

YOU MUST verifier que le test echoue avant d'implementer.

NEVER ecrire plus de code que necessaire pour passer le test.
```

## Frontmatter

### Champs obligatoires

| Champ | Description | Exemple |
|-------|-------------|---------|
| `name` | Nom du skill | `test-driven-development` |
| `description` | Description courte | `Developpement TDD...` |

### Champs optionnels

| Champ | Description | Valeurs |
|-------|-------------|---------|
| `allowed-tools` | Outils autorises | Liste d'outils |
| `context` | Type de contexte | `fork` ou `shared` |

### Contextes

| Contexte | Description | Usage |
|----------|-------------|-------|
| `fork` | Contexte isole | Taches autonomes (recommande) |
| `shared` | Contexte partage | Taches interactives |

## Mots-cles declencheurs

Les skills sont actives par detection de mots-cles. Definissez-les dans la section "Declencheurs":

```markdown
## Declencheurs

Ce skill s'active quand l'utilisateur mentionne:
- "TDD", "test first"
- "ecrire les tests d'abord"
- "red green refactor"
```

## Categories de skills

### Developpement

| Skill | Mots-cles | Action |
|-------|-----------|--------|
| `test-driven-development` | TDD, test first | Cycle Red-Green-Refactor |
| `debugging-issues` | bug, erreur, debug | Investigation systematique |
| `refactoring` | refactorer, nettoyer | Refactoring guide |
| `api-development` | API, endpoint, REST | Creation d'API |

### Workflow

| Skill | Mots-cles | Action |
|-------|-----------|--------|
| `generating-commit-messages` | commit, message | Conventional Commits |
| `creating-pull-requests` | PR, pull request | PR structuree |
| `reviewing-code` | review, code review | Revue approfondie |
| `exploring-codebase` | explorer, comprendre | Analyse de code |

### Qualite

| Skill | Mots-cles | Action |
|-------|-----------|--------|
| `security-audit` | securite, OWASP | Audit securite |

### Infrastructure

| Skill | Mots-cles | Action |
|-------|-----------|--------|
| `docker-containerization` | Docker, container | Dockerisation |
| `ci-cd-pipeline` | CI/CD, pipeline | Configuration CI |
| `monitoring-instrumentation` | logs, metriques | Instrumentation |
| `infrastructure-as-code` | Terraform, IaC, OpenTofu, module, Proxmox | Modules Terraform/OpenTofu, Infrastructure Proxmox |

## Exemples de skills

### Skill simple

```markdown
---
name: generating-commit-messages
description: Generer des messages de commit Conventional Commits
context: fork
---

# Generating Commit Messages

## Declencheurs

- "commit", "message de commit"
- "git commit"

## Instructions

Generer un message de commit suivant Conventional Commits:

\`\`\`
type(scope): description

[body]

[footer]
\`\`\`

### Types
- feat: nouvelle fonctionnalite
- fix: correction de bug
- docs: documentation
- refactor: refactoring
- test: ajout de tests
- chore: maintenance
```

### Skill avec outils restreints

```markdown
---
name: exploring-codebase
description: Explorer et comprendre un codebase
allowed-tools:
  - Read
  - Grep
  - Glob
context: fork
---

# Exploring Codebase

## Declencheurs

- "explorer", "comprendre le code"
- "decouvrir le projet"

## Instructions

1. Lire les fichiers de configuration
2. Identifier la structure
3. Reperer les patterns

## Contraintes

Ne JAMAIS modifier de fichiers.
```

## Creer un nouveau skill

### 1. Creer le dossier

```bash
mkdir -p .claude/skills/mon-skill
```

### 2. Creer SKILL.md

```markdown
---
name: mon-skill
description: Description de mon skill
allowed-tools:
  - Read
  - Write
  - Edit
context: fork
---

# Mon Skill

## Declencheurs

Ce skill s'active quand:
- "mot-cle-1", "mot-cle-2"
- "phrase declencheuse"

## Instructions

1. Etape 1
2. Etape 2
3. Etape 3

## Regles

IMPORTANT: Regle importante.

YOU MUST faire ceci.

NEVER faire cela.
```

### 3. Ajouter des exemples (optionnel)

```bash
mkdir -p .claude/skills/mon-skill/examples
touch .claude/skills/mon-skill/examples/exemple.md
```

## Difference avec Commands et Agents

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Declenchement | Manuel (`/xxx`) | **Auto (mots-cles)** | Auto (delegation) |
| Contexte | Partage | **Fork** | Isole |
| Controle | Total | **Partiel** | Delegue |
| Visibilite | Explicite | **Transparente** | Transparente |

## Bonnes pratiques

1. **Mots-cles precis**: Eviter les faux positifs
2. **Contexte fork**: Recommande pour l'isolation
3. **Outils minimaux**: Restreindre aux besoins
4. **Instructions claires**: Le skill doit etre autonome
5. **Exemples pratiques**: Aider a comprendre l'usage

---

## Voir aussi

- [Commands](./commands) - Instructions manuelles
- [Agents](./agents) - Sub-agents autonomes
- [Catalogue des skills](/docs/skills) - Tous les skills claude-socle
