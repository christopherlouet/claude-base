---
sidebar_position: 5
title: "deploy-safety"
description: "Chaque deploiement doit etre valide avant execution. Ne jamais deployer de config dev en production."
tags:
  - "rule"
  - "deploy-safety"
---

# Regles: deploy-safety

> Chaque deploiement doit etre valide avant execution. Ne jamais deployer de config dev en production.

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/docker-compose*.yml`
- `**/docker-compose*.yaml`
- `**/Dockerfile*`
- `**/deploy*`
- `**/scripts/deploy*`
- `**/.env*`
- `**/nginx*`

## Regles detaillees

# Deploy Safety

## Principe

Chaque deploiement doit etre valide avant execution. Ne jamais deployer de config dev en production.

## Checklist pre-deploiement obligatoire

| Verification | Commande | Bloquant |
|--------------|----------|----------|
| Fichier docker-compose est celui de PROD | `diff docker-compose.yml docker-compose.prod.yml` | Oui |
| Variables d'environnement presentes | `grep -E "^\w+=" .env.production` | Oui |
| Pas de secrets en dur dans les fichiers | `grep -rn "password\|secret\|api_key" docker-compose*.yml` | Oui |
| Migrations DB a jour | `npx prisma migrate status` ou equivalent | Oui |
| Cookie secure adapte a l'environnement | Verifier `secure: true` pour HTTPS, `false` pour HTTP dev | Oui |
| CSP headers autorisent les domaines prod | Verifier Content-Security-Policy | Oui |
| Tests passent | `npm test` / `pytest` / `go test` | Oui |
| Build reussit | `docker build .` ou `npm run build` | Oui |

## Red Flags — STOP immediat

| Signal | Reaction |
|--------|----------|
| Copier docker-compose.yml (dev) vers le serveur | STOP — utiliser docker-compose.prod.yml |
| Variables d'env avec valeurs par defaut de dev | STOP — verifier les valeurs production |
| `secure: true` pour cookies en environnement HTTP | STOP — adapter a l'environnement cible |
| Deployer sans avoir lance les tests | STOP — tests obligatoires avant deploy |
| Migration Prisma/DB avec `--force` sans backup | STOP — backup d'abord |

## Environnements

| Env | Cookies secure | CSP | Debug | DB |
|-----|---------------|-----|-------|----|
| Dev (HTTP) | `false` | Permissif | `true` | Locale |
| Staging (HTTPS) | `true` | Comme prod | `false` | Copie anonymisee |
| Prod (HTTPS) | `true` | Strict | `false` | Production |

## Regles

IMPORTANT: Toujours verifier que le docker-compose utilise est celui de PRODUCTION avant de deployer.

IMPORTANT: Ne JAMAIS deployer sans avoir verifie que toutes les variables d'environnement sont configurees pour la production.

NEVER copier un fichier de configuration de dev vers la production sans verification explicite.

NEVER deployer avec des migrations DB en attente sans les avoir executees ou verifiees.

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
