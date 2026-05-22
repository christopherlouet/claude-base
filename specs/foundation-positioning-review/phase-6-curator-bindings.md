# Phase 6 — Curator Bindings

> **Status**: realigned 2026-05-22 (this revision). Most of the original v1 vision is already shipped in v1.x — this doc now tracks what *remains* honestly.
> **Parent spec**: [`spec.md`](spec.md)
> **History**: vision captured in PR #239 assumed greenfield. Audit on 2026-05-22 (post-v2.0.0) found the curator-bindings mechanism was largely already implemented under different names. This revision realigns the doc with reality and re-scopes the remaining work.

## What's already shipped (as of v2.0.0)

The curator-bindings mechanism the original vision proposed already exists, just under different naming. The original spec called for "implement preset schema extension"; that work was done in v1.x and is operational today.

### Schema (in `.claude/presets/*.json`)

Each preset has a `recommendedVendorSkills[]` field. Each entry has shape:

```json
{
  "id": "vendor/repo or skill@marketplace",
  "url": "https://github.com/... or https://claude.com/plugins/...",
  "rationale": "Why this skill pairs with this preset",
  "condition": "always" | "if using X"
}
```

The `condition` field handles tier-ification: `"always"` items are unconditional recommendations for the stack; any other string is a conditional recommendation (e.g. `"if using Prisma"`, `"if using Supabase"`). The original vision proposed three explicit tiers (required/recommended/optional); the binary "always vs conditional" implementation is functionally sufficient and was kept.

State as of 2026-05-22:

| Preset | `recommendedVendorSkills[]` count | Notes |
|---|---|---|
| `apollo` | 1 | apollographql/skills |
| `astro` | 3 | frontend-design + addyosmani/web-quality-skills + claude-seo |
| `cli-tools` | 0 | **intentionally empty** — preset is headless/UI-less; vendor skills are stack-specific. See cli-tools.json description field. |
| `fastapi` | 4 | code-review + Semgrep + grafana + pulumi |
| `homelab-proxmox` | 3 | pulumi + terraform + grafana |
| `mongodb` | 1 | mongodb/agent-skills |
| `nextjs` | 6 | vercel + frontend-design + supabase + prisma + shadcn + apollo |
| `phaser` | 1 | phaserjs/phaser/skills |
| `playwright` | 1 | microsoft/playwright-cli |
| `pulumi` | 1 | pulumi/agent-skills |
| `react-vite-spa` | 4 | vercel + frontend-design + addyosmani + playwright-cli |

### CLI integration

`scripts/lib/preset-recommendations.sh` exposes `print_recommended_vendor_skills <preset_file> [project_dir]` which:

1. Groups entries into *Always pair with this preset* vs *Add if your project uses these tools*.
2. Detects install status via filesystem check (`detect_skill_install_status` — checks `$HOME/.claude/skills/<id>` and `<project_dir>/.claude/skills/<id>`).
3. Marks each entry: `[OK]` installed, `[--]` not installed, `[?]` marketplace plugin (filesystem unknown).
4. Prints install pointer per entry (`git clone --depth 1 <url>` for `vendor/repo`, `claude plugin install <id>` for `@marketplace` handles).
5. Closes with a pointer to the canonical recipe.

Wired into both `scripts/new-project.sh:1257` (at the end of `claude-base init`) and `scripts/update.sh:1581` (at the end of `claude-base update`). The vision's *"one prompt during init"* UX is operational: users see the curated list when their stack is detected, without opening the recipe.

### Validation

- `scripts/validate-presets.sh` validates the `recommendedVendorSkills[]` schema (shape, required keys, condition format).
- `tests/presets.bats` asserts:
  - `nextjs` has ≥3 entries (L654)
  - `validate-presets.sh` enforces shape (L661-678)
  - Empty `recommendedVendorSkills[]` correctly suppresses the heading at install time (L781)
  - `react-vite-spa` has exactly 4 entries with correct tier split (L908+)

## What's actually remaining

Three items remain unimplemented. Listed in order of value-to-effort:

### 1. Recipe auto-gen from preset JSONs (highest value)

The per-stack matrix added at the top of `docs/recipes/recommended-vendor-skills.md` in PR #244 is **hand-maintained**. Drift risk: if a preset's `recommendedVendorSkills[]` changes, the matrix doesn't update. Either:

- Add a `website/scripts/generate-recipe-matrix.ts` that reads all 11 preset JSONs and rewrites the "## By stack" section between marker comments. Wire into `npm --prefix website run generate`.
- Or extend `scripts/audit-docs.sh` to detect divergence between the matrix and the preset JSONs as a CI gate.

Estimated 1 session, single PR.

### 2. Conflict detection at install time

If a vendor skill defines `/dev-prisma` (slash command) and the foundation already has `dev-prisma`, the foundation wins by precedence but the user has no warning. Add to `print_recommended_vendor_skills`:

- Optionally parse the vendor skill's manifest (when checking `[OK]` status) and warn about slash-command name collisions.
- Print a one-liner: `⚠ this skill defines /dev-prisma which already exists in the foundation; the foundation version wins`.

Estimated 1 session, single PR. Lower priority — most validated vendor skills don't collide with foundation namespaces by design.

### 3. `vendorSkills.lock.json` for traceability

If a future `claude-base sync` subcommand wants to handle stack pivots (e.g. user adds Prisma to a Next.js project months after `init` and the curator should re-prompt), there needs to be a record of what was installed by `init`. Today the install-status check is purely filesystem-based (no record of *when* or *via which preset*).

- Add `.claude/vendor-skills.lock.json` with `{installed: [{id, installedAt, viaPreset}]}`.
- Update on each `init` / `update` that triggers an install acceptance.

Estimated 1-2 sessions, single PR. Lowest priority — current UX works without it; only matters if/when a stack-pivot UX is added.

## Out of scope (deliberate, unchanged from original)

- **Bundling vendor skill content into claude-base**: vendor skills stay distinct artifacts maintained by their authors. The foundation curates the *list*, not the *content*.
- **Auto-updating installed vendor skills**: that's the Claude Code marketplace's job.
- **Auto-installing vendor skills without user opt-in**: the foundation prints recommendations and install commands; the user runs them. This was a deliberate supply-chain decision (the comment at the top of `preset-recommendations.sh` makes it explicit).
- **Becoming a marketplace**: the curator role is *trusted-list maintenance*, not *artifact distribution*.

## Open questions

The original vision listed 5 open questions. Four are now resolved by the existing implementation; one remains:

1. ~~Version pinning~~ — **Resolved**: not pinned today, vendor skills follow `latest`. Acceptable given the observe-only install model.
2. ~~Marketplace API vs git fallback~~ — **Resolved**: both work today via the `_format_install_pointer` heuristic (`@` → marketplace, `/` → git clone).
3. **Stack pivot UX** — *Still open*. Re-running `claude-base init` is the current path; an explicit `claude-base sync` subcommand is cleaner but adds CLI surface.
4. ~~Conflict detection~~ — *Tracked as item #2 above*.
5. ~~Telemetry trust / data-driven ranking~~ — **Resolved**: not in scope. The recipe is curated manually with audit pilots, which is the right design for a 1-maintainer foundation.

## Why the original vision underestimated existing state

The original [`phase-6-curator-bindings.md`](phase-6-curator-bindings.md) (committed in PR #239 on 2026-05-22) was written without grepping `.claude/presets/*.json` for existing curator-binding fields, or reading `scripts/lib/preset-recommendations.sh`. Lesson: when writing a "vision spec" that proposes new architecture, always read the existing implementation first. See [[feedback-verify-code-claims]].

This realignment isn't a regression — the work to ship Phases 0-5 (Waves 1-3 + v2.0.0 cut) is unaffected. The Phase 6 *deliverables* shrink accordingly.

## Related memories

- [[project-foundation-positioning-review]] — the parent strategic work
- [[feedback-community-is-baseline]] — the framing that justifies delegating depth
- [[feedback-verify-code-claims]] — the lesson this realignment surfaces
