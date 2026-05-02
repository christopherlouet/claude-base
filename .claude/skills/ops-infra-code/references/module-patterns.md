# Module Development Patterns

> **Part of:** [infrastructure-as-code](../SKILL.md)
> **Goal:** Best practices for Terraform/OpenTofu module development

---

## Table of Contents

1. [Module Hierarchy](#module-hierarchy)
2. [Architecture Principles](#architecture-principles)
3. [Module Structure](#module-structure)
4. [Variables Best Practices](#variables-best-practices)
5. [Outputs Best Practices](#outputs-best-practices)
6. [Common Patterns](#common-patterns)
7. [Anti-patterns to Avoid](#anti-patterns-to-avoid)

---

## Module Hierarchy

### Module Type Classification

| Type | When to use | Scope | Example |
|------|-------------|-------|---------|
| **Resource Module** | Logical group of connected resources | Tightly coupled resources | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection of resource modules | Multiple modules in a region/account | Full network stack |
| **Composition** | Complete infrastructure | Spans multiple regions/accounts | Multi-region deployment |

### Resource Module

**Characteristics:**
- Smallest building block
- Single logical group of resources
- Highly reusable
- Minimal external dependencies

**Example:**
```
modules/
├── vpc/                    # Resource module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── security-group/         # Resource module
│   └── ...
└── rds/                    # Resource module
    └── ...
```

### Infrastructure Module

**Characteristics:**
- Combines multiple resource modules
- Specific to a goal (e.g., "web application infrastructure")
- Moderate reusability

**Example:**
```hcl
# modules/web-application/main.tf
module "vpc" {
  source = "../vpc"
}

module "alb" {
  source = "../alb"
  vpc_id = module.vpc.vpc_id
}

module "ecs" {
  source  = "../ecs"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnet_ids
}
```

### Composition

**Characteristics:**
- Highest level of abstraction
- Complete environment or application
- Environment-specific (dev, staging, prod)
- Not reusable (specific values)

**Structure:**
```
environments/
├── prod/
│   ├── main.tf
│   ├── backend.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── staging/
│   └── ...
└── dev/
    └── ...
```

---

## Architecture Principles

### 1. Smaller Scopes = Better Performance + Reduced Blast Radius

**Benefits:**
- Faster `terraform plan` and `apply` operations
- Isolated failures don't affect unrelated infrastructure
- Easier to reason about changes
- Parallel development by multiple teams

### 2. Always Use Remote State

```hcl
# GOOD - Remote state
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

**Why:**
- Prevents race conditions
- Provides disaster recovery
- Enables team collaboration
- Supports state locking

### 3. Use terraform_remote_state as Glue

```hcl
# environments/prod/compute/main.tf
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "prod/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ec2" {
  source = "../../modules/ec2"

  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
}
```

---

## Module Structure

### Standard Layout

```
my-module/
├── README.md               # Usage documentation
├── LICENSE                 # MIT or Apache 2.0 (public modules)
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── main.tf                 # Main resources
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Version constraints
├── examples/
│   ├── simple/             # Minimal example
│   └── complete/           # Complete example
└── tests/
    └── module_test.tftest.hcl
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.92.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_docs
```

### .gitignore Template

```gitignore
# .gitignore - Terraform/OpenTofu projects
**/.terraform/*
.terraform.lock.hcl
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
.env
.env.*
secrets/
*.secret
*.pem
*.key
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store
*.tfplan
*.tfplan.json
```

---

## Variables Best Practices

### Complete Example

```hcl
variable "instance_type" {
  description = "EC2 instance type for the application server"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Type must be t3.micro, t3.small, or t3.medium."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Enable CloudWatch detailed monitoring"
  type        = bool
  default     = true
}
```

### Key Principles

- **Always include `description`** - Helps understand the variable
- **Use explicit `type` constraints** - Catches errors early
- **Provide sensible `default` values** - When appropriate
- **Add `validation` blocks** - For complex constraints
- **Use `sensitive = true`** - For secrets

### Variable Naming

```hcl
# GOOD: Context-specific
var.vpc_cidr_block          # Not just "cidr"
var.database_instance_class # Not just "instance_class"
var.application_port        # Not just "port"

# BAD: Generic names
var.name
var.type
var.value
```

---

## Outputs Best Practices

### Complete Example

```hcl
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the created EC2 instance"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.this.private_ip
  sensitive   = false
}

output "connection_info" {
  description = "Connection information for the instance"
  value = {
    id         = aws_instance.this.id
    private_ip = aws_instance.this.private_ip
    public_dns = aws_instance.this.public_dns
  }
}
```

### Key Principles

- **Always include `description`** - Explain the output's purpose
- **Mark sensitive outputs** - `sensitive = true`
- **Return objects for related values** - Groups data logically
- **Document intended usage** - What should consumers do?

---

## Common Patterns

### DO: Use `for_each` for Resources

```hcl
# GOOD: Keeps resource addresses stable
resource "aws_instance" "server" {
  for_each = toset(["web", "api", "worker"])

  instance_type = "t3.micro"
  tags = {
    Name = each.key
  }
}
```

### DON'T: Use `count` When Order Matters

```hcl
# BAD: Removing the middle element recreates all subsequent ones
resource "aws_instance" "server" {
  count = length(var.server_names)

  tags = {
    Name = var.server_names[count.index]
  }
}
```

### DO: Separate Root Module from Reusable Modules

```
# Root module (environment-specific)
prod/
  main.tf          # Calls modules with prod values

# Reusable module
modules/webapp/
  main.tf          # Generic parameterized resources
```

### DO: Use Locals for Computed Values

```hcl
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  instance_name = "${var.project}-${var.environment}-instance"
}

resource "aws_instance" "app" {
  tags = local.common_tags
}
```

---

## Anti-patterns to Avoid

### DON'T: Hardcode Environment-Specific Values

```hcl
# BAD: Module locked to production
resource "aws_instance" "app" {
  instance_type = "m5.large"
  tags = {
    Environment = "production"
  }
}
```

**Fix:** Make everything configurable.

### DON'T: Create God Modules

```hcl
# BAD: One module does everything
module "everything" {
  source = "./modules/app-infrastructure"
  # Creates VPC, EC2, RDS, S3, IAM, etc.
}
```

**Fix:** Split into focused modules.

### DON'T: Use count/for_each in Root Modules for Environments

```hcl
# BAD: All environments in one root module
resource "aws_instance" "app" {
  for_each = toset(["dev", "staging", "prod"])

  instance_type = each.key == "prod" ? "m5.large": "t3.micro"
}
```

**Fix:** Use separate root modules.

---

**Back to:** [Main Skill File](../SKILL.md)
