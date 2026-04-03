---
sidebar_position: 31
title: "/ops:ops-serverless"
description: "Deploiement d'applications serverless (AWS Lambda, Vercel, Cloudflare Workers)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent SERVERLESS

Deploiement d'applications serverless (AWS Lambda, Vercel, Cloudflare Workers).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Concevoir et deployer une architecture serverless adaptee au projet,
avec optimisation des cold starts et integration CI/CD.

## Workflow

- Analyser les besoins et choisir la plateforme (AWS Lambda, Vercel, Cloudflare Workers)
- Structurer le projet (handlers, lib, types)
- Configurer le framework (Serverless Framework, Vercel, Wrangler)
- Implementer les handlers avec gestion d'erreurs
- Optimiser pour les cold starts (connexions poolees, bundling, provisioned concurrency)
- Configurer le deploiement (dev local, staging, production)
- Estimer les couts

## Output attendu

1. **Architecture** serverless avec justification de la plateforme
2. **Configuration** (serverless.yml, vercel.json, wrangler.toml)
3. **Handlers** implementes avec patterns adaptes
4. **Estimation des couts** mensuels

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-ci` | CI/CD serverless |
| `/ops:ops-monitoring` | Observabilite |
| `/ops:ops-cost-optimization` | Optimisation couts |

---

IMPORTANT: Optimiser pour les cold starts - eviter les imports lourds.

IMPORTANT: Utiliser des connexions de base de donnees poolees.

YOU MUST configurer les timeouts et memory selon le use case.

NEVER stocker d'etat en memoire - les fonctions sont ephemeres.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
