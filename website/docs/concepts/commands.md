---
sidebar_position: 2
title: Commands
description: Comprendre les commandes Claude Code
---

# Commands

> Instructions declenchees manuellement avec le prefixe `/`

## Qu'est-ce qu'une Command ?

Une **command** est un fichier Markdown qui contient des instructions pour Claude. Elle est declenchee explicitement par l'utilisateur avec le prefixe `/`.

```bash
# Exemples d'invocation
/work-explore "Comprendre l'architecture"
/dev-tdd "Implementer le service utilisateur"
/qa-security
```

## Structure des fichiers

Les commands sont organisees par domaine dans `.claude/commands/`:

```
.claude/commands/
├── work/                    # Workflow principal
│   ├── work-explore.md
│   ├── work-plan.md
│   ├── work-commit.md
│   └── work-pr.md
├── dev/                     # Developpement
│   ├── dev-tdd.md
│   ├── dev-api.md
│   └── dev-component.md
├── qa/                      # Qualite
│   ├── qa-security.md
│   ├── qa-perf.md
│   └── qa-a11y.md
├── ops/                     # Operations
├── doc/                     # Documentation
├── biz/                     # Business
├── growth/                  # Croissance
├── data/                    # Donnees
└── legal/                   # Legal
```

## Anatomie d'une command

### Structure minimale

```markdown
# Titre de la commande

Description de ce que fait la commande.

## Instructions

1. Etape 1
2. Etape 2
3. Etape 3

## Output attendu

Description du resultat attendu.
```

### Structure avancee avec frontmatter

```markdown
---
description: Description courte pour l'aide
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
---

# Ma Commande

## Contexte
$ARGUMENTS

## Instructions
...
```

### Variable speciale `$ARGUMENTS`

La variable `$ARGUMENTS` est remplacee par les arguments passes a la commande:

```bash
/dev-tdd "Implementer l'authentification JWT"
```

Dans le fichier `dev-tdd.md`:
```markdown
## Contexte
$ARGUMENTS
# Devient: "Implementer l'authentification JWT"
```

## Caracteristiques

| Propriete | Valeur |
|-----------|--------|
| **Declenchement** | Manuel (`/nom`) |
| **Contexte** | Partage avec la conversation |
| **Outils** | Tous disponibles (sauf restriction) |
| **Visibilite** | L'utilisateur voit l'invocation |

## Difference avec Skills et Agents

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Declenchement | Manuel | Auto (mots-cles) | Auto (delegation) |
| Contexte | Partage | Fork | Isole |
| Controle | Total | Partiel | Delegue |
| Cas d'usage | Actions explicites | Comportements recurrents | Taches autonomes |

## Bonnes pratiques

### 1. Nommage coherent

```
domaine-action
```

Exemples:
- `work-explore` (workflow + explorer)
- `dev-tdd` (developpement + TDD)
- `qa-security` (qualite + securite)

### 2. Instructions claires

```markdown
## Instructions

IMPORTANT: Toujours explorer le code avant de modifier.

YOU MUST suivre le pattern existant.

NEVER modifier les fichiers de configuration sans validation.
```

### 3. Output structure

```markdown
## Output attendu

### Format
- Section 1: Resume
- Section 2: Details
- Section 3: Recommandations

### Exemple
\`\`\`markdown
## Resume
...
\`\`\`
```

## Creer une nouvelle command

### 1. Creer le fichier

```bash
# Dans le bon domaine
touch .claude/commands/dev/dev-ma-commande.md
```

### 2. Ecrire le contenu

```markdown
# Ma Nouvelle Commande

## Contexte
$ARGUMENTS

## Instructions

1. Analyser la demande
2. Executer l'action
3. Verifier le resultat

## Output

Fournir un rapport structure.
```

### 3. Tester

```bash
/dev-ma-commande "Test de la commande"
```

## Exemples de commands

### Command simple (exploration)

```markdown
# Work Explore

Explorer et comprendre un codebase existant.

## Contexte
$ARGUMENTS

## Instructions

1. Identifier les fichiers principaux (package.json, README, etc.)
2. Analyser la structure des dossiers
3. Reperer les patterns et conventions
4. Documenter les dependances cles

## Output

Fournir une vue d'ensemble structuree du projet.
```

### Command complexe (workflow)

```markdown
# Work Flow Feature

Workflow complet pour implementer une nouvelle feature.

## Contexte
$ARGUMENTS

## Etapes

### 1. Exploration
Utiliser /work-explore pour comprendre le contexte.

### 2. Specification
Utiliser /work-specify pour definir les User Stories.

### 3. Planification
Utiliser /work-plan pour creer le plan d'implementation.

### 4. Developpement
Utiliser /dev-tdd pour implementer avec tests.

### 5. Revue
Utiliser /qa-review pour verifier la qualite.

### 6. Livraison
Utiliser /work-pr pour creer la Pull Request.
```

## Lister les commands disponibles

Dans Claude Code, utilisez `/help` pour voir les commandes disponibles, ou explorez directement le dossier `.claude/commands/`.

---

## Voir aussi

- [Skills](./skills) - Comportements automatiques
- [Agents](./agents) - Sub-agents autonomes
- [Catalogue des commands](/docs/commands) - Toutes les commands claude-socle
