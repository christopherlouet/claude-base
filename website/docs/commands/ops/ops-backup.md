---
sidebar_position: 2
title: "/ops:ops-backup"
description: "Strategie de backup et restore pour les donnees critiques du projet."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-BACKUP

Strategie de backup et restore pour les donnees critiques du projet.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Definir et implementer une strategie de sauvegarde 3-2-1 (3 copies, 2 medias, 1 offsite)
avec des procedures de restauration testees et documentees.

## Workflow

- Identifier les donnees critiques a sauvegarder (DB, fichiers, configs, logs)
- Choisir le type de backup adapte (full, incremental, differentiel, snapshot)
- Generer les scripts de backup et restore pour la stack detectee
- Configurer la planification cron et la retention
- Configurer le monitoring et les alertes sur les backups
- Generer la documentation de procedure de restore
- Proposer une matrice RPO/RTO par scenario d'incident
- Chiffrer les backups contenant des donnees sensibles

## Output attendu

1. **Scripts** : backup-db.sh, backup-files.sh, restore-db.sh, test-restore.sh
2. **Configuration cron** recommandee
3. **Matrice de restore** (scenario, RPO, RTO, procedure)
4. **Checklist** backup complete

## Agents lies

| Avant | Usage |
|-------|-------|
| `/ops:ops-database` | Migrations et schema DB |
| `/ops:ops-infra-code` | Infrastructure backup |

| Apres | Usage |
|-------|-------|
| `/ops:ops-disaster-recovery` | Plan de reprise complet |
| `/ops:ops-monitoring` | Alertes sur backups |

---

IMPORTANT: Un backup non teste n'est pas un backup. Tester regulierement les restores.

YOU MUST avoir au moins une copie des donnees hors site (autre region/provider).

NEVER oublier de chiffrer les backups contenant des donnees sensibles.

Think hard sur le RPO et RTO acceptables pour le contexte du projet.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
