# Plan — Marketplace curation engine

> Spec: `specs/marketplace-curation-engine/spec.md` (clarifications RESOLVED)
> Complexity: **Complex** (multi-component, external data source, billing-sensitive automation, supply-chain surface)
> Strategy: ship P1 as **independent slices** (schema+registry → trust-score → rot-watch → bot), one PR each — never one mega-PR.

## 1. Summary

Build a deterministic, billing-safe curation engine in four layers: a **machine-readable data model** (canonicalVendor registry + pinned/trust/provenance fields on recommendations), a **community-trust scorer** (public signals, no LLM), a **rot-watch** (nightly, LLM-free, emits one digest), and a **discovery** pass (monthly, LLM, budget-capped). Deployment target is a cron bot on `ubuntu@192.168.1.101` — nightly rot-watch costs $0 tokens (immune to the 2026-06-15 agentic-billing change), monthly discovery runs on a dedicated capped API key.

## 2. Technical context & key decisions

- **EF-012 is the spine.** Frequent path = **zero model usage**. Only discovery touches an LLM, infrequently, under a hard budget with fail-safe. This drives the component split.
- **Reuse, don't reinvent:** `.claude/presets/*.json` (11, 13 unique vendor skills), `scripts/lib/{preset-recommendations,modules,preset-detect,common}.sh`, `scripts/validate-presets.sh`, `scripts/check-updates.sh` (partial skills.sh discovery), `specs/marketplace-audit/` (the methodology + verdicts), `tests/*.bats` + `tests/presets-fixtures/`.
- **canonicalVendor location — DECISION:** a **central registry** `.claude/curation/registry.json` (source of truth), not per-skill frontmatter. Rationale: enables the candidate report (EF-011) from one file, avoids editing every skill (churn + base-maintenance noise), keeps durable-skill frontmatter clean (absence = permanence signal stays implicit). Reversible. *(Flag for confirmation in §7.)*
- **Schema fix bundled:** create the missing `specs/presets/schema.json` (every preset's `$schema` 404s today) **and** extend it for the new recommendation fields — one move fixes the dangling pointer and formalises the model.
- **Pinning:** every recommendation carries a `pinnedRef` (commit SHA or tag). Migrating the existing 13 entries = resolve each repo's current good ref once.
- **Watch output = mix** (clarification 1): auto-draft a re-pin PR for low-risk (newer tag that re-passes trust+safety); propose-only digest for new candidates / removals.
- **Trust thresholds = global first** (clarification 2) in `.claude/curation/trust-thresholds.json`; two-track (authority needs no popularity bar; community applies the global bar).
- **Discovery = periodic + targeted** (clarification 3): monthly, over covered domains + known sources (skills.sh, vendor orgs).

## 3. Architecture (components)

```
DATA          .claude/curation/registry.json        (canonicalVendor records + candidates)
              .claude/curation/trust-thresholds.json (global bars, two-track)
              specs/presets/schema.json              (NEW — preset + recommendation schema)
              .claude/presets/*.json                 (recommendedVendorSkills[] gains pinnedRef/trust/provenance/lastVerified)

SCORING       scripts/lib/trust-score.sh             (gh api → signals → verdict; NO LLM)
              scripts/lib/curation-common.sh         (shared helpers, gh wrappers, digest format)

WATCH         scripts/curation-watch.sh              (NIGHTLY, LLM-free: rot + content-drift → digest; mix output)
              scripts/curation-discover.sh           (MONTHLY, LLM: claude -p, capped, Haiku triage → propose)

DEPLOY        docs/recipes/curation-bot-deploy.md     (cron/systemd on the box; nightly vs monthly; API-key + budget)

VALIDATION    scripts/validate-presets.sh            (extend: require pinnedRef, validate new fields)
              tests/curation-*.bats + fixtures

DOCS          docs/recipes/recommended-vendor-skills.md (methodology: drop publisher-veto → advice-neutrality + provenance)
              specs/marketplace-audit/spec.md           (record the trust-bar + neutrality methodology shift)
```

## 4. Impacted files

| # | File | Action | US |
|---|------|--------|----|
| F1 | `specs/presets/schema.json` | **Create** — formal schema + new recommendation fields (fixes 404) | US-1, US-4 |
| F2 | `.claude/curation/registry.json` | **Create** — canonicalVendor records, seeded from audit verdicts | US-1 |
| F3 | `.claude/curation/trust-thresholds.json` | **Create** — global bars, two-track | US-2 |
| F4 | `.claude/presets/*.json` (11) | **Modify** — add `pinnedRef`/`trustTrack`/`provenance`/`lastVerified` to each `recommendedVendorSkills[]` entry | US-1, US-4 |
| F5 | `scripts/lib/trust-score.sh` | **Create** — deterministic scorer (gh api) | US-2 |
| F6 | `scripts/lib/curation-common.sh` | **Create** — shared gh/digest helpers | US-3 |
| F7 | `scripts/curation-watch.sh` | **Create** — nightly LLM-free rot+drift watch, digest, mix output | US-3, US-4 |
| F8 | `scripts/validate-presets.sh` | **Modify** — require pinnedRef + validate new fields/registry | US-1, US-4 |
| F9 | `scripts/curation-discover.sh` | **Create** — monthly LLM discovery, budget cap + fail-safe | US-5 |
| F10 | `docs/recipes/recommended-vendor-skills.md` | **Modify** — methodology: advice-neutrality + provenance replace publisher-veto | US-6 |
| F11 | `specs/marketplace-audit/spec.md` | **Modify** — record trust-bar + neutrality shift (community-trust, no prod-repo bar) | US-2, US-6 |
| F12 | `.claude/rules/` precedence note (or section in an existing rule) | **Create/Modify** — foundation-vs-vendor precedence | US-7 |
| F13 | `docs/recipes/curation-bot-deploy.md` | **Create** — bot deploy (cron, API key, budget) | US-3, US-5 |
| F14 | `tests/curation-trust-score.bats`, `tests/curation-watch.bats` (+ fixtures) | **Create** — coverage | all |
| G1 | `website/docs/**` | **Regen** if F10/F11/recipe matrix change docs | — |

## 5. Phases & ordering (P1 = slices 1–4)

**Phase 0 — Baseline.** Clean tree; run `validate-presets.sh` + `bats tests/` to record green baseline; confirm `gh` auth available for scoring.

**Slice 1 — Data model & schema (US-1, US-4 data)** → PR #1
1. F1 create `specs/presets/schema.json` (existing shape + new fields).
2. F3 thresholds file shape. F2 registry shape, seeded from `specs/marketplace-audit` verdicts (POINT-TO-VENDOR / REDUCE → candidate records).
3. F4 add `pinnedRef`/`trustTrack`/`provenance`/`lastVerified` to all 11 presets (resolve each of the 13 repos' current good ref once).
4. F8 extend `validate-presets.sh` (require pinnedRef; validate new fields; validate registry). F14 schema/validation tests.

**Slice 2 — Community-trust scorer (US-2)** → PR #2
5. F5 `trust-score.sh` (gh api: stars/forks/pushed_at/archived/license → verdict; two-track; global thresholds). F6 shared helpers.
6. F14 `curation-trust-score.bats` with fixtures mocking `gh api` (offline, deterministic).

**Slice 3 — Rot-watch, LLM-free (US-3, US-4 safety-on-drift)** → PR #3
7. F7 `curation-watch.sh`: iterate registry+presets → score → flag archived/stale/**collapse (sustained)**/license/**content-drift vs pinnedRef** → emit ONE digest (json+md). Mix: auto-draft re-pin (low-risk) vs propose-only.
8. `--dry-run` + idempotent `lastVerified` update; fail-safe on gh errors. F14 `curation-watch.bats`.

**Slice 4 — Nightly bot deploy (US-3 ops)** → PR #4 (+ ops step on the box)
9. F13 deploy recipe: nightly cron/systemd timer for `curation-watch.sh` (LLM-free, $0). Digest → GitHub issue/draft PR via `gh`.

**Phase P2 — Important**
- **Slice 5 — Discovery (US-5, US-6)** → PR #5: F9 `curation-discover.sh` (claude -p on **dedicated capped API key**, Haiku triage, batch, prompt-cache the methodology, hard budget + fail-safe). F10/F11 methodology shift (advice-neutrality + provenance, drop publisher-veto; community-trust bar). Extend `check-updates.sh` skills.sh discovery. Monthly cron in F13.
- **Slice 6 — Precedence (US-7)** → PR #6: F12 foundation-vs-vendor precedence rule.

**Phase P3 — Nice-to-have**
- **Slice 7** US-8 moat-encroachment signal in discovery; US-9 recommendation-drift surfaced as a tracked change (reuse the crossing-migration report).

## 6. Risks & mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Supply-chain** — we recommend third-party code users run | High | Mandatory safety screen **before pin** (EF-006); pin to immutable ref (EF-005); drift re-opens safety as propose-only |
| **Budget runaway** (discovery LLM) | High | Dedicated capped API key; hard token budget; fail-safe = report-and-stop, never silent/ runaway (EF-012); nightly stays LLM-free |
| **False "collapse"** on a noisy popularity reading | Medium | Require a **sustained** signal (≥2 consecutive runs) before flagging; never act on one reading |
| **Pinned ref unresolvable** (force-push/tag deleted) | Medium | Flag as rot; fall back to last-known-good (edge case in spec) |
| **Mirror drift** if docs touched (F10/F11/recipe matrix) | Medium | `npm --prefix website run generate` + Counts gate; never hand-edit `website/docs/` |
| **Secret leak** (bot API key) | High | Never commit; env var on the box; deploy recipe documents secret handling; no key in repo/digest |
| **base-maintenance counters** | Low | `.claude/curation/` is not a command/agent/skill/rule dir → not a counted artifact; new `scripts/` need shellcheck; run `validate-counts.sh` to confirm |
| **gh rate limits** | Low | 13 repos/night is trivial; authenticated gh; backoff in helper |
| **Scope creep into reduction waves** | Medium | Out-of-scope (positioning-review owns execution); engine only proposes |

## 7. Open decisions to confirm before Slice 1

1. **canonicalVendor location:** central registry `.claude/curation/registry.json` (planned) vs per-skill frontmatter. Plan recommends central registry.
2. **Digest sink:** GitHub **issue** vs **draft PR** for propose-only findings (auto-draft re-pins are PRs regardless).
3. **Discovery runtime:** `claude -p` headless vs Agent SDK vs a Managed Agent — affects the deploy recipe (all draw on the post-06-15 agentic credit / API key).

## 8. Definition of Done (P1)

Schema created + presets pinned + registry seeded + validator enforces pinning · trust-scorer deterministic & tested · rot-watch emits one digest, LLM-free, dry-run + fail-safe, tested · nightly bot recipe shipped · `validate-presets.sh` + `bats` green · `validate-counts.sh` green · any touched doc regenerated · zero LLM in the nightly path.

## 9. Out of scope (reaffirmed)

No auto-install · no auto-merge of findings (mix only auto-*drafts*) · no execution of reduction waves · no vendoring third-party content · no full marketplace index · Mythos/model concerns.
