---
sidebar_position: 32
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
`<arguments>`

## Objectif

Deployer l'application en production de maniere securisee, avec validation
complete avant et apres le deploiement.

---

## Workflow

1. **Detection** : identifier la stack et la methode de deploy (Docker, Vercel, VPS, serverless)
2. **Pre-flight checks** : executer la checklist de validation
3. **Build** : construire l'application
4. **Deploy** : deployer avec la methode appropriee
5. **Post-deploy** : verification de sante

---

## Checklist pre-deploiement (obligatoire)

| # | Verification | Commande | Bloquant |
|---|-------------|----------|----------|
| 1 | Tests passent | `npm test` / `pytest` / `go test` | Oui |
| 2 | Build reussit | `npm run build` / `docker build .` | Oui |
| 3 | Pas de secrets en dur | `grep -rn "password\|secret\|api_key" docker-compose*.yml` | Oui |
| 4 | Docker-compose est PROD | Verifier le fichier utilise | Oui |
| 5 | Env vars presentes | Verifier `.env.production` ou equivalent | Oui |
| 6 | Migrations DB a jour | `prisma migrate status` ou equivalent | Oui |
| 7 | Cookies/CSP pour HTTPS | `secure: true`, domaines prod dans CSP | Oui |
| 8 | Logs Docker limites | `max-size` et `max-file` configures | Oui |

---

## Post-deploy checks

| # | Verification | Commande |
|---|-------------|----------|
| 1 | Containers sains | `docker ps` -- tous UP avec healthcheck |
| 2 | API repond | `curl -s -o /dev/null -w "%{http_code}" https://url/health` |
| 3 | Pas d'erreurs recentes | `docker logs --since 60s app 2>&1 \| grep -i error` |
| 4 | Espace disque | `df -h` -- pas de saturation |

---

## Output attendu

### Fichiers et rapports

1. **Pre-flight** : rapport de validation par check (OK/FAIL)
2. **Deploy** : commandes executees et resultats
3. **Post-deploy** : verification de sante
4. **Rollback** : commande de rollback en cas de probleme

### Exemple de rapport pre-flight

```
=== PRE-FLIGHT CHECKS ===
[OK]   Tests passent (42 passing, 0 failing)
[OK]   Build reussit (docker build . -> success)
[OK]   Pas de secrets en dur
[OK]   Docker-compose PROD verifie
[FAIL] Env vars manquantes: SMTP_PASSWORD
[OK]   Migrations DB a jour
[OK]   Cookies secure: true
[OK]   Logs Docker limites

Resultat: 1 FAIL -- deploiement bloque
```

### Exemple de commande de rollback

```bash
# Rollback vers la version precedente
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --force-recreate
```

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops:ops-docker` | Configuration Docker |
| `/ops:ops-health` | Health check du projet |
| `/ops:ops-ci` | CI/CD pipeline |
| `/ops:ops-env` | Gestion des environnements |
| `/ops:ops-rollback` | Procedure de rollback |
| `/ops:ops-secrets-management` | Gestion des secrets |

---

IMPORTANT: Ne JAMAIS deployer sans avoir execute la checklist pre-deploy.

IMPORTANT: Toujours confirmer avec l'utilisateur avant d'executer le deploy.

YOU MUST proposer une commande de rollback apres chaque deploiement.

NEVER copier des configs de dev vers la production.

NEVER deployer si les tests echouent.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
