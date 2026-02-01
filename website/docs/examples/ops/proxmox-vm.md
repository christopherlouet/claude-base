---
sidebar_position: 4
title: VM Proxmox
description: Exemple de VM Proxmox avec Terraform et cloud-init
---

# VM Proxmox avec Terraform

Cet exemple montre comment créer une VM Proxmox avec Terraform, cloud-init et configuration automatisée.

## Commande utilisée

```bash
/ops:ops-proxmox "Créer une VM Ubuntu avec cloud-init et configuration réseau"
```

## Structure générée

```
infrastructure/
├── main.tf              # VM et ressources
├── providers.tf         # Configuration Proxmox
├── variables.tf         # Variables
├── outputs.tf           # Outputs
├── terraform.tfvars     # Valeurs (non committé)
└── cloud-init/
    ├── user-data.yaml   # Configuration cloud-init
    └── network-config.yaml
```

## Code Terraform

### `providers.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  ssh {
    agent    = true
    username = "root"
  }
}
```

### `variables.tf`

```hcl
# ====================
# Proxmox Connection
# ====================

variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox (ex: https://pve.example.com:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token API Proxmox (format: user@realm!token=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Ignorer la vérification SSL (dev only)"
  type        = bool
  default     = false
}

variable "target_node" {
  description = "Node Proxmox cible"
  type        = string
  default     = "pve"
}

# ====================
# VM Configuration
# ====================

variable "vm_name" {
  description = "Nom de la VM"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vm_name))
    error_message = "Le nom doit contenir uniquement des lettres minuscules, chiffres et tirets."
  }
}

variable "vm_id" {
  description = "ID de la VM (100-999999)"
  type        = number

  validation {
    condition     = var.vm_id >= 100 && var.vm_id <= 999999
    error_message = "L'ID doit être entre 100 et 999999."
  }
}

variable "vm_description" {
  description = "Description de la VM"
  type        = string
  default     = "Managed by Terraform"
}

variable "cores" {
  description = "Nombre de coeurs CPU"
  type        = number
  default     = 2

  validation {
    condition     = var.cores >= 1 && var.cores <= 128
    error_message = "Le nombre de coeurs doit être entre 1 et 128."
  }
}

variable "memory" {
  description = "Mémoire en MB"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 512 && var.memory <= 524288
    error_message = "La mémoire doit être entre 512 MB et 512 GB."
  }
}

variable "disk_size" {
  description = "Taille du disque en GB"
  type        = number
  default     = 20
}

variable "datastore" {
  description = "Datastore pour le disque"
  type        = string
  default     = "local-lvm"
}

# ====================
# Network Configuration
# ====================

variable "bridge" {
  description = "Bridge réseau"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID (null pour aucun VLAN)"
  type        = number
  default     = null
}

variable "ip_address" {
  description = "Adresse IP avec CIDR (ex: 10.0.10.11/24)"
  type        = string
}

variable "gateway" {
  description = "Passerelle par défaut"
  type        = string
}

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

# ====================
# Cloud-Init
# ====================

variable "cloud_image_url" {
  description = "URL de l'image cloud"
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "username" {
  description = "Nom d'utilisateur à créer"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Clé SSH publique"
  type        = string
}

variable "packages" {
  description = "Packages à installer"
  type        = list(string)
  default     = ["qemu-guest-agent", "curl", "wget", "htop", "vim"]
}

variable "runcmd" {
  description = "Commandes à exécuter au premier boot"
  type        = list(string)
  default     = []
}

# ====================
# Tags
# ====================

variable "tags" {
  description = "Tags pour la VM"
  type        = list(string)
  default     = []
}
```

### `main.tf`

```hcl
# ====================
# Cloud Image
# ====================

resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.target_node

  url       = var.cloud_image_url
  file_name = "ubuntu-22.04-cloudimg-amd64.img"

  # Vérifier le checksum (optionnel mais recommandé)
  # checksum = "sha256:..."
}

# ====================
# Cloud-Init Configuration
# ====================

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = yamlencode({
      "#cloud-config" = null

      # Utilisateur
      users = [
        {
          name                = var.username
          groups              = ["sudo"]
          shell               = "/bin/bash"
          sudo                = "ALL=(ALL) NOPASSWD:ALL"
          ssh_authorized_keys = [var.ssh_public_key]
        }
      ]

      # Packages
      package_update  = true
      package_upgrade = true
      packages        = var.packages

      # Configuration système
      timezone = "Europe/Paris"
      locale   = "en_US.UTF-8"

      # Commandes au premier boot
      runcmd = concat([
        # Activer qemu-guest-agent
        "systemctl enable qemu-guest-agent",
        "systemctl start qemu-guest-agent",

        # Désactiver les mises à jour automatiques en prod
        "systemctl disable apt-daily.timer",
        "systemctl disable apt-daily-upgrade.timer",
      ], var.runcmd)

      # Message de fin
      final_message = "VM ${var.vm_name} ready after $UPTIME seconds"
    })

    file_name = "${var.vm_name}-cloud-config.yaml"
  }
}

# ====================
# Virtual Machine
# ====================

resource "proxmox_virtual_environment_vm" "main" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.target_node
  vm_id       = var.vm_id

  tags = var.tags

  # Agent QEMU
  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  # Démarrage
  on_boot  = true
  started  = true
  boot_order = ["scsi0"]

  # CPU
  cpu {
    cores   = var.cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  # Mémoire
  memory {
    dedicated = var.memory
    floating  = 0  # Pas de ballooning
  }

  # Disque système
  disk {
    datastore_id = var.datastore
    file_id      = proxmox_virtual_environment_download_file.cloud_image.id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  # Contrôleur SCSI
  scsi_hardware = "virtio-scsi-single"

  # Réseau
  network_device {
    bridge  = var.bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  # Cloud-Init
  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.username
      keys     = [var.ssh_public_key]
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  # Éviter de recréer pour les changements cloud-init
  lifecycle {
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }

  # Serial console (requis pour cloud-init)
  serial_device {}

  # VGA
  vga {
    type = "serial0"
  }
}

# ====================
# DNS Record (optionnel)
# ====================

# Si vous utilisez un provider DNS
# resource "cloudflare_record" "vm" {
#   zone_id = var.cloudflare_zone_id
#   name    = var.vm_name
#   value   = split("/", var.ip_address)[0]
#   type    = "A"
#   proxied = false
# }
```

### `outputs.tf`

```hcl
output "vm_id" {
  description = "ID de la VM"
  value       = proxmox_virtual_environment_vm.main.vm_id
}

output "vm_name" {
  description = "Nom de la VM"
  value       = proxmox_virtual_environment_vm.main.name
}

output "ip_address" {
  description = "Adresse IP de la VM"
  value       = split("/", var.ip_address)[0]
}

output "ssh_command" {
  description = "Commande SSH pour se connecter"
  value       = "ssh ${var.username}@${split("/", var.ip_address)[0]}"
}

output "mac_address" {
  description = "Adresse MAC de la VM"
  value       = proxmox_virtual_environment_vm.main.network_device[0].mac_address
}
```

### `terraform.tfvars.example`

```hcl
# Proxmox
proxmox_endpoint  = "https://pve.example.com:8006"
proxmox_api_token = "root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure  = true  # false en production avec cert valide
target_node       = "pve"

# VM
vm_name = "web-01"
vm_id   = 100

# Resources
cores     = 2
memory    = 4096
disk_size = 40

# Réseau
bridge     = "vmbr0"
vlan_id    = 10
ip_address = "10.0.10.11/24"
gateway    = "10.0.10.1"

# Cloud-Init
username       = "ubuntu"
ssh_public_key = "ssh-rsa AAAA... user@host"

packages = [
  "qemu-guest-agent",
  "docker.io",
  "docker-compose",
  "nginx",
]

runcmd = [
  "usermod -aG docker ubuntu",
]

tags = ["web", "production"]
```

## Déploiement

```bash
# Initialiser
terraform init

# Planifier
terraform plan -var-file="terraform.tfvars"

# Appliquer
terraform apply -var-file="terraform.tfvars"

# Se connecter
eval $(terraform output -raw ssh_command)
```

## Créer plusieurs VMs

```hcl
# variables.tf
variable "vms" {
  description = "Map des VMs à créer"
  type = map(object({
    vm_id      = number
    cores      = number
    memory     = number
    disk_size  = number
    ip_address = string
    tags       = list(string)
  }))
}

# main.tf
resource "proxmox_virtual_environment_vm" "cluster" {
  for_each = var.vms

  name      = each.key
  vm_id     = each.value.vm_id
  node_name = var.target_node

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  # ... reste de la config
}

# terraform.tfvars
vms = {
  "web-01" = {
    vm_id      = 100
    cores      = 2
    memory     = 2048
    disk_size  = 20
    ip_address = "10.0.10.11/24"
    tags       = ["web"]
  }
  "web-02" = {
    vm_id      = 101
    cores      = 2
    memory     = 2048
    disk_size  = 20
    ip_address = "10.0.10.12/24"
    tags       = ["web"]
  }
  "db-01" = {
    vm_id      = 200
    cores      = 4
    memory     = 8192
    disk_size  = 100
    ip_address = "10.0.20.11/24"
    tags       = ["database"]
  }
}
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Provider** | bpg/proxmox (recommandé) |
| **Cloud-Init** | Configuration YAML complète |
| **Réseau** | VLAN, IP statique, DNS |
| **Sécurité** | SSH key, pas de password |
| **Scalabilité** | `for_each` pour clusters |

## Commandes associées

- `/ops:ops-proxmox` - Commande dédiée Proxmox
- `/ops:ops-infra-code` - Modules Terraform génériques
- `/ops:ops-backup` - Configuration backup Proxmox

---

:::tip Templates Proxmox
Créez un template cloud-init une fois, puis clonez-le pour accélérer les déploiements :
```bash
qm template 9000
```
:::
