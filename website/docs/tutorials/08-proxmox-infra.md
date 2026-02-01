---
sidebar_position: 9
title: "08 - Infrastructure Proxmox"
description: Déployez une infrastructure Proxmox avec Terraform et monitoring
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Infrastructure Proxmox avec Terraform

<DifficultyBadge level="advanced" /> **Durée estimée : 60 minutes**

Ce tutoriel vous montre comment déployer et gérer une infrastructure Proxmox VE en utilisant Terraform et les outils claude-socle.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/ops:ops-proxmox` pour gérer Proxmox
- Utiliser `/ops:ops-infra-code` pour l'Infrastructure as Code
- Créer des VMs et conteneurs LXC avec Terraform
- Mettre en place le monitoring et les backups

## Prérequis

- Serveur Proxmox VE installé et accessible
- Terraform installé localement
- Token API Proxmox créé
- Connaissances de base en virtualisation

## Contexte

Nous allons créer une infrastructure complète comprenant :
- 2 VMs Ubuntu pour une application web
- 1 conteneur LXC pour la base de données
- Configuration réseau avec VLAN
- Monitoring et backups automatisés

## Étape 1 : Configurer l'accès Proxmox

### Créer un token API

Dans Proxmox :
1. **Datacenter > Permissions > API Tokens**
2. Créer un token pour votre utilisateur
3. Noter l'ID et le secret

### Configurer Terraform

```bash
/ops:ops-infra-code "Configurer le provider Proxmox avec le provider bpg/proxmox"
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
  description = "URL de l'API Proxmox"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token API Proxmox (user@realm!token=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Ignorer la vérification SSL"
  type        = bool
  default     = false
}

variable "target_node" {
  description = "Node Proxmox cible"
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

## Étape 2 : Créer les VMs avec cloud-init

```bash
/ops:ops-proxmox "Créer 2 VMs Ubuntu 22.04 avec cloud-init pour une application web"
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

**`main.tf`** (racine)
```hcl
# Template cloud-init Ubuntu
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.target_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name    = "ubuntu-22.04-cloudimg-amd64.img"
}

# VM Web 1
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

# VM Web 2
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

## Étape 3 : Créer le conteneur LXC pour la base de données

```bash
/ops:ops-proxmox "Créer un conteneur LXC pour PostgreSQL"
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

**Ajout au `main.tf`**
```hcl
# Template LXC Ubuntu
resource "proxmox_virtual_environment_download_file" "ubuntu_lxc_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.target_node
  url          = "http://download.proxmox.com/images/system/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  file_name    = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

# Conteneur PostgreSQL
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

## Étape 4 : Configurer les backups

```bash
/ops:ops-backup "Configurer les backups automatiques Proxmox"
```

**`backup.tf`**
```hcl
# Job de backup quotidien
resource "proxmox_virtual_environment_cluster_backup" "daily_backup" {
  schedule = "0 2 * * *"  # Tous les jours à 2h

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

## Étape 5 : Ajouter le monitoring

```bash
/ops:ops-monitoring "Ajouter le monitoring pour l'infrastructure Proxmox"
```

**Script d'installation sur chaque VM :**

```bash
#!/bin/bash
# install-monitoring.sh

# Node Exporter pour Prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

# Service systemd
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

## Étape 6 : Déployer l'infrastructure

```bash
# Initialiser Terraform
terraform init

# Vérifier le plan
terraform plan

# Appliquer
terraform apply
```

### Vérifier le déploiement

```bash
# Lister les ressources créées
terraform state list

# Voir les outputs
terraform output

# Se connecter à une VM
ssh ubuntu@10.0.10.11
```

## Étape 7 : Outputs utiles

**`outputs.tf`**
```hcl
output "web_vms" {
  description = "Informations des VMs web"
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
  description = "Informations du conteneur DB"
  value = {
    id   = module.db_container.vm_id
    ip   = "10.0.20.11"
    name = "db-01"
  }
}

output "ssh_commands" {
  description = "Commandes SSH pour se connecter"
  value = {
    web_01 = "ssh ubuntu@10.0.10.11"
    web_02 = "ssh ubuntu@10.0.10.12"
    db_01  = "ssh root@10.0.20.11"
  }
}
```

## Étape 8 : Commiter

```bash
/work:work-commit
```

**Message suggéré :**

```
feat(infra): add Proxmox infrastructure with Terraform

- Add provider configuration for bpg/proxmox
- Add VM module with cloud-init support
- Add LXC container module
- Create 2 web VMs and 1 database container
- Configure daily backups with retention policy
- Add monitoring setup with node_exporter
```

## Structure finale

```
infrastructure/
├── main.tf              # Ressources principales
├── providers.tf         # Configuration Terraform
├── variables.tf         # Variables
├── outputs.tf           # Outputs
├── terraform.tfvars     # Valeurs (non committé)
├── backup.tf            # Configuration backups
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

## Commandes utiles

| Commande | Description |
|----------|-------------|
| `terraform plan` | Voir les changements |
| `terraform apply` | Appliquer les changements |
| `terraform destroy` | Détruire l'infrastructure |
| `terraform state list` | Lister les ressources |
| `terraform output` | Voir les outputs |

## Prochaines étapes

- [Exemples Ops](/docs/examples)
- [Commande /ops:ops-infra-code](/docs/commands/ops/ops-infra-code)
- [Commande /ops:ops-monitoring](/docs/commands/ops/ops-monitoring)

---

:::tip Infrastructure as Code
Versionnez toujours votre code Terraform et utilisez un backend distant (S3, Consul) pour le state en équipe.
:::
