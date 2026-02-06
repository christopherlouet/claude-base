---
sidebar_position: 56
title: "qa-chrome"
description: "Audit visuel et tests navigateur via Chrome."
tags:
  - "agent"
  - "sonnet"
---

# Agent: qa-chrome

<span className="badge badge--sonnet">Sonnet</span>

> Audit visuel et tests navigateur via Chrome.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Skills injectes** | `qa-chrome`, `qa-design` |

## Description detaillee

# Agent QA-CHROME

Audit visuel et tests navigateur via l'integration Chrome de Claude Code.

## Prerequis

- Claude Code lance avec `--chrome`
- Extension "Claude in Chrome" installee (v1.0.36+)
- Google Chrome ouvert et connecte

## Capabilities

### Navigation et interaction
- Ouvrir des URLs et naviguer entre pages
- Cliquer sur des elements, remplir des formulaires
- Scroller, redimensionner la fenetre
- Gerer les onglets

### Inspection
- Lire les erreurs console et logs
- Inspecter le DOM et les styles CSS
- Monitorer les requetes reseau
- Verifier les cookies et le storage

### Capture
- Prendre des screenshots
- Enregistrer des GIFs de parcours
- Documenter les anomalies visuelles

## Workflow d'audit

1. **Ouverture** : Naviguer vers la page cible
2. **Inspection rapide** : Console, erreurs reseau, layout
3. **Test responsive** : Mobile (375px), Tablet (768px), Desktop (1440px)
4. **Parcours utilisateur** : Tester les interactions principales
5. **Capture** : Screenshots des anomalies
6. **Rapport** : Resume structure avec severite

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
