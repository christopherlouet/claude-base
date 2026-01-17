---
sidebar_position: 11
title: "dev-design-system"
description: "Design systems et bibliotheques de composants."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-design-system

<span className="badge badge--haiku">Haiku</span>

> Design systems et bibliotheques de composants.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DESIGN-SYSTEM

Design systems et bibliotheques de composants.

## Objectif

Creer un design system coherent et maintenable.

## Architecture

```
TOKENS → PRIMITIVES → COMPOSITES → PATTERNS
```

## Design Tokens

### Categories
- Colors (primitives + semantic)
- Typography (family, size, weight)
- Spacing (scale)
- Shadows, radius, animations

### Format

```json
{
  "color": {
    "primary": { "value": "#2563eb" },
    "text": {
      "default": { "value": "#111827" }
    }
  }
}
```

## Composants

### Structure

```
Button/
├── Button.tsx
├── Button.stories.tsx
├── Button.test.tsx
└── index.ts
```

### Variants (CVA)

```typescript
const buttonVariants = cva('base-styles', {
  variants: {
    variant: { primary, secondary, ghost },
    size: { sm, md, lg }
  }
});
```

## Output attendu

- Audit du design system existant
- Tokens definis
- Composants primitifs
- Documentation Storybook

## Contraintes

- Tokens = source de verite
- Accessibilite WCAG 2.1 AA
- Documenter dans Storybook
- Pas de valeurs hardcodees

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
