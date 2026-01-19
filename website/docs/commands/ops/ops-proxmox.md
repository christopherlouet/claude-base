---
sidebar_position: 29
title: "/ops-proxmox"
description: "Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)"
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent OPS-PROXMOX

Gestion complète de l'infrastructure Proxmox VE : provisioning de VMs et conteneurs LXC, configuration réseau, stockage, backup avec PBS, et automatisation avec Terraform.

## Cible
`<arguments>`

## Modes d'utilisation

### Mode 1 : Provisionner des VMs
Crée des machines virtuelles QEMU/KVM avec cloud-init.

### Mode 2 : Créer des conteneurs LXC
Déploie des conteneurs légers sur Proxmox.

### Mode 3 : Configurer le réseau
Configure bridges, VLANs et SDN Proxmox.

### Mode 4 : Gérer les backups PBS
Configure Proxmox Backup Server et les schedules.

---

## Stratégie Proxmox Infrastructure

```
┌─────────────────────────────────────────────────────────────┐
│                    PROXMOX INFRASTRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ANALYSER      → Inventaire infrastructure existante     │
│  2. CONCEVOIR     → Architecture VMs/LXC cible              │
│  3. STRUCTURER    → Modules Terraform Proxmox               │
│  4. IMPLÉMENTER   → Écrire le code IaC                      │
│  5. VALIDER       → Plan, tests, review                     │
│  6. DÉPLOYER      → Apply avec backup préalable             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Structure du projet Terraform

```
infrastructure/
├── proxmox/
│   ├── main.tf                    # Provider configuration
│   ├── variables.tf               # Variables globales
│   ├── outputs.tf                 # Outputs globaux
│   ├── versions.tf                # Contraintes de versions
│   ├── terraform.tfvars           # Valeurs (NE PAS COMMITER)
│   ├── modules/
│   │   ├── vm/                    # Module VM QEMU/KVM
│   │   ├── lxc/                   # Module conteneur LXC
│   │   ├── cloud-init/            # Snippets cloud-init
│   │   └── network/               # Configuration réseau
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
```

## Configuration du provider bpg/proxmox

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

  # Authentification par token (recommandé)
  api_token = var.proxmox_api_token

  # SSH pour certaines opérations
  ssh {
    agent    = true
    username = "root"
  }
}
```

## Module VM

```hcl
resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = "Managed by Terraform"
  tags        = var.tags
  node_name   = var.target_node
  on_boot     = true

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
    datastore_id = var.datastore
    size         = var.disk_size_gb
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
  }

  network_device {
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
    model   = "virtio"
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

## Module LXC

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

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      keys = var.ssh_keys
    }
  }

  features {
    nesting = var.nesting
    fuse    = var.fuse
  }
}
```

## Bonnes pratiques

### Naming conventions

| Type | Pattern | Exemple |
|------|---------|---------|
| VM | `{env}-{role}-{index}` | `prod-web-01` |
| LXC | `{env}-{service}-{index}` | `dev-redis-01` |
| Bridge | `vmbr{n}` | `vmbr0`, `vmbr1` |

### VMID ranges

| Range | Usage |
|-------|-------|
| 100-199 | Infrastructure |
| 200-299 | Production |
| 300-399 | Staging |
| 400-499 | Development |
| 9000-9099 | Templates |

### Sécurité

| Pratique | Raison |
|----------|--------|
| **Token API** | Pas de user/password |
| **Permissions minimales** | Principe du moindre privilège |
| **Unprivileged LXC** | Isolation renforcée |
| **Firewall Proxmox** | Défense en profondeur |
| **VLANs par env** | Isolation réseau |

## Commandes utiles

### Terraform

```bash
# Initialiser
terraform init

# Planifier
terraform plan -var-file=environments/prod/terraform.tfvars

# Appliquer
terraform apply -var-file=environments/prod/terraform.tfvars

# Importer une VM existante
terraform import 'module.legacy.proxmox_virtual_environment_vm.this' 'pve1/qemu/100'
```

### Proxmox API

```bash
# Démarrer une VM
pvesh create /nodes/<node>/qemu/<vmid>/status/start

# Snapshot
pvesh create /nodes/<node>/qemu/<vmid>/snapshot -snapname "before-update"

# Rollback
pvesh create /nodes/<node>/qemu/<vmid>/snapshot/before-update/rollback
```

## Templates disponibles

Utilisez les templates dans `.claude/templates/proxmox/` :
- `provider-template.tf` - Configuration provider
- `vm-module-template.tf` - Module VM
- `lxc-module-template.tf` - Module LXC
- `infrastructure-template.tf` - Infrastructure complète

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops-infra-code` | IaC générique (AWS, GCP, Azure) |
| `/ops-monitoring` | Monitoring infrastructure |
| `/ops-backup` | Stratégie backup avancée |
| `/ops-ci` | Pipeline CI/CD pour Terraform |

---

## Voir aussi

- [Agent ops-proxmox](/docs/agents/ops-proxmox) - Sub-agent avec contexte isolé
- [Skill proxmox-infrastructure](/docs/skills/proxmox-infrastructure) - Skill auto-déclenché
- [/ops-infra-code](/docs/commands/ops/ops-infra-code) - Infrastructure as Code générique
