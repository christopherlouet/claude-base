# Agent INFRA-CODE

Implémente l'Infrastructure as Code (IaC) avec Terraform, CloudFormation ou Pulumi.

## Cible
$ARGUMENTS

## Objectif

Définir et gérer l'infrastructure de manière déclarative, reproductible et versionnée,
en suivant les meilleures pratiques DevOps.

## Stratégie Infrastructure as Code

```
┌─────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE AS CODE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ANALYSER      → Identifier besoins infra               │
│  ══════════                                                 │
│                                                             │
│  2. CONCEVOIR     → Architecture cloud cible               │
│  ═══════════                                                │
│                                                             │
│  3. STRUCTURER    → Organisation modules/stacks            │
│  ════════════                                               │
│                                                             │
│  4. IMPLÉMENTER   → Écrire le code IaC                     │
│  ═════════════                                              │
│                                                             │
│  5. VALIDER       → Plan, tests, review                    │
│  ══════════                                                 │
│                                                             │
│  6. DÉPLOYER      → Apply avec CI/CD                       │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Analyse des besoins

### Questions à se poser

```markdown
## Analyse Infrastructure

### Compute
- [ ] Type de workload (containers, VMs, serverless) ?
- [ ] Besoins CPU/RAM ?
- [ ] Auto-scaling requis ?
- [ ] Régions/zones de disponibilité ?

### Stockage
- [ ] Type de données (objets, blocs, fichiers) ?
- [ ] Volume estimé ?
- [ ] Besoins de backup/réplication ?
- [ ] Rétention et lifecycle ?

### Réseau
- [ ] Architecture VPC/subnets ?
- [ ] Accès public/privé ?
- [ ] Load balancing ?
- [ ] CDN requis ?

### Base de données
- [ ] Type (SQL, NoSQL, cache) ?
- [ ] Haute disponibilité ?
- [ ] Read replicas ?
- [ ] Backups automatiques ?

### Sécurité
- [ ] IAM et permissions ?
- [ ] Encryption at rest/in transit ?
- [ ] Firewall/Security groups ?
- [ ] Secrets management ?
```

### Matrice de décision IaC tool

| Critère | Terraform | CloudFormation | Pulumi |
|---------|-----------|----------------|--------|
| **Multi-cloud** | ✅ Excellent | ❌ AWS only | ✅ Excellent |
| **Langage** | HCL | YAML/JSON | TS/Python/Go |
| **State** | Remote/Local | Managed | Managed |
| **Learning curve** | Moyenne | Faible (AWS) | Faible (devs) |
| **Écosystème** | Très riche | AWS natif | Croissant |
| **Drift detection** | Plan | Drift detection | Preview |

## Étape 2 : Structure du projet Terraform

### Organisation recommandée

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   └── ...
│   ├── database/
│   │   └── ...
│   └── security/
│       └── ...
├── shared/
│   └── backend.tf
└── README.md
```

### Configuration du backend

```hcl
# shared/backend.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "env/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}
```

## Étape 3 : Modules réutilisables

### Module VPC

```hcl
# modules/networking/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# modules/networking/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Environment = var.environment
    Type        = "public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Environment = var.environment
    Type        = "private"
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-eip-${count.index + 1}"
    Environment = var.environment
  }
}

# modules/networking/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}
```

### Module ECS/Fargate

```hcl
# modules/compute/ecs/main.tf
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables

      secrets = var.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Environment = var.environment
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
```

### Module RDS

```hcl
# modules/database/rds/main.tf
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}"

  # Engine
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = var.kms_key_arn

  # Database
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  port                   = var.port

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  # High availability
  multi_az = var.multi_az

  # Monitoring
  performance_insights_enabled = true
  monitoring_interval         = 60
  monitoring_role_arn         = aws_iam_role.rds_monitoring.arn

  # Updates
  auto_minor_version_upgrade = true
  deletion_protection        = var.environment == "prod"

  # Snapshots
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-${var.environment}-final" : null

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}
```

## Étape 4 : Environnement spécifique

### Configuration dev

```hcl
# environments/dev/main.tf
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

module "ecs" {
  source = "../../modules/compute/ecs"

  project_name       = var.project_name
  environment        = "dev"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids

  container_name  = "app"
  container_image = var.container_image
  container_port  = 3000
  cpu             = 256
  memory          = 512
  desired_count   = 1

  environment_variables = [
    { name = "NODE_ENV", value = "development" },
    { name = "LOG_LEVEL", value = "debug" }
  ]
}

module "database" {
  source = "../../modules/database/rds"

  project_name       = var.project_name
  environment        = "dev"
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_id             = module.networking.vpc_id

  engine          = "postgres"
  engine_version  = "15.4"
  instance_class  = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50

  database_name   = "app_dev"
  master_username = "admin"
  master_password = var.db_password

  backup_retention_period = 7
  multi_az               = false
}

# environments/dev/variables.tf
variable "project_name" {
  default = "myapp"
}

variable "region" {
  default = "eu-west-1"
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

## Étape 5 : Validation et tests

### Commandes de validation

```bash
# Initialiser Terraform
terraform init

# Valider la syntaxe
terraform validate

# Formater le code
terraform fmt -recursive

# Voir le plan d'exécution
terraform plan -out=tfplan

# Analyser les coûts (avec Infracost)
infracost breakdown --path .

# Scan de sécurité (avec tfsec)
tfsec .

# Linting (avec tflint)
tflint --init
tflint
```

### Tests avec Terratest

```go
// test/vpc_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/networking",
        Vars: map[string]interface{}{
            "project_name":         "test",
            "environment":          "test",
            "vpc_cidr":             "10.99.0.0/16",
            "availability_zones":   []string{"eu-west-1a"},
            "public_subnet_cidrs":  []string{"10.99.1.0/24"},
            "private_subnet_cidrs": []string{"10.99.10.0/24"},
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.NotEmpty(t, vpcId)

    publicSubnetIds := terraform.OutputList(t, terraformOptions, "public_subnet_ids")
    assert.Equal(t, 1, len(publicSubnetIds))
}
```

## Étape 6 : CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  push:
    branches: [main]
    paths:
      - 'infrastructure/**'
  pull_request:
    branches: [main]
    paths:
      - 'infrastructure/**'

env:
  TF_VERSION: '1.5.0'
  AWS_REGION: 'eu-west-1'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format
        run: terraform fmt -check -recursive
        working-directory: infrastructure

      - name: Terraform Init
        run: terraform init -backend=false
        working-directory: infrastructure/environments/dev

      - name: Terraform Validate
        run: terraform validate
        working-directory: infrastructure/environments/dev

      - name: TFSec Security Scan
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          working_directory: infrastructure

  plan:
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        run: terraform init
        working-directory: infrastructure/environments/dev

      - name: Terraform Plan
        run: terraform plan -no-color -out=tfplan
        working-directory: infrastructure/environments/dev

      - name: Comment PR with Plan
        uses: actions/github-script@v6
        with:
          script: |
            const output = `#### Terraform Plan 📖
            \`\`\`
            ${process.env.PLAN}
            \`\`\`
            `;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

  apply:
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        run: terraform init
        working-directory: infrastructure/environments/dev

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: infrastructure/environments/dev
```

## Bonnes pratiques

### À faire

| Pratique | Raison |
|----------|--------|
| **Modules réutilisables** | DRY, maintenabilité |
| **State remote + locking** | Collaboration, sécurité |
| **Variables sensibles** | Pas de secrets en dur |
| **Tags systématiques** | Traçabilité, coûts |
| **Versionner providers** | Reproductibilité |

### À éviter

| Anti-pattern | Problème | Solution |
|--------------|----------|----------|
| State local | Conflits, perte | Backend S3/GCS |
| Secrets en dur | Sécurité | Secrets Manager |
| Hardcoded values | Pas flexible | Variables |
| Monolithe | Difficile à gérer | Modules |
| Pas de plan avant apply | Surprises | Toujours plan |

## Output attendu

```markdown
## Infrastructure Déployée

**Environment:** dev
**Region:** eu-west-1

### Ressources créées
| Type | Nom | ID |
|------|-----|-----|
| VPC | myapp-dev-vpc | vpc-xxx |
| ECS Cluster | myapp-dev | arn:aws:ecs:... |
| RDS | myapp-dev-db | myapp-dev |
| ALB | myapp-dev-alb | arn:aws:elasticloadbalancing:... |

### Endpoints
- Application: https://app.dev.example.com
- Database: myapp-dev.xxx.eu-west-1.rds.amazonaws.com:5432

### Prochaines étapes
1. [ ] Configurer DNS
2. [ ] Ajouter monitoring
3. [ ] Configurer alertes
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/docker` | Containeriser l'application |
| `/ci` | Pipeline CI/CD |
| `/secrets-management` | Gestion des secrets |
| `/monitoring` | Monitoring infrastructure |
| `/cost-optimization` | Optimiser les coûts |

---

IMPORTANT: Toujours faire un `terraform plan` avant `apply`.

YOU MUST utiliser un backend remote pour le state.

YOU MUST versionner les providers.

NEVER stocker de secrets dans le code Terraform.

Think hard sur la structure des modules pour la réutilisabilité.
