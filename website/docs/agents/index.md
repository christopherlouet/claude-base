---
sidebar_position: 1
title: "Agents"
description: "Catalog of 58 claude-base sub-agents"
---

import Stats from '@site/src/components/Stats';
import { AgentGrid } from '@site/src/components/AgentCard';
import AgentCard from '@site/src/components/AgentCard';

# Agent Catalog

> **58 sub-agents** with isolated context for autonomous tasks

<Stats items={[
  { number: 19, label: 'Haiku agents' },
  { number: 33, label: 'Sonnet agents' },
  { number: 58, label: 'Total' },
]} />

## What is an Agent?

**Agents** are autonomous sub-agents with an isolated context:

- **Automatic triggering**: Claude delegates based on context
- **Isolated context**: Does not pollute the main conversation
- **Restricted tools**: Limited access based on the task
- **Specific model**: Haiku (fast) or Sonnet (complex)

## Agents by model

### Haiku (19 agents)

Fast and economical agents for simple tasks.

| Agent | Description | Tools |
|-------|-------------|--------|
| [`biz-model`](/docs/agents/biz-model) | Business analysis and business model proposal for a project. | Read, Grep, Glob... |
| [`dev-design-system`](/docs/agents/dev-design-system) | Design systems and component libraries. | Read, Grep, Glob |
| [`dev-prisma`](/docs/agents/dev-prisma) | Prisma ORM for type-safe databases. | Read, Grep, Glob... |
| [`dev-trpc`](/docs/agents/dev-trpc) | Type-safe APIs with tRPC. | Read, Grep, Glob |
| [`doc-changelog`](/docs/agents/doc-changelog) | Changelog management following the Keep a Changelog conventi... | Read, Grep, Glob... |
| [`doc-explain`](/docs/agents/doc-explain) | Pedagogical explanation of complex code. | Read, Grep, Glob |
| [`doc-onboard`](/docs/agents/doc-onboard) | Guide for discovering and understanding a codebase. | Read, Grep, Glob |
| [`growth-cro`](/docs/agents/growth-cro) | Conversion rate audit and optimization. | Read, Grep, Glob |
| [`growth-localization`](/docs/agents/growth-localization) | Localization strategy and international expansion. | Read, Grep, Glob |
| [`legal-privacy-policy`](/docs/agents/legal-privacy-policy) | Creation of a GDPR-compliant privacy policy. | Read, Grep, Glob... |
| [`legal-terms-of-service`](/docs/agents/legal-terms-of-service) | Creation of compliant Terms of Service. | Read, Grep, Glob... |
| [`ops-cost`](/docs/agents/ops-cost) | Token consumption analysis and cost optimization recommendat... | Read, Grep, Glob... |
| [`ops-deps`](/docs/agents/ops-deps) | Audit, analysis and recommendations for project dependencies... | Read, Grep, Glob... |
| [`ops-health`](/docs/agents/ops-health) | Quick health check to evaluate the general state of a projec... | Read, Grep, Glob... |
| [`ops-serverless`](/docs/agents/ops-serverless) | Deployment of serverless applications. | Read, Grep, Glob... |
| [`ops-vercel`](/docs/agents/ops-vercel) | Deployment on Vercel. | Read, Grep, Glob... |
| [`qa-responsive`](/docs/agents/qa-responsive) | Audit of responsive design and mobile experience. | Read, Grep, Glob |
| [`wcag-audit`](/docs/agents/wcag-audit) | Accessibility audit per WCAG 2.1/2.2 level AA, inspired by t... | Read, Grep, Glob |
| [`work-explore`](/docs/agents/work-explore) | EXPLORATION mode: codebase analysis without modifying files. | Read, Grep, Glob |

### Sonnet (33 agents)

Agents for complex tasks requiring in-depth analysis.

| Agent | Description | Tools |
|-------|-------------|--------|
| [`biz-competitor`](/docs/agents/biz-competitor) | Competitive analysis and strategic positioning for a project... | Read, Grep, Glob... |
| [`biz-mvp`](/docs/agents/biz-mvp) | Definition and planning of the Minimum Viable Product. | Read, Grep, Glob... |
| [`biz-personas`](/docs/agents/biz-personas) | Creation of user personas based on data. | Read, Grep, Glob... |
| [`data-modeling`](/docs/agents/data-modeling) | Design of dimensional data models for analytics. | Read, Grep, Glob... |
| [`data-pipeline`](/docs/agents/data-pipeline) | Design and implementation of ETL/ELT data pipelines. | Read, Grep, Glob... |
| [`dev-ai-integration`](/docs/agents/dev-ai-integration) | Integration of LLMs and AI APIs into applications. | Read, Grep, Glob... |
| [`dev-component`](/docs/agents/dev-component) | Creation of modular and reusable UI components. | Read, Grep, Glob... |
| [`dev-document`](/docs/agents/dev-document) | Generation of office documents and reports. | Read, Grep, Glob... |
| [`dev-flutter`](/docs/agents/dev-flutter) | Flutter development with Clean Architecture and BLoC. | Read, Grep, Glob... |
| [`dev-supabase`](/docs/agents/dev-supabase) | Complete integration of Supabase as a backend. | Read, Grep, Glob... |
| [`dev-test`](/docs/agents/dev-test) | Generation of complete and maintainable tests. | Read, Grep, Glob... |
| [`doc-generate`](/docs/agents/doc-generate) | Generation of complete and maintainable documentation. | Read, Grep, Glob... |
| [`growth-analytics`](/docs/agents/growth-analytics) | Analytics and tracking implementation, plus post-launch data... | Read, Grep, Glob... |
| [`growth-funnel`](/docs/agents/growth-funnel) | Analysis and optimization of conversion funnels. | Read, Grep, Glob... |
| [`growth-landing`](/docs/agents/growth-landing) | Creation of landing pages optimized for conversion. | Read, Grep, Glob... |
| [`growth-seo`](/docs/agents/growth-seo) | Technical SEO audit and optimization recommendations. | Read, Grep, Glob... |
| [`legal-payment`](/docs/agents/legal-payment) | Secure and compliant payment integration. | Read, Grep, Glob... |
| [`legal-rgpd`](/docs/agents/legal-rgpd) | GDPR compliance (General Data Protection Regulation). | Read, Grep, Glob... |
| [`ops-ci`](/docs/agents/ops-ci) | Configuration of complete CI/CD pipelines. | Read, Grep, Glob... |
| [`ops-database`](/docs/agents/ops-database) | Database design and management. | Read, Grep, Glob... |
| [`ops-deploy`](/docs/agents/ops-deploy) | Secure deployment with mandatory pre-deploy validation. | Read, Grep, Glob... |
| [`ops-docker`](/docs/agents/ops-docker) | Docker containerization optimized for production. | Read, Grep, Glob... |
| [`ops-infra-code`](/docs/agents/ops-infra-code) | Infrastructure as Code with Terraform/OpenTofu. The `ops-inf... | Read, Grep, Glob... |
| [`ops-migration`](/docs/agents/ops-migration) | Planning and execution of technical migrations. | Read, Grep, Glob... |
| [`ops-monitoring`](/docs/agents/ops-monitoring) | Complete instrumentation for observability (3 pillars). | Read, Grep, Glob... |
| [`ops-opnsense`](/docs/agents/ops-opnsense) | OPNsense configuration as IaC with Terraform. The `ops-opnse... | Read, Grep, Glob... |
| [`ops-proxmox`](/docs/agents/ops-proxmox) | Proxmox VE infrastructure management with Terraform. The `op... | Read, Grep, Glob... |
| [`qa-chrome`](/docs/agents/qa-chrome) | Visual audit and browser testing. Prerequisites: `claude --c... | Read, Grep, Glob... |
| [`qa-claudemd`](/docs/agents/qa-claudemd) | Audit of compliance with the project's CLAUDE.md and the rep... | Read, Grep, Glob... |
| [`qa-e2e`](/docs/agents/qa-e2e) | End-to-End tests for critical user journeys. | Read, Grep, Glob... |
| [`qa-perf`](/docs/agents/qa-perf) | Performance analysis and optimization. | Read, Grep, Glob... |
| [`work-batch`](/docs/agents/work-batch) | Autonomous execution of stories from a PRD. The `work-batch`... | Read, Grep, Glob... |
| [`work-quick`](/docs/agents/work-quick) | Quick workflow for trivial changes. The `work-quick` skill p... | Read, Grep, Glob... |


### Opus (6 agents)

Agents for critical tasks.

| Agent | Description | Tools |
|-------|-------------|--------|
| [`dev-debug`](/docs/agents/dev-debug) | Bug diagnostic and resolution. The `dev-debug` skill provide... | Read, Grep, Glob... |
| [`dev-rag`](/docs/agents/dev-rag) | Architecture and implementation of RAG systems. | Read, Grep, Glob... |
| [`dev-tdd`](/docs/agents/dev-tdd) | Test-driven development. The `dev-tdd` skill provides the de... | Read, Grep, Glob... |
| [`qa-audit`](/docs/agents/qa-audit) | Complete quality audit covering 5 domains. | Read, Grep, Glob... |
| [`qa-loop`](/docs/agents/qa-loop) | Autonomous **AUDIT (parallel) → VALIDATE → FIX → VERIFY → CH... | Read, Grep, Glob... |
| [`qa-security`](/docs/agents/qa-security) | OWASP Top 10 security audit. The `qa-security` skill provide... | Read, Grep, Glob... |


## Card view

<AgentGrid>
  <AgentCard
    name="biz-competitor"
    description="Competitive analysis and strategic positioning for a project."
    model="sonnet"
    tools={["Read","Grep","Glob","WebSearch"]}
    href="/docs/agents/biz-competitor"
  />
  <AgentCard
    name="biz-model"
    description="Business analysis and business model proposal for a project."
    model="haiku"
    tools={["Read","Grep","Glob","WebSearch"]}
    href="/docs/agents/biz-model"
  />
  <AgentCard
    name="biz-mvp"
    description="Definition and planning of the Minimum Viable Product."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-mvp"
  />
  <AgentCard
    name="biz-personas"
    description="Creation of user personas based on data."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/biz-personas"
  />
  <AgentCard
    name="data-modeling"
    description="Design of dimensional data models for analytics."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-modeling"
  />
  <AgentCard
    name="data-pipeline"
    description="Design and implementation of ETL/ELT data pipelines."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/data-pipeline"
  />
  <AgentCard
    name="dev-ai-integration"
    description="Integration of LLMs and AI APIs into applications."
    model="sonnet"
    tools={["Read","Grep","Glob","Bash"]}
    href="/docs/agents/dev-ai-integration"
  />
  <AgentCard
    name="dev-component"
    description="Creation of modular and reusable UI components."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-component"
  />
  <AgentCard
    name="dev-debug"
    description="Bug diagnostic and resolution. The `dev-debug` skill provides the detailed metho"
    model="opus"
    tools={["Read","Grep","Glob","Bash"]}
    href="/docs/agents/dev-debug"
  />
  <AgentCard
    name="dev-design-system"
    description="Design systems and component libraries."
    model="haiku"
    tools={["Read","Grep","Glob"]}
    href="/docs/agents/dev-design-system"
  />
  <AgentCard
    name="dev-document"
    description="Generation of office documents and reports."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-document"
  />
  <AgentCard
    name="dev-flutter"
    description="Flutter development with Clean Architecture and BLoC."
    model="sonnet"
    tools={["Read","Grep","Glob","Edit"]}
    href="/docs/agents/dev-flutter"
  />
</AgentGrid>

[See all agents...](#agents-by-model)

---

## See also

- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills
- [Commands](/docs/commands) - Manual commands
- [Skills](/docs/skills) - Auto-triggered skills
