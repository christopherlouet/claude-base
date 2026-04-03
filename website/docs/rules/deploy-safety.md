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
- `**/middleware.*`
- `**/proxy.*`
- `**/sw.js`
- `**/service-worker*`
- `**/layout.tsx`
- `**/layout.jsx`
- `**/+layout.svelte`

## Regles detaillees

# Deploy Safety

## Principe

Chaque deploiement doit etre valide avant execution. Ne jamais deployer de config dev en production.

## CRITICAL: High-risk files

Ces fichiers peuvent casser la production de maniere silencieuse (pas d'erreur en dev) :

| Fichier | Risque | Test obligatoire |
|---------|--------|-----------------|
| `middleware.ts/proxy.ts` | CSP peut bloquer les scripts → page blanche | `npm run build && npm start`, verifier CSP headers avec curl |
| `layout.tsx` | `headers()` casse SSG → 500 sur pages statiques | `npm run build` doit passer sans erreur |
| `sw.js` | Cache HTML → hydration cassee apres deploy | Tester dans vrai navigateur avec DevTools &gt; Application &gt; SW |
| `docker-compose.production.yml` | `read_only` casse le cache framework | `docker compose up` en local avant deploy |
| `Dockerfile` | Image corrompue | Build + run local avant transfert |

IMPORTANT: Les tests en mode dev (`npm run dev`, `next dev`, `vite dev`) ne detectent PAS les bugs de production (CSP, SSG, SW, Docker).

## Regle absolue: REVERT FIRST

Si la prod est cassee, **REVERT au dernier etat stable AVANT de chercher a comprendre**. Ne jamais enchainer les hotfixes en cascade.

```bash
# Revert rapide
git checkout <last-known-good-tag> -- <broken-file>
./scripts/deploy.sh deploy
# PUIS investiguer dans une branche separee
```

NEVER enchainer plus de 2 hotfixes en prod. Au 2eme echec → REVERT.

## Checklist pre-deploiement obligatoire

| Verification | Commande | Bloquant |
|--------------|----------|----------|
| Build prod reussit | `npm run build` / `go build` / `docker build .` | Oui |
| Tests passent | `npm test` / `pytest` / `go test` | Oui |
| Types OK (si applicable) | `npx tsc --noEmit` / `mypy .` | Oui |
| Lint OK | `npm run lint` / `ruff check .` / `golangci-lint run` | Oui |
| Pas de secrets en dur | `grep -rn "password\|secret\|api_key" docker-compose*.yml` | Oui |
| Migrations DB a jour | `prisma migrate status` / equivalent | Oui |
| CSP headers verifies | `curl -sI localhost:3000 \| grep csp` | Si middleware modifie |
| SW ne cache pas HTML | Verifier navigate handler dans sw.js | Si SW modifie |
| Docker fonctionne | `docker compose -f docker-compose.production.yml up` local | Si Docker modifie |
| Backup DB fait | Script de backup | Oui |

## Red Flags — STOP immediat

| Signal | Reaction |
|--------|----------|
| `headers()` ou `cookies()` dans root layout | STOP — casse SSG, utiliser middleware |
| `read_only: true` dans Docker sans tmpfs complets | STOP — les frameworks ont besoin de cache writable |
| `strict-dynamic` CSP sans nonce sur scripts inline | STOP — bloque les scripts, page blanche |
| SW qui cache `request.mode === "navigate"` | STOP — casse l'hydration apres deploy |
| Deployer sans build prod local | STOP — les bugs dev ≠ bugs prod |
| 2eme hotfix en cascade qui echoue | STOP — REVERT et investiguer |
| Copier docker-compose.yml (dev) vers le serveur | STOP — utiliser docker-compose.production.yml |
| Variables d'env avec valeurs par defaut de dev | STOP — verifier les valeurs production |
| Migration DB avec `--force` sans backup | STOP — backup d'abord |

## Environnements

| Env | CSP | SW | Docker | Debug | Test method |
|-----|-----|-----|--------|-------|-------------|
| Dev | Permissif | Pas actif | Non | Oui | `npm run dev` |
| Build local | Prod | Actif si registered | Non | Non | `npm run build && npm start` |
| Staging | Prod | Actif | Oui | Non | Via deploy script |
| Prod | Strict | Actif | Oui | Non | Via deploy script |

## Regles

IMPORTANT: Toujours verifier que le docker-compose utilise est celui de PRODUCTION avant de deployer.

IMPORTANT: Ne JAMAIS deployer sans avoir verifie que toutes les variables d'environnement sont configurees pour la production.

NEVER copier un fichier de configuration de dev vers la production sans verification explicite.

NEVER deployer avec des migrations DB en attente sans les avoir executees ou verifiees.

NEVER deployer un changement de middleware, layout, sw.js, ou Docker sans test en build prod local.

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
