# Code Patterns & Structure

> **Partie de :** [infrastructure-as-code](../SKILL.md)
> **Objectif :** Patterns de code et features modernes pour Terraform/OpenTofu

---

## Table des Matieres

1. [Ordre et Structure des Blocs](#ordre-et-structure-des-blocs)
2. [Count vs For_Each en Profondeur](#count-vs-for_each-en-profondeur)
3. [Features Modernes Terraform (1.0+)](#features-modernes-terraform-10)
4. [Gestion des Versions](#gestion-des-versions)
5. [Patterns de Refactoring](#patterns-de-refactoring)
6. [Locals pour Gestion des Dependances](#locals-pour-gestion-des-dependances)

---

## Ordre et Structure des Blocs

### Structure Bloc Resource

**Ordre strict des arguments :**

1. `count` ou `for_each` EN PREMIER (ligne vide apres)
2. Autres arguments (alphabetique ou groupement logique)
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
    Name        = "${var.name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}

# MAUVAIS - Ordre incorrect
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this[0].id
  tags = { Name = "nat" }
  count = var.create_nat_gateway ? 1 : 0  # Devrait etre premier
  subnet_id = aws_subnet.public[0].id
}
```

### Structure Definition Variable

**Ordre des blocs variable :**

1. `description` (TOUJOURS requis)
2. `type`
3. `default`
4. `sensitive` (quand true)
5. `nullable` (quand false)
6. `validation`

```hcl
# BON - Ordre et structure corrects
variable "environment" {
  description = "Nom de l'environnement pour le tagging"
  type        = string
  default     = "dev"
  nullable    = false

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "L'environnement doit etre : dev, staging, prod."
  }
}
```

### Patterns de Types de Variables Modernes (Terraform 1.3+)

```hcl
# BON - Utilisation de optional() pour attributs d'objet
variable "database_config" {
  description = "Configuration base de donnees avec parametres optionnels"
  type = object({
    name               = string
    engine             = string
    instance_class     = string
    backup_retention   = optional(number, 7)       # Default: 7
    monitoring_enabled = optional(bool, true)      # Default: true
    tags               = optional(map(string), {}) # Default: {}
  })
}

# Usage - seuls les champs requis necessaires
database_config = {
  name           = "mydb"
  engine         = "mysql"
  instance_class = "db.t3.micro"
  # Les champs optionnels utilisent les defaults
}
```

### Structure Output

**Pattern :** `{name}_{type}_{attribute}`

```hcl
# BON
output "security_group_id" {
  description = "ID du security group"
  value       = try(aws_security_group.this[0].id, "")
}

output "private_subnet_ids" {  # Pluriel pour liste
  description = "Liste des IDs de subnets prives"
  value       = aws_subnet.private[*].id
}

# MAUVAIS
output "this_security_group_id" {  # Ne pas prefixer avec "this_"
  value = aws_security_group.this[0].id
}
```

---

## Count vs For_Each en Profondeur

### Quand Utiliser count

**Replication numerique simple :**
```hcl
resource "aws_subnet" "public" {
  count = 3

  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
}
```

**Conditions booleennes (creer ou non) :**
```hcl
# BON - Condition booleenne
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0
}
```

### Quand Utiliser for_each

**Reference par cle :**
```hcl
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, index(var.availability_zones, each.key))
}

# Reference par cle : aws_subnet.private["us-east-1a"]
```

**Elements pouvant etre ajoutes/supprimes du milieu :**
```hcl
# MAUVAIS avec count - supprimer element du milieu recree tous les suivants
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
}

# BON avec for_each - suppression n'affecte que cette ressource
resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)
  availability_zone = each.key
}
```

### Migration Count vers For_Each

**Etapes de migration :**

1. Ajouter `for_each` a la ressource
2. Utiliser blocs `moved` pour preserver les ressources existantes
3. Supprimer `count` apres verification avec `terraform plan`

```hcl
# Blocs de migration (previent recreation)
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

# Verifier : terraform plan devrait montrer "moved", pas destroy/create
```

---

## Features Modernes Terraform (1.0+)

### Fonction try() (Terraform 0.13+)

```hcl
# BON - Fonction try() moderne
output "security_group_id" {
  description = "ID du security group"
  value       = try(aws_security_group.this[0].id, "")
}

output "first_subnet_id" {
  description = "ID du premier subnet avec fallbacks multiples"
  value       = try(
    aws_subnet.public[0].id,
    aws_subnet.private[0].id,
    ""
  )
}

# MAUVAIS - Pattern legacy
output "security_group_id" {
  value = element(concat(aws_security_group.this.*.id, [""]), 0)
}
```

### nullable = false (Terraform 1.1+)

```hcl
# BON (Terraform 1.1+)
variable "vpc_cidr" {
  description = "Bloc CIDR pour le VPC"
  type        = string
  nullable    = false  # Passer null utilise default, pas null
  default     = "10.0.0.0/16"
}
```

### optional() avec Defaults (Terraform 1.3+)

```hcl
# BON - Utilisation de optional() pour attributs d'objet
variable "database_config" {
  description = "Configuration DB avec parametres optionnels"
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

### Blocs Moved (Terraform 1.1+)

**Renommer ressources sans destroy/recreate :**

```hcl
# Renommer une ressource
moved {
  from = aws_instance.web_server
  to   = aws_instance.web
}

# Renommer un module
moved {
  from = module.old_module_name
  to   = module.new_module_name
}

# Deplacer ressource dans for_each
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["us-east-1a"]
}
```

### Validation Cross-Variable (Terraform 1.9+)

```hcl
variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}

variable "storage_size" {
  description = "Taille du stockage en GB"
  type        = number

  validation {
    # Peut referencer var.instance_type en Terraform 1.9+
    condition = !(
      var.instance_type == "db.t3.micro" &&
      var.storage_size > 1000
    )
    error_message = "Instances micro ne peuvent pas avoir storage > 1000 GB"
  }
}

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
}

variable "backup_retention" {
  description = "Periode de retention backup en jours"
  type        = number

  validation {
    condition = (
      var.environment == "prod" ? var.backup_retention >= 7 : true
    )
    error_message = "L'environnement prod necessite backup_retention >= 7 jours"
  }
}
```

### Arguments Write-Only (Terraform 1.11+)

```hcl
# BON - Secret externe avec argument write-only
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

  # write-only: Terraform envoie a AWS puis oublie (pas dans le state)
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string
}

# MAUVAIS - Secret finit dans le state file
resource "random_password" "db" {
  length = 16
}

resource "aws_db_instance" "this" {
  password = random_password.db.result  # Stocke dans le state!
}
```

---

## Gestion des Versions

### Syntaxe des Contraintes

```hcl
# Version exacte (eviter sauf necessaire - inflexible)
version = "5.0.0"

# Contrainte pessimiste (recommande pour stabilite)
version = "~> 5.0"      # Permet 5.0.x (tout x), mais pas 5.1.0
version = "~> 5.0.1"    # Permet 5.0.x ou x >= 1, mais pas 5.1.0

# Contraintes de plage
version = ">= 5.0, < 6.0"     # Toute version 5.x
version = ">= 5.0.0, < 5.1.0" # Plage de version mineure specifique

# Version minimum
version = ">= 5.0"  # Toute version 5.0 ou superieure (risque)
```

### Strategie par Composant

**Terraform lui-meme :**
```hcl
terraform {
  required_version = "~> 1.9"  # Permet 1.9.x
}
```

**Providers :**
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

**Modules :**
```hcl
# Production - pin version exacte
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"
}

# Developpement - autoriser flexibilite
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"
}
```

### Template versions.tf

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

## Patterns de Refactoring

### Migration 0.12/0.13 vers 1.x

**Checklist de remplacement patterns legacy :**

- [ ] Remplacer `element(concat(...))` par `try()`
- [ ] Ajouter `nullable = false` aux variables qui ne devraient pas accepter null
- [ ] Utiliser `optional()` dans types object pour attributs optionnels
- [ ] Ajouter blocs `validation` aux variables avec contraintes
- [ ] Migrer secrets vers arguments write-only (Terraform 1.11+)
- [ ] Utiliser blocs `moved` pour refactoring ressources (Terraform 1.1+)
- [ ] Considerer validation cross-variable (Terraform 1.9+)

### Remediation Secrets

**Avant - Secrets dans le State :**
```hcl
# MAUVAIS - Secret genere et stocke dans le state
resource "random_password" "db" {
  length  = 16
  special = true
}

resource "aws_db_instance" "this" {
  engine   = "mysql"
  username = "admin"
  password = random_password.db.result  # Dans le state!
}
```

**Apres - Gestion de Secrets Externe :**
```hcl
# BON - Recuperer depuis AWS Secrets Manager
data "aws_secretsmanager_secret" "db_password" {
  name = "prod-database-password"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "this" {
  engine   = "mysql"
  username = "admin"

  # write-only: Envoye a AWS, pas stocke dans le state
  password_wo = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

---

## Locals pour Gestion des Dependances

**Utiliser locals pour indiquer l'ordre de suppression correct :**

```hcl
# BON - Force l'ordre de suppression correct
# Assure que les subnets sont supprimes avant les blocs CIDR secondaires

locals {
  # Reference CIDR secondaire d'abord, fallback vers VPC
  # Force Terraform a supprimer les subnets avant l'association CIDR
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
  count = var.add_secondary_cidr ? 1 : 0

  vpc_id     = aws_vpc.this.id
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  # Utilise local au lieu de reference directe
  # Cree dependance implicite sur l'association CIDR
  vpc_id     = local.vpc_id
  cidr_block = "10.1.0.0/24"
}

# Sans local: Terraform pourrait essayer de supprimer CIDR avant subnets -> ERREUR
# Avec local: Subnets supprimes en premier, puis association CIDR, puis VPC
```

**Pourquoi c'est important :**
- Previent les erreurs de suppression lors de la destruction d'infrastructure
- Assure l'ordre de dependance correct sans `depends_on` explicite
- Particulierement utile pour configurations VPC complexes avec blocs CIDR secondaires

---

**Retour vers :** [Fichier Skill Principal](../SKILL.md)
