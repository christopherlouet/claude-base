# Available Agents (<!-- count:commands -->106<!-- /count --> commands, <!-- count:agents -->45<!-- /count --> sub-agents, <!-- count:skills -->53<!-- /count --> skills)

## Orchestrator (Single entry point)
| Command | Mode | Usage |
|---------|------|-------|
| `/assistant` | Guide | Analyze → Recommend → Wait for confirmation |
| `/assistant-auto` | Automatic | Analyze → Execute the workflow directly |

## WORK-: Main Workflow (<!-- count:byDomain.work -->15<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/work:work-explore` | Explore and understand the code |
| `/work:work-brainstorm` | Structured ideation before specification (alternatives, questioning) |
| `/work:work-specify` | Create a functional specification (User Stories, criteria) |
| `/work:work-clarify` | Clarify spec ambiguities (targeted questions) |
| `/work:work-plan` | Plan an implementation (generates plan.md + tasks.md) |
| `/work:work-commit` | Create a clean commit |
| `/work:work-pr` | Create a Pull Request |
| `/work:work-commit-push-pr` | **Full workflow: commit + push + PR** |
| `/work:work-team` | Launch a coordinated team of agents (Agent Teams) |
| `/work:work-quick` | Quick workflow for trivial changes (skip full cycle) |
| `/work:work-batch` | Sequential execution of user stories from a PRD |
| `/work:work-flow-feature` | Full feature workflow |
| `/work:work-flow-bugfix` | Full bugfix workflow |
| `/work:work-flow-release` | Full release workflow |
| `/work:work-flow-launch` | Full product launch workflow |

## DEV-: Development (<!-- count:byDomain.dev -->16<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/dev:dev-tdd` | TDD cycle + generate tests for existing code + test infra setup |
| `/dev:dev-debug` | Debug an issue (4-phase methodology) |
| `/dev:dev-refactor` | Guided refactoring + entropy reduction |
| `/dev:dev-document` | Document generation (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Create/document a REST, GraphQL, or tRPC API + versioning |
| `/dev:dev-component` | Create a complete UI component (or custom hook) |
| `/dev:dev-error-handling` | Error handling strategy |
| `/dev:dev-react-perf` | React/Next.js performance optimization |
| `/dev:dev-mcp` | Create MCP servers (Model Context Protocol) |
| `/dev:dev-flutter` | Flutter widgets and screens |
| `/dev:dev-supabase` | Supabase backend (Auth, DB, Storage, Postgres perf) |
| `/dev:dev-neovim` | Neovim/Lua plugins and config |
| `/dev:dev-rag` | RAG systems (Retrieval-Augmented Generation) |
| `/dev:dev-design-system` | Design tokens and component library |
| `/dev:dev-prisma` | Prisma ORM (schema, migrations, queries) |
| `/dev:dev-ai-integration` | LLM integration (OpenAI, Claude API) |

## QA-: Quality (<!-- count:byDomain.qa -->13<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/qa:qa-review` | Thorough code review + naming analysis |
| `/qa:qa-security` | OWASP security audit |
| `/qa:qa-perf` | Performance analysis |
| `/qa:wcag-audit` | WCAG accessibility audit |
| `/qa:qa-audit` | Full quality audit |
| `/qa:qa-chrome` | Chrome visual tests (DOM debugging, responsive, captures) |
| `/qa:qa-design` | UI/UX audit (100+ web design rules, incl. responsive/mobile-first) |
| `/qa:qa-automation` | Test automation |
| `/qa:qa-loop` | Autonomous audit-fix loop with stop criteria |
| `/qa:qa-mobile` | Mobile app quality audit (Flutter) |
| `/qa:qa-neovim` | Neovim config audit (perf, keymaps) |
| `/qa:qa-e2e` | End-to-End tests (Playwright, Cypress) |
| `/qa:qa-tech-debt` | Identify/prioritize technical debt (incl. coverage + Kaizen) |

## OPS-: Operations (<!-- count:byDomain.ops -->28<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/ops:ops-hotfix` | Urgent production fix |
| `/ops:ops-release` | Create a release |
| `/ops:ops-gitflow` | GitFlow `<init\|feature\|release\|hotfix> <action>` (init, branch start/finish/list) |
| `/ops:ops-deps` | Audit and update dependencies |
| `/ops:ops-docker` | Dockerize a project |
| `/ops:ops-k8s` | Kubernetes deployment (manifests, Helm) |
| `/ops:ops-vps` | VPS deployment (OVH, Hetzner, DigitalOcean) |
| `/ops:ops-migrate` | Code/dependency migration |
| `/ops:ops-ci` | CI/CD configuration |
| `/ops:ops-monitoring` | Instrument code + deploy the observability stack (Prometheus/Grafana/Loki) |
| `/ops:ops-grafana-dashboard` | Create Grafana dashboards (templates, alerts) |
| `/ops:ops-database` | DB schema, migrations |
| `/ops:ops-health` | Quick health check |
| `/ops:ops-env` | Environment management |
| `/ops:ops-load-testing` | Load and stress tests |
| `/ops:ops-cost` | Costs: Claude Code tokens + cloud FinOps optimization |
| `/ops:ops-backup` | Backup/restore + disaster recovery (RPO/RTO, failover) |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops:ops-secrets-management` | Secure secrets management |
| `/ops:ops-mobile-release` | App Store / Google Play publishing |
| `/ops:ops-serverless` | Serverless deployment (Lambda, Vercel, CF Workers) |
| `/ops:ops-vercel` | Vercel configuration and deployment |
| `/ops:ops-proxmox` | Proxmox VE infrastructure (VMs, LXC, network, backup) |
| `/ops:ops-opnsense` | OPNsense configuration via Terraform (firewall, NAT, DHCP/DNS) |
| `/ops:ops-deploy` | Secure deployment with pre-deploy checklist |
| `/ops:ops-rollback` | Secure rollback procedure |
| `/ops:ops-standup` | Cross-repo morning briefing (commits, PRs, CI, blockers, priorities) |
| `/ops:ops-ci-fix` | Autonomous diagnosis and repair of failing CI/CD pipelines |

## DOC-: Documentation (<!-- count:byDomain.doc -->5<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/doc:doc-generate` | Generate documentation |
| `/doc:doc-changelog` | Generate/maintain the changelog |
| `/doc:doc-explain` | Explain complex code |
| `/doc:doc-onboard` | Discover a codebase |
| `/doc:doc-api-spec` | Generate OpenAPI/Swagger spec |

## BIZ-: Business (<!-- count:byDomain.biz -->9<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-mvp` | Define the MVP |
| `/biz:biz-pricing` | Pricing strategy |
| `/biz:biz-pitch` | Create a pitch deck |
| `/biz:biz-roadmap` | Plan the roadmap + define OKRs |
| `/biz:biz-launch` | Full launch workflow |
| `/biz:biz-competitor` | Market study + competitive analysis |
| `/biz:biz-personas` | Create user personas |
| `/biz:biz-research` | User research |

## GROWTH-: Growth (<!-- count:byDomain.growth -->9<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/growth:growth-landing` | Create/optimize a landing page |
| `/growth:growth-seo` | SEO audit |
| `/growth:growth-analytics` | Tracking and KPI setup |
| `/growth:growth-app-store-analytics` | App Store / Google Play metrics |
| `/growth:growth-email` | Email marketing templates |
| `/growth:growth-ab-test` | Plan A/B tests |
| `/growth:growth-retention` | Retention strategies |
| `/growth:growth-localization` | Multi-market localization strategy |
| `/growth:growth-cro` | CRO + funnel analysis + onboarding/activation |

## DATA-: Data (<!-- count:byDomain.data -->2<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/data:data-pipeline` | Design ETL/ELT pipelines |
| `/data:data-modeling` | Data warehouse modeling |

## LEGAL-: Legal (<!-- count:byDomain.legal -->5<!-- /count -->)
| Command | Usage |
|---------|-------|
| `/legal:legal-docs` | ToS, T&Cs, legal notices |
| `/legal:legal-rgpd` | RGPD/GDPR compliance |
| `/legal:legal-payment` | Payment integration |
| `/legal:legal-terms-of-service` | Terms of Service |
| `/legal:legal-privacy-policy` | Privacy Policy |

## Sub-Agents (<!-- count:agents -->45<!-- /count -->)

Claude automatically delegates to specialized agents (isolated context, restricted tools).

### Concepts

| Concept | Folder | Trigger | Context |
|---------|--------|---------|---------|
| **Commands** | `.claude/commands/` | Manual (`/name`) | Shared |
| **Skills** | `.claude/skills/` | Automatic | Shared |
| **Agents** | `.claude/agents/` | Auto-delegation | **Isolated** |

### Agents by domain

| Domain | Agents | Models |
|--------|--------|--------|
| Exploration & Doc | `work-explore`, `doc-onboard`, `doc-generate`, `doc-changelog`, `doc-explain` | haiku |
| Quality & Audits | `qa-audit`, `qa-loop`, `qa-security`, `qa-perf`, `wcag-audit`, `qa-claudemd`, `qa-e2e`, `qa-chrome` | haiku/sonnet/**opus** (security, audit, loop) |
| Operations | `ops-deps`, `ops-health`, `ops-docker`, `ops-deploy`, `ops-ci`, `ops-database`, `ops-monitoring`, `ops-infra-code`, `ops-proxmox`, `ops-opnsense`, `ops-migration` | haiku/sonnet |
| Development | `dev-debug`, `dev-flutter`, `dev-document`, `dev-tdd` | haiku/sonnet (tdd, debug) |
| Business & Growth | `biz-model`, `biz-competitor`, `biz-mvp`, `biz-personas`, `growth-seo`, `growth-analytics`, `growth-landing`, `growth-localization`, `growth-cro` | haiku |
| Data | `data-pipeline` | haiku/sonnet |
| Legal | `legal-rgpd`, `legal-payment`, `legal-privacy-policy`, `legal-terms-of-service` | haiku/sonnet |

### Agent Configuration

Each agent defines: `model` (haiku/sonnet/opus), `permissionMode` (plan/default), `disallowedTools`, `hooks`, `skills`.

**Model distribution**: 22 haiku (trivial operations) / 34 sonnet (default) / 6 opus (critical reasoning: `qa-security`, `qa-audit`, `qa-loop`, `dev-tdd`, `dev-debug`, `dev-rag`).
