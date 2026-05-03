---
sidebar_position: 31
title: "ops-infra-code"
description: "Infrastructure as Code with Terraform/OpenTofu. Trigger to create modules, configure backends, write idiomatic HCL, or audit infrastructure."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-infra-code

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Infrastructure as Code with Terraform/OpenTofu. Trigger to create modules, configure backends, write idiomatic HCL, or audit infrastructure.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops`, `infra`, `code` |

## Detailed description

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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_
- _"I want to infra..."_
- _"I want to code..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: Complete AWS VPC Module

# Example: Complete AWS VPC Module

> This example illustrates the patterns from the infrastructure-as-code skill

## Module Structure

```
modules/vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
└── tests/
    └── vpc.tftest.hcl
```

## main.tf

```hcl
locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Module    = "vpc"
      ManagedBy = "Terraform"
    }
  )

  # Force correct deletion order
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.secondary[0].vpc_id,
    aws_vpc.this.id,
    ""
  )
}

# Main VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    local.common_tags,
    {
      Name = var.name
    }
  )
}

# Secondary CIDR block (optional)
resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  count = var.secondary_cidr_block != "" ? 1: 0

  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr_block
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1: 0

  vpc_id = local.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = toset(var.availability_zones)

  vpc_id                  = local.vpc_id
  cidr_block              = cidrsubnet(var.cidr_block, 4, index(var.availability_zones, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-public-${each.key}"
      Type = "public"
    }
  )
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  vpc_id            = local.vpc_id
  cidr_block        = cidrsubnet(var.cidr_block, 4, index(var.availability_zones, each.key) + length(var.availability_zones))
  availability_zone = each.key

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-private-${each.key}"
      Type = "private"
    }
  )
}

# NAT Gateway (optional)
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1: 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1: 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-nat"
    }
  )

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}
```

## variables.tf

```hcl
variable "name" {
  description = "VPC name, used for tagging"
  type        = string
  nullable    = false
}

variable "cidr_block" {
  description = "Main CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid CIDR block."
  }
}

variable "secondary_cidr_block" {
  description = "Optional secondary CIDR block"
  type        = string
  default     = ""

  validation {
    condition     = var.secondary_cidr_block == "" || can(cidrhost(var.secondary_cidr_block, 0))
    error_message = "secondary_cidr_block must be empty or a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for HA."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Create an Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

## outputs.tf

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public: subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private: subnet.id]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = try(aws_internet_gateway.this[0].id, "")
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = try(aws_nat_gateway.this[0].id, "")
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}
```

## versions.tf

```hcl
terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## tests/vpc.tftest.hcl

```hcl
# Test with mock provider for fast execution
mock_provider "aws" {}

# Test 1: Validate minimal configuration
run "minimal_vpc" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "Default CIDR should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled by default"
  }
}

# Test 2: Verify subnet creation
run "subnets_created" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Should create 3 public subnets"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Should create 3 private subnets"
  }
}

# Test 3: CIDR validation
run "invalid_cidr_rejected" {
  command = plan

  variables {
    name       = "test-vpc"
    cidr_block = "invalid-cidr"
  }

  expect_failures = [var.cidr_block]
}

# Test 4: Minimum 2 AZs required
run "minimum_azs_required" {
  command = plan

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a"]  # Only 1 AZ
  }

  expect_failures = [var.availability_zones]
}

# Test 5: Optional NAT Gateway
run "nat_gateway_created_when_enabled" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b"]
    create_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "NAT Gateway should be created when enabled"
  }
}
```

## Usage

```hcl
# Minimal example
module "vpc" {
  source = "./modules/vpc"

  name               = "my-app"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}

# Complete example
module "vpc" {
  source = "./modules/vpc"

  name               = "production"
  cidr_block         = "10.100.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  create_igw         = true
  create_nat_gateway = true

  tags = {
    Environment = "production"
    Project     = "my-app"
    CostCenter  = "engineering"
  }
}
```

## Attribution

This module follows the best practices from [terraform-skill](https://github.com/antonbabenko/terraform-skill) by Anton Babenko.



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
