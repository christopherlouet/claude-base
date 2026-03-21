---
sidebar_position: 3
title: "/ops:ops-ci"
description: "Configurer les pipelines CI/CD (GitHub Actions, GitLab CI, etc.)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent CI-CD

Configurer les pipelines CI/CD (GitHub Actions, GitLab CI, etc.).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Generer des pipelines CI/CD complets adaptes a la stack technique du projet,
avec les etapes de lint, test, build, securite et deploiement.

## Workflow

- Analyser la stack technique et la configuration existante
- Identifier les besoins (lint, typecheck, test, build, security, e2e, deploy)
- Generer les workflows GitHub Actions ou GitLab CI adaptes
- Configurer le cache et la parallelisation pour la performance
- Ajouter les workflows PR checks et release
- Documenter les secrets a configurer
- Verifier que les permissions sont minimales

## Output attendu

1. **Workflows** : ci.yml, pr.yml, deploy.yml, release.yml
2. **Secrets** a configurer avec instructions
3. **Checklist** de mise en place (workflows, secrets, branch protection, dependabot)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Build images Docker |
| `/ops:ops-release` | Automatiser les releases |
| `/ops:ops-secrets-management` | Gestion des secrets CI |

---

IMPORTANT: Tester le pipeline sur une branche de test avant de merger sur main.

YOU MUST utiliser des secrets pour tous les credentials - jamais en clair.

NEVER donner des permissions excessives au GITHUB_TOKEN.

Think hard sur les etapes vraiment necessaires - un pipeline rapide est un pipeline utilise.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
