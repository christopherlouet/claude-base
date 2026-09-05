# Recipe: recommended community vendor skills

**Audience**: developers using claude-base who want to enrich the foundation with skills published by tool vendors. NOT a complete index of every Claude Code skill in the wild — only the ones that passed claude-base's audit methodology.

**Last verified**: 2026-05-18.

This recipe lives outside the foundation deliberately. The recommended skills are NOT bundled or auto-installed by claude-base. The user opts in per project, per skill, when their stack matches. Our role is curation (which skills are worth trusting) — the vendors handle their own distribution.

---

## Why this recipe exists

<!-- count:marketplaceAuditPilots -->5<!-- /count --> audit pilots identified a small set of vendor-published skills that complement the claude-base foundation:

- `cli-tools` plugin pilot (`specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`)
- `dev-*` skills pilot (`specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`)
- `qa-*` skills pilot (`specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`)
- `ops-*` skills pilot (`specs/marketplace-audit/ops-skills-pilot-2026-05-06.md`)
- `growth-*` skills pilot (`specs/marketplace-audit/growth-skills-pilot-2026-05-21.md`)

Combined findings:

- Our skills capture **opinionated workflow patterns** (TDD, security defaults, anti-patterns, foundation conventions). These are stack-agnostic.
- Vendor skills capture **canonical API/stack patterns** that evolve with each release. These are stack-specific and vendor-authoritative.
- Combining both = the best of both worlds for a project on that specific stack.

This recipe is the actionable companion to the audit pilots: it tells you **how** to install each recommended vendor skill once you've decided you want it.

---

## Verification methodology

Each vendor below was evaluated against the audit methodology in `specs/marketplace-audit/spec.md`. Specifically:

1. **Trust** — public, two-track signals (no "build N production repos" requirement): a skill published by the tool vendor's own organisation clears on **authority** (institutional signal, no popularity floor); a third-party/community skill clears on a **community-trust bar** (popularity, forks, recency, maintenance activity, not-archived, license — install/download counts where a channel exposes them). This is what the curation engine's deterministic scorer (`scripts/lib/trust-score.sh`) checks.
2. **Maintenance**: active commits in a recency window, open issue triage, no chronic infrastructure bugs.
3. **Safety/integrity screen** (distinct from trust — popularity ≠ safety): the skill's own content is screened for obviously-dangerous instructions, and every recommendation is **pinned to a fixed reference**, never `@latest` (`scripts/lib/curation-safety.sh`).
4. **Advice-neutrality + provenance** (this *replaces* the former publisher-veto): we judge whether a skill's **advice** pushes the user toward proprietary lock-in or away from their chosen stack / Claude — applied **uniformly to every vendor**, not just to competitors. **Publisher identity is NOT an exclusion criterion**; an excellent skill is not rejected because of who acquired its author. Instead the **publisher is disclosed as provenance** on every entry so you decide with full information, and a skill that advocates a competing primary stack is **scoped by a usage condition** rather than blanket-banned. (We are an independent curator with no duty to enforce Anthropic's competitive lines — the `vendor-neutrality-not-publisher-veto` principle supersedes the earlier `feedback_plugin_curation_vendor_neutrality` veto.)
5. **Existence/signals verified** via `gh api repos/<owner>/<repo>` (stars, last commit timestamp, archived flag).

If a vendor's **advice** later turns lock-in-pushing, or its content fails the safety screen, or it goes stale/archived, the corresponding entry is reviewed. A change of *owner* alone is recorded as provenance, not an automatic disqualification.

---

## By stack (quick lookup)

After running `claude-base init`, install the vendor skills that match your detected stack. The matrix below is **auto-generated** from each preset's `recommendedVendorSkills[]` field via `website/scripts/generate-recipe-matrix.ts` — do not edit by hand; edit the preset JSONs and re-run `npm --prefix website run generate`. *Always pair* entries are unconditional recommendations for the stack; *Conditional* entries apply only if the named tool is in use.

<!-- recipe-matrix:start -->
| Preset | Always pair | Conditional |
|---|---|---|
| `apollo` (Apollo GraphQL Client (vendor-pointer)) | `apollographql/skills` | — |
| `astro` (Astro content/static-first) | `frontend-design@claude-plugins-official` | `vercel-labs/agent-skills` (if using React islands), `shadcn-ui/ui (skills/shadcn)` (if using shadcn/ui) |
| `cli-tools` (CLI tools / automation scripts) | — | — |
| `fastapi` (FastAPI backend (Python async)) | — | `supabase/agent-skills` (if using Postgres or Supabase), `mongodb/agent-skills` (if using MongoDB), `grafana/skills` (if using Grafana / observability stack), `antonbabenko/terraform-skill` (if deploying via Terraform/OpenTofu) |
| `homelab-proxmox` (Proxmox VE homelab) | `antonbabenko/terraform-skill` | `pulumi/agent-skills` (if using Pulumi instead of Terraform), `grafana/skills` (if using Grafana / Prometheus stack), `homeassistant-ai/skills (skills/home-assistant-best-practices)` (if the project holds a Home Assistant configuration) |
| `mongodb` (MongoDB (vendor-pointer)) | `mongodb/agent-skills` | — |
| `nextjs` (Next.js full-stack) | `vercel-labs/agent-skills`, `frontend-design@claude-plugins-official` | `supabase/agent-skills` (if using Supabase), `prisma/skills` (if using Prisma), `shadcn-ui/ui (skills/shadcn)` (if using shadcn/ui), `apollographql/skills` (if using Apollo GraphQL) |
| `phaser` (Phaser (vendor-pointer)) | `phaserjs/phaser/skills` | — |
| `playwright` (Playwright (vendor-pointer)) | `microsoft/playwright-cli` | — |
| `pulumi` (Pulumi (vendor-pointer)) | `pulumi/agent-skills` | — |
| `react-vite-spa` (React Vite SPA) | `vercel-labs/agent-skills`, `frontend-design@claude-plugins-official` | `shadcn-ui/ui (skills/shadcn)` (if using shadcn/ui), `lingui/skills` (if using Lingui for i18n) |
<!-- recipe-matrix:end -->

**Cross-stack growth/marketing skills** (install if shipping a product, not a pure side-project):

- `coreyhaines31/marketingskills` — broad marketing toolkit (CRO, copywriting, lifecycle, ASO)
- `PostHog/skills` — product analytics + feature flags + session replay
- `resend/resend-skills` — transactional email (D0/D1/D3/D7 lifecycle)
- `AgriciDaniel/claude-seo` — SEO audit + content strategy

All entries below link to detailed install instructions and rationale.

---

## Install-time tips (CLI 2.1.141+)

Two recent CLI behaviors worth knowing when running `claude plugin install` against the recommendations below:

- **HTTPS clone for GitHub plugin sources**: set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` in your environment to clone plugin repositories over HTTPS instead of SSH. Useful in CI runners or sandboxed environments where SSH keys are not provisioned.
- **Dependency enforcement**: `claude plugin enable` force-enables transitive dependencies, and `claude plugin disable` now refuses when another enabled plugin depends on the target. No more silent breakage from disabling a dependency.

---

## Recommended vendor skills (by domain)

### Supabase — `supabase/agent-skills`

**Covers**: Supabase Auth, Database, Edge Functions, Realtime, Storage. Includes a separate `supabase-postgres-best-practices` skill (30 rules across 8 categories).

**When to install**: any project using Supabase as a backend.

**Pair with**: claude-base's `dev-supabase` skill (workflow / TDD / security patterns).

**Install** (vendor's preferred path; verify on their README):
```bash
# The repo includes a .claude-plugin/ structure — likely installable via:
claude plugin install supabase@supabase  # if the vendor publishes via marketplace

# Fallback: git clone + symlink the skill directories
git clone --depth 1 https://github.com/supabase/agent-skills ~/dev/vendor-skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase ./.claude/skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase-postgres-best-practices \
      ./.claude/skills/supabase-postgres-best-practices
```

**Provenance & advice-neutrality**: Supabase is independent (Series C funding), MIT-licensed, not acquired by OpenAI / Microsoft / Anthropic competitors as of 2026-05-05.

---

### Prisma — `prisma/skills`

**Covers**: Prisma ORM patterns, especially v7 (ESM-only, driver adapters, `prisma.config.ts`).

**When to install**: any project using Prisma, especially if migrating to v7.

**Pair with**: claude-base's `dev-prisma` skill (schema design, migration discipline, anti-patterns).

**Install** (verify on their README):
```bash
# Prisma's blog post mentioned: npx skills add prisma/skills
# (verify this command in their current README before relying on it)

# Fallback: git clone
git clone --depth 1 https://github.com/prisma/skills ~/dev/vendor-skills/prisma
# Skill content lives in CLAUDE.md / AGENTS.md — copy or symlink as needed
```

**Provenance & advice-neutrality**: Prisma is independent, not acquired.

---

### Apollo GraphQL — `apollographql/skills`

**Covers**: Apollo Client, Apollo Server 5, Apollo Connectors, Federation 2, Apollo Kotlin. Apollo-specific.

**When to install**: any project using the Apollo stack. **Do NOT install for non-Apollo GraphQL stacks** (Yoga, Pothos, Mercurius, Strawberry, gqlgen) — claude-base's `dev-graphql` covers those.

**Pair with**: claude-base's `dev-graphql` skill (schema design, DataLoader, N+1 prevention, security).

**Install** (verify on their README):
```bash
git clone --depth 1 https://github.com/apollographql/skills ~/dev/vendor-skills/apollographql
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: Apollo GraphQL Inc. is independent.

---

### Anthropic — `mcp-builder` (dev-mcp graduation)

**Covers**: building MCP (Model Context Protocol) servers — workflows-not-endpoints design, tool annotations, input validation, actionable errors, evaluation, for Python (FastMCP) and the Node/TS SDK.

**When to install**: any project building MCP servers. The foundation's `dev-mcp` command is now a **pointer** to this skill (the protocol authors' own).

**Pair with**: nothing extra — this is the canonical depth.

**Install** (verify on their README):
```bash
npx skills add anthropics/skills
# Fallback: git clone --depth 1 https://github.com/anthropics/skills ~/dev/vendor-skills/anthropic
# then symlink skills/mcp-builder into ./.claude/skills/
```

**Provenance & advice-neutrality**: Anthropic (the protocol authors); runtime-neutral (Python + TS), Apache-2.0 (per-skill).

---

### Anthropic — `claude-api` (dev-ai-integration companion)

**Covers**: Claude API integration depth — single call vs tool-use loop vs managed agents, streaming, prompt caching, token counting, model migration, across 8 languages.

**When to install**: **already bundled in Claude Code** — no install needed; invoke the `claude-api` skill directly. The foundation's `dev-ai-integration` stays the **neutral multi-provider chooser** (Anthropic/OpenAI/Google/Mistral/Cohere) and points here for Claude-specific depth.

**Pair with**: claude-base's `dev-ai-integration` (provider selection, rate-limit/retry, cost monitoring — provider-neutral).

**Provenance & advice-neutrality**: Anthropic; Claude-specific by nature (use the neutral chooser to decide *whether* Claude fits first).

---

### LangChain — `langchain-rag` (dev-rag companion)

**Covers**: the RAG pipeline within LangChain/LangGraph — loaders, embeddings, vector stores, retrieval.

**When to install**: projects on **LangChain/LangGraph**. The foundation's `dev-rag` stays the **framework-neutral** RAG layer (chunking, embedding choice, vector-store selection, faithfulness metrics) and points here for LangChain depth. **Do NOT** treat it as framework-agnostic RAG (it is LangChain-scoped).

**Pair with**: claude-base's `dev-rag` (framework-neutral pipeline + evaluation).

**Install** (verify on their README):
```bash
git clone --depth 1 https://github.com/langchain-ai/langchain-skills ~/dev/vendor-skills/langchain
# Symlink the langchain-rag skill into ./.claude/skills/
```

**Provenance & advice-neutrality**: LangChain (open-source, provider-agnostic framework); no root LICENSE file at pin time — track.

---

### Vercel — `vercel-labs/agent-skills`

**Covers**: `react-best-practices` (40+ rules across 8 categories from Vercel Engineering), React Composition Patterns, React View Transitions, `deploy-to-vercel`, `vercel-optimize`, Web Design Guidelines. **React + Vercel-deploy focused — no dedicated Next.js skill** (App Router / RSC / caching stay claude-base's `dev-nextjs`).

**When to install**: any project using Next.js or modern React on Vercel — for the React layer and Vercel deploy/optimize.

**Pair with**: claude-base's `dev-nextjs` (the primary App Router / Server Components / caching reference) and `dev-react-perf` skills (workflow patterns, deploy-safety, anti-patterns).

**Install** (verify on their README):
```bash
git clone --depth 1 https://github.com/vercel-labs/agent-skills ~/dev/vendor-skills/vercel
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: Vercel is independent. Note: Vercel's `v0` product is an AI-coding tool that competes adjacently with Claude Code; Vercel itself is not acquired by OpenAI / Anthropic competitors. Re-evaluate if this changes.

---

### shadcn/ui — canonical skill in main repo

**Covers**: shadcn/ui CLI v4, Radix + Base UI primitives, registry workflows, theming patterns. The skill ships **inside the canonical library repo** (`shadcn-ui/ui/skills/shadcn/SKILL.md`), so it's always in sync with the library itself.

**When to install**: any project using shadcn/ui.

**Pair with**: claude-base's `dev-shadcn` skill (integration patterns, accessibility audit triggers, anti-patterns).

**Install** (verify on their docs at <https://ui.shadcn.com/docs/skills>):
```bash
# shadcn ships its own CLI; the skill is exposed via the same CLI:
npx shadcn skill add shadcn   # syntax to verify on their docs

# Fallback: copy from the canonical repo
git clone --depth 1 https://github.com/shadcn-ui/ui ~/dev/vendor-skills/shadcn-ui
ln -s ~/dev/vendor-skills/shadcn-ui/skills/shadcn ./.claude/skills/shadcn
```

**Provenance & advice-neutrality**: shadcn/ui is open-source under MIT, individual maintainer (no vendor capture risk).

---

### Anthropic — `frontend-design` plugin (official marketplace)

**Covers**: bold design choices, typography, animations, avoiding generic aesthetic ("Inter font + purple gradient"). Distributed via the official Claude Code marketplace.

**When to install**: any frontend project that wants distinctive UI rather than generic defaults. This plugin already had 277K+ installs as of March 2026.

**Pair with**: claude-base's `dev-frontend-design` skill (art-direction taxonomy `terminal/cockpit/vitality/editorial/glass/signal` + project's `Style:` declaration).

**Install**:
```bash
claude plugin install frontend-design@claude-plugins-official
```

Then enable it in your project's `.claude/settings.json`:
```json
{ "enabledPlugins": { "frontend-design@claude-plugins-official": true } }
```

Or use the claude-base helper (idempotent):
```bash
claude-base update --add-plugin frontend-design@claude-plugins-official ./your-project
```

**Provenance & advice-neutrality**: Anthropic is, by definition, the home ecosystem.

---

### Anthropic — `code-review` plugin (qa-review companion)

**Covers**: Multi-agent code-review plugin with 4 parallel sub-agents and confidence scoring (default 80%).

**When to install**: any project where multi-agent parallel review is the preferred workflow.

**Pair with**: claude-base's `qa-review` skill (manual review checklist + workflow conventions).

**Install**:
```bash
claude plugin install code-review@claude-plugins-official
claude-base update --add-plugin code-review@claude-plugins-official ./your-project
```

**Provenance & advice-neutrality**: Anthropic. Zero concern.

---

### Phaser — `phaserjs/phaser/skills/`

**Covers**: 28 SKILL.md files shipped inside the vendor's main repo, covering scene lifecycle, sprites, physics (Arcade and Matter.js), tilemaps, animations, input handling, particles, cameras, audio, asset pipelines, plus a dedicated `v3-to-v4-migration` skill aligned with Phaser 4 (released April 2026). The skills are updated alongside each release of the framework itself.

**When to install**: any 2D web or mobile-web game project built on Phaser (v3 or v4). For a renderer-only stack (no scene graph, no physics) PixiJS is a better fit and is named under "Adjacent options" below.

**Pair with**: no bundled foundation skill on this topic yet — game-dev is an acknowledged gap. See `specs/presets/roadmap.md` §"Game / Interactive media" for the contribution path.

**Install** (verify on the vendor's README at <https://github.com/phaserjs/phaser>):
```bash
git clone --depth 1 https://github.com/phaserjs/phaser ~/dev/vendor-skills/phaser
# Symlink the relevant skill subdirectories into ./.claude/skills/
ln -s ~/dev/vendor-skills/phaser/skills/game-setup-and-config \
      ./.claude/skills/phaser-game-setup-and-config
# Repeat for the other skills you need (28 in total).
```

**Provenance & advice-neutrality**: Phaser Studio Inc. (organization), independent, MIT-licensed. Verified via `gh api repos/phaserjs/phaser` on 2026-05-18 — 39,638★, last commit 2026-04-30, archived: false, fork: false. The skill's advice is stack-neutral (it teaches Phaser, not lock-in). Note: an OpenAI-published `openai/plugins/game-studio/skills/phaser-2d-game` also exists; under the advice-neutrality policy it is **not excluded on publisher identity** — we point at `phaserjs/phaser` here because the engine vendor's own skill wins on **authority and fit**, not because the OpenAI one is banned (its provenance would simply be disclosed if preferred).

**Adjacent options (not separately evaluated)**: PixiJS (renderer, see `arimxyer/toolchest`), Kaplay (simpler component-based framework), Excalibur (TypeScript-first scene + physics). These are named so readers on those stacks know the foundation is aware of them; full audit deferred to a future marketplace-audit pilot.

---

### Addy Osmani — `web-quality-skills` (qa-perf companion)

**Covers**: Core Web Vitals (LCP, INP, CLS), perf, accessibility, SEO. Maintained by Addy Osmani (14 years Chrome DevTools / Lighthouse engineering lead at Google).

**When to install**: any project targeting Web Vitals optimisation.

**Pair with**: claude-base's `qa-perf` skill (measurement workflow).

**Install** (verify on the repo's README):
```bash
git clone --depth 1 https://github.com/addyosmani/web-quality-skills ~/dev/vendor-skills/web-quality
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: Personal repo, not Google-org-owned. Author has Google affiliation but the project is independent. Acceptable.

---

### Google Chrome DevTools — `chrome-devtools-mcp` (qa-chrome companion)

**Covers**: Programmatic access to Chrome DevTools (network inspection, profiling, accessibility tree) as MCP tools that Claude Code can invoke directly during a session.

**Format note**: This is an **MCP server**, NOT a SKILL.md skill. Configuration mechanism is different.

**When to install**: any project where Claude Code needs direct programmatic access to Chrome DevTools.

**Pair with**: claude-base's `qa-chrome` skill (manual review checklist).

**Install** (verify on their repo's README):
```bash
# Configure in your project's .mcp.json:
# {
#   "mcpServers": {
#     "chrome-devtools": {
#       "command": "npx",
#       "args": ["@chrome-devtools/mcp-server"]
#     }
#   }
# }
```

**Provenance & advice-neutrality**: Google. Web-tooling neutral.

---

### Microsoft — `playwright-cli` skill (qa-e2e companion, case-by-case)

**Covers**: Authoritative Playwright API patterns from the Microsoft Playwright team. Updated alongside each Playwright release.

**When to install**: any Playwright-based project.

**Pair with**: claude-base's `qa-e2e` skill (workflow patterns, anti-fragility rules).

**Install** (verify on their repo):
```bash
git clone --depth 1 https://github.com/microsoft/playwright-cli ~/dev/vendor-skills/playwright
ln -s ~/dev/vendor-skills/playwright/skills/playwright-cli ./.claude/skills/playwright-cli
```

**Provenance & advice-neutrality**:

Provenance: Microsoft owns Playwright. Under the advice-neutrality policy this is **disclosed, not disqualifying** — what matters is that the skill's advice is stack-neutral: Playwright (created 2020, MIT-licensed) is the de-facto E2E standard (78,000★ on the core repo) and teaches a portable testing tool, not lock-in. The community alternative `lackeyjb/playwright-skill` exists but was 5 months stale at audit time.

**Decision (2026-05-06)**: pointer to `microsoft/playwright-cli` accepted for the qa-e2e skill. Re-evaluate only if its **advice** turns lock-in-pushing or it fails the safety/maintenance bar — a change in Microsoft's commercial alignment alone is recorded as provenance, not a trigger.

---

### agamm — `claude-code-owasp` (qa-security companion)

**Covers**: OWASP Top 10:2025, ASVS 5.0, 20 language-specific quirks. Independent author.

**When to install**: any security audit context.

**Pair with**: claude-base's `qa-security` skill (manual review workflow).

**Install** (verify on their repo):
```bash
git clone --depth 1 https://github.com/agamm/claude-code-owasp ~/dev/vendor-skills/owasp
# Skill content lives under .claude/ — copy or symlink as appropriate
```

**Adoption signal**: 171★ at audit time — modest. The value is in pointing to a faithful implementation of the canonical OWASP standard, not in popularity.

**Provenance & advice-neutrality**: Independent author.

---

### MongoDB — `mongodb/agent-skills` (ops-database companion)

**Covers**: MongoDB schema design heuristics, indexing strategies, query patterns, operational safeguards.

**When to install**: any project using MongoDB.

**Pair with**: claude-base's `ops-database` skill (stack-neutral conventions: naming, soft-delete, updated_at triggers).

**Install** (verify on their repo):
```bash
git clone --depth 1 https://github.com/mongodb/agent-skills ~/dev/vendor-skills/mongodb
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: MongoDB Inc. is independent.

---

### Anton Babenko — `terraform-skill` (ops-infra-code companion, Terraform/OpenTofu)

**Covers**: comprehensive Terraform/OpenTofu patterns — CI/CD workflows, code patterns, testing frameworks, security compliance, quick reference. The de-facto community Terraform skill.

**When to install**: any project using Terraform or OpenTofu.

**Pair with**: claude-base's `ops-infra-code` skill (foundation-workflow integration: module hierarchy, naming conventions, link to `ops-deploy`).

**Install** (verify on the repo):
```bash
git clone --depth 1 https://github.com/antonbabenko/terraform-skill ~/dev/vendor-skills/terraform
ln -s ~/dev/vendor-skills/terraform/skills/terraform ./.claude/skills/terraform
```

**Provenance & advice-neutrality**: community-authored (Anton Babenko, independent maintainer). HashiCorp acquired by IBM (Feb 2025) but the skill author is independent. IBM has Watson but is not a direct Anthropic/OpenAI competitor. Acceptable.

---

### Pulumi — `pulumi/agent-skills` (ops-infra-code companion, Pulumi)

**Covers**: Pulumi authoring patterns + migration workflows (Terraform→Pulumi, CloudFormation→Pulumi).

**When to install**: any project using Pulumi (or migrating from Terraform/CloudFormation to Pulumi).

**Pair with**: claude-base's `ops-infra-code` skill.

**Install** (verify on their repo and docs at <https://www.pulumi.com/docs/ai/skills/>):
```bash
git clone --depth 1 https://github.com/pulumi/agent-skills ~/dev/vendor-skills/pulumi
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: Pulumi is independent.

---

### Grafana Labs — `grafana/skills` (ops-monitoring companion)

**Covers**: Grafana Core, Grafana Cloud, the LGTM stack (Loki, Grafana, Tempo, Mimir), k6 performance testing, Grafana app SDK. Companion repo `grafana/pyroscope-skills` covers continuous profiling.

**When to install**: any project using the Grafana / LGTM observability stack.

**Pair with**: claude-base's `ops-monitoring` skill (three-pillar overview, foundation OTEL skeleton).

**Install** (verify on the repo):
```bash
git clone --depth 1 https://github.com/grafana/skills ~/dev/vendor-skills/grafana
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Provenance & advice-neutrality**: Grafana Labs is independent.

---

### Semgrep — `semgrep` plugin (qa-security companion, automated scanner)

**Covers**: Static analysis engine integrated into Claude Code via the official Semgrep plugin.

**When to install**: any project where automated security scanning is wanted alongside manual review.

**Pair with**: claude-base's `qa-security` skill + the OWASP skill above.

**Install**:
```bash
claude plugin install semgrep@claude-plugins-official  # or via claude.com/plugins/semgrep
claude-base update --add-plugin semgrep@claude-plugins-official ./your-project
```

**Provenance & advice-neutrality**: Semgrep is an independent security company.

---

### PostHog — `PostHog/skills` (growth-analytics companion)

**Covers**: Product analytics instrumentation across 50+ frameworks (Next.js, Nuxt, SvelteKit, Astro, Django, Flask, FastAPI, Rails, Laravel, Android, iOS, React Native, Expo, Flutter…), feature flags, error tracking, LLM analytics, session replay, cohorts, funnels. The flagship skill `instrument-product-analytics` walks the agent through platform detection, SDK install, framework-specific initialization, 10-15 file event planning, server-side event coverage, user identification (with `X-POSTHOG-DISTINCT-ID` header pattern), and env-var management via the PostHog MCP server.

**When to install**: any project using PostHog as analytics backend.

**Pair with**: claude-base's `growth-analytics` command (North Star + AARRR taxonomy + GDPR consent layer). The vendor covers PostHog-specific instrumentation; the foundation covers the strategic event-design layer.

**Install**:
```bash
git clone --depth 1 https://github.com/PostHog/skills ~/dev/vendor-skills/posthog
ln -s ~/dev/vendor-skills/posthog/skills/omnibus/instrument-product-analytics \
      ./.claude/skills/instrument-product-analytics
# Other PostHog sub-skills available under skills/posthog/{product-analytics,feature-flags,error-tracking,logs,llm-analytics,migrations,integration}
```

**Provenance & advice-neutrality**: PostHog is independent, MIT-licensed, not acquired by an Anthropic competitor as of 2026-05-21.

---

### Resend — `resend/resend-skills` (growth-email companion)

**Covers**: Transactional and marketing email infrastructure. `email-best-practices` covers deliverability, double opt-in, suppression lists, idempotent sending, webhook handling, list management. Companion skills: `resend` (SDK usage), `resend-cli`, `react-email` (template patterns), `agent-email-inbox` (inbound).

**When to install**: any project sending transactional or marketing email via Resend.

**Pair with**: claude-base's `growth-email` command (D0/D1/D3/D7 onboarding sequence design, re-engagement, upgrade emails). The vendor covers the deliverability infrastructure; the foundation covers the lifecycle sequence design.

**Install**:
```bash
git clone --depth 1 https://github.com/resend/resend-skills ~/dev/vendor-skills/resend
ln -s ~/dev/vendor-skills/resend/skills/resend ./.claude/skills/resend
ln -s ~/dev/vendor-skills/resend/skills/email-best-practices ./.claude/skills/email-best-practices
ln -s ~/dev/vendor-skills/resend/skills/react-email ./.claude/skills/react-email
```

**Provenance & advice-neutrality**: Resend is independent (Series A 2024), MIT-licensed, not acquired by an Anthropic competitor as of 2026-05-21.

---

### AgriciDaniel — `claude-seo` (growth-seo companion, community-with-mass-adoption)

**Covers**: Universal SEO toolkit with 28 SKILL.md files. Auto-detects business type (Local Service / E-commerce / SaaS) and triggers specialized workflows. Crawls up to 500 pages with 7-weighted scoring (Technical 22%, Content 23%, On-Page 20%, Schema 10%, Performance 10%, AI-search Readiness 10%, Images 5%) producing a 0-100 SEO Health Score. Sub-skills: `seo-audit`, `seo-technical`, `seo-content`, `seo-schema`, `seo-sitemap`, `seo-local`, `seo-maps`, `seo-google`, `seo-backlinks`, `seo-cluster`, `seo-drift`, `seo-ecommerce`, `seo-geo`, `seo-hreflang`, `seo-images`, `seo-content-brief`, `seo-page`, `seo-programmatic`, `seo-competitor-pages`, `seo-plan`, `seo-flow`, `seo-sxo`, `seo-image-gen`. Integrations: DataForSEO, Firecrawl, Google APIs, Common Crawl. Outputs FULL-AUDIT-REPORT.md + ACTION-PLAN.md + PDF.

**When to install**: any project where SEO matters (most public-facing web projects).

**Pair with**: claude-base's `growth-seo` command — scheduled to be reduced to a thin pointer per [`specs/foundation-positioning-review/spec.md`](../../specs/foundation-positioning-review/spec.md) Wave 1, since the vendor is materially deeper across every axis our foundation command covered.

**Install**:
```bash
git clone --depth 1 https://github.com/AgriciDaniel/claude-seo ~/dev/vendor-skills/claude-seo
# The repo ships install.sh / install.ps1 for plugin-style installation
~/dev/vendor-skills/claude-seo/install.sh ./your-project
```

**Provenance & advice-neutrality**: Community-authored (single maintainer, AgriciDaniel), MIT-licensed. Mass adoption (6,800+★ as of 2026-05-21) clears the community-trust bar by orders of magnitude. Advice is stack-neutral (SEO guidance, no lock-in).

---

### Corey Haines — `coreyhaines31/marketingskills` (broad marketing toolkit, community-with-mass-adoption)

**Covers**: 30 marketing sub-skills covering most of the growth/marketing surface: `ab-testing`, `ad-creative`, `ads`, `ai-seo`, `analytics`, `aso`, `churn-prevention`, `co-marketing`, `cold-email`, `community-marketing`, `competitor-profiling`, `competitors`, `content-strategy`, `copy-editing`, `copywriting`, `cro`, `customer-research`, `directory-submissions`, `emails`, `free-tools`, `image`, `launch`, `lead-magnets`, `marketing-ideas`, `marketing-psychology`, `onboarding`, `paywalls`, `popups`, `pricing`, `product-marketing`. Skills include concrete frameworks (Van Westendorp + Good-Better-Best for pricing, page-type frameworks for CRO, etc.) and cross-skill references between the sub-skills.

**When to install**: any project doing growth/marketing work. Note: single-maintainer dependency (Corey Haines) — verify update cadence before relying in production.

**Pair with**: claude-base's `growth-*` commands and `growth-cro` skill. Many of those foundation resources will be reduced to thin pointers per [`specs/foundation-positioning-review/spec.md`](../../specs/foundation-positioning-review/spec.md) — this toolkit becomes the deep-execution layer, the foundation keeps cross-cutting wraps (GDPR, anti-patterns, workflow integration, unique angles like paywall strategies in `growth-cro` or pipeline-side analytics in `growth-app-store-analytics`).

**Install**:
```bash
git clone --depth 1 https://github.com/coreyhaines31/marketingskills ~/dev/vendor-skills/marketingskills
# Symlink only the sub-skills you need; the toolkit is broad
ln -s ~/dev/vendor-skills/marketingskills/skills/cro ./.claude/skills/cro
ln -s ~/dev/vendor-skills/marketingskills/skills/pricing ./.claude/skills/pricing
ln -s ~/dev/vendor-skills/marketingskills/skills/onboarding ./.claude/skills/onboarding
# ... pick what your project needs
```

**Provenance & advice-neutrality**: Single-maintainer community project (Corey Haines). 29,800+★ as of 2026-05-21 confirms strong adoption signal. Single-maintainer dependency — assess maintenance cadence before adoption in critical projects.

---

## Stack-specific (install only if your stack matches)

### Lingui — `lingui/skills`

**Covers**: Lingui-specific i18n patterns (announced alongside Lingui 6.0, April 2026).

**Install only if**: your project uses Lingui specifically. For other i18n libraries (next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations), claude-base's framework-agnostic `dev-i18n` skill is sufficient.

**Provenance & advice-neutrality**: Lingui is community-maintained.

---

### Callstack — `callstackincubator/agent-skills` (`react-native-best-practices`)

**Covers**: React Native optimisation patterns from Callstack (a long-standing React Native consultancy).

**Install only if**: your project is React Native. Out of scope for web React.

**Provenance & advice-neutrality**: Callstack is independent.

---

## Vendors evaluated and NOT recommended

This list is part of the curation work. Naming what we rejected matters as much as naming what we approve.

### Astral — `astral@astral-sh` (uv / ruff / ty)

**Not bundled by default — but no longer vetoed on identity.** Under the advice-neutrality policy (above), the tooling itself is advice-neutral: `uv`/`ruff`/`ty` are MIT-licensed CLI dev tools that don't push the user toward proprietary lock-in or away from Claude. We do **not** exclude it on identity. Provenance: Astral was acquired by OpenAI on 2026-03-19 — disclosed so you decide with full information, not a disqualifier.

It stays out of the default preset bundle for a *different* reason: a Python toolchain is a **project opinion, not a stack essential** (some teams are Astral-pragmatic, others conservative-PyPA). See `docs/recipes/python-toolchain-options.md`, which documents Astral as a first-class opt-in path alongside the alternatives, with provenance disclosed.

### `greptile@claude-plugins-official`

**Rejected on technical grounds**: recurrent OAuth registration bugs in successive months (Jan 2026, April 2026). Auth layer not stable. Re-evaluate if Greptile resolves these issues.

### `pyright-lsp@claude-plugins-official`

**Rejected on technical grounds**: multiple open infrastructure bugs as of early 2026 (race condition between LSP manager initialization and plugin loading, `lspServers` config not propagated). Re-evaluate when these are resolved.

### `commit-commands@claude-plugins-official`

**Rejected on overlap grounds**: redundant with claude-base's `/work:work-commit` and `/work:work-pr` commands. Adds noise, not value.

---

## Skill discovery — marketplaces & aggregators

Beyond the curated list above, several public indexes catalogue Claude Code skills, plugins, and agents at much larger scale. Use them when you need broader coverage than this recipe (e.g., niche stacks we haven't audited), or to monitor what the ecosystem ships outside vendor-authored skills.

We do **not** vouch for entries discovered through these indexes — only for the entries listed earlier in this recipe. Treat them as discovery surfaces, not curation surfaces.

| Source | Type | Scope | Note |
|---|---|---|---|
| [`claude.com/plugins`](https://claude.com/plugins) | Anthropic-official | Browsable plugin catalog with install counts and "Anthropic Verified" badges | The canonical first-party directory. Start here. |
| [`anthropics/claude-plugins-official`](https://github.com/anthropics/claude-plugins-official) | Anthropic-official | Marketplace repo auto-loaded by Claude Code; contains `/plugins` (internal) and `/external_plugins` (partner) | Read manifests directly when `claude.com/plugins` doesn't surface enough detail. |
| [`anthropics/claude-plugins-community`](https://github.com/anthropics/claude-plugins-community) | Anthropic-official (tier-2) | Nightly-synced mirror of community submissions that passed Anthropic's automated security review | PRs auto-closed; submit via `clau.de/plugin-directory-submission`. |
| [`agentskills.io`](https://agentskills.io) | Open standard | Spec for the `SKILL.md` format (originally Anthropic, now also adopted by Codex, Cursor, Copilot, Gemini CLI, VS Code) | Confirms portability — skills authored against this spec run across multiple LLM agents, not only Claude Code. |
| [`hesreallyhim/awesome-claude-code`](https://github.com/hesreallyhim/awesome-claude-code) | Community awesome-list | Broad index: skills, hooks, slash-commands, agent orchestrators, apps, plugins | Largest general-purpose community list. Verify ToC state — index was under renovation as of 2026-05. |
| [`ComposioHQ/awesome-claude-skills`](https://github.com/ComposioHQ/awesome-claude-skills) | Community awesome-list (vendor-maintained) | 1000+ skills across docs, dev, data, business, security | Maintained by Composio (SaaS-integration vendor); breadth is real but expect Composio's own integrations to be over-represented. |
| [`claudemarketplaces.com`](https://claudemarketplaces.com) | Third-party index | Plugins, skills, MCP servers ranked by installs + stars + community votes | Independent operator, transparent ranking signals. |
| [`skillsmp.com`](https://skillsmp.com) | Third-party index, cross-LLM | Aggregates `SKILL.md` content for Claude Code, Codex CLI, and ChatGPT | Useful if you're using more than one agent. Expect noise at that volume. |

URLs verified live (HTTP 200) on 2026-05-21.

**Excluded from this list** (same quality / provenance rationale as the rest of the recipe):

- "SkillKit" / `agenstskills.com` — unclear provenance, domain name appears to typo-squat `agentskills.io`.
- Duplicate awesome-lists (`travisvn/awesome-claude-skills`, `BehiSecc/awesome-claude-skills`, `GetBindu/awesome-claude-code-and-skills`, `jqueryscript/awesome-claude-code`) — content overlaps `hesreallyhim` and `ComposioHQ` without adding signal.

---

## When this list will change

This recipe is a living document. Triggers for re-evaluation:

| Trigger | Action |
|---------|--------|
| A vendor's **advice** turns lock-in-pushing or steers away from the user's stack/Claude | Re-scope with a usage condition, or move to "Not recommended" with explanation |
| A vendor is acquired by OpenAI / Microsoft / a Claude Code competitor | **Update the disclosed provenance** — not, by itself, a move to "Not recommended" (advice-neutrality, not publisher identity, decides) |
| A vendor's install method changes (especially: migration from git-clone to marketplace) | Update the install commands |
| A vendor's repo is archived or marked deprecated | Move to "Not recommended" with explanation |
| New vendor publishes a skill that passes the methodology bar | Add to recommended list |
| Quarterly review (every 3 months) | Verify all install commands still work |

The pilot traces (`specs/marketplace-audit/*-pilot-*.md`) capture the original analysis; this recipe is the user-facing summary.

---

## What this recipe is NOT

- A complete index of Claude Code skills. Many community skills exist that we did not evaluate (yet) — absence here means "not yet validated", not "rejected".
- A prescription that every claude-base user must install all of these. Each install is opt-in based on the actual stack of the project.
- A guarantee that the install commands above will work next month. The Claude Code skill ecosystem is young (May 2026); install methods will evolve. Verify the vendor's README before relying on a command.
- A statement that vendor skills are universally better than claude-base's. The recommendation is **install both** for the relevant stack — they cover different angles.
