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

The 6 maintainer-vouched presets cover the maintainer's actual production usage. The 1 vendor-pointer preset (`phaser`) surfaces a vendor-published skill suite at install time without a maintainer prod-use claim — its authority comes from the vendor's authorship of the pointed-to skill, validated via the marketplace-audit methodology. See [`specs/presets-vendor-pointer-tier/spec.md`](../../specs/presets-vendor-pointer-tier/spec.md) for the tier definition. For other stacks (Django, Rails, Laravel, SvelteKit, Vue/Nuxt, Spring Boot, Phoenix, Go-Gin, Rust-Axum, Flutter, etc.), community contributions are welcomed — see `specs/presets/roadmap.md`.

## Community presets

Community contributions land under `.claude/presets/community/` after maintainer review against `specs/presets/spec.md`. Status: `community-curated`. To propose one, open an issue first describing the stack, target audience and the marketplace plugins you'd bundle.

## Format quick reference

```json
{
  "name": "<stack-specific-lowercase-with-hyphens>",
  "displayName": "<short human-readable>",
  "description": "<2-3 lines, explicit about scope, names what is OUT>",
  "status": "maintainer-vouched | community-curated | draft",
  "appliesToTypes": ["<existing claude-base type>"],
  "detect": {
    "combinator": "anyOf",
    "files": ["<config-file>", "<glob.*>"],
    "depFiles": [
      {"path": "<dep-manifest>", "contains": "<substring>"}
    ]
  },
  "foundation": {
    "skills": { "drop": ["<skill-to-not-install>"] }
  },
  "marketplacePlugins": [],
  "defaults": { "ci": true, "hooks": true, "mcp": false, "docker": false, "designStyle": "editorial" },
  "outOfScope": ["<what this preset deliberately does not cover>"],
  "relatedPresetsWanted": ["<stack-name>"]
}
```

The `foundation.skills` filter supports two mutually-exclusive forms: `drop` (blacklist — install every foundation skill except those listed) or `keep` (whitelist — install only the listed skills). `validate-presets.sh` rejects a manifest declaring both. See `react-vite-spa.json` for a `keep`-style example and the other shipped presets for `drop`-style.

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
