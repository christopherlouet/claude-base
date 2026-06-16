# Spec: stack-pivot re-detection — notice the project outgrew its recorded preset

> **Status: 📝 Draft** — specified 2026-06-16, not yet planned.

**Status**: Draft — awaiting plan
**Date**: 2026-06-16
**Owner**: Chris
**Builds on**: `specs/presets-update-aware/` (CS-205 sticky preset, PR #162), `specs/marketplace-curation-engine/` (US-9 recommendation-drift, PR #314)
**Closes**: `specs/foundation-positioning-review/phase-6-curator-bindings.md` Open question #3 ("Stack pivot UX — *Still open*")

---

## Summary

A project's recorded preset is **sticky by design** (CS-205): once `.claude/foundation.json` names a preset, every `claude-base update` reuses it and never re-runs auto-detection (`scripts/update.sh:1000-1024`). This is correct — it avoids the multi-match refusal on every update and guarantees a stable skill filter. But it has a blind spot: when the **project's stack itself changes** after `init` (a `react-vite-spa` project grows `next.config.js` + `app/`; a plain API project adds `prisma/schema.prisma`), nothing ever tells the user that a different or additional preset now matches. They keep getting the old preset's skill filter and the old preset's vendor recommendations, silently missing the ones their new stack would unlock.

This is **distinct from recommendation-drift** (US-9, already shipped): US-9 detects when the *foundation changes the recommendation list of the recorded preset*; this spec detects when the *user's project drifts into a different preset*. One watches our data, the other watches their repo.

The fix follows the foundation's settled philosophy — **observe-and-propose, never act silently** (same stance as `preset-recommendations.sh` "observe-never-install" and the whole curation engine). `update` keeps honoring the recorded preset exactly as today; it *additionally* runs the existing `scan_presets` detector and, when the detected set diverges from the recorded preset, prints a **non-blocking notice** suggesting the explicit re-record command. It never auto-switches the preset (that would silently rewrite the skill filter and could drop skills the user relies on).

## Goals

- Surface, at `update` time, that the project now matches a preset other than (or in addition to) the recorded one.
- Stay **100% non-blocking and non-mutating** by default: the recorded preset and skill filter are unchanged unless the user explicitly opts in.
- Reuse existing machinery (`scan_presets`, `manifest_preset`, `resolve_preset_file`) — no new detection logic, no new persisted state for the MVP.
- Give the user a one-command path to adopt the new preset when they agree.

## Non-Goals / Out of Scope

- **Auto-switching the recorded preset.** Detection proposes; the user disposes. Auto-rewriting `.preset` would silently change the skill drop/keep filter — explicitly rejected (violates CS-205's stability guarantee).
- **`vendor-skills.lock.json`** (phase-6 #3). Tracking *what was installed and when* is a separate, lower-priority concern; not needed to surface a pivot.
- **Re-running auto-install of vendor skills.** Recommendations are printed, never installed (unchanged supply-chain stance).
- **A general `claude-base sync` command surface** beyond what US-3 scopes. If the notice + `--preset` re-record path covers the need, a dedicated subcommand stays optional.
- **Detecting module (not preset) changes** — modules are opt-in and orthogonal; out of scope here.

## User Stories

### P1 — MVP

#### US-1 — Pivot notice at update time

> **As** a user whose project started as one stack and grew into another (e.g. added Next.js to a Vite SPA),
> **I want** `claude-base update` to tell me my project now matches a different preset,
> **so that** I learn my skill filter and vendor recommendations are scoped to the old stack, instead of silently missing the new one.

**Acceptance criteria**

- **Given** a project whose `foundation.json` records `preset: react-vite-spa` and whose files now also satisfy the `nextjs` detect rules,
  **when** I run `claude-base update` (with or without `--all`),
  **then** a non-blocking notice names the recorded preset, the newly-detected preset(s), and the exact command to adopt the change (`claude-base update --preset <name>`),
  **and** the update otherwise proceeds and completes normally using the **recorded** preset's filter (nothing is switched, dropped, or added as a side effect).

- **Given** a project whose detected set still matches exactly its recorded preset,
  **when** I run `claude-base update`,
  **then** no pivot notice is printed (no false alarm on the steady state).

- **Given** a legacy project with no `foundation.json` (no recorded preset),
  **when** I run `claude-base update`,
  **then** the existing auto-detection path is unchanged and no pivot notice is printed (there is no recorded baseline to compare against).

#### US-2 — Explicit, non-destructive adoption

> **As** a user who agrees with the pivot notice,
> **I want** to adopt the newly-detected preset with one explicit command,
> **so that** my recorded preset, skill filter, and recommendations realign with my actual stack.

**Acceptance criteria**

- **Given** the pivot notice suggested `claude-base update --preset nextjs`,
  **when** I run exactly that,
  **then** the run applies the `nextjs` filter, re-records `preset: nextjs` in `foundation.json`, and refreshes the recommendation snapshot — reusing the existing `--preset` override path (no new code path for the mutation itself).

- **Given** I adopt the new preset,
  **when** the run finishes,
  **then** the recommendation-drift output (US-9) and the pivot notice both reflect the new baseline on the *next* update (no residual or repeated notice for an already-adopted pivot).

### P2 — Should have

#### US-3 — Read-only detection affordance

> **As** a user (or a CI/agent) who wants to check for a pivot without running a full update,
> **I want** a read-only way to ask "does my project still match its recorded preset?",
> **so that** I can detect drift in a script or before deciding to update.

**Acceptance criteria**

- **Given** any project with a recorded preset,
  **when** I run the read-only check (e.g. `claude-base update --detect-only` reusing the existing `--detect-only` flag, or an equivalent already-present affordance),
  **then** it prints the recorded preset, the detected set, and whether they diverge — and **exits 0**, mutating nothing.

> Implementation note for PLAN: prefer extending the existing `--detect-only PATH` flag (already present in `new-project.sh:179`) over inventing a new subcommand, unless the plan finds that path unsuitable.

### P3 — Nice to have

#### US-4 — Ambiguity is surfaced, not resolved silently

> **As** a user whose project matches several presets at once after a pivot,
> **I want** the notice to list all matches and stay non-blocking,
> **so that** I am never force-stopped on an update by an ambiguous detection.

**Acceptance criteria**

- **Given** a project that now matches two presets (e.g. `nextjs` and `react-vite-spa`),
  **when** I run `claude-base update`,
  **then** the notice lists every detected preset and suggests picking one with `--preset <name>`,
  **and** the update still completes using the recorded preset (the multi-match *error* path that exists for legacy projects in `resolve_active_preset` is **not** triggered here — a recorded project must never be blocked by re-detection).

## Functional Requirements

| # | Requirement |
|---|---|
| FR-1 | The pivot check runs only when a preset is recorded in the manifest AND `jq` is available AND the run is not `--no-preset` / explicit `--preset` (an explicit `--preset` is already an adoption, so no notice). |
| FR-2 | Detection reuses `scan_presets` (`lib/preset-detect.sh`) against `TARGET_DIR`; no new detection rules. |
| FR-3 | A pivot is "detected set ⊅ {recorded}" — i.e. the recorded preset is absent from the detected set, or the detected set contains a preset not equal to the recorded one. Identical set → no notice. |
| FR-4 | The notice is informational only: it must not change exit code, must not mutate any file, must not alter the active skill filter for the current run. |
| FR-5 | Adoption is the **existing** `--preset <name>` path; this spec adds no new mutation logic, only the notice and (P2) the read-only report. |
| FR-6 | Output respects the existing logging conventions (`info`/`warning` helpers) and is suppressible by the existing quiet/verbosity flags if any. |
| FR-7 | Fail-safe: any error inside the pivot check (detector failure, malformed manifest already handled upstream) must never abort or alter the update — it degrades to "no notice". |

## Edge Cases

- **No recorded preset (legacy):** no baseline → no notice (US-1 AC3).
- **Steady state (detected == recorded):** no notice (US-1 AC2).
- **Multi-match after pivot:** list all, stay non-blocking (US-4) — must NOT reuse the legacy `error "multiple presets match"` abort.
- **`--no-preset` run:** user opted out of preset governance → no notice.
- **Explicit `--preset X`:** that *is* the adoption → no notice for X.
- **`--dry-run`:** notice still printed (it is read-only anyway), nothing persisted (consistent with dry-run).
- **Detector returns empty (project no longer matches any preset, e.g. files removed):** treat as "no longer matches recorded" → a gentle notice is acceptable but must not error; PLAN to decide whether empty-detection is worth a notice or silent.
- **Community/override preset recorded but its file is now absent:** `resolve_preset_file` already warns and falls back; the pivot check must not double-warn or crash.
- **`jq` absent:** whole check skipped (consistent with `resolve_active_preset`).

## Verification Strategy

- **bats** regression tests (offline, no network), following the proven curation/preset loop:
  - synthetic project dir recorded as preset A + files matching preset B → assert notice + exact suggested command + unchanged filter + exit 0.
  - steady-state project → assert no notice.
  - legacy (no manifest) → assert no notice, detection path unchanged.
  - multi-match → assert all listed, no abort.
  - `--no-preset` / explicit `--preset` → assert no notice.
  - read-only check (US-3) mutates nothing (assert manifest byte-identical before/after).
- **Counts gate:** no command/agent/skill count change expected (this is a behavior addition inside `update`, not a new artifact) — confirm `validate-counts.sh` stays green; regen website mirror only if any `docs/**` text changes.
- **Adversarial review** (parallel finder agents) on the diff before PR, per the proven session loop.

## Risks

- **R-1 — Notice fatigue.** If the detector is noisy (over-matches), users learn to ignore it. Mitigation: only fire on a genuine divergence (FR-3), never on the steady state; keep it one concise block.
- **R-2 — Breaking the sticky guarantee.** Any accidental mutation of `.preset` would regress CS-205. Mitigation: FR-4 + a test asserting the manifest is byte-identical after a notice-only run.
- **R-3 — Coupling to detection accuracy.** `scan_presets` precision bounds this feature; a weak detect rule yields a weak notice. Out of scope to improve detect rules here, but PLAN should note any obviously-wrong rule found while testing.

## Open Questions (for PLAN)

1. **Surface:** fold the notice into `update` only (MVP), or also expose a first-class `claude-base sync` / `claude-base preset detect` command? Lean: extend `--detect-only` (US-3) and `update`'s notice; defer a new subcommand unless ergonomics demand it.
2. **Empty-detection** (project matches nothing now): notice or silent? (edge case above).
3. Where exactly to slot the check in `update.sh` so it runs after `resolve_active_preset` but before the recommendation-drift print, for a coherent single "preset & recommendations status" block.

## Related

- `specs/foundation-positioning-review/phase-6-curator-bindings.md` — open-q #3 (this closes it).
- `specs/presets-update-aware/spec.md` — CS-205 sticky preset (the constraint this respects).
- `specs/marketplace-curation-engine/` — US-9 recommendation-drift (the sibling, foundation-side drift).
- Memory `[[curation-vision-open-refinements]]` #ergonomics — "recommendation drift for existing projects → treat as a versioned/migratable change, not silent" (same spirit, project-side).
