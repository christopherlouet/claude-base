---
name: ops-infra-code
description: Infrastructure as Code with Terraform/OpenTofu. Trigger to create modules, configure backends, write idiomatic HCL, or audit infrastructure.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
argument-hint: "[module-name]"
---

# Infrastructure as Code (Terraform / OpenTofu)

Complete guide for Terraform and OpenTofu covering modules, tests, CI/CD and production patterns.
Based on [terraform-best-practices.com](https://terraform-best-practices.com) and Anton Babenko's enterprise experience.

## When to use this Skill

**Activate this skill to:**
- Create Terraform/OpenTofu configurations or modules
- Set up the test infrastructure for IaC
- Choose between testing approaches (validate, plan, frameworks)
- Structure multi-environment deployments
- Implement CI/CD for infrastructure-as-code
- Review or refactor existing Terraform/OpenTofu projects

**Do not use for:**
- Basic syntax questions (Claude already knows)
- Provider-specific API reference (use the documentation)
- Cloud questions unrelated to Terraform/OpenTofu

## Core Principles

### 1. Module Hierarchy

| Type | When to use | Scope |
|------|-------------|-------|
| **Resource Module** | Logical group of connected resources | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection of resource modules | Several modules in a region/account |
| **Composition** | Complete infrastructure | Spans multiple regions/accounts |

**Hierarchy:** Resource -> Resource Module -> Infrastructure Module -> Composition

### 2. Directory Structure

```
environments/        # Configurations per environment
├── prod/
├── staging/
└── dev/

modules/            # Reusable modules
├── networking/
├── compute/
└── data/

examples/           # Usage examples (also serve as tests)
├── complete/
└── minimal/
```

### 3. Naming Conventions

**Resources:**
```hcl
# Good: Descriptive and contextual
resource "aws_instance" "web_server" { }
resource "aws_s3_bucket" "application_logs" { }

# Good: "this" for singleton resources (only one of this type)
resource "aws_vpc" "this" { }
resource "aws_security_group" "this" { }

# Avoid: Generic names for non-singletons
resource "aws_instance" "main" { }
```

**Variables:**
```hcl
# Prefix with context
var.vpc_cidr_block          # Not just "cidr"
var.database_instance_class # Not just "instance_class"
```

**Files:**
- `main.tf` - Main resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Provider versions

## Block Order

### Resource Block

**Strict order for consistency:**
1. `count` or `for_each` FIRST (blank line after)
2. Other arguments
3. `tags` as the last real argument
4. `depends_on` after tags (if necessary)
5. `lifecycle` at the very end (if necessary)

```hcl
# GOOD - Correct order
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1: 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}
```

### Variable Block

1. `description` (ALWAYS required)
2. `type`
3. `default`
4. `validation`
5. `nullable` (when false)

```hcl
variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging, or prod."
  }

  nullable = false
}
```

## Count vs For_Each

### Quick Decision Guide

| Scenario | Use | Why |
|----------|-----|-----|
| Boolean condition (create or not) | `count = condition ? 1: 0` | Simple on/off toggle |
| Simple numeric replication | `count = 3` | Fixed number of identical resources |
| Items that may be reordered/deleted | `for_each = toset(list)` | Stable resource addresses |
| Reference by key | `for_each = map` | Named access to resources |

### Common Patterns

**Boolean conditions:**
```hcl
# GOOD - Boolean condition
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1: 0
  # ...
}
```

**Stable addressing with for_each:**
```hcl
# GOOD - Removing "us-east-1b" only affects this subnet
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  availability_zone = each.key
  # ...
}

# BAD - Removing the middle AZ recreates all the following ones
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  # ...
}
```

## Testing Strategy

### Decision Matrix

| Situation | Recommended Approach | Tools | Cost |
|-----------|---------------------|-------|------|
| **Quick syntax check** | Static analysis | `terraform validate`, `fmt` | Free |
| **Pre-commit validation** | Static + lint | `validate`, `tflint`, `trivy` | Free |
| **Terraform 1.6+, simple logic** | Native test framework | `terraform test` | Free-Low |
| **Pre-1.6, or Go expertise** | Integration tests | Terratest | Low-Medium |
| **Security/compliance focus** | Policy as code | OPA, Sentinel | Free |
| **Cost-sensitive workflow** | Mock providers (1.7+) | Native tests + mocking | Free |

### Testing Pyramid for Infrastructure

```
        /\
       /  \          End-to-End Tests (Expensive)
      /____\         - Full environment deployment
     /      \        - Production-like setup
    /________\
   /          \      Integration Tests (Moderate)
  /____________\     - Module testing in isolation
 /              \    - Real resources in test account
/________________\   Static Analysis (Inexpensive)
                     - validate, fmt, lint
                     - Security scanning
```

## Security and Compliance

### Essential Security Checks

```bash
# Static security scanning
trivy config .
checkov -d .
```

### Common Issues to Avoid

**DO NOT:**
- Store secrets in variables
- Use the default VPC
- Omit encryption
- Open security groups to 0.0.0.0/0

**DO:**
- Use AWS Secrets Manager / Parameter Store
- Create dedicated VPCs
- Enable encryption at rest
- Use least-privilege security groups

## Version Management

### Constraint Syntax

```hcl
version = "5.0.0"      # Exact (avoid - inflexible)
version = "~> 5.0"     # Recommended: 5.0.x only
version = ">= 5.0"     # Minimum (risky - breaking changes)
```

### Strategy per Component

| Component | Strategy | Example |
|-----------|----------|---------|
| **Terraform** | Pin minor version | `required_version = "~> 1.9"` |
| **Providers** | Pin major version | `version = "~> 5.0"` |
| **Modules (prod)** | Pin exact version | `version = "5.1.2"` |
| **Modules (dev)** | Allow patch updates | `version = "~> 5.1"` |

## Modern Features (1.0+)

| Feature | Version | Use case |
|---------|---------|----------|
| `try()` function | 0.13+ | Safe fallbacks, replaces `element(concat())` |
| `nullable = false` | 1.1+ | Prevent null values in variables |
| `moved` blocks | 1.1+ | Refactor without destroy/recreate |
| `optional()` with defaults | 1.3+ | Optional object attributes |
| Native tests | 1.6+ | Built-in test framework |
| Mock providers | 1.7+ | Unit tests at no cost |
| Cross-variable validation | 1.9+ | Validate relationships between variables |
| Write-only arguments | 1.11+ | Secrets never stored in state |

## Detailed Guides

This skill uses **progressive disclosure** - essential information in this file, detailed guides available via external resources:

- **Module Patterns** - Structure, variables/outputs, DO vs DON'T
- **Code Patterns** - Modern features, refactoring, locals
- **Testing Frameworks** - Static analysis, native tests, Terratest
- **Security & Compliance** - Trivy/Checkov, secrets management, state file

See [terraform-best-practices.com](https://terraform-best-practices.com) for the full guides.

## Attribution

This skill is adapted from [terraform-skill](https://github.com/antonbabenko/terraform-skill) by Anton Babenko.
Additional resources:
- [terraform-best-practices.com](https://terraform-best-practices.com)
- [Compliance.tf](https://compliance.tf)
