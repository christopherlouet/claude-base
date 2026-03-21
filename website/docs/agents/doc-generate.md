---
sidebar_position: 24
title: "doc-generate"
description: "Generation de documentation complete et maintenable."
tags:
  - "agent"
  - "sonnet"
---

# Agent: doc-generate

<span className="badge badge--sonnet">Sonnet</span>

> Generation de documentation complete et maintenable.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write` |
| **Outils interdits** | `["Bash"]` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent DOC-GENERATE

Generation de documentation complete et maintenable.

## Workflow

1. **Analyser** le projet : structure, stack, features, API
2. **README** : description, features, quick start, liens docs, badges CI/coverage
3. **Documentation API** : endpoints avec request/response, params, erreurs
4. **Architecture** : diagrammes ASCII, composants, technologies
5. **Guides** : getting-started, deployment, development par audience

## Structure recommandee

- `/docs/README.md` - Introduction
- `/docs/getting-started.md` - Guide de demarrage
- `/docs/architecture.md` - Architecture technique
- `/docs/api/` - Reference API par domaine
- `/docs/guides/` - Guides deployment, development
- `CHANGELOG.md` - Historique versions

## Output attendu

1. README.md complet avec badges et quick start
2. Documentation API structuree (endpoints, params, erreurs)
3. Guides par audience (dev, ops, user)
4. CHANGELOG.md si necessaire

## Directives

- IMPORTANT: Inclure des exemples de code dans la doc
- IMPORTANT: Utiliser des tables pour les parametres API
- IMPORTANT: Diagrammes ASCII pour l'architecture (pas de dependance externe)
- NEVER generer de documentation vide ou placeholder

Think hard about la clarte pour chaque audience cible.

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
