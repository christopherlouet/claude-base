---
sidebar_position: 34
title: "/ops:ops-vercel"
description: "Deploiement et configuration sur Vercel."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-VERCEL

Deploiement et configuration sur Vercel.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Configurer un projet sur Vercel avec variables d'environnement,
serverless functions, edge middleware, cron jobs et optimisations.

## Workflow

- Configurer vercel.json (framework, build, functions, crons, headers, redirects)
- Gerer les variables d'environnement par scope (production, preview, development)
- Implementer les Edge Functions et Middleware si necessaire
- Configurer les API Routes (App Router)
- Proteger les endpoints cron avec un secret
- Ajouter les headers de securite et les optimisations (ISR, images)
- Configurer les domaines et DNS
- Integrer Speed Insights et Analytics

## Output attendu

1. **vercel.json** configure
2. **Variables d'environnement** par scope
3. **Functions et Crons** configures
4. **Commandes** CLI essentielles (deploy, logs, rollback)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD |
| `/ops:ops-monitoring` | Observabilite |
| `/ops:ops-env` | Gestion environnements |

---

IMPORTANT: Utiliser Edge Functions pour les operations rapides (&lt; 25ms).

IMPORTANT: Configurer les headers de securite.

YOU MUST proteger les endpoints cron avec un secret.

NEVER commiter les variables d'environnement.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
