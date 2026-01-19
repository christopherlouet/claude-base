---
sidebar_position: 30
title: "proxmox-infrastructure"
description: "Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)"
tags:
  - "skill"
  - "fork"
---

# Skill: proxmox-infrastructure

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `Proxmox`, `PVE`, `Proxmox VE`, `LXC Proxmox`, `VM Proxmox`, `PBS`, `Proxmox Backup Server`, `cloud-init Proxmox`, `QEMU/KVM` |

## Quand ce skill est activé

Ce skill s'active automatiquement quand la conversation mentionne :
- "Proxmox", "PVE", "Proxmox VE"
- "VM Proxmox", "LXC Proxmox", "conteneur Proxmox"
- "cluster Proxmox", "node Proxmox"
- "PBS", "Proxmox Backup Server"
- "cloud-init Proxmox"
- "QEMU/KVM" dans un contexte Proxmox

## Principes fondamentaux

### 1. Infrastructure as Code

Toute infrastructure Proxmox doit être gérée via Terraform :
- **Reproductibilité** : Même config = même résultat
- **Versionnement** : Historique des changements dans Git
- **Review** : PR pour valider les changements d'infra
- **Documentation** : Le code EST la documentation

### 2. Séparation des environnements

```
environments/
├── dev/           # Développement (peut être détruit)
├── staging/       # Pré-production (miroir prod)
└── prod/          # Production (critique)
```

### 3. Modules réutilisables

```
modules/
├── vm/            # Machine virtuelle QEMU/KVM
├── lxc/           # Conteneur LXC
├── network/       # Configuration réseau
├── storage/       # Configuration stockage
└── backup/        # Configuration PBS
```

## Architecture Proxmox

### Hiérarchie des ressources

```
Datacenter
├── Cluster (optionnel)
│   ├── Node 1 (pve1)
│   │   ├── VMs (QEMU/KVM)
│   │   ├── Containers (LXC)
│   │   ├── Storage (local, shared)
│   │   └── Network (bridges, bonds)
│   ├── Node 2 (pve2)
│   └── Node 3 (pve3)
├── Storage (datacenter level)
│   ├── local (par node)
│   ├── local-lvm (par node)
│   ├── nfs-shared (partagé)
│   └── ceph (distribué)
└── SDN (Software Defined Network)
```

### Types de ressources

| Type | Description | Use case |
|------|-------------|----------|
| **VM (QEMU)** | Machine virtuelle complète | Workloads lourds, isolation forte |
| **LXC** | Conteneur système | Services légers, densité élevée |
| **Template** | Image de base | Clonage rapide de VMs/LXC |
| **Snippet** | Fichiers cloud-init | Configuration automatisée |

## Provider Terraform

### bpg/proxmox (recommandé)

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
  endpoint = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure = var.proxmox_insecure

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

# Permissions minimales requises
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum aclmod /storage -user terraform@pve -role PVEDatastoreUser
```

Format du token : `terraform@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

## Patterns Terraform

### Module VM

```hcl
resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = var.tags
  node_name   = var.target_node

  clone {
    vm_id = var.template_id
    full  = true
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.disk_size_gb
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      username = "ubuntu"
      keys     = var.ssh_keys
    }
  }
}
```

### Module LXC

```hcl
resource "proxmox_virtual_environment_container" "this" {
  description   = "Managed by Terraform"
  node_name     = var.target_node
  tags          = var.tags
  unprivileged  = var.unprivileged
  start_on_boot = true

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  disk {
    datastore_id = var.datastore
    size         = var.disk_size_gb
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  features {
    nesting = var.nesting
    fuse    = var.fuse
  }
}
```

## Conventions de nommage

### VMs et conteneurs

| Environnement | Pattern | Exemple |
|---------------|---------|---------|
| Production | `prod-{role}-{index}` | `prod-web-01` |
| Staging | `stg-{role}-{index}` | `stg-api-01` |
| Development | `dev-{role}-{index}` | `dev-db-01` |

### VMID ranges

| Range | Usage |
|-------|-------|
| 100-199 | Infrastructure (DNS, DHCP, etc.) |
| 200-299 | Production |
| 300-399 | Staging |
| 400-499 | Development |
| 9000-9099 | Templates |

## Sécurité

### Bonnes pratiques

1. **API Token** : Utiliser des tokens avec permissions minimales
2. **Firewall** : Activer le firewall Proxmox par défaut
3. **Isolation** : VLANs séparés par environnement
4. **Unprivileged LXC** : Toujours utiliser des conteneurs non privilégiés
5. **Audit** : Logger les accès API et SSH

## Troubleshooting

| Problème | Cause | Solution |
|----------|-------|----------|
| `TASK ERROR: VM is locked` | Opération en cours | Attendre ou `qm unlock <vmid>` |
| `storage not found` | Mauvais datastore | Vérifier avec `pvesm status` |
| `clone failed` | Pas assez d'espace | Libérer de l'espace |
| `Permission denied (API)` | Token sans permissions | Vérifier les ACLs |

## Attribution

Ce skill est basé sur :
- [Documentation officielle Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Provider Terraform bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox Backup Server Documentation](https://pbs.proxmox.com/docs/)

---

## Voir aussi

- [/ops-proxmox](/docs/commands/ops/ops-proxmox) - Commande associée
- [Agent ops-proxmox](/docs/agents/ops-proxmox) - Sub-agent avec contexte isolé
- [Skill infrastructure-as-code](/docs/skills/infrastructure-as-code) - IaC générique
