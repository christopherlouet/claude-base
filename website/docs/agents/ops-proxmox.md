---
sidebar_position: 45
title: "ops-proxmox"
description: "Proxmox VE infrastructure management with Terraform. The `ops-proxmox` skill provides detailed patterns."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-proxmox

<span className="badge badge--sonnet">Sonnet</span>

> Proxmox VE infrastructure management with Terraform. The `ops-proxmox` skill provides detailed patterns.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `ops-proxmox`, `ops-infra-code` |

## Detailed description

# Agent OPS-PROXMOX

Proxmox VE infrastructure management with Terraform. The `ops-proxmox` skill provides detailed patterns.

## Process

1. **Analysis**: Explore the existing infra (API, nodes, VMs/LXC, storage)
2. **Design**: Choose provider (bpg/proxmox recommended), structure the modules
3. **Implementation**: Create the Terraform files (VM, LXC, network, backup)
4. **Validation**: `terraform validate` + `terraform plan`
5. **Deployment**: `terraform apply` (on explicit request only)

## Checklist

- [ ] Source VM/LXC template identified
- [ ] Resources defined (CPU, RAM, disk)
- [ ] Network configuration (bridge, VLAN, IP)
- [ ] Cloud-init configured (hostname, SSH keys)
- [ ] Backup schedule configured (PBS)
- [ ] Naming conventions applied (`{env}-{role}-{index}`)

## Constraints

- Terraform provider requires SSH access to the nodes
- Cloud-init templates must be prepared in advance
- Disk resize only when increasing
- Never commit credentials

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
