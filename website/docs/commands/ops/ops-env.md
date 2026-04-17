---
sidebar_position: 12
title: "/ops:ops-env"
description: "Gestion des environnements (dev, staging, prod) et des variables d'environnement."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-ENV

Gestion des environnements (dev, staging, prod) et des variables d'environnement.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Configurer une gestion propre des environnements avec validation des variables,
templates documentes et separation stricte des secrets par environnement.

## Workflow

- Identifier les environnements necessaires (dev, staging, prod)
- Creer le template .env.example documente et categorise
- Implementer la validation des variables avec Zod ou equivalent
- Configurer les fichiers par environnement (.env.development, .env.staging, .env.production)
- Verifier que .env et .env.local sont dans .gitignore
- Recommander une solution de secrets management adaptee
- Configurer les variables CI/CD (GitHub Actions, GitLab CI)

## Output attendu

1. **Fichiers** : .env.example, .env.development, .env.staging, .env.production
2. **Validation** : config/env.ts avec schema Zod
3. **Documentation** des variables requises et optionnelles
4. **Checklist** securite des environnements

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-secrets-management` | Gestion securisee des secrets |
| `/ops:ops-docker` | Configuration Docker |
| `/ops:ops-ci` | Secrets en CI/CD |

---

IMPORTANT: Ne JAMAIS commiter de fichiers .env contenant des secrets reels.

YOU MUST utiliser des secrets differents pour chaque environnement.

NEVER hardcoder des valeurs sensibles dans le code.

Think hard sur quelles variables sont vraiment necessaires.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
