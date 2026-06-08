# claude-base

> **Workflow framework + curator for Claude Code.** Makes Claude Code follow a real engineering workflow — **Explore → Specify → Plan → TDD → Audit → Commit** — wired through hooks, path-specific rules, and an anti-drift CI gate. Stack presets (`nextjs`, `fastapi`, `astro`, `react-vite-spa`, `cli-tools`, `homelab-proxmox`) auto-detect your repo and point you at a curated set of vendor skills for tool-specific depth, so you don't have to figure out which community skill to trust.

[![CI](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml)
[![Security](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/christopherlouet/claude-base/actions)
[![Tests](https://img.shields.io/badge/tests-849%20passing-brightgreen)](./tests)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/christopherlouet/claude-base?label=release&color=blue)](https://github.com/christopherlouet/claude-base/releases/latest)
[![Documentation](https://img.shields.io/badge/docs-Docusaurus-blue)](https://christopherlouet.github.io/claude-base/)

## Try it (30 seconds)

```bash
# 1. Install the foundation (clones to ~/.local/share/claude-base, symlinks to ~/.local/bin)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash

# 2. Install into a project (auto-detects the stack, picks the right preset)
claude-base init --preset nextjs ./my-app
# or just: claude-base init ./existing-project   (interactive, auto-detects)

# 3. Open Claude Code in the project and run the canonical workflow
cd ./my-app && claude
> /work:work-flow-feature "add a /counter route with optimistic UI"
```

That last command chains the 6 phases automatically: Explore → Specify → Plan → TDD → Audit → Commit. Each phase has dedicated slash commands you can also drive manually.

## Is it for you?

| You are... | This helps... | Skip it if... |
|---|---|---|
| **Solo dev** shipping side-projects with Claude Code | preset gives you stack + workflow rigor in 30s ; no copy-pasting prompts between sessions | you barely use Claude Code yet — start with the [official docs](https://code.claude.com/docs/en/overview) first |
| **Team lead** wanting consistent Claude Code outputs across a codebase | enforces TDD + audit-loop gates in shared `.claude/` config, anti-drift counters CI-gated | your team has already built bespoke prompts you're happy with |
| **Educator / mentor** | the 6-phase workflow is named, teachable, and the audit-loop produces a quality score | you only need ad-hoc Claude Code use |
| **Returning user** who tried Claude Code, found it too freeform | the dispatcher CLI is small (init / update / validate / uninstall) and the foundation is fully reversible (`claude-base uninstall`) | you prefer raw `.claude/` files without a foundation layer |

**You don't have to learn the <!-- count:commands -->128<!-- /count --> commands.** The mandatory workflow is 5 slash-commands: `/work:work-explore`, `/work:work-plan`, `/dev:dev-tdd`, `/qa:qa-loop`, `/work:work-pr`. The rest are domain-specific (CI, a11y, payment, GDPR, etc.) and either auto-trigger via path rules or stay one slash away when relevant.

## How it fits in the AI-coding ecosystem

claude-base plays **two roles**, both Claude-Code-native:

1. **Workflow framework** — the foundation owns the rigor: Explore → Specify → Plan → TDD → Audit, enforced via path-specific rules (TypeScript strict, OWASP, WCAG, perf), wired into hooks (`settings.json`, PostToolUse tsc+eslint, gitleaks, anti-drift counters), orchestrated via the `claude-base` CLI.
2. **Curator** — for tool-specific depth (React, Prisma, Supabase, MSW, Docker, Web Vitals, Chrome DevTools, analytics, email, SEO…), the foundation points to vendor-published skills validated through audit pilots (see [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md)). Each vendor maintains their own canonical content; we curate the list of which ones are worth trusting.

The foundation does NOT chase vendor freshness: a 1-maintainer project can't out-update a 6,700+ skill ecosystem refreshed daily. Instead, the skills the foundation ships either (a) capture **workflow patterns** that survive across vendor releases (TDD discipline, audit-loop orchestration, deploy-safety checklists), or (b) **point** to the canonical vendor source with a thin foundation-specific discipline overlay.

Two adjacent ecosystems share part of the surface area :

### vs [Spec Kit](https://github.com/github/spec-kit) (GitHub, Spec-Driven Development across 30+ agents)

Spec Kit is the **canonical SDD primitives toolkit** : `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement` — agent-agnostic, well-documented, batteries-included. If you need spec-driven development that works across Claude, Codex, Cursor, Copilot and 30+ other agents, **use spec-kit**.

claude-base is **the opinionated discipline layer on top of (or in place of) those primitives, specifically for Claude Code**. It adds what Spec Kit does not :

| | spec-kit | claude-base |
|---|---|---|
| Scope | Multi-agent (30+) | Claude Code-native + cross-tool via [`AGENTS.md`](./AGENTS.md) |
| Spec → Plan → Tasks → Implement | ✓ | ✓ (different command names ; same workflow shape) |
| Explore phase (read-before-write) | — | ✓ `/work:work-explore` |
| TDD enforced (tests-first mandatory) | — | ✓ via `tdd-enforcement` rule + `/dev:dev-tdd` |
| Adaptive audit-fix loop (quality score) | — | ✓ `/qa:qa-loop "score 90"` |
| Path-specific rules (TS strict, OWASP, WCAG, perf...) | — | ✓ 30 auto-activated rules |
| Hooks wired into `settings.json` (PostToolUse tsc+eslint, gitleaks, anti-drift) | — | ✓ |
| Anti-drift CI strategy (`counts.json`, `audit-docs.sh` firewall) | — | ✓ |
| Stack presets with vendor-skill pointers | — | ✓ <!-- count:presets -->11<!-- /count --> presets, 3 tiers |

**They are complementary, not competing.** If you adopt SDD primitives, spec-kit is the canonical choice. If you want Claude Code with deep TDD/audit/rules baked in, claude-base ships the opinionated stack. There's no clean way to package claude-base as a spec-kit extension (the rules engine, hooks wiring, and presets system have no spec-kit equivalent) — but a project can reasonably use both : spec-kit for the multi-agent SDD primitives, claude-base for the Claude-Code-side discipline.

### vs the [official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) (vendor-published skills/plugins)

For deeper coverage of **specific tools** — vendor-published skills for Terraform, Postgres, Playwright, MongoDB, observability stacks, framework-specific patterns — the marketplace and community skills ship targeted depth that goes further than what a foundation could bundle. That's the design: a foundation curates **workflow integration + a trusted list**, vendor skills curate **depth on a single tool or stack**.

**Recommended pattern**

```
claude-base (workflow framework + curator)   ← Explore → TDD → Audit, anti-drift, qa-loop, hooks, rules
       +
vendor skills (tool-specific depth)          ← Prisma, Supabase, Playwright, Grafana, MSW, PostHog, ...
```

The foundation ships <!-- count:commands -->128<!-- /count --> commands + <!-- count:agents -->61<!-- /count --> agents + <!-- count:skills -->53<!-- /count --> skills, but most skills are **thin pointers** pairing the canonical vendor source with a few foundation-specific discipline lines (security/GDPR wraps, anti-patterns, cross-skill orchestration). What's NOT pointer-shaped is the workflow layer:

- **Workflow rigor coordinated as one experience** — TDD enforcement, autonomous `qa-loop` audit-fix cycle, score-90 gates
- **Anti-drift counter strategy** across the entire foundation, CI-enforced via `counts.json` + a doc drift firewall (`scripts/audit-docs.sh`)
- **<!-- count:rules -->30<!-- /count --> path-specific rules** auto-activated by file path (TypeScript strict, OWASP defaults, WCAG, Core Web Vitals, deploy-safety)
- **PostToolUse output rewriter** for Bash + tsc/eslint (Claude Code 2.1.121+)
- **Integrated install + update flow** via the `claude-base` CLI

**How the curator role works today**: [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md) lists <!-- count:vendorSkillsValidated -->21<!-- /count --> vendor skills validated through <!-- count:marketplaceAuditPilots -->5<!-- /count --> audit pilots, organised by stack (see the *By stack* matrix) and by domain. You install the ones matching your stack; the foundation does not bundle them (vendors handle their own distribution and updates).

**Where this is going**: see [`specs/foundation-positioning-review/phase-6-curator-bindings.md`](./specs/foundation-positioning-review/phase-6-curator-bindings.md) — the next milestone wires preset detection to per-stack vendor-skill recommendations, surfaced in a single `claude-base init` prompt instead of leaving the curation as a homework assignment.

## What you get on disk

After `claude-base init`, your project gains:

```
your-project/
├── CLAUDE.md              # Project instructions auto-loaded by Claude Code
├── .claude/
│   ├── settings.json      # Hooks, permissions, plugin enablement
│   ├── commands/          # Slash commands grouped by domain (work, dev, qa, ops, ...)
│   ├── agents/            # Sub-agents with isolated context
│   ├── skills/            # Auto-triggered on keywords
│   ├── rules/             # Path-specific rules (TDD, security, a11y, performance)
│   ├── presets/           # Stack-specific bundle manifests
│   ├── output-styles/     # Output rendering styles
│   └── templates/         # Per-stack CLAUDE.*.md scaffolds
└── .github/               # (optional) CI workflows + pre-commit hooks
```

Everything is plain markdown + JSON. No daemon, no telemetry, no network access at runtime. Reversible via `claude-base uninstall`.

## What's included

| Component | Count | What it is |
|---|---|---|
| Slash commands | <!-- count:commands -->128<!-- /count --> across 9 domains (work, dev, qa, ops, doc, biz, growth, data, legal) | Manually triggered (`/work:work-plan`) |
| Sub-agents | <!-- count:agents -->61<!-- /count --> | Autonomous, isolated-context workers spawned by commands |
| Skills | <!-- count:skills -->53<!-- /count --> | Auto-triggered on keywords in your prompts |
| Path-specific rules | <!-- count:rules -->30<!-- /count --> | Auto-activated based on the file being edited (TS strict, OWASP, WCAG, ...) |
| Presets | <!-- count:presets -->11<!-- /count --> | Stack-specific bundles ; tier breakdown in [Going deeper](#going-deeper) |

Full catalogue: [Docusaurus reference](https://christopherlouet.github.io/claude-base/docs/reference) — or browse `.claude/` directly after install.

## What it looks like

![claude-base install tour](./website/static/img/60-second-tour.gif)

Real `curl | bash` install + `claude-base init --preset nextjs` + the resulting `.claude/` tree on disk, recorded inside an isolated Docker container. ~10 seconds end-to-end (recording scaffolding under [`website/demo/`](./website/demo/), reproducible).

From there you `cd ./my-app && claude` and the foundation drives the 6-phase workflow :

```
> /work:work-flow-feature "add a /counter route with optimistic UI"

[work-explore]  Scans app/, hooks/, lib/ → detects the project shape
[work-specify]  Drafts user stories + acceptance criteria
[work-plan]     Lists the files to touch + identifies risks
[dev-tdd]       RED → GREEN → REFACTOR cycle, tests before code
[qa-loop]       Audit + auto-fix until target score (default ≥ 90)
[work-pr]       Branch, commit, push, open the PR
```

One command chains the 6 phases. Each phase is also runnable on its own (`/work:work-explore`, `/dev:dev-tdd`, etc.) if you prefer manual control.

## Installation

### Option 1: One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
```

This clones the foundation to `~/.local/share/claude-base` and symlinks the
dispatcher into `~/.local/bin/claude-base`. The installer never runs as root,
never modifies your shell rc files, and only requires `git`. After install:

```bash
claude-base init --preset fastapi ./my-api      # Python backend
claude-base init --preset nextjs   ./my-web-app # Next.js fullstack
claude-base init --simple          ./my-project # Foundation only, no preset
claude-base preset list                          # Discover available presets
claude-base help                                 # All commands
```

To update the foundation later:

```bash
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash -s -- --update
```

If `~/.local/bin` is not on your `PATH`, add it (most modern distros already do):

```bash
export PATH="$HOME/.local/bin:$PATH"  # add to ~/.bashrc or ~/.zshrc
```

### Option 2: Manual git clone

```bash
git clone https://github.com/christopherlouet/claude-base.git
cd claude-base

# Install in an existing project (in-repo dispatcher — no PATH install yet)
./bin/claude-base init --simple /path/to/your/project

# Full install with CI/CD, hooks, Docker
./bin/claude-base init --all /path/to/your/project
```

### Option 3: Manual copy (minimal)

```bash
# Copy the Claude configuration directly
cp -r claude-base/.claude your-project/
cp claude-base/CLAUDE.md your-project/

# Optional
cp claude-base/.mcp.json your-project/
cp claude-base/.github your-project/ -r
```

### Keeping Claude Code itself up to date

The commands above install and update **claude-base** — they do not touch the underlying Claude Code CLI. If you installed Claude Code through Homebrew or WinGet, you can opt into background upgrades by exporting `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` in your shell. This has no effect on the curl one-liner install of claude-base, and no effect if you installed Claude Code through any other channel. Available in Claude Code 2.1.129+.

## Repository layout

After `curl | bash` install, the foundation lives at `~/.local/share/claude-base/`. The repo's top-level layout:

| Path | Role |
|---|---|
| `bin/claude-base` | CLI dispatcher (`init` / `update` / `validate` / `preset` / `uninstall` / `version` / `help`) |
| `install.sh` | One-liner installer — clones to `~/.local/share/claude-base/`, symlinks the dispatcher to `~/.local/bin/` |
| `.claude/` | Foundation kit — `skills/`, `agents/`, `commands/`, `rules/`, `presets/`, `output-styles/`, `templates/`, `settings.json` |
| `scripts/` | Implementation scripts behind the CLI + maintenance tools (`audit-base.sh`, `audit-docs.sh`, `doctor.sh`, `diff.sh`, ...) + hook scripts |
| `templates/` | Stack-specific `CLAUDE.*.md` templates + advisory docs (`FAQ.md`, `PERFORMANCE-GUIDE.md`, `TROUBLESHOOTING.md`) |
| `docs/` | Human-maintained documentation — `QUICKSTART.md`, `CHEATSHEET.md`, `ARCHITECTURE.md`, `WORKFLOWS.md`, `STACK-RECIPES.md`, `CUSTOMIZATION.md`, `recipes/`, `reference/`, `guides/` |
| `website/` | [Docusaurus site](https://christopherlouet.github.io/claude-base/) — `docs/` is auto-mirrored here by `npm --prefix website run generate` |
| `specs/` | Feature specs consumed by the workflow agents (`/work:work-specify`, `/work:work-plan`) |
| `tests/` | <!-- count:tests -->849<!-- /count --> bats tests across <!-- count:testFiles -->35<!-- /count --> files |
| `.github/workflows/` | CI : `ci.yml`, `security.yml`, `docs.yml`, `pr-check.yml`, `release.yml`, `dependabot-auto-merge.yml` |
| `AGENTS.md`, `CHANGELOG.md`, `VERSION`, `LICENSE`, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `counts.json` | Project metadata |

For the full file-by-file reference, see the [Docusaurus reference docs](https://christopherlouet.github.io/claude-base/docs/reference).

## Available Commands (<!-- count:commands -->128<!-- /count -->)

Commands are grouped into 9 domains:

| Domain | Count | Examples |
|---------|------:|----------|
| `work-` | <!-- count:byDomain.work -->15<!-- /count --> | `/work:work-explore`, `/work:work-plan`, `/work:work-commit`, `/work:work-pr`, `/work:work-flow-feature` |
| `dev-` | <!-- count:byDomain.dev -->22<!-- /count --> | `/dev:dev-tdd`, `/dev:dev-debug`, `/dev:dev-api`, `/dev:dev-flutter`, `/dev:dev-prisma` |
| `qa-` | <!-- count:byDomain.qa -->16<!-- /count --> | `/qa:qa-loop`, `/qa:qa-security`, `/qa:qa-perf`, `/qa:wcag-audit`, `/qa:qa-e2e` |
| `ops-` | <!-- count:byDomain.ops -->34<!-- /count --> | `/ops:ops-deploy`, `/ops:ops-docker`, `/ops:ops-monitoring`, `/ops:ops-k8s`, `/ops:ops-rollback` |
| `doc-` | <!-- count:byDomain.doc -->8<!-- /count --> | `/doc:doc-onboard`, `/doc:doc-explain`, `/doc:doc-changelog`, `/doc:doc-architecture` |
| `biz-` | <!-- count:byDomain.biz -->11<!-- /count --> | `/biz:biz-model`, `/biz:biz-mvp`, `/biz:biz-pricing`, `/biz:biz-personas` |
| `growth-` | <!-- count:byDomain.growth -->11<!-- /count --> | `/growth:growth-landing`, `/growth:growth-seo`, `/growth:growth-cro`, `/growth:growth-funnel` |
| `data-` | <!-- count:byDomain.data -->2<!-- /count --> | `/data:data-pipeline`, `/data:data-modeling` |
| `legal-` | <!-- count:byDomain.legal -->5<!-- /count --> | `/legal:legal-rgpd`, `/legal:legal-terms-of-service`, `/legal:legal-privacy-policy` |

→ **Full list**: [docs/CHEATSHEET.md](docs/CHEATSHEET.md) or the [Docusaurus catalog](https://christopherlouet.github.io/claude-base/docs/commands).

→ **By stack**: [docs/STACK-RECIPES.md](docs/STACK-RECIPES.md) lists the relevant commands for each stack (Web, Mobile, API, Auth, etc.).

## Recommended Workflow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│ SPECIFY │───▶│  PLAN   │───▶│   TDD   │───▶│  AUDIT  │───▶│ COMMIT  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Practical example (Web)

```bash
# 1. Explore the existing system
/work:work-explore the authentication system

# 2. Specify the feature (User Stories + acceptance criteria)
/work:work-specify add OAuth2 Google sign-in

# 3. Plan the implementation
/work:work-plan OAuth2 Google

# 4. Implement in TDD (tests BEFORE the code)
/dev:dev-tdd OAuth2 authentication flow

# 5. Audit + fix loop (score 90 required)
/qa:qa-loop "score 90"

# 6. Open the PR
/work:work-pr OAuth2 Google authentication
```

### Practical example (Mobile Flutter)

```bash
# 1. Explore the existing architecture
/work:work-explore the feature directory layout

# 2. Specify the screen (User Stories + criteria)
/work:work-specify user profile screen

# 3. Plan the implementation
/work:work-plan user profile screen

# 4. Build the widget/screen in TDD
/dev:dev-tdd UserProfileScreen with BLoC + widget tests

# 5. Mobile quality audit + fix loop
/qa:qa-loop "score 90"

# 6. Open the PR
/work:work-pr user profile screen
```

## Available Templates

| Template | Language / Framework |
|----------|---------------------|
| `CLAUDE.react.md` | React |
| `CLAUDE.nextjs.md` | Next.js (App Router) |
| `CLAUDE.vue.md` | Vue.js 3 |
| `CLAUDE.node-api.md` | Node.js API |
| `CLAUDE.python.md` | Python |
| `CLAUDE.go.md` | Go |
| `CLAUDE.rust.md` | Rust |
| `CLAUDE.java.md` | Java / Spring Boot |
| `CLAUDE.fullstack.md` | Fullstack monorepo |
| `CLAUDE.flutter.md` | Flutter / Dart (Mobile) |
| `CLAUDE.neovim.md` | Neovim / Lua config |

```bash
# Recommended: scaffold via the dispatcher (works post-install, any cwd)
claude-base init --type react ./my-app

# Or copy the template manually (from a foundation clone)
cp templates/CLAUDE.react.md CLAUDE.md
```

The dispatcher path additionally wires hooks, settings, and preset-specific filtering ; the raw `cp` only installs the project-instructions file.

## Utility CLI (`claude-base`)

After `curl | bash` install, the unified dispatcher is on your PATH. Use it as the canonical entry point:

```bash
# Create a new project (interactive)
claude-base init

# Install in an existing project
claude-base init --simple /path/to/project

# Update commands
claude-base update /path/to/project

# Validate the configuration
claude-base validate /path/to/project
claude-base validate --json /path/to/project   # for CI/CD

# Uninstall
claude-base uninstall /path/to/project
```

Maintenance / diagnostic tools without a dispatcher alias (still callable directly from a foundation clone):

```bash
# Full diagnostic
./scripts/doctor.sh /path/to/project

# Diff against the foundation
./scripts/diff.sh /path/to/project

# IDE integration (VSCode, IntelliJ, Vim/Neovim)
./scripts/ide.sh setup vscode
```

## Getting started in Claude Code

Once installed, the fastest way to learn the workflow is the built-in orchestrator:

```
/assistant              # guided mode: explains and suggests commands
/assistant-auto "..."   # automatic mode: routes to the right workflow

# Or follow the canonical 6-step workflow
/work:work-explore
/work:work-specify
/work:work-plan
/dev:dev-tdd
/qa:qa-loop "score 90"
/work:work-commit
```

See [docs/QUICKSTART.md](docs/QUICKSTART.md), [docs/CHEATSHEET.md](docs/CHEATSHEET.md) and [docs/STACK-RECIPES.md](docs/STACK-RECIPES.md) for more.

## IDE Integration

```bash
./scripts/ide.sh setup <vscode|idea|vim|all>   # configure
./scripts/ide.sh check  <vscode|idea|vim>      # verify
./scripts/ide.sh remove <vscode|idea|vim>      # uninstall
```

Sets up Settings/Tasks/Extensions/Snippets (VSCode/Cursor), Run Configurations/Code Style/Templates (IntelliJ), or Abbreviations/Mappings/Autocmds (Vim/Neovim). Run `./scripts/ide.sh --help` for the full surface.

## CI/CD Included

### GitHub Actions

- **ci.yml**: Tests (bats + node), shellcheck, lint, build
- **security.yml**: Gitleaks + shellcheck-security workflow
- **pr-check.yml**: PR format / size / labels validation (uses `amannn/action-semantic-pull-request`)
- **docs.yml**: Builds and deploys the Docusaurus site to GitHub Pages
- **release.yml**: Automated releases with changelog
- **dependabot-auto-merge.yml**: Auto-merges dependabot PRs that pass CI

Full file-by-file at `.github/workflows/`.

### Pre-commit Hooks

The foundation ships `.husky/` with auto-lint, Conventional Commits validation, and secret detection (gitleaks). Enabled automatically when `claude-base init` runs with `--hooks` or `--all`. To re-enable manually in an existing install : `npx husky install` (assumes husky + lint-staged + commitlint are already in your project's devDependencies).

## Documentation

### Online documentation

The full documentation site lives at **[https://christopherlouet.github.io/claude-base/](https://christopherlouet.github.io/claude-base/)**.

It covers:
- Quick start guide
- Catalog of <!-- count:commands -->128<!-- /count --> commands, <!-- count:agents -->61<!-- /count --> agents, <!-- count:skills -->53<!-- /count --> skills, <!-- count:rules -->30<!-- /count --> rules
- Recommended workflows (Explore → Specify → Plan → TDD → Audit → Commit)
- Stack Recipes: relevant commands per stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, AI/LLM, Business, Growth)
- Specific guides: Learning path, Extending, Team, Prompting, Troubleshooting

### Local documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)**: 5-minute getting started
- **[CHEATSHEET.md](docs/CHEATSHEET.md)**: Command quick reference
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Commands vs Agents vs Skills vs Rules
- **[WORKFLOWS.md](docs/WORKFLOWS.md)**: Workflow diagrams
- **[STACK-RECIPES.md](docs/STACK-RECIPES.md)**: Commands/agents/skills per stack (Web, Mobile, API…)
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)**: Customization guide
- **[recipes/](docs/recipes/)**: Targeted recipes — recommended vendor skills, Python toolchain options, SaaS monetization, etc.
- **[guides/EXTENDING-GUIDE.md](docs/guides/EXTENDING-GUIDE.md)**: Extend the foundation (custom commands/skills/rules)
- **[guides/TEAM-GUIDE.md](docs/guides/TEAM-GUIDE.md)**: Team adoption — including [`When .claude/ is gitignored`](docs/guides/TEAM-GUIDE.md#when-claude-is-gitignored--scope-choices-for-plugins--skills) (scope choices for plugins & skills)
- **[guides/PROMPTING-GUIDE.md](docs/guides/PROMPTING-GUIDE.md)**: Prompting techniques
- **[guides/TROUBLESHOOTING-GUIDE.md](docs/guides/TROUBLESHOOTING-GUIDE.md)**: Common issues and fixes
- **Learning path** (Docusaurus only): [9h30, 5 levels novice → pro](https://christopherlouet.github.io/claude-base/docs/guides/learning-path)

## Resources

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [How Anthropic Teams Use Claude Code](https://www.anthropic.com/news/how-anthropic-teams-use-claude-code)

## Secret Detection (gitleaks)

The foundation ships a pre-configured [gitleaks](https://github.com/gitleaks/gitleaks) ruleset at `.gitleaks.toml`. It runs automatically via pre-commit hooks (when enabled) and on every PR through `security.yml`. Detected categories include AWS/GitHub/GitLab/Stripe/Slack tokens, JWTs, private keys, and database URLs — see `.gitleaks.toml` for the exact rules.

Install gitleaks itself per the [upstream instructions](https://github.com/gitleaks/gitleaks#installing). Local scan :

```bash
gitleaks detect --source . --config .gitleaks.toml          # full scan
gitleaks detect --staged --config .gitleaks.toml            # staged-only (pre-commit)
```

## Automated Tests

The foundation ships with [bats-core](https://github.com/bats-core/bats-core) tests that validate every script. Install bats via the [upstream instructions](https://github.com/bats-core/bats-core#installation) (or `./scripts/test.sh --install-bats` to use the foundation's bundled helper).

```bash
./scripts/test.sh                # parallel run, all tests
./scripts/test.sh validate       # filter to one suite (e.g. validate.bats)
./scripts/test.sh -v             # verbose
```

### Test layout

<!-- count:tests -->849<!-- /count --> bats tests across <!-- count:testFiles -->35<!-- /count --> files. A few anchors :

| Area | File | Tests |
|---|---|---|
| Smoke + utility | `smoke.bats`, `common.bats` | Fast integrity check + lib unit tests |
| Installer + dispatcher | `install.bats`, `new-project.bats`, `dispatcher.bats` | One-liner installer, `claude-base init` flow, CLI dispatcher |
| Update flow | `update.bats`, `update-presets.bats` | Refresh logic, preset-aware filters |
| Preset system | `presets.bats`, `preset-detect.bats`, `preset-e2e.bats` | Manifest schema, data-driven detection, per-preset E2E |
| Quality gates | `validate.bats`, `qa-loop.bats`, `audit-docs.bats` | Validation, audit-fix loop, doc-drift firewall |
| End-to-end | `e2e.bats` | Full bootstrap → validate → uninstall cycle |
| Drift guards | `manifest-hooks-coverage.bats`, `docs-under-claude.bats` | Hooks coverage, structural layout |

Full file-by-file inventory at `tests/`. Run via `./scripts/test.sh` (parallel) or `bats tests/*.bats` (sequential).

## Upgrades & Changelog

For per-release details (Added / Changed / Fixed / Security / Removed), see [CHANGELOG.md](CHANGELOG.md) — kept in [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

### Upgrading an installed project

```bash
# Upgrade the foundation itself (refreshes ~/.local/share/claude-base)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash -s -- --update

# Refresh an installed project to the current foundation
claude-base update /path/to/your/project

# Or refresh with a specific preset filter applied
claude-base update --preset nextjs /path/to/your/project
```

`claude-base update` is COPY-only by default — existing files in your project's `.claude/` are not deleted. Pass `--clean` to wipe-and-replace (a backup is created first).

### Versioning policy

The foundation follows [Semantic Versioning](https://semver.org/). Each release is tagged `vX.Y.Z` and shipped with a GitHub Release containing the relevant CHANGELOG excerpt. Pin via `git checkout vX.Y.Z` in `~/.local/share/claude-base` if you need reproducible installs. Behaviour-breaking changes between minor versions are explicitly called out in the CHANGELOG under `### Breaking`.

## Production Readiness

Concrete signals rather than a self-assessment score :

- <!-- count:tests -->849<!-- /count --> bats tests run on every PR (Linux + macOS), parallelised via `./scripts/test.sh`
- Six GitHub Actions workflows (CI, security, docs, PR check, release, dependabot auto-merge) gating merges
- Doc drift firewall (`scripts/audit-docs.sh`) catches syntactic doc drift before merge — see [PR #201](https://github.com/christopherlouet/claude-base/pull/201)
- Counter anti-drift gate (`scripts/validate-counts.sh`) regenerated from `counts.json`
- Pinned versions via git tags (current : v<!-- version -->1.41.0<!-- /version -->) with full `CHANGELOG.md` in Keep-a-Changelog format

### Security measures

- **Gitleaks**: secret detection ruleset (CI workflow + local scan) — see `.gitleaks.toml`
- **ShellCheck**: bash linting on all `scripts/` (CI workflow `security.yml`, severity warning)
- **Deny list**: dangerous commands blocked (`rm -rf /`, `sudo`, `git push --force`)
- **Protection hooks**: blocks edits on main/master
- **GitHub Secret Scanning**: enabled on the public repo
- **GitHub Code Scanning** (CodeQL): TypeScript security analysis (Default Setup, scans `website/scripts/`, `website/src/`)

See [SECURITY.md](SECURITY.md) for the full security policy.

## Going deeper

Detail-level docs and editorial pieces that didn't make the front-door:

- **Three preset tiers** — `maintainer-vouched` (production use ≥3 months) / `vendor-pointer` (vendor-authored, validated via marketplace audit) / `community-curated` (signed maintenance commitment). See [`.claude/presets/README.md`](./.claude/presets/README.md) and [`specs/presets-vendor-pointer-tier/spec.md`](./specs/presets-vendor-pointer-tier/spec.md).
- **Pre-detection category prompt** — when `claude-base init` runs on an empty directory with no preset/type and no auto-detect match, an interactive 8-entry intent prompt narrows the menu. Spec: [`specs/preset-category-prompt/spec.md`](./specs/preset-category-prompt/spec.md).
- **Cross-tool compatibility** — `AGENTS.md` at repo root signals SKILL.md open-standard compliance to Codex, Cursor, Copilot, Gemini CLI. Skills under `.claude/skills/` use the standard frontmatter ; Claude-specific extensions are silently ignored by other tools. See [`AGENTS.md`](./AGENTS.md).
- **Doc drift firewall** — `scripts/audit-docs.sh` catches 5 categories of syntactic drift (paths, claude-base verbs, init/update flags, local scripts, npm scripts) before merge. CI-gated.

### Long-term direction

claude-base's irreducible value is the workflow rigor (TDD, audit-loop, anti-drift) and the path-specific rules. **Domain-specific knowledge is increasingly available as vendor-published skills/plugins** in the official Claude Code marketplace. The foundation lives alongside the marketplace, not in opposition.

Three mechanisms keep it aligned with that trajectory:

1. **Periodic marketplace audits** with a vendor-neutrality filter (we reject vendors acquired by direct Anthropic competitors). Output: [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md).
2. **Recommended vendor skills per preset** — printed at the end of `claude-base init`. Manual install today ; the foundation does NOT auto-install third-party code.
3. **Trajectory-driven automation** — when most vendors are on the official marketplace, automating install becomes safe. We don't today (~21% are on the official marketplace, as of last audit) but will revisit when the ratio inverts.
