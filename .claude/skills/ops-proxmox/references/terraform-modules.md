# Terraform Modules — Proxmox

Modules Terraform reutilisables pour Proxmox (VM QEMU, LXC, utilisation).

## Module VM

### Variables

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

### Resource principale

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

### Outputs

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

## Module LXC

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

## Utilisation des modules

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

## Reseau

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

### VLAN tagging sur une VM

```hcl
network_device {
  bridge  = "vmbr0"
  vlan_id = 100
}
```

## Stockage

### Types de stockage Proxmox

| Type | Description | Performance | HA |
|------|-------------|-------------|-----|
| `local` | Repertoire local | Moyenne | Non |
| `local-lvm` | LVM local | Bonne | Non |
| `nfs` | NFS partage | Variable | Oui |
| `ceph` | Ceph RBD | Excellente | Oui |
| `zfs` | ZFS local | Excellente | Non |
| `zfs-over-iscsi` | ZFS sur iSCSI | Bonne | Oui |

### Configuration stockage partage

```hcl
resource "proxmox_virtual_environment_storage_nfs" "backup" {
  node_name  = var.target_node
  storage_id = "nfs-backup"
  server     = "nas.example.com"
  export     = "/volume1/proxmox-backup"
  content    = ["backup", "iso", "vztmpl"]
}
```
