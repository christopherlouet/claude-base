---
sidebar_position: 28
title: "/ops:ops-proxmox"
description: "Proxmox VE infrastructure management: VMs, LXC, network, storage, backup with Terraform."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# OPS-PROXMOX Agent

Proxmox VE infrastructure management: VMs, LXC, network, storage, backup with Terraform.

## Request context
`&lt;arguments&gt;`

## Objective

Deploy and manage a Proxmox VE infrastructure declaratively with Terraform,
using the bpg/proxmox provider.

Use the `ops-proxmox` skill for templates and detailed methodology.

## Workflow

- Analyze the existing infrastructure (nodes, storage, network, templates)
- Structure the Terraform project (VM, LXC, cloud-init, network modules)
- Configure the provider with an API token with minimal permissions
- Implement reusable modules (QEMU VM, LXC container)
- Configure backups with PBS
- Validate with terraform plan and apply

## Expected output

1. **Terraform structure** organized by environment
2. **Reusable modules** for VM and LXC
3. **PBS backup configuration**
4. **Inventory** of created resources (VMs, LXC, IPs)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-infra-code` | Generic IaC (AWS, GCP, Azure) |
| `/ops:ops-monitoring` | Infrastructure monitoring |
| `/ops:ops-backup` | Advanced backup strategy |

---

IMPORTANT: Always run terraform plan before apply.

YOU MUST create an API token with minimal permissions.

YOU MUST use unprivileged LXC containers by default.

NEVER store Proxmox credentials in the code.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
