---
name: ops-proxmox
description: Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Skill Proxmox Infrastructure

Gestion d'infrastructure Proxmox VE avec Terraform : provisioning de machines virtuelles, conteneurs LXC, configuration réseau, stockage et backup.

## Quand utiliser ce Skill

Ce skill est activé automatiquement quand la conversation mentionne :
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

Chaque environnement a :
- Ses propres variables (`terraform.tfvars`)
- Son propre state Terraform
- Ses propres credentials

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
    ├── Zones
    ├── VNets
    └── Subnets
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

Le provider `bpg/proxmox` est moderne, bien maintenu et offre une couverture complète de l'API Proxmox.

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
  # API endpoint (https://pve.example.com:8006)
  endpoint = var.proxmox_endpoint

  # Authentification par token (recommandé)
  api_token = var.proxmox_api_token

  # OU authentification par user/password
  # username = var.proxmox_username
  # password = var.proxmox_password

  # Ignorer les certificats auto-signés (dev only)
  insecure = var.proxmox_insecure

  # Configuration SSH pour certaines opérations
  ssh {
    agent    = true
    username = "root"
  }
}
```

### Authentification par token API

Créer un token dans Proxmox :

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
# modules/vm/variables.tf
variable "name" {
  description = "Nom de la VM"
  type        = string
}

variable "target_node" {
  description = "Node Proxmox cible"
  type        = string
}

variable "template_id" {
  description = "ID du template à cloner"
  type        = number
}

variable "cpu_cores" {
  description = "Nombre de cores CPU"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "RAM en MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Taille du disque en GB"
  type        = number
  default     = 20
}

variable "network_bridge" {
  description = "Bridge réseau"
  type        = string
  default     = "vmbr0"
}

variable "ip_address" {
  description = "Adresse IP (CIDR notation)"
  type        = string
}

variable "gateway" {
  description = "Passerelle par défaut"
  type        = string
}

variable "ssh_keys" {
  description = "Clés SSH publiques"
  type        = list(string)
}

variable "tags" {
  description = "Tags de la VM"
  type        = list(string)
  default     = []
}
```

```hcl
# modules/vm/main.tf
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

  agent {
    enabled = true
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

  lifecycle {
    ignore_changes = [
      initialization,
      disk[0].size,
    ]
  }
}
```

```hcl
# modules/vm/outputs.tf
output "vm_id" {
  description = "ID de la VM"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "ipv4_address" {
  description = "Adresse IPv4"
  value       = proxmox_virtual_environment_vm.this.ipv4_addresses[1][0]
}

output "mac_address" {
  description = "Adresse MAC"
  value       = proxmox_virtual_environment_vm.this.mac_addresses[0]
}
```

### Module LXC

```hcl
# modules/lxc/main.tf
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
      keys     = var.ssh_keys
      password = var.root_password
    }
  }

  features {
    nesting = var.nesting
    fuse    = var.fuse
    keyctl  = var.keyctl
  }
}
```

### Utilisation des modules

```hcl
# environments/prod/main.tf
module "web_servers" {
  source   = "../../modules/vm"
  for_each = toset(["01", "02", "03"])

  name           = "prod-web-${each.key}"
  target_node    = "pve1"
  template_id    = 9000
  cpu_cores      = 4
  memory_mb      = 8192
  disk_size_gb   = 50
  network_bridge = "vmbr0"
  ip_address     = "10.0.1.${10 + tonumber(each.key)}/24"
  gateway        = "10.0.1.1"
  ssh_keys       = var.ssh_public_keys
  tags           = ["prod", "web", "terraform"]
}

module "redis_cache" {
  source = "../../modules/lxc"

  hostname       = "prod-redis-01"
  target_node    = "pve2"
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  os_type        = "ubuntu"
  cpu_cores      = 2
  memory_mb      = 4096
  disk_size_gb   = 20
  network_bridge = "vmbr0"
  ip_address     = "10.0.1.50/24"
  gateway        = "10.0.1.1"
  ssh_keys       = var.ssh_public_keys
  unprivileged   = true
  tags           = ["prod", "cache", "terraform"]
}
```

## Cloud-init

### Template cloud-init

```yaml
#cloud-config
hostname: ${hostname}
fqdn: ${hostname}.${domain}
manage_etc_hosts: true

users:
  - name: ${username}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      ${ssh_keys}

package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - curl
  - vim
  - htop

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
```

### Upload snippet cloud-init

```hcl
resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/templates/cloud-config.yaml", {
      hostname  = var.hostname
      domain    = var.domain
      username  = var.username
      ssh_keys  = indent(6, join("\n", [for key in var.ssh_keys : "- ${key}"]))
    })
    file_name = "${var.hostname}-cloud-config.yaml"
  }
}
```

## Réseau

### Configuration bridge

```hcl
resource "proxmox_virtual_environment_network_linux_bridge" "vlan_backend" {
  node_name = var.target_node
  name      = "vmbr1"
  comment   = "Backend VLAN"

  ports = ["eno2"]

  vlan_aware = true
}
```

### VLAN tagging

```hcl
network_device {
  bridge  = "vmbr0"
  vlan_id = 100  # VLAN 100
}
```

## Stockage

### Types de stockage Proxmox

| Type | Description | Performance | HA |
|------|-------------|-------------|-----|
| `local` | Répertoire local | Moyenne | Non |
| `local-lvm` | LVM local | Bonne | Non |
| `nfs` | NFS partagé | Variable | Oui |
| `ceph` | Ceph RBD | Excellente | Oui |
| `zfs` | ZFS local | Excellente | Non |
| `zfs-over-iscsi` | ZFS sur iSCSI | Bonne | Oui |

### Configuration stockage partagé

```hcl
resource "proxmox_virtual_environment_storage_nfs" "backup" {
  node_name = var.target_node
  storage_id = "nfs-backup"
  server     = "nas.example.com"
  export     = "/volume1/proxmox-backup"
  content    = ["backup", "iso", "vztmpl"]
}
```

## Backup avec PBS

### Configuration backup schedule

```hcl
resource "proxmox_virtual_environment_cluster_options" "backup" {
  backup_schedule {
    enabled         = true
    schedule        = "0 2 * * *"  # Tous les jours à 2h
    storage         = "pbs-backup"
    mode            = "snapshot"
    compress        = "zstd"
    notification    = "failure"

    selection_mode  = "include"
    vmid            = [100, 101, 102]  # VMs à backup
  }
}
```

### Commandes PBS utiles

```bash
# Vérifier l'état des backups
proxmox-backup-client list --repository user@pbs:datastore

# Restaurer un backup
qmrestore pbs:backup/vzdump-qemu-100-2024_01_15-02_00_00.vma 200

# Vérifier l'intégrité
proxmox-backup-client verify --repository user@pbs:datastore
```

## Haute disponibilité

### Configuration HA

```hcl
resource "proxmox_virtual_environment_haresource" "critical_vm" {
  resource_id = "vm:100"
  state       = "started"
  group       = "production"

  max_restart  = 3
  max_relocate = 3
}

resource "proxmox_virtual_environment_hagroup" "production" {
  group_id   = "production"
  nodes      = ["pve1", "pve2", "pve3"]
  restricted = true
  nofailback = false
}
```

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

### Tags recommandés

```
environment:prod
role:webserver
team:platform
backup:daily
managed-by:terraform
criticality:high
```

## Sécurité

### Bonnes pratiques

1. **API Token** : Utiliser des tokens avec permissions minimales
2. **Firewall** : Activer le firewall Proxmox par défaut
3. **Isolation** : VLANs séparés par environnement
4. **Unprivileged LXC** : Toujours utiliser des conteneurs non privilégiés
5. **Audit** : Logger les accès API et SSH

### Permissions minimales Terraform

```bash
# Créer un rôle dédié
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Use"

# Créer l'utilisateur
pveum user add terraform@pve

# Assigner le rôle
pveum aclmod / -user terraform@pve -role TerraformRole
```

## Troubleshooting

### Problèmes courants

| Problème | Cause | Solution |
|----------|-------|----------|
| `TASK ERROR: VM is locked` | Opération en cours | Attendre ou `qm unlock <vmid>` |
| `storage not found` | Mauvais datastore | Vérifier avec `pvesm status` |
| `clone failed` | Pas assez d'espace | Libérer de l'espace ou changer de storage |
| `cloud-init drive exists` | Réapplication cloud-init | Supprimer le drive cloud-init |
| `Permission denied (API)` | Token sans permissions | Vérifier les ACLs avec `pveum acl list` |

### Commandes de diagnostic

```bash
# État du cluster
pvecm status

# État des VMs
qm list

# État des conteneurs
pct list

# Logs système
journalctl -u pve-cluster -f

# État du stockage
pvesm status

# Tâches en cours
pvesh get /cluster/tasks
```

## Attribution

Ce skill est basé sur :
- [Documentation officielle Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Provider Terraform bpg/proxmox](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox Backup Server Documentation](https://pbs.proxmox.com/docs/)
