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

Presets in pipeline (next PRs): `cli-tools`. See `specs/presets/roadmap.md`.

## Community presets

Community contributions land under `.claude/presets/community/` after maintainer review against `specs/presets/spec.md`. Status: `community-curated`. To propose one, open an issue first describing the stack, target audience and the marketplace plugins you'd bundle.

## Format quick reference

```json
{
  "name": "<stack-specific-lowercase-with-hyphens>",
  "displayName": "<short human-readable>",
  "description": "<2-3 lines, explicit about scope, names what is OUT>",
  "status": "maintainer-vouched | community-curated | draft",
  "appliesToTypes": ["<existing claude-socle type>"],
  "foundation": {
    "skills": { "drop": ["<skill-to-not-install>"] }
  },
  "marketplacePlugins": [],
  "defaults": { "ci": true, "hooks": true, "mcp": false, "docker": false, "designStyle": "editorial" },
  "outOfScope": ["<what this preset deliberately does not cover>"],
  "relatedPresetsWanted": ["<stack-name>"]
}
```

Field naming is camelCase (matches `settings.json` and other Claude Code config files). Validation runs via `scripts/validate-presets.sh` (jq-based schema check, executed in CI).
