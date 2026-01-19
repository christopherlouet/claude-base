# =============================================================================
# Template: Module Terraform VM Proxmox
# Usage: Copier dans modules/vm/ et adapter selon vos besoins
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Nom de la VM"
  type        = string
}

variable "description" {
  description = "Description de la VM"
  type        = string
  default     = "Managed by Terraform"
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

variable "cpu_type" {
  description = "Type de CPU (host, kvm64, etc.)"
  type        = string
  default     = "host"
}

variable "memory_mb" {
  description = "RAM en MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Taille du disque système en GB"
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

variable "username" {
  description = "Utilisateur cloud-init"
  type        = string
  default     = "ubuntu"
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

variable "start_on_boot" {
  description = "Démarrer automatiquement au boot du node"
  type        = bool
  default     = true
}

variable "agent_enabled" {
  description = "Activer QEMU Guest Agent"
  type        = bool
  default     = true
}

variable "additional_disks" {
  description = "Disques additionnels"
  type = list(object({
    size         = number
    datastore_id = optional(string, "local-lvm")
    interface    = optional(string, "scsi")
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Resource VM
# -----------------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "this" {
  name          = var.name
  description   = var.description
  tags          = var.tags
  node_name     = var.target_node
  on_boot       = var.start_on_boot
  started       = true

  # Clone depuis template
  clone {
    vm_id = var.template_id
    full  = true
  }

  # CPU
  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  # Mémoire
  memory {
    dedicated = var.memory_mb
  }

  # Disque système
  disk {
    datastore_id = var.datastore
    size         = var.disk_size_gb
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  # Disques additionnels
  dynamic "disk" {
    for_each = var.additional_disks
    content {
      datastore_id = disk.value.datastore_id
      size         = disk.value.size
      interface    = "${disk.value.interface}${disk.key + 1}"
      iothread     = true
      discard      = "on"
    }
  }

  # Réseau
  network_device {
    bridge  = var.network_bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  # QEMU Guest Agent
  agent {
    enabled = var.agent_enabled
  }

  # Cloud-init
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
      keys     = var.ssh_keys
    }
  }

  # Lifecycle
  lifecycle {
    ignore_changes = [
      initialization,       # Ne pas recréer pour changement cloud-init
      disk[0].size,        # Permet resize manuel
    ]
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "vm_id" {
  description = "ID de la VM"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "Nom de la VM"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_address" {
  description = "Adresse IPv4 (depuis QEMU Guest Agent)"
  value       = try(proxmox_virtual_environment_vm.this.ipv4_addresses[1][0], var.ip_address)
}

output "mac_address" {
  description = "Adresse MAC"
  value       = proxmox_virtual_environment_vm.this.mac_addresses[0]
}

output "node_name" {
  description = "Node Proxmox"
  value       = proxmox_virtual_environment_vm.this.node_name
}
