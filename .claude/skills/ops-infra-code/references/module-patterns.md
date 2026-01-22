# Module Development Patterns

> **Partie de :** [infrastructure-as-code](../SKILL.md)
> **Objectif :** Bonnes pratiques pour le developpement de modules Terraform/OpenTofu

---

## Table des Matieres

1. [Hierarchie des Modules](#hierarchie-des-modules)
2. [Principes d'Architecture](#principes-darchitecture)
3. [Structure de Module](#structure-de-module)
4. [Bonnes Pratiques Variables](#bonnes-pratiques-variables)
5. [Bonnes Pratiques Outputs](#bonnes-pratiques-outputs)
6. [Patterns Courants](#patterns-courants)
7. [Anti-patterns a Eviter](#anti-patterns-a-eviter)

---

## Hierarchie des Modules

### Classification des Types de Modules

| Type | Quand utiliser | Portee | Exemple |
|------|----------------|--------|---------|
| **Resource Module** | Groupe logique de ressources connectees | Ressources etroitement couplees | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection de resource modules | Plusieurs modules dans une region/compte | Stack reseau complete |
| **Composition** | Infrastructure complete | Couvre plusieurs regions/comptes | Deploiement multi-region |

### Resource Module

**Caracteristiques :**
- Plus petit bloc de construction
- Groupe logique unique de ressources
- Hautement reutilisable
- Dependances externes minimales

**Exemple :**
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

**Caracteristiques :**
- Combine plusieurs resource modules
- Specifique a un objectif (ex: "infrastructure application web")
- Reutilisabilite moderee

**Exemple :**
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

**Caracteristiques :**
- Plus haut niveau d'abstraction
- Environnement ou application complete
- Specifique a l'environnement (dev, staging, prod)
- Non reutilisable (valeurs specifiques)

**Structure :**
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

## Principes d'Architecture

### 1. Portees Plus Petites = Meilleures Performances + Blast Radius Reduit

**Avantages :**
- Operations `terraform plan` et `apply` plus rapides
- Echecs isoles n'affectent pas l'infrastructure non concernee
- Plus facile de raisonner sur les changements
- Developpement parallele par plusieurs equipes

### 2. Toujours Utiliser Remote State

```hcl
# BON - Remote state
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

**Pourquoi :**
- Previent les race conditions
- Fournit disaster recovery
- Permet collaboration d'equipe
- Supporte le state locking

### 3. Utiliser terraform_remote_state comme Glue

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

## Structure de Module

### Layout Standard

```
my-module/
├── README.md               # Documentation d'usage
├── LICENSE                 # MIT ou Apache 2.0 (modules publics)
├── .pre-commit-config.yaml # Configuration pre-commit hooks
├── main.tf                 # Ressources principales
├── variables.tf            # Variables d'entree
├── outputs.tf              # Valeurs de sortie
├── versions.tf             # Contraintes de versions
├── examples/
│   ├── simple/             # Exemple minimal
│   └── complete/           # Exemple complet
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

## Bonnes Pratiques Variables

### Exemple Complet

```hcl
variable "instance_type" {
  description = "Type d'instance EC2 pour le serveur applicatif"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Le type doit etre t3.micro, t3.small, ou t3.medium."
  }
}

variable "tags" {
  description = "Tags a appliquer a toutes les ressources"
  type        = map(string)
  default     = {}
}

variable "enable_monitoring" {
  description = "Activer CloudWatch detailed monitoring"
  type        = bool
  default     = true
}
```

### Principes Cles

- **Toujours inclure `description`** - Aide a comprendre la variable
- **Utiliser des contraintes `type` explicites** - Detecte les erreurs tot
- **Fournir des valeurs `default` sensees** - Quand appropriee
- **Ajouter des blocs `validation`** - Pour contraintes complexes
- **Utiliser `sensitive = true`** - Pour les secrets

### Nommage des Variables

```hcl
# BON : Specifique au contexte
var.vpc_cidr_block          # Pas juste "cidr"
var.database_instance_class # Pas juste "instance_class"
var.application_port        # Pas juste "port"

# MAUVAIS : Noms generiques
var.name
var.type
var.value
```

---

## Bonnes Pratiques Outputs

### Exemple Complet

```hcl
output "instance_id" {
  description = "ID de l'instance EC2 creee"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN de l'instance EC2 creee"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Adresse IP privee de l'instance"
  value       = aws_instance.this.private_ip
  sensitive   = false
}

output "connection_info" {
  description = "Informations de connexion pour l'instance"
  value = {
    id         = aws_instance.this.id
    private_ip = aws_instance.this.private_ip
    public_dns = aws_instance.this.public_dns
  }
}
```

### Principes Cles

- **Toujours inclure `description`** - Expliquer l'utilite de l'output
- **Marquer les outputs sensibles** - `sensitive = true`
- **Retourner des objets pour valeurs liees** - Groupe les donnees logiquement
- **Documenter l'usage prevu** - Que doivent faire les consommateurs ?

---

## Patterns Courants

### DO : Utiliser `for_each` pour les Ressources

```hcl
# BON : Maintient des adresses de ressources stables
resource "aws_instance" "server" {
  for_each = toset(["web", "api", "worker"])

  instance_type = "t3.micro"
  tags = {
    Name = each.key
  }
}
```

### DON'T : Utiliser `count` Quand l'Ordre Importe

```hcl
# MAUVAIS : Supprimer l'element du milieu recree tous les suivants
resource "aws_instance" "server" {
  count = length(var.server_names)

  tags = {
    Name = var.server_names[count.index]
  }
}
```

### DO : Separer Root Module des Modules Reutilisables

```
# Root module (specifique a l'environnement)
prod/
  main.tf          # Appelle modules avec valeurs prod

# Module reutilisable
modules/webapp/
  main.tf          # Ressources generiques parametrees
```

### DO : Utiliser Locals pour Valeurs Calculees

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

## Anti-patterns a Eviter

### DON'T : Hardcoder des Valeurs Specifiques a l'Environnement

```hcl
# MAUVAIS : Module verrouille a la production
resource "aws_instance" "app" {
  instance_type = "m5.large"
  tags = {
    Environment = "production"
  }
}
```

**Fix :** Tout rendre configurable.

### DON'T : Creer des God Modules

```hcl
# MAUVAIS : Un module fait tout
module "everything" {
  source = "./modules/app-infrastructure"
  # Cree VPC, EC2, RDS, S3, IAM, etc.
}
```

**Fix :** Decouper en modules focalises.

### DON'T : Utiliser count/for_each dans Root Modules pour Environnements

```hcl
# MAUVAIS : Tous les environnements dans un root module
resource "aws_instance" "app" {
  for_each = toset(["dev", "staging", "prod"])

  instance_type = each.key == "prod" ? "m5.large" : "t3.micro"
}
```

**Fix :** Utiliser des root modules separes.

---

**Retour vers :** [Fichier Skill Principal](../SKILL.md)
