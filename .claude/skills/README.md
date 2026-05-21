# Claude Code Skills

This folder contains **Skills** — reusable domain knowledge that teaches Claude the project's patterns and conventions.

## Difference between Commands and Skills

| Aspect | Commands (`.claude/commands/`) | Skills (`.claude/skills/`) |
|--------|-------------------------------|---------------------------|
| **Invocation** | Explicit: `/name` | Automatic or `/name` |
| **Format** | A single `.md` file | Folder with `SKILL.md` + resources |
| **Trigger** | Manual only | Based on the description (semantic) |
| **Resources** | No | Yes (examples/, scripts/, references/) |

## Structure of a Skill

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── examples/          # Concrete examples (optional)
│   └── example-1.md
├── references/        # Additional documentation (optional)
└── scripts/           # Helper scripts (optional)
```

## Available skills (54)

| Skill | Trigger keywords | Description |
|-------|----------------------|-------------|
| `agent-teams` | agent team, swarm, coordinated multi-agents | Orchestration of agent teams (native Agent Teams) |
| `api-mocking` | API mock, MSW, test without backend | API mock configuration for tests |
| `data-pipeline` | ETL, Airflow, dbt | Design of ETL/ELT pipelines |
| `dev-api` | API, endpoint, REST, route | Develop and document a REST or GraphQL API |
| `dev-auth` | login, signup, OAuth, sessions, 2FA | Modern web auth (better-auth, Lucia, NextAuth, Clerk, Supabase Auth) |
| `dev-debug` | bug, error, debug, not working | Debug and resolve problems |
| `dev-document` | PDF, DOCX, XLSX, PPTX, report | Office document generation |
| `dev-error-handling` | error handling, exceptions, error boundary | Error handling strategy |
| `dev-flutter` | Flutter, widget, BLoC | Flutter development with Clean Architecture |
| `dev-frontend-design` | UI, landing page, visual component, art direction | Distinctive UI design with strong art direction |
| `dev-graphql` | GraphQL, resolver, schema | GraphQL API development |
| `dev-i18n` | i18n, translation, locale, multiple languages | Internationalization (next-intl, react-i18next, vue-i18n, ARB) |
| `dev-nextjs` | Next.js, App Router, RSC, Server Actions | Next.js development (caching, streaming, middleware) |
| `dev-prisma` | Prisma, schema.prisma, migration, type-safe queries | Development with Prisma ORM |
| `dev-react-perf` | React perf, re-render, memo | React/Next.js performance optimization |
| `dev-refactor` | refactor, clean code, restructure | Code refactoring |
| `dev-shadcn` | shadcn, shadcn/ui, Radix, copy-paste components | Integration and customization of shadcn/ui |
| `dev-supabase` | Supabase, auth, RLS, storage | Supabase backend development |
| `dev-tdd` | TDD, test first, write the tests | Red-Green-Refactor TDD cycle |
| `doc-changelog` | changelog, release notes | CHANGELOG maintenance |
| `doc-generate` | document, README, JSDoc | Technical documentation generation |
| `feature-flags` | feature flag, A/B test, progressive deployment | Feature flags and toggles management |
| `git-worktrees` | worktree, parallel dev, simultaneous branches | Git worktrees for parallel dev |
| `growth-cro` | conversion, CRO, signup flow, onboarding | Conversion rate optimization |
| `ops-ci` | CI/CD, GitHub Actions, pipeline | CI/CD pipeline configuration |
| `ops-ci-fix` | broken CI, red workflow, failing CI tests | Autonomous diagnosis and repair of CI/CD pipelines |
| `ops-database` | schema, migration, index | Database schema design |
| `ops-docker` | Docker, container, Dockerfile | Docker and Docker Compose containerization |
| `ops-infra-code` | Terraform, IaC, OpenTofu | Infrastructure as Code |
| `ops-mobile-release` | App Store, Play Store, Fastlane | Mobile app publishing |
| `ops-monitoring` | logs, metrics, traces | Application instrumentation |
| `ops-opnsense` | OPNsense, firewall, NAT, DHCP | OPNsense configuration via Terraform |
| `ops-proxmox` | Proxmox, PVE, VM, LXC, PBS | Proxmox VE infrastructure with Terraform |
| `ops-standup` | standup, morning briefing, activity summary | Cross-repo briefing (commits, PRs, CI, blockers) |
| `parallel-agents` | parallel, concurrent, fan-out, multi-agents | Parallel agent orchestration |
| `qa-chrome` | browser, Chrome DevTools, console, UI tests | Visual audit and browser tests via Chrome |
| `qa-design` | design audit, UI/UX, interface | UI/UX design audit |
| `qa-e2e` | E2E, Playwright, Cypress | End-to-End tests |
| `qa-perf` | optimize, latency, TTFB | Performance optimization |
| `qa-review` | review, re-read, verify the code | In-depth code review |
| `qa-security` | security, audit, vulnerability, OWASP | OWASP security audit |
| `qa-tech-debt` | technical debt, tech debt, refactoring priority | Technical debt management |
| `session-handoff` | handoff, resume, session transfer | Context transfer between sessions |
| `state-management` | state, Redux, Zustand, store | State management patterns |
| `web-scraping` | scraping, Firecrawl, crawler, extract | Clean web scraping for LLMs (Firecrawl + Playwright fallback) |
| `work-batch` | backlog, batch stories, autonomous mode, PRD | Sequential execution of user stories from a PRD |
| `work-brainstorm` | brainstorm, ideation, alternatives, fuzzy idea | Structured ideation before specification |
| `work-commit` | commit, commit message | Conventional Commits messages |
| `work-explore` | explore, understand the code, discover | Explore and understand a codebase |
| `work-plan` | plan, architecture, plan | Plan an implementation |
| `work-pr` | PR, pull request, merge | Create a complete Pull Request |
| `work-quick` | quick, fast, rapid, simple fix, typo | Quick workflow for trivial changes |
| `writing-skills` | create skill, new skill, write a skill | Guide to create new skills |

## Naming convention

Skills follow the `domain-action` convention:

| Domain | Examples |
|--------|----------|
| `work-` | `work-explore`, `work-plan`, `work-commit`, `work-pr` |
| `dev-` | `dev-tdd`, `dev-debug`, `dev-api`, `dev-flutter` |
| `qa-` | `qa-review`, `qa-security`, `qa-perf`, `qa-e2e` |
| `ops-` | `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring` |
| `doc-` | `doc-generate`, `doc-changelog` |
| `growth-` | `growth-cro` |
| `data-` | `data-pipeline` |

## Create a new Skill

1. Create the folder: `mkdir .claude/skills/domain-action`
2. Create `SKILL.md` with YAML frontmatter
3. Add examples in `examples/` (recommended)
4. The description must include the triggers (when to use)

## Best practices

- **Consistent naming**: Use the `domain-action` format (e.g., `dev-tdd`, `qa-security`)
- **Rich description**: Include all trigger keywords
- **SKILL.md < 500 lines**: Details in `references/`
- **Concrete examples**: Show the good AND the bad pattern
