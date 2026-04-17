---
sidebar_position: 31
title: "/ops:ops-secrets-management"
description: "Implemente une gestion securisee des secrets et credentials."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent SECRETS-MANAGEMENT

Implemente une gestion securisee des secrets et credentials.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Mettre en place une strategie complete de gestion des secrets : inventaire,
centralisation, injection securisee, rotation automatique et audit.

## Workflow

- Inventorier tous les secrets du projet (API keys, DB, auth, cloud, certs)
- Classifier par sensibilite (critique, haute, moyenne)
- Choisir la solution de stockage (AWS Secrets Manager, Vault, K8s Secrets)
- Implementer l'injection securisee avec cache et fallback
- Configurer la rotation automatique (30 jours recommande)
- Mettre en place l'audit des acces (logging, alertes)
- Configurer les pre-commit hooks pour detecter les secrets

## Output attendu

1. **Inventaire** des secrets avec ancienne/nouvelle methode
2. **Configuration** du provider choisi avec rotation
3. **Code** d'injection securisee avec cache
4. **Checklist** securite (stockage, acces, rotation, developpement)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-security` | Audit securite complet |
| `/ops:ops-infra-code` | Provisionner Secrets Manager |
| `/ops:ops-env` | Configuration environnements |
| `/ops:ops-ci` | Injection secrets en CI |

---

IMPORTANT: JAMAIS de secrets dans le code ou les logs.

YOU MUST utiliser un gestionnaire de secrets centralise.

YOU MUST activer la rotation automatique.

NEVER partager des secrets entre environnements.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
