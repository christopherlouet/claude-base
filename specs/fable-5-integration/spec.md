# Spec — Claude Fable 5 documentation integration

> Status: DRAFT · Scope: DOCUMENTATION ONLY (no runtime/frontmatter change)
> Source of truth: the `claude-api` skill reference + the work-explore map in this session.

## 1. Summary

Document **Claude Fable 5** — Anthropic's most capable widely-released model — across the foundation's guidance so that (a) users know when a task is demanding enough to justify reaching for it over Opus 4.8, (b) users building LLM apps via the `dev-ai-integration` agent get an accurate SDK model menu with Fable 5's API caveats, and (c) maintainers know how to run the foundation's own heaviest sessions on it. No agent is repointed and no model tier alias is invented; the change is purely informational.

**Reference facts** (to be stated consistently): id `claude-fable-5`; $10 / $50 per MTok input/output (2× Opus 4.8); 1M context (default and max); 128K max output; same tokenizer as Opus 4.8; thinking always on; raw chain-of-thought never returned; no assistant prefill; safety-classifier refusals possible (cyber/bio); requires 30-day data retention (unavailable under zero-data-retention).

## 2. User Stories

### P1 — MVP

**US-1 — Position Fable 5 as the top "most demanding / long-horizon" tier**
As a foundation user choosing a model for a hard task,
I want the model-recommendation and effort guidance to name Fable 5 as the tier above Opus 4.8 for the most demanding, long-horizon autonomous work,
So that I reach for it deliberately and only when the task justifies the higher cost.

- **Given** `docs/reference/best-practices.md` "Recommended Model" table, **When** a reader scans the tiers, **Then** a Fable 5 row sits above Opus 4.8, labelled for "most demanding reasoning / long-horizon autonomous work", and explicitly notes the 2× Opus cost and "reach for it deliberately" framing.
- **Given** the same file's effort guidance, **When** a reader looks for the heaviest setting, **Then** Opus 4.8 + `xhigh`/`max` remains the default heavy path and Fable 5 is presented as a distinct, costlier escalation — not a replacement for Opus 4.8.
- **Given** `docs/reference/advanced-features.md` and `docs/guides/TEAM-GUIDE.md`, **When** they describe top-tier model choice, **Then** they reference Fable 5 consistently with best-practices.md (same id, same price, same framing) and do not contradict each other.
- **Given** any edited source doc, **When** CI runs, **Then** the regenerated `website/docs/` mirror is committed and the "Counts gate" passes (no `git diff` drift).

**US-2 — Accurate SDK model menu with API caveats for app builders**
As a developer building an LLM app through the `dev-ai-integration` agent,
I want Fable 5 listed in the Anthropic SDK model matrix together with its API differences,
So that I don't write code that breaks against Fable 5 (disabled thinking, prefill, retention).

- **Given** `.claude/agents/dev-ai-integration.md` SDK matrix, **When** a reader consults the Anthropic row, **Then** Fable 5 appears as the most-capable option alongside Opus 4.8 / Sonnet 4.6 / Haiku 4.5.
- **Given** the same agent, **When** Fable 5 is mentioned, **Then** its four caveats are stated: (1) thinking is always on — `thinking:{type:"disabled"}` returns 400 (omit the param); (2) assistant prefill is not supported; (3) safety classifiers may return `stop_reason:"refusal"` (cyber/bio) and must be handled before reading content; (4) 30-day data retention required (unavailable under ZDR).
- **Given** the agent's existing examples or "Adaptive Thinking" note, **When** they assume Opus-style toggling or prefill, **Then** they are corrected or scoped so they are not stated as valid for Fable 5.

### P2 — Important

**US-3 — Runtime usage note for the foundation's own heavy work**
As a maintainer of claude-base running a large multi-PR migration or deep audit,
I want a note telling me to run those sessions on Fable 5 via `--model claude-fable-5`,
So that I use the strongest model for the foundation's hardest work without altering agent definitions.

- **Given** `docs/guides/TEAM-GUIDE.md` (and/or the `agent-teams` skill's `--model` documentation), **When** a maintainer reads the model-selection guidance, **Then** there is a note recommending `--model claude-fable-5` for dispatched/heavy foundation sessions (multi-PR migrations, deep audits), framed as a deliberate, costlier choice.
- **Given** that note, **When** it describes how to select Fable 5, **Then** it uses the documented `--model <id>` / `/model` selection path and explicitly states that agent frontmatter is **not** changed and no `fable` tier alias exists.

### P3 — Nice-to-have

**US-4 — FAQ touch-up on context/thinking framing**
As a user reading the onboarding FAQ,
I want the context-window / Adaptive-Thinking FAQ to acknowledge Fable 5 where relevant,
So that the FAQ stays current without overstating Fable 5 as a default.

- **Given** `templates/FAQ.md` entries on the 1M context window and Adaptive Thinking, **When** a reader consults them, **Then** Fable 5 is mentioned only where accurate (e.g. most-capable tier) and is not presented as the default model.

## 3. Functional Requirements

- **EF-001** — Every Fable 5 mention states the canonical id `claude-fable-5` (never a date-suffixed or invented variant) and the price `$10 / $50 per MTok`.
- **EF-002** — Fable 5 is positioned **above** Opus 4.8, never as a replacement; Opus 4.8 remains the documented default for complex tasks.
- **EF-003** — The cost differential (2× Opus 4.8) and the "deliberate / reach-for-it" framing appear at least once per surface that recommends Fable 5.
- **EF-004** — The four API caveats appear wherever Fable 5 is offered as an SDK build target (US-2).
- **EF-005** — The runtime note (US-3) recommends `--model claude-fable-5` and explicitly excludes any frontmatter change or new tier alias.
- **EF-006** — All edited sources are in English; the `website/docs/` mirror is regenerated and committed so the Counts gate passes.
- **EF-007** — Cross-surface consistency: best-practices.md, advanced-features.md, TEAM-GUIDE.md (and FAQ if touched) agree on id, price, context, and framing.
- **EF-008** — A new CHANGELOG `[Unreleased]` entry documents the addition (English); the historical CHANGELOG record is not edited.

## 4. Edge Cases

- **Stale mirror**: a source doc edited without regen → Counts gate must catch it (acceptance covered by EF-006).
- **Caveat omission**: Fable 5 named as a build target without its caveats → fails EF-004; reviewer must reject.
- **Scope creep into runtime**: any change to an agent's `model:` frontmatter or creation of a `fable` alias → out of scope, must be rejected (EF-005).
- **Contradiction**: one surface calls Fable 5 the default while another calls Opus 4.8 the default → fails EF-007.
- **Wrong price/id drift**: a future model price change leaves these docs stale → mitigated by stating facts in few, consistent places.

## 5. Entities

Not applicable — no data model. The "entity" is documentation content describing model tiers.

## 6. Success Criteria

- **CS-001** — 100% of Fable 5 mentions use `claude-fable-5` and `$10 / $50` (grep check).
- **CS-002** — Fable 5 appears as a tier above Opus 4.8 in all three target docs (best-practices, advanced-features, TEAM-GUIDE).
- **CS-003** — All four caveats present in `dev-ai-integration.md` (checklist).
- **CS-004** — Zero changes to any `.claude/agents/*` `model:` frontmatter and zero new `fable` alias (git diff review).
- **CS-005** — `npm --prefix website run generate` produces no uncommitted diff after the change; `./scripts/validate-counts.sh` passes; CI Counts gate green.
- **CS-006** — A single focused PR following the `CHANGELOG.md:141` playbook (source edit → regen → commit mirror → CHANGELOG `[Unreleased]`).

## 7. Out of Scope

- Changing any agent/skill/command `model:` frontmatter (no agent repointed to Fable 5).
- Creating a `fable` model tier alias.
- Making Fable 5 a default anywhere.
- Editing historical CHANGELOG entries or `specs/` history.
- Bedrock/Vertex/Foundry-specific Fable 5 availability details (mention only if already framed generically).
- Mythos 5 (`claude-mythos-5`, Project Glasswing only) — not documented here.
- Any code/runtime behaviour change, hook, or setting.

## 8. Clarification Points — RESOLVED

1. **FAQ scope (US-4, P3):** ✅ **Included** in this PR — `templates/FAQ.md` is updated where accurate (US-4 promoted into scope).
2. **Runtime note placement (US-3):** ✅ **Both** — note in `TEAM-GUIDE.md` and a line in the `agent-teams` skill where `--model` is already documented.
3. **Release framing:** ✅ **`[Unreleased]` doc entry** (patch-level); shippable on merge, tagged later.
