---
sidebar_position: 42
title: "qa-chrome"
description: "Tests visuels et debugging navigateur via Chrome. Utiliser pour tester des pages web, vérifier le rendu visuel, débuguer avec la console, ou automatiser des actions navigateur."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-chrome

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Tests visuels et debugging navigateur via Chrome. Utiliser pour tester des pages web, verifier le rendu visuel, debuguer avec la console, ou automatiser des actions navigateur.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Bash`, `Grep`, `Glob` |
| **Mots-cles** | `Chrome`, `test visuel`, `navigateur`, `console browser`, `DOM`, `screenshot`, `GIF` |

## Description detaillee

# Tests Visuels et Debugging Chrome

## Prerequis

- Claude Code lance avec `--chrome` flag
- Extension "Claude in Chrome" installee (v1.0.36+)
- Google Chrome ouvert

## Capabilities

| Action | Description |
|--------|-------------|
| Navigation | Ouvrir une URL, naviguer entre pages |
| Interaction | Cliquer, taper du texte, remplir des formulaires |
| Inspection | Lire le DOM, les logs console, les requetes reseau |
| Capture | Prendre des screenshots, enregistrer des GIFs |
| Test | Verifier le rendu, tester des parcours utilisateur |

## Workflows de test

### Test visuel d'une page
1. Ouvrir la page dans Chrome
2. Verifier le rendu visuel (layout, couleurs, typographie)
3. Tester le responsive (redimensionner la fenetre)
4. Capturer un screenshot pour reference

### Debugging console
1. Ouvrir la page
2. Lire les erreurs console
3. Identifier la source des erreurs dans le code
4. Proposer des corrections

### Test de parcours utilisateur
1. Naviguer vers le point de depart
2. Suivre le parcours pas a pas (clic, saisie, navigation)
3. Verifier chaque etape
4. Reporter les anomalies

## Checklist de verification

- [ ] Page charge sans erreur console
- [ ] Layout correct (pas de overflow, pas de chevauchement)
- [ ] Textes lisibles (contraste, taille)
- [ ] Images chargees
- [ ] Liens fonctionnels
- [ ] Formulaires remplissables
- [ ] Responsive OK (mobile, tablet, desktop)
- [ ] Pas d'erreur reseau (404, 500)

## Limitations

- Necessite Chrome (pas Brave, Arc, ou Firefox)
- Fenetre Chrome visible requise (pas de headless)
- Les dialogues JavaScript (alert, confirm) bloquent le flux
- WSL non supporte

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux Chrome..."_
- _"Je veux test visuel..."_
- _"Je veux screenshot..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
