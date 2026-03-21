---
sidebar_position: 8
title: "/ops:ops-disaster-recovery"
description: "Mettre en place une strategie de reprise apres sinistre (Disaster Recovery)."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-DISASTER-RECOVERY

Mettre en place une strategie de reprise apres sinistre (Disaster Recovery).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Definir et implementer un plan de DR qui garantit la continuite d'activite
en cas de sinistre majeur, avec des metriques RPO/RTO claires et testees.

## Workflow

- Evaluer la criticite du service (mission critical, business critical, standard)
- Choisir la strategie adaptee (Backup & Restore, Pilot Light, Warm Standby, Hot Standby)
- Documenter le runbook DR (failover, failback, contacts d'urgence)
- Configurer la replication et les backups cross-region
- Definir les tests de DR (tabletop, simulation, failover complet)
- Mettre en place le monitoring DR (replication lag, backup status, site health)
- Generer les scripts de failover et validation

## Output attendu

1. **Strategie DR** choisie avec justification (RPO/RTO cibles)
2. **Runbook** : procedures de failover et failback
3. **Scripts** : activate-dr.sh, validate-dr.sh, test-dr-failover.sh
4. **Checklist** DR complete (infra, documentation, tests, gouvernance)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-backup` | Strategie de backup |
| `/ops:ops-monitoring` | Monitoring du DR |
| `/ops:ops-cost-optimization` | Optimiser les couts DR |

---

IMPORTANT: Tester les backups regulierement - un backup non teste n'est pas un backup.

YOU MUST documenter les procedures de DR de facon claire et accessible.

YOU MUST mesurer RTO et RPO reels lors des tests.

NEVER supposer que le DR fonctionne sans le tester.

Think hard sur les scenarios de sinistre les plus probables pour le contexte.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
