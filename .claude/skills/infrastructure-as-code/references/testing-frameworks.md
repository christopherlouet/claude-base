# Testing Frameworks - Guide Detaille

> **Partie de :** [infrastructure-as-code](../SKILL.md)
> **Objectif :** Guide approfondi des frameworks de test pour Terraform/OpenTofu

---

## Table des Matieres

1. [Analyse Statique](#analyse-statique)
2. [Test de Plan](#test-de-plan)
3. [Tests Natifs Terraform](#tests-natifs-terraform)
4. [Terratest (Go)](#terratest-go)

---

## Analyse Statique

**Toujours faire cela en premier.** Zero cout, detecte 40%+ des problemes avant deploiement.

### Pre-commit Hooks

```yaml
# Dans .pre-commit-config.yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  hooks:
    - id: terraform_fmt
    - id: terraform_validate
    - id: terraform_tflint
```

### Ce que Chaque Outil Verifie

- **`terraform fmt`** - Coherence du formatage
- **`terraform validate`** - Syntaxe et coherence interne
- **`TFLint`** - Bonnes pratiques, regles specifiques aux providers
- **`trivy` / `checkov`** - Vulnerabilites securite

### Quand Utiliser

A chaque commit, toujours. Zero cout, detecte 40%+ des problemes.

---

## Test de Plan

### Ce que terraform plan Valide

- Verifier que les ressources attendues seront creees/modifiees/detruites
- Detecter les problemes d'authentification provider
- Valider les combinaisons de variables
- Revue avant application

### Dans CI/CD

```bash
terraform init
terraform plan -out=tfplan

# Optionnel : Convertir plan en JSON et valider avec outils
terraform show -json tfplan | jq '.'
```

### Limitations

- Ne deploie pas de vraie infrastructure
- Ne peut pas detecter problemes runtime (permissions IAM, connectivite reseau)
- Ne trouve pas les bugs specifiques aux ressources

---

## Tests Natifs Terraform

**Disponible :** Terraform 1.6+, OpenTofu 1.6+

### Quand Utiliser

- Equipe travaille principalement en HCL (pas d'experience Go/Ruby necessaire)
- Test des operations logiques et comportement de module
- Eviter les dependances de test externes

### Structure de Base

```hcl
# tests/s3_bucket.tftest.hcl
run "create_bucket" {
  command = apply

  assert {
    condition     = aws_s3_bucket.main.bucket != ""
    error_message = "Le nom du bucket S3 doit etre defini"
  }
}

run "verify_encryption" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.main.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Le bucket doit utiliser le chiffrement AES256"
  }
}
```

### Important : Valider les Schemas de Ressources

**Toujours verifier les schemas avant d'ecrire des tests :**

- Certains blocs sont des **sets** (non ordonnes, pas d'indexation avec `[0]`)
- Certains blocs sont des **lists** (ordonnes, indexables)
- Certains attributs sont **computed** (connus seulement apres apply)

**Patterns de Schema Courants :**

| Ressource AWS | Type de Bloc | Indexation |
|---------------|--------------|------------|
| `rule` dans `aws_s3_bucket_server_side_encryption_configuration` | **set** | Impossible avec `[0]` |
| `transition` dans `aws_s3_bucket_lifecycle_configuration` | **set** | Impossible avec `[0]` |
| `noncurrent_version_expiration` dans lifecycle | **list** | Possible avec `[0]` |

### Travailler avec Blocs de Type Set

**Probleme :** Impossible d'indexer les sets avec `[0]`
```hcl
# MAUVAIS : Va echouer
condition = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].bucket_key_enabled == true
# Error: Cannot index a set value
```

**Solution 1 :** Utiliser `command = apply` pour materialiser le set
```hcl
run "test_encryption" {
  command = apply  # Cree ressources reelles/mockees

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      rule.bucket_key_enabled == true
    ])
    error_message = "Bucket key devrait etre active"
  }
}
```

**Solution 2 :** Verifier au niveau ressource (eviter acces blocs imbriques)
```hcl
run "test_encryption_exists" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this != null
    error_message = "Configuration chiffrement devrait etre creee"
  }
}
```

### command = plan vs command = apply

**Decision critique :** Quand utiliser chaque mode

#### Utiliser `command = plan`

**Quand :**
- Verifier la validation des entrees
- Verifier qu'une ressource sera creee
- Tester les defaults de variables
- Verifier attributs derives des entrees (pas computes)

```hcl
run "test_input_validation" {
  command = plan  # Rapide, pas de creation de ressource

  variables {
    bucket = "test-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket"
    error_message = "Le nom du bucket devrait correspondre a l'entree"
  }
}
```

#### Utiliser `command = apply`

**Quand :**
- Verifier attributs computed (IDs, ARNs, noms generes)
- Acceder aux blocs de type set
- Verifier le comportement reel des ressources
- Tester avec reponses provider reelles/mockees

```hcl
run "test_computed_values" {
  command = apply  # Execute et obtient valeurs computed

  variables {
    bucket_prefix = "test-"  # AWS genere le nom complet
  }

  assert {
    condition     = length(aws_s3_bucket.this.bucket) > 0
    error_message = "Le bucket devrait avoir un nom genere"
  }
}
```

**Guide de Decision Rapide :**
```
Verifier valeurs d'entree ? -> command = plan
Verifier valeurs computed ? -> command = apply
Acceder blocs type set ? -> command = apply
Besoin feedback rapide ? -> command = plan (avec mocks)
Tester comportement reel ? -> command = apply (sans mocks)
```

### Avec Mocking (1.7+)

```hcl
mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id  = "i-mock123"
      arn = "arn:aws:ec2:us-east-1:123456789:instance/i-mock123"
    }
  }
}
```

### Avantages

- Syntaxe HCL native (familiere aux utilisateurs Terraform)
- Pas de dependances externes
- Execution rapide avec mocks
- Bon pour tests unitaires de logique module

### Inconvenients

- Feature plus recente (moins mature que Terratest)
- Ecosysteme/exemples limites
- Le mocking ne capture pas le comportement AWS reel

---

## Terratest (Go)

**Recommande pour :** Equipes avec experience Go, tests d'integration robustes

### Quand Utiliser

- Equipe a de l'experience Go
- Besoin de tests d'integration robustes
- Test de plusieurs providers/infrastructure complexe
- Framework battle-tested avec grande communaute

### Structure de Base

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestS3Module(t *testing.T) {
    t.Parallel() // TOUJOURS inclure pour execution parallele

    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "bucket_name": "test-bucket-" + uniqueId(),
        },
    }

    // Nettoyer ressources apres test
    defer terraform.Destroy(t, terraformOptions)

    // Executer terraform init et apply
    terraform.InitAndApply(t, terraformOptions)

    // Obtenir outputs et verifier
    bucketName := terraform.Output(t, terraformOptions, "bucket_name")
    assert.NotEmpty(t, bucketName)
}
```

### Gestion des Couts

```go
// Utiliser tags pour cleanup automatise
Vars: map[string]interface{}{
    "tags": map[string]string{
        "Environment": "test",
        "TTL":         "2h", // Auto-delete apres 2 heures
    },
}
```

### Patterns Critiques

1. **Toujours utiliser `t.Parallel()`** - Active execution parallele
2. **Toujours utiliser `defer terraform.Destroy()`** - Assure cleanup
3. **Utiliser identifiants uniques** - Eviter conflits de ressources
4. **Taguer les ressources** - Tracking couts et cleanup automatise
5. **Utiliser comptes AWS separes** - Isoler infrastructure de test

### Couts Reels

- Module petit (S3, IAM): $0-5 par execution
- Module moyen (VPC, EC2): $5-20 par execution
- Module large (RDS, cluster ECS): $20-100 par execution

### Optimisation avec Test Stages

```go
// Stages de test pour iteration plus rapide
stage := test_structure.RunTestStage

stage(t, "setup", func() {
    terraform.InitAndApply(t, opts)
})

stage(t, "validate", func() {
    // Assertions ici
})

stage(t, "teardown", func() {
    terraform.Destroy(t, opts)
})

// Sauter stages pendant developpement :
// export SKIP_setup=true
// export SKIP_teardown=true
```

---

## Resume Bonnes Pratiques

### Pour Tous les Frameworks

1. **Commencer avec analyse statique** - Toujours gratuit, toujours rapide
2. **Utiliser identifiants uniques** - Prevenir conflits de ressources
3. **Taguer ressources de test** - Tracking et cleanup
4. **Separer comptes de test** - Isoler infrastructure de test
5. **Implementer TTL** - Cleanup automatique des ressources

### Selection Framework

```
Verification syntaxe rapide ? -> terraform validate + fmt
Scan securite ? -> trivy + checkov
Terraform 1.6+, logique simple ? -> Tests natifs
Pre-1.6, ou integration complexe ? -> Terratest
```

### Optimisation Couts

1. Utiliser mocking pour tests unitaires
2. Implementer tags TTL sur ressources
3. Executer tests d'integration seulement sur branche main
4. Utiliser types d'instance plus petits dans tests
5. Partager ressources de test quand sur

---

**Retour vers :** [Fichier Skill Principal](../SKILL.md)
