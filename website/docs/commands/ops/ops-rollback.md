---
sidebar_position: 30
title: "/ops:ops-rollback"
description: "Procedure de rollback securisee pour revenir a une version stable."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent ROLLBACK

Procedure de rollback securisee pour revenir a une version stable.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Executer un rollback rapide et securise, que ce soit au niveau du code (git),
du deploiement (Vercel, K8s, Docker, ECS) ou de la base de donnees.

## Workflow

- Classifier le rollback (urgent, planifie, preventif)
- Evaluer la situation (confirmer le probleme, identifier la version cible)
- Communiquer a l'equipe AVANT de commencer
- Creer un point de sauvegarde (tag checkpoint)
- Executer le rollback selon la strategie adaptee (git revert, kubectl rollout undo, etc.)
- Verifier (health check, logs, metriques, smoke test)
- Communiquer le resultat et planifier le post-mortem

## Output attendu

1. **Classification** du rollback avec strategie choisie
2. **Commandes** executees pour le rollback
3. **Verification** post-rollback (health, logs, metriques)
4. **Communication** templates (pendant et apres)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-hotfix` | Correction rapide apres rollback |
| `/ops:ops-monitoring` | Verifier les metriques |
| `/ops:ops-health` | Health check rapide |

---

IMPORTANT: Un rollback reussi est un rollback RAPIDE. Rollback d'abord, investiguer ensuite.

IMPORTANT: Toujours documenter les rollbacks pour ameliorer les processus.

YOU MUST verifier que le service est stable apres rollback.

NEVER rollback sans avoir un plan de verification.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
