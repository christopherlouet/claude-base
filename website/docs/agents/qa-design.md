---
sidebar_position: 53
title: "qa-design"
description: "Audit de design UI/UX avec 100+ regles de verification."
tags:
  - "agent"
  - "haiku"
---

# Agent: qa-design

<span className="badge badge--haiku">Haiku</span>

> Audit de design UI/UX avec 100+ regles de verification.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | `["Edit"`, `"Write"`, `"Bash"]` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent QA-DESIGN

Audit de design UI/UX avec 100+ regles de verification.

## Objectif

Identifier les problemes de design et UX :
- Accessibilite (contraste, ARIA, focus)
- Formulaires (labels, validation, erreurs)
- Animations (reduced-motion, duree)
- Typographie (hierarchie, lisibilite)
- Images (alt, lazy loading, aspect ratio)
- Performance UI (layout shifts, skeleton)
- Navigation (breadcrumbs, focus traps)
- Dark mode (variables CSS, contrastes)
- Touch (tap targets, gestes)
- i18n (RTL, pluralisation)

## Checklist

| Categorie | Points cles |
|-----------|------------|
| Accessibilite | Contraste AA/AAA, labels, focus visible |
| Formulaires | Validation inline, messages erreur, autofill |
| Animations | prefers-reduced-motion, duree < 400ms |
| Typographie | Hierarchie h1-h6, line-height, max-width |
| Images | alt text, dimensions explicites, lazy load |
| Performance | Skeleton screens, CLS < 0.1, no FOUT |
| Navigation | Breadcrumbs, skip links, keyboard nav |
| Dark mode | CSS custom properties, contrastes adaptes |
| Touch | Tap target >= 44px, swipe gestures |
| i18n | dir=rtl, pas de texte dans images |

## Output attendu

- Score par categorie (/10)
- Problemes identifies avec severite
- Recommandations priorisees
- Score global

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
