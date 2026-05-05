---
sidebar_position: 35
title: "ops-proxmox"
description: "Proxmox VE infrastructure with Terraform (VMs, LXC, network, storage, backup)"
tags:
  - "skill"
  - "fork"
---

# Skill: ops-proxmox

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Proxmox VE infrastructure with Terraform (VMs, LXC, network, storage, backup)

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops`, `proxmox`, `pve`, `proxmox ve`, `proxmox vm`, `proxmox lxc` |

## Detailed description

# Proxmox Infrastructure Skill

Proxmox VE infrastructure management with Terraform: provisioning of virtual machines, LXC containers, network configuration, storage and backup.

## When to use this skill

This skill is automatically activated when the conversation mentions:
- "Proxmox", "PVE", "Proxmox VE"
- "Proxmox VM", "Proxmox LXC", "Proxmox container"
- "Proxmox cluster", "Proxmox node"
- "PBS", "Proxmox Backup Server"
- "Proxmox cloud-init"
- "QEMU/KVM" in a Proxmox context

## Core principles

### 1. Infrastructure as Code

All Proxmox infrastructure must be managed via Terraform:
- **Reproducibility**: same config = same result
- **Versioning**: history in Git
- **Review**: PR to validate infra changes
- **Documentation**: the code IS the documentation

### 2. Environment separation

```
environments/
├── dev/           # Can be destroyed
├── staging/       # Mirrors prod
└── prod/          # Critical
```

Each environment has its own variables (`terraform.tfvars`), its own Terraform state and its own credentials.

### 3. Reusable modules

```
modules/
├── vm/            # QEMU/KVM virtual machine
├── lxc/           # LXC container
├── network/       # Network configuration
├── storage/       # Storage configuration
└── backup/        # PBS configuration
```

## Proxmox architecture

### Resource hierarchy

```
Datacenter
├── Cluster (optional)
│   ├── Node 1 (pve1) → VMs, LXC, Storage, Network
│   ├── Node 2 (pve2)
│   └── Node 3 (pve3)
├── Storage (datacenter level)
│   ├── local, local-lvm (per node)
│   ├── nfs-shared (shared)
│   └── ceph (distributed)
└── SDN (Zones, VNets, Subnets)
```

### Resource types

| Type | Description | Use case |
|------|-------------|----------|
| **VM (QEMU)** | Full virtual machine | Heavy workloads, strong isolation |
| **LXC** | System container | Lightweight services, high density |
| **Template** | Base image | Fast cloning of VMs/LXC |
| **Snippet** | cloud-init files | Automated configuration |

## Terraform provider

### bpg/proxmox (recommended)

Modern, well-maintained provider, full coverage of the Proxmox API.

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token  # Recommended token
  insecure  = var.proxmox_insecure   # Dev only

  ssh {
    agent    = true
    username = "root"
  }
}
```

### API token authentication

```bash
# On the Proxmox node
pveum user token add terraform@pve terraform-token --privsep=0

# Minimal permissions
pveum aclmod / -user terraform@pve -role PVEVMAdmin
pveum aclmod /storage -user terraform@pve -role PVEDatastoreUser
```

Format: `terraform@pve!terraform-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

## Naming conventions

### VMs and containers

| Environment | Pattern | Example |
|---------------|---------|---------|
| Production | `prod-{role}-{index}` | `prod-web-01` |
| Staging | `stg-{role}-{index}` | `stg-api-01` |
| Development | `dev-{role}-{index}` | `dev-db-01` |
| Test | `test-{purpose}` | `test-migration` |

### VMID ranges

| Range | Usage |
|-------|-------|
| 100-199 | Infrastructure (DNS, DHCP, etc.) |
| 200-299 | Production |
| 300-399 | Staging |
| 400-499 | Development |
| 500-599 | Test/Temporary |
| 9000-9099 | Templates |

### Recommended tags

```
environment:prod
role:webserver
team:platform
backup:daily
managed-by:terraform
criticality:high
```

## Security

### Best practices

1. **API Token**: minimal permissions (dedicated role, not root)
2. **Firewall**: enable the Proxmox firewall by default
3. **Isolation**: separate VLANs per environment
4. **Unprivileged LXC**: always use unprivileged containers
5. **Audit**: log API and SSH access
6. **Secrets**: NEVER hardcode in HCL (use Vault, TF_VAR_*, or gitignored tfvars)

### Minimal Terraform permissions

```bash
# Dedicated role
pveum role add TerraformRole -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Use"

# User + assignment
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role TerraformRole
```

## References

This SKILL.md section contains the core principles. For technical details with full HCL examples, see the reference files:

| File | Content |
|---------|---------|
| [`references/terraform-modules.md`](https://github.com/christopherlouet/claude-base/blob/main/.claude/skills/ops-proxmox/references/terraform-modules.md) | VM modules, LXC, usage, network, storage |
| [`references/cloud-init.md`](https://github.com/christopherlouet/claude-base/blob/main/.claude/skills/ops-proxmox/references/cloud-init.md) | cloud-config templates, snippet uploads |
| [`references/backup-ha.md`](https://github.com/christopherlouet/claude-base/blob/main/.claude/skills/ops-proxmox/references/backup-ha.md) | PBS schedule, commands, HA configuration |
| [`references/troubleshooting.md`](https://github.com/christopherlouet/claude-base/blob/main/.claude/skills/ops-proxmox/references/troubleshooting.md) | Common issues, diagnostic commands, recovery |

## Rules

IMPORTANT: NEVER manage Proxmox manually via the UI. Always via Terraform.

IMPORTANT: Use unprivileged LXC by default (limited privilege escalation).

IMPORTANT: One Terraform state per environment (dev/staging/prod isolated).

YOU MUST use the `bpg/proxmox` provider (modern, maintained) rather than `telmate/proxmox` (deprecated).

YOU MUST use API tokens with minimal permissions, never root.

NEVER hardcode secrets in committed HCL. Use gitignored tfvars or Vault.

NEVER skip PBS backups on critical VMs.

## Attribution

This skill is based on:
- [Official Proxmox VE documentation](https://pve.proxmox.com/wiki/Main_Page)
- [bpg/proxmox Terraform provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_
- _"I want to proxmox..."_
- _"I want to pve..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
