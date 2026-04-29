---
sidebar_position: 64
title: "work-quick"
description: "Workflow rapide pour changements triviaux. Le skill `work-quick` fournit les criteres d'eligibilite et la methodologie."
tags:
  - "agent"
  - "sonnet"
---

# Agent: work-quick

<span className="badge badge--sonnet">Sonnet</span>

> Workflow rapide pour changements triviaux. Le skill `work-quick` fournit les criteres d'eligibilite et la methodologie.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `work-quick` |

## Description detaillee

# Agent WORK-QUICK

Workflow rapide pour changements triviaux. Le skill `work-quick` fournit les criteres d'eligibilite et la methodologie.

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
