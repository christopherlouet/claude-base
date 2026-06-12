# Spec — Marketplace curation engine (watch + community-trust + canonicalVendor)

> Status: DRAFT · Builds on the session's captured direction
> (memories: community-graduation-mechanism-state, solo-maintainer-community-trust-bar,
> vendor-neutrality-not-publisher-veto, curation-vision-open-refinements)
> Strategic north star: `specs/foundation-positioning-review/spec.md` · graduation design:
> `docs/designs/2026-06-12-foundation-vendor-graduation-design.md`

## 1. Summary

Turn the foundation's one-off, manually-dated curation snapshots into a **living curation engine**: a recurring check that keeps the recommended community-skill list fresh (detecting both rot in what we already point to and newly-published candidates), a **community-trust criterion** scored from public popularity/maintenance signals (so a solo maintainer never has to build projects to qualify a skill), and a **machine-readable record** (`canonicalVendor`) marking which foundation skills are graduation candidates and which vendor would replace them. Every recommendation is pinned, safety-screened, and provenance-disclosed.

## 2. User Stories

### P1 — MVP: the living refresh loop on known candidates

**US-1 — Machine-readable graduation record (`canonicalVendor`)**
As the foundation maintainer,
I want each graduatable foundation skill to carry a structured record naming its canonical replacement vendor, the pinned reference of that vendor skill, its trust verdict, and the date last verified,
So that graduation candidates are tracked by the system instead of buried in prose specs.

- **Given** a foundation skill judged a graduation candidate, **When** I inspect its record, **Then** it states: the canonical vendor identifier, a **pinned reference** (a fixed version/commit, not "latest"), the trust track (authority vs community), the trust verdict, the provenance (publisher), and a `lastVerified` date.
- **Given** a durable workflow skill (the moat), **When** I inspect it, **Then** it carries **no** canonical-vendor record (its absence is the positive signal of permanence).
- **Given** the full set of records, **When** a candidate report is requested, **Then** the system can list all graduation candidates and their freshness without a human re-reading the audit pilots.

**US-2 — Community-trust criterion (no project-building required)**
As a solo maintainer,
I want a skill's eligibility decided from public popularity and maintenance signals rather than from production-adoption evidence I'd have to manufacture,
So that I can qualify community skills cheaply and the referential can grow richer.

- **Given** any candidate skill, **When** it is scored, **Then** the criterion uses public signals only (popularity count, forks, recency of last update, maintenance activity, not-archived, license) — **never** a "build N production projects" requirement.
- **Given** a skill authored by the tool's own organisation (canonical vendor), **When** scored, **Then** **authority** is the dominant signal and a low popularity bar suffices.
- **Given** a skill from a third-party author with no institutional authority, **When** scored, **Then** a **high** popularity/recency bar applies before it can be recommended.
- **Given** a distribution channel that exposes install/download counts, **When** available, **Then** those counts feed the score; **when not available**, the score falls back to popularity+forks without penalising the skill for the missing metric.

**US-3 — Recurring rot re-verification (keeps the known list honest)**
As the maintainer,
I want a scheduled check over every skill we already recommend or point to, that flags decay,
So that stale or dead recommendations are caught automatically instead of rotting silently.

- **Given** the recurring check runs, **When** a recommended skill is now archived, abandoned (no update past a defined recency window), suffers a popularity collapse, or changes license, **Then** it is flagged with the specific reason.
- **Given** a skill pinned to a reference, **When** its current content has **drifted** from the pinned reference, **Then** the drift is flagged (the check compares content/reference, not only repository status).
- **Given** a check run completes, **When** there are findings, **Then** they are delivered as a **single reviewable digest** (one batched proposal), never as a stream of separate notifications.
- **Given** a check run with no findings, **When** it completes, **Then** it records the run and updates `lastVerified` dates without producing noise.

**US-4 — Safety/integrity gate + mandatory pinning (distinct from trust)**
As the maintainer recommending third-party skills to users,
I want every recommendation safety-screened and pinned to a fixed reference,
So that popularity is never mistaken for safety and users don't silently receive whatever a repository contains today.

- **Given** a skill considered for recommendation, **When** it passes the trust criterion, **Then** it must **separately** pass an integrity screen (a content review for obviously dangerous instructions) before it can be recommended — trust alone is insufficient.
- **Given** a recommended skill, **When** it is published in the list, **Then** it carries a **pinned reference**; an unpinned ("latest") recommendation is not allowed.
- **Given** a richer referential (more candidates), **When** the list grows, **Then** the integrity screen applies to every entry — coverage scales with the list.

### P2 — Important

**US-5 — Discovery of new candidates**
As the maintainer,
I want the engine to periodically surface newly-published skills in the foundation's domains and run them through the trust, safety and neutrality checks,
So that fresh community work enters the referential without me hunting for it.

- **Given** a discovery sweep runs, **When** a newly-published skill in a covered domain clears the trust + safety + advice-neutrality checks, **Then** it is **proposed** as a new candidate (proposal only — never auto-added).
- **Given** a proposed candidate, **When** surfaced, **Then** it includes its trust verdict, provenance, pinned reference, and a short fit rationale for maintainer review.

**US-6 — Advice-neutrality + provenance (replaces publisher veto)**
As an independent curator,
I want skills judged on the neutrality of their advice and their fit, not on who published them, with the publisher disclosed,
So that excellent skills from Anthropic competitors are not excluded on identity alone.

- **Given** a skill published by an Anthropic competitor, **When** evaluated, **Then** it is **not** excluded for publisher identity; only quality, fit, safety and advice-neutrality decide.
- **Given** any vendor skill, **When** evaluated, **Then** an **advice-neutrality** check applies uniformly: does it push the user toward proprietary lock-in or away from their chosen stack/Claude? (applied to all vendors, not just competitors).
- **Given** a recommended skill, **When** listed, **Then** its **publisher is disclosed** as metadata so the user decides with full information.
- **Given** a skill that advocates a competing primary stack, **When** recommended, **Then** it is scoped by a usage condition (surfaced only when that stack is in use), never blanket-banned.

**US-7 — Foundation-vs-vendor precedence policy**
As a user who opted into both a foundation skill and a recommended vendor skill,
I want a defined precedence when their advice conflicts,
So that coexisting skills don't leave me with contradictory guidance.

- **Given** a foundation workflow skill and a vendor skill are both active, **When** their guidance conflicts, **Then** a documented precedence rule resolves it (or a scoping convention prevents the collision).
- **Given** two recommended vendor skills overlap, **When** both could apply, **Then** the curation records which is preferred for which need.

### P3 — Nice-to-have

**US-8 — Moat-encroachment signal**
As the maintainer,
I want the watch to also flag community skills that start covering the foundation's durable workflow patterns,
So that I get a strategic signal when the moat itself is being challenged.

- **Given** a discovery sweep, **When** a high-trust skill covers a workflow pattern currently marked durable/KEEP, **Then** it is flagged as a strategic signal (not auto-treated as a graduation candidate).

**US-9 — Recommendation-drift treated as a versioned change**
As a user of an existing project,
I want changes to my preset's recommendations to be surfaced as a tracked change rather than silently drifting,
So that an added/removed recommendation is visible and reversible like other foundation changes.

- **Given** a preset's recommendation set changes, **When** an existing project updates, **Then** the change is reported (added/removed/repinned), consistent with how other foundation changes are migrated.

## 3. Functional Requirements

- **EF-001** — Graduatable foundation skills carry a `canonicalVendor` record (vendor id, pinned reference, trust track, verdict, provenance, `lastVerified`); durable workflow skills carry none.
- **EF-002** — The trust criterion uses only public signals (popularity, forks, recency, maintenance, not-archived, license, install counts where exposed); the "≥3 production repos" requirement is removed.
- **EF-003** — Two trust tracks: canonical-vendor (authority-led, low popularity bar) and community (high popularity/recency bar).
- **EF-004** — A recurring check re-verifies every recommended/pointed skill for archive/abandonment/popularity-collapse/license-change **and content drift vs the pinned reference**.
- **EF-005** — Every recommendation is pinned to a fixed reference; no "latest" recommendations.
- **EF-006** — A safety/integrity screen, **distinct from** the trust criterion, gates every recommendation.
- **EF-007** — Watch findings are delivered as a single batched, reviewable digest per run; nothing is auto-applied without review (unless a clarification decides otherwise).
- **EF-008** — Publisher identity is **not** an exclusion criterion; an advice-neutrality check applies to all vendors; publisher provenance is disclosed on every recommendation.
- **EF-009** — A precedence policy resolves foundation-vs-vendor and vendor-vs-vendor advice conflicts.
- **EF-010** — Third-party content is **pointed to, never copied** into the foundation (license boundary preserved).
- **EF-011** — A candidate/graduation report is producible from the records without re-reading prose audit specs.
- **EF-012** — The engine runs at **bounded, predictable recurring cost.** The frequent/nightly portion (rot re-verification) must require **no model usage** (deterministic checks only) so it stays free regardless of model-billing changes. The model-based portion (discovery) runs at a **low cadence under an explicit budget cap**; it must **fail safe** — a budget/credit exhaustion is reported, never a silent stop or runaway spend. (Context: from 2026-06-15 Anthropic meters `claude -p`/Agent SDK/cron usage on a separate credit at API rates, no rollover, stopping automation on exhaustion — see memory `anthropic-june15-2026-agentic-billing`.)

## 4. Edge Cases

- **Channel exposes no install count** → score on popularity+forks; do not penalise (EF-002).
- **Recommended repo deleted/made private** → flagged as a hard rot finding, recommendation suspended.
- **Pinned reference no longer resolvable** (force-push, tag deleted) → flagged; fall back to last-known-good.
- **Popular but unsafe skill** → passes trust, **fails** safety screen → not recommended (EF-006).
- **Skill with zero institutional authority but viral popularity** → community track high bar; still requires safety + advice-neutrality.
- **Competitor skill that advocates leaving Claude** → not banned; condition-scoped + provenance-disclosed (US-6).
- **Watch run during a popularity dip caused by metric reset** → avoid false "collapse" on a single noisy reading (require a sustained signal).
- **Digest with hundreds of findings** → must remain one reviewable artifact, batched/grouped, not a flood (EF-007).
- **A durable workflow skill mistakenly given a canonicalVendor record** → contradiction; should be caught (EF-001).

## 5. Entities

- **Canonical-vendor record** — per graduatable foundation skill: `vendorId`, `pinnedRef`, `trustTrack` (authority|community), `trustVerdict`, `provenance` (publisher), `adviceNeutrality` (pass/flag), `lastVerified`, `status` (candidate|graduating|graduated).
- **Trust score** — per vendor skill: the public signals captured + the computed verdict + the threshold track applied.
- **Watch finding** — one issue from a run: subject skill, type (rot: archived|stale|collapse|license|drift; or discovery: new-candidate; or moat-encroachment), evidence, proposed action.
- **Watch digest** — the batched set of findings for one run + run metadata (date, scope, counts).

## 6. Success Criteria

- **CS-001** — A scheduled check runs end-to-end with **zero** maintainer project-building.
- **CS-002** — 100% of recommended/pointed skills carry a pinned reference, a trust verdict, a provenance, and a `lastVerified` date.
- **CS-003** — Each watch run yields exactly **one** reviewable digest, not N separate alerts.
- **CS-004** — An archived/abandoned/license-changed/drifted recommendation is flagged within one watch cycle.
- **CS-005** — No publisher-identity exclusion remains; the advice-neutrality check is applied uniformly and recorded.
- **CS-006** — A safety screen exists and is recorded **separately** from trust; no unpinned recommendation ships.
- **CS-007** — A graduation-candidate report is generated from records alone (no prose re-reading).
- **CS-008** — A foundation-vs-vendor conflict has a documented resolution.

## 7. Out of Scope

- **Auto-installing** any skill (observe-never-install stays; the user opts in manually).
- **Auto-merging** watch findings without review (unless Clarification 1 decides a safe subset).
- **Executing the graduation reduction waves** themselves (that is the positioning-review's roadmap, separate work).
- **Vendoring/copying** third-party content (always point — EF-010).
- A **complete index** of every skill in the wild (only audited, recommended ones).
- **Telemetry the channel doesn't expose** — best-effort signals only.
- Mythos 5 / model-specific concerns (unrelated).

## 8. Clarification Points — RESOLVED

1. **Watch output contract:** ✅ **Mix** — auto-draft a change for low-risk actions (re-pinning to an already-verified new version), **propose-only** (digest to approve) for new candidates and removals. Drives EF-007.
2. **Trust thresholds:** ✅ **Global first, refine later** — one set of popularity/recency bars to start (simple to calibrate); specialise per-domain only where a domain justifies it. The two-track split (EF-003) still stands: authority track needs no popularity bar, only the community track applies the global bar.
3. **Discovery cadence & breadth:** ✅ **Periodic + targeted** — a monthly/quarterly sweep over the covered domains + known sources (skills.sh, vendor orgs). The rot re-verification (US-3) stays recurrent independently; discovery is the costlier, scheduled-but-infrequent part.
