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
| `fastapi` | FastAPI + Pydantic + SQLAlchemy/async ORM (Python async backend) | v1.33.0 (this PR) |

Each shipped preset has:
- `.json` manifest under `.claude/presets/`
- `tests/presets.bats` test entries (≥6 per preset)
- Entry in `.claude/presets/README.md`
- Entry in `CHANGELOG.md`

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

| Category | Shipped | Community-wanted |
|---|---|---|
| JS web frameworks | 1 (`nextjs`) | 5+ |
| Non-Node backend frameworks | 1 (`fastapi`) | 8+ |
| Infrastructure / homelab | 1 (`homelab-proxmox`) | 3+ |
| CLI / automation | 1 (`cli-tools`) | — |
| Mobile / desktop | 0 | 5+ |
| Data / AI pipelines | 0 | 2+ |

**4 shipped. 23+ named as community-wanted.** That ratio is the foundation's honest position.
