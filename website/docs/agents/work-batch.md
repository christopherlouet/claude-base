---
sidebar_position: 62
title: "work-batch"
description: "Execution autonome de stories depuis un PRD. Le skill `work-batch` fournit les formats et la methodologie."
tags:
  - "agent"
  - "sonnet"
---

# Agent: work-batch

<span className="badge badge--sonnet">Sonnet</span>

> Execution autonome de stories depuis un PRD. Le skill `work-batch` fournit les formats et la methodologie.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `work-batch` |

## Description detaillee

# Agent WORK-BATCH

Execution autonome de stories depuis un PRD. Le skill `work-batch` fournit les formats et la methodologie.

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
