# Spec: presets — curated bundles per stack

**Status**: Draft (planning, not yet validated)
**Date**: 2026-05-04
**Owner**: Chris

---

## Summary

A **preset** is a curated bundle that, for one specific stack (e.g. Next.js, Proxmox+Terraform, Python CLI tools), declares:

1. Which **foundation modules** to enable (rules, commands, agents, skills filters)
2. Which **marketplace plugins** to install on top via `claude plugin install`
3. Which **default flags** to set (CI, hooks, MCP, Docker, design style)

Presets are the answer to a recurring user question: *"I have a Next.js SaaS / a Proxmox homelab / a Python automation tool — what should I install on top of claude-base to be productive immediately?"*

This spec defines the **format** and the **install mechanism**. No actual preset `.json` ships in this spec's PR — concrete presets land in dedicated follow-up PRs (one per preset) so each one gets focused review and lives or dies on its own merits. See `specs/presets/roadmap.md` for the list of presets in pipeline + community-targeted stacks.

## Goals

- **Honest curation**: each preset names its stack explicitly. No `web-app`, no `mobile-app`, no `backend-app`. Stack-specific names only (`nextjs`, `homelab-proxmox`, `cli-tools`, etc.).
- **No claim of universal coverage**: every preset acknowledges what it does NOT cover, points to roadmap for community-contributed alternatives.
- **Layered on existing infrastructure**: extend the existing `--type` / `get_rules_for_type()` / minimal-manifest patterns, do not rebuild from scratch.
- **Quality over volume**: ship presets only for stacks the maintainer can vouch for from production use. The rest is community-driven.
- **Reversible**: every preset is opt-in via `--preset` flag. Default `new-project.sh` behavior unchanged.

## Non-goals

- Auto-detection of which preset to use (would need heuristics that fail subtly). User picks explicitly via flag.
- Marketplace plugin management beyond install (no auto-update logic, that's the plugin system's job).
- Per-preset CI matrix (each preset is a config, not a runtime; no separate CI per preset).
- Forced replacement of existing `--type` flag (presets COMPOSE with `--type`, not replace it).
- Mobile / desktop presets in MVP. Out of scope until a maintainer or contributor uses them in prod.

## Format

### File location

```
.claude/presets/
├── nextjs.json                  # Maintainer-vouched (in pipeline, ships in follow-up PR)
├── homelab-proxmox.json         # Maintainer-vouched (in pipeline)
├── cli-tools.json               # Maintainer-vouched (in pipeline)
├── community/                   # Future home for community-contributed presets
│   └── README.md                # Explains contribution requirements
└── README.md                    # Format reference, points to spec.md
```

### JSON schema

Format chosen: JSON. Rationale: `jq` is already a hard dependency of the foundation (used by 4+ hooks, `update.sh`, `validate-counts.sh`), `yq` is not. JSON+jq is consistent with `settings.json`, `.mcp.json`, `counts.json`. The `rationale` field on each plugin replaces what would have been a YAML inline comment, making the curation reasoning structured and queryable.

```json
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",

  "name": "nextjs",
  "displayName": "Next.js full-stack",
  "description": "Next.js (App Router) + React + TypeScript. Includes auth scaffolding, database access patterns, and Vercel deploy. Does NOT bundle payment or subscription logic — see docs/recipes/saas-monetization.md if needed.",

  "version": "1.0.0",
  "status": "maintainer-vouched",

  "author": {
    "name": "Chris",
    "github": "christopherlouet"
  },

  "appliesToTypes": ["react", "fullstack"],

  "foundation": {
    "rules": [
      "typescript",
      "react",
      "nextjs",
      "accessibility",
      "performance",
      "security"
    ],
    "commands": {
      "domains": ["work", "dev", "qa", "ops", "growth", "doc"],
      "excludes": []
    },
    "agents": {
      "domains": ["work", "dev", "qa", "ops", "growth", "doc"]
    },
    "skills": {
      "keep": [
        "dev-shadcn",
        "dev-nextjs",
        "dev-prisma",
        "dev-react-perf",
        "growth-cro"
      ]
    }
  },

  "marketplacePlugins": [
    {
      "id": "anthropic-official/vercel-deploy",
      "rationale": "Deploy preview + production via Vercel CLI",
      "install": "claude plugin install anthropic-official/vercel-deploy",
      "optional": false
    },
    {
      "id": "supabase/auth-helpers",
      "rationale": "Auth flows + RLS templates",
      "install": "claude plugin install supabase/auth-helpers",
      "optional": true
    }
  ],

  "recommendedVendorSkills": [
    {
      "id": "vercel-labs/agent-skills",
      "url": "https://github.com/vercel-labs/agent-skills",
      "rationale": "Canonical Next.js + React patterns from Vercel Engineering",
      "condition": "always"
    },
    {
      "id": "supabase/agent-skills",
      "url": "https://github.com/supabase/agent-skills",
      "rationale": "Auth, DB, Edge Functions, Storage patterns + Postgres best practices",
      "condition": "if using Supabase"
    }
  ],

  "defaults": {
    "ci": true,
    "hooks": true,
    "mcp": true,
    "docker": false,
    "designStyle": "editorial"
  },

  "outOfScope": [
    "Payment processing (Stripe, etc.)",
    "Native mobile companion (use a flutter or swift preset)",
    "Backend in non-Node languages"
  ],

  "relatedPresetsWanted": [
    "astro",
    "sveltekit",
    "vue-nuxt",
    "django",
    "rails",
    "laravel"
  ]
}
```

### Field naming

JSON convention is camelCase (`appliesToTypes`, `marketplacePlugins`, `designStyle`, `outOfScope`, `relatedPresetsWanted`). This matches the existing `settings.json` / Claude Code config style. Bash readers use `jq` queries: `jq -r '.foundation.rules[]'`, `jq -r '.marketplacePlugins[].id'`, etc.

### Mandatory fields

| Field | Why |
|---|---|
| `name` | Stack-specific, never aspirational |
| `description` | 2-3 lines naming what's in AND what's out |
| `status` | Sets reader's expectation about quality bar |
| `applies_to_types` | Composes with existing `--type` |
| `foundation.rules` | Drives the existing `get_rules_for_type` filter |
| `marketplace_plugins[].why` | Forces the curator to justify each plugin |
| `out_of_scope` | The honesty gate — no preset can claim everything |

The optional **`recommendedVendorSkills`** field (added in v1.36.0) is an array of validated community/vendor skills the user is encouraged to install alongside the preset. It is **printed at the end of `claude-base init`** but never auto-installed. Each entry has `id` (vendor's skill identifier), `url` (canonical source), `rationale` (one-line justification), and `condition` (e.g. `"always"` or `"if using Supabase"`). The `"always"` recommendations print first as "Always pair with this preset"; conditional ones print under "Add if your project uses these tools." Sources for these recommendations come from the marketplace audit pilots in `specs/marketplace-audit/*-pilot-*.md`. The audit methodology (vendor-neutrality filter, etc.) is the gatekeeper for what enters this list.

### Status tiers

| Status | Quality bar | Visible to default users |
|---|---|---|
| `maintainer-vouched` | Maintainer uses it in prod, ≥3 months, monthly review | Yes, in `.claude/presets/` |
| `community-curated` | Contributor uses it in prod, signed maintenance commitment | Yes, in `.claude/presets/community/` |
| `draft` | Skeleton, marketplace plugins not yet verified | No (hidden behind `--include-draft` flag) |

## Install mechanism

### CLI surface

```bash
# Install foundation with a preset (composes with existing flags)
./scripts/new-project.sh --preset nextjs ./my-app
./scripts/new-project.sh --preset homelab-proxmox --no-mcp ./my-infra
./scripts/new-project.sh --preset cli-tools --simple ./my-tool

# List available presets
./scripts/new-project.sh --list-presets

# Show what a preset includes without installing
./scripts/new-project.sh --preset nextjs --dry-run
```

### Resolution order

1. `--preset` flag is resolved against `.claude/presets/<name>.json`, then `.claude/presets/community/<name>.json`
2. If not found: list available presets and exit with code 2
3. If found:
   a. Set `--type` from `applies_to_types[0]` if `--type` not already passed
   b. Apply `defaults` (CI, hooks, MCP, Docker, design_style) unless user overrode
   c. Filter rules/commands/agents/skills per `foundation.*`
   d. Run normal install (existing `install_claude_files` flow)
   e. After install: chain `claude plugin install <id>` for each non-`optional: true` marketplace plugin
   f. Print summary: which plugins installed, which skipped (optional + user said no), where to read recipes
4. `--dry-run` short-circuits at step (e) and prints what would happen

### Plugin install handling

- Maintainer-vouched presets: required plugins are installed automatically. User confirmation (y/N) before each install batch.
- Community-curated: BOTH required AND optional plugins ask user confirmation per plugin (extra caution).
- Plugin install failure is non-fatal: print warning, continue. User can retry manually.
- Capability check: if `claude plugin install` is not available (CLI < 2.1.119), preset install warns and skips the plugin step. Foundation install still completes.

## Composition with existing flags

| Existing flag | Behavior with `--preset` |
|---|---|
| `-t, --type` | If passed, overrides preset's `applies_to_types` |
| `--ci` / `--hooks` / `--mcp` / `--docker` | If passed, overrides preset's `defaults` |
| `--style <name>` | If passed, overrides preset's `defaults.design_style` |
| `--simple` | Skips preset's `foundation.*` filters; installs flat (preset reduced to plugin install only) |
| `--minimal` | Conflicts with `--preset`; one or the other |
| `--skip-prompts` | Preset install proceeds without per-plugin confirmation |
| `--dry-run` | Compatible; shows full preset plan |

## Versioning

- Presets ship versioned with claude-base releases. `nextjs.json` from v1.32 → ships in `claude-base@1.32`.
- A preset's `version:` field defaults to claude-base's version unless explicitly set (community-curated presets MAY pin earlier versions if they need stability).
- Breaking changes to a preset (e.g. dropping a marketplace plugin a user relied on) are flagged in the CHANGELOG and trigger a minor bump.
- No per-preset semver tree at MVP. If demand emerges, can be added later via the `version:` field.

## Tooling

- `./scripts/new-project.sh --list-presets` — list installed presets with status, displayName
- `./scripts/validate-presets.sh` (new, ~50 LOC) — validate every preset JSON against the schema (jq queries on required fields, type checks, enum checks for `status`), fail CI if invalid. Lives under `scripts/`.
- `tests/presets.bats` — for each preset, dry-run install in tmp dir, verify expected files copied, verify plugin list parsed.

## Risks

| Risk | Mitigation |
|---|---|
| Marketplace plugin gets abandoned/compromised | Quarterly review of every preset's plugins. Pin to specific git refs when possible. Status tier visible. |
| User installs preset, plugin install fails halfway | Foundation install completes first; plugin install is post-step. Failure is loud but non-fatal. |
| Maintainer ships fake "vouched" preset for stack they don't really use | Status tiers explicit. PR review enforces. CONTRIBUTING.md acceptance criteria mandate ≥3 months prod use claim. |
| Preset JSON schema drift over time | `scripts/validate-presets.sh` in CI prevents drift. Schema versioned in spec. JSON Schema file at `specs/presets/schema.json` may be added later for stricter validation. |
| Community feels stacks they care about are missing | `related_presets_wanted` field + dedicated roadmap doc + active contribution invitation. |
| `--preset` clashes with future native plugin system | Compatible: presets layer foundation + native plugin install. If foundation is later ported, preset becomes plugin-of-plugins. |

## Success criteria

- Spec accepted, schema stabilized.
- 3 maintainer-vouched presets in pipeline (`nextjs`, `homelab-proxmox`, `cli-tools`) shipped via dedicated follow-up PRs over the following 2-3 weeks.
- At least 1 community-contributed preset accepted within 6 months of MVP.
- Zero CI / `validate-counts.sh` / `audit-base.sh` regression on any preset PR.
- README + EXTENDING-GUIDE link to `specs/presets/roadmap.md` so the community can find the contribution path.

## Clarification points

1. **Should `--preset` and `--type` be mutually exclusive, or compose?** Default proposal: compose (preset sets type if `--type` absent, user override wins). Alternative: hard error if both passed (more predictable).
2. **Plugin install confirmation**: per-plugin (5 prompts for a preset with 5 plugins) or batched (one prompt with the list)? Default proposal: batched.
3. **Community preset acceptance criteria**: should we require the contributor to be the upstream maintainer of at least ONE marketplace plugin used in their preset? Default proposal: no, but they must have ≥3 months prod use claim and commit to quarterly review for ≥1 year.
