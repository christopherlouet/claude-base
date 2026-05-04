# Presets — roadmap & invitation

**Date**: 2026-05-04
**Status**: Living document — updated as presets ship or community proposals land.

---

## What ships now (in this PR)

**Zero preset `.json` files.** Only the format spec (`spec.md`) and this roadmap. Each concrete preset lands in its own dedicated follow-up PR so it can be reviewed atomically and held to its own quality bar.

This deliberate decoupling avoids two anti-patterns:
- Shipping fake or skeleton presets to "look complete" at MVP launch.
- Ossifying the format around assumptions only proven once the first real preset is built.

## What ships next (maintainer-vouched, in pipeline)

These three presets are committed to land in dedicated follow-up PRs over the next 2-3 weeks. Each one reflects a stack the maintainer uses in production today.

| Preset | Stack | What it bundles | Tracking |
|---|---|---|---|
| `nextjs` | Next.js (App Router) + React + TypeScript | Auth scaffolding, DB patterns, Vercel deploy. **No payment / subscription** (see `docs/recipes/saas-monetization.md` if needed). | TBD PR |
| `homelab-proxmox` | Proxmox VE + Terraform + monitoring | VM/LXC modules, Prometheus + Grafana stack, backup recipes | TBD PR |
| `cli-tools` | Python or Shell automation | GitHub API helpers, dependency analyzers, headless-friendly patterns | TBD PR |

**Each one will land with**:
- Its `.json` manifest under `.claude/presets/`
- A `tests/presets.bats` test verifying dry-run install
- A short demo recipe under `docs/recipes/`
- An entry in `CHANGELOG.md`

## What is NOT covered (stacks where contributions are wanted)

These stacks **do not have a preset yet, and won't until either** (a) a maintainer adopts them in production, or (b) a community contributor ships one with a maintenance commitment. Naming them here is the explicit signal that we know they exist and want them.

### Web frameworks (alternatives to Next.js)

| Stack | Why we don't have it yet |
|---|---|
| **Astro** | Content / static-first JS — different design center than Next.js. Maintainer doesn't run Astro in prod. |
| **SvelteKit** | Different reactivity model. No prod use yet. |
| **Vue / Nuxt** | Major community we don't represent. Open to a contributor with prod experience. |
| **Remix** | Now under React Router umbrella; status uncertain. Open to a contributor. |
| **Qwik / Solid** | Resumable / fine-grained reactivity. Niche but vocal community. |

### Backend frameworks (non-Node)

| Stack | Why we don't have it yet |
|---|---|
| **Django** | Full-fat Python web. Maintainer hasn't shipped a Django app. |
| **FastAPI** | Python API. Closer to maintainer's tooling but not used in prod web context. |
| **Flask** | Lighter Python web. Same reason as above. |
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

If your daily stack isn't here, it's exactly the kind of contribution that would expand claude-socle's honest coverage.

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

| Category | In pipeline | Community-wanted |
|---|---|---|
| JS web frameworks | 1 (`nextjs`) | 5+ |
| Non-Node backend frameworks | 0 | 9+ |
| Infrastructure / homelab | 1 (`homelab-proxmox`) | 3+ |
| CLI / automation | 1 (`cli-tools`) | — |
| Mobile / desktop | 0 | 5+ |
| Data / AI pipelines | 0 | 2+ |

**3 in pipeline. 24+ named as community-wanted.** That ratio is the foundation's honest position.
