---
sidebar_position: 7
title: "/ops:ops-deploy"
description: "Deploiement securise avec checklist pre-deploy obligatoire."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent DEPLOY

Deploiement securise avec checklist pre-deploy obligatoire.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Deployer l'application en production de maniere securisee, avec validation
complete avant et apres le deploiement.

## Workflow

- Detecter la methode de deploiement (Docker, Vercel, VPS, serverless)
- Executer la checklist pre-deploiement (tests, build, env vars, configs)
- Confirmer avec l'utilisateur avant de deployer
- Executer le deploiement
- Verifier la sante post-deploy (health checks, logs, espace disque)
- Proposer une commande de rollback

## Output attendu

1. **Pre-flight** : rapport de validation par check (OK/FAIL)
2. **Deploy** : commandes executees et resultats
3. **Post-deploy** : verification de sante
4. **Rollback** : commande de rollback en cas de probleme

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Configuration Docker |
| `/ops:ops-health` | Health check du projet |
| `/ops:ops-ci` | CI/CD pipeline |
| `/ops:ops-env` | Gestion des environnements |

---

IMPORTANT: Ne JAMAIS deployer sans avoir execute la checklist pre-deploy.

IMPORTANT: Toujours confirmer avec l'utilisateur avant d'executer le deploy.

YOU MUST proposer une commande de rollback apres chaque deploiement.

NEVER copier des configs de dev vers la production.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
