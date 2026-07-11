---
sidebar_position: 9
title: "Cheatsheet - Claude Code Agents"
description: " Visual reference of all available agents."
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Cheatsheet - Claude Code Agents

> Visual reference of all available agents.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         CLAUDE CODE AGENTS - CHEATSHEET                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  Total: <!-- count:commands -->106<!-- /count --> commands | <!-- count:agents -->44<!-- /count --> agents | <!-- count:skills -->53<!-- /count --> skills | 9 categories       ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│                              ASSISTANT                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│   ┌────────────────┐  ┌────────────────────┐                                │
│   │   /assistant   │  │  /assistant-auto   │                                │
│   │  Guide mode    │  │  Automatic mode    │                                │
│   └────────────────┘  └────────────────────┘                                │
│   Orchestrators: analyze intent and route to the right workflow.            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORK- : MAIN WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   EXPLORE → (BRAINSTORM) → SPECIFY → PLAN → TDD → AUDIT → COMMIT            │
│                                                                             │
│   ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────┐  ┌─────┐  ┌───────┐  ┌────────┐ │
│   │ EXPLORE │→│BRAINSTORM│→│ SPECIFY │→│ PLAN │→│ TDD │→│ AUDIT │→│ COMMIT │ │
│   │ Read    │  │ (option) │  │ Stories │  │ Plan │  │ R-G-R│  │ Score │  │ +PR    │ │
│   │ existing│  │ Ideation │  │ Criteria│  │ Files│  │ Tests│  │ ≥ 90  │  │        │ │
│   └─────────┘  └──────────┘  └─────────┘  └──────┘  └─────┘  └───────┘  └────────┘ │
│                                                                             │
│   Commands: /work:work-explore, /work:work-brainstorm,                      │
│   /work:work-specify, /work:work-plan, /dev:dev-tdd,                        │
│   /qa:qa-loop "score 90", /work:work-commit, /work:work-pr                  │
│                                                                             │
│   Chained workflows (all-in-one):                                           │
│   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ ┌─────────────┐  │
│   │ flow-feature   │ │ flow-bugfix    │ │ flow-release   │ │ flow-launch │  │
│   │ Feature A→Z    │ │ Bug A→Z        │ │ Release A→Z    │ │ Product A→Z │  │
│   └────────────────┘ └────────────────┘ └────────────────┘ └─────────────┘  │
│                                                                             │
│   Variants:                                                                 │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐                                  │
│   │  quick   │  │  batch   │  │   team   │                                  │
│   │ <50 LOC  │  │ Multi-US │  │ Agents   │                                  │
│   └──────────┘  └──────────┘  └──────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       DEV- : DEVELOPMENT (16 commands)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  TDD cycle     : tdd (cycle + test-gen + infra setup), debug, refactor      │
│  API & types   : api (REST/GraphQL/tRPC + versioning), prisma               │
│  UI & front    : component (+hooks), design-system, react-perf, error-handling│
│  Mobile/Edit   : flutter, neovim                                            │
│  AI / Document : ai-integration, rag, mcp, document                         │
│  Backend BaaS  : supabase                                                   │
│  → Full details: "DEV- : Development (16)" table below                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          QA- : QUALITY (13 commands)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│  Main audit      : qa-loop (audit + fix loop, score ≥ 90)                   │
│  Targeted audits : security, perf, design (UI/UX + responsive), tech-debt   │
│                    (debt + coverage + kaizen), review, audit, automation,e2e│
│  Specific        : wcag-audit (a11y), mobile, neovim, chrome (visual)       │
│  → Full details: "QA- : Quality (13)" table below                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       OPS- : OPERATIONS (28 commands)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  Release & deploy : release, deploy, rollback, hotfix, mobile-release       │
│  GitFlow          : gitflow <init|feature|release|hotfix> <action>          │
│  CI/CD            : ci, ci-fix, deps                                        │
│  Infra            : docker, k8s, vps, vercel, serverless,                   │
│                     proxmox, opnsense, infra-code                           │
│  Observability    : monitoring (+stack deploy), grafana-dashboard,          │
│                     load-testing, health                                    │
│  Data/Sec         : database, backup (+DR), secrets-management              │
│  Meta-ops         : env, migrate, cost (tokens+cloud FinOps), standup       │
│  → Full details: "OPS- : Operations (28)" table below                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOC- : DOCUMENTATION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌───────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐    │
│   │ GENERATE │  │ CHANGELOG │  │ EXPLAIN │  │ ONBOARD │  │ API-SPEC │    │
│   │ Auto doc │  │ History   │  │ Teach   │  │ Discover│  │ OpenAPI  │    │
│   └──────────┘  └───────────┘  └─────────┘  └─────────┘  └──────────┘    │
│   (generate covers README + architecture/ADR doc types)                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             BIZ- : BUSINESS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐                     │
│   │  MODEL  │  │   MVP   │  │ PRICING │  │  PITCH  │                     │
│   │ Canvas  │  │ Minimum │  │ Strategy│  │ Deck    │                     │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘                     │
│                                                                             │
│   ┌──────────────┐  ┌─────────┐  ┌──────────────────┐  ┌──────────┐      │
│   │ ROADMAP +OKR │  │ LAUNCH  │  │ COMPETITOR +market│  │ RESEARCH │      │
│   │ Plan + OKRs  │  │ Go-to   │  │ TAM/SAM + SWOT    │  │ User res │      │
│   └──────────────┘  └─────────┘  └──────────────────┘  └──────────┘      │
│                                                                             │
│   ┌──────────┐                                                             │
│   │ PERSONAS │                                                             │
│   │ Profiles │                                                             │
│   └──────────┘                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       GROWTH- : GROWTH (9 commands)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  Acquisition     : landing, seo, ab-test                                    │
│  Conversion      : cro (funnel + onboarding/activation)                     │
│  Measurement     : analytics, app-store-analytics                           │
│  Engagement      : email, retention                                         │
│  International   : localization                                             │
│  → Full details: "GROWTH- : Growth (9)" table below                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA- : DATA                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌──────────┐                                                │
│   │ PIPELINE │  │ MODELING │                                                │
│   │ ETL/ELT  │  │ DWH      │                                                │
│   └──────────┘  └──────────┘                                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             LEGAL- : LEGAL                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────────┐             │
│   │  DOCS   │  │  GDPR   │  │ PAYMENT │  │ TERMS-OF-SERVICE │             │
│   │ T&Cs    │  │ GDPR    │  │ Stripe  │  │ Detailed ToS     │             │
│   └─────────┘  └─────────┘  └─────────┘  └──────────────────┘             │
│                                                                             │
│   ┌────────────────┐                                                       │
│   │ PRIVACY-POLICY │                                                       │
│   │ Privacy        │                                                       │
│   └────────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════════════════╗
║                              QUICK REFERENCE                                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  MANDATORY WORKFLOW:                                                          ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │ EXPLORE → (BRAINSTORM) → SPECIFY → PLAN → TDD → AUDIT → COMMIT        │  ║
║  │ explore   brainstorm     specify   plan   dev-tdd   qa-loop   commit  │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  NEW FEATURE:             /work:work-flow-feature "description"            ║
║  BUG FIX:                 /work:work-flow-bugfix "issue #123"              ║
║  NEW RELEASE:             /work:work-flow-release "v2.0"                   ║
║  PRODUCT LAUNCH:          /work:work-flow-launch "my SaaS"                 ║
║                                                                               ║
║  FULL AUDIT:              /qa:qa-audit                                   ║
║  QUICK HEALTH CHECK:      /ops:ops-health                                 ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Commands by Category (<!-- count:commands -->106<!-- /count -->)

### Orchestrator (1)

| Command | Usage |
|----------|-------|
| `/assistant` | Guide for choosing agents and workflows |

### WORK- : Main Workflow (15)

| Command | Usage |
|----------|-------|
| `/work:work-explore` | Explore and understand the code |
| `/work:work-brainstorm` | Structured ideation before spec |
| `/work:work-specify` | Create a functional specification |
| `/work:work-clarify` | Clarify ambiguities |
| `/work:work-plan` | Plan an implementation |
| `/work:work-commit` | Create a clean commit |
| `/work:work-pr` | Create a Pull Request |
| `/work:work-commit-push-pr` | Commit + push + PR in a single command |
| `/work:work-quick` | Quick workflow (trivial changes, skip full cycle) |
| `/work:work-batch` | Sequential execution of user stories from a PRD |
| `/work:work-team` | Launch a team of coordinated agents (Agent Teams) |
| `/work:work-flow-feature` | Full feature workflow |
| `/work:work-flow-bugfix` | Full bugfix workflow |
| `/work:work-flow-release` | Full release workflow |
| `/work:work-flow-launch` | Full launch workflow |

### DEV- : Development (16)

| Command | Usage |
|----------|-------|
| `/dev:dev-tdd` | TDD cycle + test generation + test infra setup |
| `/dev:dev-debug` | Debug a problem |
| `/dev:dev-refactor` | Guided refactoring |
| `/dev:dev-document` | Document generation (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Create/document REST, GraphQL, or tRPC API + versioning |
| `/dev:dev-component` | Create a complete UI component (or custom hook) |
| `/dev:dev-error-handling` | Error handling strategy |
| `/dev:dev-react-perf` | React/Next.js optimization |
| `/dev:dev-mcp` | Create MCP servers |
| `/dev:dev-flutter` | Flutter widgets and screens |
| `/dev:dev-supabase` | Supabase backend (Auth, DB, Storage) |
| `/dev:dev-neovim` | Neovim plugins and config |
| `/dev:dev-design-system` | Design tokens and components |
| `/dev:dev-prisma` | Prisma ORM |
| `/dev:dev-rag` | RAG systems |
| `/dev:dev-ai-integration` | LLM integration (OpenAI, Claude) |

### QA- : Quality (13)

| Command | Usage |
|----------|-------|
| `/qa:qa-review` | Code review + naming analysis |
| `/qa:qa-security` | OWASP security audit |
| `/qa:qa-perf` | Performance analysis |
| `/qa:wcag-audit` | WCAG accessibility audit |
| `/qa:qa-audit` | Full audit (all in one) |
| `/qa:qa-design` | UI/UX audit (100+ rules, incl. responsive/mobile) |
| `/qa:qa-automation` | Test automation |
| `/qa:qa-e2e` | E2E tests (Playwright, Cypress) |
| `/qa:qa-mobile` | Mobile app quality audit |
| `/qa:qa-neovim` | Neovim config audit |
| `/qa:qa-tech-debt` | Technical debt (incl. coverage + kaizen) |
| `/qa:qa-chrome` | Chrome visual tests |
| `/qa:qa-loop` | Audit + fix loop until target score (90 by default) |

### OPS- : Operations (28)

| Command | Usage |
|----------|-------|
| `/ops:ops-hotfix` | Urgent production fix |
| `/ops:ops-release` | Create a release |
| `/ops:ops-rollback` | Safe rollback |
| `/ops:ops-gitflow` | GitFlow: `<init\|feature\|release\|hotfix> <action>` |
| `/ops:ops-deps` | Dependency audit and updates |
| `/ops:ops-docker` | Dockerize |
| `/ops:ops-k8s` | Kubernetes deployment |
| `/ops:ops-vps` | VPS deployment |
| `/ops:ops-migrate` | Code/deps migration |
| `/ops:ops-ci` | CI/CD pipelines |
| `/ops:ops-monitoring` | Logs, metrics, alerts + deploy stack (Prometheus/Grafana/Loki) |
| `/ops:ops-grafana-dashboard` | Grafana dashboards |
| `/ops:ops-database` | DB schema, migrations |
| `/ops:ops-health` | Quick health check |
| `/ops:ops-env` | Environment management |
| `/ops:ops-backup` | Backup/restore + disaster recovery (RPO/RTO) |
| `/ops:ops-load-testing` | Load testing |
| `/ops:ops-infra-code` | Infrastructure as Code |
| `/ops:ops-proxmox` | Proxmox VE infrastructure |
| `/ops:ops-opnsense` | OPNsense configuration |
| `/ops:ops-secrets-management` | Secrets management |
| `/ops:ops-serverless` | Serverless deployment |
| `/ops:ops-vercel` | Vercel configuration |
| `/ops:ops-mobile-release` | App/Play Store publishing |
| `/ops:ops-deploy` | Safe deployment with pre-deploy checklist |
| `/ops:ops-cost` | Claude Code token tracking and costs |
| `/ops:ops-standup` | Cross-repo morning briefing |
| `/ops:ops-ci-fix` | Autonomous CI diagnostic and repair |

### DOC- : Documentation (5)

| Command | Usage |
|----------|-------|
| `/doc:doc-generate` | Generate documentation (README, architecture/ADR, API, inline) |
| `/doc:doc-changelog` | Changelog |
| `/doc:doc-explain` | Explain complex code |
| `/doc:doc-onboard` | Discover a codebase |
| `/doc:doc-api-spec` | OpenAPI/Swagger spec |

### BIZ- : Business (9)

| Command | Usage |
|----------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-mvp` | Define the MVP |
| `/biz:biz-pricing` | Pricing strategy |
| `/biz:biz-pitch` | Pitch deck |
| `/biz:biz-roadmap` | Product roadmap + OKRs |
| `/biz:biz-launch` | Launch workflow |
| `/biz:biz-competitor` | Market study + competitive analysis |
| `/biz:biz-personas` | User personas |
| `/biz:biz-research` | User research |

### GROWTH- : Growth (9)

| Command | Usage |
|----------|-------|
| `/growth:growth-landing` | Landing page |
| `/growth:growth-seo` | SEO audit |
| `/growth:growth-analytics` | Tracking and KPIs |
| `/growth:growth-app-store-analytics` | App/Play Store metrics |
| `/growth:growth-email` | Email templates |
| `/growth:growth-ab-test` | A/B testing |
| `/growth:growth-retention` | Retention strategies |
| `/growth:growth-localization` | Multi-market localization |
| `/growth:growth-cro` | CRO + funnel + onboarding/activation |

### DATA- : Data (2)

| Command | Usage |
|----------|-------|
| `/data:data-pipeline` | ETL/ELT pipelines |
| `/data:data-modeling` | Data warehouse modeling |

### LEGAL- : Legal (5)

| Command | Usage |
|----------|-------|
| `/legal:legal-docs` | T&Cs, Sales T&Cs, legal notices |
| `/legal:legal-rgpd` | GDPR compliance |
| `/legal:legal-payment` | Payment integration |
| `/legal:legal-terms-of-service` | Terms of Service |
| `/legal:legal-privacy-policy` | Privacy Policy |

---

## Quick decision by intent

> "I want to do X" → which command to use?

| Intent | Command |
|-----------|----------|
| Understand existing code | `/work:work-explore` |
| Brainstorm / explore ideas | `/work:work-brainstorm` |
| Create a specification (User Stories) | `/work:work-specify` |
| Clarify ambiguities in a spec | `/work:work-clarify` |
| Plan a feature (architecture, tasks) | `/work:work-plan` |
| Implement with TDD | `/dev:dev-tdd` |
| Debug a problem | `/dev:dev-debug` |
| Refactor code | `/dev:dev-refactor` |
| Do a code review | `/qa:qa-review` |
| Full audit + fix loop | `/qa:qa-loop` |
| Check security (OWASP) | `/qa:qa-security` |
| Audit performance | `/qa:qa-perf` |
| Check accessibility (WCAG) | `/qa:wcag-audit` |
| Full audit (read-only) | `/qa:qa-audit` |
| Create a clean commit | `/work:work-commit` |
| Create a PR | `/work:work-pr` |
| Morning briefing / standup | `/ops:ops-standup` |
| Fix broken CI | `/ops:ops-ci-fix` |
| Deploy to production | `/ops:ops-deploy` |
| Quick health check | `/ops:ops-health` |

> If you hesitate: `/assistant` (guide mode) or `/assistant-auto "your request"` (direct execution).

---

## claude-base CLI (install & modules)

```
claude-base init [--preset <name>] .    Install (core-only by default; auto-detects stack)
claude-base modules                     List modules + what's installed
claude-base add <module> .              Opt into a module (biz, growth, legal, mobile, iac…)
claude-base remove <module> .           Opt back out
claude-base update [--all] .            Update; keeps the preset filter + flags recommendation/stack drift
claude-base update --detect-only .      Read-only: does the project still match its recorded preset?
claude-base validate .                  Check the install
```

Default install is **core-only** (work, dev, qa, ops, doc). Horizontal domains, the
`data` domain (`data-eng` module) and platform/stack tooling are opt-in modules.

## Common Scenarios

### New project
```
/doc:doc-onboard     → Understand the structure
/work:work-explore    → Explore the code
/work:work-plan       → Plan the work
```

### New feature (standard workflow)
```
/work:work-explore         → Understand the existing code
/work:work-specify         → Spec User Stories + Given/When/Then criteria
/work:work-plan            → Design the solution + tasks per US
/dev:dev-tdd               → Implement with tests (Red-Green-Refactor)
/qa:qa-loop "score 90"     → Audit + fix loop (mandatory before commit)
/work:work-commit          → Commit cleanly
/work:work-pr              → Create the PR
```

### Trivial change (skip full cycle)
```
/work:work-quick "rename X to Y"   # < 50 LOC, 1-3 files
```

### New feature (full workflow)
```
/work:work-flow-feature "add dark mode"
```

### Bug fix
```
/work:work-flow-bugfix "#123 - user cannot log in"
```

### Before going to production
```
/qa:qa-audit        → Full audit
/ops:ops-health      → Quick health check
```

### New release
```
/work:work-flow-release "v2.0.0"
```

### Launch a new business
```
/work:work-flow-launch "my new SaaS"
```

### Flutter mobile app
```
/work:work-explore → /work:work-plan → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
```

---

## Command Format

```
/{category}-{action} "context"

Categories:
• assistant → Orchestrator
• work-   → Base workflow
• dev-    → Development
• qa-     → Quality
• ops-    → Operations
• doc-    → Documentation
• biz-    → Business
• growth- → Growth
• data-   → Data
• legal-  → Legal
```

---

## Built-in Claude Code Commands

| Command | Usage |
|----------|-------|
| `/clear` | Reset the context |
| `/compact` | Compact the history |
| `/resume` | Resume a session |
| `/help` | Help |

---

## Keyboard Shortcuts

| Shortcut | Action |
|-----------|--------|
| `Escape` | Interrupt Claude |
| `Escape` x2 | Go back |
| `Tab` | Autocompletion |
| `Ctrl+C` | Cancel |

---

## Reasoning Keywords

| Keyword | Level |
|---------|--------|
| `think` | Basic |
| `think hard` | Deep |
| `think harder` | Deeper |
| `ultrathink` | Maximum |

---

## Commit Format

```
type(scope): description

Types: feat, fix, refactor, test, docs, style, chore, perf, hotfix
```

**Examples:**
```bash
feat(auth): add OAuth2 login
fix(api): handle null response
refactor(user): extract validation logic
```

---

## Configuration Files

| File | Role |
|---------|------|
| `CLAUDE.md` | Project instructions |
| `CLAUDE.local.md` | Local config (gitignore) |
| `.claude/settings.json` | Permissions and hooks |
| `.claude/commands/**/*.md` | Commands (organized by category) |
| `.claude/skills/` | Automatic skills |
| `.claude/agents/` | Isolated sub-agents |
| `.claude/rules/` | Path-based contextual rules |
| `.mcp.json` | MCP servers |

---

## Golden Rules

1. **Explore before coding** - Always understand the context
2. **Plan before implementing** - Avoids backtracking
3. **Tests BEFORE code (TDD)** - Mandatory Red-Green-Refactor cycle
4. **Audit before commit** - qa-loop score ≥ 90 mandatory before push
5. **Atomic commits** - One commit = one concern
6. **Conventional Commits** - `feat(scope): description`
7. **No secrets in code** - Use `.env` + gitleaks

---

## Resources

- [Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Official documentation](https://code.claude.com/docs/en/overview)

---

*Claude-Base v&lt;!-- version -->5.1.0&lt;!-- /version --> - <!-- count:commands -->106<!-- /count --> commands - <!-- count:agents -->44<!-- /count --> agents - <!-- count:skills -->53<!-- /count --> skills - <!-- count:rules -->32<!-- /count --> rules*
