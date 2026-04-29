# Stack Recipes

> Pour chaque stack, les **commandes / agents / skills / rules** du socle qui s'activent, plus 1-2 liens externes pour les best practices génériques.
>
> Le socle ne réinvente pas les conventions REST ou la Clean Architecture Flutter — il les **applique automatiquement** via ses rules path-specific et ses agents spécialisés. Cette page est une carte d'orientation, pas un manuel.

---

## Web (React, Next.js, Vue, Svelte, Astro)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-component` | Création de composant UI complet (tests + stories) |
| Command | `/dev:dev-react-perf` | Optimisation rendering (Core Web Vitals, memoization) |
| Command | `/dev:dev-hook` | Création de hooks React/Vue customs |
| Command | `/dev:dev-design-system` | Tokens, composants partagés |
| Command | `/qa:qa-design`, `/qa:qa-responsive`, `/qa:qa-chrome` | Audits UI/UX, mobile-first, visuels Chrome |
| Command | `/qa:wcag-audit` | Accessibilité WCAG 2.1 AA |
| Skill auto | `dev-shadcn`, `dev-nextjs`, `dev-frontend-design` | Activés sur mots-clés (`shadcn`, `App Router`, `landing page`) |
| Rules auto | `react.md`, `nextjs.md`, `vue.md`, `svelte.md`, `astro.md`, `accessibility.md`, `performance.md`, `design-style.md` | Selon `**/*.tsx`, `**/components/**`, `**/app/**` |

### Best practices externes

- [React docs](https://react.dev/) · [Next.js docs](https://nextjs.org/docs) · [Vue docs](https://vuejs.org/)
- [Web Vitals](https://web.dev/vitals/) · [WCAG 2.2 quick ref](https://www.w3.org/WAI/WCAG22/quickref/)

---

## Mobile (Flutter)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-flutter` | Widgets, screens, BLoC, Clean Architecture |
| Command | `/qa:qa-mobile` | Audit qualité apps mobiles |
| Command | `/ops:ops-mobile-release` | Publication App Store + Play Store via Fastlane |
| Skill auto | `dev-flutter` | Activé sur `Flutter`, `widget`, `BLoC` |
| Rule auto | `flutter.md` | `**/*.dart`, `**/lib/**`, `**/test/**` |

### Best practices externes

- [Flutter docs](https://docs.flutter.dev/) · [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [BLoC library](https://bloclibrary.dev/) · [Material Design 3](https://m3.material.io/)

---

## API (REST, GraphQL, tRPC)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-api` | Endpoints REST, controllers, services |
| Command | `/dev:dev-api-versioning` | Stratégies de versioning |
| Command | `/dev:dev-graphql` | Schema GraphQL, resolvers |
| Command | `/dev:dev-trpc` | APIs type-safe TypeScript |
| Command | `/qa:qa-security` | Audit OWASP Top 10 |
| Command | `/doc:doc-api-spec` | Spec OpenAPI/Swagger |
| Rule auto | `api.md`, `security.md` | `**/api/**`, `**/routes/**`, `**/auth/**` |

### Best practices externes

- [REST API Tutorial](https://restfulapi.net/) · [GraphQL spec](https://spec.graphql.org/)
- [tRPC docs](https://trpc.io/) · [OWASP API Security Top 10](https://owasp.org/API-Security/)

---

## Auth (better-auth, Lucia, NextAuth, Clerk, Supabase Auth)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Skill auto | `dev-auth` | Activé sur `auth`, `login`, `OAuth`, `2FA`, `better-auth`, `NextAuth`, `Lucia` |
| Command | `/dev:dev-supabase` | Auth + Row Level Security Supabase |
| Command | `/qa:qa-security` | Audit sessions, tokens, OWASP |
| Command | `/legal:legal-rgpd` | Conformité RGPD/GDPR |
| Rule auto | `security.md` | `**/auth/**`, `**/api/**`, `**/middleware/**` |

### Best practices externes

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [better-auth](https://www.better-auth.com/) · [Lucia](https://lucia-auth.com/) · [NextAuth/Auth.js](https://authjs.dev/)

---

## Database (Prisma, PostgreSQL, MongoDB)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/ops:ops-database` | Schema, migrations, indexes |
| Skill auto | `dev-prisma` | Activé sur `Prisma`, `schema.prisma`, `migrate`, `Accelerate` |

### Best practices externes

- [Prisma docs](https://www.prisma.io/docs) · [PostgreSQL Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Database Refactoring patterns](https://databaserefactoring.com/)

---

## Infrastructure (Docker, K8s, VPS, Vercel, Serverless, Proxmox, OPNsense)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/ops:ops-docker` | Dockerisation, multi-stage builds |
| Command | `/ops:ops-k8s` | Manifests, Helm |
| Command | `/ops:ops-vps`, `/ops:ops-vercel`, `/ops:ops-serverless` | Cibles de déploiement |
| Command | `/ops:ops-infra-code` | Terraform / OpenTofu (modules, state, backends) |
| Command | `/ops:ops-proxmox`, `/ops:ops-opnsense` | Homelab / infra perso |
| Command | `/ops:ops-deploy`, `/ops:ops-rollback` | Déploiement sécurisé + rollback |
| Skill auto | `ops-infra-code`, `ops-proxmox`, `ops-opnsense` | Activés sur mots-clés |
| Rule auto | `deploy-safety.md` | Dockerfile, docker-compose, .env, middleware |

### Best practices externes

- [Docker docs](https://docs.docker.com/) · [Kubernetes docs](https://kubernetes.io/docs/)
- [Terraform docs](https://developer.hashicorp.com/terraform/docs) · [The 12-Factor App](https://12factor.net/)

---

## Observability (logs, métriques, traces)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/ops:ops-monitoring` | Logs, métriques, alertes |
| Command | `/ops:ops-observability-stack` | Prometheus + Grafana + Loki |
| Command | `/ops:ops-grafana-dashboard` | Dashboards Grafana |
| Command | `/ops:ops-load-testing` | Tests de charge |
| Command | `/ops:ops-health` | Health checks |

### Best practices externes

- [3 piliers de l'observability](https://www.honeycomb.io/blog/observability-101-terminology-and-concepts)
- [OpenTelemetry](https://opentelemetry.io/) · [SRE Workbook (Google)](https://sre.google/workbook/)

---

## Testing (TDD, unit, integration, E2E)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-tdd` | Cycle Red-Green-Refactor (workflow obligatoire) |
| Command | `/dev:dev-test` | Génération de tests |
| Command | `/dev:dev-testing-setup` | Configuration de l'infra de tests |
| Command | `/qa:qa-e2e` | Tests E2E (Playwright, Cypress) |
| Command | `/qa:qa-automation`, `/qa:qa-coverage` | Auto, couverture |
| Skill auto | `qa-e2e`, `api-mocking` | Activés sur mots-clés (`E2E`, `MSW`, `mock API`) |
| Rule auto | `tdd-enforcement.md`, `testing.md` | Tout code TS/Py/Go/Dart, tests/, *.test.* |

### Best practices externes

- [Kent Beck — TDD by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- [Testing Library docs](https://testing-library.com/) · [Playwright docs](https://playwright.dev/)

---

## Backend langages (Go, Python, Rust, Ruby, Java, C#, PHP)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-debug`, `/dev:dev-refactor` | Investigation et refactoring |
| Skill auto | `dev-i18n` | Localisation (next-intl, react-i18next, vue-i18n, flutter_localizations) |
| Rules auto | `go.md`, `python.md`, `rust.md`, `ruby.md`, `java.md`, `csharp.md`, `php.md` | Activées par extension de fichier |

### Best practices externes

- [Effective Go](https://go.dev/doc/effective_go) · [PEP 8 (Python)](https://peps.python.org/pep-0008/)
- [Rust Book](https://doc.rust-lang.org/book/) · [Ruby Style Guide](https://rubystyle.guide/)

---

## Data (ETL, analytics, modeling)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/data:data-pipeline` | Pipelines ETL/ELT (Airflow, dbt) |
| Command | `/data:data-modeling` | Modélisation data warehouse (star/snowflake) |
| Command | `/data:data-analytics` | Rapports et KPIs |
| Skill auto | `data-pipeline` | Activé sur `ETL`, `Airflow`, `dbt` |

### Best practices externes

- [dbt docs](https://docs.getdbt.com/) · [Airflow docs](https://airflow.apache.org/docs/)
- [Kimball — The Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/books/)

---

## AI / LLM (RAG, prompt engineering, MCP)

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Command | `/dev:dev-ai-integration` | Intégration LLMs (OpenAI, Claude) |
| Command | `/dev:dev-prompt-engineering` | Optimisation de prompts |
| Command | `/dev:dev-rag` | Systèmes RAG (retrieval-augmented generation) |
| Command | `/dev:dev-mcp` | Création de serveurs MCP |
| Skill auto | `dev-prompt-engineering` | Activé sur `prompt`, `instruction`, `few-shot`, `LLM` |

### Best practices externes

- [Anthropic — Claude best practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [OpenAI Prompting Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [MCP spec](https://modelcontextprotocol.io/)

---

## Business & Growth

### Du socle

| Type | Élément | Activation |
|---|---|---|
| Commands BIZ | `/biz:biz-model`, `biz-market`, `biz-mvp`, `biz-pricing`, `biz-pitch`, `biz-roadmap`, `biz-launch`, `biz-competitor`, `biz-okr`, `biz-personas`, `biz-research` | Stratégie produit |
| Commands GROWTH | `/growth:growth-landing`, `growth-seo`, `growth-analytics`, `growth-ab-test`, `growth-cro`, `growth-funnel`, `growth-onboarding`, `growth-retention`, `growth-email`, `growth-localization`, `growth-app-store-analytics` | Acquisition / activation / rétention |
| Commands LEGAL | `/legal:legal-rgpd`, `legal-payment`, `legal-terms-of-service`, `legal-privacy-policy` | Conformité |
| Skill auto | `growth-cro` | Activé sur `conversion`, `signup flow`, `paywall` |

### Best practices externes

- [Lean Canvas](https://leanstack.com/lean-canvas) · [AARRR Pirate Metrics](https://www.startups.com/library/expert-advice/aarrr-pirate-metrics)
- [OWASP Privacy](https://owasp.org/www-project-top-10-privacy-risks/) · [CNIL guides RGPD](https://www.cnil.fr/fr/reglement-europeen-protection-donnees)

---

## Voir aussi

- [EXTENDING-GUIDE](https://github.com/christopherlouet/claude-socle/blob/main/docs/guides/EXTENDING-GUIDE.md) — Comment ajouter vos propres commands, skills, agents, rules
- [TEAM-GUIDE](https://github.com/christopherlouet/claude-socle/blob/main/docs/guides/TEAM-GUIDE.md) — Adoption en équipe, conventions partagées
- [PROMPTING-GUIDE](https://github.com/christopherlouet/claude-socle/blob/main/docs/guides/PROMPTING-GUIDE.md) — Techniques de prompting Claude Code
- [TROUBLESHOOTING-GUIDE](https://github.com/christopherlouet/claude-socle/blob/main/docs/guides/TROUBLESHOOTING-GUIDE.md) — Problèmes courants
- [Site Docusaurus](https://christopherlouet.github.io/claude-socle/) — Catalogue complet (commands, agents, skills, rules)
