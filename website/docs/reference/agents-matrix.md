---
sidebar_position: 3
title: Agents Matrix
description: Breakdown of the 63 agents by model
---

# Agents Matrix

> **63 sub-agents** with model and tools
>
> For the exhaustive and always up-to-date list, see the [Agents catalog](/docs/reference/agents-catalog) (auto-generated from `.claude/agents/`).

## By model

Current breakdown: **22 Haiku** (fast/economical), **35 Sonnet** (analysis), **6 without explicit model**.

### Haiku (Fast/Economical)

| Agent | Description | Tools |
|-------|-------------|-------|
| `biz-competitor` | Competitive analysis | Read, Grep, Glob, WebSearch |
| `biz-model` | Business model | Read, Grep, Glob, WebSearch |
| `biz-mvp` | MVP definition | Read, Grep, Glob, Edit, Write |
| `biz-personas` | User personas | Read, Grep, Glob, Edit, Write |
| `dev-design-system` | Design tokens and components | Read, Grep, Glob |
| `dev-prisma` | Prisma ORM | Read, Grep, Glob, Bash |
| `dev-trpc` | Type-safe tRPC APIs | Read, Grep, Glob |
| `doc-changelog` | Generate changelog | Read, Grep, Glob, Edit, Write |
| `doc-explain` | Explain code | Read, Grep, Glob |
| `doc-generate` | Generate documentation | Read, Grep, Glob, Edit, Write |
| `doc-onboard` | Developer onboarding | Read, Grep, Glob |
| `growth-cro` | Conversion rate optimization | Read, Grep, Glob |
| `growth-localization` | Multi-market localization | Read, Grep, Glob |
| `growth-seo` | Technical SEO audit | Read, Grep, Glob, WebFetch |
| `legal-privacy-policy` | Privacy policy | Read, Grep, Glob, Edit, Write |
| `legal-terms-of-service` | Terms of Service | Read, Grep, Glob, Edit, Write |
| `ops-deps` | Dependency audit | Read, Grep, Glob, Bash |
| `ops-health` | Quick health check | Read, Grep, Glob, Bash |
| `ops-serverless` | Serverless deployment | Read, Grep, Glob, Bash |
| `ops-vercel` | Vercel deployment | Read, Grep, Glob, Bash |
| `wcag-audit` | WCAG accessibility audit | Read, Grep, Glob |
| `qa-coverage` | Test coverage | Read, Grep, Glob, Bash |
| `qa-design` | UI/UX audit | Read, Grep, Glob |
| `qa-responsive` | Responsive audit | Read, Grep, Glob |
| `qa-tech-debt` | Technical debt | Read, Grep, Glob |
| `work-explore` | Explore a codebase | Read, Grep, Glob |

### Sonnet (Complex/Analysis)

| Agent | Description | Tools |
|-------|-------------|-------|
| `data-analytics` | Data analysis | Read, Grep, Glob, Edit, Write, Bash |
| `data-modeling` | Data warehouse modeling | Read, Grep, Glob, Edit, Write |
| `data-pipeline` | ETL/ELT pipelines | Read, Grep, Glob, Edit, Write, Bash |
| `dev-ai-integration` | LLM integration (OpenAI, Claude) | Read, Grep, Glob, Bash |
| `dev-component` | UI components | Read, Grep, Glob, Edit, Write |
| `dev-debug` | Bug investigation | Read, Grep, Glob, Bash |
| `dev-document` | Document generation (PDF, DOCX) | Read, Grep, Glob, Edit, Write, Bash |
| `dev-flutter` | Flutter widgets and screens | Read, Grep, Glob, Edit, Write, Bash |
| `dev-prompt-engineering` | LLM prompt optimization | Read, Grep, Glob, WebFetch |
| `dev-rag` | RAG systems | Read, Grep, Glob, Bash |
| `dev-supabase` | Supabase backend | Read, Grep, Glob, Edit, Write, Bash |
| `dev-tdd` | TDD development | Read, Grep, Glob, Edit, Write, Bash |
| `dev-test` | Test generation | Read, Grep, Glob, Edit, Write, Bash |
| `growth-analytics` | Analytics and tracking setup | Read, Grep, Glob, Edit, Write, Bash |
| `growth-funnel` | Funnel optimization | Read, Grep, Glob, Edit, Write |
| `growth-landing` | Landing pages | Read, Grep, Glob, Edit, Write |
| `legal-payment` | Payment integration | Read, Grep, Glob, Edit, Write |
| `legal-rgpd` | GDPR compliance | Read, Grep, Glob, Edit, Write |
| `ops-ci` | CI/CD configuration | Read, Grep, Glob, Edit, Write, Bash |
| `ops-database` | DB schema and migrations | Read, Grep, Glob, Edit, Write, Bash |
| `ops-docker` | Docker containerization | Read, Grep, Glob, Edit, Write, Bash |
| `ops-infra-code` | Infrastructure as Code (Terraform) | Read, Grep, Glob, Edit, Write, Bash |
| `ops-migration` | Framework migration | Read, Grep, Glob, Bash |
| `ops-monitoring` | Instrumentation and monitoring | Read, Grep, Glob, Edit, Write, Bash |
| `ops-opnsense` | OPNsense configuration | Read, Grep, Glob, Edit, Write, Bash |
| `ops-proxmox` | Proxmox VE infrastructure | Read, Grep, Glob, Edit, Write, Bash |
| `qa-audit` | Full quality audit | Read, Grep, Glob, Bash |
| `qa-chrome` | Chrome visual tests | Read, Grep, Glob, Bash |
| `qa-e2e` | End-to-End tests | Read, Grep, Glob, Bash |
| `qa-perf` | Performance audit | Read, Grep, Glob, Bash |
| `qa-security` | OWASP security audit | Read, Grep, Glob, Bash |

## By domain

### Exploration & Documentation (5)

| Agent | Model | Usage |
|-------|-------|-------|
| `work-explore` | haiku | Explore and understand code |
| `doc-onboard` | haiku | New developer onboarding |
| `doc-changelog` | haiku | Generate the changelog |
| `doc-explain` | haiku | Explain complex code |
| `doc-generate` | haiku | Generate documentation |

### Quality & Audits (10)

| Agent | Model | Usage |
|-------|-------|-------|
| `qa-security` | sonnet | OWASP Top 10 security audit |
| `qa-audit` | sonnet | Full audit (security + GDPR + a11y + perf) |
| `qa-perf` | sonnet | Performance audit, Core Web Vitals |
| `qa-chrome` | sonnet | Chrome visual tests and debugging |
| `qa-e2e` | sonnet | End-to-End tests (Playwright, Cypress) |
| `wcag-audit` | haiku | WCAG 2.1 accessibility audit |
| `qa-coverage` | haiku | Test coverage analysis |
| `qa-design` | haiku | UI/UX audit (100+ rules) |
| `qa-responsive` | haiku | Responsive/mobile-first audit |
| `qa-tech-debt` | haiku | Identify technical debt |

### Operations (12)

| Agent | Model | Usage |
|-------|-------|-------|
| `ops-ci` | sonnet | CI/CD configuration |
| `ops-database` | sonnet | DB schema and migrations |
| `ops-docker` | sonnet | Docker containerization |
| `ops-infra-code` | sonnet | Infrastructure as Code (Terraform) |
| `ops-migration` | sonnet | Framework and version migration |
| `ops-monitoring` | sonnet | Instrumentation and monitoring |
| `ops-opnsense` | sonnet | OPNsense configuration via Terraform |
| `ops-proxmox` | sonnet | Proxmox VE infrastructure |
| `ops-deps` | haiku | Dependency audit, vulnerabilities |
| `ops-health` | haiku | Quick project health check |
| `ops-serverless` | haiku | Serverless deployment |
| `ops-vercel` | haiku | Vercel deployment |

### Development (13)

| Agent | Model | Usage |
|-------|-------|-------|
| `dev-ai-integration` | sonnet | LLM integration (OpenAI, Claude API) |
| `dev-component` | sonnet | UI component creation |
| `dev-debug` | sonnet | Bug investigation and diagnosis |
| `dev-document` | sonnet | Office document generation |
| `dev-flutter` | sonnet | Flutter widgets and screens |
| `dev-prompt-engineering` | sonnet | LLM prompt optimization |
| `dev-rag` | sonnet | RAG architecture |
| `dev-supabase` | sonnet | Supabase backend |
| `dev-tdd` | sonnet | TDD development (Red-Green-Refactor) |
| `dev-test` | sonnet | Test generation |
| `dev-design-system` | haiku | Design tokens and components |
| `dev-prisma` | haiku | Prisma ORM |
| `dev-trpc` | haiku | Type-safe tRPC APIs |

### Business & Growth (10)

| Agent | Model | Usage |
|-------|-------|-------|
| `growth-analytics` | sonnet | Analytics and tracking setup |
| `growth-funnel` | sonnet | Funnel optimization |
| `growth-landing` | sonnet | Optimized landing pages |
| `biz-model` | haiku | Business model analysis |
| `biz-competitor` | haiku | Competitive analysis |
| `biz-mvp` | haiku | MVP definition |
| `biz-personas` | haiku | User personas |
| `growth-cro` | haiku | Conversion rate optimization |
| `growth-localization` | haiku | Multi-market localization |
| `growth-seo` | haiku | Technical SEO audit |

### Data (3)

| Agent | Model | Usage |
|-------|-------|-------|
| `data-analytics` | sonnet | Data analysis |
| `data-modeling` | sonnet | Data warehouse modeling |
| `data-pipeline` | sonnet | ETL/ELT pipelines |

### Legal (4)

| Agent | Model | Usage |
|-------|-------|-------|
| `legal-payment` | sonnet | Payment integration |
| `legal-rgpd` | sonnet | GDPR compliance |
| `legal-privacy-policy` | haiku | Privacy policy |
| `legal-terms-of-service` | haiku | Terms of Service |

---

## See also

- [Commands Matrix](/docs/reference/commands-matrix)
- [Cheatsheet](/docs/reference/commands)
- [Architecture](/docs/intro/architecture)
