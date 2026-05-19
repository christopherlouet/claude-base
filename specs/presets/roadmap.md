# Presets — roadmap & invitation

**Date**: 2026-05-05
**Status**: Living document — updated as presets ship or community proposals land.

---

## Shipped (maintainer-vouched)

| Preset | Stack | Shipped in |
|---|---|---|
| `nextjs` | Next.js (App Router) + React + TypeScript | v1.32.0 (PR #119) |
| `homelab-proxmox` | Proxmox VE + Terraform + Ansible + monitoring | v1.32.0 (PR #120) |
| `cli-tools` | Python or Shell automation, GitHub API helpers, headless scripts | v1.32.0 (PR #121) |
| `fastapi` | FastAPI + Pydantic + SQLAlchemy/async ORM (Python async backend) | v1.33.0 (PR #132) |
| `astro` | Astro + TypeScript + Content Collections (content/static-first web) | v1.35.0 |
| `react-vite-spa` | React + Vite + React Router for Single-Page Apps (no SSR, Capacitor-compatible) | v1.39.0 (PR #178) |

Each shipped preset has:
- `.json` manifest under `.claude/presets/`
- `tests/presets.bats` test entries (≥6 per preset)
- Entry in `.claude/presets/README.md`
- Entry in `CHANGELOG.md`

## Shipped (vendor-pointer)

| Preset | Stack | Shipped in |
|---|---|---|
| `phaser` | Phaser 2D web game framework — pointer to `phaserjs/phaser/skills/` | v1.40.0 (PR #185) |
| `playwright` | Playwright end-to-end testing framework — pointer to `microsoft/playwright-cli` | v1.40.0 (PR #188) |
| `pulumi` | Pulumi Infrastructure-as-Code framework — pointer to `pulumi/agent-skills` | v1.40.0 (PR #189) |
| `apollo` | Apollo GraphQL Client — pointer to `apollographql/skills` | v1.40.0 (PR #190) |
| `mongodb` | MongoDB Node.js driver — pointer to `mongodb/agent-skills` | v1.40.0 (this PR) |

The `vendor-pointer` tier is for thin pointer-only manifests whose authority comes from the vendor (validated via the marketplace-audit methodology), not from maintainer production use. See [`specs/presets-vendor-pointer-tier/spec.md`](../presets-vendor-pointer-tier/spec.md) for the tier definition.

Each shipped vendor-pointer preset has:
- `.json` manifest under `.claude/presets/`
- A positive bats test + a fixture-pairing test under `tests/presets-fixtures/<preset>/`
- Entry in `.claude/presets/README.md`
- Entry in `CHANGELOG.md`
- The pointed-to vendor source already validated in `docs/recipes/recommended-vendor-skills.md`

## Category taxonomy

Locked 8-entry intent enum, mirrored by the pre-detection category prompt in `scripts/lib/category-map.sh` and enforced by `validate-presets.sh` (strict enum on the optional `categories[]` field of preset manifests). The drift-guard bats test ([`tests/presets.bats`](../../tests/presets.bats) T013) reads both this section and the library at every CI run.

| Slug | Display label | Maps to roadmap section |
|---|---|---|
| `web-frontend` | Web frontend | Web frameworks (alternatives to Next.js) |
| `api-backend` | API / Backend | Backend frameworks (non-Node) |
| `mobile-desktop` | Mobile / Desktop | Mobile / Desktop |
| `game-interactive-media` | Game / Interactive media | Game / Interactive media |
| `data-database` | Data / Database | (Other infra / data — database side) |
| `infra-devops` | Infra / DevOps | Other infra / data |
| `cli-automation` | CLI / Automation | (CLI tools — covered by the `cli-tools` preset) |
| `other-generic` | Other / Generic | Fallback (full unfiltered menu) |

A preset declares `categories: [string]` to opt into the filtered menu. Multi-category is allowed for legitimately cross-cutting presets. Spec at [`specs/preset-category-prompt/spec.md`](../preset-category-prompt/spec.md).

## What is NOT covered (stacks where contributions are wanted)

These stacks **do not have a preset yet, and won't until either** (a) a maintainer adopts them in production, or (b) a community contributor ships one with a maintenance commitment. Naming them here is the explicit signal that we know they exist and want them.

### Web frameworks (alternatives to Next.js)

| Stack | Why we don't have it yet |
|---|---|
| **SvelteKit** | Different reactivity model. No prod use yet. |
| **Vue / Nuxt** | Major community we don't represent. Open to a contributor with prod experience. |
| **Remix** | Now under React Router umbrella; status uncertain. Open to a contributor. |
| **Qwik / Solid** | Resumable / fine-grained reactivity. Niche but vocal community. |

### Backend frameworks (non-Node)

| Stack | Why we don't have it yet |
|---|---|
| **Django** | Full-fat Python web. Maintainer hasn't shipped a Django app. |
| **Flask** | Lighter Python web. Maintainer's prod usage skewed to FastAPI; Flask preset open to a contributor. |
| **Rails** | Ruby. Iconic stack; no prod experience at maintainer level. |
| **Laravel** | PHP. Open to a contributor with prod experience. |
| **Spring Boot** | Java enterprise. Open to a contributor. |
| **Phoenix** | Elixir. Smaller community but very loyal. |
| **Gin / Echo / Fiber** | Go web frameworks. Open to contributor. |
| **Axum / Actix** | Rust web frameworks. Open to contributor. |
| **ASP.NET Core** | C# / .NET. Open to contributor. |

### Mobile / Desktop

| Stack | Why we don't have it yet |
|---|---|
| **Flutter** | Maintainer doesn't ship mobile. Highest community demand. |
| **React Native** | Same. |
| **Swift / iOS** | Native iOS. Different toolchain. |
| **Kotlin / Android** | Native Android. |
| **Tauri / Electron** | Desktop wrappers. |

### Other infra / data

| Stack | Why we don't have it yet |
|---|---|
| **Kubernetes (general)** | We have `homelab-proxmox` but not a generic k8s preset. |
| **Vercel-only / serverless** | Could overlap with `nextjs`; intentionally separate. |
| **Data pipelines (dbt / Airflow / Dagster)** | Out of maintainer's stack. |
| **AI / RAG pipelines** | Specific enough to warrant its own preset. |

### Game / Interactive media

| Stack | Why we don't have it yet |
|---|---|
| **2D web game framework (generic)** | No maintainer production use yet. The canonical vendor (Phaser Studio Inc., MIT-licensed) publishes its own skill suite — see `docs/recipes/recommended-vendor-skills.md` §"Phaser". A preset would need a contributor with ≥3 months production use on a Phaser-based game. |

Contributions welcome — see `## How to contribute a preset` below.

If your daily stack isn't here, it's exactly the kind of contribution that would expand claude-base's honest coverage.

## How to contribute a preset

1. **Read** `specs/presets/spec.md` (format + status tiers)
2. **Use the stack in production for ≥3 months** before proposing a preset (the quality bar)
3. **Open an issue first** describing the stack, target audience, and the marketplace plugins you'd bundle (with rationale per plugin)
4. **Wait for maintainer feedback** — we may suggest narrowing scope, splitting into multiple presets, or merging with an existing one
5. **Submit a PR** with:
   - `.claude/presets/community/<name>.json` (status: `community-curated`)
   - `tests/presets.bats` test entry
   - `docs/recipes/<name>-<scenario>.md` if relevant
   - Maintenance commitment statement in PR description (commit to quarterly review for ≥1 year)
6. **Maintainer reviews** the JSON manifest against the spec, the marketplace plugins for trustworthiness, and the test for correctness
7. On acceptance, the preset moves to `.claude/presets/community/` and ships in the next minor release

A formal `specs/presets/contributing.md` document with full criteria will land alongside the first community preset proposal — until then, this section is the contract.

## Maintenance discipline

Every preset (vouched or community) is subject to:

- **Quarterly review** of marketplace plugins (still maintained? still recommended?)
- **CI run** on every PR touching the preset (`scripts/validate-presets.sh`)
- **Removal path** if the underlying stack falls out of use or marketplace plugins die. Removal is a minor-version event with a deprecation period.

## What this roadmap is NOT

- A promise to ship every named stack. Naming is acknowledgment, not commitment.
- A scoring of which stacks "matter most". Order in tables is alphabetical or by category, not preference.
- A statement that the listed stacks are inferior or superior to anything. Each ecosystem has its own merits.
- A complete index of frameworks. The list will grow as contributors propose additions.

## Quick reference (count)

| Category | Shipped | Community-wanted |
|---|---|---|
| JS web frameworks | 3 (`nextjs`, `astro`, `react-vite-spa`) | 4+ |
| Non-Node backend frameworks | 1 (`fastapi`) | 8+ |
| Infrastructure / homelab | 1 (`homelab-proxmox`) | 3+ |
| CLI / automation | 1 (`cli-tools`) | — |
| Mobile / desktop | 0 | 5+ |
| Data / AI pipelines | 0 | 2+ |
| Game / Interactive media | 0 | 1+ |
| Vendor-pointer presets | 5 (`phaser`, `playwright`, `pulumi`, `apollo`, `mongodb`) | 1+ |

**6 maintainer-vouched + 5 vendor-pointer = 11 shipped. 24+ named as community-wanted** (23+ maintainer-vouched candidates + 1+ vendor-pointer candidates). That ratio is the foundation's honest position.

## Vendor-pointer candidates

These vendors already have validated entries in [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md) and could become `vendor-pointer` presets in future PRs following the same pattern as `phaser`. Each is its own PR; this list is acknowledgment, not commitment.

| Vendor | Recipe source | Candidate detect rule |
|---|---|---|
| ~~**Apollo GraphQL**~~ | ~~`apollographql/skills`~~ | ~~`package.json contains "@apollo/client"` (dominant package)~~ — **shipped as `apollo` preset** |
| ~~**Microsoft Playwright**~~ | ~~`microsoft/playwright-cli`~~ | ~~`package.json contains "@playwright/test"`~~ — **shipped as `playwright` preset** |
| ~~**Pulumi**~~ | ~~`pulumi/agent-skills`~~ | ~~single-file detect on `Pulumi.yaml`~~ — **shipped as `pulumi` preset** |
| ~~**MongoDB**~~ | ~~`mongodb/agent-skills`~~ | ~~`package.json contains "mongodb"`~~ — **shipped as `mongodb` preset** (substring colon-anchored to `"mongodb":` to disambiguate from `mongodb-memory-server` etc.; `mongoose` ODM remains a separate hypothetical candidate) |
| **Grafana Labs** | `grafana/skills` | TBD per project shape — likely a single config-file pattern |

Each candidate would ship as its own PR + spec amendment, not in this initial batch.
