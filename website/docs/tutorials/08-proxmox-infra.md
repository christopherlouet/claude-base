---
sidebar_position: 9
title: "08 - Proxmox Infrastructure"
description: Deploy a Proxmox infrastructure with Terraform and monitoring
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Proxmox Infrastructure with Terraform

<DifficultyBadge level="advanced" /> **Estimated duration: 60 minutes**

This tutorial shows you how to deploy and manage a Proxmox VE infrastructure using Terraform and the claude-socle tools.

## Objectives

By the end of this tutorial, you will know how to:
- Use `/ops:ops-proxmox` to manage Proxmox
- Use `/ops:ops-infra-code` for Infrastructure as Code
- Create VMs and LXC containers with Terraform
- Set up monitoring and backups

## Prerequisites

- Proxmox VE server installed and accessible
- Terraform installed locally
- Proxmox API token created
- Basic knowledge of virtualization

## Context

We will create a complete infrastructure including:
- 2 Ubuntu VMs for a web application
- 1 LXC container for the database
- Network configuration with VLAN
- Automated monitoring and backups

## Step 1: Configure Proxmox access

### Create an API token

In Proxmox:
1. **Datacenter > Permissions > API Tokens**
2. Create a token for your user
3. Note the ID and the secret

### Configure Terraform

```bash
/ops:ops-infra-code "Configure the Proxmox provider with the bpg/proxmox provider"
```

**`providers.tf`**
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

**`variables.tf`**
```hcl
variable "proxmox_endpoint" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (user@realm!token=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip SSL verification"
  type        = bool
  default     = false
}

variable "target_node" {
  description = "Target Proxmox node"
  type        = string
  default     = "pve"
}
```

**`terraform.tfvars.example`**
```hcl
proxmox_endpoint  = "https://proxmox.example.com:8006"
proxmox_api_token = "root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
proxmox_insecure  = true
target_node       = "pve"
```

## Step 2: Create the VMs with cloud-init

```bash
/ops:ops-proxmox "Create 2 Ubuntu 22.04 VMs with cloud-init for a web application"
```

**`modules/vm/main.tf`**
```hcl
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id

  tags = var.tags

  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore
    file_id      = var.cloud_image_id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      username = var.username
      keys     = var.ssh_keys
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  lifecycle {
    ignore_changes = [
      initialization[0].user_data_file_id,
    ]
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - qemu-guest-agent
      - curl
      - wget
      - htop
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
    EOF

    file_name = "${var.name}-cloud-config.yaml"
  }
}
```

**`main.tf`** (root)
```hcl
# Ubuntu cloud-init template
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.target_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "ubuntu-22.04-cloudimg-amd64.img"
}

# Web VM 1
module "web_vm_1" {
  source = "./modules/vm"

  name           = "web-01"
  node_name      = var.target_node
  vm_id          = 100
  cores          = 2
  memory         = 2048
  disk_size      = 20
  datastore      = "local-lvm"
  cloud_image_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  bridge         = "vmbr0"
  vlan_id        = 10
  ip_address     = "10.0.10.11/24"
  gateway        = "10.0.10.1"
  username       = "ubuntu"
  ssh_keys       = [file("~/.ssh/id_rsa.pub")]
  tags           = ["web", "production"]
}

# Web VM 2
module "web_vm_2" {
  source = "./modules/vm"

  name           = "web-02"
  node_name      = var.target_node
  vm_id          = 101
  cores          = 2
  memory         = 2048
  disk_size      = 20
  datastore      = "local-lvm"
  cloud_image_id = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  bridge         = "vmbr0"
  vlan_id        = 10
  ip_address     = "10.0.10.12/24"
  gateway        = "10.0.10.1"
  username       = "ubuntu"
  ssh_keys       = [file("~/.ssh/id_rsa.pub")]
  tags           = ["web", "production"]
}
```

## Step 3: Create the LXC container for the database

```bash
/ops:ops-proxmox "Create an LXC container for PostgreSQL"
```

**`modules/lxc/main.tf`**
```hcl
resource "proxmox_virtual_environment_container" "container" {
  node_name = var.node_name
  vm_id     = var.vm_id

  description = var.description
  tags        = var.tags

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

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore
    size         = var.disk_size
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    template_file_id = var.template_id
    type             = "ubuntu"
  }

  features {
    nesting = true
  }

  unprivileged = true
  start_on_boot = true
}
```

**Add to `main.tf`**
```hcl
# Ubuntu LXC template
resource "proxmox_virtual_environment_download_file" "ubuntu_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.target_node
  url          = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  file_name    = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

# PostgreSQL container
module "db_container" {
  source = "./modules/lxc"

  node_name    = var.target_node
  vm_id        = 200
  hostname     = "db-01"
  description  = "PostgreSQL Database Server"
  cores        = 2
  memory       = 4096
  swap         = 512
  disk_size    = 50
  datastore    = "local-lvm"
  template_id  = proxmox_virtual_environment_download_file.ubuntu_lxc_template.id
  bridge       = "vmbr0"
  vlan_id      = 20
  ip_address   = "10.0.20.11/24"
  gateway      = "10.0.20.1"
  ssh_keys     = [file("~/.ssh/id_rsa.pub")]
  tags         = ["database", "production"]
}
```

## Step 4: Configure backups

```bash
/ops:ops-backup "Configure automated Proxmox backups"
```

**`backup.tf`**
```hcl
# Daily backup job
resource "proxmox_virtual_environment_cluster_backup" "daily_backup" {
  schedule = "0 2 * * *"  # Every day at 2am

  backup_target_storage = "backup-storage"
  compression           = "zstd"
  mode                  = "snapshot"
  notification_mode     = "failure"

  vm_ids = [
    module.web_vm_1.vm_id,
    module.web_vm_2.vm_id,
    module.db_container.vm_id,
  ]

  retention {
    daily   = 7
    weekly  = 4
    monthly = 3
  }
}
```

## Step 5: Add monitoring

```bash
/ops:ops-monitoring "Add monitoring for the Proxmox infrastructure"
```

**Installation script on each VM:**

```bash
#!/bin/bash
# install-monitoring.sh

# Node Exporter for Prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# systemd service
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

sudo useradd -rs /bin/false node_exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

## Step 6: Deploy the infrastructure

```bash
# Initialize Terraform
terraform init

# Check the plan
terraform plan

# Apply
terraform apply
```

### Verify the deployment

```bash
# List the created resources
terraform state list

# View the outputs
terraform output

# Connect to a VM
ssh ubuntu@10.0.10.11
```

## Step 7: Useful outputs

**`outputs.tf`**
```hcl
output "web_vms" {
  description = "Web VMs information"
  value = {
    web_01 = {
      id   = module.web_vm_1.vm_id
      ip   = "10.0.10.11"
      name = "web-01"
    }
    web_02 = {
      id   = module.web_vm_2.vm_id
      ip   = "10.0.10.12"
      name = "web-02"
    }
  }
}

output "db_container" {
  description = "DB container information"
  value = {
    id   = module.db_container.vm_id
    ip   = "10.0.20.11"
    name = "db-01"
  }
}

output "ssh_commands" {
  description = "SSH commands to connect"
  value = {
    web_01 = "ssh ubuntu@10.0.10.11"
    web_02 = "ssh ubuntu@10.0.10.12"
    db_01  = "ssh root@10.0.20.11"
  }
}
```

## Step 8: Commit

```bash
/work:work-commit
```

**Suggested message:**

```
feat(infra): add Proxmox infrastructure with Terraform

- Add provider configuration for bpg/proxmox
- Add VM module with cloud-init support
- Add LXC container module
- Create 2 web VMs and 1 database container
- Configure daily backups with retention policy
- Add monitoring setup with node_exporter
```

## Final structure

```
infrastructure/
├── main.tf              # Main resources
├── providers.tf         # Terraform configuration
├── variables.tf         # Variables
├── outputs.tf           # Outputs
├── terraform.tfvars     # Values (not committed)
├── backup.tf            # Backup configuration
├── modules/
│   ├── vm/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lxc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── scripts/
    └── install-monitoring.sh
```

## Useful commands

| Command | Description |
|----------|-------------|
| `terraform plan` | View the changes |
| `terraform apply` | Apply the changes |
| `terraform destroy` | Destroy the infrastructure |
| `terraform state list` | List the resources |
| `terraform output` | View the outputs |

## Next steps

- [Ops Examples](/docs/examples)
- [Command /ops:ops-infra-code](/docs/commands/ops/ops-infra-code)
- [Command /ops:ops-monitoring](/docs/commands/ops/ops-monitoring)

---

:::tip Infrastructure as Code
Always version your Terraform code and use a remote backend (S3, Consul) for the state when working as a team.
:::
