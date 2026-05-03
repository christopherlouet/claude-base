---
sidebar_position: 4
title: Proxmox VM
description: Example Proxmox VM with Terraform and cloud-init
---

# Proxmox VM with Terraform

This example shows how to create a Proxmox VM with Terraform, cloud-init, and automated configuration.

## Command used

```bash
/ops:ops-proxmox "Create an Ubuntu VM with cloud-init and network configuration"
```

## Generated structure

```
infrastructure/
├── main.tf              # VM and resources
├── providers.tf         # Proxmox configuration
├── variables.tf         # Variables
├── outputs.tf           # Outputs
├── terraform.tfvars     # Values (not committed)
└── cloud-init/
    ├── user-data.yaml   # Cloud-init configuration
    └── network-config.yaml
```

## Terraform code

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
  description = "Proxmox API URL (e.g., https://pve.example.com:8006)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!token=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip SSL verification (dev only)"
  type        = bool
  default     = false
}

variable "target_node" {
  description = "Target Proxmox node"
  type        = string
  default     = "pve"
}

# ====================
# VM Configuration
# ====================

variable "vm_name" {
  description = "VM name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vm_name))
    error_message = "Name must contain only lowercase letters, digits, and hyphens."
  }
}

variable "vm_id" {
  description = "VM ID (100-999999)"
  type        = number

  validation {
    condition     = var.vm_id >= 100 && var.vm_id <= 999999
    error_message = "ID must be between 100 and 999999."
  }
}

variable "vm_description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2

  validation {
    condition     = var.cores >= 1 && var.cores <= 128
    error_message = "Number of cores must be between 1 and 128."
  }
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 512 && var.memory <= 524288
    error_message = "Memory must be between 512 MB and 512 GB."
  }
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "datastore" {
  description = "Datastore for the disk"
  type        = string
  default     = "local-lvm"
}

# ====================
# Network Configuration
# ====================

variable "bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID (null for no VLAN)"
  type        = number
  default     = null
}

variable "ip_address" {
  description = "IP address with CIDR (e.g., 10.0.10.11/24)"
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

# ====================
# Cloud-Init
# ====================

variable "cloud_image_url" {
  description = "Cloud image URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "username" {
  description = "Username to create"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "packages" {
  description = "Packages to install"
  type        = list(string)
  default     = ["qemu-guest-agent", "curl", "wget", "htop", "vim"]
}

variable "runcmd" {
  description = "Commands to run on first boot"
  type        = list(string)
  default     = []
}

# ====================
# Tags
# ====================

variable "tags" {
  description = "VM tags"
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

  # Verify the checksum (optional but recommended)
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

      # User
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

      # System configuration
      timezone = "Europe/Paris"
      locale   = "en_US.UTF-8"

      # Commands on first boot
      runcmd = concat([
        # Enable qemu-guest-agent
        "systemctl enable qemu-guest-agent",
        "systemctl start qemu-guest-agent",

        # Disable automatic updates in prod
        "systemctl disable apt-daily.timer",
        "systemctl disable apt-daily-upgrade.timer",
      ], var.runcmd)

      # Final message
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

  # QEMU agent
  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  # Startup
  on_boot  = true
  started  = true
  boot_order = ["scsi0"]

  # CPU
  cpu {
    cores   = var.cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  # Memory
  memory {
    dedicated = var.memory
    floating  = 0  # No ballooning
  }

  # System disk
  disk {
    datastore_id = var.datastore
    file_id      = proxmox_virtual_environment_download_file.cloud_image.id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  # SCSI controller
  scsi_hardware = "virtio-scsi-single"

  # Network
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

  # Avoid recreation for cloud-init changes
  lifecycle {
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }

  # Serial console (required for cloud-init)
  serial_device {}

  # VGA
  vga {
    type = "serial0"
  }
}

# ====================
# DNS Record (optional)
# ====================

# If you use a DNS provider
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
  description = "VM ID"
  value       = proxmox_virtual_environment_vm.main.vm_id
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_virtual_environment_vm.main.name
}

output "ip_address" {
  description = "VM IP address"
  value       = split("/", var.ip_address)[0]
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh ${var.username}@${split("/", var.ip_address)[0]}"
}

output "mac_address" {
  description = "VM MAC address"
  value       = proxmox_virtual_environment_vm.main.network_device[0].mac_address
}
```

### `terraform.tfvars.example`

```hcl
# Proxmox
proxmox_endpoint  = "https://pve.example.com:8006"
proxmox_api_token = "root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure  = true  # false in production with valid cert
target_node       = "pve"

# VM
vm_name = "web-01"
vm_id   = 100

# Resources
cores     = 2
memory    = 4096
disk_size = 40

# Network
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

## Deployment

```bash
# Initialize
terraform init

# Plan
terraform plan -var-file="terraform.tfvars"

# Apply
terraform apply -var-file="terraform.tfvars"

# Connect
eval $(terraform output -raw ssh_command)
```

## Create multiple VMs

```hcl
# variables.tf
variable "vms" {
  description = "Map of VMs to create"
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

  # ... rest of the config
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

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Provider** | bpg/proxmox (recommended) |
| **Cloud-Init** | Full YAML configuration |
| **Network** | VLAN, static IP, DNS |
| **Security** | SSH key, no password |
| **Scalability** | `for_each` for clusters |

## Related commands

- `/ops:ops-proxmox` - Dedicated Proxmox command
- `/ops:ops-infra-code` - Generic Terraform modules
- `/ops:ops-backup` - Proxmox backup configuration

---

:::tip Proxmox templates
Create a cloud-init template once, then clone it to speed up deployments:
```bash
qm template 9000
```
:::
