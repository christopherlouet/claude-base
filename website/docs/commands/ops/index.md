---
sidebar_position: 1
title: "OPS"
description: "Commandes OPS - Operations (CI/CD, Docker, monitoring, GitFlow)"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# Commandes OPS

> Operations (CI/CD, Docker, monitoring, GitFlow)

## Vue d'ensemble

Ce domaine contient **28 commandes** pour operations (ci/cd, docker, monitoring, gitflow).

## Liste des commandes

| Commande | Description |
|----------|-------------|
| [`/ops-backup`](/docs/commands/ops/ops-backup) | Stratégie de backup et restore pour les données critiques. |
| [`/ops-ci`](/docs/commands/ops/ops-ci) | Configurer les pipelines CI/CD (GitHub Actions, GitLab CI, etc.). |
| [`/ops-cost-optimization`](/docs/commands/ops/ops-cost-optimization) | Analyser et optimiser les coûts d'infrastructure cloud. |
| [`/ops-database`](/docs/commands/ops/ops-database) | Design de schéma, migrations et optimisation de base de données. |
| [`/ops-deps`](/docs/commands/ops/ops-deps) | Audit, analyse et mise à jour des dépendances du projet. |
| [`/ops-disaster-recovery`](/docs/commands/ops/ops-disaster-recovery) | Mettre en place une stratégie de reprise après sinistre (Disaster Recovery). |
| [`/ops-docker`](/docs/commands/ops/ops-docker) | Dockerisation et containerisation de projets. |
| [`/ops-env`](/docs/commands/ops/ops-env) | Gestion des environnements (dev, staging, prod) et des variables d'environnement. |
| [`/ops-gitflow-feature`](/docs/commands/ops/ops-gitflow-feature) | Gérer les branches feature avec GitFlow. |
| [`/ops-gitflow-hotfix`](/docs/commands/ops/ops-gitflow-hotfix) | Gérer les hotfixes urgents avec GitFlow. |
| [`/ops-gitflow-init`](/docs/commands/ops/ops-gitflow-init) | Initialiser GitFlow sur le repository. |
| [`/ops-gitflow-release`](/docs/commands/ops/ops-gitflow-release) | Gérer les branches release avec GitFlow. |
| [`/ops-grafana-dashboard`](/docs/commands/ops/ops-grafana-dashboard) | Creation de dashboards Grafana avec provisioning automatique. |
| [`/ops-health`](/docs/commands/ops/ops-health) | Vérification rapide de la santé d'un projet. Diagnostic express en 5 minutes. |
| [`/ops-hotfix`](/docs/commands/ops/ops-hotfix) | Workflow de correction urgente en production. |
| [`/ops-infra-code`](/docs/commands/ops/ops-infra-code) | Implémente l'Infrastructure as Code (IaC) avec Terraform, CloudFormation ou Pulumi. |
| [`/ops-k8s`](/docs/commands/ops/ops-k8s) | Deploiement et orchestration Kubernetes. |
| [`/ops-load-testing`](/docs/commands/ops/ops-load-testing) | Mettre en place et exécuter des tests de charge et de stress. |
| [`/ops-migrate`](/docs/commands/ops/ops-migrate) | Migration de code, dépendances ou données. |
| [`/ops-mobile-release`](/docs/commands/ops/ops-mobile-release) | Publication d'applications mobiles sur les stores (App Store, Google Play). |
| [`/ops-monitoring`](/docs/commands/ops/ops-monitoring) | Instrumentation du code pour le monitoring, logging et alerting. |
| [`/ops-observability-stack`](/docs/commands/ops/ops-observability-stack) | Deploiement d'une stack d'observabilite complete (Prometheus, Grafana, Loki, Alertmanager). |
| [`/ops-proxmox`](/docs/commands/ops/ops-proxmox) | Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup). |
| [`/ops-release`](/docs/commands/ops/ops-release) | Workflow de release avec changelog et versioning. |
| [`/ops-secrets-management`](/docs/commands/ops/ops-secrets-management) | Implémente une gestion sécurisée des secrets et credentials. |
| [`/ops-serverless`](/docs/commands/ops/ops-serverless) | Deploiement d'applications serverless (AWS Lambda, Vercel, Cloudflare Workers). |
| [`/ops-vercel`](/docs/commands/ops/ops-vercel) | Deploiement et configuration sur Vercel. |
| [`/ops-vps`](/docs/commands/ops/ops-vps) | Deploiement sur serveur VPS (OVH, Hetzner, DigitalOcean, Scaleway, etc.). |

## Commandes en detail

<CommandGrid>
  <CommandCard
    name="ops-backup"
    description="Stratégie de backup et restore pour les données critiques."
    domain="ops"
    href="/docs/commands/ops/ops-backup"
  />
  <CommandCard
    name="ops-ci"
    description="Configurer les pipelines CI/CD (GitHub Actions, GitLab CI, etc.)."
    domain="ops"
    href="/docs/commands/ops/ops-ci"
  />
  <CommandCard
    name="ops-cost-optimization"
    description="Analyser et optimiser les coûts d'infrastructure cloud."
    domain="ops"
    href="/docs/commands/ops/ops-cost-optimization"
  />
  <CommandCard
    name="ops-database"
    description="Design de schéma, migrations et optimisation de base de données."
    domain="ops"
    href="/docs/commands/ops/ops-database"
  />
  <CommandCard
    name="ops-deps"
    description="Audit, analyse et mise à jour des dépendances du projet."
    domain="ops"
    href="/docs/commands/ops/ops-deps"
  />
  <CommandCard
    name="ops-disaster-recovery"
    description="Mettre en place une stratégie de reprise après sinistre (Disaster Recovery)."
    domain="ops"
    href="/docs/commands/ops/ops-disaster-recovery"
  />
  <CommandCard
    name="ops-docker"
    description="Dockerisation et containerisation de projets."
    domain="ops"
    href="/docs/commands/ops/ops-docker"
  />
  <CommandCard
    name="ops-env"
    description="Gestion des environnements (dev, staging, prod) et des variables d'environnement."
    domain="ops"
    href="/docs/commands/ops/ops-env"
  />
  <CommandCard
    name="ops-gitflow-feature"
    description="Gérer les branches feature avec GitFlow."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-feature"
  />
  <CommandCard
    name="ops-gitflow-hotfix"
    description="Gérer les hotfixes urgents avec GitFlow."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-hotfix"
  />
  <CommandCard
    name="ops-gitflow-init"
    description="Initialiser GitFlow sur le repository."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-init"
  />
  <CommandCard
    name="ops-gitflow-release"
    description="Gérer les branches release avec GitFlow."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-release"
  />
  <CommandCard
    name="ops-grafana-dashboard"
    description="Creation de dashboards Grafana avec provisioning automatique."
    domain="ops"
    href="/docs/commands/ops/ops-grafana-dashboard"
  />
  <CommandCard
    name="ops-health"
    description="Vérification rapide de la santé d'un projet. Diagnostic express en 5 minutes."
    domain="ops"
    href="/docs/commands/ops/ops-health"
  />
  <CommandCard
    name="ops-hotfix"
    description="Workflow de correction urgente en production."
    domain="ops"
    href="/docs/commands/ops/ops-hotfix"
  />
  <CommandCard
    name="ops-infra-code"
    description="Implémente l'Infrastructure as Code (IaC) avec Terraform, CloudFormation ou Pulumi."
    domain="ops"
    href="/docs/commands/ops/ops-infra-code"
  />
  <CommandCard
    name="ops-k8s"
    description="Deploiement et orchestration Kubernetes."
    domain="ops"
    href="/docs/commands/ops/ops-k8s"
  />
  <CommandCard
    name="ops-load-testing"
    description="Mettre en place et exécuter des tests de charge et de stress."
    domain="ops"
    href="/docs/commands/ops/ops-load-testing"
  />
  <CommandCard
    name="ops-migrate"
    description="Migration de code, dépendances ou données."
    domain="ops"
    href="/docs/commands/ops/ops-migrate"
  />
  <CommandCard
    name="ops-mobile-release"
    description="Publication d'applications mobiles sur les stores (App Store, Google Play)."
    domain="ops"
    href="/docs/commands/ops/ops-mobile-release"
  />
  <CommandCard
    name="ops-monitoring"
    description="Instrumentation du code pour le monitoring, logging et alerting."
    domain="ops"
    href="/docs/commands/ops/ops-monitoring"
  />
  <CommandCard
    name="ops-observability-stack"
    description="Deploiement d'une stack d'observabilite complete (Prometheus, Grafana, Loki, Alertmanager)."
    domain="ops"
    href="/docs/commands/ops/ops-observability-stack"
  />
  <CommandCard
    name="ops-proxmox"
    description="Infrastructure Proxmox VE avec Terraform (VMs, LXC, réseau, stockage, backup)."
    domain="ops"
    href="/docs/commands/ops/ops-proxmox"
  />
  <CommandCard
    name="ops-release"
    description="Workflow de release avec changelog et versioning."
    domain="ops"
    href="/docs/commands/ops/ops-release"
  />
  <CommandCard
    name="ops-secrets-management"
    description="Implémente une gestion sécurisée des secrets et credentials."
    domain="ops"
    href="/docs/commands/ops/ops-secrets-management"
  />
  <CommandCard
    name="ops-serverless"
    description="Deploiement d'applications serverless (AWS Lambda, Vercel, Cloudflare Workers)."
    domain="ops"
    href="/docs/commands/ops/ops-serverless"
  />
  <CommandCard
    name="ops-vercel"
    description="Deploiement et configuration sur Vercel."
    domain="ops"
    href="/docs/commands/ops/ops-vercel"
  />
  <CommandCard
    name="ops-vps"
    description="Deploiement sur serveur VPS (OVH, Hetzner, DigitalOcean, Scaleway, etc.)."
    domain="ops"
    href="/docs/commands/ops/ops-vps"
  />
</CommandGrid>

---

[Retour a toutes les commandes](/docs/commands)
