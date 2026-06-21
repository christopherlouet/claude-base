# Spec — Dynamic vendor-precedence hint (session-time wiring)

> Status: ▶ In progress · 2026-06-21 · Owner: Chris
> Follows: `specs/dev-command-vendor-graduation/spec.md` (§5 deferred the *dynamic gap*)
> Policy wired: `.claude/rules/vendor-precedence.md` (T3 — vendor owns tool API)
> Mapping reused: `.claude/curation/registry.json` (foundationSkill → vendorId)

## 1. Problem

Foundation→vendor graduation is wired **statically**: pointer-skills say "superseded by
`<vendor>`", `vendor-precedence.md` states the precedence ladder, and the install-time print
lists `recommendedVendorSkills[]`. But there is **no session-time signal**: when a project has
a vendor skill *installed* (e.g. `prisma/skills`) **and** the foundation still ships its
sibling (`dev-prisma`), nothing nudges the assistant to prefer the vendor for that specific
session. The precedence is policy-only, not surfaced against concrete session state.

## 2. Scope (decided 2026-06-21)

- **Precedence-only** — fire **only** when the vendor skill is actually **installed** (not an
  install-recommendation nag; the install-time print already covers discovery). Firing on
  "stack detected but vendor absent" was explicitly rejected as noise.
- **Once per session** — a session-scoped marker prevents per-prompt repetition.

Because an installed vendor skill *already implies* the project uses the tool, **no stack
detection (`scan_presets`) is needed** — the install presence is the sufficient, cheap signal.

## 3. Design

### 3.1 Detection (feasibility verified 2026-06-21)

The 5 graduated dev-* vendors install via `npx skills add <repo>`, which symlinks each skill
into `.claude/skills/<name>/` (`<name>` = the skill's `name:` frontmatter / dir). Confirmed
high-confidence names:

| foundationSkill | vendorId | sentinel install dirs (any match ⟹ installed) |
|---|---|---|
| `dev-prisma` | `prisma/skills` | `prisma-cli`, `prisma-client-api`, `prisma-postgres` |
| `dev-supabase` | `supabase/agent-skills` | `supabase`, `supabase-postgres-best-practices` |
| `dev-shadcn` | `shadcn-ui/ui/skills/shadcn` | `shadcn` |

v1 scopes to these 3 (graduated pointer-skill + high-confidence dir names). `dev-nextjs`
(`vercel-labs/agent-skills`) and `dev-graphql` (`apollographql/skills`) are extensible by one
sentinel-map line each once their dir names are verified and the foundation skill graduates.

Search roots (project + global, both layouts to catch the `npx skills` global-symlink bug
[vercel-labs/skills#851]): `<project>/.claude/skills/`, `$HOME/.claude/skills/`,
`<project>/.agents/skills/`, `$HOME/.agents/skills/`.

**Known limitation (documented, accepted):** the **marketplace-plugin** install path
(`claude plugin install supabase@…`) does not create a `.claude/skills/<dir>` and is **not**
detected. v1 covers the dominant `npx skills add` path only.

### 3.2 Where the detection lives

Sourceable helper `scripts/hooks/_vendor-precedence-hint.sh` (the `_`-prefixed
sibling-helper convention, like `_hook-helpers.sh`):

- **Must** live under `scripts/hooks/` because `init`/`update` copy only
  `scripts/hooks/*.sh` downstream (not `scripts/lib/` nor `.claude/curation/`). Added to
  `scripts/lib/minimal-manifest.txt` so the minimal export ships it; a generic drift guard in
  `tests/manifest-hooks-coverage.bats` enforces that any sourced `_*.sh` helper is shipped.
- `vendor_precedence_hints <project_dir> [home_dir]` — **pure shell**, **no jq, no registry
  read, no common.sh**, **fail-safe** (silent exit 0 when nothing installed). Self-contained so
  it works even in downstream projects that never received the curation registry, and can never
  break the standalone hook.
- The `foundationSkill | vendorId | sentinel dirs` table is **local to the helper** — detection
  data that drifts independently of curation truth, so the validated/`curation-watch`'d
  `registry.json` is deliberately **not** modified.
- Output: one markdown bullet per installed vendor, e.g.
  `` - `prisma/skills` (vendor, installed) is canonical here — prefer it over the foundation `dev-prisma` pointer (vendor-precedence T3). ``

### 3.3 Hook wiring

`scripts/hooks/prompt-context.sh` (UserPromptSubmit):

- Read `session_id` from the stdin payload (fallback: `transcript_path`, then no-marker).
- **Once-per-session gate:** marker file `${TMPDIR:-/tmp}/claude-base-vprec.<hash(session_id+project)>`.
  If present → skip the section. Else compute hints; if non-empty, emit a
  `## Vendor skills (precedence)` section **before** `## Routing` and `touch` the marker.
- Disable with `SKIP_VENDOR_PRECEDENCE=1`. Inherits the hook's existing fast bail-outs.

## 4. User Stories

**US-1 (P1) — Surface installed-vendor precedence once per session**
- **Given** `prisma/skills` is installed (`.claude/skills/prisma-cli` exists) and the
  foundation ships `dev-prisma`, **When** the user submits a non-slash prompt for the first
  time in the session, **Then** the injected context names the vendor as canonical and tells
  the assistant to prefer it over `dev-prisma` (T3); **and** the section does **not** reappear
  on subsequent prompts in the same session.
- **Given** no vendor skill is installed, **When** any prompt is submitted, **Then** no
  vendor-precedence section is emitted.

**US-2 (P1) — Fail-safe & opt-out**
- **Given** `jq` is absent or the registry is missing, **When** the lib runs, **Then** it exits
  0 with no output (never breaks the hook).
- **Given** `SKIP_VENDOR_PRECEDENCE=1`, **When** the hook runs, **Then** the section is omitted.

## 5. Acceptance criteria

- `tests/vendor-precedence-hint.bats` covers: installed→hint, not-installed→silent, jq-missing→
  silent, registry-missing→silent, both `.claude/skills` and `.agents/skills` roots, project +
  global, and the marketplace-only case producing no false hint.
- `tests/prompt-context.bats` gains: section appears once, suppressed on 2nd prompt (marker),
  `SKIP_VENDOR_PRECEDENCE=1` suppresses it, output stays valid JSON.
- `shellcheck` clean on the new lib + modified hook.
- `scripts/validate-counts.sh` green (no command/agent/skill/rule count change); `audit-base.sh`
  clean. Hook timing stays well within the 3s UserPromptSubmit budget (only `[ -d ]` tests +
  one `jq` read of a small file).

## 6. Out of scope

- Install-recommendation for **absent** vendors (the install-time print owns discovery).
- Marketplace-plugin detection (`@`-handle installs outside `.claude/skills/`).
- `dev-nextjs` / `dev-graphql` sentinels (extensible later; names not yet high-confidence).
- Any change to `registry.json` schema or to `vendor-precedence.md` policy text.
- Stack detection via `scan_presets` (made unnecessary by the installed-vendor signal).
