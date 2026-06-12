# Plan — Claude Fable 5 documentation integration

> Spec: `specs/fable-5-integration/spec.md` (clarifications RESOLVED)
> Type: documentation-only · Complexity: **Simple–Medium** (low logic, high cross-surface consistency risk)
> Playbook: mirror the `CHANGELOG.md:141` bulk model-doc refresh (source edit → regen → commit mirror → CHANGELOG `[Unreleased]`).

## 1. Summary

Add Claude Fable 5 to the foundation's guidance as the tier above Opus 4.8, give app-builders an accurate SDK menu with API caveats, and tell maintainers to run the foundation's heaviest sessions on `--model claude-fable-5` — without touching any agent runtime config. The hard part is not the prose; it is **consistency across 6 source surfaces + the generated mirror + CI**.

## 2. Technical context

- **Edit only sources**: `docs/`, `templates/`, `.claude/`. Never hand-edit `website/docs/`.
- **Mandatory regen**: `npm --prefix website run generate` after all source edits; commit the regenerated mirror. CI "Counts gate" re-runs generate + `git diff --exit-code` and fails on drift.
- **No counter impact**: model mentions are not gated counts (`validate-counts.sh:252` explicitly avoids "by model" counts) — but the mirror regen is still required.
- **Frozen reference facts** (use verbatim, every surface): `claude-fable-5` · `$10 / $50` per MTok (2× Opus 4.8) · 1M context (default & max) · 128K max output · same tokenizer as Opus 4.8 · thinking always on (`thinking:{type:"disabled"}` → 400, omit param) · no assistant prefill · safety-classifier refusals possible (cyber/bio) · 30-day data retention required (unavailable under ZDR).

## 3. Impacted files

| # | File | Change | US |
|---|------|--------|----|
| F1 | `docs/reference/best-practices.md` | Add Fable 5 row above Opus 4.8 in "Recommended Model"; keep Opus 4.8 as default; note 2× cost + "deliberate"; reconcile Effort-Levels table | US-1 |
| F2 | `docs/reference/advanced-features.md` | Add/adjust top-tier model section so Fable 5 is the costlier escalation above Opus 4.8; consistent facts | US-1 |
| F3 | `docs/guides/TEAM-GUIDE.md` | Update model/cost tables (L.77, 296, 299, 580 area) to include Fable 5 tier; add US-3 runtime note | US-1, US-3 |
| F4 | `.claude/agents/dev-ai-integration.md` | Add Fable 5 to SDK matrix (L.21) + 4 caveats; correct the Adaptive-Thinking note (L.31) so Opus-style toggling/prefill is not implied for Fable 5 | US-2 |
| F5 | `.claude/skills/agent-teams/SKILL.md` | Add one line near L.242 (`--model` doc) recommending `--model claude-fable-5` for heavy foundation sessions; state no frontmatter/alias change | US-3 |
| F6 | `templates/FAQ.md` | Touch L.174–184 (1M context / Adaptive Thinking) to mention Fable 5 where accurate, not as default | US-4 |
| F7 | `CHANGELOG.md` | New `[Unreleased]` entry (English), historical entries untouched | EF-008 |
| G1 | `website/docs/**` (generated) | Produced by regen — committed, never hand-edited | EF-006 |

## 4. Phases & ordering

**Ordering rationale:** establish the canonical fact block first (F1), then propagate so later surfaces copy from a single agreed wording → minimizes contradiction risk (EF-007).

1. **Phase 0 — Baseline** : confirm clean tree, run `./scripts/validate-counts.sh` (note pre-existing state), skim each target file's current model wording.
2. **Phase 1 — Anchor surface (US-1 core)** : F1 best-practices.md — write the canonical Fable 5 tier + caveat-free positioning + cost framing. This becomes the wording reference.
3. **Phase 2 — Propagate US-1** : F2 advanced-features.md, F3 TEAM-GUIDE.md tier rows — copy facts/framing from F1.
4. **Phase 3 — US-2 builder caveats** : F4 dev-ai-integration.md SDK matrix + 4 caveats + Adaptive-Thinking correction.
5. **Phase 4 — US-3 runtime note** : F3 TEAM-GUIDE.md note + F5 agent-teams SKILL.md line. Cross-check both say "no frontmatter / no alias".
6. **Phase 5 — US-4 FAQ** : F6 templates/FAQ.md touch-up.
7. **Phase 6 — Changelog** : F7 `[Unreleased]` entry.
8. **Phase 7 — Regen & verify** : `npm --prefix website run generate`; commit mirror; `./scripts/validate-counts.sh`; consistency grep; self-review against EF-001…008.

## 5. Verification strategy

- **Consistency grep** (CS-001/CS-007): `grep -rn "claude-fable-5\|Fable 5" docs/ templates/ .claude/ | grep -v website/` → every hit pairs id + `$10 / $50`; no "default" wording.
- **Caveats checklist** (CS-003): all 4 present in F4 (thinking-disabled→400, no prefill, refusal, 30-day retention).
- **No-runtime guard** (CS-004): `git diff --stat` shows **zero** changes under `.claude/agents/*` frontmatter `model:` lines and no new `fable` alias anywhere.
- **Mirror clean** (CS-005): after regen, `git status` shows the `website/docs/` changes staged and a re-run of generate yields no further diff; `validate-counts.sh` exits 0.
- **CI** (CS-006): Counts gate green on the PR.

## 6. Risks & mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Mirror drift (forgot regen) → CI red | High likelihood | Phase 7 is mandatory; regen + commit before PR; treat as definition of done |
| Cross-surface contradiction (default vs escalation) | Medium | Anchor-first ordering (Phase 1); single canonical wording copied outward; final consistency grep |
| Caveat omission in F4 | Medium | Explicit 4-item checklist in CS-003; reviewer rejects if any missing |
| Scope creep into runtime (someone "helpfully" repoints an opus agent) | Medium | EF-005 hard guard; CS-004 git-diff review; out-of-scope list in spec |
| Stale price/id in future | Low | Facts stated in few places; CHANGELOG notes the source-of-truth date |
| Hand-edit of `website/docs/` | Low | base-maintenance rule + banner; never touch mirror manually |
| Touching historical CHANGELOG | Low | Only add under `[Unreleased]`; leave dated sections intact |

## 7. Definition of Done

All P1+P2+P3 stories met · EF-001…008 satisfied · CS-001…006 verified · mirror regenerated & committed · `validate-counts.sh` green · single focused PR with `[Unreleased]` entry · zero runtime/frontmatter/alias change.

## 8. Out of scope (reaffirmed)

No agent repointed; no `fable` alias; no default change; no historical CHANGELOG edit; no Mythos 5; no Bedrock/Vertex/Foundry-specific availability matrix; no code/hook/setting change.
