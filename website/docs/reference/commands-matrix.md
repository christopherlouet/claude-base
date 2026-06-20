---
sidebar_position: 2
title: Commands Matrix
description: Breakdown of all claude-base commands by domain
---

# Commands Matrix

> **<!-- count:commands -->106<!-- /count --> commands** organized by domain
>
> For the exhaustive and always up-to-date list, see the [Commands Catalog](/docs/reference/commands) (auto-generated from `.claude/commands/`).

## WORK - Workflow (11)

| Command | Description |
|----------|-------------|
| `/work:work-explore` | Explore and understand the code |
| `/work:work-specify` | Create a specification |
| `/work:work-clarify` | Clarify the requirements |
| `/work:work-plan` | Plan an implementation |
| `/work:work-commit` | Create a clean commit |
| `/work:work-commit-push-pr` | Full workflow: commit + push + PR |
| `/work:work-pr` | Create a Pull Request |
| `/work:work-flow-feature` | Full feature workflow |
| `/work:work-flow-bugfix` | Full bugfix workflow |
| `/work:work-flow-release` | Full release workflow |
| `/work:work-flow-launch` | Full launch workflow |

## DEV - Development (23)

| Command | Description |
|----------|-------------|
| `/dev:dev-tdd` | TDD development |
| `/dev:dev-test` | Generate tests |
| `/dev:dev-testing-setup` | Configure the test infrastructure |
| `/dev:dev-debug` | Debug a problem |
| `/dev:dev-refactor` | Guided refactoring |
| `/dev:dev-document` | Document generation (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Create/document REST API |
| `/dev:dev-api-versioning` | API versioning |
| `/dev:dev-component` | Create a UI component |
| `/dev:dev-hook` | Create a React/Vue hook |
| `/dev:dev-error-handling` | Error handling strategy |
| `/dev:dev-react-perf` | React/Next.js optimization |
| `/dev:dev-mcp` | Create MCP servers |
| `/dev:dev-flutter` | Flutter widgets and screens |
| `/dev:dev-supabase` | Supabase backend |
| `/dev:dev-graphql` | GraphQL API |
| `/dev:dev-neovim` | Neovim plugins |
| `/dev:dev-rag` | RAG (Retrieval-Augmented Generation) systems |
| `/dev:dev-design-system` | Design tokens and component library |
| `/dev:dev-prisma` | Prisma ORM (schema, migrations, queries) |
| `/dev:dev-trpc` | Type-safe APIs with tRPC |
| `/dev:dev-ai-integration` | LLM integration (OpenAI, Claude API) |

## QA - Quality (15)

| Command | Description |
|----------|-------------|
| `/qa:qa-review` | In-depth code review |
| `/qa:qa-security` | OWASP security audit |
| `/qa:qa-perf` | Performance analysis |
| `/qa:wcag-audit` | WCAG accessibility audit |
| `/qa:qa-audit` | Full quality audit |
| `/qa:qa-chrome` | Chrome visual tests (DOM debugging, responsive, captures) |
| `/qa:qa-design` | UI/UX audit (100+ web design rules) |
| `/qa:qa-responsive` | Responsive/mobile audit |
| `/qa:qa-automation` | Test automation |
| `/qa:qa-coverage` | Test coverage analysis |
| `/qa:qa-e2e` | End-to-End tests (Playwright, Cypress) |
| `/qa:qa-kaizen` | Continuous improvement |
| `/qa:qa-mobile` | Mobile quality audit |
| `/qa:qa-neovim` | Neovim config audit |
| `/qa:qa-tech-debt` | Identify and prioritize technical debt |

## OPS - Operations (30)

| Command | Description |
|----------|-------------|
| `/ops:ops-hotfix` | Urgent production fix |
| `/ops:ops-release` | Create a release |
| `/ops:ops-deps` | Dependencies audit |
| `/ops:ops-docker` | Dockerize a project |
| `/ops:ops-migrate` | Code migration |
| `/ops:ops-ci` | CI/CD configuration |
| `/ops:ops-monitoring` | Logs, metrics, alerts |
| `/ops:ops-observability-stack` | Deploy Prometheus, Grafana, Loki, Alertmanager |
| `/ops:ops-grafana-dashboard` | Grafana dashboard |
| `/ops:ops-database` | Schema, DB migrations |
| `/ops:ops-health` | Quick health check |
| `/ops:ops-env` | Environment management |
| `/ops:ops-backup` | Backup/restore strategy |
| `/ops:ops-load-testing` | Load testing |
| `/ops:ops-cost-optimization` | Cloud cost optimization |
| `/ops:ops-disaster-recovery` | Recovery plan |
| `/ops:ops-infra-code` | Infrastructure as Code |
| `/ops:ops-secrets-management` | Secrets management |
| `/ops:ops-k8s` | Kubernetes |
| `/ops:ops-vps` | VPS configuration |
| `/ops:ops-mobile-release` | Mobile release |
| `/ops:ops-serverless` | Serverless deployment (Lambda, Vercel, CF Workers) |
| `/ops:ops-vercel` | Vercel configuration and deployment |
| `/ops:ops-proxmox` | Proxmox VE infrastructure (VMs, LXC, network, backup) |
| `/ops:ops-opnsense` | OPNsense configuration via Terraform |
| `/ops:ops-rollback` | Safe rollback procedure |
| `/ops:ops-gitflow-init` | Initialize GitFlow |
| `/ops:ops-gitflow-feature` | GitFlow feature |
| `/ops:ops-gitflow-release` | GitFlow release |
| `/ops:ops-gitflow-hotfix` | GitFlow hotfix |

## DOC - Documentation (9)

| Command | Description |
|----------|-------------|
| `/doc:doc-generate` | Generate documentation |
| `/doc:doc-changelog` | Generate changelog |
| `/doc:doc-explain` | Explain code |
| `/doc:doc-onboard` | Discover a codebase |
| `/doc:doc-i18n` | Internationalization |
| `/doc:doc-fix-issue` | Fix a GitHub issue |
| `/doc:doc-api-spec` | OpenAPI/Swagger spec |
| `/doc:doc-readme` | Create/improve README |
| `/doc:doc-architecture` | Document the architecture |

## BIZ - Business (11)

| Command | Description |
|----------|-------------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-market` | Market study |
| `/biz:biz-mvp` | Define the MVP |
| `/biz:biz-pricing` | Pricing strategy |
| `/biz:biz-pitch` | Create a pitch deck |
| `/biz:biz-roadmap` | Plan the roadmap |
| `/biz:biz-launch` | Launch workflow |
| `/biz:biz-competitor` | Competitive analysis |
| `/biz:biz-okr` | Define OKRs |
| `/biz:biz-personas` | Create personas |
| `/biz:biz-research` | User research |

## GROWTH - Growth (11)

| Command | Description |
|----------|-------------|
| `/growth:growth-landing` | Landing page |
| `/growth:growth-seo` | SEO audit |
| `/growth:growth-analytics` | Tracking setup |
| `/growth:growth-cro` | Conversion rate optimization (CRO) |
| `/growth:growth-onboarding` | Onboarding journey |
| `/growth:growth-email` | Email marketing |
| `/growth:growth-ab-test` | Plan A/B tests |
| `/growth:growth-retention` | Retention strategies |
| `/growth:growth-funnel` | Funnel optimization |
| `/growth:growth-localization` | Multi-market localization strategy |
| `/growth:growth-app-store-analytics` | App Store analytics |

## DATA - Data (2)

| Command | Description |
|----------|-------------|
| `/data:data-pipeline` | ETL/ELT pipelines |
| `/data:data-modeling` | Data modeling |

## LEGAL - Legal (5)

| Command | Description |
|----------|-------------|
| `/legal:legal-docs` | ToS, T&Cs, legal notices |
| `/legal:legal-rgpd` | GDPR compliance |
| `/legal:legal-payment` | Payment integration |
| `/legal:legal-terms-of-service` | ToS |
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
