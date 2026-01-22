# Security & Compliance

> **Partie de :** [infrastructure-as-code](../SKILL.md)
> **Objectif :** Bonnes pratiques securite et patterns de conformite pour Terraform/OpenTofu

---

## Table des Matieres

1. [Outils de Scanning Securite](#outils-de-scanning-securite)
2. [Problemes de Securite Courants](#problemes-de-securite-courants)
3. [Tests de Conformite](#tests-de-conformite)
4. [Gestion des Secrets](#gestion-des-secrets)
5. [Securite du State File](#securite-du-state-file)

---

## Outils de Scanning Securite

### Checks de Securite Essentiels

```bash
# Scanning securite statique
trivy config .
checkov -d .

# Tests de conformite
terraform-compliance -f compliance/ -p tfplan.json
```

### Integration Trivy

**Installation :**

```bash
# macOS
brew install trivy

# Linux
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Dans CI
- uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: '.'
```

**Note :** Trivy est le successeur de tfsec, maintenu par Aqua Security.

**Exemple de Sortie :**

```
Result #1 HIGH Security group rule allows egress to multiple public internet addresses
--------------------------------------------------------------------------------
  security.tf:15-20

   12 | resource "aws_security_group_rule" "egress" {
   13 |   type              = "egress"
   14 |   from_port         = 0
   15 |   to_port           = 0
   16 |   protocol          = "-1"
   17 |   cidr_blocks       = ["0.0.0.0/0"]
   18 |   security_group_id = aws_security_group.this.id
   19 | }
```

### Integration Checkov

```bash
# Executer Checkov
checkov -d . --framework terraform

# Ignorer checks specifiques
checkov -d . --skip-check CKV_AWS_23

# Generer rapport JSON
checkov -d . -o json > checkov-report.json
```

---

## Problemes de Securite Courants

### DON'T : Stocker des Secrets dans les Variables

```hcl
# MAUVAIS : Secret en clair
variable "database_password" {
  type    = string
  default = "SuperSecret123!"  # Ne jamais faire ca
}
```

### DO : Utiliser Secrets Manager

```hcl
# BON : Reference secrets depuis AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "this" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### DON'T : Utiliser le VPC par Defaut

```hcl
# MAUVAIS : VPC par defaut a des subnets publics
resource "aws_instance" "app" {
  ami       = "ami-12345"
  subnet_id = "subnet-default"  # Eviter ressources par defaut
}
```

### DO : Creer des VPCs Dedies

```hcl
# BON : VPC custom avec subnets prives
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
```

### DON'T : Ignorer le Chiffrement

```hcl
# MAUVAIS : Bucket S3 non chiffre
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  # Pas de chiffrement configure
}
```

### DO : Activer le Chiffrement au Repos

```hcl
# BON : Activer le chiffrement
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### DON'T : Ouvrir Security Groups a Internet

```hcl
# MAUVAIS : Security group ouvert a internet
resource "aws_security_group_rule" "allow_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Ne jamais faire ca
  security_group_id = aws_security_group.this.id
}
```

### DO : Utiliser Security Groups Least-Privilege

```hcl
# BON : Restreindre a ports et sources specifiques
resource "aws_security_group_rule" "app_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]  # Interne seulement
  security_group_id = aws_security_group.this.id
}
```

---

## Tests de Conformite

### terraform-compliance

**Installation :**

```bash
pip install terraform-compliance
```

**Exemple de Test de Conformite :**

```gherkin
# compliance/aws-encryption.feature
Feature: Les ressources AWS doivent etre chiffrees

  Scenario: Les buckets S3 doivent avoir le chiffrement
    Given I have aws_s3_bucket defined
    When it has aws_s3_bucket_server_side_encryption_configuration
    Then it must contain rule
    And it must contain apply_server_side_encryption_by_default

  Scenario: Les instances RDS doivent etre chiffrees
    Given I have aws_db_instance defined
    Then it must contain storage_encrypted
    And its value must be true
```

**Executer les Tests :**

```bash
# Generer plan en JSON
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Executer tests de conformite
terraform-compliance -f compliance/ -p tfplan.json
```

### Open Policy Agent (OPA)

```rego
# policy/s3_encryption.rego
package terraform.s3

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  not resource.change.after.server_side_encryption_configuration

  msg := sprintf("Le bucket S3 '%s' doit avoir le chiffrement active", [resource.address])
}
```

---

## Gestion des Secrets

### Pattern AWS Secrets Manager

```hcl
# Creer secret
resource "aws_secretsmanager_secret" "db_password" {
  name        = "prod/database/password"
  description = "Mot de passe master RDS"

  recovery_window_in_days = 30
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Generer mot de passe securise
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Utiliser secret dans RDS
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "this" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  # ...
}
```

### Variables d'Environnement

```bash
# Ne jamais commiter ces valeurs
export TF_VAR_database_password="secret123"
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

**Dans .gitignore :**

```
*.tfvars
.env
secrets/
```

---

## Securite du State File

### Chiffrer le State au Repos

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true  # Toujours activer le chiffrement
  }
}
```

### Securiser le Bucket State

```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state"
}

# Activer versioning (protection contre suppression accidentelle)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Activer chiffrement
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer acces public
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Restreindre Acces au State

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/TerraformRole"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::my-terraform-state",
        "arn:aws:s3:::my-terraform-state/*"
      ]
    }
  ]
}
```

---

## Bonnes Pratiques IAM

### DO : Utiliser Least Privilege

```hcl
# BON : Permissions specifiques uniquement
resource "aws_iam_policy" "app_policy" {
  name = "app-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-app-bucket/*"
      }
    ]
  })
}
```

### DON'T : Utiliser Permissions Wildcard

```hcl
# MAUVAIS : Permissions trop larges
resource "aws_iam_policy" "bad_policy" {
  policy = jsonencode({
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"  # Ne jamais utiliser wildcard
        Resource = "*"
      }
    ]
  })
}
```

---

## Checklists de Conformite

### Conformite SOC 2

- [ ] Chiffrement au repos pour tous les data stores
- [ ] Chiffrement en transit (TLS/SSL)
- [ ] Politiques IAM suivent least privilege
- [ ] Logging active pour toutes les ressources
- [ ] MFA requis pour acces privilegie
- [ ] Scanning securite regulier dans CI/CD

### Conformite HIPAA

- [ ] PHI chiffre au repos et en transit
- [ ] Logs d'acces actives
- [ ] VPC dedie avec subnets prives
- [ ] Politiques backup et retention regulieres
- [ ] Piste d'audit pour tous les changements infrastructure

### Conformite PCI-DSS

- [ ] Segmentation reseau (VPCs separes)
- [ ] Pas de mots de passe par defaut
- [ ] Algorithmes de chiffrement forts
- [ ] Scanning securite regulier
- [ ] Controle d'acces et monitoring

---

## Ressources

- [Documentation Trivy](https://aquasecurity.github.io/trivy/)
- [Documentation Checkov](https://www.checkov.io/)
- [terraform-compliance](https://terraform-compliance.com/)
- [Open Policy Agent](https://www.openpolicyagent.org/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)

---

**Retour vers :** [Fichier Skill Principal](../SKILL.md)
