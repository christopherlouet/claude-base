# =============================================================================
# Template: Module Terraform LXC Proxmox
# Usage: Copier dans modules/lxc/ et adapter selon vos besoins
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "hostname" {
  description = "Hostname du conteneur"
  type        = string
}

variable "description" {
  description = "Description du conteneur"
  type        = string
  default     = "Managed by Terraform"
}

variable "target_node" {
  description = "Node Proxmox cible"
  type        = string
}

variable "template_file_id" {
  description = "ID du template LXC (ex: local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst)"
  type        = string
}

variable "os_type" {
  description = "Type d'OS (ubuntu, debian, alpine, etc.)"
  type        = string
  default     = "ubuntu"
}

variable "cpu_cores" {
  description = "Nombre de cores CPU"
  type        = number
  default     = 1
}

variable "memory_mb" {
  description = "RAM en MB"
  type        = number
  default     = 512
}

variable "swap_mb" {
  description = "Swap en MB"
  type        = number
  default     = 512
}

variable "disk_size_gb" {
  description = "Taille du rootfs en GB"
  type        = number
  default     = 8
}

variable "datastore" {
  description = "Datastore pour le rootfs"
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
  description = "Adresse IP en notation CIDR (ex: 10.0.1.10/24)"
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

variable "ssh_keys" {
  description = "Clés SSH publiques"
  type        = list(string)
}

variable "root_password" {
  description = "Mot de passe root (optionnel, privilégier SSH)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags du conteneur"
  type        = list(string)
  default     = ["terraform"]
}

variable "unprivileged" {
  description = "Conteneur non privilégié (recommandé)"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Démarrer automatiquement au boot du node"
  type        = bool
  default     = true
}

# Features LXC
variable "nesting" {
  description = "Activer le nesting (Docker dans LXC)"
  type        = bool
  default     = false
}

variable "fuse" {
  description = "Activer FUSE"
  type        = bool
  default     = false
}

variable "keyctl" {
  description = "Activer keyctl"
  type        = bool
  default     = false
}

variable "mount_types" {
  description = "Types de mount autorisés"
  type        = list(string)
  default     = []
}

# Mountpoints additionnels
variable "mountpoints" {
  description = "Mountpoints additionnels"
  type = list(object({
    volume    = string
    path      = string
    size      = optional(number)
    read_only = optional(bool, false)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Resource LXC
# -----------------------------------------------------------------------------

resource "proxmox_virtual_environment_container" "this" {
  description   = var.description
  node_name     = var.target_node
  tags          = var.tags
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = true

  # Template OS
  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  # CPU
  cpu {
    cores = var.cpu_cores
  }

  # Mémoire
  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  # Rootfs
  disk {
    datastore_id = var.datastore
    size         = var.disk_size_gb
  }

  # Mountpoints additionnels
  dynamic "mount_point" {
    for_each = var.mountpoints
    content {
      volume    = mount_point.value.volume
      path      = mount_point.value.path
      size      = mount_point.value.size
      read_only = mount_point.value.read_only
    }
  }

  # Réseau
  network_interface {
    name    = "eth0"
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
  }

  # Initialisation
  initialization {
    hostname = var.hostname

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
      keys     = var.ssh_keys
      password = var.root_password
    }
  }

  # Features
  features {
    nesting     = var.nesting
    fuse        = var.fuse
    keyctl      = var.keyctl
    mount       = var.mount_types
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      initialization,
      disk[0].size,
    ]
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "container_id" {
  description = "ID du conteneur"
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "hostname" {
  description = "Hostname du conteneur"
  value       = var.hostname
}

output "ipv4_address" {
  description = "Adresse IPv4"
  value       = var.ip_address
}

output "node_name" {
  description = "Node Proxmox"
  value       = proxmox_virtual_environment_container.this.node_name
}
