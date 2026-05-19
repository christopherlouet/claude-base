# claude-base

> **Opinionated Claude Code foundation.** Makes Claude Code follow a real engineering workflow — **Explore → Specify → Plan → TDD → Audit → Commit** — and drops in a curated `.claude/` (slash commands, sub-agents, skills, path-specific rules for TDD/security/a11y/perf). Stack presets (`nextjs`, `fastapi`, `astro`, `react-vite-spa`, `cli-tools`, `homelab-proxmox`, + vendor pointers) auto-detect your repo on install.

[![CI](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml)
[![Security](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/christopherlouet/claude-base/actions)
[![Tests](https://img.shields.io/badge/tests-659%20passing-brightgreen)](./tests)
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

**You don't have to learn the <!-- count:commands -->131<!-- /count --> commands.** The mandatory workflow is 5 slash-commands: `/work:work-explore`, `/work:work-plan`, `/dev:dev-tdd`, `/qa:qa-loop`, `/work:work-pr`. The rest are domain-specific (CI, a11y, payment, GDPR, etc.) and either auto-trigger via path rules or stay one slash away when relevant.

## How it fits in the Claude Code ecosystem

claude-base is a **workflow foundation**, not a competing plugin marketplace. It curates a coherent rigor (Explore → Specify → Plan → TDD → Audit), wires hooks/rules/conventions, and orchestrates project setup via the `claude-base` CLI.

For deeper coverage of specific tools — vendor-published skills for Terraform, Postgres, Playwright, MongoDB, observability stacks, framework-specific patterns — the [official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) and community-published skills often ship targeted depth that goes further than what this foundation bundles. That's expected: a foundation curates **breadth + workflow integration**, vendor skills curate **depth on a single tool or stack**.

**Recommended pattern**

```
claude-base (foundation)        ← Explore → TDD → Audit, anti-drift, qa-loop, hooks, rules
       +
vendor skills (specific tools)  ← Terraform, Postgres, Playwright, Grafana, Prisma, MongoDB, ...
```

claude-base's unique value (vs assembling vendor skills alone):

- **Workflow rigor coordinated as one experience** — TDD enforcement, autonomous `qa-loop` audit-fix cycle, score-90 gates
- **Anti-drift counter strategy** across the entire foundation, CI-enforced via `counts.json` + a new doc drift firewall (`scripts/audit-docs.sh`)
- **30 path-specific rules** auto-activated by file path (TypeScript strict, OWASP defaults, WCAG, Core Web Vitals, deploy-safety)
- **PostToolUse output rewriter** for Bash + tsc/eslint (Claude Code 2.1.121+)
- **Integrated install + update flow** via the `claude-base` CLI

**Honest limit**: for any specific tool integration, there's likely a more specialized vendor skill that goes deeper. The recipe [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md) is the curated list of validated sources (<!-- count:vendorSkillsValidated -->17<!-- /count --> skills across <!-- count:marketplaceAuditPilots -->4<!-- /count --> audit pilots).

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
| Slash commands | <!-- count:commands -->131<!-- /count --> across 9 domains (work, dev, qa, ops, doc, biz, growth, data, legal) | Manually triggered (`/work:work-plan`) |
| Sub-agents | <!-- count:agents -->63<!-- /count --> | Autonomous, isolated-context workers spawned by commands |
| Skills | <!-- count:skills -->54<!-- /count --> | Auto-triggered on keywords in your prompts |
| Path-specific rules | <!-- count:rules -->30<!-- /count --> | Auto-activated based on the file being edited (TS strict, OWASP, WCAG, ...) |
| Presets | <!-- count:presets -->11<!-- /count --> | Stack-specific bundles ; tier breakdown in [Going deeper](#going-deeper) |

Full catalogue: [Docusaurus reference](https://christopherlouet.github.io/claude-base/docs/reference) — or browse `.claude/` directly after install.

## What it looks like (60-second tour)

> An [asciinema](https://asciinema.org) recording is on the roadmap. Until then,
> here is the exact terminal output you would see end-to-end. The flow is
> reproducible: replace `./my-app` with any directory and run yourself.

```text
$ curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
[INFO] Cloning to ~/.local/share/claude-base ...
[OK]   Cloned (foundation v1.41.0)
[OK]   Symlinked dispatcher → ~/.local/bin/claude-base
[INFO] Done. Run `claude-base help` to get started.

$ claude-base init --preset nextjs ./my-app
[INFO] Preset: nextjs (maintainer-vouched, 6+ months prod use)
[INFO] Installing into ./my-app
[OK]   Filtered foundation copy applied (skills/agents/commands relevant to Next.js)
[OK]   Wired hooks: PostToolUse (tsc + eslint inline), PreToolUse (anti-drift)
[OK]   CLAUDE.md written, .claude/settings.json initialized

  → 3 vendor skills recommended for your stack:
      - tailwindcss/tailwindcss-skill   (validated)
      - vercel/nextjs-skill             (validated)
      - shadcn/shadcn-ui-skill          (validated)
  See ./RECOMMENDED-VENDOR-SKILLS.md for manual install commands.

$ cd ./my-app && claude
> /work:work-flow-feature "add a /counter route with optimistic UI"

[work-explore]  Scanning app/, hooks/, lib/ ... 24 files indexed
[work-explore]  Detected: App Router, server actions, no existing state mgmt
[work-specify]  US-1 (P1): user clicks +/- and counter updates without lag
                Acceptance: optimistic UI, server-action persistence, rollback on error
[work-plan]     Files to create: app/counter/page.tsx, app/api/counter/route.ts,
                                  hooks/use-counter.ts, tests/counter.test.tsx
[dev-tdd]       RED:    wrote 4 tests in counter.test.tsx → 4 failing as expected
[dev-tdd]       GREEN:  minimal implementation → 4/4 passing
[dev-tdd]       REFACTOR: extracted optimistic hook, kept tests green
[qa-loop]       Audit pass 1: 86/100 (1 a11y issue: button without aria-label)
[qa-loop]       Auto-fix applied, audit pass 2: 92/100 ✓ (≥ target score 90)
[work-pr]       Branch: feat/counter-route, 5 files changed, +127 -3
[work-pr]       PR #1 opened: https://github.com/you/my-app/pull/1
```

Six phases, one command. Each phase is also runnable on its own (`/work:work-explore`, `/dev:dev-tdd`, etc.) if you prefer manual control.

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
| `tests/` | <!-- count:tests -->659<!-- /count --> bats tests across <!-- count:testFiles -->29<!-- /count --> files |
| `.github/workflows/` | CI : `ci.yml`, `security.yml`, `docs.yml`, `pr-check.yml`, `release.yml`, `dependabot-auto-merge.yml` |
| `AGENTS.md`, `CHANGELOG.md`, `VERSION`, `LICENSE`, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `counts.json` | Project metadata |

For the full file-by-file reference, see the [Docusaurus reference docs](https://christopherlouet.github.io/claude-base/docs/reference).

## Available Commands (<!-- count:commands -->131<!-- /count -->)

Commands are grouped into 9 domains:

| Domain | Count | Examples |
|---------|------:|----------|
| `work-` | <!-- count:byDomain.work -->15<!-- /count --> | `/work:work-explore`, `/work:work-plan`, `/work:work-commit`, `/work:work-pr`, `/work:work-flow-feature` |
| `dev-` | <!-- count:byDomain.dev -->23<!-- /count --> | `/dev:dev-tdd`, `/dev:dev-debug`, `/dev:dev-api`, `/dev:dev-flutter`, `/dev:dev-prisma` |
| `qa-` | <!-- count:byDomain.qa -->16<!-- /count --> | `/qa:qa-loop`, `/qa:qa-security`, `/qa:qa-perf`, `/qa:wcag-audit`, `/qa:qa-e2e` |
| `ops-` | <!-- count:byDomain.ops -->34<!-- /count --> | `/ops:ops-deploy`, `/ops:ops-docker`, `/ops:ops-monitoring`, `/ops:ops-k8s`, `/ops:ops-rollback` |
| `doc-` | <!-- count:byDomain.doc -->9<!-- /count --> | `/doc:doc-onboard`, `/doc:doc-explain`, `/doc:doc-changelog`, `/doc:doc-architecture` |
| `biz-` | <!-- count:byDomain.biz -->11<!-- /count --> | `/biz:biz-model`, `/biz:biz-mvp`, `/biz:biz-pricing`, `/biz:biz-personas` |
| `growth-` | <!-- count:byDomain.growth -->11<!-- /count --> | `/growth:growth-landing`, `/growth:growth-seo`, `/growth:growth-cro`, `/growth:growth-funnel` |
| `data-` | <!-- count:byDomain.data -->3<!-- /count --> | `/data:data-pipeline`, `/data:data-modeling`, `/data:data-analytics` |
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

# 5. Wire up the Supabase backend
/dev:dev-supabase user profile endpoint

# 6. Mobile quality audit + fix loop
/qa:qa-loop "score 90"

# 7. Open the PR
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
# Use a template
cp templates/CLAUDE.react.md CLAUDE.md
```

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

Configure your IDE for the best experience with claude-base.

```bash
# Configure VSCode/Cursor
./scripts/ide.sh setup vscode

# Configure IntelliJ IDEA
./scripts/ide.sh setup idea

# Configure Vim/Neovim
./scripts/ide.sh setup vim

# Configure all IDEs at once
./scripts/ide.sh setup all

# Verify the configuration
./scripts/ide.sh check vscode

# Remove the configuration
./scripts/ide.sh remove vscode
```

### IDE Features

| IDE | Features |
|-----|----------|
| **VSCode/Cursor** | Settings, Tasks, Extensions, Snippets |
| **IntelliJ IDEA** | Run Configurations, Code Style, Templates |
| **Vim/Neovim** | Abbreviations, Mappings, Autocmds |

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

- Auto lint and format
- Conventional Commits validation
- Secret detection

```bash
# Enable husky
npm install husky lint-staged @commitlint/cli @commitlint/config-conventional -D
npx husky install
```

## Documentation

### Online documentation

The full documentation site lives at **[https://christopherlouet.github.io/claude-base/](https://christopherlouet.github.io/claude-base/)**.

It covers:
- Quick start guide
- Catalog of <!-- count:commands -->131<!-- /count --> commands, <!-- count:agents -->63<!-- /count --> agents, <!-- count:skills -->54<!-- /count --> skills, <!-- count:rules -->30<!-- /count --> rules
- Recommended workflows (Explore → Specify → Plan → TDD → Audit → Commit)
- Stack Recipes: relevant commands per stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, AI/LLM, Business, Growth)
- Specific guides: Extending, Team, Prompting, Troubleshooting

### Local documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)**: 5-minute getting started
- **[CHEATSHEET.md](docs/CHEATSHEET.md)**: Command quick reference
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Commands vs Agents vs Skills vs Rules
- **[WORKFLOWS.md](docs/WORKFLOWS.md)**: Workflow diagrams
- **[STACK-RECIPES.md](docs/STACK-RECIPES.md)**: Commands/agents/skills per stack (Web, Mobile, API…)
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)**: Customization guide
- **[guides/EXTENDING-GUIDE.md](docs/guides/EXTENDING-GUIDE.md)**: Extend the foundation (custom commands/skills/rules)
- **[guides/TEAM-GUIDE.md](docs/guides/TEAM-GUIDE.md)**: Team adoption — including [`When .claude/ is gitignored`](docs/guides/TEAM-GUIDE.md#when-claude-is-gitignored--scope-choices-for-plugins--skills) (scope choices for plugins & skills)

## Default Permissions

| Allowed | Blocked |
|---------|---------|
| ✅ File editing | ❌ `git push --force` |
| ✅ npm test/lint/build | ❌ `rm -rf` |
| ✅ git status/diff/add/commit | |
| ✅ gh issue/pr | |

## Resources

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [How Anthropic Teams Use Claude Code](https://www.anthropic.com/news/how-anthropic-teams-use-claude-code)

## Secret Detection (gitleaks)

The foundation uses [gitleaks](https://github.com/gitleaks/gitleaks) to automatically catch secrets in code.

### Install gitleaks

```bash
# macOS
brew install gitleaks

# Linux (via go)
go install github.com/gitleaks/gitleaks/v8@latest

# Docker
docker pull ghcr.io/gitleaks/gitleaks:latest
```

### Usage

```bash
# Scan the project
gitleaks detect --source . --config .gitleaks.toml

# Scan before commit (automatic via hooks)
gitleaks detect --staged --config .gitleaks.toml
```

### Detected secrets

- AWS access keys
- GitHub/GitLab tokens
- Stripe API keys
- Slack tokens / webhooks
- JWT tokens
- Private keys (RSA, EC, etc.)
- Database URLs
- And many more…

## Automated Tests

The foundation ships with [bats-core](https://github.com/bats-core/bats-core) tests that validate every script.

### Install bats

```bash
# Via npm
npm install -g bats

# Via brew (macOS)
brew install bats-core

# Via the script
./scripts/test.sh --install-bats
```

### Run the tests

```bash
# All tests
./scripts/test.sh

# Specific tests
./scripts/test.sh validate
./scripts/test.sh gitleaks

# Verbose mode
./scripts/test.sh -v
```

### Test layout

<!-- count:tests -->659<!-- /count --> bats tests across <!-- count:testFiles -->29<!-- /count --> files. A few anchors :

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

claude-base is **production-ready** with:

| Criterion | Status | Score |
|-----------|--------|-------|
| Features | ✅ Mature | 9/10 |
| Tests | ✅ Complete | 8/10 |
| CI/CD | ✅ Mature | 8/10 |
| Security | ✅ Mature | 9/10 |
| Documentation | ✅ Mature | 9/10 |

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
