# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

> **Language note**: from v1.31.0 onwards, all entries are in English.
> Earlier entries (v1.30.x and before) remain in their original French
> as a historical record of the project's pre-i18n era.

## [Unreleased]

### Changed

- **Project renamed `claude-socle` → `claude-base`** for English-language
  consistency with the rest of the codebase (the FR→EN migration in v1.31.0
  left the project name as the only French-coded element). The new name is
  shorter, EN-native, and matches the vocabulary already used throughout the
  documentation. The GitHub repo is renamed at the same time
  (`christopherlouet/claude-socle` → `christopherlouet/claude-base`); old
  URLs continue to redirect via GitHub's automatic 301. Internal renames:
  `SOCLE_DIR` → `BASE_DIR` (bash), `SKIP_SOCLE_INTEGRITY` → `SKIP_BASE_INTEGRITY`
  (env var), `SOCLE_STATS` → `BASE_STATS` (TypeScript constant), files
  `socle-maintenance.md` → `base-maintenance.md`,
  `socle-integrity-check.sh` → `base-integrity-check.sh`,
  `audit-socle.sh` → `audit-base.sh`. Historical CHANGELOG entries
  (v1.32.0 and earlier) keep their original `claude-socle` references —
  those releases were genuinely shipped under the old name.

## [1.33.0] - 2026-05-05

Maintenance and ecosystem release: a 4th maintainer-vouched preset
(`fastapi`), the first marketplace plugin audit pilot under the
methodology in `specs/marketplace-audit/spec.md`, a recipe documenting
three Python toolchain paths, and a new `update.sh --add-plugin` helper
that closes the friction gap for users opting into marketplace plugins.

### Added

- **`update.sh --add-plugin <id>` flag**: idempotent helper that adds
  an entry to `enabledPlugins` in a project's `.claude/settings.json`
  without overwriting other keys. Mirrors the existing `--add-hook`
  pattern. Useful when a user wants to opt into a marketplace plugin
  (e.g. `astral@astral-sh`) and avoid losing the entry if a later
  `update.sh --settings` overwrites the file. 8 bats tests cover the
  helper (idempotent re-run, `--dry-run`, missing settings.json,
  preservation of existing keys).
- **Marketplace plugin audit pilot — `cli-tools` preset**: first audit
  conducted under the methodology in `specs/marketplace-audit/spec.md`,
  using `gh search code` to cross-reference plugin adoption across real-product
  repos (filtering out dotfiles, templates, config kits, portfolios). Four
  candidates evaluated: `pyright-lsp@claude-plugins-official` (rejected —
  active LSP infrastructure bugs), `greptile@claude-plugins-official`
  (rejected — recurrent OAuth bugs), `commit-commands@claude-plugins-official`
  (rejected — overlaps with foundation `/work:work-commit`), and
  `astral@astral-sh` (rejected on positioning grounds). The Astral
  toolchain plugin had strong technical and adoption signal (13+ qualifying
  real-product repos) but was rejected because Astral was acquired by
  OpenAI on 2026-03-19; bundling OpenAI-acquired tooling in an
  Anthropic-ecosystem kit would publish a dissonant signal. Outcome:
  `cli-tools.json` `marketplacePlugins` stays `[]`. Full trace in
  `specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`.
- **Recipe: `docs/recipes/python-toolchain-options.md`**: documents
  three paths for picking a Python toolchain inside `cli-tools` or
  `fastapi` projects — Astral (perf-first, OpenAI-adjacent),
  vendor-neutral (pdm/poetry + flake8/black + mypy), or PyPA defaults
  (pip + venv + flake8 + mypy). Includes opt-in instructions for the
  `astral@astral-sh` plugin and a decision matrix. Aligned with the
  established "stack-essential agnostic, recipes = product opinion"
  doctrine.
- **Fourth preset: `fastapi`** — FastAPI + Pydantic + SQLAlchemy/async ORM
  for developers building HTTP APIs, LLM-backed services, or async data
  ingestion endpoints in Python. Filters out 12 non-applicable skills
  (frontend stacks, mobile, homelab-specific ops, browser-bound QA).
  Keeps `dev-api`, `dev-auth`, `dev-graphql`, `dev-prompt-engineering`
  (LLM API backends), `dev-supabase`, `ops-database`, `ops-docker`,
  `ops-monitoring`, `qa-perf`, `qa-security`. Bundles ZERO marketplace
  plugins at v1 — Python-specific plugin curation will be added
  incrementally as validated. Default `docker: true` (containerised
  deployment is the dominant pattern), `designStyle: editorial`.
  See `.claude/presets/fastapi.json`. With this PR, the maintainer-vouched
  preset catalogue grows to 4: nextjs, homelab-proxmox, cli-tools, fastapi.

## [1.32.0] - 2026-05-05

Headline release: PostToolUse output rewriter (Claude Code 2.1.121+),
preset system with 3 maintainer-vouched presets (nextjs, homelab-proxmox,
cli-tools), and a multi-OS CI matrix that brings macOS to first-class
support after a focused portability sweep.

### Added

- **Third preset: `cli-tools`** — Python or Shell automation tools,
  GitHub API helpers, headless-friendly scripts. Targets developers
  building CLI utilities, dependency analyzers, code-mod tooling, or
  ops automation that runs in CI/cron without a UI. Filters out 13
  app/UI/mobile/infra-heavy skills. Bundles ZERO marketplace plugins
  at v1. Default `designStyle: terminal` (matches headless CLI usage).
  See `.claude/presets/cli-tools.json`. With this PR, the 3
  maintainer-vouched presets in `specs/presets/roadmap.md` pipeline
  are all live.
- **Second preset: `homelab-proxmox`** — Proxmox VE + Terraform + Ansible
  + monitoring (Prometheus/Grafana). Targets sysadmins running
  infrastructure-as-code on a personal or small-team Proxmox cluster.
  Filters out 10 app/UI/mobile-only skills (`dev-flutter`, `dev-shadcn`,
  `dev-nextjs`, `dev-react-perf`, `dev-frontend-design`,
  `ops-mobile-release`, `growth-cro`, `qa-chrome`, `qa-responsive`,
  `qa-design`). Bundles ZERO marketplace plugins at v1 — Terraform-specific
  plugins will be added incrementally as validated. Default
  `designStyle: cockpit` (matches infra/ops aesthetic).
  See `.claude/presets/homelab-proxmox.json`.
- **First preset: `nextjs` + preset system mechanism**: `./scripts/new-project.sh --preset nextjs <path>`
  installs the foundation with stack-specific filters applied. The first concrete
  preset ships alongside the install mechanism (parsing, filtering, plugin install
  capability check). The `nextjs` preset is intentionally minimal at v1: it filters
  out 6 clearly-out-of-stack skills (Flutter, Proxmox, OPNsense, mobile-release,
  infra-code, data-pipeline) and bundles ZERO marketplace plugins. Plugins will
  be added incrementally in follow-up PRs as each one is validated in real
  production use, not assumed from name. See `.claude/presets/nextjs.json`,
  `.claude/presets/README.md`, `specs/presets/spec.md`.
- New `--list-presets` flag to discover available presets with their status tier.
- New `scripts/validate-presets.sh` — jq-based JSON schema check for preset
  manifests. Runs on each preset PR via the existing CI (called by `bash scripts/lint.sh`).
- New tests `tests/presets.bats` (16 tests) covering manifest validation, filter
  behavior on real install, capability fallback, and CLI flag composition.
- New recipe `docs/recipes/saas-monetization.md` — the first opt-in recipe
  documenting subscription/billing patterns for those who need them, kept
  deliberately separate from the `nextjs` preset (preset = stack essentials,
  recipe = product opinion).

### Added (output rewriter)

- **PostToolUse output rewriter (#116)**: three coordinated hooks that
  exploit the new `hookSpecificOutput.updatedToolOutput` envelope
  (Claude Code 2.1.121+) to tighten the feedback loop on foundation-equipped
  projects.
  - `bash-output-filter.sh` (PostToolUse Bash) trims noisy outputs of
    allowlisted package-manager / build / test commands
    (npm/pnpm/yarn/bun install/audit/test/build, pytest, go test/build,
    cargo build/test/check) to actionable lines only. Threshold guard
    skips outputs under 30 lines.
  - `post-edit-typecheck-and-lint.sh` (PostToolUse Edit|Write)
    consolidates the former two inline tsc + eslint blocks into a single
    script that **inlines** type/lint errors mentioning the just-edited
    file into the Edit/Write tool result envelope. Status stays SUCCESS;
    annotations are appended under delimited sections.
  - `check-cli-version.sh` (SessionStart) probes `claude --version` and
    sets a sentinel consumed by the two PostToolUse hooks. On older
    CLIs, prints one notice and falls back silently.
- 12 test fixtures under `tests/hook-output-rewriter/fixtures/`
  (6 Bash, 6 inline-edit) covering the 6 distinct extractor branches.
- 45 new bats tests (`tests/hook-output-rewriter.bats`).
- Hook env vars: `SKIP_BASH_OUTPUT_FILTER`, `SKIP_INLINE_EDIT_ERRORS`,
  `BASH_OUTPUT_FILTER_VERBOSE`, `BASH_OUTPUT_FILTER_THRESHOLD`.
- Metric log at `/tmp/claude-rewriter.log` (one line per rewrite).

### Added (CI / docs)

- **macOS-latest in the CI matrix (#122)**: Bats + ShellCheck + counts
  gate now run on macOS in addition to Ubuntu. The macOS column is
  marked `experimental: true` so portability regressions surface
  without blocking merges. After the portability sweep below, both
  columns pass green at v1.32.0.
- **Native plugin migration status (#117)**: `docs/guides/EXTENDING-GUIDE.md`
  now documents which parts of the foundation could move to native
  Claude Code plugins (CLI 2.1.121+) and the three structural gaps
  that currently block a full port (rules not a plugin component,
  `settings.json` plugin scope, no setup callback). The foundation
  stays standalone; revisit when 2/3 gaps land.

### Fixed (macOS / BSD portability)

A focused sweep so every script works identically on Ubuntu (GNU coreutils)
and macOS (BSD coreutils). Each fix is small in isolation but together
they unblock first-class macOS support.

- `date +%s%N` (GNU-only nanoseconds) replaced with a portable
  `now_ms` helper that prefers `python3`, falls back to `gdate`,
  then `date`, then second-resolution as a last resort (#125).
- `readlink -f` (GNU) replaced with a `realpath` fallback chain
  in `scripts/export-minimal.sh` (#126).
- `sed -i` invocations made portable across BSD (`-i ''`) and GNU
  (`-i`) via a small wrapper in `scripts/lib/common.sh` (#127).
- `grep -P` (Perl regex, GNU-only) replaced with `grep -oE` (POSIX
  ERE) — same semantics for the patterns we use (#128).
- `#!/bin/bash` shebangs replaced with `#!/usr/bin/env bash` so
  Homebrew's bash 5+ is picked up on macOS (Apple ships bash 3.2,
  which lacks features we rely on) (#129).
- `seq 0 -1` guarded for BSD (which counts down) so empty preset
  marketplace plugin arrays don't loop (#129).
- `[[:space:]]` and `($|[^[:alnum:]_])` replace `\s` and `\b` in
  `scan_drift` patterns for BSD grep ERE compatibility (#129).
- `BSD wc -l` whitespace padding stripped via `tr -d '[:space:]'`
  in `validate-counts.sh` count assignments — the silent killer
  of literal string equality on macOS (#129).
- `scripts/new-project.sh --simple --dry-run` no longer exits 1 on
  bash 5+: the `find | wc | tr` pipeline under `set -e` + `pipefail`
  was killing the assignment when the directory didn't exist (#123).

### Changed

- `scripts/new-project.sh`: gains `--preset NAME` and `--list-presets` flags.
  `--preset` composes with existing `--type`, `--ci`, `--hooks`, `--mcp`,
  `--docker`, `--style` flags (preset's defaults apply only when the user
  did not pass the corresponding flag, so user choice always wins).
- `.claude/settings.json`: the two PostToolUse Edit|Write blocks
  "Type-check TypeScript" and "ESLint check" are removed and replaced
  by a single block calling `post-edit-typecheck-and-lint.sh`.
  Behavior parity is preserved when the new feature is disabled
  (`SKIP_INLINE_EDIT_ERRORS=1` falls back to legacy stdout side-messages).
- `scripts/update.sh`: the interactive prompt for `.claude/settings.json`
  now flags this release explicitly and warns when declining.
- `actions/setup-node` bumped from v4 to v6 in `.github/workflows/`
  (Dependabot, #115).

### Notes

- The preset format is **JSON** (not YAML as initially drafted in the planning
  spec). Pivot reason: the codebase has no YAML parser (`yq` is not a hard
  dependency) but `jq` is required by 4+ existing hooks, `update.sh`, and
  `validate-counts.sh`. JSON + jq is consistent with `settings.json`,
  `.mcp.json`, `counts.json`. The choice is documented in `specs/presets/spec.md` § "JSON schema".

### Migration

- **Existing projects**: run `./scripts/update.sh -f --all <project>` to
  get the new hooks coherently. Partial updates
  (e.g. `--hook-scripts` without `--settings`) are detected at runtime
  by `post-edit-typecheck-and-lint.sh` and trigger a one-line notice
  once per session pointing to the correct command.
- **Older CLIs (< 2.1.121)**: the SessionStart probe emits a single
  visible notice on session start and the rewriter hooks remain
  inactive. No upgrade is forced; sessions work as before.

---

## [1.31.2] - 2026-05-03

Maintenance release: anti-drift counter infrastructure now permanent
(counts.json + CI gate), MDX escape pipeline rewritten to fix visible
`&lt;` / `&gt;` text in rendered docs, Welcome page hero counter drift
fixed.

### Added

- **Single source of truth for counters (#110)**: new `counts.json` at
  the repo root, generated by `website/scripts/generate-counts.ts` from
  filesystem scans. Schema covers commands, agents, skills, rules, tests,
  testFiles and per-domain command subtotals (work/dev/qa/ops/...).
- **CI gate against counter drift (#110)**: `.github/workflows/ci.yml`
  runs `npm --prefix website run generate && git diff --exit-code` on
  every PR. Adding/removing a `.claude/{commands,agents,skills,rules}/`
  file without re-running the generator now fails CI.
- **Markdown count markers (#110)**: 18 instrumented `.md` files use
  `<!-- count:KEY -->NNN<!-- /count -->` markers updated by a new
  `inject-counts-md.ts` step. The shields.io tests badge in `README.md`
  is also auto-rewritten.
- **`escape-mdx-content.ts` shared helper (#111)** with 14 unit tests
  via `node:test`/`tsx`. Replaces 3 duplicated copies of the
  fenced-only escape function.

### Fixed

- **Welcome page hero counter drift (#109)**: `Stats.tsx` had been
  showing 123/59/42/24 for multiple versions while the real counts are
  131/63/54/30. `validate-counts.sh` did not include the file.
- **Same drift in `what-is-claude-code.md` (#110)**: the 4-row component
  table said 126/62/44/25. All four cells fixed and instrumented.
- **MDX escape leaking into inline code spans (#111)**:
  `` `<arguments>` `` was being HTML-encoded to `` `&lt;arguments&gt;` ``
  in 158 generated files. Cause: the regex only skipped fenced code
  blocks, not inline backticks.
- **Markdown blockquotes broken by over-escaped `>` (#111)**: every
  `> quoted text` line in `PROMPTING-GUIDE`, `TEAM-GUIDE`,
  `EXTENDING-GUIDE` and rules descriptions rendered as plain
  paragraphs starting with `&gt;`. `escapeMdx` now only escapes what
  is genuinely JSX-dangerous (`{`, `}`, `<`).
- **Pre-encoded HTML entities double-escaped**: `&lt;` was becoming
  `&amp;lt;` (rendered literally). Dropped the `&` escape from
  `escapeMdx`.

### Changed

- **Workflow phrasing aligned on canonical 6-step (#110)**: 4 work
  commands (`work-explore`, `work-plan`, `work-commit`, `work-specify`),
  `.claude/rules/workflow.md` (full restructure with new
  `### 2. SPECIFY` section, renumbered 3-6), `.claude/rules/README.md`
  and 2 tutorials now reflect Explore → (Brainstorm) → Specify → Plan
  → TDD → Audit → Commit.
- **`sync-docs.ts` now preserves count markers and inline-code regions**
  when copying `docs/` → `website/docs/`.
- **CI workflow stale "Bats: 258 tests" string** replaced with
  "see job logs for the test count" (no maintenance needed).
- **Validate-counts.sh pruned of redundant Layer 1 checks** (-69 lines)
  now covered by the CI gate. Layer 2 narrative scan extended with
  two new patterns (`Label (N available)`, multi-column table cell).
- **GitHub repo description updated** to `130+/60+/50+` fuzzy form +
  homepage URL added pointing to the Docusaurus site.

---

## [1.31.1] - 2026-05-03

Hardening release: 5 CodeQL alerts closed, Docusaurus URLs cleaned up,
canonical 6-step workflow now reflected in onboarding pages and tutorials.

### Fixed

- **Documentation cohesion (#107)**: 6 onboarding/tutorial pages still showed the legacy 4-step workflow (Explore → Plan → Code → Commit). They now reflect the canonical 6-step workflow documented in `CLAUDE.md`: Explore → **Specify** → Plan → TDD → **Audit** → Commit. Pages updated: `intro/quick-start.md`, `workflow/explore-plan-code-commit.md`, `guides/migration.md`, `tutorials/01-first-project.md`, `tutorials/02-feature-react.md`, `tutorials/03-api-rest-node.md`. Promoted `qa-review` / `qa-security` references to the canonical `qa-loop "score 90"`.
- 6 auto-regenerated MDX-escape touch-ups in `website/docs/{commands,concepts,reference,rules}/` produced by `website/scripts/generate-*.ts` after the `escapeMdx` fix.

### Changed

- **3 French-named tutorial files renamed to English (#107)**: leftover from the FR→EN migration shipped in v1.31.0. `01-premier-projet.md` → `01-first-project.md`, `05-audit-securite.md` → `05-security-audit.md`, `10-projet-complet.md` → `10-complete-project.md`. Old URLs (`/docs/tutorials/premier-projet`, etc.) preserved via a new `@docusaurus/plugin-client-redirects` configuration — no broken external links.
- **CI workflow rename (#105)**: `.github/workflows/codeql.yml` → `security.yml`. The file ran ShellCheck + Gitleaks but never CodeQL (Default Setup runs separately). Filename now matches what the workflow does. README badge URL updated.

### Security

- **5 CodeQL alerts closed (#106)**:
  - **HIGH (3)** in `website/scripts/utils/parse-frontmatter.ts`:
    - `escapeMdx()` was missing `&` and `\` escaping. An input like `&lt;script&gt;` would survive untouched and render as `<script>` in MDX, enabling XSS via frontmatter-injected content. Fixed escape order: `&` → `\\` → `\{}` → `<>` so already-encoded entities stay literal and braces don't get ambiguous backslashes.
    - `serializeFrontmatter()` did not escape `\` before `"`. Input `foo\bar` produced invalid YAML; input `"; key: x` could break out of the quoted scalar.
  - **MEDIUM (2)** in `.github/workflows/{ci,pr-check}.yml`: missing explicit `permissions:` block, jobs ran with the default `GITHUB_TOKEN` scope (read+write across contents/issues/PRs). Added least-privilege blocks (`contents: read` on `ci.yml`, `contents: read` + `pull-requests: read` on `pr-check.yml`).
- **GitHub CodeQL Default Setup enabled** for TypeScript files in `website/`. Documented in README "Security measures" section.

---

## [1.31.0] - 2026-05-03

### Added

#### Migration FR→EN (2026-04-30 → 2026-05-03)
- **Full repository localization to English**: 537 files translated across 8 sequential tiers (~285k words). The project's primary language is now English, opening the door to international contributors.
- Tier breakdown: Tier 1 (44 showcase + rules), Tier 2 (194 agents + commands), Tier 3 (96 skills + hooks), Tier 4 (77 website Docusaurus), Tier 5 (51 user templates + Terraform + missed markdown), Tier 6 (49 scripts + tests + CI + ROOT misc), Tier 7 (13 final missed), Tier 8 (13 settings.json + Docusaurus generators).
- 29 auto-generated docs in `website/docs/{commands,agents,skills,rules}/` regenerated in EN via `npm run generate`.
- 7 files intentionally remain bilingual: `scripts/hooks/prompt-context.sh` (FR/EN feedback detection), `scripts/update.sh` (legacy FR section detection in user CLAUDE.md cleanup), 5 `.bats` tests with bilingual output assertions.
- CHANGELOG: header in EN with transition note; entries before v1.31.0 preserved in original FR as project history.

#### Sync Claude Code March-April 2026
- **Monitor Tool docs** (CLI 2.1.98+): new section in `docs/reference/advanced-features.md` describing the native tool that streams background events into the conversation. Use cases: tail logs, babysit CI, watch dev server. Recommended pairing with `/loop` auto-pace.
- **`/autofix-pr` docs** (CLI 2.1.92+): dedicated section in `advanced-features.md` + entry in the Recommended Workflows table of `CLAUDE.md`. Enables PR auto-fix on Claude Code Web from the terminal for the current branch.
- **March-April 2026 regression note** in `TROUBLESHOOTING-GUIDE.md`: default `medium` effort + broken thinking caching + 25-word system prompt, resolved in v2.1.101 on April 10.

### Fixed

- **`scripts/update.sh` finally syncs `scripts/hooks/`**: the scripts referenced by `settings.json` (`command-validator.sh`, `prompt-context.sh`, `setup-deps.sh`, `socle-integrity-check.sh`) were previously missing after `update.sh --all` because the sync function ignored this directory. Result: `settings.json` pointed to non-existent scripts and the SessionStart/PreToolUse hooks failed silently. New `--hook-scripts` flag (included in `--all`), with idempotency, preservation of customizations and automatic `chmod +x`.
- README test layout counter: 23 files → 17 files (post-extraction of `tests/migration/`).

### Removed

- **`scripts/themes/`**: 25 files of out-of-mission terminal aliases (eza/ls colored aliases, gnome-terminal/starship installers). Preserved in git history if needed: `git log --all -- scripts/themes/`.
- **`scripts/migration/`, `tests/migration/`, `specs/migration-fr-en/`, `docs/guides/MIGRATION-GUIDE.md`**: the FR→EN translation harness extracted to a standalone repository: [christopherlouet/claude-i18n-migration](https://github.com/christopherlouet/claude-i18n-migration). Battle-tested on this very migration, with multi-language roadmap (v1.0 FR→EN → v3.0 multi-target parallel).

---

## [1.30.0] - 2026-04-28

### **BREAKING CHANGE — relocalisation de la doc socle vers `.claude/docs/`**

Avant cette version, `new-project.sh --simple` et `update.sh --upgrade-claude-md` copiaient la documentation du socle (`docs/reference/`, `docs/guides/`, `docs/ARCHITECTURE.md`, `docs/WORKFLOWS.md`) directement dans le dossier `docs/` du projet utilisateur. Cela posait deux problemes :

1. **Collisions** : tout projet ayant son propre `docs/ARCHITECTURE.md` (ex : un projet d'infra avec un schema Mermaid) le voyait ecrase pendant l'install/update.
2. **Pollution** : la doc du socle se melangeait a la doc du projet, sans marqueur clair de propriete.

A partir de v1.30.0, la doc socle est installee sous `.claude/docs/` (territoire du socle), et le `docs/` du projet utilisateur n'est plus jamais touche.

#### Modifie

- `new-project.sh --simple` et `--minimal` placent desormais la doc socle sous `.claude/docs/reference/` et `.claude/docs/guides/`. Le dossier `docs/` du projet n'est plus cree ni modifie.
- `new-project.sh` ne copie plus `docs/ARCHITECTURE.md` ni `docs/WORKFLOWS.md` (meta-docs sur le socle, accessibles via le repo GitHub et le website Docusaurus).
- `update.sh` detecte automatiquement les installs legacy (`docs/reference/` + `@docs/reference/...` dans `CLAUDE.md`) et les migre vers `.claude/docs/`. Les guides modifies localement par l'utilisateur sont preserves. Backup `CLAUDE.md.backup.*` cree avant migration.
- `update.sh --upgrade-claude-md` reecrit les `@imports` de `@docs/reference/...` vers `@.claude/docs/reference/...` et ecrit toujours sous `.claude/docs/`.
- `CLAUDE.md` genere pour les utilisateurs : `@imports` et tables de reference pointent desormais vers `.claude/docs/...`.
- `scripts/lib/minimal-claude-md.template` et `scripts/lib/minimal-manifest.txt` alignes sur le nouveau layout.
- Helper `rewrite_claude_md_paths()` ajoute a `scripts/lib/common.sh` (DRY entre `new-project.sh` et `update.sh`).

#### Migration

**Automatique** : `./scripts/update.sh --upgrade-claude-md /chemin/vers/projet` migre l'install legacy vers le nouveau layout. Idempotent : executable plusieurs fois sans casser.

**Manuelle** : la procedure pas-a-pas detaillee n'est plus distribuee dans le repo (le guide `MIGRATION-v1.30.md` a ete retire avant la release publique). Si vous avez besoin du diff exact, consultez les notes de la release v1.30.0 sur GitHub ou l'historique de ce CHANGELOG.

#### Precisions techniques

- Le **repo socle** (ce repo) conserve `docs/` comme source de verite — coherent avec le website Docusaurus et la doc historique (`CHEATSHEET.md`, `GUIDE.md`, etc.). La migration ne concerne que les **projets utilisateurs**.
- La rule `socle-maintenance.md` n'est pas modifiee : ses chemins `docs/reference/...` parlent du repo socle, pas des projets utilisateurs.

---

## [1.29.0] - 2026-04-20

### Ajoute

#### Nouveaux skills (47 → 53)
- **Skill `dev-prisma`** : Prisma ORM (schema, migrations dev/prod, queries type-safe, transactions, N+1 detection, cursor pagination, Accelerate cache, singleton HMR-safe). Complete l'agent `dev-prisma` existant par un skill proactif auto-declenche sur `schema.prisma` (#77)
- **Skill `dev-i18n`** : internationalisation web et mobile (next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations ARB). Pluriels ICU, format date/nombre, extraction strings, RTL, SEO multi-langue. Gap majeur : aucune couverture i18n auparavant (#77)
- **Skill `dev-frontend-design`** : design UI distinctif avec direction artistique forte. Bannit les fonts overused (Inter, Roboto, Arial, Space Grotesk) et force un choix de direction (terminal, cockpit, vitality, editorial, glass, signal) avant de coder. Inspire du skill Anthropic #1 (305K installs sur skills.sh)
- **Skill `dev-shadcn`** : integration et customisation de shadcn/ui (composants Radix + Tailwind copy-paste). Install, theming via CSS variables, dark mode, patterns de customisation, pieges courants (cn, FormField, DialogTitle)
- **Skill `dev-nextjs`** : developpement Next.js App Router (Server Components, Server Actions, Route Handlers, caching, streaming, middleware, Metadata API). Complete la rule passive `nextjs` par un skill proactif
- **Skill `dev-auth`** : implementation auth web moderne (better-auth, Lucia v3, NextAuth/Auth.js, Clerk, Supabase Auth). Sessions cookie vs JWT, password hashing argon2id, OAuth, 2FA, RBAC/ABAC, pieges de securite OWASP

#### Nouvelles rules (26 → 29)
- **Rule `vue.md`** : Composition API (`<script setup>`), composables avec prefixe `use`, Pinia pour state management (Vuex deprecated), Nuxt 3+ (`useFetch`, `useState`, `navigateTo`, `server/api/`), anti-patterns (Options API, `watch` pour derivations, Vuex) (#80)
- **Rule `svelte.md`** : Svelte 5 runes (`$state`, `$derived`, `$effect`, `$props`), table de migration Svelte 4 → 5, SvelteKit (`+page.server.ts`, form actions, load functions), callback props > `createEventDispatcher`, `{@render children?.()}` > `<slot />` (#80)
- **Rule `astro.md`** : Islands Architecture (zero JS par defaut), client directives (`client:visible` par defaut), Content Collections avec validation Zod type-safe, modes rendering (static / hybrid / server), View Transitions (Astro 3+) (#80)

#### Nouveaux hooks (14 → 17 events configures)
- **Hook `PermissionDenied`** (CLI 2.1.111+) : log les permissions refusees par l'auto mode classifier dans `/tmp/claude-permissions.log`. Utile pour tuner les allowlists avec `/less-permission-prompts` (#79)
- **Hook `UserPromptSubmit`** : log les timestamps de submission de prompt dans `/tmp/claude-prompts.log`. Fondation pour un futur `/socle:stats` (#79)
- **Hook `PostToolUseFailure`** : log les echecs d'outils avec leur nom dans `/tmp/claude-failures.log`. Complete `PostToolUse` pour une observabilite complete des tool calls (#79)

#### Happy Path par defaut (routing semantique) (#83)
- **Hook `prompt-context.sh`** (`scripts/hooks/`) : injecte automatiquement branche, fichiers modifies, LOC diff, memoire perso et hint `/assistant-auto` pour chaque prompt libre sans slash command. Desactivable avec `SKIP_PROMPT_CONTEXT=1`
- **Rewrite `assistant-auto`** : passe d'un mapping lexical de 112 lignes (table de 80 lignes a maintenir) a 78 lignes en routing semantique a partir de l'intention + du contexte injecte. Regles de priorite explicites (securite > memoire > taille > specifique)
- **Section "Happy Path par Defaut"** dans `CLAUDE.md` + mise a jour `docs/reference/hooks-reference.md`
- **12 bats tests** pour `prompt-context.sh` (contrat de sortie, contenu, robustesse hors repo git)

#### Tooling
- **`scripts/audit-socle.sh`** : audit de la sante du socle (frontmatter skills/agents, rules registration dans README, liens doc relatifs, counts via `validate-counts.sh`) (#81)
- **Template `CLAUDE.nextjs.md`** : dedie Next.js App Router (Server Components, Server Actions, data fetching Next 15+, Route Handlers, stack 2026 Prisma/better-auth/shadcn/next-intl/Zod). Distinct du generique `CLAUDE.react.md` (#81)
- **Workflow `dependabot-auto-merge`** : auto-merge des patches de securite et minor GitHub Actions, comment sur les major updates

#### Sync Claude Code 2.1.109 → 2.1.114 (#85)
- **3 hook events documentes** dans `docs/reference/hooks-reference.md` : `StopFailure` (CLI 2.1.78+, turn termine sur erreur API), `TaskCreated` (CLI 2.1.84+), `WorktreeCreate` (CLI 2.1.84+, hook `http` retournant `worktreePath`)
- **Settings avances** : `sandbox.network.deniedDomains` (2.1.113), `sandbox.failIfUnavailable` (2.1.83), `modelOverrides` (2.1.84, ARNs Bedrock custom), `autoScrollEnabled` (2.1.110), `showThinkingSummaries` (defaut `false` desormais), `disableDeepLinkRegistration` (2.1.83), `feedbackSurveyRate` (2.1.76), `forceRemoteSettingsRefresh` (policy), theme `"Auto (match terminal)"` (2.1.111)
- **Variables d'environnement** : `CLAUDE_CODE_USE_POWERSHELL_TOOL` (2.1.111), `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` (2.1.108), `CLAUDE_CODE_PERFORCE_MODE` (2.1.98), `CLAUDE_STREAM_IDLE_TIMEOUT_MS` (2.1.84), `OTEL_LOG_RAW_API_BODIES` (2.1.113)
- **MCP evolutions** : OAuth RFC 9728 Protected Resource Metadata (2.1.85), step-up authorization via `403 insufficient_scope` (2.1.84), override `_meta["anthropic/maxResultSizeChars"]` jusqu'a 500K (2.1.84)
- **Fiabilite subagents** (2.1.113+) : hang > 10 min echoue avec erreur claire, worktrees isoles avec Read/Edit sur leur propre worktree, fix crash dialog permission teammate (2.1.114)
- **`/loop` Esc** annule les wakeups en attente (2.1.113)
- **Guide d'extension** : note sur l'unification `.claude/skills/` ↔ `.claude/commands/` (skills recommandes pour nouveaux workflows)

### Modifie
- **Compteur skills** : 47 → 53 dans `docs/reference/skills-catalog.md`
- **Compteur rules** : 26 → 29 dans `.claude/rules/README.md`
- **Compteur hooks events** : 14 → 17 events configures dans `.claude/settings.json`
- **Docusaurus** : upgrade 3.9.2 → 3.10.0 avec override `serialize-javascript@^7.0.5` (#76)
- **Refactor `ops-proxmox/SKILL.md`** : 650 → 215 lignes + 4 references (`terraform-modules.md` 303L, `cloud-init.md` 65L, `backup-ha.md` 85L, `troubleshooting.md` 151L). Pattern identique a `ops-infra-code` (#82)
- **`generate-skill-docs.ts`** : reecriture des liens `references/*.md` en URLs GitHub absolues pour le build Docusaurus (#82)
- **`docs/guides/TROUBLESHOOTING-GUIDE.md`** : 3 entrees ajoutees (migration CLI binaire natif 2.1.113, subagent hang > 10 min, crash dialog permission teammate)

### Corrige
- **`command-validator.sh`** : utilise `CLAUDE_PROJECT_DIR` au lieu d'un chemin relatif fragile (#78)

### Securite
- **29 vulnerabilites resolues** (12 high, 16 medium, 1 low) — toutes dans les transitives webpack de Docusaurus : RCE GHSA-5c6j-r48x-rmvq (`serialize-javascript`) + DoS GHSA-qj8w-gfj5-8c6v (#76)
- **Bash hardening documente** (CLI 2.1.113) dans `.claude/rules/security.md` : paths `/private/{etc,var,tmp,home}` traites dangereux, deny rules resistent aux wrappers `env`/`sudo`/`watch`/`ionice`/`setsid`, `Bash(find:*)` n'auto-approuve plus `-exec`/`-delete`, UI-spoofing fix sur commentaires multilignes. Exemple de `permissions.sandbox` documente (#85)

---

## [1.28.0] - 2026-04-17

### Ajoute

#### Synchronisation Claude Code (Q1 + Apr 2026)
- **Opus 4.7 + effort `xhigh`** : nouveau modele et niveau de raisonnement maximum (best-practices.md, advanced-features.md, TEAM-GUIDE.md) (#70, #71)
- **Routines** : workflows automatises cloud (prompts + repos + connecteurs sur schedule, API ou GitHub events) (#70)
- **`/ultraplan` et `/ultrareview`** : commandes cloud multi-agents pour plan et review (#70)
- **`/recap`** : resume de session (decisions, fichiers modifies, etat du travail) (#70)
- **`/undo`** : alias de `/rewind` (CLI 2.1.108+) (#70)
- **`/less-permission-prompts`** : scan de transcripts pour optimiser les allowlists (#70)
- **`/team-onboarding`** : generation automatique de guide d'onboarding teammate (#70)
- **`/proactive`** : alias de `/loop` avec auto-pacing (#70)
- **TUI Fullscreen enrichi** : 3 benefices cles (flicker-free, memoire constante, support souris), raccourcis clavier, `CLAUDE_CODE_DISABLE_MOUSE`, `CLAUDE_CODE_SCROLL_SPEED`, compatibilite tmux (#70, #71)
- **Prompt Caching 1h** : `ENABLE_PROMPT_CACHING_1H` et `FORCE_PROMPT_CACHING_5M` (CLI 2.1.108+) (#70)
- **Push Notifications** : notifications mobile via Remote Control (#70)
- **Hook `additionalContext`** : propriete PreToolUse pour enrichir le contexte (CLI 2.1.110+) (#70)
- **Sync Q1 2026** : adaptive thinking, Fast Mode, MCP Channels, `/rewind`, context compaction (#58)

#### Nouvelles rules
- **Rule `design-style`** : 6 directions artistiques (terminal, cockpit, vitality, editorial, glass, signal) (#66)
- **Rule `service-worker`** : NEVER cache HTML navigations, bump cache version (8fbfb4e)
- **Rule `performance`** enrichie avec patterns.dev 2026 (#69)
- **Rule `react`** enrichie avec patterns.dev 2026 (#69)
- **Rule `nextjs`** : RSC, data fetching, caching, App Router (#05f05ee)

#### Nouveaux skills et enrichissements
- **Skill `work-brainstorm`** : ideation structuree avant specification (#68)
- **Skill `ops-standup`** : briefing matinal cross-repo (#68)
- **Skill `ops-ci-fix`** : diagnostic et reparation autonome pipelines CI/CD (#68)
- **Skill `dev-tdd` enrichi** : cycle Red-Green-Refactor detaille avec exemples (#68)
- **Audit step adaptatif** : phase Audit apres TDD avec `/qa:qa-loop "score 90"` (#4bcdc07)
- **Command validator** : 8 categories de risque bloquees (#05f05ee)
- **Workflows quick/batch** : `/work:work-quick`, `/work:work-batch "prd.json"` (#05f05ee)
- **Cost tracking** : `/ops:ops-cost` pour suivi tokens et couts (#05f05ee)

#### Documentation et site Docusaurus
- **6 nouveaux guides** : Python, Go, Auth, Testing, Database, Observability (#64)
- **Guide Claude Code Training** : prerequis au socle pour debutants (#62)
- **Learning path novice → pro** : 2259 lignes (#17791bb)
- **Capstone project TaskFlow** : SaaS end-to-end (#63)
- **Docusaurus UX debutant → avance** : navigation enrichie (#61)
- **Training guide** comme prerequis (#62)
- **Website auto-sync** : `docs/` → `website/docs/` via `sync-docs.ts` (#59, #6a08f35, #72)
- **Examples dans navbar** + anchor fixes (#3a3dcf2)
- **7 pages manquantes regenerees** : ops-ci-fix, ops-standup, work-brainstorm, design-style, etc. (#72)

#### Scripts
- **`check-updates.sh`** : verification des mises a jour CLI et skills (#8856834)
- **`new-project.sh` modularise** : lib/ modules pour faciliter la maintenance (#dea4169)
- **`bump-version.sh`** : mise a jour centralisee de la version dans tous les fichiers

### Modifie
- **Modeles** : references Opus 4.6 → Opus 4.7 dans toute la documentation (22 occurrences)
- **Effort levels** : ajout de `xhigh` dans tous les tableaux
- **Gestion du contexte** : `/recap` et `/undo` dans workflow.md
- **Variables d'env** : `ENABLE_PROMPT_CACHING_1H`, `FORCE_PROMPT_CACHING_5M`, `CLAUDE_CODE_DISABLE_MOUSE`, `CLAUDE_CODE_SCROLL_SPEED`
- **Fast Mode** : documente comme "meme modele Opus 4.7, sortie 2.5x plus rapide"

### Corrige
- **Compteurs stales** : documentation mise a jour (126 commands, 62 agents, 44 skills) (#b2f6195, #9b1846f, #a09ab36)
- **Broken anchor** website (#3a3dcf2)
- **Shellcheck** cross-file global variables (#4fe2f4c)

### Chore
- **Archive des specs implementees** : a11y, check-updates, sync-q1-v2, docs-update-v1.25 (#d7fc33d, #32cedf9)
- **Bump GitHub Actions** (#67)

---

## [1.27.0] - 2026-03-19

### Ajoute
- **Agent `qa-loop`** : boucle autonome audit → fix → test → re-audit avec criteres d'arret (score cible, max iterations, detection regression) (#46)
- **Agent `ops-deploy`** : deploiement securise avec checklist pre-deploy, post-deploy health checks et commande de rollback (#46)
- **Rule `research`** : verifier les capacites natives du framework avant d'implementer une solution custom (#46)
- **Rule `deploy-safety`** : checklist pre-deploiement (env vars, cookies secure, CSP, migrations DB, logs Docker) (#46)
- **Rule `migration-safety`** : checklist migration de framework avec table des pieges courants et caches a vider (#46)
- **Hook pre-push CI** : lint + type-check + tests avant chaque push, supporte Node.js/Python/Go (desactivable avec `SKIP_PRE_PUSH_CI=1`) (#46)
- **Hook destructive ops guard** : bloque DELETE/DROP/TRUNCATE/rm sur donnees sans confirmation (desactivable avec `SKIP_DESTRUCTIVE_CHECK=1`) (#46)
- **Gate operations destructives** : workflow dry-run obligatoire dans verification.md (compter → echantillonner → confirmer → backup → executer) (#46)
- **CI baseline check** : etape 0 dans workflow.md pour distinguer erreurs CI pre-existantes des nouvelles (#46)
- **Scope guard** : guidance dans workflow.md pour decouper les sessions trop ambitieuses (15+ taches = regressions) (#46)
- **7 pages Docusaurus** : qa-loop, ops-deploy, research, deploy-safety, migration-safety (commands + agents + rules) (#46)

### Modifie
- **`update.sh` securise** : `update_directory()` utilise le diff par fichier au lieu de `cp -r` aveugle, protege docs projet (ARCHITECTURE.md, WORKFLOWS.md, guides/) (#46)
- **Hook pre-commit ameliore** : detecte Husky non installe et tente reparation auto, supporte Python (pytest) et Go (go test) (#46)
- **Agent `ops-docker`** : enrichi avec checklist pre-deploiement et directives logs Docker (#46)
- **Skill `parallel-agents`** : prevention des conflits de fichiers inter-agents avec carte des fichiers et file-locking (#46)
- **CLAUDE.md** : ajout workflows `qa-loop` et `ops-deploy` dans le tableau recommande (#46)
- **Compteurs mis a jour** : 123 commands, 59 agents, 42 skills, 24 rules dans toute la documentation (#46)

### Corrige
- **ShellCheck SC2034** : variable `total` inutilisee supprimee dans update.sh (#46)
- **Husky templates** : restaures comme templates pour new-project.sh (supprimes par erreur) (#46)
- **Compteurs stales** : 27+ fichiers avec anciens compteurs (120/121 commands, 37/57 agents, 41 skills, 21 rules) corriges (#46)

### Securite
- **Pre-push CI hook** : empeche de pousser du code qui ne passe pas lint/typecheck/tests (#46)
- **Destructive ops guard** : empeche les suppressions en masse de donnees sans confirmation (#46)
- **Deploy safety rule** : empeche le deploiement de configs dev en production (#46)

---

### Refactore
- **Renommage `qa-a11y` → `wcag-audit`** : agent, commande et documentation renommes dans tout le codebase (#45)

### Ajoute (accessibilite)
- **Rule `accessibility` enrichie** : 100+ regles inspirees d'axe-core, audit WCAG 2.1 AA complet (#45)

### Modifie (dependances)
- **`bats-core/bats-action`** : 3.0.1 → 4.0.0 (#28)

### Modifie (hooks)
- **RTK desactive par defaut** : necessite `ENABLE_RTK=1` pour activer (#44)
- **`update.sh --add-hook rtk`** : ajout de hooks sans ecraser settings.json (#42)
- **RTK token optimizer** : integration optionnelle, -60-90% tokens (#41)

### Corrige
- **ShellCheck warnings** : corrections dans update.sh (#43)

## [1.26.0] - 2026-03-14

### Ajoute
- **Sync CLI 2.1.76** : 6 nouveaux hooks (PostCompact, TeammateIdle, TaskCompleted, InstructionsLoaded, Elicitation, ElicitationResult) avec mode async (#30)
- **Securite hooks/MCP** : hooks SessionStart pour verification .env/.gitignore et warning hooks tiers (#30)
- **Documentation CLI 2.1.76** : memoire automatique, /effort levels, --name sessions nommees, VSCode URI handler (#37)
- **3 guides domaine** : INFRA-GUIDE.md (30 ops), BIZ-GUIDE.md (11 biz), GROWTH-GUIDE.md (11 growth) (#34)
- **2 output styles** : debug (Error/RootCause/Evidence/Fix) et metrics (numbers-first, trend arrows) (#34)
- **15 exemples skills** : ops-ci, ops-docker, ops-monitoring, ops-database, dev-supabase, dev-flutter, dev-graphql, dev-refactor, dev-error-handling, qa-perf, qa-tech-debt, qa-design, data-pipeline, doc-generate, growth-cro (#36)
- **Script generate-commands-doc.sh** : generation automatique de docs/reference/commands.md avec --output et --check (#34)
- **.mcp.env.example** : documentation des variables d'environnement MCP (#33)
- **Rule precedence** : matrice de priorite des rules dans rules/README.md (security > verification > tdd > language > framework) (#33)
- **Gate Function** : enrichissement de la rule verification avec 5 etapes obligatoires et Red Flags (#31)
- **Documentation** : sections async hooks, HTTP hooks, worktree.sparsePaths, Claude Code Security, MCP Elicitation dans advanced-features.md (#30)

### Modifie
- **Commands trimmes -85%** : 121 commandes de 41,527 a 6,116 lignes (avg 343 → 50 lignes/fichier), skills comme source de verite (#34, #35)
- **Agents trimmes -61%** : 57 agents de 7,079 a 2,784 lignes (avg 124 → 48 lignes/fichier), 0 agents > 80 lignes (#36)
- **Scripts securises** : fix injection commande dans new-project.sh (node -e, sed), safe_mktemp dans update.sh, fix awk injection (#38)
- **Scripts refactores** : detect_stack() decoupe en 8 sous-fonctions, update_directory() remplace 5 fonctions identiques, main() data-driven (#38)
- **Modeles agents** : biz-mvp, biz-competitor, biz-personas, growth-seo, doc-generate passes de haiku a sonnet (#33)
- **Hooks logging en async** : SessionEnd, PreCompact, SubagentStop, Notification passes en mode non-bloquant (#30)
- **VERSION dynamique** : new-project.sh et update.sh lisent VERSION depuis le fichier (#38, #39)
- **Compteurs dynamiques** : new-project.sh utilise find au lieu de comptes hardcodes (#33)
- **Commandes namespace** : toutes les references utilisent /category:command au lieu de /category-command (#39)

### Corrige
- **2 tests en echec** : smoke test CLAUDE.md > 100 lignes (ajuste a 30), update.sh @imports skip detection (#32)
- **detect_database()** : utilise find -exec au lieu de xargs fragile (#39)
- **copy_socle_dir()** : protection contre les repertoires vides (glob safety) (#39)
- **generate_smart_claude_md** : extraction test tools reecrite (etait pipe casse) (#39)

### Supprime
- **4 specs archivees** : agent-teams, opnsense-iac, doc-improvements, claude-code-sync-2026 deplaces vers specs/archived/ (#33)
- **~38,000 lignes de duplication** : methodologie retiree des commands et agents (vit dans les skills) (#35, #36)

### Securite
- **5 vulnerabilites corrigees** : injection node -e, injection sed, mktemp sans verification, injection awk, quoting variables (#38, #39)
- **Documentation risques depots tiers** : 3 vecteurs d'attaque (hooks, MCP, env vars) documentes dans security.md (#30)
- **--restore option** : update.sh permet de restaurer depuis un backup (#38)

---

## [1.25.1] - 2026-02-06

### Ajoute
- **Documentation Docusaurus** : mise a jour complete pour combler les ecarts avec le socle v1.25.0
  - Page [Fonctionnalites Avancees](/docs/concepts/advanced-features) dans Concepts : Opus 4.6, Agent Teams, Plugins, LSP, MCP, @imports
  - Page [Bonnes Pratiques](/docs/guides/best-practices) dans Guides : recommandations Boris Cherny (verification, modele, prompting, sessions paralleles, commit-push-pr)
  - Style `explanatory` documente dans la page Output Styles (recommande par Boris Cherny)

### Modifie
- Compteurs Docusaurus corriges : Skills 41 → 42 (navbar, footer, index), WORK 11 → 12 (sidebar, index)
- Concepts passe de 9 a 10 concepts cles (ajout Fonctionnalites Avancees)
- Sidebar mise a jour avec les 2 nouvelles pages (concepts + guides)
- Guide index enrichi avec la page Bonnes Pratiques

---

## [1.25.0] - 2026-02-06

### Ajoute
- **Agent Teams** : integration native de l'orchestration multi-agents (TeammateTool)
  - Skill `agent-teams` avec documentation complete (activation, architecture, modes, raccourcis)
  - 4 patterns pre-configures : Audit (3-4 agents), Feature (2-3 agents), Debug (3-5 agents), Review (3 agents)
  - Commande `/work:work-team` avec detection automatique du pattern adapte
  - Workflow en 5 etapes : Analyser → Creer → Coordonner → Synthetiser → Cleanup
  - Support tmux (split-panes) et mode in-process
  - Raccourcis clavier : Shift+Up/Down (navigation), Shift+Tab (delegate), Ctrl+T (task list)
- **Documentation** : reference croisee Agent Teams dans le skill `parallel-agents`
- **CLI** : flag `--teammate-mode` documente (auto, in-process, tmux)

### Modifie
- Compteurs mis a jour : 121 commandes, 42 skills (README, website, docs)
- Section WORK passe de 11 a 12 commandes dans le catalogue

---

## [1.24.2] - 2026-02-06

### Ajoute
- **GitHub Pages** : deploiement automatique de la documentation Docusaurus
  - Workflow `docs.yml` : ajout des jobs `upload-pages-artifact` et `deploy-pages`
  - Permissions `pages: write` et `id-token: write` configurees
  - Site accessible sur https://christopherlouet.github.io/claude-socle/

### Corrige
- **Workflow Specify** : ajout de l'etape manquante "Specify" dans 16 references
  - Toutes les occurrences affichent desormais le workflow complet en 5 etapes : Explore → Specify → Plan → TDD → Commit
  - Fichiers corriges : `docusaurus.config.ts`, pages intro, guides, FAQ, workflows, tutorials, `GUIDE.md`

---

## [1.24.1] - 2026-02-06

### Corrige
- **Website Docusaurus** : build casse corrige et ameliorations multiples
  - `sidebars.ts` : chemins orchestrateur corriges (`commands/assistant` → `commands/other/assistant`), compteurs domaines mis a jour (WORK 11, DEV 23, QA 15, GROWTH 11)
  - Liens casses corriges dans `concepts/orchestrator.md`, `workflow/choosing-workflow.md`, `workflow/tdd.md`, `examples/ops/opnsense-config.md`, `tutorials/opnsense-firewall.md`
  - `generate-command-docs.ts` : syntaxe commandes corrigee (`/command` → `/{domain}:{command}`), ajout etape Specify dans le guide rapide
  - `docusaurus.config.ts` : `onBrokenLinks` passe de `warn` a `throw`, migration `onBrokenMarkdownLinks` vers `markdown.hooks` (Docusaurus v4)

### Ajoute
- **Assets statiques** : `favicon.svg` et `social-card.svg` (Open Graph 1200x630)
- **Homepage** : workflow aligne avec CLAUDE.md (5 etapes : Explore → Specify → Plan → TDD → Commit)
- **`WorkflowDiagram.tsx`** : etape Specify ajoutee au `MAIN_WORKFLOW`
- **Accessibilite** : styles `:focus-visible` pour cards, boutons et liens dans `custom.css`
- **`FeatureComparison.tsx`** : refactorise avec props `columns` et `data` (retrocompatible)

---

## [1.24.0] - 2026-02-06

### Modifie
- **Documentation Opus 4.6** : mise a jour des references pour Claude Opus 4.6
  - `docs/reference/best-practices.md` : citation Boris Cherny et recommandations mises a jour (Opus 4.5 → 4.6), ajout section Adaptive Thinking (4 niveaux d'effort), mention Context Compaction
  - `docs/reference/advanced-features.md` : nouvelle section "Opus 4.6 : Nouvelles Capacites" (Adaptive Thinking, 1M contexte beta, 128k sortie, Context Compaction, Agent Teams)
  - `templates/FAQ.md` : fenetre de contexte mise a jour (200k → 1M beta), nouvelle FAQ Adaptive Thinking
  - `docs/ARCHITECTURE.md` : tableau des modeles enrichi avec contexte et sortie max
  - `dev-ai-integration` (agent, commande, page Docusaurus) : modeles Anthropic mis a jour, nouvel exemple Opus 4.6 avec Adaptive Thinking

### Corrige
- **`new-project.sh`** : copie de `docs/reference/`, `docs/guides/`, `docs/ARCHITECTURE.md` et `docs/WORKFLOWS.md` lors de l'installation
  - Les @imports de CLAUDE.md (`@docs/reference/*.md`) sont maintenant resolus dans les nouveaux projets
  - Les liens de navigation du CLAUDE.md vers les guides et l'architecture sont disponibles
- **`update.sh`** : `--upgrade-claude-md` copie aussi `docs/ARCHITECTURE.md`, `docs/WORKFLOWS.md` et `docs/guides/` en plus de `docs/reference/`

---

## [1.23.2] - 2026-02-06

### Corrige
- **Documentation Docusaurus** : correction de la coherence et suppression des fichiers dupliques
  - Suppression de 29 pages de skills dupliquees (anciens noms descriptifs)
  - Suppression de 2 fichiers assistant dupliques a la racine des commandes
  - Correction des compteurs dans 8+ fichiers (commands, agents, reference, concepts)
  - Reecriture complete de `agents-matrix.md` (37 → 57 agents)
  - Correction de `concepts/orchestrator.md` (compteurs et noms de skills obsoletes)
- **Pages manquantes** : creation des pages documentation absentes
  - `qa-chrome` : skill, agent et commande
  - `work-commit-push-pr` : commande
- **Matrices de reference** : ajout des commandes manquantes
  - DEV : 7 commandes ajoutees (dev-ai-integration, dev-design-system, dev-document, dev-prisma, dev-prompt-engineering, dev-rag, dev-trpc)
  - QA : 4 commandes ajoutees (qa-chrome, qa-design, qa-e2e, qa-tech-debt)
  - OPS : 6 commandes ajoutees (ops-observability-stack, ops-opnsense, ops-proxmox, ops-rollback, ops-serverless, ops-vercel)
  - GROWTH : 2 commandes ajoutees (growth-cro, growth-localization)

---

## [1.23.1] - 2026-02-03

### Corrige
- **Compteurs documentation** : correction des incohérences dans tous les fichiers
  - `Stats.tsx` : 100→120 commands, 37→57 agents, 24→41 skills, 15→21 rules
  - `website/docs/intro/index.md` : Rules 20→21, WORK 10→11
  - `website/docs/reference/index.md` : Commands 119→120, Rules 20→21, WORK 10→11
  - `WHEN-TO-USE-WHICH-AGENT.md` : 56→57 agents
  - `docs/ARCHITECTURE.md` : Skills 40→41, Agents 56→57, Rules 20→21
  - `.claude/skills/README.md` : 40→41 skills
- **`/assistant`** : ajout de `/work:work-commit-push-pr` dans le catalogue (11 WORK commands)

---

## [1.23.0] - 2026-02-03

### Ajoute
- **Bonnes pratiques Boris Cherny** : integration des recommandations du createur de Claude Code
  - Nouvelle section "Verification" dans CLAUDE.md (feedback loop = 2-3x qualite)
  - Nouvelle section "Modele Recommande" (Opus 4.5 avec thinking, mis a jour vers Opus 4.6 en v1.24)
  - Nouvelle section "Prompting Avance" ("Grill me", "Prove it", "elegant solution")
  - Nouvelle section "Sessions Paralleles" (git worktrees)
- **`/work:work-commit-push-pr`** : nouvelle commande combinee commit+push+PR (120 commands)
- **`docs/reference/best-practices.md`** : fichier de reference importe via @import
- **`docs/guides/PROMPTING-GUIDE.md`** : guide complet des techniques de prompting
- **Output style `explanatory`** : mode apprentissage avec explications detaillees (8 styles)
- **MCP servers** : ajout Slack, Sentry, BigQuery, Linear, Notion (13 servers)

### Modifie
- **`update.sh`** : amelioration de la mise a jour des @imports
  - Copie toujours `docs/reference/*` (mise a jour des fichiers)
  - Detecte et ajoute les @imports manquants dans CLAUDE.md existants
  - Ajoute automatiquement `@docs/reference/best-practices.md`
- **Skill `git-worktrees`** : enrichi avec le workflow Boris (aliases shell, worktree analyse, notifications)
- **Compteurs documentation** : mise a jour 119 → 120 commands

---

## [1.22.2] - 2026-02-02

### Modifie
- **README** : migration des commandes vers le format namespace, correction badge release, arbre structure et politique de versioning
- **CI** : bump actions/checkout, actions/setup-node et actions/cache via Dependabot

---

## [1.22.1] - 2026-02-02

### Supprime
- **setup-wizard.sh supprime** : le wrapper de compatibilite est retire, utiliser `new-project.sh --simple` directement

---

## [1.22.0] - 2026-02-02

### Modifie
- **setup-wizard.sh deprecie** : remplace par un wrapper de 14 lignes qui redirige vers `new-project.sh --simple`, eliminant 520+ lignes de code duplique

---

## [1.21.0] - 2026-02-02

### Ajoute
- **Auto-creation de branches** : les workflows feature/bugfix/release creent automatiquement une branche et une PR active

### Modifie
- **Commandes namespacees** : toutes les references de commandes utilisent le format namespace (`/work:work-explore` au lieu de `/work-explore`)

### Corrige
- **CI ShellCheck** : resolution de SC2155 (declare and assign separately) dans `update.sh`

---

## [1.20.0] - 2026-02-01

### Ajoute
- **Auto CLAUDE.md** : generation automatique du CLAUDE.md lors de `update.sh` si absent
- **Default .gitignore** : ajout de `.claude/` et `CLAUDE.md` dans le .gitignore par defaut des nouveaux projets
- **Migration CLAUDE.md** : option `--upgrade-claude-md` dans `update.sh` pour migrer les anciens projets vers les @imports

### Modifie
- **CLAUDE.md @imports** : refactoring du CLAUDE.md pour utiliser des @imports vers `docs/reference/` (commands, project-structures, agents-catalog, hooks-reference, skills-catalog, advanced-features)

### Corrige
- **CI workflows** : optimisation pour les repos prives (reduction de la consommation de minutes GitHub Actions)

---

## [1.19.1] - 2026-01-30

### Corrige
- **Compteurs documentation** : alignement des compteurs (120 cmd, 57 agents, 41 skills, 21 rules) dans README badge, Docusaurus config (navbar/footer), quick-start, commands/index, skills/index, CONTRIBUTING, assistant.md
- **Badge version README** : correction v1.17.0 → v1.19.0

---

## [1.19.0] - 2026-01-30

### Ajoute
- **Sync documentation officielle** : alignement avec code.claude.com (nouveau domaine docs Anthropic)
- **Nouveaux Hook Events** : `UserPromptSubmit`, `PermissionRequest`, `PostToolUseFailure`, `SubagentStart`, `Stop` documentes dans CLAUDE.md
- **Prompt-based hooks** : documentation du type `prompt` (evaluation LLM) en plus du type `command`
- **CLAUDE.md @imports** : documentation de la syntaxe `@path/to/file` pour importer des fichiers
- **Plugins system** : documentation du systeme de plugins (`.claude-plugin/plugin.json`, marketplace, namespacing)
- **SessionStart matchers** : documentation des matchers `startup`, `resume`, `clear`, `compact`
- **Notification types** : ajout de `auth_success` et `elicitation_dialog`

### Modifie
- **URLs documentation** : migration de `docs.anthropic.com` vers `code.claude.com` dans tous les fichiers MD
- **Hook Events CLAUDE.md** : table enrichie avec 13 events (etait 8), types command/prompt
- **docs/CHEATSHEET.md** : mise a jour complete avec tous les 120 commandes par categorie, accents corriges
- **docs/ALIASES.md** : enrichissement avec orchestrateur, nouveaux alias dev/qa/ops/growth
- **docs/GUIDE.md** : restructuration et enrichissement du guide complet
- **docs/GUIDE-UTILISATEUR.md** : mise a jour du guide utilisateur
- **docs/CUSTOMIZATION.md** : mise a jour du guide de personnalisation

---

## [1.18.0] - 2026-01-30

### Ajoute
- **LSP Configuration** : `.lsp.json` avec support de 12 langages (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS)
- **Regle LSP** : `.claude/rules/lsp.md` pour guider l'utilisation LSP vs Grep (navigation semantique)
- **Hooks Setup** : hook `Setup` avec `init` (install dependances) et `maintenance` (audit + update)
- **Hooks Notification** : hook `Notification` pour `permission_prompt` et `idle_prompt`
- **Hook SubagentStop** : log de fin des sub-agents pour tracabilite
- **Hook SessionEnd** : log de fin de session pour analytics
- **Hook PreCompact** : log avant compaction du contexte pour debugging
- **Skill qa-chrome** : tests visuels Chrome (debugging DOM, responsive, captures GIF)
- **Agent qa-chrome** : agent audit visuel Chrome (sonnet, Bash/Read/Grep/Glob)
- **Commande /qa-chrome** : commande pour invoquer les tests Chrome
- **Script setup-deps.sh** : script hook Setup detectant le type de projet et installant les dependances
- **Section CLI Flags** dans CLAUDE.md : 14 flags documentes (`--agent`, `--chrome`, `--teleport`, `--remote`, `--init`, `--maintenance`, `--max-budget-usd`, etc.)
- **Section LSP** dans CLAUDE.md : activation, langages supportes, guide LSP vs Grep
- **Section Bonnes Pratiques Skills** dans CLAUDE.md : taille, budget, frontmatter, substitutions, dynamic context injection

### Modifie
- **Hooks settings.json** : ajout de 5 nouveaux hook events (Setup, Notification, SubagentStop, SessionEnd, PreCompact)
- **Section Hooks CLAUDE.md** : reecrite avec tableau complet des 23 hooks configures et variables d'environnement
- **Skills frontmatter** : enrichissement de 26 skills avec `disable-model-invocation`, `argument-hint`, `model`, `user-invocable`
- **writing-skills/SKILL.md** : documentation complete des nouveaux champs frontmatter Claude Code 2.1+
- **Compteurs** : 120 commandes, 57 sub-agents, 41 skills, 21 regles (README, CLAUDE.md, website)

---

## [1.17.0] - 2026-01-29

### Securite
- **Mots de passe exemples** : remplacement de tous les `POSTGRES_PASSWORD=pass` par `${POSTGRES_PASSWORD:?required}` ou `${{ secrets.POSTGRES_PASSWORD }}` dans ops-docker, ops-ci, qa-automation
- **curl|sh** : remplacement du pattern `curl | sh` par download-then-execute dans `install-starship-theme.sh`
- **Avertissement curl|sh** : ajout d'un bloc securite dans `ops-vps.md` documentant le risque
- **CLAUDE.md** : enrichissement de la section Securite avec gestion des secrets, MCP security, curl|bash
- **Input validation** : ajout de `sanitize_input()` et `validate_input()` dans `scripts/lib/common.sh`

### Ajoute
- **`.claude/rules/README.md`** : index des 20 regles avec paths cibles et descriptions
- **`.claude/skills/README.md`** : mise a jour complete avec les 40 skills (etait 9)
- **CI validate-counts** : nouveau job `validate-counts` dans le pipeline CI
- **CI Semgrep SAST** : nouveau job `semgrep` (informatif) pour l'analyse statique de securite

### Corrige
- **validate-counts.sh** : exclusion des fichiers `README.md` du comptage (commands, agents, rules)

---

## [1.16.1] - 2026-01-29

### Corrige
- **Compteur DEV** : correction dans CLAUDE.md (24 → 23 commandes)
- **Compteur Skills** : correction dans CLAUDE.md (39 → 40 skills)
- **Index agents** : description mise a jour (37 → 56 sub-agents)
- **Workflows** : ajout de l'etape `/work-specify` dans les exemples de workflows
- **CI/docs** : echappement des chevrons dans dev-debug SKILL.md pour MDX
- **CI** : correction des erreurs ShellCheck et MDX build

### Ajoute
- **CONTRIBUTING.md** : guide de contribution avec setup, conventions et checklist
- **Synchronisation docs** : mise a jour complete de la documentation website (138 fichiers)

---

## [1.16.0] - 2026-01-28

### Ajouté
- **3 nouveaux agents** : `dev-document`, `growth-cro`, `qa-design`
  - `dev-document` (sonnet) : Génération de documents (PDF, DOCX, XLSX, PPTX)
  - `growth-cro` (haiku) : Optimisation du taux de conversion (CRO)
  - `qa-design` (haiku) : Audit UI/UX (100+ règles design web)
- **3 nouvelles commandes** : `/dev-document`, `/growth-cro`, `/qa-design`
- **7 nouveaux skills** :
  - `dev-document` : Génération de documents bureautiques
  - `growth-cro` : Optimisation CRO (conversion, signup, onboarding, paywall)
  - `qa-design` : Audit design UI/UX
  - `git-worktrees` : Développement parallèle avec git worktrees
  - `parallel-agents` : Orchestration d'agents parallèles (fan-out)
  - `session-handoff` : Transfert de contexte entre sessions IA
  - `writing-skills` : Guide pour créer de nouveaux skills
- **2 nouvelles règles** :
  - `nextjs.md` : Règles Next.js (RSC, App Router, data fetching, caching)
  - `verification.md` : Vérification avant completion (4 phases)
- **2 nouveaux scripts** :
  - `scripts/bump-version.sh` : Mise à jour unifiée de la version dans tous les fichiers
  - `scripts/validate-counts.sh` : Validation de la cohérence des compteurs (commands/agents/skills/rules)
- **Script thème GNOME Terminal** : `scripts/themes/install-gnome-terminal-theme.sh`

### Modifié
- **Skills enrichis** : Contenu étendu pour `dev-debug`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `qa-review`
- **Commandes enrichies** : `assistant`, `assistant-auto`, `doc-architecture`
- **Documentation complètement synchronisée** :
  - Tous les compteurs alignés sur 118 commands, 56 agents, 40 skills, 20 rules
  - README.md : badge version corrigé (v1.12.1 → v1.15.0), compteurs catégories corrigés
  - Website : 8 fichiers corrigés (index.tsx, architecture.md, quick-start.md, cheatsheet.md, FeatureComparison.tsx, docusaurus.config.ts, intro/index.md)
  - Politique de versioning mise à jour dans README.md

### Corrigé
- **Badge README.md** : Version affichée corrigée de v1.12.1 à v1.15.0 (maintenant v1.16.0)
- **Compteurs README.md** : dev (22→23), qa (12→14), ops (27→30), growth (9→11)
- **Website quick-start** : Version et compteurs obsolètes (v1.4.1/109/47 → v1.16.0/118/56)
- **Website architecture** : Compteurs mixtes corrigés (110/52/32/17 → 118/56/40/20)
- **Website index.tsx** : Compteurs homepage corrigés (108/45/27/17 → 118/56/40/20)
- **Website FeatureComparison** : Compteurs comparaison corrigés (100/37/24 → 118/56/40)
- **Website cheatsheet** : Compteurs footer corrigés (111/52/32/17 → 118/56/40/20)
- **Website docusaurus.config.ts** : Labels footer corrigés

### Technique
- Compteurs totaux : 118 commands (+0), 56 agents (+3), 40 skills (+7), 20 rules (+2)
- Nouveau script `bump-version.sh` pour éviter les désynchronisations futures
- Nouveau script `validate-counts.sh` pour validation CI des compteurs
- 38+ fichiers modifiés, ~1000 lignes ajoutées

---

## [1.15.0] - 2026-01-25

### Ajouté
- **Nouveaux hooks de qualité** (issus du retour d'expérience sur des projets utilisateurs réels)
  - `SessionStart` : Vérification de node_modules manquant
  - `PreToolUse` : Exécution des tests avant commit (désactivable via `SKIP_PRE_COMMIT_TESTS=1`)
  - `PostToolUse` : Type-check TypeScript (`tsc --noEmit`) après modification
  - `PostToolUse` : Vérification ESLint après modification JS/TS
  - `PostToolUse` : Vérification couverture de tests après modification de fichiers `.test.ts`

### Technique
- 5 nouveaux hooks dans `.claude/settings.json`
- Synchronisation des fonctionnalités depuis un projet utilisateur réel
- Variables d'environnement pour désactiver les hooks (SKIP_PRE_COMMIT_TESTS, ALLOW_MAIN_EDIT)
- Détection secrets gitleaks en PreToolUse (avant écriture) - pas de scan post-commit redondant

---

## [1.14.0] - 2026-01-24

### Ajouté
- **Collection de thèmes terminal** : 7 thèmes visuels complets dans `scripts/themes/`
  - Thèmes disponibles : matrix, cyberpunk, dracula, catppuccin, nord, gruvbox, tokyo-night
  - Chaque thème inclut 3 composants :
    - Configuration Starship (prompt) : `starship-themes/<theme>.toml`
    - Couleurs eza (listing moderne) : `eza-<theme>.sh`
    - Couleurs LS_COLORS (ls natif) : `ls-<theme>.sh`
  - Script d'installation interactif : `install-starship-theme.sh`
  - Documentation complète avec palettes de couleurs et aliases

### Technique
- 23 nouveaux fichiers de configuration de thèmes
- Support True Color (RGB 24-bit) pour tous les thèmes
- Aliases inclus : `ls`, `ll`, `la`, `lt`, `l`

---

## [1.13.0] - 2026-01-23

### Ajouté
- **Règle TDD Enforcement** : Nouvelle règle `.claude/rules/tdd-enforcement.md` pour déclencher proactivement le TDD
  - S'applique à tous les fichiers source (TS, JS, Dart, Python, Go, Rust, Java, C#, Ruby, PHP)
  - Mots-clés déclencheurs : "implémenter", "ajouter", "créer", "fixer", "corriger", "feature", "bugfix"
  - Exceptions définies : fichiers de config, documentation, refactoring mineur

- **Documentation Docusaurus** : Page `/docs/rules/tdd-enforcement` avec exemples et intégration

### Modifié
- **Skill dev-tdd** : Description élargie avec nouveaux mots-clés déclencheurs automatiques
- **Agent dev-tdd** : Description alignée avec le skill pour déclenchement étendu
- **Commandes dev-*** : Ajout de la section "Pré-requis TDD" obligatoire
  - `/dev-component` : Ordre de création TDD (types → tests → composant → stories)
  - `/dev-api` : Ordre de création TDD (spec → tests → handler → doc)
  - `/dev-hook` : Ordre de création TDD (types → tests → hook)
- **CLAUDE.md** : Compteur de règles mis à jour (17 → 18), documentation tdd-enforcement
- **Docusaurus** : Mise à jour de l'index des règles, skill TDD et workflow TDD avec cross-links

### Technique
- Score d'enforcement TDD amélioré de 5.4/10 à ~8/10
- Cross-linking établi entre rule, skill et workflow TDD

---

## [1.12.1] - 2026-01-22

### Ajouté
- **Documentation Docusaurus Skills** : 29 nouvelles pages de documentation pour les skills
  - Skills WORK : `work-commit`, `work-explore`, `work-plan`, `work-pr`
  - Skills DEV : `dev-api`, `dev-debug`, `dev-error-handling`, `dev-flutter`, `dev-graphql`, `dev-prompt-engineering`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `dev-tdd`
  - Skills DOC : `doc-changelog`, `doc-generate`
  - Skills OPS : `ops-ci`, `ops-database`, `ops-docker`, `ops-infra-code`, `ops-mobile-release`, `ops-monitoring`, `ops-opnsense`, `ops-proxmox`
  - Skills QA : `qa-e2e`, `qa-perf`, `qa-review`, `qa-security`, `qa-tech-debt`

### Modifié
- **Agent ops-opnsense** : Ajout des métadonnées standardisées (name, description, tools) dans le frontmatter
- **Documentation agents** : Mise à jour des métadonnées (outils, skills injectés)

### Corrigé
- **Tests smoke** : Mise à jour des noms de skills après harmonisation (test-driven-development → dev-tdd, etc.)

---

## [1.12.0] - 2026-01-22

### Ajouté
- **Support IaC OPNsense** : Configuration complète du firewall OPNsense via Terraform
  - Nouvelle commande `/ops-opnsense` pour gérer OPNsense en Infrastructure as Code
  - Nouvel agent `ops-opnsense` (modèle sonnet) avec skills infrastructure-as-code et opnsense-configuration
  - Nouveau skill `opnsense-configuration` avec patterns et bonnes pratiques

- **Templates Terraform OPNsense** (`.claude/templates/opnsense/`)
  - `provider-template.tf` : Configuration provider `browningluke/opnsense`
  - `interfaces-module.tf` : Interfaces WAN/LAN/VLAN avec gateway
  - `firewall-module.tf` : Règles firewall avec anti-lockout obligatoire
  - `nat-module.tf` : NAT outbound et port forwarding
  - `services-module.tf` : DHCP server et DNS Unbound
  - `aliases-module.tf` : Groupes d'adresses, ports et réseaux

- **Exemple complet Orange Box DMZ** (`examples/orange-box-dmz/`)
  - Configuration OPNsense derrière une box Orange en mode DMZ
  - 7 règles firewall (anti-lockout, web, DNS, NTP, ICMP, block-all)
  - DHCP, DNS forwarders Cloudflare, outputs avec résumé ASCII

- **Documentation Docusaurus**
  - Page commande `/ops-opnsense` (auto-générée)
  - Page agent `ops-opnsense` (auto-générée)
  - Page skill `opnsense-configuration` (auto-générée)
  - Exemple `opnsense-config.md` : Configuration complète avec code Terraform
  - Tutoriel `opnsense-firewall.md` : Guide pas-à-pas (45 min, niveau intermédiaire)

### Modifié
- **CLAUDE.md** : Ajout `/ops-opnsense` (115 commandes, 53 agents, 33 skills)
- **sidebars.ts** : OPS (24 → 30), ajout tutoriel et exemple OPNsense
- **Index pages** : Exemples et tutoriels mis à jour

### Corrigé
- **Provider OPNsense** : `allow_insecure_cert` → `allow_insecure` (attribut correct)

---

## [1.11.0] - 2026-01-22

### Ajouté
- **TDD obligatoire** dans le workflow d'implémentation
  - Le cycle Red-Green-Refactor devient obligatoire pour toute feature
  - Workflow mis à jour : Explore → Plan → **TDD** → Commit
  - Anti-pattern ajouté : "Coder AVANT d'écrire les tests"
  - Documentation Docusaurus mise à jour (13 fichiers)

- **Permissions optimisées** dans `settings.json`
  - `NotebookEdit` : Édition notebooks Jupyter sans confirmation
  - `TodoRead` / `TodoWrite` : Gestion todo list sans confirmation
  - `AskFollowup` : Questions de suivi sans confirmation
  - `mcp__*` : Tous les serveurs MCP autorisés

- **Nouveaux hooks d'auto-installation**
  - `pubspec.yaml` → `flutter pub get` automatique
  - `go.mod` → `go mod tidy` automatique
  - `Cargo.toml` → `cargo check` automatique

### Modifié
- **Deny list renforcée** (+10 patterns de sécurité)
  - `git restore .`, `git checkout .` bloqués
  - `rm -rf node_modules` bloqué
  - `shutdown`, `reboot`, `halt`, `poweroff` bloqués
  - Fork bomb et pipes dangereux bloqués

### Corrigé
- **CVE-2025-13465** : Patch lodash-es via npm overrides

### Documentation
- Mise à jour du workflow dans 13 fichiers Docusaurus
- WorkflowDiagram.tsx : Code → TDD dans les diagrammes
- FAQ et guides mis à jour

---

## [1.10.1] - 2026-01-22

### Corrigé
- **Correction settings.json** : Erreurs de syntaxe des permissions
  - `Bash(*)` → `Bash` (syntaxe correcte pour autoriser toutes les commandes)
  - Suppression du pattern fork bomb invalide
  - Ajout de `Task(*)` dans les permissions

### Ajouté
- **Tests de smoke** (`tests/smoke.bats`) : Validation rapide de l'intégrité du socle

### Documentation
- **README.md** : Mise à jour badges (250 tests), section migration v1.10.x
- **SECURITY.md** : Mise à jour versions supportées (1.8.x à 1.10.x)

---

## [1.10.0] - 2026-01-22

### Ajouté
- **Nouvel Agent**
  - `dev-tdd` : Agent TDD pour le développement guidé par les tests
- **3 nouvelles Commandes** (total: 114 commandes)
  - `/dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `/growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `/qa-tech-debt` : Identifier et prioriser la dette technique

### Modifié
- **Fusion de `install.sh` dans `new-project.sh`**
  - Nouveau mode `--simple` (ou `--install-only`) pour installation rapide
  - Options ajoutées : `--dry-run`, `--quiet`, `--verbose`, `--skip-prompts`
  - L'ancien comportement de `install.sh` est maintenant accessible via `new-project.sh --simple .`
- **Compteurs mis à jour** dans la documentation : 114 commandes, 52 agents, 32 skills

### Supprimé
- **`scripts/install.sh`** : Fonctionnalités fusionnées dans `new-project.sh --simple`
- **`tests/install.bats`** : Tests migrés vers les tests de `new-project.sh`

### Statistiques
- Commands: 114 (+3)
- Sub-Agents: 52 (+1)
- Skills: 32 (inchangé)

---

## [1.9.0] - 2026-01-20

### Modifié
- **Configuration settings.json optimisée**
  - Permissions génériques avec wildcards (npm, git, docker, terraform, etc.)
  - Support multi-stack : Node.js, Python, Go, Rust, Flutter, Docker, Kubernetes, Terraform
  - Wildcards pour Skills (`Skill(*)`) et MCP tools (`mcp__*`)
  - Scripts locaux via pattern relatif `Bash(./scripts/*:*)`
  - Hooks conditionnels vérifiant l'existence des outils avant exécution

### Supprimé
- **Hooks redondants**
  - Vérification npm install au démarrage
  - TypeScript type-check après modification (bruit)
  - ESLint check après modification (bruit)
  - Couverture de tests après modification (bruit)
  - Scan gitleaks post-commit (redondant avec PreToolUse)

### Sécurité
- **Deny list étendue**
  - `git reset --hard` bloqué
  - `rm -rf ~` bloqué
  - `sudo` et `su` bloqués
  - `chmod 777` bloqué
  - Commandes destructives bas niveau bloquées (mkfs, dd)

### Amélioré
- **Portabilité** : Plus de chemins absolus, configuration universelle
- **Moins d'interactions** : Permissions élargies réduisent les prompts
- **Maintenance** : settings.local.json minimal (11 lignes vs 135)

---

## [1.8.0] - 2026-01-20

### Ajouté
- **8 tutoriels progressifs** (`docs/tutorials/`)
  - 01 - Premier projet : workflow de base (débutant)
  - 02 - Feature React : composant et hook complets (débutant)
  - 03 - API REST Node.js : TDD et documentation OpenAPI (intermédiaire)
  - 04 - Flutter + Supabase : app mobile avec backend (intermédiaire)
  - 05 - Audit de sécurité : OWASP Top 10 (intermédiaire)
  - 06 - Pipeline CI/CD : GitHub Actions (intermédiaire)
  - 07 - Refactoring Legacy : approche méthodique (avancé)
  - 08 - Infrastructure Proxmox : Terraform et monitoring (avancé)

- **Guides utilisateur** (`docs/guides/`)
  - `faq.md` : 20+ questions fréquentes avec réponses détaillées
  - `troubleshooting.md` : 15+ problèmes courants et solutions
  - `migration.md` : guide complet de migration vers claude-socle

- **12 exemples de code** (`docs/examples/`)
  - Web : React component, custom hook, Next.js API route
  - Mobile : Flutter screen (Clean Architecture), BLoC pattern
  - API : REST endpoint, GraphQL resolver, tRPC procedure
  - Ops : Docker multi-stage, CI/CD pipeline, Terraform module, Proxmox VM

- **Composants React Docusaurus**
  - `TutorialCard.tsx` : cartes de tutoriel avec durée et difficulté
  - `DifficultyBadge.tsx` : badges beginner/intermediate/advanced

- **Diagrammes Mermaid**
  - Workflow principal dans `cheatsheet.md`
  - Arbre de décision dans `choosing-workflow.md`
  - Séquence dans `explore-plan-code-commit.md`
  - Vue d'ensemble architecture dans `intro/architecture.md`

### Modifié
- **Skill infrastructure-as-code** : suppression des liens vers fichiers de référence inexistants
- **Sidebars** : ajout des tutoriels, exemples et guides

### Corrigé
- Liens internes dans les tutoriels (suppression préfixes numériques des IDs)
- Lien vers agent `qa-tech-debt` (était incorrectement lié à commands)
- Lien vers guide ops (remplacé par exemples)

---

## [1.7.0] - 2025-01-20

### Ajouté
- **Option `--path` pour `new-project.sh`**
  - Permet de spécifier le dossier parent où créer le projet
  - Exemple : `./scripts/new-project.sh --path ~/projects mon-app`
  - Crée automatiquement le dossier parent s'il n'existe pas (avec confirmation)
  - Mode interactif : demande le dossier si non spécifié

### Corrigé
- **Synchronisation des compteurs dans les scripts**
  - `scripts/new-project.sh` : Compteurs mis à jour (111 commandes, 51 agents, 32 skills)
  - `scripts/install.sh` : Compteurs synchronisés
  - `scripts/learn.sh` : Compteurs synchronisés

---

## [1.6.1] - 2025-01-20

### Ajouté
- **Documentation Docusaurus Orchestrateur**
  - Catégorie "Orchestrateur (2)" dans le sidebar avec `/assistant` et `/assistant-auto`
  - Page `concepts/orchestrator.md` enrichie : guide de décision rapide, workflows par type de projet, agents activés, skills déclenchés
  - Section dédiée dans `commands/index.md` pour mettre en avant le point d'entrée unique

### Modifié
- **Consolidation de la documentation**
  - Suppression des pages dupliquées dans `commands/other/` (contenu fusionné dans orchestrator.md)
  - Liens corrigés dans toute la documentation
- **Compteurs mis à jour**
  - `reference/cheatsheet.md` : 111 Commands, 51 Agents, 32 Skills, 17 Rules
  - `intro/quick-start.md` : 111 commandes
  - `commands/index.md` : 111 commandes en 10 domaines + orchestrateur

### Supprimé
- `website/docs/commands/other/assistant.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/assistant-auto.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/index.md` (dossier supprimé)

---

## [1.6.0] - 2025-01-20

### Ajouté
- **4 nouveaux Agents** (total: 51 agents)
  - `dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `ops-migration` : Migrations de frameworks, versions et dépendances
  - `qa-tech-debt` : Identification et priorisation de la dette technique
- **3 nouveaux Skills** (total: 32 skills)
  - `api-mocking` : Configuration de mocks API avec MSW pour les tests
  - `state-management` : Patterns de state management (Redux, Zustand, Jotai)
  - `tech-debt-management` : Gestion et priorisation de la dette technique
- **1 nouvelle Command** (total: 110 commands)
  - `/ops-rollback` : Procédure de rollback sécurisée (Git, Vercel, K8s, Docker)
- **Documentation Docusaurus**
  - Nouveau chapitre `concepts/orchestrator.md` : Documentation dédiée de `/assistant` comme point d'entrée
  - `docs/README.md` : Index de navigation pour la documentation
  - 9 concepts clés documentés (ajout de l'Orchestrateur)
- **Guides améliorés**
  - `WEB-GUIDE.md` : Ajout section Architecture (React/Next.js et Vue.js)
  - `API-GUIDE.md` : Amélioration phase Testing avec objectifs de couverture

### Modifié
- **WHEN-TO-USE-WHICH-AGENT.md** : Guide de choix enrichi avec les 51 agents
- **CLAUDE.md** : Mise à jour sections agents, skills et commands
- **Concepts index** : L'Orchestrateur est maintenant le 1er concept recommandé aux nouveaux utilisateurs

### Corrigé
- Synchronisation de tous les compteurs dans la documentation (110 commandes, 51 agents, 32 skills)
- Compteurs dans README.md, CHEATSHEET.md, et toute la documentation Docusaurus
- Section legal agents tronquée dans CLAUDE.md

### Statistiques
- Commands: 110 (+1)
- Sub-Agents: 51 (+4)
- Skills: 32 (+3)
- Concepts documentés: 9 (+1 Orchestrateur)

---

## [1.5.0] - 2025-01-19

### Ajouté
- **Proxmox Infrastructure Support**
  - Nouvelle commande `/ops-proxmox` : Gestion complète Proxmox VE (VMs, LXC, réseau, stockage, backup)
  - Nouvel agent `ops-proxmox` : Provisioning infrastructure Proxmox avec Terraform
  - Nouveaux templates Terraform dans `.claude/templates/proxmox/` :
    - `provider-template.tf` : Configuration provider bpg/proxmox
    - `vm-module-template.tf` : Module VM QEMU/KVM avec cloud-init
    - `lxc-module-template.tf` : Module conteneur LXC
    - `infrastructure-template.tf` : Infrastructure complète multi-VMs/LXC
- **Infrastructure as Code**
  - Nouveau skill `infrastructure-as-code` : Terraform/OpenTofu avec best practices
  - Nouvel agent `ops-infra-code` : Création de modules Terraform, gestion state, HCL idiomatique
- **Scripts**
  - `install.sh` : Copie maintenant agents, rules, output-styles, templates
  - `new-project.sh` : Inclut templates et compteurs mis à jour
  - `update.sh` : Support des fichiers `.tf`, `.yaml`, `.yml`, `.json` pour les templates

### Corrigé
- Synchronisation des compteurs dans toute la documentation (109 commandes, 47 agents, 29 skills)
- `learn.sh` : Correction du nombre d'agents (était 85, maintenant 47)
- Documentation Docusaurus : Tous les compteurs mis à jour

### Statistiques
- Commands: 109 (était 108)
- Sub-Agents: 47 (était 45)
- Skills: 29 (était 27)
- Templates: 7 (nouveau dossier proxmox avec 4 templates)

---

## [1.4.1] - 2025-01-18

### Ajouté
- **Scripts**
  - Option `--templates` dans `update.sh` pour synchroniser `.claude/templates/`
  - Inclusion de templates dans `--all`, `--detect-orphans` et `--clean`
- **Documentation**
  - Nouvelle page `docs/concepts/templates.md` documentant les 3 templates de spécification
  - Mise à jour de l'index des concepts (8 concepts au lieu de 7)

### Corrigé
- Templates de spécification (spec, plan, tasks) maintenant synchronisés par `update.sh`

---

## [1.4.0] - 2025-01-18

### Ajouté
- **8 nouveaux Agents** (total: 45 agents)
  - DEV: `dev-design-system`, `dev-prisma`, `dev-trpc`, `dev-prompt-engineering`, `dev-rag`
  - OPS: `ops-serverless`, `ops-vercel`
  - QA: `qa-e2e`
- **3 nouveaux Skills** (total: 27 skills)
  - `e2e-testing` : Tests End-to-End avec Playwright/Cypress
  - `feature-flags` : Gestion de feature flags et déploiement progressif
  - `prompt-engineering` : Optimisation de prompts pour LLMs
- **2 nouvelles Rules** (total: 17 rules)
  - `accessibility.md` : WCAG 2.1 AA, patterns d'accessibilité
  - `performance.md` : Core Web Vitals, optimisation frontend
- **8 nouvelles Commands** (total: 108 commands)
  - `/dev-design-system` : Design tokens et bibliothèque de composants
  - `/dev-prisma` : ORM Prisma (schema, migrations, queries)
  - `/dev-trpc` : APIs type-safe avec tRPC
  - `/dev-prompt-engineering` : Optimisation de prompts LLM
  - `/dev-rag` : Systèmes RAG (Retrieval-Augmented Generation)
  - `/ops-serverless` : Déploiement serverless (Lambda, Vercel, CF Workers)
  - `/ops-vercel` : Configuration et déploiement Vercel
  - `/qa-e2e` : Tests End-to-End avec Playwright ou Cypress
- **Documentation**
  - `docs/QUICKSTART.md` : Guide de démarrage rapide en 5 minutes
  - `WHEN-TO-USE-WHICH-AGENT.md` : Guide de choix des agents

### Corrigé
- Cohérence des chiffres dans la documentation (108/45/27/17)

### Statistiques
- Commands: 108 (était 94)
- Sub-Agents: 45 (était 37)
- Skills: 27 (était 24)
- Rules: 17 (était 15)

---

## [1.3.0] - 2025-01-17

### Ajouté
- **Site de documentation Docusaurus** sur GitHub Pages
  - Documentation complète : 100 commandes, 37 agents, 24 skills, 15 rules
  - Auto-génération depuis les fichiers `.claude/`
  - Déploiement automatique via GitHub Actions
  - URL : https://christopherlouet.github.io/claude-socle/
- **37 Sub-Agents** avec contexte isolé (était 14)
  - DEV: `dev-component`, `dev-test`, `dev-flutter`, `dev-supabase`
  - OPS: `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring`
  - DOC: `doc-generate`, `doc-changelog`, `doc-explain`
  - LEGAL: `legal-rgpd`, `legal-payment`, `legal-privacy-policy`, `legal-terms-of-service`
  - DATA: `data-pipeline`, `data-analytics`, `data-modeling`
  - GROWTH: `growth-analytics`, `growth-landing`, `growth-funnel`
  - BIZ: `biz-mvp`, `biz-personas`
- **24 Skills** avec déclenchement automatique (était 9)
  - `flutter-development`, `supabase-development`, `react-performance`
  - `docker-containerization`, `ci-cd-pipeline`, `database-design`
  - `monitoring-instrumentation`, `documentation-generation`, `changelog-maintenance`
  - `refactoring`, `error-handling`, `graphql-development`
  - `mobile-release`, `data-pipeline`, `performance-optimization`
- **15 Rules modulaires** par langage
  - Nouvelles: `java.md`, `csharp.md`, `ruby.md`, `php.md`, `rust.md`
- **7 Output Styles** documentés avec exemples
  - `teaching`, `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`
- **4 Guides par domaine** dans `docs/guides/`
  - `WEB-GUIDE.md` (React/Next.js/Vue)
  - `MOBILE-GUIDE.md` (Flutter/Clean Architecture)
  - `API-GUIDE.md` (REST/GraphQL)
  - `DATA-GUIDE.md` (ETL/Airflow/dbt)
- **Documentation architecture** (`docs/ARCHITECTURE.md`)
  - Matrice Commands vs Agents vs Skills vs Rules
  - Diagrammes de flux de données
- **Diagrammes workflows** (`docs/WORKFLOWS.md`)
  - Flowcharts ASCII et Mermaid
  - Workflows: Feature, Bugfix, Release, Audit, Mobile, API, Data
- **Setup Wizard** (`scripts/setup-wizard.sh`)
  - Configuration interactive par type de projet
  - Détection automatique des technologies
  - Génération de settings.json personnalisé
- **6 nouvelles commandes OPS**
  - `/ops-grafana-dashboard` : Création dashboards Grafana avec templates
  - `/ops-observability-stack` : Déploiement Prometheus/Grafana/Loki
  - `/ops-k8s` : Déploiement Kubernetes (manifests, Helm)
  - `/ops-vps` : Déploiement VPS (OVH, Hetzner, DigitalOcean)
  - `/ops-mobile-release` : Publication App Store/Google Play avec Fastlane
  - `/growth-app-store-analytics` : Métriques stores mobiles

### Modifié
- **`/assistant`** : Orchestrateur intelligent amélioré
  - Catalogue complet des 94 commandes
  - Détection du type de projet (Web, Mobile, API, Data)
  - Workflows spécifiques par domaine
  - Références aux guides de domaine
- **CLAUDE.md** : Documentation complète mise à jour
  - 94 commandes, 37 agents, 24 skills, 15 rules
  - Section guides et documentation enrichie
- **`/ops-monitoring`** : Enrichi avec instrumentation complète
- Scripts `update.sh`, `validate.sh`, `new-project.sh` améliorés

### Statistiques
- Commands: 94 (était 88)
- Sub-Agents: 37 (était 14)
- Skills: 24 (était 9)
- Rules: 15 (était 10)
- Output Styles: 7 (documentés)
- Guides domaine: 4 (nouveaux)

## [1.2.0] - 2025-01-15

### Ajouté
- **Mode apprentissage interactif** (`learn.sh`) : Tutoriel pour maîtriser claude-socle
  - Tutoriel complet (15-20 min) avec 6 leçons
  - Mode rapide (5 min) pour l'essentiel
  - Apprentissage par agent spécifique (`--agent tdd`, `--agent commit`)
  - Quiz interactifs avec système de score et niveau
  - Couverture : workflow, agents, TDD, Conventional Commits
- **Intégration IDE** (`ide.sh`) : Configuration automatique des IDE
  - Support VSCode/Cursor : settings, tasks, extensions, snippets
  - Support IntelliJ IDEA : run configurations, code style, templates
  - Support Vim/Neovim : abréviations, mappings, autocmds
  - Commandes setup/check/remove pour chaque IDE
  - Option `--force` pour écraser les configurations existantes
- Fichier `.editorconfig` pour formatage cohérent
- Tests bats pour `learn.sh` (40+ tests)
- Tests bats pour `ide.sh` (50+ tests)

### Modifié
- README mis à jour avec documentation des nouvelles fonctionnalités
- Compteur de lignes de tests mis à jour (1664+ lignes)

## [1.1.0] - 2025-01-15

### Ajouté
- **Analyse CI/CD intelligente** : `new-project.sh` analyse maintenant les workflows existants et propose des améliorations
- Fonction `analyze_existing_cicd()` pour détecter 7 aspects de CI/CD (tests, lint, sécurité, cache, coverage, PR, release)
- Fonction `suggest_cicd_improvements()` avec score de qualité CI/CD
- Fonction `merge_cicd_workflows()` pour ajouter uniquement les workflows manquants
- Menu interactif pour choisir entre garder/améliorer/remplacer la CI/CD existante
- Tests bats pour `gitleaks.bats`
- Configuration `.gitleaks.toml` avec 24+ règles de détection de secrets

### Modifié
- `get_options()` propose maintenant des améliorations quand une CI/CD existe
- `create_project()` supporte les actions "merge" et "replace" pour la CI/CD
- Migration de `[ ]` vers `[[ ]]` pour la cohérence bash

### Sécurité
- Hook gitleaks pré-écriture pour détecter les secrets avant commit
- Hook post-commit pour scanner les secrets après commit

## [1.0.0] - 2025-01-14

### Ajouté
- **79 agents Claude Code** organisés par catégorie :
  - WORK (8) : Workflow principal (explore, plan, commit, pr)
  - DEV (10) : Développement (tdd, test, debug, refactor, api)
  - QA (8) : Qualité (review, security, perf, a11y, audit)
  - OPS (16) : Opérations (hotfix, release, deps, docker, ci)
  - DOC (9) : Documentation (generate, changelog, explain, onboard)
  - BIZ (11) : Business (model, market, mvp, pricing, pitch)
  - GROWTH (8) : Croissance (landing, seo, analytics, onboarding)
  - DATA (3) : Données (pipeline, analytics, modeling)
  - LEGAL (5) : Légal (docs, rgpd, payment, terms, privacy)
- **9 skills** avec déclenchement automatique contextuel
- **8 hooks** Claude Code (protection main, auto-format, type-check, gitleaks)
- Script `new-project.sh` pour créer/configurer des projets
- Script `install.sh` pour installer le socle dans un projet existant
- Script `validate.sh` pour valider une configuration Claude Code
- Script `doctor.sh` pour diagnostiquer l'environnement
- Script `diff.sh` pour comparer avec la version installée
- Script `update.sh` pour mettre à jour le socle
- Script `uninstall.sh` pour supprimer la configuration
- Librairie partagée `lib/common.sh` avec 30+ fonctions utilitaires
- 17 templates CLAUDE.md par stack (react, vue, node-api, python, go, rust, java, fullstack)
- Configuration pre-commit avec detect-secrets et commitlint
- Workflows GitHub Actions (ci.yml, pr-check.yml, release.yml)
- Documentation complète (guides, cheatsheet, workflows)

### Configuration
- Permissions granulaires pour Claude Code
- Protection automatique de la branche main/master
- Validation des commits (Conventional Commits)
- Auto-formatage TypeScript/JavaScript après modifications

## Types de changements

- `Ajouté` pour les nouvelles fonctionnalités
- `Modifié` pour les changements aux fonctionnalités existantes
- `Déprécié` pour les fonctionnalités qui seront supprimées
- `Supprimé` pour les fonctionnalités supprimées
- `Corrigé` pour les corrections de bugs
- `Sécurité` pour les vulnérabilités corrigées
