# Code Patterns & Structure

> **Part of:** [infrastructure-as-code](../SKILL.md)
> **Goal:** Code patterns and modern features for Terraform/OpenTofu

---

## Table of Contents

1. [Block Order and Structure](#block-order-and-structure)
2. [Count vs For_Each in Depth](#count-vs-for_each-in-depth)
3. [Modern Terraform Features (1.0+)](#modern-terraform-features-10)
4. [Version Management](#version-management)
5. [Refactoring Patterns](#refactoring-patterns)
6. [Locals for Dependency Management](#locals-for-dependency-management)

---

## Block Order and Structure

### Resource Block Structure

**Strict argument order:**

1. `count` or `for_each` FIRST (blank line after)
2. Other arguments (alphabetical or logical grouping)
3. `tags` as last real argument
4. `depends_on` after tags (if needed)
5. `lifecycle` at the very end (if needed)

```hcl
# GOOD - Correct order
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1: 0

  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "${var.name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}

# BAD - Incorrect order
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id
  tags = { Name = "nat" }
  count = var.create_nat_gateway ? 1: 0  # Should be first
  subnet_id = aws_subnet.public[0].id
}
```

### Variable Definition Structure

**Variable block order:**

1. `description` (ALWAYS required)
2. `type`
3. `default`
4. `sensitive` (when true)
5. `nullable` (when false)
6. `validation`

```hcl
# GOOD - Correct order and structure
variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
  nullable    = false

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging, prod."
  }
}
```

### Modern Variable Type Patterns (Terraform 1.3+)

```hcl
# GOOD - Using optional() for object attributes
variable "database_config" {
  description = "Database configuration with optional parameters"
  type = object({
    name               = string
    engine             = string
    instance_class     = string
    backup_retention   = optional(number, 7)       # Default: 7
    monitoring_enabled = optional(bool, true)      # Default: true
    tags               = optional(map(string), {}) # Default: {}
  })
}

# Usage - only required fields needed
database_config = {
  name           = "mydb"
  engine         = "mysql"
  instance_class = "db.t3.micro"
  # Optional fields use defaults
}
```

### Output Structure

**Pattern:** `{name}_{type}_{attribute}`

```hcl
# GOOD
output "security_group_id" {
  description = "Security group ID"
  value       = try(aws_security_group.this[0].id, "")
}

output "private_subnet_ids" {  # Plural for list
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# BAD
output "this_security_group_id" {  # Do not prefix with "this_"
  value = aws_security_group.this[0].id
}
```

---

## Count vs For_Each in Depth

### When to Use count

**Simple numeric replication:**
```hcl
resource "aws_subnet" "public" {
  count = 3

  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
}
```

**Boolean conditions (create or not):**
```hcl
# GOOD - Boolean condition
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1: 0
}
```

### When to Use for_each

**Reference by key:**
```hcl
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, index(var.availability_zones, each.key))
}

# Reference by key: aws_subnet.private["us-east-1a"]
```

**Elements that can be added/removed from the middle:**
```hcl
# BAD with count - removing a middle element recreates all subsequent ones
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
}

# GOOD with for_each - removal only affects that resource
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)
  availability_zone = each.key
}
```

### Migrating Count to For_Each

**Migration steps:**

1. Add `for_each` to the resource
2. Use `moved` blocks to preserve existing resources
3. Remove `count` after verifying with `terraform plan`

```hcl
# Migration blocks (prevents recreation)
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["us-east-1a"]
}

moved {
  from = aws_subnet.private[1]
  to   = aws_subnet.private["us-east-1b"]
}

moved {
  from = aws_subnet.private[2]
  to   = aws_subnet.private["us-east-1c"]
}

# Verify: terraform plan should show "moved", not destroy/create
```

---

## Modern Terraform Features (1.0+)

### try() Function (Terraform 0.13+)

```hcl
# GOOD - Modern try() function
output "security_group_id" {
  description = "Security group ID"
  value       = try(aws_security_group.this[0].id, "")
}

output "first_subnet_id" {
  description = "ID of first subnet with multiple fallbacks"
  value       = try(
    aws_subnet.public[0].id,
    aws_subnet.private[0].id,
    ""
  )
}

# BAD - Legacy pattern
output "security_group_id" {
  value = element(concat(aws_security_group.this.*.id, [""]), 0)
}
```

### nullable = false (Terraform 1.1+)

```hcl
# GOOD (Terraform 1.1+)
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  nullable    = false  # Passing null uses default, not null
  default     = "10.0.0.0/16"
}
```

### optional() with Defaults (Terraform 1.3+)

```hcl
# GOOD - Using optional() for object attributes
variable "database_config" {
  description = "DB configuration with optional parameters"
  type = object({
    name               = string
    engine             = string
    instance_class     = string
    backup_retention   = optional(number, 7)
    monitoring_enabled = optional(bool, true)
    tags               = optional(map(string), {})
  })
}
```

### Moved Blocks (Terraform 1.1+)

**Rename resources without destroy/recreate:**

```hcl
# Rename a resource
moved {
  from = aws_instance.web_server
  to   = aws_instance.web
}

# Rename a module
moved {
  from = module.old_module_name
  to   = module.new_module_name
}

# Move resource into for_each
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["us-east-1a"]
}
```

### Cross-Variable Validation (Terraform 1.9+)

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "storage_size" {
  description = "Storage size in GB"
  type        = number

  validation {
    # Can reference var.instance_type in Terraform 1.9+
    condition = !(
      var.instance_type == "db.t3.micro" &&
      var.storage_size > 1000
    )
    error_message = "Micro instances cannot have storage > 1000 GB"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number

  validation {
    condition = (
      var.environment == "prod" ? var.backup_retention >= 7: true
    )
    error_message = "Prod environment requires backup_retention >= 7 days"
  }
}
```

### Write-Only Arguments (Terraform 1.11+)

```hcl
# GOOD - External secret with write-only argument
data "aws_secretsmanager_secret" "db_password" {
  name = "prod-database-password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "this" {
  engine         = "mysql"
  instance_class = "db.t3.micro"
  username       = "admin"

  # write-only: Terraform sends to AWS then forgets (not in state)
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string
}

# BAD - Secret ends up in the state file
resource "random_password" "db" {
  length = 16
}

resource "aws_db_instance" "this" {
  password = random_password.db.result  # Stored in state!
}
```

---

## Version Management

### Constraint Syntax

```hcl
# Exact version (avoid unless necessary - inflexible)
version = "5.0.0"

# Pessimistic constraint (recommended for stability)
version = "~> 5.0"      # Allows 5.0.x (any x), but not 5.1.0
version = "~> 5.0.1"    # Allows 5.0.x where x >= 1, but not 5.1.0

# Range constraints
version = ">= 5.0, < 6.0"     # Any 5.x version
version = ">= 5.0.0, < 5.1.0" # Specific minor version range

# Minimum version
version = ">= 5.0"  # Any version 5.0 or higher (risky)
```

### Per-Component Strategy

**Terraform itself:**
```hcl
terraform {
  required_version = "~> 1.9"  # Allows 1.9.x
}
```

**Providers:**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Modules:**
```hcl
# Production - pin exact version
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
}

# Development - allow flexibility
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"
}
```

### versions.tf Template

```hcl
terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Refactoring Patterns

### Migration from 0.12/0.13 to 1.x

**Legacy patterns replacement checklist:**

- [ ] Replace `element(concat(...))` with `try()`
- [ ] Add `nullable = false` to variables that should not accept null
- [ ] Use `optional()` in object types for optional attributes
- [ ] Add `validation` blocks to variables with constraints
- [ ] Migrate secrets to write-only arguments (Terraform 1.11+)
- [ ] Use `moved` blocks for resource refactoring (Terraform 1.1+)
- [ ] Consider cross-variable validation (Terraform 1.9+)

### Secrets Remediation

**Before - Secrets in State:**
```hcl
# BAD - Secret generated and stored in state
resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_db_instance" "this" {
  engine   = "mysql"
  username = "admin"
  password = random_password.db.result  # In state!
}
```

**After - External Secrets Management:**
```hcl
# GOOD - Fetch from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_password" {
  name = "prod-database-password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "this" {
  engine   = "mysql"
  username = "admin"

  # write-only: Sent to AWS, not stored in state
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

---

## Locals for Dependency Management

**Use locals to enforce correct deletion order:**

```hcl
# GOOD - Forces correct deletion order
# Ensures subnets are deleted before secondary CIDR blocks

locals {
  # Reference secondary CIDR first, fallback to VPC
  # Forces Terraform to delete subnets before the CIDR association
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.this[0].vpc_id,
    aws_vpc.this.id,
    ""
  )
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = var.add_secondary_cidr ? 1: 0

  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  # Uses local instead of direct reference
  # Creates implicit dependency on the CIDR association
  vpc_id     = local.vpc_id
  cidr_block = "10.1.0.0/24"
}

# Without local: Terraform might try to delete CIDR before subnets -> ERROR
# With local: Subnets deleted first, then CIDR association, then VPC
```

**Why this matters:**
- Prevents deletion errors when destroying infrastructure
- Ensures correct dependency order without explicit `depends_on`
- Particularly useful for complex VPC configurations with secondary CIDR blocks

---

**Back to:** [Main Skill File](../SKILL.md)
