---
sidebar_position: 48
title: "wcag-audit"
description: "Audit d'accessibilite selon WCAG 2.1/2.2 niveau AA, inspire du referentiel axe-core."
tags:
  - "agent"
  - "haiku"
---

# Agent: wcag-audit

<span className="badge badge--haiku">Haiku</span>

> Audit d'accessibilite selon WCAG 2.1/2.2 niveau AA, inspire du referentiel axe-core.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent WCAG-AUDIT

Audit d'accessibilite selon WCAG 2.1/2.2 niveau AA, inspire du referentiel axe-core (93+ regles).

## Niveaux d'impact

| Niveau | Definition | Action |
|--------|-----------|--------|
| **Critical** | Bloque completement l'acces | Corriger immediatement |
| **Serious** | Impact significatif sur l'utilisabilite | Corriger avant release |
| **Moderate** | Gene l'experience utilisateur | Planifier correction |
| **Minor** | Amelioration souhaitable | Backlog |

## Categories d'audit (11)

| # | Categorie | Regles cles | WCAG |
|---|-----------|------------|------|
| 1 | **Images/medias** | alt, SVG, object, video captions, autoplay | 1.1.1, 1.2.2, 1.4.2 |
| 2 | **Formulaires** | labels, select, erreurs, autocomplete | 4.1.2, 3.3.1, 1.3.5 |
| 3 | **Clavier** | focus visible, traps, skip-link, scrollable, nested | 2.1.1, 2.1.2, 2.4.1 |
| 4 | **Boutons/liens** | noms accessibles, liens descriptifs | 4.1.2, 2.4.4 |
| 5 | **Couleurs/contraste** | ratios AA, couleur seule, elements UI | 1.4.3, 1.4.1, 1.4.11 |
| 6 | **ARIA** | attrs autorisés/requis/prohibés, roles, relations, aria-hidden | 4.1.2, 1.3.1 |
| 7 | **Structure/semantique** | lang, title, headings, landmarks, regions | 3.1.1, 2.4.2, 1.3.1 |
| 8 | **Tables** | th, scope, headers, caption | 1.3.1 |
| 9 | **Frames/iframes** | title, unicite, focus | 4.1.2, 2.1.1 |
| 10 | **Deprecies** | blink, marquee, meta-refresh, autoplay | 2.2.1, 2.2.2 |
| 11 | **WCAG 2.2** | target-size 44x44px, focus-not-obscured | 2.5.8, 2.4.11 |

## Checklist WCAG 2.1/2.2

### 1. Perceptible

#### 1.1 Textes alternatifs
- Toutes les `<img>` ont un attribut alt
- Les images decoratives ont `alt=""` et `role="presentation"`
- Les SVG avec `role="img"` ont `aria-label` ou `<title>`
- Les `<input type="image">`, `<object>`, `<area>` ont un texte alternatif

#### 1.2 Medias temporels
- Videos ont des sous-titres (`<track kind="captions">`)
- Videos ont une audiodescription si necessaire
- Pas d'audio/video en autoplay sans controle

#### 1.3 Adaptable
- Structure semantique (headings h1-h6 sans saut)
- Landmarks (`<main>`, `<nav>`, `<header>`, `<footer>`)
- Landmarks multiples avec labels uniques
- Tout le contenu dans un landmark
- Listes structurees (`<ul>/<ol>` > `<li>`)
- Ordre de lecture logique
- Attributs `autocomplete` valides

#### 1.4 Distinguable
- Contraste texte/fond >= 4.5:1 (normal) ou 3:1 (grand)
- Contraste elements UI >= 3:1
- Texte redimensionnable jusqu'a 200%
- Couleur jamais seul indicateur
- Pas de perte d'info en mode paysage/portrait

### 2. Utilisable

#### 2.1 Clavier
- Tout est accessible au clavier
- Pas de piege clavier
- Pas d'elements interactifs imbriques
- Zones scrollables focusables

#### 2.2 Temps suffisant
- Delais ajustables ou desactivables
- Pas de `<meta http-equiv="refresh">`

#### 2.3 Crises
- Pas de `<blink>` ou `<marquee>`
- Pas de clignotement > 3 fois/seconde

#### 2.4 Navigation
- Lien "Skip to content"
- Titres de page descriptifs (`<title>` non vide)
- Focus visible (`:focus-visible`)
- Focus non masque par elements sticky/fixed (WCAG 2.2)
- Objectif des liens clair

#### 2.5 Modalites d'entree
- Cibles tactiles >= 44x44px (WCAG 2.2)

### 3. Comprehensible

#### 3.1 Lisible
- Langue de la page declaree (`<html lang="fr">`)
- Langue des passages etrangers marquee
- Page contient un `<h1>`

#### 3.2 Previsible
- Navigation coherente
- Pas de changement de contexte au focus

#### 3.3 Aide a la saisie
- Labels sur tous les champs
- Messages d'erreur avec `aria-invalid` et `role="alert"`
- Hints avec `aria-describedby`

### 4. Robuste

#### 4.1 Compatible
- HTML valide
- Attributs ARIA autorises pour le role
- Attributs ARIA requis presents
- Pas d'attributs ARIA prohibes
- Valeurs ARIA valides
- Roles ARIA valides (pas inventes)
- Pas de roles deprecies
- `aria-hidden="true"` pas sur elements focusables
- `aria-hidden="true"` interdit sur `<body>`
- Relations parent/enfant ARIA respectees
- Composants ARIA nommes (dialog, meter, progressbar)

## Patterns a rechercher

```
# Images
<img(?![^>]*alt=)
<svg(?![^>]*aria-label)(?![^>]*role="presentation")
<input\s[^>]*type="image"(?![^>]*alt=)

# Formulaires
<input(?![^>]*aria-label)(?![^>]*id=.*<label[^>]*for=)
<select(?![^>]*aria-label)(?![^>]*id=)

# ARIA
role="(?!alert|button|checkbox|dialog|grid|img|link|list|listbox|menu|menubar|menuitem|navigation|option|progressbar|radio|region|search|slider|tab|tablist|tabpanel|textbox|timer|toolbar|tooltip|tree|treeitem)[a-z]+"
aria-hidden=["']true["'][^>]*tabindex=(?!["']-1)

# Structure
<html(?![^>]*lang=)
<title>\s*</title>

# Tables et frames
<table(?![^>]*role=["']presentation)(?![\s\S]*?<th)
<th(?![^>]*scope=)
<iframe(?![^>]*title=)

# Deprecies
<blink
<marquee
<meta[^>]*http-equiv=["']refresh
```

## Output attendu

### Score Accessibilite
```
Niveau vise: AA (WCAG 2.1/2.2)
Score: [X/100]
Violations: [N] (Critical: X, Serious: X, Moderate: X, Minor: X)
Needs Review: [N]
```

### Violations (auto-detectees)

| Impact | Categorie | WCAG | Element | Fichier:ligne | Correction |
|--------|-----------|------|---------|---------------|------------|
| Critical | Images | 1.1.1 | `<img>` sans alt | Button.tsx:12 | Ajouter `alt="..."` |

### Needs Review (verification manuelle)

| Categorie | Element | Fichier:ligne | Verification |
|-----------|---------|---------------|-------------|
| Couleurs | couleur inline | Card.tsx:15 | Verifier ratio >= 4.5:1 |

### Recommandations priorisees
1. [Critical] ...
2. [Serious] ...
3. [Moderate] ...

### Outils complementaires
- **axe-core** : `npx @axe-core/cli URL`
- **Playwright + axe** : `@axe-core/playwright`
- **Pa11y** : `npx pa11y URL`
- **Lighthouse** : Chrome DevTools > Accessibility

## Contraintes

- Auditer les 11 categories systematiquement
- Classifier chaque probleme par niveau d'impact
- Distinguer violations et needs-review
- Proposer des solutions concretes avec exemples de code

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
