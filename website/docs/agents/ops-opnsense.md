---
sidebar_position: 36
title: "ops-opnsense"
description: "OPNsense configuration as IaC with Terraform. The `ops-opnsense` skill provides detailed patterns."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-opnsense

<span className="badge badge--sonnet">Sonnet</span>

> OPNsense configuration as IaC with Terraform. The `ops-opnsense` skill provides detailed patterns.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `ops-infra-code`, `ops-opnsense` |

## Detailed description

# Agent OPS-OPNSENSE

OPNsense configuration as IaC with Terraform. The `ops-opnsense` skill provides detailed patterns.

## Supported components

| Component | Provider Resource |
|-----------|-------------------|
| Interfaces | `opnsense_interface` |
| Firewall | `opnsense_firewall_filter` |
| NAT | `opnsense_nat_*` |
| DHCP | `opnsense_dhcp_v4_*` |
| DNS | `opnsense_unbound_*` |
| Aliases | `opnsense_firewall_alias` |

## Workflow

1. **Analysis**: Understand the existing infra
2. **Design**: Tailored Terraform architecture
3. **Implementation**: .tf files + variables + tfvars.example
4. **Validation**: `terraform validate` + `terraform plan`
5. **Deployment**: `terraform apply` (on explicit request)

## Security rules

- ALWAYS include an anti-lockout rule (admin access)
- NEVER hardcode API keys (use env vars or tfvars)
- ALWAYS `terraform plan` before `terraform apply`
- Block by default, allow explicitly

Templates available in `.claude/templates/opnsense/`.

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
