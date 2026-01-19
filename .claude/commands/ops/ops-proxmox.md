# Agent OPS-PROXMOX

Gestion complète de l'infrastructure Proxmox VE : provisioning de VMs et conteneurs LXC, configuration réseau, stockage, backup avec PBS, et automatisation avec Terraform.

## Cible
$ARGUMENTS

## Objectif

Déployer et gérer une infrastructure Proxmox VE de manière déclarative avec Terraform, en suivant les meilleures pratiques de virtualisation et d'Infrastructure as Code.

## Stratégie Proxmox Infrastructure

```
┌─────────────────────────────────────────────────────────────┐
│                    PROXMOX INFRASTRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ANALYSER      → Inventaire infrastructure existante     │
│  ══════════                                                 │
│                                                             │
│  2. CONCEVOIR     → Architecture VMs/LXC cible              │
│  ═══════════                                                │
│                                                             │
│  3. STRUCTURER    → Modules Terraform Proxmox               │
│  ════════════                                               │
│                                                             │
│  4. IMPLÉMENTER   → Écrire le code IaC                      │
│  ═════════════                                              │
│                                                             │
│  5. VALIDER       → Plan, tests, review                     │
│  ══════════                                                 │
│                                                             │
│  6. DÉPLOYER      → Apply avec backup préalable             │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Analyse de l'infrastructure Proxmox

### Commandes de diagnostic

```bash
# Vérifier la version Proxmox
pveversion

# État du cluster
pvecm status

# Lister les nodes
pvesh get /nodes

# Lister toutes les VMs
qm list

# Lister tous les conteneurs
pct list

# État des storages
pvesm status

# Vérifier la connectivité API
curl -k https://<proxmox-host>:8006/api2/json/version
```

### Checklist d'analyse

```markdown
## Analyse Infrastructure Proxmox

### Nodes
- [ ] Nombre de nodes dans le cluster ?
- [ ] Ressources disponibles par node (CPU, RAM, stockage) ?
- [ ] Version Proxmox (7.x, 8.x) ?
- [ ] Licenses (Community, Subscription) ?

### Stockage
- [ ] Types de storage configurés (local, NFS, Ceph, ZFS) ?
- [ ] Espace disponible par storage ?
- [ ] Thin provisioning activé ?
- [ ] Réplication entre nodes ?

### Réseau
- [ ] Bridges configurés (vmbr0, vmbr1, ...) ?
- [ ] VLANs utilisés ?
- [ ] SDN Proxmox activé ?
- [ ] Bonds/agrégation de liens ?

### Templates existants
- [ ] Templates VM cloud-init disponibles ?
- [ ] Templates LXC téléchargés ?
- [ ] Snippets cloud-init présents ?

### Backup
- [ ] PBS configuré ?
- [ ] Schedules de backup existants ?
- [ ] Rétention configurée ?
```

## Étape 2 : Structure du projet Terraform

### Organisation recommandée

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
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── lxc/                   # Module conteneur LXC
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── cloud-init/            # Snippets cloud-init
│   │   │   └── ...
│   │   └── network/               # Configuration réseau
│   │       └── ...
│   └── environments/
│       ├── dev/
│       │   ├── main.tf
│       │   └── terraform.tfvars
│       ├── staging/
│       └── prod/
```

### Configuration du provider bpg/proxmox

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }

  # Backend recommandé
  backend "s3" {
    bucket         = "terraform-state"
    key            = "proxmox/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# main.tf
provider "proxmox" {
  endpoint = var.proxmox_endpoint

  # Authentification par token (recommandé)
  api_token = var.proxmox_api_token

  # Ignorer SSL auto-signé (dev only)
  insecure = var.proxmox_insecure

  # SSH pour certaines opérations
  ssh {
    agent    = true
    username = "root"
  }
}
```

### Création du token API Proxmox

```bash
# Créer un utilisateur dédié
pveum user add terraform@pve

# Créer un rôle avec permissions minimales
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Use"

# Assigner le rôle
pveum aclmod / -user terraform@pve -role TerraformRole

# Créer le token
pveum user token add terraform@pve terraform-token --privsep=0
```

## Étape 3 : Module VM

### Variables du module

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

variable "datastore" {
  description = "Datastore pour le disque"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Bridge réseau"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID (null si pas de VLAN)"
  type        = number
  default     = null
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
  default     = ["terraform"]
}
```

### Ressource VM

```hcl
# modules/vm/main.tf
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

## Étape 4 : Module LXC

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
      keys = var.ssh_keys
    }
  }

  features {
    nesting = var.nesting
    fuse    = var.fuse
  }
}
```

## Étape 5 : Utilisation des modules

### Exemple d'infrastructure complète

```hcl
# environments/prod/main.tf
locals {
  common_tags = ["prod", "terraform", "managed"]

  web_servers = {
    "01" = { ip = "10.0.1.11/24", cores = 4, memory = 8192 }
    "02" = { ip = "10.0.1.12/24", cores = 4, memory = 8192 }
  }

  service_containers = {
    redis    = { ip = "10.0.1.50/24", cores = 2, memory = 2048 }
    nginx    = { ip = "10.0.1.51/24", cores = 1, memory = 512 }
  }
}

# VMs Web Servers
module "web_servers" {
  source   = "../../modules/vm"
  for_each = local.web_servers

  name           = "prod-web-${each.key}"
  target_node    = "pve1"
  template_id    = 9000
  cpu_cores      = each.value.cores
  memory_mb      = each.value.memory
  disk_size_gb   = 50
  network_bridge = "vmbr0"
  ip_address     = each.value.ip
  gateway        = "10.0.1.1"
  ssh_keys       = var.ssh_public_keys
  tags           = concat(local.common_tags, ["web"])
}

# Conteneurs services
module "services" {
  source   = "../../modules/lxc"
  for_each = local.service_containers

  hostname         = "prod-${each.key}-01"
  target_node      = "pve1"
  template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  os_type          = "ubuntu"
  cpu_cores        = each.value.cores
  memory_mb        = each.value.memory
  disk_size_gb     = 20
  network_bridge   = "vmbr0"
  ip_address       = each.value.ip
  gateway          = "10.0.1.1"
  ssh_keys         = var.ssh_public_keys
  unprivileged     = true
  tags             = concat(local.common_tags, [each.key])
}
```

## Étape 6 : Backup avec PBS

### Configuration du schedule

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
    vmid            = [100, 101, 102]
  }
}
```

### Commandes PBS utiles

```bash
# Lister les backups
proxmox-backup-client list --repository user@pbs:datastore

# Vérifier l'intégrité
proxmox-backup-client verify --repository user@pbs:datastore

# Restaurer une VM
qmrestore pbs:backup/vzdump-qemu-100-2024_01_15-02_00_00.vma 200
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

### Tags recommandés

```
environment:prod
role:webserver
team:platform
backup:daily
managed-by:terraform
```

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

# Détruire une ressource
terraform destroy -target=module.web_servers["01"]

# Importer une VM existante
terraform import 'module.legacy.proxmox_virtual_environment_vm.this' 'pve1/qemu/100'
```

### Proxmox API

```bash
# Démarrer une VM
pvesh create /nodes/<node>/qemu/<vmid>/status/start

# Arrêter une VM
pvesh create /nodes/<node>/qemu/<vmid>/status/stop

# Snapshot
pvesh create /nodes/<node>/qemu/<vmid>/snapshot -snapname "before-update"

# Rollback
pvesh create /nodes/<node>/qemu/<vmid>/snapshot/before-update/rollback
```

## Output attendu

```markdown
## Infrastructure Proxmox Déployée

**Cluster:** proxmox.example.com
**Environment:** prod
**Node principal:** pve1

### VMs créées
| Nom | VMID | IP | Cores | RAM |
|-----|------|-----|-------|-----|
| prod-web-01 | 200 | 10.0.1.11 | 4 | 8GB |
| prod-web-02 | 201 | 10.0.1.12 | 4 | 8GB |

### Conteneurs LXC créés
| Nom | CTID | IP | Cores | RAM |
|-----|------|-----|-------|-----|
| prod-redis-01 | 210 | 10.0.1.50 | 2 | 2GB |
| prod-nginx-01 | 211 | 10.0.1.51 | 1 | 512MB |

### Backup
- Schedule: Quotidien à 02:00
- Storage: pbs-backup
- Rétention: 7 jours

### Prochaines étapes
1. [ ] Configurer DNS interne
2. [ ] Ajouter monitoring Prometheus
3. [ ] Configurer alertes backup
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

IMPORTANT: Toujours faire un `terraform plan` avant `apply`.

YOU MUST créer un token API avec permissions minimales.

YOU MUST utiliser des conteneurs LXC unprivileged par défaut.

NEVER stocker les credentials Proxmox dans le code.

Think hard sur la structure des modules pour la réutilisabilité.
