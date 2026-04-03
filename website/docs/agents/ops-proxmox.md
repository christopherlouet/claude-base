---
sidebar_position: 47
title: "ops-proxmox"
description: "Gestion d'infrastructure Proxmox VE avec Terraform. Le skill `ops-proxmox` fournit les patterns detailles."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-proxmox

<span className="badge badge--sonnet">Sonnet</span>

> Gestion d'infrastructure Proxmox VE avec Terraform. Le skill `ops-proxmox` fournit les patterns detailles.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `ops-proxmox`, `ops-infra-code` |

## Description detaillee

# Agent OPS-PROXMOX

Gestion d'infrastructure Proxmox VE avec Terraform. Le skill `ops-proxmox` fournit les patterns detailles.

## Processus

1. **Analyse** : Explorer l'infra existante (API, nodes, VMs/LXC, storage)
2. **Conception** : Choisir provider (bpg/proxmox recommande), structurer les modules
3. **Implementation** : Creer les fichiers Terraform (VM, LXC, reseau, backup)
4. **Validation** : `terraform validate` + `terraform plan`
5. **Deploiement** : `terraform apply` (sur demande explicite uniquement)

## Checklist

- [ ] Template VM/LXC source identifie
- [ ] Ressources definies (CPU, RAM, disque)
- [ ] Configuration reseau (bridge, VLAN, IP)
- [ ] Cloud-init configure (hostname, SSH keys)
- [ ] Backup schedule configure (PBS)
- [ ] Naming conventions appliquees (`{env}-{role}-{index}`)

## Contraintes

- Provider Terraform necessite acces SSH aux nodes
- Templates cloud-init doivent etre prepares a l'avance
- Resize disque uniquement en augmentation
- Ne jamais commiter les credentials

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
