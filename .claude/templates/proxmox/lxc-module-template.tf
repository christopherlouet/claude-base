# =============================================================================
# Template: Terraform LXC Proxmox Module
# Usage: Copy into modules/lxc/ and adapt to your needs
# Provider: bpg/proxmox >= 0.50
# =============================================================================

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "hostname" {
  description = "Container hostname"
  type        = string
}

variable "description" {
  description = "Container description"
  type        = string
  default     = "Managed by Terraform"
}

variable "target_node" {
  description = "Target Proxmox node"
  type        = string
}

variable "template_file_id" {
  description = "LXC template ID (e.g.: local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst)"
  type        = string
}

variable "os_type" {
  description = "OS type (ubuntu, debian, alpine, etc.)"
  type        = string
  default     = "ubuntu"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "memory_mb" {
  description = "RAM in MB"
  type        = number
  default     = 512
}

variable "swap_mb" {
  description = "Swap in MB"
  type        = number
  default     = 512
}

variable "disk_size_gb" {
  description = "Rootfs size in GB"
  type        = number
  default     = 8
}

variable "datastore" {
  description = "Datastore for the rootfs"
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

variable "ssh_keys" {
  description = "Public SSH keys"
  type        = list(string)
}

variable "root_password" {
  description = "Root password (optional, prefer SSH)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Container tags"
  type        = list(string)
  default     = ["terraform"]
}

variable "unprivileged" {
  description = "Unprivileged container (recommended)"
  type        = bool
  default     = true
}

variable "start_on_boot" {
  description = "Automatically start on node boot"
  type        = bool
  default     = true
}

# LXC features
variable "nesting" {
  description = "Enable nesting (Docker in LXC)"
  type        = bool
  default     = false
}

variable "fuse" {
  description = "Enable FUSE"
  type        = bool
  default     = false
}

variable "keyctl" {
  description = "Enable keyctl"
  type        = bool
  default     = false
}

variable "mount_types" {
  description = "Allowed mount types"
  type        = list(string)
  default     = []
}

# Additional mountpoints
variable "mountpoints" {
  description = "Additional mountpoints"
  type = list(object({
    volume    = string
    path      = string
    size      = optional(number)
    read_only = optional(bool, false)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# LXC Resource
# -----------------------------------------------------------------------------

resource "proxmox_virtual_environment_container" "this" {
  description   = var.description
  node_name     = var.target_node
  tags          = var.tags
  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  started       = true

  # OS template
  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  # CPU
  cpu {
    cores = var.cpu_cores
  }

  # Memory
  memory {
    dedicated = var.memory_mb
    swap      = var.swap_mb
  }

  # Rootfs
  disk {
    datastore_id = var.datastore
    size         = var.disk_size_gb
  }

  # Additional mountpoints
  dynamic "mount_point" {
    for_each = var.mountpoints
    content {
      volume    = mount_point.value.volume
      path      = mount_point.value.path
      size      = mount_point.value.size
      read_only = mount_point.value.read_only
    }
  }

  # Network
  network_interface {
    name    = "eth0"
    bridge  = var.network_bridge
    vlan_id = var.vlan_id
  }

  # Initialization
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
  description = "Container ID"
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "hostname" {
  description = "Container hostname"
  value       = var.hostname
}

output "ipv4_address" {
  description = "IPv4 address"
  value       = var.ip_address
}

output "node_name" {
  description = "Proxmox node"
  value       = proxmox_virtual_environment_container.this.node_name
}
