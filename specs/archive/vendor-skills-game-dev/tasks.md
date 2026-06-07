# Tasks: acknowledge game-dev as a vendor-pointer gap

**Input**: `specs/vendor-skills-game-dev/spec.md` + `specs/vendor-skills-game-dev/plan.md`
**Prerequisites**: spec.md (5 user stories, all clarifications resolved), plan.md (5 phases)
**Branch**: `feature/auto-20260518-142206` → rename to `feat/vendor-skill-pointer-game-dev`

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** : runnable in parallel (different files, no dependencies)
- **[US1..US5]** : traceability to the spec's user stories
- Exact file paths required

---

## Phase 1 — Pre-verification (BLOCKING)

**Goal**: Verify `phaserjs/phaser` repo state at change-time. The recipe's `Vendor-neutrality` paragraph must cite real numbers (per `feedback_verify_code_claims` memory).

- [ ] **T001** Run `gh api repos/phaserjs/phaser --jq '{stars: .stargazers_count, pushed_at: .pushed_at, archived: .archived, license: .license.spdx_id, fork: .fork}'`. Record output verbatim for use in T004.
- [ ] **T002** Confirm `skills/` directory exists at HEAD: `gh api repos/phaserjs/phaser/contents/skills --jq 'length'` returns ≥ 1. Capture the count.
- [ ] **T003** Capture CI baseline: run `./scripts/validate-counts.sh` and `jq '.vendorSkillsValidated' counts.json` BEFORE any edit. Expected baseline: `16`. Record exit code.

**Checkpoint**: Real numbers in hand. If `archived == true` OR license is not MIT OR fork is `true`, STOP and reconsider — likely needs spec revision.

---

## Phase 2 — Recipe entry (US-1, P1) 🎯 MVP

**Goal**: Add the Phaser pointer in `docs/recipes/recommended-vendor-skills.md`.

**Independent test**: `grep -c "^### Phaser " docs/recipes/recommended-vendor-skills.md` returns `1`.

- [ ] **T004** [US1] Insert the new entry in `docs/recipes/recommended-vendor-skills.md`, placed **after** the existing `### Anthropic — \`frontend-design\` plugin (official marketplace)` section and **before** `### Anthropic — \`code-review\` plugin (qa-review companion)`. Entry template (5 sections + adjacent options):
  ```
  ### Phaser — `phaserjs/phaser/skills/`

  **Covers**: …28 SKILL.md files in the vendor's main repo …scene lifecycle, sprites, physics (Arcade/Matter), tilemaps, animations, input, particles, cameras, audio, plus a dedicated `v3-to-v4-migration` skill.

  **When to install**: any 2D web/mobile-web game project built on Phaser (v3 or v4).

  **Pair with**: no bundled foundation skill on this topic (acknowledged gap — see `specs/presets/roadmap.md` §"Game / Interactive media").

  **Install** (verify on their README):
  …git clone command pointing to the vendor's `skills/` directory…

  **Vendor-neutrality**: Phaser Studio Inc., independent, MIT-licensed. Verified via `gh api repos/phaserjs/phaser` on 2026-05-18 — <stars from T001>★, last commit <pushed_at from T001>, archived: false. Not acquired by Anthropic competitors as of verification date.

  **Adjacent options (not separately evaluated)**: PixiJS (rendering-focused, see `arimxyer/toolchest`), Kaplay (simpler scene-graph), Excalibur (TypeScript-first).
  ```
  Fill the placeholders with T001 outputs.
- [ ] **T005** [US1] Update the file header line `**Last verified**: 2026-05-06.` → `**Last verified**: 2026-05-18.`
- [ ] **T006** [P] [US1] Self-check: `grep -c "^### " docs/recipes/recommended-vendor-skills.md` returns `17 ± headings under "Stack-specific" + "Vendors evaluated and NOT recommended"`. Compare to baseline captured during exploration.

**Checkpoint**: Recipe has 1 new entry. No formatting drift.

---

## Phase 3 — Roadmap subsection + Quick-ref row (US-2, US-3, US-5)

**Goal**: Make the gap visible in `specs/presets/roadmap.md`; reference the contribution path; update the count table.

**Independent test**: `grep -c "^### Game / Interactive media$" specs/presets/roadmap.md` returns `1` AND the Quick-reference table has one new row.

- [ ] **T007** [US2] In `specs/presets/roadmap.md`, add the subsection under `## What is NOT covered`, placed alphabetically between `### Mobile / Desktop` and `### Other infra / data`:
  ```
  ### Game / Interactive media

  | Stack | Why we don't have it yet |
  |---|---|
  | **2D web game framework (generic)** | No maintainer production use yet. The vendor (Phaser Studio Inc.) publishes a canonical skill — see `docs/recipes/recommended-vendor-skills.md`. |
  ```
- [ ] **T008** [US3] Append one sentence at the end of the new subsection: "Contributions welcome — see `## How to contribute a preset` below."
- [ ] **T009** [US5] Add one row to the `## Quick reference (count)` table:
  ```
  | Game / Interactive media | 0 | 1+ |
  ```
  Placed under the existing rows (alphabetical not strictly enforced in the existing table).
- [ ] **T010** [P] [US2] Self-check: `grep -c "^### " specs/presets/roadmap.md` reflects an increment of `+1`.

**Checkpoint**: Roadmap acknowledges the gap; quick reference up to date.

---

## Phase 4 — Counter regeneration + validation (US-4, P2)

**Goal**: Auto-regenerated artifacts are in sync; all foundation scripts green.

**Independent test**: `jq '.vendorSkillsValidated' counts.json` returns `17` AND `validate-counts.sh` exits `0`.

⚠️ DO NOT hand-edit `counts.json` or `README.md` badge. Run the generator.

- [ ] **T011** [US4] From repo root: `npm --prefix website run generate`. Capture stdout (it logs the new count line).
- [ ] **T012** [US4] Verify: `jq '.vendorSkillsValidated' counts.json` returns `17`.
- [ ] **T013** [US4] Verify: `grep -oE 'count:vendorSkillsValidated -->[0-9]+' README.md` shows `17`.
- [ ] **T014** [P] [US4] Run `npm --prefix website test` (covers `generate-counts.test.ts`). Exit code must be `0`.
- [ ] **T015** [P] [US4] Run `./scripts/validate-counts.sh`. Exit code must be `0`.
- [ ] **T016** [P] [US4] Run `./scripts/audit-base.sh`. Exit code must be `0` (recommended per `base-maintenance.md`, not blocking but should not regress).

**Checkpoint**: All counters consistent; all scripts green.

---

## Phase 5 — CHANGELOG + pre-commit guardrails

**Goal**: Diff is clean, named, ready for commit handoff.

- [ ] **T017** [P] In `CHANGELOG.md`, add ONE bullet under the existing `## [Unreleased]` section (create an `### Added` subgroup if not present at the top of [Unreleased], otherwise reuse the existing group). Example wording:
  ```
  - **Recipe**: `docs/recipes/recommended-vendor-skills.md` gains a Phaser
    pointer (`phaserjs/phaser/skills/`); `specs/presets/roadmap.md` gains a
    `Game / Interactive media` acknowledgment under "What is NOT covered".
    Counter `vendorSkillsValidated` 16 → 17.
  ```
- [ ] **T018** [P] Run `git diff --name-only`. Expected file set:
  - `docs/recipes/recommended-vendor-skills.md`
  - `specs/presets/roadmap.md`
  - `CHANGELOG.md`
  - `counts.json` (auto-regenerated)
  - `README.md` (auto-regenerated badge only)
  - `specs/vendor-skills-game-dev/spec.md`, `plan.md`, `tasks.md` (this feature's design docs)
  Any extra file → investigate before commit.
- [ ] **T019** [P] Run `git diff -- '*.md' '*.json' | grep -Ei '<protected-end-user-project-names>'` over the diff (per `feedback_no_project_names` memory). Expected: zero matches. If any match, fix before commit.
- [ ] **T020** Rename the branch via `/git-rename feat/vendor-skill-pointer-game-dev` (current `feature/auto-20260518-142206` is auto-generated and uninformative).
- [ ] **T021** Hand off to `/work:work-commit` (or `/work:work-pr` if the change should land via PR). Suggested commit shape:
  - 1 commit: `docs(recipe,roadmap): point to phaserjs/phaser/skills for 2D web game dev`
  - Includes all hand-edited + auto-regenerated files in the same commit (single logical change).

**Checkpoint**: Branch renamed, diff clean, ready to commit.

---

## Dependencies and Execution Order

```
Phase 1 (Pre-verification, T001-T003)  ◄── BLOCKS everything
       │
       ▼
Phase 2 (Recipe, T004-T006)  ──┐
                               ├──▶ Phase 4 (Regen + validate, T011-T016)
Phase 3 (Roadmap, T007-T010) ──┘
                                            │
                                            ▼
                                  Phase 5 (CHANGELOG + handoff, T017-T021)
```

### Story dependencies

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US-1 (P1) | Phase 1 | Recipe entry depends on T001-T002 outputs |
| US-2 (P1) | Phase 1 | Roadmap text references the recipe by relative path; safe to draft once T001 confirms vendor exists |
| US-3 (P2) | Phase 1 | Same file as US-2; bundled in T008 |
| US-4 (P2) | Phase 2 + Phase 3 | Generator reads the recipe; both files must be written first |
| US-5 (P3) | Phase 1 | Same file as US-2; bundled in T009 |

### Parallelization opportunities

- Phases 2 and 3 touch different files → run T004-T006 in parallel with T007-T010.
- T014 / T015 / T016 read the regenerated artifacts → run in parallel after T011-T013.
- T017 (CHANGELOG) and T018-T019 (diff checks) are independent → run in parallel.

---

## Implementation Strategy

### MVP path (US-1 + US-2 only, 30 min target)

1. Phase 1 (~3 min — one `gh api` call)
2. Phase 2 + Phase 3 in parallel (~10 min total)
3. Phase 4 (~5 min — wait on generator + tests)
4. Phase 5 (~5 min — CHANGELOG + diff checks)

### Solo strategy (this is a 1-developer change)

Linear walk through phases 1 → 5. No team parallelization needed — the [P] markers refer to commands that can be batched in one shell call, not to multi-developer split.

---

## Notes

- **No TDD red-green loop** for this change: no new logic, no new test file. The existing `website/scripts/generate-counts.test.ts` IS the test gate — it asserts the count matches the recipe content.
- **No bundled artifact**: zero touch on `.claude/skills/`, `.claude/presets/`, `.claude/agents/`, `.claude/settings.json` (spec EF-008).
- **Auto-regenerated files in the same commit** is intentional — keeps the diff atomic and reviewable; partial commits would create a stale-counter window.
- **Branch rename** is queued in T020 rather than done at T000 because `/git-rename` is a user-invoked slash command, not a Bash operation — the agent surfaces the suggestion, the user runs it.

**To avoid**:
- Editing `counts.json` by hand (T011 overwrites it).
- Adding more than one bullet to CHANGELOG (spec EF-010 caps at one).
- Naming end-user projects in the recipe or roadmap (T019 grep guard).
- Skipping `npm --prefix website test` (T014) — it's the only thing that catches a parser-level breakage in `generate-counts.ts`.

---

**Version**: 1.0 | **Created**: 2026-05-18
