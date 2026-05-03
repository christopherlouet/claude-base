---
sidebar_position: 20
title: "/ops:ops-infra-code"
description: "Implements Infrastructure as Code (IaC) with Terraform, CloudFormation or Pulumi."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# INFRA-CODE Agent

Implements Infrastructure as Code (IaC) with Terraform, CloudFormation or Pulumi.

## Request context
`<arguments>`

## Objective

Define and manage infrastructure declaratively, reproducibly and version-controlled,
with reusable modules and a CI/CD pipeline.

Use the `ops-infra-code` skill for detailed Terraform patterns.

## Workflow

- Analyze infra needs (compute, storage, network, DB, security)
- Choose the appropriate IaC tool (Terraform, CloudFormation, Pulumi)
- Structure the project (environments, modules, shared)
- Create reusable modules (networking, compute, database, security)
- Configure the remote backend with state locking
- Write configurations per environment (dev, staging, prod)
- Validate (plan, tfsec, tflint, infracost) and deploy via CI/CD

## Expected output

1. **Structure** of the organized Terraform project
2. **Reusable modules** with variables, outputs
3. **Configuration** per environment
4. **CI/CD pipeline** for Terraform (validate, plan, apply)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Containerize the application |
| `/ops:ops-ci` | CI/CD pipeline |
| `/ops:ops-secrets-management` | Secrets management |
| `/ops:ops-cost-optimization` | Optimize costs |

---

IMPORTANT: Always run a terraform plan before apply.

YOU MUST use a remote backend for the state.

YOU MUST version the providers.

NEVER store secrets in Terraform code.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
