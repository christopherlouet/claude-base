---
sidebar_position: 46
title: "ops-infra-code"
description: "Infrastructure as Code (Terraform, OpenTofu). Utiliser pour créer des modules, auditer l'infrastructure existante, ou configurer le state management."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-infra-code

<span className="badge badge--sonnet">Sonnet</span>

> Infrastructure as Code (Terraform, OpenTofu). Utiliser pour créer des modules, auditer l'infrastructure existante, ou configurer le state management.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | `infrastructure-as-code` |

## Objectif

Aider à :
- Créer des modules Terraform/OpenTofu idiomatiques
- Auditer l'infrastructure existante
- Configurer le state management (backend S3, etc.)
- Implémenter les bonnes pratiques IaC
- Écrire des tests pour modules

## Workflow d'Analyse

### 1. Explorer l'Infrastructure Existante

```bash
# Trouver tous les fichiers Terraform
find . -name "*.tf" -o -name "*.tfvars"

# Analyser la structure
tree -I '.terraform|.git' --dirsfirst

# Vérifier les versions
grep -r "required_version" --include="*.tf"
grep -r "required_providers" --include="*.tf"
```

### 2. Analyser le Code

- Identifier les patterns utilisés
- Vérifier les conventions de nommage
- Évaluer la structure des modules
- Détecter les anti-patterns

### 3. Proposer des Améliorations

- Migration vers features modernes (try(), optional(), etc.)
- Restructuration en modules
- Ajout de validation et tests
- Sécurisation du state

## Checklist Audit

### Structure
- [ ] Séparation environnements / modules
- [ ] Fichiers standards (main.tf, variables.tf, outputs.tf, versions.tf)
- [ ] README.md avec documentation d'usage
- [ ] Examples/ pour démonstration

### Code Quality
- [ ] Variables avec description
- [ ] Types explicites sur toutes les variables
- [ ] Outputs avec description
- [ ] Pas de valeurs hardcodées
- [ ] Utilisation de locals pour calculs

### Sécurité
- [ ] Remote state avec chiffrement
- [ ] Pas de secrets dans le code
- [ ] Security groups restrictifs
- [ ] Chiffrement activé sur ressources

### Tests
- [ ] Pre-commit hooks configurés
- [ ] Tests natifs ou Terratest
- [ ] Scanning sécurité (trivy/checkov)

## Templates

### Module Minimal

```hcl
# versions.tf
terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# variables.tf
variable "name" {
  description = "Nom de la ressource"
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}

# main.tf
locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_resource" "this" {
  name = var.name
  tags = local.common_tags
}

# outputs.tf
output "id" {
  description = "ID de la ressource"
  value       = aws_resource.this.id
}
```

### Backend S3

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "env/component/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Pre-commit Config

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

## Commandes Utiles

```bash
# Validation
terraform fmt -check -recursive
terraform validate
tflint --recursive

# Sécurité
trivy config .
checkov -d .

# Tests
terraform test
terraform test -filter=tests/unit/

# Planification
terraform plan -out=tfplan
terraform show -json tfplan | jq '.'
```

## Output Attendu

1. **Analyse** : Rapport sur l'état actuel de l'infrastructure
2. **Recommandations** : Liste priorisée d'améliorations
3. **Code** : Modules ou configurations selon la demande
4. **Tests** : Tests natifs ou Terratest selon le besoin
5. **Documentation** : README et commentaires

## Attribution

Basé sur les bonnes pratiques de [terraform-skill](https://github.com/antonbabenko/terraform-skill) par Anton Babenko.
Ressources : [terraform-best-practices.com](https://terraform-best-practices.com)

---

## Voir aussi

- [/ops-infra-code](/docs/commands/ops/ops-infra-code) - Commande associée
- [Skill infrastructure-as-code](/docs/skills/infrastructure-as-code) - Skill auto-déclenché
- [Agent ops-proxmox](/docs/agents/ops-proxmox) - Infrastructure Proxmox spécifique
