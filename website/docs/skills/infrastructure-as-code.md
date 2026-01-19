---
sidebar_position: 29
title: "infrastructure-as-code"
description: "Infrastructure as Code avec Terraform/OpenTofu. Déclencher pour créer modules, configurer backends, écrire HCL idiomatique, ou auditer infrastructure."
tags:
  - "skill"
  - "fork"
---

# Skill: infrastructure-as-code

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Infrastructure as Code avec Terraform/OpenTofu. Déclencher pour créer modules, configurer backends, écrire HCL idiomatique, ou auditer infrastructure.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `Terraform`, `IaC`, `OpenTofu`, `module`, `state`, `HCL`, `provider`, `backend` |

## Quand utiliser ce Skill

**Activer ce skill pour :**
- Créer des configurations ou modules Terraform/OpenTofu
- Mettre en place l'infrastructure de tests pour IaC
- Choisir entre les approches de test (validate, plan, frameworks)
- Structurer des déploiements multi-environnements
- Implémenter CI/CD pour l'infrastructure-as-code
- Revoir ou refactorer des projets Terraform/OpenTofu existants

**Ne pas utiliser pour :**
- Questions de syntaxe basiques (Claude connaît déjà)
- Référence API spécifique aux providers (utiliser la doc)
- Questions cloud non liées à Terraform/OpenTofu

## Principes Fondamentaux

### 1. Hiérarchie des Modules

| Type | Quand utiliser | Portée |
|------|----------------|--------|
| **Resource Module** | Groupe logique de ressources connectées | VPC + subnets, Security group + rules |
| **Infrastructure Module** | Collection de resource modules | Plusieurs modules dans une région/compte |
| **Composition** | Infrastructure complète | Couvre plusieurs régions/comptes |

**Hiérarchie :** Resource -> Resource Module -> Infrastructure Module -> Composition

### 2. Structure de Répertoire

```
environments/        # Configurations par environnement
├── prod/
├── staging/
└── dev/

modules/            # Modules réutilisables
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

# Éviter : Noms génériques pour non-singletons
resource "aws_instance" "main" { }
```

**Variables :**
```hcl
# Préfixer avec le contexte
var.vpc_cidr_block          # Pas juste "cidr"
var.database_instance_class # Pas juste "instance_class"
```

**Fichiers :**
- `main.tf` - Ressources principales
- `variables.tf` - Variables d'entrée
- `outputs.tf` - Valeurs de sortie
- `versions.tf` - Versions des providers

## Ordre des Blocs

### Bloc Resource

**Ordre strict pour la cohérence :**
1. `count` ou `for_each` EN PREMIER (ligne vide après)
2. Autres arguments
3. `tags` comme dernier argument réel
4. `depends_on` après tags (si nécessaire)
5. `lifecycle` à la toute fin (si nécessaire)

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
    error_message = "L'environnement doit être : dev, staging, ou prod."
  }

  nullable = false
}
```

## Count vs For_Each

### Guide de Décision Rapide

| Scenario | Utiliser | Pourquoi |
|----------|----------|----------|
| Condition booléenne (créer ou non) | `count = condition ? 1 : 0` | Simple toggle on/off |
| Réplication numérique simple | `count = 3` | Nombre fixe de ressources identiques |
| Éléments pouvant être réordonnés/supprimés | `for_each = toset(list)` | Adresses de ressources stables |
| Référence par clé | `for_each = map` | Accès nommé aux ressources |

## Stratégie de Tests

### Matrice de Décision

| Situation | Approche Recommandée | Outils | Coût |
|-----------|---------------------|--------|------|
| **Vérification syntaxe rapide** | Analyse statique | `terraform validate`, `fmt` | Gratuit |
| **Validation pre-commit** | Statique + lint | `validate`, `tflint`, `trivy` | Gratuit |
| **Terraform 1.6+, logique simple** | Framework de test natif | `terraform test` | Gratuit-Faible |
| **Pre-1.6, ou expertise Go** | Tests d'intégration | Terratest | Faible-Moyen |
| **Focus sécurité/compliance** | Policy as code | OPA, Sentinel | Gratuit |

### Pyramide de Tests pour Infrastructure

```
        /\
       /  \          Tests End-to-End (Coûteux)
      /____\         - Déploiement environnement complet
     /      \        - Setup production-like
    /________\
   /          \      Tests d'Intégration (Modéré)
  /____________\     - Test de module en isolation
 /              \    - Vraies ressources en compte de test
/________________\   Analyse Statique (Peu coûteux)
                     - validate, fmt, lint
                     - Scanning sécurité
```

## Features Modernes (1.0+)

| Feature | Version | Cas d'usage |
|---------|---------|-------------|
| `try()` function | 0.13+ | Fallbacks sûrs, remplace `element(concat())` |
| `nullable = false` | 1.1+ | Prévenir valeurs null dans les variables |
| `moved` blocks | 1.1+ | Refactorer sans destroy/recreate |
| `optional()` avec defaults | 1.3+ | Attributs d'objet optionnels |
| Tests natifs | 1.6+ | Framework de test intégré |
| Mock providers | 1.7+ | Tests unitaires sans coût |
| Cross-variable validation | 1.9+ | Valider relations entre variables |
| Write-only arguments | 1.11+ | Secrets jamais stockés dans le state |

## Sécurité et Compliance

### Checks de Sécurité Essentiels

```bash
# Scanning sécurité statique
trivy config .
checkov -d .
```

### Issues Courantes à Éviter

**NE PAS :**
- Stocker des secrets dans les variables
- Utiliser le VPC par défaut
- Omettre le chiffrement
- Ouvrir les security groups à 0.0.0.0/0

**FAIRE :**
- Utiliser AWS Secrets Manager / Parameter Store
- Créer des VPCs dédiés
- Activer le chiffrement au repos
- Utiliser des security groups least-privilege

## Attribution

Ce skill est adapté de [terraform-skill](https://github.com/antonbabenko/terraform-skill) par Anton Babenko.
Ressources additionnelles :
- [terraform-best-practices.com](https://terraform-best-practices.com)
- [Compliance.tf](https://compliance.tf)

---

## Voir aussi

- [/ops-infra-code](/docs/commands/ops/ops-infra-code) - Commande associée
- [Agent ops-infra-code](/docs/agents/ops-infra-code) - Sub-agent avec contexte isolé
- [Skill proxmox-infrastructure](/docs/skills/proxmox-infrastructure) - Infrastructure Proxmox spécifique
