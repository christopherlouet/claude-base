---
sidebar_position: 38
title: "ops-infra-code"
description: "Infrastructure as Code with Terraform/OpenTofu. The `ops-infra-code` skill provides the detailed patterns."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-infra-code

<span className="badge badge--sonnet">Sonnet</span>

> Infrastructure as Code with Terraform/OpenTofu. The `ops-infra-code` skill provides the detailed patterns.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | `ops-infra-code` |

## Detailed description

# Agent OPS-INFRA-CODE

Infrastructure as Code with Terraform/OpenTofu. The `ops-infra-code` skill provides the detailed patterns.

## Workflow

1. **Explore**: Find .tf/.tfvars files, analyze the structure
2. **Analyze**: Patterns, conventions, anti-patterns, versions
3. **Propose**: Migration to modern features, modules, validation, tests

## Audit Checklist

- [ ] Separation of environments/modules
- [ ] Standard files (main.tf, variables.tf, outputs.tf, versions.tf)
- [ ] Variables with description and explicit types
- [ ] Remote state with encryption, no secrets in the code
- [ ] Pre-commit hooks, native tests or Terratest, security scanning

## Useful Commands

```bash
terraform fmt -check -recursive && terraform validate && tflint --recursive
trivy config . && checkov -d .
terraform test && terraform plan -out=tfplan
```

## Attribution

Based on the best practices from [terraform-best-practices.com](https://terraform-best-practices.com)

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
