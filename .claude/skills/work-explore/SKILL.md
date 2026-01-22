---
name: work-explore
description: Explorer et comprendre un codebase existant. Utiliser quand l'utilisateur veut comprendre le code, explorer un projet, découvrir une architecture, ou avant de modifier du code existant.
allowed-tools:
  - Read
  - Glob
  - Grep
context: fork
---

# Explorer un Codebase

## Objectif

Comprendre un codebase AVANT de le modifier. Ne jamais coder sans avoir exploré.

## Instructions

### 1. Vue d'ensemble (5 min)

```bash
# Structure du projet
ls -la
tree -L 2 -I 'node_modules|.git|dist|build' | head -40

# Configuration
cat package.json | head -30
cat README.md | head -50
```

**Questions à répondre:**
- Type de projet (frontend, backend, fullstack, lib) ?
- Stack technique (langages, frameworks) ?
- Comment lancer le projet ?

### 2. Architecture (10 min)

**Identifier les couches:**
- Entry points (main, index, app)
- Routes / Controllers
- Services / Business logic
- Data access / Models
- Utilitaires

**Patterns à repérer:**
- Architecture (MVC, Clean, Hexagonal)
- State management
- Error handling
- Configuration

### 3. Flux de données

Tracer un flux complet:
```
Requête → Validation → Traitement → DB → Réponse
```

### 4. Conventions

- Style de code (linter config)
- Nommage (camelCase, snake_case)
- Structure des tests
- Format des commits

## Output attendu

```markdown
## Résumé du projet

**Type**: [frontend/backend/fullstack]
**Stack**: [langages et frameworks]
**Architecture**: [pattern principal]

## Structure clé
- `/src/xxx` - [description]
- `/src/yyy` - [description]

## Points d'entrée
- `fichier.ts:ligne` - [rôle]

## Conventions identifiées
- [Convention 1]
- [Convention 2]

## Zones sensibles
- [Zone 1] - [pourquoi]
```

## Règles

- TOUJOURS explorer avant de modifier
- Ne pas supposer - vérifier dans le code
- Noter les patterns pour les réutiliser
