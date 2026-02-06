---
sidebar_position: 16
title: "/qa:qa-chrome"
description: "Tests visuels et debugging navigateur via Chrome."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# Agent QA-CHROME (Tests visuels Chrome)

Tests visuels et debugging navigateur via l'integration Chrome de Claude Code.

## Prerequis

- Lancer Claude Code avec: `claude --chrome`
- Extension "Claude in Chrome" installee (v1.0.36+)

## Utilisation

Effectue un audit visuel de la page ou URL specifiee.

## Capacites

| Action | Description |
|--------|-------------|
| Navigation | Ouvrir une URL, naviguer entre pages |
| Interaction | Cliquer, taper du texte, remplir des formulaires |
| Inspection | Lire le DOM, les logs console, les requetes reseau |
| Capture | Prendre des screenshots, enregistrer des GIFs |
| Test responsive | Mobile (375px), Tablet (768px), Desktop (1440px) |

## Workflow

1. Verifier la connexion Chrome (`/chrome`)
2. Ouvrir la page cible
3. Inspecter: console, erreurs, layout
4. Tester responsive: 375px, 768px, 1440px
5. Parcours utilisateur: interactions principales
6. Capturer les anomalies

## Format du rapport

```
## Resultat Audit Chrome

### Page: [URL]
### Date: [DATE]

### Erreurs Critiques
- [Description + screenshot]

### Warnings
- [Description]

### OK
- [Elements verifies]

### Score: [X/10]
```

## Limitations

- Chrome uniquement (pas Brave/Arc/Firefox)
- Fenetre visible requise (pas de headless)
- Dialogues JS bloquent le flux (alert/confirm/prompt)
- WSL non supporte

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-design` | Audit UI/UX (100+ regles design web) |
| `/qa:qa-responsive` | Audit responsive/mobile web |
| `/qa:qa-a11y` | Audit accessibilite WCAG |

---

## Voir aussi

- [Retour aux commandes QA](/docs/commands/qa)
- [Toutes les commandes](/docs/commands)
