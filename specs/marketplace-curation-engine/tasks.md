# Tasks — Marketplace curation engine

> Plan: `specs/marketplace-curation-engine/plan.md` · `[P]` parallelizable · `[US?]` trace
> P1 = Slices 1–4 (one PR each). Confirm §7 open decisions before T100.

## Phase 0 — Baseline
- **T001** Clean tree; run `./scripts/validate-presets.sh` + `bats tests/` → record green baseline.
- **T002** Confirm `gh` is authenticated (scorer dependency); note rate-limit headroom.
- **T003** Confirm §7 decisions: registry location, digest sink (issue vs draft PR), discovery runtime.

## Slice 1 — Data model & schema (PR #1)
- **T100** `[US1]` Create `specs/presets/schema.json` — formalise the current preset shape (from the 11 existing files) + new recommendation fields: `pinnedRef`, `trustTrack` (authority|community), `provenance`, `lastVerified`, `safetyScreen`, `adviceNeutrality`.
- **T101** `[US1]` Define `.claude/curation/registry.json` shape (canonicalVendor records: `foundationSkill`, `vendorId`, `pinnedRef`, `trustTrack`, `trustVerdict`, `provenance`, `adviceNeutrality`, `lastVerified`, `status`).
- **T102** `[US1]` Seed the registry from `specs/marketplace-audit/` verdicts (POINT-TO-VENDOR + REDUCE-TO-POINTER → candidate records).
- **T103** `[US1][US4]` Resolve a current good ref (commit SHA/tag) for each of the 13 vendor skills; add `pinnedRef`+`provenance`+`trustTrack`+`lastVerified` to every `recommendedVendorSkills[]` entry in `.claude/presets/*.json`.
- **T104** `[US1][US4]` Extend `scripts/validate-presets.sh`: require `pinnedRef` on every recommendation; validate new fields; validate `registry.json`.
- **T105** `[P]` `tests/curation-schema.bats` — schema + validator coverage (valid/invalid fixtures).
- **T106** Regen if any generated doc/matrix touched; `validate-counts.sh`; PR #1.

## Slice 2 — Community-trust scorer (PR #2)
- **T200** `[US2]` Create `.claude/curation/trust-thresholds.json` (global bars; two-track: authority=no popularity bar, community=global bar).
- **T201** `[US2]` Create `scripts/lib/curation-common.sh` (gh wrappers, backoff, digest format helpers).
- **T202** `[US2]` Create `scripts/lib/trust-score.sh` — `gh api repos/<id>` → stars/forks/pushed_at/archived/license → verdict against thresholds + track. **No LLM.** Downloads/install counts used only where exposed.
- **T203** `[US2]` `tests/curation-trust-score.bats` — fixtures **mock `gh api`** (offline, deterministic): authority-track pass, community below/above bar, archived, license fail.
- **T204** `shellcheck` new scripts; PR #2.

## Slice 3 — Rot-watch, LLM-free (PR #3)
- **T300** `[US3]` Create `scripts/curation-watch.sh` — iterate registry + presets → `trust-score` → flag: archived / abandoned (recency window) / **collapse (sustained ≥2 runs)** / license-change / **content-drift vs `pinnedRef`**.
- **T301** `[US3]` Emit **one digest** (json + markdown) per run; `--dry-run`; idempotent `lastVerified` update; fail-safe on gh errors.
- **T302** `[US3][US4]` Mix output: auto-draft a re-pin PR for low-risk (newer tag re-passing trust; safety re-screen flagged for review), propose-only for new candidates / removals.
- **T303** `[US4]` Safety screen hook at pin-time (documented gate; deterministic drift flag re-opens it as propose-only).
- **T304** `tests/curation-watch.bats` — fixtures: drift detected, archived, sustained-collapse vs single-blip (no false flag), empty run = no noise.
- **T305** `shellcheck`; PR #3.

## Slice 4 — Nightly bot deploy (PR #4 + ops on the box)
- **T400** `[US3]` Create `docs/recipes/curation-bot-deploy.md` — nightly cron/systemd timer for `curation-watch.sh` (LLM-free, $0 tokens); digest → GitHub issue/draft PR via `gh`; secret handling (no key needed for rot-watch beyond `gh`).
- **T401** Regen mirror if recipe is mirrored; `validate-counts.sh`; PR #4.
- **T402** (ops, off-repo) Install the nightly timer on the self-hosted homelab host; verify a real run produces a digest.

## Phase P2 — Important
### Slice 5 — Discovery (PR #5)
- **T500** `[US5]` Create `scripts/curation-discover.sh` — monthly; invokes `claude -p` on a **dedicated capped API key**; Haiku triage → escalate borderline; batch all candidates; prompt-cache the audit methodology; **hard token budget + fail-safe** (report on exhaustion, never silent/runaway).
- **T501** `[US6]` Modify `docs/recipes/recommended-vendor-skills.md` + `specs/marketplace-audit/spec.md`: **advice-neutrality + provenance** replace publisher-veto; community-trust bar replaces ≥3-prod-repos.
- **T502** `[US5]` Extend `scripts/check-updates.sh` skills.sh discovery to feed candidate proposals.
- **T503** `[US6]` Discovery applies trust + **safety** + advice-neutrality before proposing; provenance disclosed in output.
- **T504** Monthly cron in deploy recipe; regen docs; `shellcheck`; PR #5.

### Slice 6 — Precedence (PR #6)
- **T600** `[US7]` Add foundation-vs-vendor (and vendor-vs-vendor) precedence policy — new note in `.claude/rules/` or a section; update README rules table + counter if a new rule file; regen.

## Phase P3 — Nice-to-have (PR #7)
- **T700** `[US8]` Discovery flags high-trust skills encroaching on durable/KEEP workflow patterns as a strategic signal (not a graduation candidate).
- **T701** `[US9]` Surface recommendation-set changes for existing projects as a tracked/migratable change (reuse the crossing-migration report).

## Traceability
| US | Tasks |
|----|-------|
| US-1 (P1) | T100–T103, T106 |
| US-2 (P1) | T200–T204 |
| US-3 (P1) | T300–T302, T304, T400–T402 |
| US-4 (P1) | T103, T104, T302, T303 |
| US-5 (P2) | T500, T502, T503 |
| US-6 (P2) | T501, T503 |
| US-7 (P2) | T600 |
| US-8 (P3) | T700 |
| US-9 (P3) | T701 |
| Cross/DoD | T001–T003, T105, T204, T305, T401 |
