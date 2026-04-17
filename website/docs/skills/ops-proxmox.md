---
sidebar_position: 35
title: "ops-proxmox"
description: "Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)"
tags:
  - "skill"
  - "fork"
---

# Skill: ops-proxmox

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `ops`, `proxmox`, `pve`, `proxmox ve`, `vm proxmox`, `lxc proxmox` |

## Description detaillee

# Skill Proxmox Infrastructure

Gestion d'infrastructure Proxmox VE avec Terraform : provisioning de machines virtuelles, conteneurs LXC, configuration reseau, stockage et backup.

## Quand utiliser ce skill

Ce skill est active automatiquement quand la conversation mentionne :
- "Proxmox", "PVE", "Proxmox VE"
- "VM Proxmox", "LXC Proxmox", "conteneur Proxmox"
- "cluster Proxmox", "node Proxmox"
- "PBS", "Proxmox Backup Server"
- "cloud-init Proxmox"
- "QEMU/KVM" dans un contexte Proxmox

## Principes fondamentaux

### 1. Infrastructure as Code

Toute infrastructure Proxmox doit etre geree via Terraform :
- **Reproductibilite** : meme config = meme resultat
- **Versionnement** : historique dans Git
- **Review** : PR pour valider les changements d'infra
- **Documentation** : le code EST la documentation

### 2. Separation des environnements

```
environments/
├── dev/           # Peut etre detruit
├── staging/       # Miroir prod
└── prod/          # Critique
```

Chaque environnement a ses propres variables (`terraform.tfvars`), son state Terraform et ses credentials.

### 3. Modules reutilisables

```
modules/
├── vm/            # Machine virtuelle QEMU/KVM
├── lxc/           # Conteneur LXC
├── network/       # Configuration reseau
├── storage/       # Configuration stockage
└── backup/        # Configuration PBS
```

## Architecture Proxmox

### Hierarchie des ressources

```
Datacenter
├── Cluster (optionnel)
│   ├── Node 1 (pve1) → VMs, LXC, Storage, Network
│   ├── Node 2 (pve2)
│   └── Node 3 (pve3)
├── Storage (datacenter level)
│   ├── local, local-lvm (par node)
│   ├── nfs-shared (partage)
│   └── ceph (distribue)
└── SDN (Zones, VNets, Subnets)
```

### Types de ressources

| Type | Description | Use case |
|------|-------------|----------|
| **VM (QEMU)** | Machine virtuelle complete | Workloads lourds, isolation forte |
| **LXC** | Conteneur systeme | Services legers, densite elevee |
| **Template** | Image de base | Clonage rapide de VMs/LXC |
| **Snippet** | Fichiers cloud-init | Configuration automatisee |

## Provider Terraform

### bpg/proxmox (recommande)

Provider moderne, bien maintenu, couverture complete de l'API Proxmox.

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token  # Token recommande
  insecure  = var.proxmox_insecure   # Dev only

  ssh {
    agent    = true
    username = "root"
  }
}
```

### Authentification par token API

```bash
# Sur le node Proxmox
pveum user token add terraform@pve terraform-token --privsep=0

# Permissions minimales
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum aclmod /storage -user terraform@pve -role PVEDatastoreUser
```

Format : `terraform@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

## Conventions de nommage

### VMs et conteneurs

| Environnement | Pattern | Exemple |
|---------------|---------|---------|
| Production | `prod-{role}-{index}` | `prod-web-01` |
| Staging | `stg-{role}-{index}` | `stg-api-01` |
| Development | `dev-{role}-{index}` | `dev-db-01` |
| Test | `test-{purpose}` | `test-migration` |

### VMID ranges

| Range | Usage |
|-------|-------|
| 100-199 | Infrastructure (DNS, DHCP, etc.) |
| 200-299 | Production |
| 300-399 | Staging |
| 400-499 | Development |
| 500-599 | Test/Temporaire |
| 9000-9099 | Templates |

### Tags recommandes

```
environment:prod
role:webserver
team:platform
backup:daily
managed-by:terraform
criticality:high
```

## Securite

### Bonnes pratiques

1. **API Token** : permissions minimales (role dedie, pas root)
2. **Firewall** : activer le firewall Proxmox par defaut
3. **Isolation** : VLANs separes par environnement
4. **Unprivileged LXC** : toujours utiliser des conteneurs non privilegies
5. **Audit** : logger les acces API et SSH
6. **Secrets** : JAMAIS hardcoder dans le HCL (utiliser Vault, TF_VAR_*, ou tfvars gitignore)

### Permissions minimales Terraform

```bash
# Role dedie
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Use"

# User + assignation
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role TerraformRole
```

## References

Cette section SKILL.md contient les principes fondamentaux. Pour les details techniques avec exemples HCL complets, consulter les fichiers references :

| Fichier | Contenu |
|---------|---------|
| [`references/terraform-modules.md`](https://github.com/christopherlouet/claude-socle/blob/main/.claude/skills/ops-proxmox/references/terraform-modules.md) | Modules VM, LXC, utilisation, reseau, stockage |
| [`references/cloud-init.md`](https://github.com/christopherlouet/claude-socle/blob/main/.claude/skills/ops-proxmox/references/cloud-init.md) | Templates cloud-config, upload snippets |
| [`references/backup-ha.md`](https://github.com/christopherlouet/claude-socle/blob/main/.claude/skills/ops-proxmox/references/backup-ha.md) | PBS schedule, commandes, configuration HA |
| [`references/troubleshooting.md`](https://github.com/christopherlouet/claude-socle/blob/main/.claude/skills/ops-proxmox/references/troubleshooting.md) | Problemes courants, commandes diagnostic, recovery |

## Regles

IMPORTANT: Ne JAMAIS gerer Proxmox manuellement via l'UI. Toujours via Terraform.

IMPORTANT: Utiliser des unprivileged LXC par defaut (escalation de privilege limitee).

IMPORTANT: Un seul state Terraform par environnement (dev/staging/prod isoles).

YOU MUST utiliser le provider `bpg/proxmox` (moderne, maintenu) plutot que `telmate/proxmox` (deprecie).

YOU MUST utiliser des API tokens avec permissions minimales, jamais root.

NEVER hardcoder des secrets dans le HCL commite. Utiliser tfvars gitignore ou Vault.

NEVER skipper les backups PBS sur les VMs critiques.

## Attribution

Ce skill est base sur :
- [Documentation officielle Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Provider Terraform bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux ops..."_
- _"Je veux proxmox..."_
- _"Je veux pve..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
