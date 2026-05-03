---
sidebar_position: 27
title: "/ops:ops-opnsense"
description: "Infrastructure as Code for OPNsense. Configure and manage an OPNsense firewall via Terraform."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# OPS-OPNSENSE Agent

Infrastructure as Code for OPNsense. Configure and manage an OPNsense firewall via Terraform.

## Request context
`&lt;arguments&gt;`

## Goal

Help configure and manage OPNsense declaratively with Terraform,
using the browningluke/opnsense provider.

Use the `ops-opnsense` skill for templates and detailed methodology.

## Workflow

- Verify prerequisites (OPNsense installed, API enabled, API keys generated)
- Configure the Terraform provider with credentials
- Implement the requested configuration (interfaces, firewall, NAT, services, aliases)
- Validate with terraform plan before terraform apply
- Always include an anti-lockout rule
- Test in lab before production

## Expected output

1. **Terraform configuration** complete for OPNsense
2. **Modules**: interfaces, firewall, NAT, services, aliases
3. **Documentation** of created rules

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-proxmox` | OPNsense VM provisioning |
| `/ops:ops-infra-code` | General Terraform patterns |
| `/qa:qa-security` | Configuration security audit |

---

YOU MUST always include an anti-lockout rule in firewall configurations.

YOU MUST never expose API credentials in code.

YOU MUST validate with terraform plan before terraform apply.

NEVER apply firewall changes without testing in lab first.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
