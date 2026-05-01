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
  count = var.secondary_cidr_block != "" ? 1 : 0

  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr_block
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

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
  count = var.create_nat_gateway ? 1 : 0

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
  count = var.create_nat_gateway ? 1 : 0

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
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
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
