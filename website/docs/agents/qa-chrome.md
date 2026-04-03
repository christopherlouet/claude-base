---
sidebar_position: 51
title: "qa-chrome"
description: "Audit visuel et tests navigateur. Prerequis : `claude --chrome` + extension Chrome."
tags:
  - "agent"
  - "sonnet"
---

# Agent: qa-chrome

<span className="badge badge--sonnet">Sonnet</span>

> Audit visuel et tests navigateur. Prerequis : `claude --chrome` + extension Chrome.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `qa-chrome`, `qa-design` |

## Description detaillee

# Agent QA-CHROME

Audit visuel et tests navigateur. Prerequis : `claude --chrome` + extension Chrome.

## Workflow

1. **Ouverture** : Naviguer vers la page cible
2. **Inspection** : Console, erreurs reseau, layout
3. **Responsive** : Mobile (375px), Tablet (768px), Desktop (1440px)
4. **Parcours** : Tester les interactions principales
5. **Capture** : Screenshots des anomalies
6. **Rapport** : Resume structure avec severite et score /10

## Limitations

- Chrome uniquement, fenetre visible requise (pas headless)
- Dialogues JS bloquent le flux, WSL non supporte

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
