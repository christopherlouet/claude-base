---
sidebar_position: 1
title: "OPS"
description: "OPS commands - Operations (CI/CD, Docker, monitoring, GitFlow)"
---

import { CommandGrid } from '@site/src/components/CommandCard';
import CommandCard from '@site/src/components/CommandCard';

# OPS Commands

> Operations (CI/CD, Docker, monitoring, GitFlow)

## Overview

This domain contains **34 commands** for operations (ci/cd, docker, monitoring, gitflow).

## Commands list

| Command | Description |
|----------|-------------|
| [`/ops:ops-backup`](/docs/commands/ops/ops-backup) | Backup and restore strategy for the project's critical data. |
| [`/ops:ops-ci`](/docs/commands/ops/ops-ci) | Configure CI/CD pipelines (GitHub Actions, GitLab CI, etc.). |
| [`/ops:ops-ci-fix`](/docs/commands/ops/ops-ci-fix) | Diagnose and repair failing CI/CD pipelines. |
| [`/ops:ops-cost`](/docs/commands/ops/ops-cost) | Track token consumption and Claude Code costs. |
| [`/ops:ops-cost-optimization`](/docs/commands/ops/ops-cost-optimization) | Analyze and optimize cloud infrastructure costs. |
| [`/ops:ops-database`](/docs/commands/ops/ops-database) | Schema design, migrations, and database optimization. |
| [`/ops:ops-deploy`](/docs/commands/ops/ops-deploy) | Secure deployment with mandatory pre-deploy checklist. |
| [`/ops:ops-deps`](/docs/commands/ops/ops-deps) | Audit, analysis and update of project dependencies. |
| [`/ops:ops-disaster-recovery`](/docs/commands/ops/ops-disaster-recovery) | Set up a disaster recovery strategy (Disaster Recovery). |
| [`/ops:ops-docker`](/docs/commands/ops/ops-docker) | Dockerization and containerization of projects. |
| [`/ops:ops-env`](/docs/commands/ops/ops-env) | Environment management (dev, staging, prod) and environment variables. |
| [`/ops:ops-gitflow-feature`](/docs/commands/ops/ops-gitflow-feature) | Manage feature branches with GitFlow (start, finish, list, publish, pull). |
| [`/ops:ops-gitflow-hotfix`](/docs/commands/ops/ops-gitflow-hotfix) | Manage urgent hotfixes with GitFlow (start, finish, list). |
| [`/ops:ops-gitflow-init`](/docs/commands/ops/ops-gitflow-init) | Initialize GitFlow on the repository with the appropriate branches and conventions. |
| [`/ops:ops-gitflow-release`](/docs/commands/ops/ops-gitflow-release) | Manage release branches with GitFlow (start, finish, list). |
| [`/ops:ops-grafana-dashboard`](/docs/commands/ops/ops-grafana-dashboard) | Creation of Grafana dashboards with automatic provisioning. |
| [`/ops:ops-health`](/docs/commands/ops/ops-health) | Quick health check of a project. Express diagnostic in 5 minutes. |
| [`/ops:ops-hotfix`](/docs/commands/ops/ops-hotfix) | Workflow for urgent production fixes. |
| [`/ops:ops-infra-code`](/docs/commands/ops/ops-infra-code) | Implements Infrastructure as Code (IaC) with Terraform, CloudFormation or Pulumi. |
| [`/ops:ops-k8s`](/docs/commands/ops/ops-k8s) | Kubernetes deployment and orchestration. |
| [`/ops:ops-load-testing`](/docs/commands/ops/ops-load-testing) | Set up and run load and stress tests. |
| [`/ops:ops-migrate`](/docs/commands/ops/ops-migrate) | Migration of code, dependencies or data. |
| [`/ops:ops-mobile-release`](/docs/commands/ops/ops-mobile-release) | Publishing mobile applications to stores (App Store, Google Play). |
| [`/ops:ops-monitoring`](/docs/commands/ops/ops-monitoring) | Code instrumentation for monitoring, logging and alerting. |
| [`/ops:ops-observability-stack`](/docs/commands/ops/ops-observability-stack) | Deployment of a complete observability stack (Prometheus, Grafana, Loki, Alertmanager). |
| [`/ops:ops-opnsense`](/docs/commands/ops/ops-opnsense) | Infrastructure as Code for OPNsense. Configure and manage an OPNsense firewall via Terraform. |
| [`/ops:ops-proxmox`](/docs/commands/ops/ops-proxmox) | Proxmox VE infrastructure management: VMs, LXC, network, storage, backup with Terraform. |
| [`/ops:ops-release`](/docs/commands/ops/ops-release) | Release workflow with changelog and versioning. |
| [`/ops:ops-rollback`](/docs/commands/ops/ops-rollback) | Secure rollback procedure to revert to a stable version. |
| [`/ops:ops-secrets-management`](/docs/commands/ops/ops-secrets-management) | Implements secure management of secrets and credentials. |
| [`/ops:ops-serverless`](/docs/commands/ops/ops-serverless) | Deployment of serverless applications (AWS Lambda, Vercel, Cloudflare Workers). |
| [`/ops:ops-standup`](/docs/commands/ops/ops-standup) | Morning briefing: commits, PRs, CI, blockers and priorities of the day. |
| [`/ops:ops-vercel`](/docs/commands/ops/ops-vercel) | Deployment and configuration on Vercel. |
| [`/ops:ops-vps`](/docs/commands/ops/ops-vps) | Deployment to a VPS server (OVH, Hetzner, DigitalOcean, Scaleway, etc.). |

## Commands in detail

<CommandGrid>
  <CommandCard
    name="ops-backup"
    description="Backup and restore strategy for the project's critical data."
    domain="ops"
    href="/docs/commands/ops/ops-backup"
  />
  <CommandCard
    name="ops-ci"
    description="Configure CI/CD pipelines (GitHub Actions, GitLab CI, etc.)."
    domain="ops"
    href="/docs/commands/ops/ops-ci"
  />
  <CommandCard
    name="ops-ci-fix"
    description="Diagnose and repair failing CI/CD pipelines."
    domain="ops"
    href="/docs/commands/ops/ops-ci-fix"
  />
  <CommandCard
    name="ops-cost"
    description="Track token consumption and Claude Code costs."
    domain="ops"
    href="/docs/commands/ops/ops-cost"
  />
  <CommandCard
    name="ops-cost-optimization"
    description="Analyze and optimize cloud infrastructure costs."
    domain="ops"
    href="/docs/commands/ops/ops-cost-optimization"
  />
  <CommandCard
    name="ops-database"
    description="Schema design, migrations, and database optimization."
    domain="ops"
    href="/docs/commands/ops/ops-database"
  />
  <CommandCard
    name="ops-deploy"
    description="Secure deployment with mandatory pre-deploy checklist."
    domain="ops"
    href="/docs/commands/ops/ops-deploy"
  />
  <CommandCard
    name="ops-deps"
    description="Audit, analysis and update of project dependencies."
    domain="ops"
    href="/docs/commands/ops/ops-deps"
  />
  <CommandCard
    name="ops-disaster-recovery"
    description="Set up a disaster recovery strategy (Disaster Recovery)."
    domain="ops"
    href="/docs/commands/ops/ops-disaster-recovery"
  />
  <CommandCard
    name="ops-docker"
    description="Dockerization and containerization of projects."
    domain="ops"
    href="/docs/commands/ops/ops-docker"
  />
  <CommandCard
    name="ops-env"
    description="Environment management (dev, staging, prod) and environment variables."
    domain="ops"
    href="/docs/commands/ops/ops-env"
  />
  <CommandCard
    name="ops-gitflow-feature"
    description="Manage feature branches with GitFlow (start, finish, list, publish, pull)."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-feature"
  />
  <CommandCard
    name="ops-gitflow-hotfix"
    description="Manage urgent hotfixes with GitFlow (start, finish, list)."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-hotfix"
  />
  <CommandCard
    name="ops-gitflow-init"
    description="Initialize GitFlow on the repository with the appropriate branches and conventions."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-init"
  />
  <CommandCard
    name="ops-gitflow-release"
    description="Manage release branches with GitFlow (start, finish, list)."
    domain="ops"
    href="/docs/commands/ops/ops-gitflow-release"
  />
  <CommandCard
    name="ops-grafana-dashboard"
    description="Creation of Grafana dashboards with automatic provisioning."
    domain="ops"
    href="/docs/commands/ops/ops-grafana-dashboard"
  />
  <CommandCard
    name="ops-health"
    description="Quick health check of a project. Express diagnostic in 5 minutes."
    domain="ops"
    href="/docs/commands/ops/ops-health"
  />
  <CommandCard
    name="ops-hotfix"
    description="Workflow for urgent production fixes."
    domain="ops"
    href="/docs/commands/ops/ops-hotfix"
  />
  <CommandCard
    name="ops-infra-code"
    description="Implements Infrastructure as Code (IaC) with Terraform, CloudFormation or Pulumi."
    domain="ops"
    href="/docs/commands/ops/ops-infra-code"
  />
  <CommandCard
    name="ops-k8s"
    description="Kubernetes deployment and orchestration."
    domain="ops"
    href="/docs/commands/ops/ops-k8s"
  />
  <CommandCard
    name="ops-load-testing"
    description="Set up and run load and stress tests."
    domain="ops"
    href="/docs/commands/ops/ops-load-testing"
  />
  <CommandCard
    name="ops-migrate"
    description="Migration of code, dependencies or data."
    domain="ops"
    href="/docs/commands/ops/ops-migrate"
  />
  <CommandCard
    name="ops-mobile-release"
    description="Publishing mobile applications to stores (App Store, Google Play)."
    domain="ops"
    href="/docs/commands/ops/ops-mobile-release"
  />
  <CommandCard
    name="ops-monitoring"
    description="Code instrumentation for monitoring, logging and alerting."
    domain="ops"
    href="/docs/commands/ops/ops-monitoring"
  />
  <CommandCard
    name="ops-observability-stack"
    description="Deployment of a complete observability stack (Prometheus, Grafana, Loki, Alertmanager)."
    domain="ops"
    href="/docs/commands/ops/ops-observability-stack"
  />
  <CommandCard
    name="ops-opnsense"
    description="Infrastructure as Code for OPNsense. Configure and manage an OPNsense firewall via Terraform."
    domain="ops"
    href="/docs/commands/ops/ops-opnsense"
  />
  <CommandCard
    name="ops-proxmox"
    description="Proxmox VE infrastructure management: VMs, LXC, network, storage, backup with Terraform."
    domain="ops"
    href="/docs/commands/ops/ops-proxmox"
  />
  <CommandCard
    name="ops-release"
    description="Release workflow with changelog and versioning."
    domain="ops"
    href="/docs/commands/ops/ops-release"
  />
  <CommandCard
    name="ops-rollback"
    description="Secure rollback procedure to revert to a stable version."
    domain="ops"
    href="/docs/commands/ops/ops-rollback"
  />
  <CommandCard
    name="ops-secrets-management"
    description="Implements secure management of secrets and credentials."
    domain="ops"
    href="/docs/commands/ops/ops-secrets-management"
  />
  <CommandCard
    name="ops-serverless"
    description="Deployment of serverless applications (AWS Lambda, Vercel, Cloudflare Workers)."
    domain="ops"
    href="/docs/commands/ops/ops-serverless"
  />
  <CommandCard
    name="ops-standup"
    description="Morning briefing: commits, PRs, CI, blockers and priorities of the day."
    domain="ops"
    href="/docs/commands/ops/ops-standup"
  />
  <CommandCard
    name="ops-vercel"
    description="Deployment and configuration on Vercel."
    domain="ops"
    href="/docs/commands/ops/ops-vercel"
  />
  <CommandCard
    name="ops-vps"
    description="Deployment to a VPS server (OVH, Hetzner, DigitalOcean, Scaleway, etc.)."
    domain="ops"
    href="/docs/commands/ops/ops-vps"
  />
</CommandGrid>

---

[Back to all commands](/docs/commands)
