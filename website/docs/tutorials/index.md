---
sidebar_position: 1
title: Tutorials
description: Learn how to use claude-socle with progressive step-by-step tutorials
---

import TutorialCard, { TutorialGrid } from '@site/src/components/TutorialCard';

# Tutorials

Welcome to the claude-socle tutorials! These hands-on guides walk you step-by-step through mastering the **Explore → Specify → Plan → TDD → Audit → Commit** workflow.

## Recommended path

Follow these tutorials in order for an optimal progression:

<TutorialGrid>
  <TutorialCard
    title="First project"
    description="Discover the basic workflow by creating your first feature with claude-socle."
    duration="15 min"
    difficulty="beginner"
    href="/docs/tutorials/first-project"
  />
  <TutorialCard
    title="React feature"
    description="Create a complete React component and hook with tests and documentation."
    duration="30 min"
    difficulty="beginner"
    href="/docs/tutorials/feature-react"
    prerequisites={['Tutorial 01', 'React']}
  />
  <TutorialCard
    title="Node.js REST API"
    description="Build a complete REST API with TDD, validation and OpenAPI documentation."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-rest-node"
    prerequisites={['Node.js', 'Express/Fastify']}
  />
  <TutorialCard
    title="Flutter + Supabase"
    description="Build a Flutter mobile app with authentication and a Supabase backend."
    duration="60 min"
    difficulty="intermediate"
    href="/docs/tutorials/flutter-supabase"
    prerequisites={['Flutter SDK', 'Supabase account']}
  />
  <TutorialCard
    title="Security audit"
    description="Run a complete OWASP security audit and fix the vulnerabilities."
    duration="30 min"
    difficulty="intermediate"
    href="/docs/tutorials/security-audit"
    prerequisites={['Existing web project']}
  />
  <TutorialCard
    title="CI/CD pipeline"
    description="Set up a complete GitHub Actions pipeline with tests, build and deployment."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/cicd-github"
    prerequisites={['GitHub repository']}
  />
  <TutorialCard
    title="Legacy refactoring"
    description="Refactor a legacy project using TDD and a methodical approach."
    duration="60 min"
    difficulty="advanced"
    href="/docs/tutorials/refactoring-legacy"
    prerequisites={['Project to refactor']}
  />
  <TutorialCard
    title="Proxmox infrastructure"
    description="Deploy a Proxmox infrastructure with Terraform and monitoring."
    duration="60 min"
    difficulty="advanced"
    href="/docs/tutorials/proxmox-infra"
    prerequisites={['Proxmox', 'Terraform']}
  />
  <TutorialCard
    title="OPNsense firewall"
    description="Configure OPNsense as a firewall behind an ISP box with Terraform."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/opnsense-firewall"
    prerequisites={['OPNsense', 'Terraform']}
  />
  <TutorialCard
    title="Python FastAPI"
    description="Build a FastAPI REST API with pytest TDD, Pydantic validation and OpenAPI documentation."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-python"
    prerequisites={['Python 3.11+', 'uv or pip']}
  />
  <TutorialCard
    title="Go API"
    description="Build a Go REST API with Chi, table-driven TDD and OpenAPI documentation."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-go"
    prerequisites={['Go 1.22+']}
  />
</TutorialGrid>

## Capstone project

<TutorialGrid>
  <TutorialCard
    title="Complete project: TaskFlow"
    description="Build a mini-SaaS from A to Z using the full foundation workflow: Specify, Plan, TDD, Audit, CI/CD, Deploy."
    duration="3-4h"
    difficulty="advanced"
    href="/docs/tutorials/complete-project"
    prerequisites={['Tutorials 01-06', 'Node.js', 'React']}
  />
</TutorialGrid>

## General prerequisites

Before starting, make sure you have:

- **Claude Code** installed and working
- **claude-socle** configured in your project (see [Installation](/docs/intro/installation))
- Basic command-line knowledge

## How to use these tutorials

1. **Follow the suggested order** - The tutorials are designed to be progressive
2. **Practice** - Run each command yourself
3. **Compare your results** - Each step shows the expected result
4. **Experiment** - Once the tutorial is finished, adapt it to your own projects

## Need help?

- Check the [FAQ](/docs/guides/faq) for common questions
- Check [Troubleshooting](/docs/guides/troubleshooting) if you run into issues
- Open a [GitHub issue](https://github.com/christopherlouet/claude-socle/issues) if you're stuck
