---
sidebar_position: 54
title: "qa-responsive"
description: "Audit de la conception responsive et de l'experience mobile."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-responsive

<span className="badge badge--haiku">Haiku</span>

> Audit de la conception responsive et de l'experience mobile.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent QA-RESPONSIVE

Audit de la conception responsive et de l'experience mobile.

## Objectif

Verifier que l'application s'adapte correctement a toutes les tailles d'ecran
et offre une bonne experience sur mobile.

## Breakpoints standards

| Nom | Largeur | Devices |
|-----|---------|---------|
| xs | < 576px | Mobiles portrait |
| sm | >= 576px | Mobiles paysage |
| md | >= 768px | Tablettes |
| lg | >= 992px | Laptops |
| xl | >= 1200px | Desktops |
| xxl | >= 1400px | Grands ecrans |

## Checklist Responsive

### 1. Meta viewport

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

### 2. Approche Mobile-First

- CSS de base pour mobile
- Media queries pour ecrans plus grands
- Progressive enhancement

### 3. Images responsives

- Attribut `srcset` pour differentes resolutions
- Attribut `sizes` pour indiquer les tailles
- Format WebP avec fallback
- Lazy loading (`loading="lazy"`)

### 4. Typographie fluide

- Unites relatives (rem, em, %)
- `clamp()` pour tailles fluides
- Ligne de lecture optimale (45-75 caracteres)

### 5. Grilles et layouts

- CSS Grid ou Flexbox
- Pas de largeurs fixes en pixels
- Conteneurs avec max-width

### 6. Navigation mobile

- Menu hamburger ou bottom nav
- Zone de touch minimum 44x44px
- Espacement suffisant entre elements cliquables

### 7. Formulaires

- Inputs suffisamment grands
- Labels toujours visibles
- Clavier adapte (type="email", type="tel")

## Patterns a rechercher

```
# Largeurs fixes problematiques
width:\s*\d+px(?!.*max-width)

# Absence de media queries
@media.*screen

# Images sans responsive
<img(?![^>]*srcset)

# Viewport mal configure
viewport.*user-scalable=no

# Touch targets trop petits
(width|height):\s*(1\d|2\d|3\d)px
```

## Points de verification

### Mobile (< 576px)
- [ ] Navigation accessible
- [ ] Texte lisible sans zoom
- [ ] Boutons facilement cliquables
- [ ] Formulaires utilisables
- [ ] Images bien dimensionnees
- [ ] Pas de scroll horizontal

### Tablette (768px - 992px)
- [ ] Layout adapte (2-3 colonnes max)
- [ ] Navigation appropriee
- [ ] Espacement coherent

### Desktop (> 992px)
- [ ] Utilisation efficace de l'espace
- [ ] Contenus centres avec max-width
- [ ] Hover states presents

## Output attendu

### Resume

```
Audit Responsive
================
Score global: [X/100]

Mobile  : [OK/PROBLEMES]
Tablette: [OK/PROBLEMES]
Desktop : [OK/PROBLEMES]
```

### Problemes identifies

| Breakpoint | Fichier | Probleme | Solution |
|------------|---------|----------|----------|
| Mobile | Header.tsx | Menu non accessible | Ajouter hamburger menu |
| Tablette | Grid.css | Colonnes trop etroites | Ajuster grid-template |

### Bonnes pratiques manquantes

| Pratique | Statut | Impact |
|----------|--------|--------|
| Mobile-first CSS | [ ] | Eleve |
| Images srcset | [ ] | Moyen |
| Touch targets 44px | [ ] | Eleve |
| Viewport meta | [x] | Critique |

### Recommandations

1. **Priorite haute**
   - [Action 1]
   - [Action 2]

2. **Priorite moyenne**
   - [Action 3]

## Contraintes

- Verifier tous les breakpoints principaux
- Tester l'orientation portrait ET paysage
- Verifier les interactions tactiles
- S'assurer de l'absence de scroll horizontal

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
