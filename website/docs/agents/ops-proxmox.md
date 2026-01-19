---
sidebar_position: 47
title: "ops-proxmox"
description: "Gestion d'infrastructure Proxmox VE (VMs, LXC, storage, réseau, backup)"
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-proxmox

<span className="badge badge--sonnet">Sonnet</span>

> Gestion d'infrastructure Proxmox VE (VMs, LXC, storage, réseau, backup)

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `proxmox-infrastructure`, `infrastructure-as-code` |

## Quand utiliser cet Agent

- Provisionner des VMs ou conteneurs LXC sur Proxmox
- Configurer le réseau (bridges, VLANs, SDN)
- Gérer le stockage (local, NFS, Ceph, ZFS)
- Configurer les backups avec Proxmox Backup Server
- Automatiser avec Terraform (provider bpg/proxmox)
- Monitorer et optimiser le cluster Proxmox

## Processus

### 1. Analyse de l'infrastructure existante

```bash
# Vérifier la connectivité API Proxmox
curl -k https://<proxmox-host>:8006/api2/json/version

# Lister les nodes du cluster
pvesh get /nodes --output-format json

# Lister les VMs et conteneurs
pvesh get /cluster/resources --type vm --output-format json
```

### 2. Choix du provider Terraform

| Provider | Avantages | Cas d'usage |
|----------|-----------|-------------|
| `bpg/proxmox` | Moderne, actif, bien documenté | Recommandé pour nouveaux projets |
| `telmate/proxmox` | Mature, large adoption | Projets existants |

### 3. Structure recommandée

```
infrastructure/
├── proxmox/
│   ├── main.tf              # Configuration provider
│   ├── variables.tf         # Variables d'entrée
│   ├── outputs.tf           # Outputs
│   ├── versions.tf          # Contraintes de versions
│   ├── terraform.tfvars     # Valeurs (gitignore)
│   ├── modules/
│   │   ├── vm/              # Module VM
│   │   ├── lxc/             # Module conteneur LXC
│   │   ├── network/         # Module réseau
│   │   └── storage/         # Module stockage
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
```

## Checklist de provisioning

### VMs

- [ ] Template VM source identifié (cloud-init ready)
- [ ] Ressources définies (CPU, RAM, disque)
- [ ] Configuration réseau (bridge, VLAN, IP)
- [ ] Cloud-init configuré (hostname, SSH keys, users)
- [ ] Tags et description ajoutés
- [ ] Backup schedule configuré

### Conteneurs LXC

- [ ] Template LXC source identifié
- [ ] Ressources définies (CPU, RAM, rootfs)
- [ ] Configuration réseau
- [ ] Features activées (nesting, FUSE, etc.)
- [ ] Unprivileged vs privileged décidé

## Templates Terraform

### Provider bpg/proxmox (recommandé)

```hcl
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure = var.proxmox_insecure

  ssh {
    agent = true
  }
}
```

### VM avec cloud-init

```hcl
resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = var.description
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
    datastore_id = var.datastore
    size         = var.disk_size_gb
    interface    = "scsi0"
  }

  network_device {
    bridge  = var.network_bridge
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
  }
}
```

## Commandes utiles

### API Proxmox (pvesh)

```bash
# Lister les nodes
pvesh get /nodes

# Lister les VMs d'un node
pvesh get /nodes/<node>/qemu

# Démarrer/Arrêter une VM
pvesh create /nodes/<node>/qemu/<vmid>/status/start
pvesh create /nodes/<node>/qemu/<vmid>/status/stop
```

### Terraform

```bash
# Initialiser
terraform init

# Planifier
terraform plan -var-file=environments/dev/terraform.tfvars

# Appliquer
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Bonnes pratiques

### Sécurité

- Utiliser un token API plutôt que user/password
- Créer un utilisateur dédié avec permissions minimales
- Ne jamais commiter les credentials
- Activer le firewall Proxmox
- Isoler les VLANs par environnement

### Naming conventions

| Resource | Pattern | Exemple |
|----------|---------|---------|
| VM | `{env}-{role}-{index}` | `prod-web-01` |
| LXC | `{env}-{service}-{index}` | `dev-redis-01` |
| Bridge | `vmbr{n}` | `vmbr0`, `vmbr1` |

## Output attendu

1. **Structure Terraform** complète avec modules
2. **Configuration provider** avec credentials sécurisés
3. **Modules réutilisables** pour VM, LXC, réseau, stockage
4. **Variables par environnement** (dev, staging, prod)
5. **Documentation** des ressources créées

---

## Voir aussi

- [/ops-proxmox](/docs/commands/ops/ops-proxmox) - Commande associée
- [Skill proxmox-infrastructure](/docs/skills/proxmox-infrastructure) - Skill auto-déclenché
- [Agent ops-infra-code](/docs/agents/ops-infra-code) - Infrastructure as Code générique
