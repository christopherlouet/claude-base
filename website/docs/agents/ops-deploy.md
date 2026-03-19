---
sidebar_position: 41
title: "ops-deploy"
description: "Deploiement securise avec checklist pre-deploy obligatoire."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-deploy

<span className="badge badge--sonnet">Sonnet</span>

> Deploiement securise avec checklist pre-deploy obligatoire.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent OPS-DEPLOY

Deploiement securise avec validation pre-deploy obligatoire.

## Objectif

Deployer l'application en production de maniere securisee :
- Detection automatique de la stack et methode de deploy
- Checklist pre-deploiement obligatoire
- Verification post-deploy
- Commande de rollback proposee

## Workflow

1. **Detection** : identifier la stack et la methode de deploy (Docker, Vercel, VPS, serverless)
2. **Pre-flight checks** : executer la checklist de validation
3. **Build** : construire l'application
4. **Deploy** : deployer avec la methode appropriee
5. **Post-deploy** : verification de sante

## Checklist pre-deploiement

| # | Verification | Commande |
|---|-------------|----------|
| 1 | Tests passent | `npm test` / `pytest` / `go test` |
| 2 | Build reussit | `npm run build` / `docker build .` |
| 3 | Pas de secrets en dur | `grep -rn "password\|secret\|api_key" docker-compose*.yml` |
| 4 | Docker-compose est PROD | Verifier le fichier utilise |
| 5 | Env vars presentes | Verifier `.env.production` ou equivalent |
| 6 | Migrations DB a jour | `prisma migrate status` ou equivalent |
| 7 | Cookies/CSP pour HTTPS | `secure: true`, domaines prod dans CSP |
| 8 | Logs Docker limites | `max-size` et `max-file` configures |

## Post-deploy checks

| # | Verification | Commande |
|---|-------------|----------|
| 1 | Containers sains | `docker ps` |
| 2 | API repond | `curl -s -o /dev/null -w "%{http_code}" https://url/health` |
| 3 | Pas d'erreurs recentes | `docker logs --since 60s app` |
| 4 | Espace disque | `df -h` |

## Output attendu

1. Rapport pre-flight avec status par check
2. Commandes de deploiement executees
3. Rapport post-deploy avec verification de sante
4. Commande de rollback en cas de probleme

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
