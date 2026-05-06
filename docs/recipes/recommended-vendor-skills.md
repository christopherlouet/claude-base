# Recipe: recommended community vendor skills

**Audience**: developers using claude-base who want to enrich the foundation with skills published by tool vendors. NOT a complete index of every Claude Code skill in the wild — only the ones that passed claude-base's audit methodology.

**Last verified**: 2026-05-06.

This recipe lives outside the foundation deliberately. The recommended skills are NOT bundled or auto-installed by claude-base. The user opts in per project, per skill, when their stack matches. Our role is curation (which skills are worth trusting) — the vendors handle their own distribution.

---

## Why this recipe exists

Three audit pilots identified a small set of vendor-published skills that complement the claude-base foundation:

- `cli-tools` plugin pilot (`specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`)
- `dev-*` skills pilot (`specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`)
- `qa-*` skills pilot (`specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`)

Combined findings:

- Our skills capture **opinionated workflow patterns** (TDD, security defaults, anti-patterns, foundation conventions). These are stack-agnostic.
- Vendor skills capture **canonical API/stack patterns** that evolve with each release. These are stack-specific and vendor-authoritative.
- Combining both = the best of both worlds for a project on that specific stack.

This recipe is the actionable companion to the audit pilots: it tells you **how** to install each recommended vendor skill once you've decided you want it.

---

## Verification methodology

Each vendor below was evaluated against the audit methodology in `specs/marketplace-audit/spec.md`. Specifically:

1. **Authorship**: published by the tool vendor itself (high signal) or by a community member with verified adoption (≥3 real-product repos)
2. **Maintenance**: active commits in the past 60 days, open issue triage, no chronic infrastructure bugs
3. **Vendor-neutrality filter** (per `feedback_plugin_curation_vendor_neutrality` memory): no acquisition by OpenAI / direct Anthropic competitor. Vendors acquired by such are filtered out, regardless of technical merit.
4. **Existence verified** via `gh api repos/<owner>/<repo>` on 2026-05-05 (stars, last commit timestamp, archived flag)

If any vendor below is later acquired by an Anthropic competitor, the corresponding entry must be reviewed.

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

**Vendor-neutrality**: Supabase is independent (Series C funding), MIT-licensed, not acquired by OpenAI / Microsoft / Anthropic competitors as of 2026-05-05.

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

**Vendor-neutrality**: Prisma is independent, not acquired.

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

**Vendor-neutrality**: Apollo GraphQL Inc. is independent.

---

### Vercel — `vercel-labs/agent-skills`

**Covers**: `react-best-practices` (40+ rules across 8 categories from Vercel Engineering), View Transitions, React Composition Patterns, Web Design Guidelines, Next.js patterns.

**When to install**: any project using Next.js or modern React on Vercel.

**Pair with**: claude-base's `dev-nextjs` and `dev-react-perf` skills (workflow patterns, deploy-safety, anti-patterns).

**Install** (verify on their README):
```bash
git clone --depth 1 https://github.com/vercel-labs/agent-skills ~/dev/vendor-skills/vercel
# Symlink the relevant skill subdirectories into ./.claude/skills/
```

**Vendor-neutrality**: Vercel is independent. Note: Vercel's `v0` product is an AI-coding tool that competes adjacently with Claude Code; Vercel itself is not acquired by OpenAI / Anthropic competitors. Re-evaluate if this changes.

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

**Vendor-neutrality**: shadcn/ui is open-source under MIT, individual maintainer (no vendor capture risk).

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

**Vendor-neutrality**: Anthropic is, by definition, the home ecosystem.

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

**Vendor-neutrality**: Anthropic. Zero concern.

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

**Vendor-neutrality**: Personal repo, not Google-org-owned. Author has Google affiliation but the project is independent. Acceptable.

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

**Vendor-neutrality**: Google. Web-tooling neutral.

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

**Vendor-neutrality** (CASE-BY-CASE per `feedback_plugin_curation_vendor_neutrality` memory):

Microsoft owns Playwright. Per the foundation's policy, Microsoft tools that **predate the company's deepening OpenAI commercial relationship** are evaluated case-by-case rather than auto-rejected. Playwright was created in 2020, predates that deepening, remains MIT-licensed, and is the de-facto standard for E2E testing (78,000★ on the core repo). The community alternative `lackeyjb/playwright-skill` exists but was 5 months stale at audit time.

**Decision (2026-05-06)**: pointer to `microsoft/playwright-cli` accepted for the qa-e2e skill. Re-evaluate if Microsoft's commercial alignment with OpenAI changes the project's roadmap visibly (e.g. direct OpenAI product integration into Playwright).

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

**Vendor-neutrality**: Independent author.

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

**Vendor-neutrality**: Semgrep is an independent security company.

---

## Stack-specific (install only if your stack matches)

### Lingui — `lingui/skills`

**Covers**: Lingui-specific i18n patterns (announced alongside Lingui 6.0, April 2026).

**Install only if**: your project uses Lingui specifically. For other i18n libraries (next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations), claude-base's framework-agnostic `dev-i18n` skill is sufficient.

**Vendor-neutrality**: Lingui is community-maintained.

---

### Callstack — `callstackincubator/agent-skills` (`react-native-best-practices`)

**Covers**: React Native optimisation patterns from Callstack (a long-standing React Native consultancy).

**Install only if**: your project is React Native. Out of scope for web React.

**Vendor-neutrality**: Callstack is independent.

---

## Vendors evaluated and NOT recommended

This list is part of the curation work. Naming what we rejected matters as much as naming what we approve.

### Astral — `astral@astral-sh` (uv / ruff / ty)

**Rejected on positioning grounds**: Astral was acquired by OpenAI on 2026-03-19. Bundling OpenAI-acquired tooling in an Anthropic-ecosystem kit publishes a dissonant signal. Tools remain MIT-licensed, but future roadmap drift toward Codex-specific integration is plausible.

**If you want it anyway**: see `docs/recipes/python-toolchain-options.md` for the opt-in path. claude-base does not bundle this plugin.

### `greptile@claude-plugins-official`

**Rejected on technical grounds**: recurrent OAuth registration bugs in successive months (Jan 2026, April 2026). Auth layer not stable. Re-evaluate if Greptile resolves these issues.

### `pyright-lsp@claude-plugins-official`

**Rejected on technical grounds**: multiple open infrastructure bugs as of early 2026 (race condition between LSP manager initialization and plugin loading, `lspServers` config not propagated). Re-evaluate when these are resolved.

### `commit-commands@claude-plugins-official`

**Rejected on overlap grounds**: redundant with claude-base's `/work:work-commit` and `/work:work-pr` commands. Adds noise, not value.

---

## When this list will change

This recipe is a living document. Triggers for re-evaluation:

| Trigger | Action |
|---------|--------|
| Any vendor in this recipe is acquired by OpenAI / Microsoft (>50% economic ownership) / direct Claude Code competitor | Move to "Not recommended" with explanation |
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
