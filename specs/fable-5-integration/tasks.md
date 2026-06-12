# Tasks — Claude Fable 5 documentation integration

> Plan: `specs/fable-5-integration/plan.md` · `[P]` = parallelizable · `[US?]` = story trace

## Phase 0 — Baseline
- **T001** Confirm clean working tree; run `./scripts/validate-counts.sh` and record pre-existing state (baseline, not introduced by us).
- **T002** Skim current model wording in F1–F6 to capture exact anchors/phrases to edit (read-only).

## Phase 1 — Anchor surface (US-1 core)
- **T010** `[US1]` Edit `docs/reference/best-practices.md`: add a Fable 5 row **above** Opus 4.8 in "Recommended Model" (most demanding / long-horizon autonomous), with `claude-fable-5`, `$10 / $50` (2× Opus 4.8), 1M ctx, 128K out, "reach for it deliberately". Keep Opus 4.8 as the documented default for complex tasks.
- **T011** `[US1]` In the same file's Effort-Levels guidance, ensure Opus 4.8 + `xhigh`/`max` stays the default heavy path and Fable 5 is a distinct costlier escalation (no replacement framing). → **canonical wording reference for all later surfaces.**

## Phase 2 — Propagate US-1
- **T020** `[US1][P]` Edit `docs/reference/advanced-features.md`: position Fable 5 as the top tier above Opus 4.8; copy facts/framing verbatim from T010.
- **T021** `[US1][P]` Edit `docs/guides/TEAM-GUIDE.md` model/cost tables (≈L.77, 296, 299, 580) to add the Fable 5 tier consistently. (Runtime note added later in T040.)

## Phase 3 — US-2 builder caveats
- **T030** `[US2]` Edit `.claude/agents/dev-ai-integration.md` SDK matrix (≈L.21): add Fable 5 as most-capable Anthropic option.
- **T031** `[US2]` Add the 4 caveats near the matrix: (1) thinking always on, `thinking:{type:"disabled"}`→400 (omit param); (2) no assistant prefill; (3) `stop_reason:"refusal"` (cyber/bio) — handle before reading content; (4) 30-day retention required (no ZDR).
- **T032** `[US2]` Correct the "Adaptive Thinking" note (≈L.31) so Opus-style toggling/prefill is not implied as valid for Fable 5.

## Phase 4 — US-3 runtime note
- **T040** `[US3]` Add a note in `docs/guides/TEAM-GUIDE.md`: use `--model claude-fable-5` for heavy foundation sessions (multi-PR migrations, deep audits); deliberate/costlier; **no frontmatter change, no `fable` alias**.
- **T041** `[US3][P]` Add one line in `.claude/skills/agent-teams/SKILL.md` near the `--model` doc (≈L.242) mirroring T040; explicitly state frontmatter is untouched.

## Phase 5 — US-4 FAQ
- **T050** `[US4]` Edit `templates/FAQ.md` (≈L.174–184): mention Fable 5 where accurate (most-capable tier), not as default.

## Phase 6 — Changelog
- **T060** Add a `[Unreleased]` entry in `CHANGELOG.md` (English) summarizing the Fable 5 doc integration; **do not edit historical entries**.

## Phase 7 — Regen & verify (Definition of Done)
- **T070** Run `npm --prefix website run generate`; stage regenerated `website/docs/**`.
- **T071** Verify: re-run generate → no further diff; `./scripts/validate-counts.sh` exits 0.
- **T072** Consistency grep: `grep -rn "claude-fable-5\|Fable 5" docs/ templates/ .claude/ | grep -v website/` → every hit pairs id + `$10 / $50`, no "default" wording (CS-001/007).
- **T073** Caveats checklist on F4 — all 4 present (CS-003).
- **T074** No-runtime guard: `git diff` shows zero `.claude/agents/*` `model:` changes and no new `fable` alias (CS-004).
- **T075** Self-review against EF-001…008 and CS-001…006; prepare single focused PR.

## Traceability
| US | Tasks |
|----|-------|
| US-1 (P1) | T010, T011, T020, T021 |
| US-2 (P1) | T030, T031, T032 |
| US-3 (P2) | T040, T041 |
| US-4 (P3) | T050 |
| Cross/DoD | T001, T002, T060, T070–T075 |
