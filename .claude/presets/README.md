# Presets

Curated bundles per stack. Each preset declares which foundation modules to filter, which marketplace plugins to install, and which default flags to apply.

See `specs/presets/spec.md` for the full format specification and `specs/presets/roadmap.md` for the list of presets in pipeline + community-targeted stacks.

## Usage

```bash
./scripts/new-project.sh --preset nextjs ./my-app
./scripts/new-project.sh --preset nextjs --dry-run ./my-app
./scripts/new-project.sh --list-presets
```

`--preset` composes with existing flags:

| Flag combination | Behavior |
|---|---|
| `--preset nextjs` (alone) | Apply preset's defaults (ci, hooks, mcp, docker, designStyle) and foundation filters |
| `--preset nextjs --no-mcp` | Override one default — preset's other defaults still apply |
| `--preset nextjs --type fullstack` | Override the auto-resolved type |
| `--preset nextjs --simple` | Skip preset's foundation filters; install flat with marketplace plugins only |

## Available presets (this repo)

| Preset | Status | Stack |
|---|---|---|
| `nextjs` | maintainer-vouched | Next.js (App Router) + React + TypeScript |
| `homelab-proxmox` | maintainer-vouched | Proxmox VE + Terraform + Ansible + monitoring |
| `cli-tools` | maintainer-vouched | Python or Shell automation, GitHub API helpers, headless scripts |
| `fastapi` | maintainer-vouched | FastAPI + Pydantic + SQLAlchemy/async ORM (Python async backend) |
| `astro` | maintainer-vouched | Astro + TypeScript + Content Collections (content/static-first web) |
| `react-vite-spa` | maintainer-vouched | React + Vite + React Router for Single-Page Apps (no SSR, Capacitor-compatible) |
| `phaser` | vendor-pointer | Phaser 2D web game framework — pointer to `phaserjs/phaser/skills/` |
| `playwright` | vendor-pointer | Playwright end-to-end testing framework — pointer to `microsoft/playwright-cli` (case-by-case vendor-neutrality) |
| `pulumi` | vendor-pointer | Pulumi Infrastructure-as-Code framework — pointer to `pulumi/agent-skills` (single-file detect on `Pulumi.yaml`) |
| `apollo` | vendor-pointer | Apollo GraphQL Client — pointer to `apollographql/skills` (detect on `@apollo/client`; server-side documented in outOfScope) |
| `mongodb` | vendor-pointer | MongoDB Node.js driver — pointer to `mongodb/agent-skills` (colon-anchored substring `"mongodb":` to avoid false positives on `mongodb-memory-server` etc.) |

### Category-based pre-prompt

When a user runs `claude-base init ./empty-dir` interactively without `--preset` or `--type`, and auto-detection produces no match, a pre-prompt asks "What are you building?" with an 8-entry intent taxonomy (Web frontend / API-Backend / Mobile-Desktop / Game-Interactive media / Data-Database / Infra-DevOps / CLI-Automation / Other-Generic). The chosen category filters the subsequent menu down to relevant presets and types. A preset opts in by declaring `categories: [string]` in its manifest (strict enum validated by `validate-presets.sh`). Presets without `categories[]` remain accessible via auto-detection, `--preset` flag, and `claude-base preset list` (soft migration). Spec: [`specs/preset-category-prompt/spec.md`](../../specs/preset-category-prompt/spec.md).

The 6 maintainer-vouched presets cover the maintainer's actual production usage. The 5 vendor-pointer presets (`phaser`, `playwright`, `pulumi`, `apollo`, `mongodb`) surface vendor-published skill suites at install time without a maintainer prod-use claim — their authority comes from the vendor's authorship of the pointed-to skill, validated via the marketplace-audit methodology. See [`specs/presets-vendor-pointer-tier/spec.md`](../../specs/presets-vendor-pointer-tier/spec.md) for the tier definition. For other stacks (Django, Rails, Laravel, SvelteKit, Vue/Nuxt, Spring Boot, Phoenix, Go-Gin, Rust-Axum, Flutter, etc.), community contributions are welcomed — see `specs/presets/roadmap.md`.

## Community presets

Community contributions land under `.claude/presets/community/` after maintainer review against `specs/presets/spec.md`. Status: `community-curated`. To propose one, open an issue first describing the stack, target audience and the marketplace plugins you'd bundle.

## Format quick reference

```json
{
  "name": "<stack-specific-lowercase-with-hyphens>",
  "displayName": "<short human-readable>",
  "description": "<2-3 lines, explicit about scope, names what is OUT>",
  "status": "maintainer-vouched | community-curated | vendor-pointer | draft",
  "appliesToTypes": ["<existing claude-base type>"],
  "detect": {
    "combinator": "anyOf",
    "files": ["<config-file>", "<glob.*>"],
    "depFiles": [
      {"path": "<dep-manifest>", "contains": "<substring>"}
    ]
  },
  "foundation": {
    "skills":   { "drop": ["<skill-to-not-install>"] },
    "commands": { "drop": ["<command-to-not-install>", "domain:<whole-domain>"] },
    "agents":   { "drop": ["<agent-to-not-install>"] }
  },
  "marketplacePlugins": [],
  "defaults": { "ci": true, "hooks": true, "mcp": false, "docker": false, "designStyle": "editorial" },
  "outOfScope": ["<what this preset deliberately does not cover>"],
  "relatedPresetsWanted": ["<stack-name>"]
}
```

The `foundation.skills` filter supports two mutually-exclusive forms: `drop` (blacklist — install every foundation skill except those listed) or `keep` (whitelist — install only the listed skills). `validate-presets.sh` rejects a manifest declaring both. See `react-vite-spa.json` for a `keep`-style example and the other shipped presets for `drop`-style.

### `foundation.commands` / `foundation.agents` (optional)

Scope the installed catalog of commands and agents exactly like `foundation.skills`, with the same mutually-exclusive `drop` / `keep` polarity. Two entry forms are accepted:

- **Exact item name** — `"dev-flutter"`, `"data-pipeline"` (the file basename without `.md`).
- **Whole domain** — `"domain:ops"` matches every `commands/ops/*.md` (and every `ops-*` agent).

Rules enforced by `validate-presets.sh`:

- **`drop` XOR `keep`** — declaring both is an error.
- **Protected floor (EF-111)** — the `work` command domain plus `assistant`/`assistant-auto` can never be removed; a `drop` targeting them is rejected.
- **Module-owned items stay with modules** — a filter targeting any module-owned item is rejected; use `defaultModules` instead. This covers the horizontal domains (`domain:biz` / `domain:legal` / `domain:growth`) **and** any cross-domain thematic-module item (`dev-flutter`, `ops-proxmox`, `data-pipeline`, …) whose own domain is not itself a module. The rejection names the owning module.
- **Vendor-pointer tier** — may not declare command/agent filters (inherits foundation wholesale).
- Unknown item names produce a non-fatal `[WARN]`.

Behaviour: filters apply at `init` **and** on `claude-base update` (excluded items are skipped, COPY-only — never deleting on-disk; `update --no-preset` re-installs the full catalog). See `.claude/presets/nextjs.json` for the shipped worked example.

> **Keep the three drop lists in sync per stack.** A stack preset typically drops a skill *and* its command *and* its agent counterpart together. The lists are validated independently (no enforced coupling), and the mapping is **not** always 1:1 — e.g. `ops-mobile-release` ships as a skill and a command but has no agent, so it belongs in `skills.drop`/`commands.drop` but not `agents.drop`. When adding a new other-stack exclusion, check whether each catalog actually has a counterpart before listing it (a missing counterpart only triggers a harmless `[WARN]`).

### `defaultModules` (optional)

A **module** is a named, opt-in, composable bundle. Since v4.0.0 a module may span
several domains (`module ≠ domain`): a default install ships the **minimal universal
core only**, and everything platform/stack-specific is an opt-in module. A preset
declares which modules its stack needs:

```json
"defaultModules": ["api-data", "frontend"]
```

**The 15 modules:**

| Kind | Modules |
|------|---------|
| Horizontal domains | `biz`, `legal`, `growth` |
| Thematic (cross-domain) | `mobile`, `self-hosted`, `iac`, `data-eng`, `observability`, `editor`, `api-data`, `ai`, `frontend`, `nextjs`, `flutter`, `gitflow` |

**Mutually-exclusive grain.** A mutually-exclusive choice (a framework, or an alternative workflow) is its own opt-in unit rather than an item bundled into a broader agnostic module — a project picks one, so it should opt in to one:
- `frontend` = framework-agnostic React tooling (React-perf, shadcn, design); `nextjs` = the Next.js framework. A Next.js preset opts into `frontend` **and** `nextjs`; Astro/Vite-SPA opt into `frontend` only.
- `mobile` = framework-agnostic app lifecycle (store release, testing); `flutter` = the Flutter framework. A Flutter preset opts into `mobile` **and** `flutter`.
- `gitflow` = the GitFlow branching model (init/feature/release/hotfix), incompatible with the foundation's default trunk-ish flow — opt in only if your project uses GitFlow.

(An **additive** library — shadcn, Prisma — stays grouped in its theme; only a mutually-exclusive choice earns its own module.)

- **Absent (key not declared)** → **no modules** installed (opt-in default). The init
  summary prints a `claude-base add <mod>` hint for every available module.
- **Empty array (`[]`)** → same as absent: **zero** modules installed.
- **Non-empty array** → only the listed modules are installed and recorded in
  `foundation.json`; init summary prints a `claude-base add <mod>` hint for
  each available-but-not-installed module.
- **Restore after install** → `claude-base add <module>` at any time; an existing
  project crossing the v4.0.0 update stops tracking the now-modularised items
  (files left in place, COPY-only) until re-added.
- **Allowed values**: any of the 15 module names above.
- **Forbidden** on `vendor-pointer` tier (tier inheritance rule — vendor-pointer
  presets inherit foundation defaults wholesale).
- `validate-presets.sh` rejects unknown names and non-array values.

Field naming is camelCase (matches `settings.json` and other Claude Code config files). Validation runs via `scripts/validate-presets.sh` (jq-based schema check, executed in CI).

### `detect` block (data-driven detection)

Optional. When present, every available preset is evaluated against the target directory whenever `claude-base init` runs without `--preset`. Matching presets are surfaced as additional menu entries (interactive mode) or as an info banner (non-interactive). When `--preset <name>` is passed explicitly, detection is skipped entirely.

| Field | Type | Notes |
|---|---|---|
| `combinator` | string | `allOf` (every signal must match) or `anyOf` (at least one). Defaults to `anyOf` when omitted. |
| `files` | array of strings | File names or simple globs (e.g. `next.config.*`). A signal matches when the named file exists (recursive search up to depth 2) in the target dir. |
| `depFiles` | array of `{path, contains}` | A signal matches when `<path>` exists in the target dir AND its contents contain `<contains>` (case-insensitive, fixed-string). |

At least one of `files` or `depFiles` MUST contain a non-empty signal — a `detect` block with no signals is meaningless and rejected by `validate-presets.sh`.

#### Worked examples

**Next.js — file presence OR dependency match (anyOf):**

```json
"detect": {
  "combinator": "anyOf",
  "files": ["next.config.js", "next.config.mjs", "next.config.ts"],
  "depFiles": [
    {"path": "package.json", "contains": "\"next\""}
  ]
}
```

**FastAPI — dependency match across three Python manifest formats:**

```json
"detect": {
  "combinator": "anyOf",
  "depFiles": [
    {"path": "requirements.txt", "contains": "fastapi"},
    {"path": "pyproject.toml",   "contains": "fastapi"},
    {"path": "Pipfile",          "contains": "fastapi"}
  ]
}
```

**Standalone audit:** `claude-base init --detect-only <path>` prints which presets would match the given directory without performing any install.

**Drift-guard:** every preset that ships a `detect` block also ships a paired fixture under `tests/presets-fixtures/<preset>/` and a test asserting the rule matches its own fixture. If upstream renames a marker file (e.g. Astro changes `astro.config.mjs`), the paired test fails loudly.
