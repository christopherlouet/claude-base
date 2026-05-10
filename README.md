# claude-base

[![CI](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/ci.yml)
[![Security](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml/badge.svg)](https://github.com/christopherlouet/claude-base/actions/workflows/security.yml)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/christopherlouet/claude-base/actions)
[![Tests](https://img.shields.io/badge/tests-593%20passing-brightgreen)](./tests)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/christopherlouet/claude-base?label=release&color=blue)](https://github.com/christopherlouet/claude-base/releases/latest)
[![Documentation](https://img.shields.io/badge/docs-Docusaurus-blue)](https://christopherlouet.github.io/claude-base/)

A Claude Code configuration kit for a solid, reproducible development workflow.

## What is it?

**claude-base** is a configuration bundle for [Claude Code](https://code.claude.com/docs/en/overview) that gives you:

- A structured development workflow: **Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit**
- **<!-- count:commands -->131<!-- /count --> commands**, **<!-- count:agents -->63<!-- /count --> sub-agents**, **<!-- count:skills -->54<!-- /count --> skills**, and **30 path-specific rules** wired together
- **5 stack-specific presets** (`nextjs`, `fastapi`, `astro`, `cli-tools`, `homelab-proxmox`) installable via `claude-base init --preset <name> <path>`
- **Auto-detection of presets** — `claude-base init <existing-project>` recognizes the stack via marker files (e.g. `next.config.js`, `pyproject.toml` containing `fastapi`) and surfaces the matching preset at the top of the type menu. Standalone audit via `claude-base init --detect-only <path>`. Adding a new preset is data-driven (a `.json` manifest with a `detect` block — no code change in detection scripts).
- **Preset-aware updates** — `claude-base update --all` keeps the preset's skill filter applied, so a project bootstrapped with `--preset nextjs` no longer drifts back to the unfiltered foundation on every refresh. Override with `--preset <name>`, opt out with `--no-preset`. The filter is COPY-only — files already on disk are never deleted.
- **Curated vendor skill pointers** per preset, surfaced at install time via the recipe [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md) — 14 vendor skills validated across 4 marketplace audit pilots
- **One-liner install** via `curl | bash` + unified CLI dispatcher (`claude-base init/update/validate/preset/uninstall`)
- Built-in conventions enforced via path-specific rules: TDD (mandatory tests-first), security (OWASP defaults), accessibility (WCAG), performance (Core Web Vitals), deploy-safety
- Ready-to-use CI/CD workflows and pre-commit hooks, including a counts.json anti-drift gate
- PostToolUse output rewriter for noisy bash + inline tsc/eslint errors (Claude Code 2.1.121+)

## How it fits in the Claude Code ecosystem

claude-base is a **workflow foundation**, not a competing plugin marketplace. It curates a coherent rigor (Explore → Specify → Plan → TDD → Audit), wires hooks/rules/conventions, and orchestrates project setup via `new-project.sh`.

For deeper coverage of specific tools — vendor-published skills for Terraform, Postgres, Playwright, MongoDB, observability stacks, framework-specific patterns — the [official Claude Code marketplace](https://code.claude.com/docs/en/discover-plugins) and community-published skills often ship targeted depth that goes further than what this foundation bundles. That's expected: a foundation curates **breadth + workflow integration**, vendor skills curate **depth on a single tool or stack**.

**Recommended pattern**

```
claude-base (foundation)        ← Explore → TDD → Audit, anti-drift, qa-loop, hooks, rules
       +
vendor skills (specific tools)  ← Terraform, Postgres, Playwright, Grafana, Prisma, MongoDB, ...
```

claude-base's unique value (vs assembling vendor skills alone):

- Workflow rigor coordinated as one experience (TDD enforcement, autonomous `qa-loop` audit-fix cycle, score-90 gates)
- Anti-drift counter strategy across the entire foundation, CI-enforced via `counts.json`
- 30 path-specific rules (currently not a plugin component — see `docs/guides/EXTENDING-GUIDE.md` § 7)
- PostToolUse output rewriter for Bash + tsc/eslint (Claude Code 2.1.121+)
- Integrated install + update flow via the `claude-base` CLI (init, update, validate, preset, uninstall)

**Honest limit**: for any specific tool integration, there's likely a more specialized vendor skill that goes deeper. The recipe [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md) is the curated list of validated sources.

**Presets**: stack-specific presets (`nextjs`, `fastapi`, `astro`, `cli-tools`, `homelab-proxmox`) installable via `claude-base init --preset <name> <path>`. Each preset filters the foundation to the relevant skills + ships a curated `recommendedVendorSkills` list printed at the end of the install. Four of them also self-describe a `detect` block, so running `claude-base init <existing-project>` (or `claude-base update`) auto-recognises the stack and applies the right filter — without persisting any state on disk. See [`.claude/presets/README.md`](./.claude/presets/README.md) for the canonical catalogue and [`specs/presets/roadmap.md`](./specs/presets/roadmap.md) for community-wanted stacks. Stack-specific naming only — no `web-app` or `backend-app`. Contributions welcome for stacks not yet covered.

## Strategy & trajectory

claude-base's long-term position is **a foundation that lives alongside the official Claude Code marketplace, not in opposition to it**. The kit's irreducible value is the workflow rigor (TDD, audit-loop, anti-drift), the path-specific rules, and the foundation conventions. Everything else — domain-specific knowledge — is increasingly available as vendor-published skills/plugins.

Three mechanisms keep the foundation aligned with that trajectory:

1. **Periodic marketplace audits**. The maintainer evaluates community and vendor-published skills against the foundation, applies a vendor-neutrality filter (we reject vendors acquired by direct Anthropic competitors — e.g. Astral acquired by OpenAI in March 2026), and documents the verdict per skill. The user-facing output is the recipe [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md).
2. **Recommended vendor skills per preset**. Each preset ships a `recommendedVendorSkills` array — a curated list printed at the end of `claude-base init`, telling the user which validated vendor skills complement their stack. Manual install today; the foundation does NOT auto-install third-party code.
3. **Trajectory-driven automation**. As more vendors migrate to the official Claude Code marketplace, the install mechanism becomes uniform (`claude plugin install <id>`) and Anthropic-vetted. At that point, automating the install of recommended vendor skills becomes safe — the supply-chain risk is no longer "git clone arbitrary URL" but "install Anthropic-reviewed plugin." We do not automate today (~21% of audited vendors are on the official marketplace) but we will revisit when the ratio inverts.

The recipe is the canonical, user-facing index of every validated source, with install commands, vendor-neutrality status, and explicit re-evaluation triggers.

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

# Install in an existing project
./scripts/new-project.sh --simple /path/to/your/project

# Or via the dispatcher (same result)
./bin/claude-base init --simple /path/to/your/project

# Full install with CI/CD, hooks, Docker
./scripts/new-project.sh --all /path/to/your/project
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

## Structure

```
claude-base/
├── CLAUDE.md                    # Main project instructions
├── CLAUDE.local.md.example      # Local config template
├── README.md                    # This file
├── .gitignore
│
├── .claude/
│   ├── settings.json            # Permissions and hooks
│   ├── skills/                  # <!-- count:skills -->54<!-- /count --> specialized skills
│   └── commands/                # <!-- count:commands -->131<!-- /count --> available commands
│       ├── assistant.md         # Main orchestrator
│       ├── work/                # Workflow (15 commands)
│       │   ├── work-explore.md
│       │   ├── work-plan.md
│       │   ├── work-commit.md
│       │   ├── work-pr.md
│       │   └── ...
│       ├── dev/                 # Development (23 commands)
│       │   ├── dev-tdd.md
│       │   ├── dev-api.md
│       │   └── ...
│       ├── qa/                  # Quality (16 commands)
│       │   ├── qa-review.md
│       │   ├── qa-security.md
│       │   └── ...
│       ├── ops/                 # Operations (34 commands)
│       ├── doc/                 # Documentation (9 commands)
│       ├── biz/                 # Business (11 commands)
│       ├── growth/              # Growth (11 commands)
│       ├── data/                # Data (3 commands)
│       └── legal/               # Legal (5 commands)
│
├── .mcp.json                    # MCP configuration
│
├── .github/workflows/           # GitHub Actions CI/CD
│   ├── ci.yml                   # Tests, lint, build
│   ├── pr-check.yml             # PR validation
│   └── release.yml              # Automated releases
│
├── .husky/                      # Git hooks
│   ├── pre-commit
│   └── commit-msg
├── .pre-commit-config.yaml      # Pre-commit config
├── .lintstagedrc.json           # lint-staged config
├── .commitlintrc.json           # commitlint config
│
├── tests/                       # <!-- count:tests -->536<!-- /count --> automated tests (bats)
│   ├── test_helper.bash         # Shared helpers
│   ├── new-project.bats         # Install script tests
│   ├── update.bats              # Update script tests
│   ├── validate.bats            # Validation tests
│   ├── docs-under-claude.bats   # v1.30 layout tests
│   └── ...                      # <!-- count:testFiles -->26<!-- /count --> test files in total
│
├── .gitleaks.toml               # gitleaks config (secret detection)
├── VERSION                      # Centralized foundation version (1.30.0)
│
├── scripts/                     # Utility scripts
│   ├── new-project.sh           # Create / install (modes --simple, --all)
│   ├── update.sh                # Update
│   ├── validate.sh              # Validation
│   ├── uninstall.sh             # Uninstall
│   ├── doctor.sh                # Diagnostic
│   ├── diff.sh                  # Diff against the foundation
│   ├── hooks/                   # Hook scripts referenced by settings.json
│   └── lib/common.sh            # Shared library
│
├── templates/                   # 11 CLAUDE.*.md templates by stack
│   ├── CLAUDE.react.md          # React
│   ├── CLAUDE.nextjs.md         # Next.js (App Router)
│   ├── CLAUDE.vue.md            # Vue.js 3
│   ├── CLAUDE.node-api.md       # Node.js API
│   ├── CLAUDE.python.md         # Python
│   ├── CLAUDE.go.md             # Go
│   ├── CLAUDE.rust.md           # Rust
│   ├── CLAUDE.java.md           # Java / Spring Boot
│   ├── CLAUDE.fullstack.md      # Fullstack monorepo
│   ├── CLAUDE.flutter.md        # Flutter / Dart (Mobile)
│   └── CLAUDE.neovim.md         # Neovim / Lua config
│
└── docs/                        # Documentation (English)
    ├── QUICKSTART.md            # 5-minute getting started
    ├── CHEATSHEET.md            # Command quick reference
    ├── ARCHITECTURE.md          # Commands vs Agents vs Skills vs Rules
    ├── WORKFLOWS.md             # Workflow diagrams
    ├── STACK-RECIPES.md         # Commands/agents/skills per stack
    ├── CUSTOMIZATION.md         # Customization guide
    ├── reference/               # Reference docs (best-practices, hooks…)
    └── guides/                  # 4 specific guides
        ├── EXTENDING-GUIDE.md   # Extend the foundation
        ├── TEAM-GUIDE.md        # Team adoption
        ├── PROMPTING-GUIDE.md   # Prompting techniques
        └── TROUBLESHOOTING-GUIDE.md
```

## Available Commands (<!-- count:commands -->131<!-- /count -->)

Commands are grouped into 9 domains:

| Domain | Count | Examples |
|---------|------:|----------|
| `work-` | 15 | `/work:work-explore`, `/work:work-plan`, `/work:work-commit`, `/work:work-pr`, `/work:work-flow-feature` |
| `dev-` | 23 | `/dev:dev-tdd`, `/dev:dev-debug`, `/dev:dev-api`, `/dev:dev-flutter`, `/dev:dev-prisma` |
| `qa-` | 16 | `/qa:qa-loop`, `/qa:qa-security`, `/qa:qa-perf`, `/qa:wcag-audit`, `/qa:qa-e2e` |
| `ops-` | 34 | `/ops:ops-deploy`, `/ops:ops-docker`, `/ops:ops-monitoring`, `/ops:ops-k8s`, `/ops:ops-rollback` |
| `doc-` | 9 | `/doc:doc-onboard`, `/doc:doc-explain`, `/doc:doc-changelog`, `/doc:doc-architecture` |
| `biz-` | 11 | `/biz:biz-model`, `/biz:biz-mvp`, `/biz:biz-pricing`, `/biz:biz-personas` |
| `growth-` | 11 | `/growth:growth-landing`, `/growth:growth-seo`, `/growth:growth-cro`, `/growth:growth-funnel` |
| `data-` | 3 | `/data:data-pipeline`, `/data:data-modeling`, `/data:data-analytics` |
| `legal-` | 5 | `/legal:legal-rgpd`, `/legal:legal-terms-of-service`, `/legal:legal-privacy-policy` |

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

## Available Templates (11)

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

## Utility Scripts

```bash
# Create a new project (interactive)
./scripts/new-project.sh

# Install in an existing project
./scripts/new-project.sh --simple /path/to/project

# Update commands
./scripts/update.sh /path/to/project

# Validate the configuration
./scripts/validate.sh /path/to/project
./scripts/validate.sh --json /path/to/project   # for CI/CD

# Full diagnostic
./scripts/doctor.sh /path/to/project

# Diff against the foundation
./scripts/diff.sh /path/to/project

# Uninstall
./scripts/uninstall.sh /path/to/project

# IDE integration (VSCode, IntelliJ, Vim/Neovim)
./scripts/ide.sh setup vscode
```

## Getting started in Claude Code

Once installed, the fastest way to learn the workflow is the built-in orchestrator:

```
/assistant              # guided mode: explains and suggests commands
/assistant-auto "..."   # automatic mode: routes to the right workflow

# Or follow the canonical 7-step workflow
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

- **ci.yml**: Tests, lint, build, security audit
- **pr-check.yml**: PR format / size / labels validation
- **release.yml**: Automated releases with changelog

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
- **[guides/TEAM-GUIDE.md](docs/guides/TEAM-GUIDE.md)**: Team adoption

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

### Test layout (<!-- count:testFiles -->26<!-- /count --> files, <!-- count:tests -->536<!-- /count --> tests)

| File | Description |
|------|-------------|
| `smoke.bats` | Smoke tests (fast integrity check) |
| `common.bats` | Utility function tests |
| `new-project.bats` | Install script tests |
| `update.bats` | Update script tests |
| `docs-under-claude.bats` | v1.30 layout tests (`.claude/docs/`) |
| `validate.bats` | Validation script tests |
| `doctor.bats` | Diagnostic script tests |
| `gitleaks.bats` | gitleaks config tests |
| `qa-loop.bats` | Audit-fix loop workflow tests |
| `lint.bats` | Linting script tests |
| `e2e.bats` | End-to-end tests |
| `prompt-context.bats` | UserPromptSubmit hook tests |
| `presets.bats` | Preset manifest schema + suggestion + integration tests |
| `preset-detect.bats` | `scan_presets()` library unit tests (data-driven detection) |
| `preset-e2e.bats` | Per-preset end-to-end (bootstrap + validate + doctor + hook drift-guard) |
| `update-presets.bats` | Preset-aware update behaviour (`--preset`, `--no-preset`, filter, multi-match) |
| `menu.bats` | Interactive type-menu rendering when matched presets prepend |
| `manifest-hooks-coverage.bats` | Drift guard between source `settings.json` hooks and the minimal-install manifest |
| `diff.bats`, `ide.bats`, `learn.bats`, `uninstall.bats`, `test-runner.bats` | Tests for the related scripts |

## Migration & Breaking Changes

### Upgrading to v1.10.x

#### Breaking changes

| Change | Impact | Migration |
|--------|--------|-----------|
| `install.sh` removed | Installation scripts | Use `new-project.sh --simple` |
| Agents YAML structure | Agent files | Re-copy from the foundation |

#### New features

- **Agent `dev-tdd`**: TDD development with the Red-Green-Refactor cycle
- **Commands**: `/dev:dev-ai-integration`, `/growth:growth-localization`, `/qa:qa-tech-debt`
- **Generic permissions**: wildcards for npm, git, docker, terraform, etc.

#### Migration guide

```bash
# 1. Back up your customizations
cp CLAUDE.md CLAUDE.md.backup
cp .claude/settings.local.json .claude/settings.local.json.backup

# 2. Update the foundation
cd /path/to/claude-base
git pull origin main

# 3. Reinstall (overwrites existing files)
./scripts/new-project.sh --simple /path/to/your/project

# 4. Restore your customizations
# Manually merge CLAUDE.md.backup into the new CLAUDE.md
```

### Versioning policy

| Version | Support | Notes |
|---------|---------|-------|
| 1.30.x | Current | Stable release (docs relocated to `.claude/docs/`) |
| 1.29.x | Supported | Security fixes |
| 1.28.x | Supported | Security fixes |
| < 1.28 | Unsupported | Update recommended |

### Changelog

See [CHANGELOG.md](CHANGELOG.md) for the full history of changes.

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

- **Gitleaks**: 24+ secret detection rules (CI workflow + local scan)
- **ShellCheck**: bash linting on all `scripts/` (CI workflow `security.yml`, severity warning)
- **Deny list**: dangerous commands blocked (`rm -rf /`, `sudo`, `git push --force`)
- **Protection hooks**: blocks edits on main/master
- **GitHub Secret Scanning**: enabled on the public repo
- **GitHub Code Scanning** (CodeQL): TypeScript security analysis (Default Setup, scans `website/scripts/`, `website/src/`)

See [SECURITY.md](SECURITY.md) for the full security policy.
