# Exemple : Module VPC AWS Complet

> Cet exemple illustre les patterns du skill infrastructure-as-code

## Structure du Module

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
  # Tags communs pour toutes les ressources
  common_tags = merge(
    var.tags,
    {
      Module    = "vpc"
      ManagedBy = "Terraform"
    }
  )

  # Force l'ordre de suppression correct
  vpc_id = try(
    aws_vpc_ipv4_cidr_block_association.secondary[0].vpc_id,
    aws_vpc.this.id,
    ""
  )
}

# VPC principal
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

# CIDR bloc secondaire (optionnel)
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

# Subnets publics
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

# Subnets prives
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

# NAT Gateway (optionnel)
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
  description = "Nom du VPC, utilise pour le tagging"
  type        = string
  nullable    = false
}

variable "cidr_block" {
  description = "Bloc CIDR principal pour le VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Le cidr_block doit etre un bloc CIDR valide."
  }
}

variable "secondary_cidr_block" {
  description = "Bloc CIDR secondaire optionnel"
  type        = string
  default     = ""

  validation {
    condition     = var.secondary_cidr_block == "" || can(cidrhost(var.secondary_cidr_block, 0))
    error_message = "Le secondary_cidr_block doit etre vide ou un bloc CIDR valide."
  }
}

variable "availability_zones" {
  description = "Liste des zones de disponibilite pour les subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Au moins 2 zones de disponibilite sont requises pour la HA."
  }
}

variable "enable_dns_hostnames" {
  description = "Activer les DNS hostnames dans le VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Activer le support DNS dans le VPC"
  type        = bool
  default     = true
}

variable "create_igw" {
  description = "Creer une Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Creer une NAT Gateway pour les subnets prives"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags additionnels a appliquer a toutes les ressources"
  type        = map(string)
  default     = {}
}
```

## outputs.tf

```hcl
output "vpc_id" {
  description = "ID du VPC cree"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN du VPC cree"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "Bloc CIDR du VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Liste des IDs des subnets publics"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Liste des IDs des subnets prives"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, "")
}

output "nat_gateway_id" {
  description = "ID de la NAT Gateway"
  value       = try(aws_nat_gateway.this[0].id, "")
}

output "availability_zones" {
  description = "Zones de disponibilite utilisees"
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
# Test avec mock provider pour execution rapide
mock_provider "aws" {}

# Test 1: Valider configuration minimale
run "minimal_vpc" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "Le CIDR par defaut devrait etre 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames devrait etre active par defaut"
  }
}

# Test 2: Verifier creation subnets
run "subnets_created" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Devrait creer 3 subnets publics"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Devrait creer 3 subnets prives"
  }
}

# Test 3: Validation du CIDR
run "invalid_cidr_rejected" {
  command = plan

  variables {
    name       = "test-vpc"
    cidr_block = "invalid-cidr"
  }

  expect_failures = [var.cidr_block]
}

# Test 4: Minimum 2 AZs requis
run "minimum_azs_required" {
  command = plan

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a"]  # Seulement 1 AZ
  }

  expect_failures = [var.availability_zones]
}

# Test 5: NAT Gateway optionnel
run "nat_gateway_created_when_enabled" {
  command = apply

  variables {
    name               = "test-vpc"
    availability_zones = ["us-east-1a", "us-east-1b"]
    create_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "NAT Gateway devrait etre creee quand activee"
  }
}
```

## Usage

```hcl
# Exemple minimal
module "vpc" {
  source = "./modules/vpc"

  name               = "my-app"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}

# Exemple complet
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

Ce module suit les bonnes pratiques de [terraform-skill](https://github.com/antonbabenko/terraform-skill) par Anton Babenko.
