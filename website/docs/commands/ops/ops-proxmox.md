---
sidebar_position: 28
title: "/ops:ops-proxmox"
description: "Gestion d'infrastructure Proxmox VE : VMs, LXC, reseau, stockage, backup avec Terraform."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-PROXMOX

Gestion d'infrastructure Proxmox VE : VMs, LXC, reseau, stockage, backup avec Terraform.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Deployer et gerer une infrastructure Proxmox VE de maniere declarative avec Terraform,
en utilisant le provider bpg/proxmox.

Utilise le skill `ops-proxmox` pour les templates et la methodologie detaillee.

## Workflow

- Analyser l'infrastructure existante (nodes, stockage, reseau, templates)
- Structurer le projet Terraform (modules VM, LXC, cloud-init, network)
- Configurer le provider avec token API a permissions minimales
- Implementer les modules reutilisables (VM QEMU, conteneur LXC)
- Configurer les backups avec PBS
- Valider avec terraform plan et appliquer

## Output attendu

1. **Structure Terraform** organisee par environnement
2. **Modules** VM et LXC reutilisables
3. **Configuration** backup PBS
4. **Inventaire** des ressources creees (VMs, LXC, IPs)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-infra-code` | IaC generique (AWS, GCP, Azure) |
| `/ops:ops-monitoring` | Monitoring infrastructure |
| `/ops:ops-backup` | Strategie backup avancee |

---

IMPORTANT: Toujours faire un terraform plan avant apply.

YOU MUST creer un token API avec permissions minimales.

YOU MUST utiliser des conteneurs LXC unprivileged par defaut.

NEVER stocker les credentials Proxmox dans le code.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
