---
name: ops-infra-code
description: Infrastructure as Code avec Terraform/OpenTofu. Declencher pour creer modules, configurer backends, ecrire HCL idiomatique, ou auditer infrastructure.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

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
