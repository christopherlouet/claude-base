# =============================================================================
# Template: Proxmox VM Terraform Module
# Usage: Copy into modules/vm/ and adapt to your needs
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "VM name"
  type        = string
}

variable "description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
}

variable "target_node" {
  description = "Target Proxmox node"
  type        = string
}

variable "template_id" {
  description = "ID of the template to clone"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_type" {
  description = "CPU type (host, kvm64, etc.)"
  type        = string
  default     = "host"
}

variable "memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "System disk size in GB"
  type        = number
  default     = 20
}

variable "datastore" {
  description = "Datastore for the disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID (null if no VLAN)"
  type        = number
  default     = null
}

variable "ip_address" {
  description = "IP address in CIDR notation (e.g.: 10.0.1.10/24)"
  type        = string
}

variable "gateway" {
  description = "Default gateway"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "username" {
  description = "cloud-init user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_keys" {
  description = "Public SSH keys"
  type        = list(string)
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = ["terraform"]
}

variable "start_on_boot" {
  description = "Start automatically on node boot"
  type        = bool
  default     = true
}

variable "agent_enabled" {
  description = "Enable QEMU Guest Agent"
  type        = bool
  default     = true
}

variable "additional_disks" {
  description = "Additional disks"
  type = list(object({
    size         = number
    datastore_id = optional(string, "local-lvm")
    interface    = optional(string, "scsi")
  }))
  default = []
}

# -----------------------------------------------------------------------------
# VM Resource
# -----------------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "this" {
  name          = var.name
  description   = var.description
  tags          = var.tags
  node_name     = var.target_node
  on_boot       = var.start_on_boot
  started       = true

  # Clone from template
  clone {
    vm_id = var.template_id
    full  = true
  }

  # CPU
  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  # Memory
  memory {
    dedicated = var.memory_mb
  }

  # System disk
  disk {
    datastore_id = var.datastore
    size         = var.disk_size_gb
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    ssd          = true
  }

  # Additional disks
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

  # Network
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
      initialization,       # Do not recreate on cloud-init change
      disk[0].size,        # Allow manual resize
    ]
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "vm_id" {
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.this.name
}

output "ipv4_address" {
  description = "IPv4 address (from QEMU Guest Agent)"
  value       = try(proxmox_virtual_environment_vm.this.ipv4_addresses[1][0], var.ip_address)
}

output "mac_address" {
  description = "MAC address"
  value       = proxmox_virtual_environment_vm.this.mac_addresses[0]
}

output "node_name" {
  description = "Proxmox node"
  value       = proxmox_virtual_environment_vm.this.node_name
}
