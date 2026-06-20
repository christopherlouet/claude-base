# Stack Recipes

> For each stack, the **commands / agents / skills / rules** of the foundation that activate, plus 1-2 external links for generic best practices.
>
> The foundation does not reinvent REST conventions or Flutter Clean Architecture — it **applies them automatically** via its path-specific rules and specialized agents. This page is an orientation map, not a manual.

---

## Web (React, Next.js, Vue, Svelte, Astro)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-component` | Complete UI component (+ custom hooks) — tests + stories |
| Command | `/dev:dev-react-perf` | Rendering optimization (Core Web Vitals, memoization) |
| Command | `/dev:dev-design-system` | Tokens, shared components |
| Command | `/qa:qa-design`, `/qa:qa-chrome` | UI/UX + responsive/mobile-first, Chrome visual audits |
| Command | `/qa:wcag-audit` | WCAG 2.1 AA accessibility |
| Skill auto | `dev-shadcn`, `dev-nextjs`, `dev-frontend-design` | Activated on keywords (`shadcn`, `App Router`, `landing page`) |
| Rules auto | `react.md`, `nextjs.md`, `vue.md`, `svelte.md`, `astro.md`, `accessibility.md`, `performance.md`, `design-style.md` | Based on `**/*.tsx`, `**/components/**`, `**/app/**` |

### External best practices

- [React docs](https://react.dev/) · [Next.js docs](https://nextjs.org/docs) · [Vue docs](https://vuejs.org/)
- [Web Vitals](https://web.dev/vitals/) · [WCAG 2.2 quick ref](https://www.w3.org/WAI/WCAG22/quickref/)

---

## Mobile (Flutter)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-flutter` | Widgets, screens, BLoC, Clean Architecture |
| Command | `/qa:qa-mobile` | Mobile app quality audit |
| Command | `/ops:ops-mobile-release` | App Store + Play Store publishing via Fastlane |
| Skill auto | `dev-flutter` | Activated on `Flutter`, `widget`, `BLoC` |
| Rule auto | `flutter.md` | `**/*.dart`, `**/lib/**`, `**/test/**` |

### External best practices

- [Flutter docs](https://docs.flutter.dev/) · [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [BLoC library](https://bloclibrary.dev/) · [Material Design 3](https://m3.material.io/)

---

## API (REST, GraphQL, tRPC)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-api` | REST endpoints, GraphQL, tRPC, controllers, services, versioning |
| Skill auto | `dev-graphql` | GraphQL schema, resolvers, DataLoader, N+1 |
| Command | `/qa:qa-security` | OWASP Top 10 audit |
| Command | `/doc:doc-api-spec` | OpenAPI/Swagger spec |
| Rule auto | `api.md`, `security.md` | `**/api/**`, `**/routes/**`, `**/auth/**` |

### External best practices

- [REST API Tutorial](https://restfulapi.net/) · [GraphQL spec](https://spec.graphql.org/)
- [tRPC docs](https://trpc.io/) · [OWASP API Security Top 10](https://owasp.org/API-Security/)

---

## Auth (better-auth, Lucia, NextAuth, Clerk, Supabase Auth)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Skill auto | `dev-auth` | Activated on `auth`, `login`, `OAuth`, `2FA`, `better-auth`, `NextAuth`, `Lucia` |
| Command | `/dev:dev-supabase` | Supabase Auth + Row Level Security |
| Command | `/qa:qa-security` | Sessions, tokens, OWASP audit |
| Command | `/legal:legal-rgpd` | GDPR compliance |
| Rule auto | `security.md` | `**/auth/**`, `**/api/**`, `**/middleware/**` |

### External best practices

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [better-auth](https://www.better-auth.com/) · [Lucia](https://lucia-auth.com/) · [NextAuth/Auth.js](https://authjs.dev/)

---

## Database (Prisma, PostgreSQL, MongoDB)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/ops:ops-database` | Schema, migrations, indexes |
| Skill auto | `dev-prisma` | Activated on `Prisma`, `schema.prisma`, `migrate`, `Accelerate` |

### External best practices

- [Prisma docs](https://www.prisma.io/docs) · [PostgreSQL Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Database Refactoring patterns](https://databaserefactoring.com/)

---

## Infrastructure (Docker, K8s, VPS, Vercel, Serverless, Proxmox, OPNsense)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/ops:ops-docker` | Dockerization, multi-stage builds |
| Command | `/ops:ops-k8s` | Manifests, Helm |
| Command | `/ops:ops-vps`, `/ops:ops-vercel`, `/ops:ops-serverless` | Deployment targets |
| Command | `/ops:ops-infra-code` | Terraform / OpenTofu (modules, state, backends) |
| Command | `/ops:ops-proxmox`, `/ops:ops-opnsense` | Homelab / personal infra |
| Command | `/ops:ops-deploy`, `/ops:ops-rollback` | Safe deployment + rollback |
| Skill auto | `ops-infra-code`, `ops-proxmox`, `ops-opnsense` | Activated on keywords |
| Rule auto | `deploy-safety.md` | Dockerfile, docker-compose, .env, middleware |

### External best practices

- [Docker docs](https://docs.docker.com/) · [Kubernetes docs](https://kubernetes.io/docs/)
- [Terraform docs](https://developer.hashicorp.com/terraform/docs) · [The 12-Factor App](https://12factor.net/)

---

## Observability (logs, metrics, traces)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/ops:ops-monitoring` | Logs, metrics, alerts + deploy Prometheus/Grafana/Loki stack |
| Command | `/ops:ops-grafana-dashboard` | Grafana dashboards |
| Command | `/ops:ops-load-testing` | Load tests |
| Command | `/ops:ops-health` | Health checks |

### External best practices

- [3 pillars of observability](https://www.honeycomb.io/blog/observability-101-terminology-and-concepts)
- [OpenTelemetry](https://opentelemetry.io/) · [SRE Workbook (Google)](https://sre.google/workbook/)

---

## Testing (TDD, unit, integration, E2E)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-tdd` | Red-Green-Refactor cycle (mandatory workflow) + test generation + test infra setup |
| Command | `/qa:qa-e2e` | E2E tests (Playwright, Cypress) |
| Command | `/qa:qa-automation`, `/qa:qa-tech-debt` | Automation, coverage & tech-debt |
| Skill auto | `qa-e2e`, `api-mocking` | Activated on keywords (`E2E`, `MSW`, `mock API`) |
| Rule auto | `tdd-enforcement.md`, `testing.md` | All TS/Py/Go/Dart code, tests/, *.test.* |

### External best practices

- [Kent Beck — TDD by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- [Testing Library docs](https://testing-library.com/) · [Playwright docs](https://playwright.dev/)

---

## Backend languages (Go, Python, Rust, Ruby, Java, C#, PHP)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-debug`, `/dev:dev-refactor` | Investigation and refactoring |
| Skill auto | `dev-i18n` | Localization (next-intl, react-i18next, vue-i18n, flutter_localizations) |
| Rules auto | `go.md`, `python.md`, `rust.md`, `ruby.md`, `java.md`, `csharp.md`, `php.md` | Activated by file extension |

### External best practices

- [Effective Go](https://go.dev/doc/effective_go) · [PEP 8 (Python)](https://peps.python.org/pep-0008/)
- [Rust Book](https://doc.rust-lang.org/book/) · [Ruby Style Guide](https://rubystyle.guide/)

---

## Data (ETL, analytics, modeling)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/data:data-pipeline` | ETL/ELT pipelines (Airflow, dbt) |
| Command | `/data:data-modeling` | Data warehouse modeling (star/snowflake) |
| Command | `/growth:growth-analytics` | KPIs, cohort/RFM analysis, reports |
| Skill auto | `data-pipeline` | Activated on `ETL`, `Airflow`, `dbt` |

### External best practices

- [dbt docs](https://docs.getdbt.com/) · [Airflow docs](https://airflow.apache.org/docs/)
- [Kimball — The Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/books/)

---

## AI / LLM (RAG, prompt engineering, MCP)

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Command | `/dev:dev-ai-integration` | LLM integration (OpenAI, Claude) |
| Command | `/dev:dev-rag` | RAG systems (retrieval-augmented generation) |
| Command | `/dev:dev-mcp` | MCP server creation |

### External best practices

- [Anthropic — Claude best practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [OpenAI Prompting Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [MCP spec](https://modelcontextprotocol.io/)

---

## Business & Growth

### From the foundation

| Type | Element | Activation |
|---|---|---|
| Commands BIZ | `/biz:biz-model`, `biz-mvp`, `biz-pricing`, `biz-pitch`, `biz-roadmap` (+OKR), `biz-launch`, `biz-competitor` (+market), `biz-personas`, `biz-research` | Product strategy |
| Commands GROWTH | `/growth:growth-landing`, `growth-seo`, `growth-analytics`, `growth-ab-test`, `growth-cro` (+funnel +onboarding), `growth-retention`, `growth-email`, `growth-localization`, `growth-app-store-analytics` | Acquisition / activation / retention |
| Commands LEGAL | `/legal:legal-rgpd`, `legal-payment`, `legal-terms-of-service`, `legal-privacy-policy` | Compliance |
| Skill auto | `growth-cro` | Activated on `conversion`, `signup flow`, `paywall` |

### External best practices

- [Lean Canvas](https://leanstack.com/lean-canvas) · [AARRR Pirate Metrics](https://www.startups.com/library/expert-advice/aarrr-pirate-metrics)
- [OWASP Privacy](https://owasp.org/www-project-top-10-privacy-risks/) · [CNIL GDPR guides](https://www.cnil.fr/fr/reglement-europeen-protection-donnees)

---

## See also

- [EXTENDING-GUIDE](https://github.com/christopherlouet/claude-base/blob/main/docs/guides/EXTENDING-GUIDE.md) — How to add your own commands, skills, agents, rules
- [TEAM-GUIDE](https://github.com/christopherlouet/claude-base/blob/main/docs/guides/TEAM-GUIDE.md) — Team adoption, shared conventions
- [PROMPTING-GUIDE](https://github.com/christopherlouet/claude-base/blob/main/docs/guides/PROMPTING-GUIDE.md) — Claude Code prompting techniques
- [TROUBLESHOOTING-GUIDE](https://github.com/christopherlouet/claude-base/blob/main/docs/guides/TROUBLESHOOTING-GUIDE.md) — Common problems
- [Docusaurus site](https://christopherlouet.github.io/claude-base/) — Complete catalog (commands, agents, skills, rules)
