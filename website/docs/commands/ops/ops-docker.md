---
sidebar_position: 10
title: "/ops:ops-docker"
description: "Dockerisation et containerisation de projets."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent DOCKER

Dockerisation et containerisation de projets.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Generer des Dockerfiles optimises, docker-compose et .dockerignore
adaptes a la stack technique du projet, avec multi-stage builds et securite.

## Workflow

- Detecter la stack technique du projet (Node.js, Python, Go, React, etc.)
- Generer un Dockerfile multi-stage optimise (build + production)
- Creer un docker-compose.yml avec services, volumes et networks
- Configurer le .dockerignore
- Appliquer les bonnes pratiques securite (non-root user, pas de secrets dans l'image)
- Configurer les healthchecks
- Optimiser l'ordre des layers pour le cache

## Output attendu

1. **Dockerfile** : image de production optimisee
2. **docker-compose.yml** : orchestration multi-containers
3. **.dockerignore** : exclusions configurees
4. **Informations** : taille estimee, commandes build/run

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD avec Docker |
| `/ops:ops-env` | Gestion des environnements |
| `/ops:ops-monitoring` | Monitoring des containers |

---

IMPORTANT: Toujours utiliser des tags specifiques pour les images de base (pas latest).

YOU MUST scanner l'image pour les vulnerabilites avant deploiement.

NEVER inclure de secrets ou credentials dans l'image Docker.

NEVER utiliser root en production.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
