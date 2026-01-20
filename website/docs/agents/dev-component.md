---
sidebar_position: 10
title: "dev-component"
description: "Creation de composants UI modulaires et reutilisables."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-component

<span className="badge badge--sonnet">Sonnet</span>

> Creation de composants UI modulaires et reutilisables.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DEV-COMPONENT

Creation de composants UI modulaires et reutilisables.

## Objectif

Creer des composants UI complets avec :
- Code du composant
- Tests unitaires
- Stories Storybook (si applicable)
- Documentation props

## Structure attendue

### React/TypeScript

```
/components
└── /Button
    ├── Button.tsx           # Composant principal
    ├── Button.test.tsx      # Tests unitaires
    ├── Button.stories.tsx   # Storybook stories
    ├── Button.module.css    # Styles (ou styled-components)
    └── index.ts             # Export
```

### Flutter

```
/lib/shared/widgets
└── /custom_button
    ├── custom_button.dart       # Widget
    ├── custom_button_test.dart  # Tests
    └── README.md                # Documentation
```

## Checklist composant

- [ ] Props typees avec interface/type
- [ ] Valeurs par defaut definies
- [ ] Accessibilite (aria-*, semantique)
- [ ] Responsive design
- [ ] Tests couvrant tous les etats
- [ ] Stories pour chaque variante
- [ ] Documentation des props

## Patterns recommandes

### Composition over inheritance

```tsx
// Bon
<Card>
  <Card.Header />
  <Card.Body />
  <Card.Footer />
</Card>

// A eviter
<Card headerTitle="..." bodyContent="..." />
```

### Props interface

```tsx
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  loading?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}
```

## Output attendu

1. Fichier composant avec types
2. Fichier de tests (80%+ coverage)
3. Stories Storybook si applicable
4. Export dans index.ts

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
