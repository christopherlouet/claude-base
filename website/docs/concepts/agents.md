---
sidebar_position: 3
title: Agents
description: Comprendre les sub-agents Claude Code
---

# Agents (Sub-agents)

> Sub-processus autonomes avec contexte isole pour des taches specialisees

## Qu'est-ce qu'un Agent ?

Un **agent** est un sub-processus lance par Claude via le **Task tool** pour executer une tache de maniere autonome. L'agent a son propre contexte isole et des outils restreints.

```
┌────────────────────────────────────────────────────────────────┐
│ Conversation principale                                        │
│                                                                │
│  User: "Fais un audit de securite"                             │
│                                                                │
│  Claude: Je delegue a l'agent qa-security...                   │
│          ┌──────────────────────────────────┐                  │
│          │ Agent qa-security                │                  │
│          │ ┌──────────────────────────────┐ │                  │
│          │ │ Contexte ISOLE               │ │                  │
│          │ │ Outils: Read, Grep, Glob     │ │                  │
│          │ │ Modele: sonnet               │ │                  │
│          │ └──────────────────────────────┘ │                  │
│          │                                  │                  │
│          │ [Execute l'audit...]             │                  │
│          │                                  │                  │
│          │ Resultat: 3 vulnerabilites       │                  │
│          └──────────────────────────────────┘                  │
│                                                                │
│  Claude: L'audit a trouve 3 vulnerabilites...                  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Avantages des agents

| Avantage | Description |
|----------|-------------|
| **Contexte isole** | Ne pollue pas la conversation principale |
| **Outils restreints** | Acces limite (lecture seule pour audits) |
| **Modele optimise** | Haiku pour taches simples, Sonnet pour complexes |
| **Parallelisation** | Plusieurs agents peuvent tourner simultanement |
| **Specialisation** | Instructions specifiques au domaine |

## Structure des fichiers

Les agents sont definis dans `.claude/agents/`:

```
.claude/agents/
├── work-explore.md       # Exploration de code
├── qa-security.md        # Audit securite
├── qa-perf.md            # Audit performance
├── ops-deps.md           # Audit dependances
├── dev-debug.md          # Investigation bugs
├── biz-competitor.md     # Analyse concurrentielle
└── ...
```

## Anatomie d'un agent

### Frontmatter obligatoire

```yaml
---
model: haiku              # ou "sonnet" pour taches complexes
---
```

### Frontmatter complet

```yaml
---
model: sonnet
permissionMode: plan      # "plan" = lecture seule
disallowedTools:
  - Edit
  - Write
  - NotebookEdit
hooks:
  PreToolUse:
    - matcher: ".*"
      command: "echo 'Tool used'"
skills:
  - security-audit        # Skills injectes dans l'agent
---
```

### Contenu de l'agent

```markdown
---
model: haiku
---

# Agent Work-Explore

Agent specialise dans l'exploration de codebase.

## Mission

Explorer et comprendre un codebase existant sans le modifier.

## Instructions

1. Identifier les fichiers de configuration (package.json, etc.)
2. Analyser la structure des dossiers
3. Reperer les patterns et conventions
4. Documenter les dependances cles

## Contraintes

- Ne JAMAIS modifier de fichiers
- Se concentrer sur la comprehension
- Fournir une synthese structuree

## Output

Rapport d'exploration avec:
- Vue d'ensemble
- Technologies utilisees
- Points d'attention
```

## Configuration des agents

### Modeles disponibles

| Modele | Usage | Cout | Vitesse |
|--------|-------|------|---------|
| `haiku` | Taches simples, rapides | Faible | Rapide |
| `sonnet` | Taches complexes, analyses | Moyen | Moyen |

### Permission modes

| Mode | Description | Outils |
|------|-------------|--------|
| `default` | Acces complet | Tous |
| `plan` | Lecture seule | Read, Grep, Glob uniquement |

### Outils restreints

```yaml
disallowedTools:
  - Edit           # Pas de modification
  - Write          # Pas de creation
  - NotebookEdit   # Pas d'edition notebook
  - Bash           # Pas de commandes shell
```

## Declenchement automatique

Claude delegue automatiquement aux agents selon le contexte:

| Demande utilisateur | Agent delegue | Raison |
|---------------------|---------------|--------|
| "Explore le code" | `work-explore` | Mots-cles exploration |
| "Audit de securite" | `qa-security` | Mots-cles securite |
| "Verifie les dependances" | `ops-deps` | Mots-cles dependances |
| "Analyse les concurrents" | `biz-competitor` | Mots-cles business |

## Categories d'agents

### Exploration & Documentation

| Agent | Modele | Description |
|-------|--------|-------------|
| `work-explore` | haiku | Explorer un codebase |
| `doc-onboard` | haiku | Onboarding developpeur |
| `doc-explain` | haiku | Expliquer du code |

### Qualite & Audits

| Agent | Modele | Description |
|-------|--------|-------------|
| `qa-security` | sonnet | Audit OWASP Top 10 |
| `qa-perf` | sonnet | Audit performance |
| `wcag-audit` | haiku | Audit accessibilite |
| `qa-audit` | sonnet | Audit complet |

### Operations

| Agent | Modele | Description |
|-------|--------|-------------|
| `ops-deps` | haiku | Audit dependances |
| `ops-health` | haiku | Health check |
| `ops-docker` | haiku | Containerisation |

### Developpement

| Agent | Modele | Description |
|-------|--------|-------------|
| `dev-debug` | sonnet | Investigation bugs |
| `dev-test` | haiku | Generation tests |

### Business & Growth

| Agent | Modele | Description |
|-------|--------|-------------|
| `biz-model` | haiku | Business model |
| `biz-competitor` | haiku | Analyse concurrents |
| `growth-seo` | haiku | Audit SEO |

## Creer un nouvel agent

### 1. Creer le fichier

```bash
touch .claude/agents/mon-agent.md
```

### 2. Definir le frontmatter

```yaml
---
model: haiku
permissionMode: plan
disallowedTools:
  - Edit
  - Write
---
```

### 3. Ecrire les instructions

```markdown
# Agent Mon-Agent

## Mission
Description de la mission.

## Instructions
1. Etape 1
2. Etape 2

## Output
Format attendu.
```

## Difference avec Commands et Skills

| Aspect | Command | Skill | Agent |
|--------|---------|-------|-------|
| Declenchement | Manuel | Auto (mots-cles) | Auto (delegation) |
| Contexte | Partage | Fork | **Isole** |
| Outils | Tous | Restreints | **Tres restreints** |
| Modele | Principal | Principal | **Configurable** |
| Parallelisation | Non | Non | **Oui** |

## Bonnes pratiques

1. **Choisir le bon modele**: Haiku pour taches simples, Sonnet pour analyses complexes
2. **Restreindre les outils**: Minimum necessaire pour la tache
3. **Mode plan pour audits**: Empeche les modifications accidentelles
4. **Instructions claires**: L'agent doit etre autonome
5. **Output structure**: Facilite l'integration du resultat

---

## Voir aussi

- [Commands](./commands) - Instructions manuelles
- [Skills](./skills) - Comportements automatiques
- [Catalogue des agents](/docs/agents) - Tous les agents claude-socle
