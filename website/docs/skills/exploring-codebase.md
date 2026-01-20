---
sidebar_position: 14
title: "exploring-codebase"
description: "Explorer et comprendre un codebase existant. Utiliser quand l'utilisateur veut comprendre le code, explorer un projet, découvrir une architecture, ou avant de modifier du code existant."
tags:
  - "skill"
  - "fork"
---

# Skill: exploring-codebase

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Explorer et comprendre un codebase existant. Utiliser quand l'utilisateur veut comprendre le code, explorer un projet, découvrir une architecture, ou avant de modifier du code existant.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep` |
| **Mots-cles** | `exploring`, `codebase` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux exploring..."_
- _"Je veux codebase..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple d'exploration de codebase

# Exemple d'exploration de codebase

## Contexte
Nouveau développeur sur un projet e-commerce Next.js.

## Exploration réalisée

### 1. Vue d'ensemble
```bash
# Structure du projet
tree -L 2 -d src/
```

**Résultat:**
```
src/
├── app/           # Routes Next.js 13+ (App Router)
├── components/    # Composants React
├── hooks/         # Custom hooks
├── lib/           # Utilitaires et configurations
├── services/      # Appels API
└── types/         # Types TypeScript
```

### 2. Points d'entrée identifiés
- `src/app/layout.tsx` - Layout principal
- `src/app/page.tsx` - Page d'accueil
- `src/lib/db.ts` - Connexion base de données
- `src/services/api.ts` - Client API

### 3. Patterns découverts

| Pattern | Localisation | Usage |
|---------|--------------|-------|
| Server Components | `app/**/*.tsx` | Rendu côté serveur |
| Client Components | `components/**/*.tsx` | Interactivité |
| Custom Hooks | `hooks/use*.ts` | Logique réutilisable |
| Zod Validation | `lib/schemas/*.ts` | Validation des données |

### 4. Dépendances clés
```json
{
  "next": "14.x",
  "react": "18.x",
  "prisma": "5.x",
  "zod": "3.x",
  "tailwindcss": "3.x"
}
```

### 5. Conventions détectées
- Nommage: PascalCase pour composants, camelCase pour hooks
- Tests: `__tests__/` à côté des fichiers
- Styles: Tailwind CSS, pas de CSS modules

## Output final

```markdown
## Résumé de l'exploration

**Type de projet**: E-commerce Next.js 14
**Architecture**: App Router + Server Components
**Base de données**: PostgreSQL via Prisma
**Styling**: Tailwind CSS

### Fichiers clés à connaître
1. `src/app/layout.tsx` - Point d'entrée
2. `src/lib/db.ts` - Configuration Prisma
3. `src/services/api.ts` - Appels backend

### Prochaines étapes recommandées
- Lire `src/app/api/` pour comprendre les endpoints
- Explorer `src/components/` pour les composants UI
```



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
