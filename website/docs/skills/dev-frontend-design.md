---
sidebar_position: 11
title: "dev-frontend-design"
description: "Design UI distinctif avec direction artistique forte. Declencher quand l'utilisateur veut creer une interface, une landing page, un composant visuel, ou quand on detecte la creation de code frontend sans direction design definie."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-frontend-design

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Design UI distinctif avec direction artistique forte. Declencher quand l'utilisateur veut creer une interface, une landing page, un composant visuel, ou quand on detecte la creation de code frontend sans direction design definie.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `frontend`, `design`, `parce que c'est joli`, `parce que c'est safe` |

## Description detaillee

# Frontend Design avec Direction Artistique

## Principe

Les interfaces generees par IA se ressemblent toutes. Typographie Inter/Roboto, palette bleu/violet, cards arrondies, meme rythme visuel. Pour sortir du lot, il faut **s'engager sur une direction artistique avant d'ecrire du code**.

## Workflow obligatoire

### 1. Verifier la direction dans CLAUDE.md

Lire le CLAUDE.md du projet pour trouver une directive `Style:` :

```markdown
## Design Direction
Style: terminal    # ou cockpit, vitality, editorial, glass, signal
```

Si trouve, appliquer strictement la direction (voir rule `.claude/rules/design-style.md`).

### 2. Si aucune direction definie — DEMANDER

Avant de coder, poser la question a l'utilisateur :

> Aucune direction artistique n'est definie dans CLAUDE.md. Avant de coder, choisis une direction :
>
> - **terminal** : monospace, noir/vert neon, sharp edges (pour outils dev, CLI web)
> - **cockpit** : dense, multi-panels, indicateurs temps reel (pour dashboards, monitoring)
> - **vitality** : colore, anime, arrondi genereux (pour apps B2C, gamifiees)
> - **editorial** : serif, aere, papier/ivoire (pour blogs, long form)
> - **glass** : glassmorphism, gradients, depth (pour apps moderne premium)
> - **signal** : minimal, gris/blanc, dense utilitaire (pour outils productivite)

## Fonts — ce qu'il faut bannir

**Interdit** (overused par l'IA) :
- Inter, Roboto, Arial, Space Grotesk
- Helvetica (sauf direction editorial explicite)

**Preferer** selon la direction :

| Direction | Fonts recommandees |
|-----------|-------------------|
| terminal | JetBrains Mono, Fira Code, IBM Plex Mono, Berkeley Mono |
| cockpit | DM Sans, Geist, IBM Plex Sans + Geist Mono pour les chiffres |
| vitality | Nunito, Plus Jakarta Sans, Bricolage Grotesque, Instrument Serif |
| editorial | Playfair Display, Lora, Merriweather, Fraunces + Inter-like sans-serif |
| glass | Geist, SF Pro, Neue Haas Grotesk |
| signal | Geist Mono, IBM Plex Mono, system-ui |

IMPORTANT: Si aucune direction n'est choisie et que l'utilisateur refuse d'en choisir une, utiliser **Geist** (neutre moderne) mais JAMAIS Inter/Roboto.

## Couleurs — proscrire le generique

**Patterns a eviter** :
- Palette bleu/violet IA-stereotype (#6366f1, #8b5cf6, gradients)
- Pastels mous sans contraste
- Gris neutres type Tailwind defaut

**Preferer** :

| Direction | Palette type |
|-----------|-------------|
| terminal | `#0a0a0a` + un seul accent neon (`#00ff9c`, `#00d8ff`, `#ffb000`) |
| cockpit | Dark stratifie (`#0d1117`, `#161b22`) + couleurs fonctionnelles (alerte rouge, OK vert) |
| vitality | 3-4 couleurs vives distinctes (ex: `#ff6b35`, `#004e89`, `#ffd23f`), fond clair |
| editorial | Noir/blanc/creme + 1 accent (rouge coquelicot, bleu nuit, vert mousse) |
| glass | Fond gradient ou image + surfaces `rgba` semi-transparentes |
| signal | Gris/blanc uniquement + couleurs strictement signaletiques |

## Radius — signer la personnalite

| Direction | Radius |
|-----------|--------|
| terminal, editorial | 0-4px (sharp) |
| cockpit, signal | 4-6px (subtil) |
| glass | 12-16px (fluide) |
| vitality | 12-16px (genereux) |

IMPORTANT: Ne PAS utiliser `rounded-xl` / `rounded-2xl` par defaut "parce que c'est joli". Le radius est une signature.

## Animations — rejeter le defaut

**A eviter** :
- Transitions lineaires `transition-all duration-300`
- Hover avec scale `1.05` generique

**Preferer** :

| Direction | Style animation |
|-----------|----------------|
| terminal | Caret blink, scanlines, glow pulse (100-150ms, step easing) |
| cockpit | Transitions instantanees, pulse sur indicateurs, fade pour updates |
| vitality | Spring/bounce subtil, progress fluides, celebratory feedback |
| editorial | Fade-in au scroll (300-500ms, ease-out), transitions douces |
| glass | Blur transitions, fade avec depth, parallax subtil |
| signal | Quasi-absentes (50-100ms), feedback immediat |

## Layout — briser la grille IA

**Patterns a eviter** :
- Hero centre + 3 cards en grid + CTA + footer
- Sections successives pleine largeur identiques
- Padding uniforme partout

**Preferer** :
- Asymetrie intentionnelle
- Densites variables selon les zones (dense/aere)
- Grilles non alignees sur colonnes uniformes
- Whitespace strategique (editorial) ou densite max (cockpit, signal)

## Checklist avant ecriture de code

- [ ] Direction artistique identifiee et validee avec l'utilisateur
- [ ] Fonts choisies (pas Inter/Roboto/Arial par defaut)
- [ ] Palette definie (pas bleu/violet IA-stereotype)
- [ ] Radius coherent avec la direction
- [ ] Animations coherentes avec la direction
- [ ] Layout non-stereotype (pas hero/grid/CTA auto)

## Output attendu

1. **Confirmation** de la direction choisie
2. **Tokens design** : fonts, couleurs, radius, spacing (CSS custom properties ou theme Tailwind)
3. **Composants** respectant strictement la direction
4. **Pas de fallback generique** — si la direction est choisie, la suivre integralement

## Regles

IMPORTANT: NEVER coder du frontend sans avoir confirme la direction artistique.

IMPORTANT: NEVER utiliser Inter, Roboto, Arial, Space Grotesk par defaut.

IMPORTANT: NEVER proposer un hero centre + grid 3-cards "parce que c'est safe".

YOU MUST lire `.claude/rules/design-style.md` pour les details par direction.

YOU MUST expliquer a l'utilisateur le POURQUOI des choix design (engagement artistique > neutralite).

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux frontend..."_
- _"Je veux design..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
