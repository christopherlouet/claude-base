---
sidebar_position: 2
title: Commands Matrix
description: Breakdown of all claude-base commands by domain
---

# Commands Matrix

> **<!-- count:commands -->106<!-- /count --> commands** organized by domain
>
> For the exhaustive and always up-to-date list, see the [Commands Catalog](/docs/reference/commands) (auto-generated from `.claude/commands/`).

## WORK - Workflow (<!-- count:byDomain.work -->15<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/work:work-explore` | Explore and understand the code |
| `/work:work-brainstorm` | Structured ideation before specification |
| `/work:work-specify` | Create a specification (User Stories, criteria) |
| `/work:work-clarify` | Clarify spec ambiguities |
| `/work:work-plan` | Plan an implementation (plan.md + tasks.md) |
| `/work:work-commit` | Create a clean commit |
| `/work:work-pr` | Create a Pull Request |
| `/work:work-commit-push-pr` | Full workflow: commit + push + PR |
| `/work:work-team` | Launch a coordinated team of agents |
| `/work:work-quick` | Quick workflow for trivial changes |
| `/work:work-batch` | Sequential execution of stories from a PRD |
| `/work:work-flow-feature` | Full feature workflow |
| `/work:work-flow-bugfix` | Full bugfix workflow |
| `/work:work-flow-release` | Full release workflow |
| `/work:work-flow-launch` | Full launch workflow |

## DEV - Development (<!-- count:byDomain.dev -->16<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/dev:dev-tdd` | TDD cycle + generate tests + test infra setup |
| `/dev:dev-debug` | Debug an issue (4-phase methodology) |
| `/dev:dev-refactor` | Guided refactoring + entropy reduction |
| `/dev:dev-document` | Document generation (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Create/document a REST, GraphQL, or tRPC API + versioning |
| `/dev:dev-component` | Create a UI component (or custom hook) |
| `/dev:dev-error-handling` | Error handling strategy |
| `/dev:dev-react-perf` | React/Next.js performance optimization |
| `/dev:dev-mcp` | Create MCP servers |
| `/dev:dev-flutter` | Flutter widgets and screens |
| `/dev:dev-supabase` | Supabase backend (Auth, DB, Storage) |
| `/dev:dev-neovim` | Neovim/Lua plugins and config |
| `/dev:dev-rag` | RAG (Retrieval-Augmented Generation) systems |
| `/dev:dev-design-system` | Design tokens and component library |
| `/dev:dev-prisma` | Prisma ORM (schema, migrations, queries) |
| `/dev:dev-ai-integration` | LLM integration (OpenAI, Claude API) |

## QA - Quality (<!-- count:byDomain.qa -->13<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/qa:qa-review` | In-depth code review + naming analysis |
| `/qa:qa-security` | OWASP security audit |
| `/qa:qa-perf` | Performance analysis |
| `/qa:wcag-audit` | WCAG accessibility audit |
| `/qa:qa-audit` | Full quality audit |
| `/qa:qa-chrome` | Chrome visual tests (DOM debugging, responsive, captures) |
| `/qa:qa-design` | UI/UX audit (100+ web design rules, incl. responsive/mobile) |
| `/qa:qa-automation` | Test automation |
| `/qa:qa-loop` | Autonomous audit-fix loop with stop criteria |
| `/qa:qa-mobile` | Mobile app quality audit (Flutter) |
| `/qa:qa-neovim` | Neovim config audit |
| `/qa:qa-e2e` | End-to-End tests (Playwright, Cypress) |
| `/qa:qa-tech-debt` | Identify/prioritize tech debt (incl. coverage + Kaizen) |

## OPS - Operations (<!-- count:byDomain.ops -->28<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/ops:ops-hotfix` | Urgent production fix |
| `/ops:ops-release` | Create a release |
| `/ops:ops-gitflow` | GitFlow `<init\|feature\|release\|hotfix> <action>` |
| `/ops:ops-deps` | Dependencies audit |
| `/ops:ops-docker` | Dockerize a project |
| `/ops:ops-k8s` | Kubernetes deployment (manifests, Helm) |
| `/ops:ops-vps` | VPS deployment |
| `/ops:ops-migrate` | Code/dependency migration |
| `/ops:ops-ci` | CI/CD configuration |
| `/ops:ops-monitoring` | Instrument code + deploy the observability stack |
| `/ops:ops-grafana-dashboard` | Create Grafana dashboards |
| `/ops:ops-database` | DB schema, migrations |
| `/ops:ops-health` | Quick health check |
| `/ops:ops-env` | Environment management |
| `/ops:ops-load-testing` | Load and stress tests |
| `/ops:ops-cost` | Costs: Claude Code tokens + cloud FinOps |
| `/ops:ops-backup` | Backup/restore + disaster recovery (RPO/RTO) |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops:ops-secrets-management` | Secure secrets management |
| `/ops:ops-mobile-release` | App Store / Google Play publishing |
| `/ops:ops-serverless` | Serverless deployment (Lambda, Vercel, CF Workers) |
| `/ops:ops-vercel` | Vercel configuration and deployment |
| `/ops:ops-proxmox` | Proxmox VE infrastructure (VMs, LXC, network, backup) |
| `/ops:ops-opnsense` | OPNsense configuration via Terraform |
| `/ops:ops-deploy` | Secure deployment with pre-deploy checklist |
| `/ops:ops-rollback` | Safe rollback procedure |
| `/ops:ops-standup` | Cross-repo morning briefing |
| `/ops:ops-ci-fix` | Autonomous diagnosis and repair of failing CI |

## DOC - Documentation (<!-- count:byDomain.doc -->5<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/doc:doc-generate` | Generate documentation (README, architecture, API) |
| `/doc:doc-changelog` | Generate/maintain the changelog |
| `/doc:doc-explain` | Explain complex code |
| `/doc:doc-onboard` | Discover a codebase |
| `/doc:doc-api-spec` | Generate OpenAPI/Swagger spec |

## BIZ - Business (<!-- count:byDomain.biz -->9<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-mvp` | Define the MVP |
| `/biz:biz-pricing` | Pricing strategy |
| `/biz:biz-pitch` | Create a pitch deck |
| `/biz:biz-roadmap` | Plan the roadmap + define OKRs |
| `/biz:biz-launch` | Full launch workflow |
| `/biz:biz-competitor` | Market study + competitive analysis |
| `/biz:biz-personas` | Create user personas |
| `/biz:biz-research` | User research |

## GROWTH - Growth (<!-- count:byDomain.growth -->9<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/growth:growth-landing` | Create/optimize a landing page |
| `/growth:growth-seo` | SEO audit |
| `/growth:growth-analytics` | Tracking and KPI setup |
| `/growth:growth-app-store-analytics` | App Store / Google Play metrics |
| `/growth:growth-email` | Email marketing templates |
| `/growth:growth-ab-test` | Plan A/B tests |
| `/growth:growth-retention` | Retention strategies |
| `/growth:growth-localization` | Multi-market localization strategy |
| `/growth:growth-cro` | CRO + funnel analysis + onboarding/activation |

## DATA - Data (<!-- count:byDomain.data -->2<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/data:data-pipeline` | Design ETL/ELT pipelines |
| `/data:data-modeling` | Data warehouse modeling |

## LEGAL - Legal (<!-- count:byDomain.legal -->5<!-- /count -->)

| Command | Description |
|----------|-------------|
| `/legal:legal-docs` | ToS, T&Cs, legal notices |
| `/legal:legal-rgpd` | GDPR compliance |
| `/legal:legal-payment` | Payment integration |
| `/legal:legal-terms-of-service` | Terms of Service |
| `/legal:legal-privacy-policy` | Privacy policy |

## ASSISTANT (2)

| Command | Description |
|----------|-------------|
| `/assistant` | Single entry point, full guide |
| `/assistant-auto` | Automatic mode, analyzes and executes directly |

---

## See also

- [Agents Matrix](/docs/reference/agents-matrix)
- [Cheatsheet](/docs/reference/commands)
