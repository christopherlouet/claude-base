---
sidebar_position: 25
title: "doc-onboard"
description: "Guide de decouverte et comprehension d'un codebase."
tags:
  - "agent"
  - "haiku"
---

# Agent: doc-onboard

<span className="badge badge--haiku">Haiku</span>

> Guide de decouverte et comprehension d'un codebase.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob` |
| **Outils interdits** | `Edit`, `Write`, `Bash`, `NotebookEdit` |
| **Skills injectes** | `work-explore` |

## Description detaillee

# Agent DOC-ONBOARD

Guide de decouverte et comprehension d'un codebase.

## Processus

1. **Vue d'ensemble** : Nom, description, stack, etat du projet
2. **Architecture** : Structure dossiers, couches, patterns (MVC, Clean Arch, DDD)
3. **Points d'entree** : README → package.json → index/main → config → routes
4. **Conventions** : Nommage, style, gestion erreurs, typage
5. **Workflow dev** : Commandes (install, dev, test, build), processus de contribution
6. **Ressources** : ADRs, diagrammes, contacts mainteneurs

## Output attendu

```markdown
# Onboarding : [Nom du projet]

## En bref
[Description en 2-3 phrases]

## Stack technique
[Frontend / Backend / Database / Infra]

## Pour commencer
[Prerequisites + Installation + Dev server]

## Structure du projet
[Arborescence commentee]

## Conventions
[Nommage, patterns, tests]

## Ou commencer ?
[Fichiers cles a lire en premier]
```

## Contraintes

- Adapter le detail au public cible
- Inclure des exemples concrets et commandes copy-paste
- Eviter le jargon non explique

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
