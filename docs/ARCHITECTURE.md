# Architecture Claude Code Socle

> Comprendre la difference entre Commands, Agents, Skills et Rules

## Pourquoi certains fichiers existent dans commands/ ET agents/ ?

La duplication est **intentionnelle** et sert des objectifs differents :

- **commands/xxx.md** = Prompt interactif invoque manuellement (`/xxx`)
- **agents/xxx.md** = Version delegable avec frontmatter YAML (model, tools, skills)

Claude Code utilise :
1. La **command** quand l'utilisateur tape `/xxx` explicitement
2. L'**agent** quand Claude delegue automatiquement une sous-tache

### Differences cles

| Aspect | Command | Agent |
|--------|---------|-------|
| Declenchement | Manuel (`/xxx`) | Automatique (delegation) |
| Frontmatter | Non | Oui (model, tools, skills) |
| Contexte | Partage | **Isole** |
| Variable | `$ARGUMENTS` | Non |
| Modele | Default | Configurable (haiku/sonnet) |
| Outils | Tous | Restreints (configurable) |

### Exemple concret

```bash
# L'utilisateur tape explicitement la commande
/qa:qa-security

# → Claude charge commands/qa/qa-security.md (prompt)
# → Claude delegue a agents/qa-security.md (contexte isole, model: sonnet)
# → L'agent utilise le skill security-audit
# → Resultat retourne au contexte principal
```

Cette architecture permet :
- **Flexibilite** : L'utilisateur controle via commands
- **Optimisation** : Claude delegue avec le bon modele
- **Isolation** : Les agents ne polluent pas le contexte
- **Securite** : Outils restreints pour les audits

---

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                         UTILISATEUR                              │
│                             │                                    │
│    ┌───────────────────────┼───────────────────────┐            │
│    │                       ▼                       │            │
│    │  ┌─────────────────────────────────────────┐  │            │
│    │  │           DECLENCHEMENT                  │  │            │
│    │  │                                          │  │            │
│    │  │  Manuel (/cmd)    Automatique (context)  │  │            │
│    │  │       │                  │               │  │            │
│    │  │       ▼                  ▼               │  │            │
│    │  │  ┌─────────┐      ┌───────────┐         │  │            │
│    │  │  │COMMANDS │      │  SKILLS   │         │  │            │
│    │  │  └────┬────┘      └─────┬─────┘         │  │            │
│    │  │       │                 │               │  │            │
│    │  │       └────────┬────────┘               │  │            │
│    │  │                │                        │  │            │
│    │  │                ▼                        │  │            │
│    │  │         ┌───────────┐                   │  │            │
│    │  │         │  AGENTS   │ (delegation)      │  │            │
│    │  │         └─────┬─────┘                   │  │            │
│    │  │               │                         │  │            │
│    │  │               ▼                         │  │            │
│    │  │         ┌───────────┐                   │  │            │
│    │  │         │  RULES    │ (contraintes)     │  │            │
│    │  │         └───────────┘                   │  │            │
│    │  └─────────────────────────────────────────┘  │            │
│    │                                               │            │
│    └───────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## Comparaison Detaillee

| Aspect | Commands | Skills | Agents | Rules |
|--------|----------|--------|--------|-------|
| **Dossier** | `.claude/commands/` | `.claude/skills/` | `.claude/agents/` | `.claude/rules/` |
| **Declenchement** | Manuel (`/cmd`) | Automatique | Delegation auto | Path-based |
| **Contexte** | Partage | Fork ou partage | **Isole** | Injecte |
| **Outils** | Tous | Configurable | Restreints | N/A |
| **Modele** | Default | Default | Configurable | N/A |
| **Cas d'usage** | Actions explicites | Patterns detectes | Taches isolees | Contraintes |

## Commands (118 disponibles)

### Definition
Prompts invoques manuellement avec la syntaxe `/nom-commande`.

### Caracteristiques
- Declenchement explicite par l'utilisateur
- Contexte partage avec la conversation
- Acces a tous les outils
- Structure: prompts markdown

### Structure fichier
```
.claude/commands/
├── work/
│   ├── work-explore.md
│   ├── work-plan.md
│   └── work-commit.md
├── dev/
│   ├── dev-tdd.md
│   └── dev-api.md
└── ...
```

### Format
```markdown
# Titre de la commande

## Instructions
Instructions pour Claude...

## Variables
$ARGUMENTS - Arguments passes par l'utilisateur
```

### Exemple d'utilisation
```bash
/work:work-explore "comprendre le systeme d'authentification"
/dev:dev-api "endpoint CRUD pour les utilisateurs"
/qa:qa-security
```

### Quand utiliser
- Workflow explicite
- Actions specifiques
- Taches complexes necessitant un prompt detaille

## Skills (41 disponibles)

### Definition
Patterns declenches automatiquement par Claude selon le contexte de la conversation.

### Caracteristiques
- Declenchement automatique (mots-cles, contexte)
- Contexte fork recommande
- Outils configurables (whitelist)
- Structure: YAML frontmatter + instructions

### Structure fichier
```
.claude/skills/
└── skill-name/
    └── SKILL.md
```

### Format
```yaml
---
name: nom-du-skill
description: Quand declencher ce skill
allowed-tools:
  - Read
  - Write
  - Edit
context: fork
---

# Instructions

Instructions pour le skill...
```

### Exemple de skill
```yaml
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

# TDD Skill

Quand l'utilisateur mentionne "TDD", "test first", ou "ecrire les tests d'abord"...
```

### Quand utiliser
- Patterns recurrents
- Declenchement contextuel desire
- Standardisation de comportements

## Agents (57 disponibles)

### Definition
Sub-agents specialises avec contexte isole, delegation automatique.

### Caracteristiques
- **Contexte completement isole** (ne pollue pas la conversation)
- Outils restreints (securite)
- Modele configurable (haiku/sonnet/opus)
- Hooks pre/post outil
- Skills injectables

### Structure fichier
```
.claude/agents/
├── work-explore.md
├── qa-security.md
├── dev-debug.md
└── ...
```

### Format
```yaml
---
name: nom-agent
description: Description de l'agent
model: haiku | sonnet | opus
permissionMode: plan | default
disallowedTools:
  - Edit
  - Write
hooks:
  PreToolUse:
    - command: validate.sh
skills:
  - security-audit
---

# Instructions

Instructions pour l'agent...
```

### Modeles disponibles

| Modele | Usage | Cout | Vitesse | Contexte | Sortie max |
|--------|-------|------|---------|----------|------------|
| haiku | Taches simples, lecture | $ | Rapide | 200k | 8k |
| sonnet | Taches complexes, analyse | $$ | Medium | 200k | 64k |
| opus (4.6) | Taches critiques, adaptive thinking | $$$ | Plus lent | 1M (beta) | 128k |

### Exemple d'agent
```yaml
---
name: qa-security
description: Audit de securite OWASP Top 10
model: sonnet
permissionMode: plan
disallowedTools:
  - Edit
  - Write
  - NotebookEdit
skills:
  - security-audit
---

# Agent QA Security

Effectue un audit de securite complet base sur OWASP Top 10...
```

### Quand utiliser
- Taches necessitant isolation
- Audits (lecture seule)
- Parallelisation
- Economie de tokens (haiku)

## Rules (21 disponibles)

### Definition
Contraintes et conventions injectees automatiquement selon le chemin des fichiers.

### Caracteristiques
- Injection automatique par path
- Pas de declenchement utilisateur
- Contraintes globales ou specifiques
- Affecte Commands, Skills, Agents

### Structure fichier
```
.claude/rules/
├── typescript.md    # **/*.ts, **/*.tsx
├── react.md         # **/*.tsx, **/components/**
├── flutter.md       # **/*.dart, **/lib/**
├── testing.md       # **/*.test.ts, **/__tests__/**
├── security.md      # **/auth/**, **/api/**
├── api.md           # **/api/**, **/routes/**
├── git.md           # Global
├── workflow.md      # Global
├── java.md          # **/*.java
├── csharp.md        # **/*.cs
├── ruby.md          # **/*.rb
├── php.md           # **/*.php
└── rust.md          # **/*.rs
```

### Format
```yaml
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Mode strict
- Toujours `strict: true`
- Pas de `any` sauf justifie
...
```

### Quand utiliser
- Conventions de code
- Regles de securite
- Standards de qualite
- Contraintes par technologie

## Matrice de Decision

### Par type de tache

| Tache | Meilleur choix | Raison |
|-------|----------------|--------|
| Workflow explicite | **Command** | Controle utilisateur |
| Pattern recurrent | **Skill** | Declenchement auto |
| Audit lecture seule | **Agent** | Isolation, securite |
| Convention code | **Rule** | Injection auto |
| Tache parallele | **Agent** | Contexte isole |
| Action complexe | **Command** | Prompt detaille |

### Par frequence d'usage

| Frequence | Meilleur choix |
|-----------|----------------|
| 1x par projet | Command |
| Plusieurs fois/jour | Skill |
| En parallele | Agent |
| Toujours (constraint) | Rule |

### Par besoin d'isolation

| Besoin | Choix |
|--------|-------|
| Partager le contexte | Command ou Skill |
| Isoler completement | Agent |
| Contraindre globalement | Rule |

## Exemples Concrets

### Scenario 1: Nouvelle feature

```
1. /work:work-explore        → Command (explicite)
2. Pattern TDD detecte  → Skill (auto)
3. Audit securite       → Agent (isole)
4. /work:work-pr             → Command (explicite)

Rules appliquees: typescript.md, react.md, security.md
```

### Scenario 2: Bug fix urgent

```
1. /dev:dev-debug           → Command (explicite)
2. Investigation        → Agent dev-debug (isole)
3. Fix applique         → Rules typescript.md
4. /work:work-commit         → Command (explicite)
```

### Scenario 3: Audit complet

```
1. /qa:qa-audit            → Command (explicite)
   ├── qa-security      → Agent (parallele)
   ├── qa-perf          → Agent (parallele)
   ├── qa-a11y          → Agent (parallele)
   └── qa-coverage      → Agent (parallele)

Tous en lecture seule, contextes isoles
```

## Bonnes Pratiques

### Commands
- Noms explicites (`/work:work-explore` pas `/we`)
- Grouper par domaine (`work-`, `dev-`, `qa-`)
- Documenter les arguments attendus

### Skills
- `context: fork` recommande
- Limiter les `allowed-tools`
- Mots-cles de declenchement clairs

### Agents
- `model: haiku` pour taches simples
- `disallowedTools` pour securite
- Injecter les skills pertinents

### Rules
- Paths specifiques pas trop larges
- Regles claires et actionables
- Pas de regles conflictuelles

## Flux de Donnees

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  User: "/qa:qa-security"                                          │
│       │                                                        │
│       ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ COMMAND: /qa:qa-security                                    │   │
│  │ → Charge le prompt qa-security.md                        │   │
│  │ → Detecte fichiers *.ts → Injecte rules/typescript.md   │   │
│  │ → Detecte dossier api/ → Injecte rules/api.md           │   │
│  │ → Detecte dossier auth/ → Injecte rules/security.md     │   │
│  └─────────────────────────────────────────────────────────┘   │
│       │                                                        │
│       ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ DELEGATION → AGENT: qa-security                          │   │
│  │ → model: sonnet                                          │   │
│  │ → permissionMode: plan (lecture seule)                   │   │
│  │ → disallowedTools: [Edit, Write]                         │   │
│  │ → skills: [security-audit]                               │   │
│  │ → Contexte ISOLE                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│       │                                                        │
│       ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ SKILL: security-audit (injecte dans agent)               │   │
│  │ → Checklist OWASP Top 10                                 │   │
│  │ → Patterns de vulnerabilite                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│       │                                                        │
│       ▼                                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ RESULTAT → Retourne au contexte principal                │   │
│  │ → Rapport de l'agent                                     │   │
│  │ → Contexte principal preserve                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Resume

| Concept | Declencheur | Contexte | Usage principal |
|---------|-------------|----------|-----------------|
| **Command** | `/nom` | Partage | Actions explicites |
| **Skill** | Mots-cles | Fork | Patterns auto |
| **Agent** | Delegation | **Isole** | Taches paralleles |
| **Rule** | Path fichier | Injecte | Contraintes |
