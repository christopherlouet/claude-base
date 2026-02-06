---
sidebar_position: 24
title: "ops-infra-code"
description: "Infrastructure as Code avec Terraform/OpenTofu. Declencher pour creer modules, configurer backends, ecrire HCL idiomatique, ou auditer infrastructure."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-infra-code

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Infrastructure as Code avec Terraform/OpenTofu. Declencher pour creer modules, configurer backends, ecrire HCL idiomatique, ou auditer infrastructure.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `ops`, `infra`, `code`, `aws_instance`, `web_server`, `aws_s3_bucket`, `application_logs`, `this` |

## Description detaillee

# Infrastructure as Code (Terraform / OpenTofu)

Guide complet pour Terraform et OpenTofu couvrant modules, tests, CI/CD et patterns de production.
Base sur [terraform-best-practices.com](https://terraform-best-practices.com) et l'experience enterprise d'Anton Babenko.

## Quand utiliser ce Skill

**Activer ce skill pour :**
- Creer des configurations ou modules Terraform/OpenTofu
- Mettre en place l'infrastructure de tests pour IaC
- Choisir entre les approches de test (validate, plan, frameworks)
- Structurer des deploiements multi-environnements
- Implementer CI/CD pour l'infrastructure-as-code
- Revoir ou refactorer des projets Terraform/OpenTofu existants

**Ne pas utiliser pour :**
- Questions de syntaxe basiques (Claude connait deja)
- Reference API specifique aux providers (utiliser la doc)
- Questions cloud non liees a Terraform/OpenTofu

## Principes Fondamentaux

### 1. Hierarchie des Modules

| Type | Quand utiliser | Portee |
|------|----------------|--------|
| **Resource Module** | Groupe logique de ressources connectees | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection de resource modules | Plusieurs modules dans une region/compte |
| **Composition** | Infrastructure complete | Couvre plusieurs regions/comptes |

**Hierarchie :** Resource -> Resource Module -> Infrastructure Module -> Composition

### 2. Structure de Repertoire

```
environments/        # Configurations par environnement
├── prod/
├── staging/
└── dev/

modules/            # Modules reutilisables
├── networking/
├── compute/
└── data/

examples/           # Exemples d'utilisation (servent aussi de tests)
├── complete/
└── minimal/
```

### 3. Conventions de Nommage

**Ressources :**
```hcl
# Bon : Descriptif et contextuel
resource "aws_instance" "web_server" { }
resource "aws_s3_bucket" "application_logs" { }

# Bon : "this" pour ressources singleton (une seule de ce type)
resource "aws_vpc" "this" { }
resource "aws_security_group" "this" { }

# Eviter : Noms generiques pour non-singletons
resource "aws_instance" "main" { }
```

**Variables :**
```hcl
# Prefixer avec le contexte
var.vpc_cidr_block          # Pas juste "cidr"
var.database_instance_class # Pas juste "instance_class"
```

**Fichiers :**
- `main.tf` - Ressources principales
- `variables.tf` - Variables d'entree
- `outputs.tf` - Valeurs de sortie
- `versions.tf` - Versions des providers

## Ordre des Blocs

### Bloc Resource

**Ordre strict pour la coherence :**
1. `count` ou `for_each` EN PREMIER (ligne vide apres)
2. Autres arguments
3. `tags` comme dernier argument reel
4. `depends_on` apres tags (si necessaire)
5. `lifecycle` a la toute fin (si necessaire)

```hcl
# BON - Ordre correct
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

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

### Bloc Variable

1. `description` (TOUJOURS requis)
2. `type`
3. `default`
4. `validation`
5. `nullable` (quand false)

```hcl
variable "environment" {
  description = "Nom de l'environnement pour le tagging"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit etre : dev, staging, ou prod."
  }

  nullable = false
}
```

## Count vs For_Each

### Guide de Decision Rapide

| Scenario | Utiliser | Pourquoi |
|----------|----------|----------|
| Condition booleenne (creer ou non) | `count = condition ? 1 : 0` | Simple toggle on/off |
| Replication numerique simple | `count = 3` | Nombre fixe de ressources identiques |
| Elements pouvant etre reordonnes/supprimes | `for_each = toset(list)` | Adresses de ressources stables |
| Reference par cle | `for_each = map` | Acces nomme aux ressources |

### Patterns Courants

**Conditions booleennes :**
```hcl
# BON - Condition booleenne
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0
  # ...
}
```

**Adressage stable avec for_each :**
```hcl
# BON - Supprimer "us-east-1b" n'affecte que ce subnet
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  availability_zone = each.key
  # ...
}

# MAUVAIS - Supprimer l'AZ du milieu recree tous les suivants
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  availability_zone = var.availability_zones[count.index]
  # ...
}
```

## Strategie de Tests

### Matrice de Decision

| Situation | Approche Recommandee | Outils | Cout |
|-----------|---------------------|--------|------|
| **Verification syntaxe rapide** | Analyse statique | `terraform validate`, `fmt` | Gratuit |
| **Validation pre-commit** | Statique + lint | `validate`, `tflint`, `trivy` | Gratuit |
| **Terraform 1.6+, logique simple** | Framework de test natif | `terraform test` | Gratuit-Faible |
| **Pre-1.6, ou expertise Go** | Tests d'integration | Terratest | Faible-Moyen |
| **Focus securite/compliance** | Policy as code | OPA, Sentinel | Gratuit |
| **Workflow sensible aux couts** | Mock providers (1.7+) | Tests natifs + mocking | Gratuit |

### Pyramide de Tests pour Infrastructure

```
        /\
       /  \          Tests End-to-End (Couteux)
      /____\         - Deploiement environnement complet
     /      \        - Setup production-like
    /________\
   /          \      Tests d'Integration (Modere)
  /____________\     - Test de module en isolation
 /              \    - Vraies ressources en compte de test
/________________\   Analyse Statique (Peu couteux)
                     - validate, fmt, lint
                     - Scanning securite
```

## Securite et Compliance

### Checks de Securite Essentiels

```bash
# Scanning securite statique
trivy config .
checkov -d .
```

### Issues Courantes a Eviter

**NE PAS :**
- Stocker des secrets dans les variables
- Utiliser le VPC par defaut
- Omettre le chiffrement
- Ouvrir les security groups a 0.0.0.0/0

**FAIRE :**
- Utiliser AWS Secrets Manager / Parameter Store
- Creer des VPCs dedies
- Activer le chiffrement au repos
- Utiliser des security groups least-privilege

## Gestion des Versions

### Syntaxe des Contraintes

```hcl
version = "5.0.0"      # Exact (eviter - inflexible)
version = "~> 5.0"     # Recommande : 5.0.x seulement
version = ">= 5.0"     # Minimum (risque - breaking changes)
```

### Strategie par Composant

| Composant | Strategie | Exemple |
|-----------|-----------|---------|
| **Terraform** | Pin version mineure | `required_version = "~> 1.9"` |
| **Providers** | Pin version majeure | `version = "~> 5.0"` |
| **Modules (prod)** | Pin version exacte | `version = "5.1.2"` |
| **Modules (dev)** | Autoriser patch updates | `version = "~> 5.1"` |

## Features Modernes (1.0+)

| Feature | Version | Cas d'usage |
|---------|---------|-------------|
| `try()` function | 0.13+ | Fallbacks surs, remplace `element(concat())` |
| `nullable = false` | 1.1+ | Prevenir valeurs null dans les variables |
| `moved` blocks | 1.1+ | Refactorer sans destroy/recreate |
| `optional()` avec defaults | 1.3+ | Attributs d'objet optionnels |
| Tests natifs | 1.6+ | Framework de test integre |
| Mock providers | 1.7+ | Tests unitaires sans cout |
| Cross-variable validation | 1.9+ | Valider relations entre variables |
| Write-only arguments | 1.11+ | Secrets jamais stockes dans le state |

## Guides Detailles

Ce skill utilise le **progressive disclosure** - informations essentielles dans ce fichier, guides détaillés disponibles via les ressources externes :

- **Module Patterns** - Structure, variables/outputs, DO vs DON'T
- **Code Patterns** - Features modernes, refactoring, locals
- **Testing Frameworks** - Analyse statique, tests natifs, Terratest
- **Security & Compliance** - Trivy/Checkov, gestion secrets, state file

Consultez [terraform-best-practices.com](https://terraform-best-practices.com) pour les guides complets.

## Attribution

Ce skill est adapte de [terraform-skill](https://github.com/antonbabenko/terraform-skill) par Anton Babenko.
Ressources additionnelles :
- [terraform-best-practices.com](https://terraform-best-practices.com)
- [Compliance.tf](https://compliance.tf)

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux ops..."_
- _"Je veux infra..."_
- _"Je veux code..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple : Module VPC AWS Complet

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



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
