---
sidebar_position: 3
title: Module Terraform
description: Exemple de module Terraform réutilisable
---

# Module Terraform Réutilisable

Cet exemple montre comment créer un module Terraform professionnel et réutilisable.

## Commande utilisée

```bash
/ops:ops-infra-code "Créer un module Terraform pour une infrastructure AWS avec VPC, ECS et RDS"
```

## Structure générée

```
modules/
└── ecs-service/
    ├── main.tf           # Ressources principales
    ├── variables.tf      # Variables d'entrée
    ├── outputs.tf        # Outputs
    ├── versions.tf       # Contraintes de version
    ├── locals.tf         # Valeurs locales
    ├── data.tf           # Data sources
    ├── iam.tf            # Rôles IAM
    └── README.md         # Documentation
```

## Code du Module

### `versions.tf`

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### `variables.tf`

```hcl
# ====================
# Required Variables
# ====================

variable "name" {
  description = "Nom du service ECS"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Le nom doit contenir uniquement des lettres minuscules, chiffres et tirets."
  }
}

variable "environment" {
  description = "Environnement (dev, staging, production)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "L'environnement doit être dev, staging ou production."
  }
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs des subnets pour le service"
  type        = list(string)
}

variable "container_image" {
  description = "Image Docker du conteneur"
  type        = string
}

# ====================
# Optional Variables
# ====================

variable "cpu" {
  description = "CPU units pour la tâche (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "CPU doit être 256, 512, 1024, 2048 ou 4096."
  }
}

variable "memory" {
  description = "Mémoire en MB pour la tâche"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Nombre d'instances du service"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port exposé par le conteneur"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Path pour le health check"
  type        = string
  default     = "/api/health"
}

variable "environment_variables" {
  description = "Variables d'environnement pour le conteneur"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets à injecter (ARN SSM ou Secrets Manager)"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "enable_autoscaling" {
  description = "Activer l'autoscaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Capacité minimale pour l'autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Capacité maximale pour l'autoscaling"
  type        = number
  default     = 10
}

variable "enable_execute_command" {
  description = "Activer ECS Exec pour le debugging"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags additionnels pour les ressources"
  type        = map(string)
  default     = {}
}
```

### `locals.tf`

```hcl
locals {
  # Tags communs
  common_tags = merge(
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "ecs-service"
    },
    var.tags
  )

  # Nom complet avec environnement
  full_name = "${var.name}-${var.environment}"

  # Configuration du container
  container_definition = {
    name      = var.name
    image     = var.container_image
    cpu       = var.cpu
    memory    = var.memory
    essential = true

    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }
    ]

    environment = [
      for key, value in var.environment_variables : {
        name  = key
        value = value
      }
    ]

    secrets = var.secrets

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.main.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}${var.health_check_path} || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }
}
```

### `data.tf`

```hcl
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}
```

### `main.tf`

```hcl
# ====================
# ECS Cluster
# ====================
resource "aws_ecs_cluster" "main" {
  name = local.full_name

  setting {
    name  = "containerInsights"
    value = var.environment == "production" ? "enabled" : "disabled"
  }

  tags = local.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = var.environment == "production" ? "FARGATE" : "FARGATE_SPOT"
    weight            = 1
    base              = var.environment == "production" ? 1 : 0
  }
}

# ====================
# Task Definition
# ====================
resource "aws_ecs_task_definition" "main" {
  family                   = local.full_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([local.container_definition])

  tags = local.common_tags
}

# ====================
# ECS Service
# ====================
resource "aws_ecs_service" "main" {
  name            = local.full_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  # Fargate
  launch_type = "FARGATE"

  # Réseau
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  # Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  # Déploiement
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  # ECS Exec
  enable_execute_command = var.enable_execute_command

  # Éviter les conflits avec l'autoscaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.https]

  tags = local.common_tags
}

# ====================
# Security Group
# ====================
resource "aws_security_group" "ecs_tasks" {
  name        = "${local.full_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# ====================
# CloudWatch Logs
# ====================
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${local.full_name}"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = local.common_tags
}

# ====================
# Application Load Balancer
# ====================
resource "aws_security_group" "alb" {
  name        = "${local.full_name}-alb"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_lb" "main" {
  name               = local.full_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.environment == "production"

  tags = local.common_tags
}

resource "aws_lb_target_group" "main" {
  name        = local.full_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.common_tags
}

# ====================
# Auto Scaling
# ====================
resource "aws_appautoscaling_target" "main" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.full_name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.full_name}-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
```

### `iam.tf`

```hcl
# ====================
# Execution Role (pour ECS agent)
# ====================
resource "aws_iam_role" "execution" {
  name = "${local.full_name}-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  count = length(var.secrets) > 0 ? 1 : 0
  name  = "${local.full_name}-secrets"
  role  = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [for s in var.secrets : s.valueFrom]
      }
    ]
  })
}

# ====================
# Task Role (pour l'application)
# ====================
resource "aws_iam_role" "task" {
  name = "${local.full_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy pour ECS Exec
resource "aws_iam_role_policy" "ecs_exec" {
  count = var.enable_execute_command ? 1 : 0
  name  = "${local.full_name}-ecs-exec"
  role  = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### `outputs.tf`

```hcl
output "cluster_id" {
  description = "ID du cluster ECS"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Nom du service ECS"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "ARN de la task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "alb_dns_name" {
  description = "DNS name de l'ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID de l'ALB (pour Route53)"
  value       = aws_lb.main.zone_id
}

output "security_group_id" {
  description = "ID du security group des tâches ECS"
  value       = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  description = "Nom du log group CloudWatch"
  value       = aws_cloudwatch_log_group.main.name
}

output "task_role_arn" {
  description = "ARN du rôle de tâche"
  value       = aws_iam_role.task.arn
}
```

## Utilisation du module

```hcl
module "api_service" {
  source = "./modules/ecs-service"

  name            = "api"
  environment     = "production"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  container_image = "ghcr.io/myorg/api:v1.2.3"
  certificate_arn = aws_acm_certificate.main.arn

  cpu    = 512
  memory = 1024

  environment_variables = {
    NODE_ENV = "production"
    LOG_LEVEL = "info"
  }

  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = aws_ssm_parameter.database_url.arn
    }
  ]

  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 10

  tags = {
    Team = "backend"
  }
}
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Validation** | Variables avec contraintes |
| **Locals** | Logique centralisée |
| **Sécurité** | IAM least privilege |
| **Flexibilité** | Variables optionnelles |
| **Documentation** | Descriptions sur chaque variable |

## Commandes associées

- `/ops:ops-ci` - Pipeline avec terraform plan/apply
- `/ops:ops-proxmox` - Module pour infrastructure Proxmox
- `/qa:qa-security` - Audit sécurité Terraform

---

:::tip Terraform Registry
Publiez vos modules sur le [Terraform Registry](https://registry.terraform.io) pour les réutiliser facilement.
:::
