# Implementation Plan: Trim the foundation to what intermittent maintenance can keep true

**Branch**: `spec/guardrail-cleanup`
**Date**: 2026-08-29
**Spec**: [`spec.md`](./spec.md)
**Status**: Validated — D2 resolved 2026-08-29; D1 deliberately deferred to T604

---

## Summary

The spec asks for a decision, not a feature: grade every guardrail and every carried item by the
evidence behind it, record the harm each one *causes* beside the harm it *prevents*, then remove
what does not earn its place — and stop the counter bookkeeping that serialises unrelated work.

The deliverable is therefore a **record** plus a set of **removals**, not a module. This plan treats
the record as the primary artifact: it is what US7 preserves, what EF-008 requires to be readable in
one view, and what EF-011 requires to be complete before any new guardrail is considered.

**Two measurements taken while planning change the spec's own starting numbers.** They are stated
here rather than folded in silently, because the spec forbids inheriting an unverified figure.

---

## What planning measured (and what it changes)

### The "18 guardrails" figure is correct — for one directory only

The spec scopes the first half to *"18 items, ten blocking and eight advisory"*. Verified on the
repository:

| Source | Count | Note |
|---|---|---|
| `scripts/hooks/*.sh` that can refuse (`exit 2`) | **10** | matches the spec |
| `scripts/hooks/*.sh` advisory, excluding `_`-prefixed shared libraries | **8** | matches the spec |
| `_`-prefixed shared libraries in the same directory | 9 | building blocks, not guardrails |

So 10 + 8 = 18 is **confirmed**, not merely restated.

But that count enumerates **one directory**. Three further sources ship things that refuse an
action, and none of them is in the 18:

| Source | What refuses | In the 18? |
|---|---|---|
| `.husky/pre-commit` | `scripts/private-names-check.sh` (blocks, merged 2026-08-29), `npx lint-staged`, `scripts/sync-counts.sh` (mutates the commit) | **no** |
| `.husky/pre-push` → `scripts/preflight.sh` | shellcheck, counts, conflict markers, manifest, structure gates | **no** |
| `.husky/commit-msg` | commitlint | **no** |
| `.github/workflows/` | ShellCheck, conflict markers, counts gate, bats (Linux + macOS shards), gitleaks behaviour, CodeQL, Security Scan, Validate PR | **no** |

`.claude/settings.json` additionally declares **49 hook invocations** across 17 events — more
declarations than there are scripts, so the mapping is many-to-one and must be resolved by
enumeration rather than assumed.

**Consequence for the plan**: EF-001 requires the record to *establish* completeness, not assert it.
An inventory built from `scripts/hooks/` alone would satisfy the spec's stated number while failing
its stated requirement — and would reproduce, at the level of the audit itself, the exact edge case
the spec names: *"a guardrail exists but is not listed anywhere"*. Phase 1 therefore enumerates from
all four sources. Whether CI gates are *graded* is decision **D2** below.

### US4's evidence is confirmed, but its harm is not commit noise

Measured over 95 commits since 2026-06-29:

| File | Commits touching it | Share |
|---|---|---|
| `counts.json` | 60 | 63 % |
| `README.md` | 66 | 69 % |

The spec's "majority of commits over two months" holds. But **zero commits touch *only* those two
files** — the bookkeeping never produces standalone commits; it rides along with real work.

So the cost is not clutter, it is **serialisation**: a prepared change is invalidated when an
unrelated one lands first. This session is direct evidence — merging #503, #501, #509 and #502
required, for each successor, a rebase, a counts resynchronisation and a full 2 000-test suite re-run
before it could be merged. Four merges cost three forced rebases. The remedy must target
invalidation (EF-009), not commit hygiene.

### The carried load, measured against this very session

US5 can be measured with an instrument the project already has and has never pointed at itself: a
session's loaded context is observable from inside the session. Verified list and sizes:

| Item | Bytes | Share |
|---|---:|---:|
| `docs/reference/best-practices.md` | 8 240 | 23 % |
| `.claude/rules/workflow.md` | 5 646 | 16 % |
| `.claude/rules/README.md` | 5 441 | 15 % |
| `CLAUDE.md` | 5 360 | 15 % |
| `.claude/rules/self-improvement.md` | 3 758 | 11 % |
| `.claude/rules/vendor-precedence.md` | 3 393 | 10 % |
| `docs/reference/project-structures.md` | 1 927 | 5 % |
| `.claude/rules/git.md` | 1 397 | 4 % |
| **Total carried unconditionally** | **35 162** | ~8 k tokens |

One finding is already actionable: **`.claude/rules/README.md` is a catalogue *describing* the 32
rules** — a table of names, paths and priorities. It is carried into every session because it lacks
a `paths:` frontmatter and is therefore treated as a global rule. It is documentation *about* the
rules, not a rule, and it is 15 % of the load. It is the clearest US5 candidate in the set, and the
cheapest to test.

For scale: `scripts/hooks/*.sh` is 118 935 bytes of code, but **none of it is carried** — it runs,
it is never read into context. The spec's framing of the carried material as "roughly four fifths of
the shipped cost" is therefore about *context* cost, where the guardrails contribute approximately
nothing. Phase 5 must state which cost it is measuring, every time it reports a number.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Deliverable** | Markdown record + removals + one bookkeeping change | Not a module; no runtime component |
| **Language** | Bash (POSIX-ish, macOS bash 3.2 safe) | Only for the enumeration tool |
| **Tests** | bats-core | Existing suite: 2 138 tests |
| **Record location** | `specs/guardrail-cleanup/inventory.md` | Single view, per EF-008 |
| **Enumeration tool** | `scripts/guardrail-inventory.sh` | Reporting only — refuses nothing |
| **Baseline** | `main` @ `2a74c23f`, suite green | Rebased 2026-08-29 |

### Constraints

- **The record must not decide by counting** (EF-014). No score column, no totals that invite
  arithmetic. Counts may appear as context, never as a verdict.
- **Native coverage must be demonstrated on this repository** (EF-015), not read from documentation.
  A demonstration that cannot be staged is "unproven" — and unproven is not grounds for removal
  (EF-016).
- **Portability is recorded, never investigated** (EF-007). If an entry's portability is unknown, the
  record says "not measured" and no work is opened.
- **No new guardrail may be decided before the record is complete** (EF-011). This binds the plan
  itself — see D1.
- macOS bash 3.2 portability for any new shell (`.claude/rules/base-maintenance.md`).

---

## Constitution / Conventions Check

- [x] Follows project conventions (CLAUDE.md, `base-maintenance.md`)
- [x] Consistent with existing architecture — the record lives beside the spec, as other passes do
- [x] No over-engineering — the enumeration tool is a reporter, not a gate; the drift guard that
      would naturally accompany it is **deliberately deferred** (D1)
- [x] Tests planned — for the enumeration tool only; the record itself is prose and is validated by
      review, not by assertions

---

## Decisions

### D1 — Does the enumeration ship a drift guard? → **DEFERRED to T604** (option A)

An inventory is only true on the day it is written. The natural durability mechanism is a bats test
asserting that every guardrail on disk appears in the record — the same "self-application test"
pattern the foundation already mandates.

**But that test would itself be a new guardrail**, and EF-011 forbids deciding to add one before the
record is complete. Adding it during the pass would be the pass contradicting its own rule on its
first move.

| Option | Consequence |
|---|---|
| **A — defer (recommended)** | Phase 1 ships the reporter only. The drift-guard decision is taken *after* the record exists, judged by the same criteria as every other guardrail. Costs one round trip; keeps the pass honest. |
| B — ship it now | The record stays true automatically, but the pass adds a guardrail while its whole thesis is that guardrails are added too readily on the day they seem sensible. |
| C — never | The record rots at the first change, and US7's "readable in six months" quietly fails. |

### D2 — Are CI gates in scope for grading? → **RESOLVED 2026-08-29: option A, enumerate all and grade all**

They refuse an action (a merge), so by the spec's own criterion they qualify. They were not in the
18 because the 18 counted one directory.

| Option | Consequence |
|---|---|
| **A — enumerate all, grade all** ✅ **CHOSEN** | Honest completeness. Adds ~10 entries; several will grade quickly ("prevented, recorded" — the gitleaks and counts gates have documented catches). |
| B — enumerate all, grade the hooks only | The record states plainly that CI gates are listed but ungraded, and why. Cheaper, still complete, and EF-004-compatible if the omission is explicit. |
| C — hooks only | Fails EF-001. Not recommended. |

**Consequence**: the record covers ~34 entries — 18 Claude Code hooks, ~6 git-hook gates, ~10 CI
gates. Phase 2 is sized accordingly, and EF-001 is satisfied without reservation.

### D3 — Is the `.husky`/`preflight` chain retired as CI duplication? → **RESOLVED 2026-09-01: no, keep**

Raised by Phase 3, which measured five of five `preflight --fast` gates as duplicated in CI — the
only entry in the whole pass that came back *covered*, and so the only one whose removal would lose
no coverage.

| Option | Consequence |
|---|---|
| **A — keep** ✅ **CHOSEN** | It survives abandonment: skips are announced unconditionally, the success line is withheld when a gate did not run (#515), a real failure exits 1. Neither of the spec's two rot modes applies. |
| B — retire it | Saves maintaining a script that is already written, already tested, and whose caused-harm column is empty *after being genuinely exercised*. Costs the local loop before a push. |

Full argument, including the bias it had to survive — after seven phases, a "cleanup" that removes
nothing invites taking the one candidate on offer, which is the reasoning EF-014 exists to block —
in [`decision-d3.md`](./decision-d3.md).

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `specs/guardrail-cleanup/inventory.md` | **The record.** One row per item: grade, evidence, harm prevented (irreversible/recoverable), harm caused (dated episodes or "none recorded"), portability verdict, keep/remove decision, rationale |
| `specs/guardrail-cleanup/carried-material.md` | US5 record: per-item size, behaviour verdict (changes / does not / unmeasured), and whether it needs *carrying* as distinct from being *useful* |
| `specs/guardrail-cleanup/native-coverage.md` | EF-015 demonstrations: what was disabled, what was triggered, what the platform actually did, what was observed |
| `specs/guardrail-cleanup/tasks.md` | Task breakdown (generated with this plan) |
| `scripts/guardrail-inventory.sh` | Enumerate the guardrail surface from all four sources; print a stable, sorted list. **Reports only — refuses nothing** |
| `tests/guardrail-inventory.bats` | Tests for the enumerator, including a non-vacuity control (it must fail when a known guardrail is hidden from it) |

### To modify

| File | Modification |
|------|--------------|
| `counts.json`, `README.md` | US4 — outcome depends on the option chosen in T401 |
| `scripts/sync-counts.sh`, `scripts/validate-counts.sh` | US4 — same |
| `.github/workflows/ci.yml` | US4 — the counts gate, if the mechanism changes |
| `.claude/rules/README.md` | US5 — add `paths:` frontmatter, or relocate, if it grades "does not change behaviour" |
| `docs/GUARDRAILS.md` | US3 — must follow every removal; a doc teaching a retired guardrail is the rot the spec describes |
| `.claude/settings.json` | US3 — hook declarations for anything removed |
| Removed guardrails' own tests | US3 — deleted with their subject, never left orphaned |

### Tests to add

| File | Coverage |
|------|----------|
| `tests/guardrail-inventory.bats` | Enumeration from each of the four sources; a hidden guardrail is detected; output is stable and sorted |
| *(existing suites)* | Every removal must leave the 2 138-test suite green; any test that only existed to cover a removed guardrail is removed with it and **named in the record** |

---

## Chosen Approach

### The record is the architecture

```
   ENUMERATE                 GRADE                    DECIDE                 ACT
   (Phase 1)                 (Phase 2-3)              (Phase 4)              (Phase 4-6)

   4 sources                 per item:                EF-012/013:            remove + sweep
   ├─ scripts/hooks/    ──▶  ├─ grade A/B/C/D   ──▶   irreversible=keep ──▶  ├─ code
   ├─ .husky/*               ├─ harm prevented        recoverable=remove     ├─ tests
   ├─ preflight chain        ├─ harm caused (dated)   departures argued      ├─ docs
   └─ .github/workflows/     ├─ irreversible?         (never by counting)    └─ settings.json
                             └─ portability (recorded,
        │                       never investigated)                                │
        │                                                                          │
        └──────────────▶ inventory.md — one view, both harms visible ◀─────────────┘
```

### Grading scale (EF-002)

The scale must distinguish a guardrail that *has* prevented something from one that prevents
something *by construction*. Four grades, and the difference between C and D is the spec's own edge
case ("a guardrail nobody can trigger… may be evidence it never runs at all"):

| Grade | Meaning | Evidence required |
|---|---|---|
| **A** | Prevented a failure that really happened | A dated occasion, named in the record |
| **B** | Has fired, outcome unknown | It blocked something; whether that thing was harmful is not recorded |
| **C** | Preventive, nothing recorded | Never shown to have prevented anything — stated explicitly, never left blank |
| **D** | Never observed to fire in either direction | Must be probed: is it dormant, or does it not run at all? |

A grade may claim no more than the evidence beside it (EF-002). Grade D entries are **not**
removal candidates on that basis alone — they are *instrumentation* candidates first.

### Rationale

The record is built before anything is removed because the spec's failure mode is deciding from
memory. Enumeration is separated from grading because they fail differently: enumeration fails by
omission (silent, and fatal to EF-001), grading fails by overclaim (visible, and correctable in
review).

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| Grade in place, in each script's header comment | Fails EF-008 — the two harms are never visible in one view, and the spec's whole point is that the balance is currently one-sided |
| Start with removals, document afterwards | Fails EF-005 and EF-011; and "cleanup" without a record is exactly the taste-driven pass the spec exists to prevent |
| Skip enumeration, take the spec's 18 | Fails EF-001; measurement above shows the 18 covers one of four sources |
| Automate grading (script reads git log for each guardrail's catches) | Attractive but false precision: "prevented harm leaves no trace" (EF-014), so a log-derived count would measure only the caused harm and bias every verdict the wrong way |

---

## Implementation Phases

### Phase 1: Enumerate (blocking) — US1

**Objective**: a reproducible list of everything that refuses an action, from all four sources.

**Checkpoint**: the enumeration is reproducible by command, and its non-vacuity is proven — hiding a
known guardrail makes it fail.

### Phase 2: Grade what refuses (US1, US2) — after D2

**Objective**: every enumerated item carries a grade, its evidence, both harms, and the
irreversible/recoverable classification.

**Checkpoint**: no entry is blank; "none recorded" appears wherever nothing is recorded.

### Phase 3: Demonstrate native coverage (US1) — EF-015

**Objective**: for each guardrail suspected of being covered by the platform, stage the real case and
record what actually happened.

**Checkpoint**: every claim of native coverage is backed by an observation; anything unstageable is
recorded "unproven" and **kept**.

### Phase 4: Decide and retire (US3)

**Objective**: an explicit keep-or-remove per entry; removals executed with their tests, docs and
declarations swept.

**Checkpoint**: suite green; `docs/GUARDRAILS.md` and `.claude/settings.json` carry no reference to
anything removed; every removal names the failure mode now uncovered.

### Phase 5: Stop the bookkeeping serialising work (US4)

**Objective**: accepting one prepared change stops invalidating another (EF-009), and a change that
adds nothing counted carries no counting update (EF-010).

Three mechanisms, to be chosen in T401 with the measurement in hand:

| Option | How | Cost |
|---|---|---|
| **A** — stop tracking derived counts | Remove the numbers from tracked files; render them at docs-build time and in the CI badge | Highest reach; README loses inline numbers on GitHub |
| **B** — merge driver | A git merge driver regenerates `counts.json` / `README.md` counts instead of conflicting | Keeps every number where it is; adds a mechanism that must itself be maintained — the thing this pass is against |
| **C** — CI recomputes, tree stores nothing authoritative | The gate recomputes and compares against the working tree, never against committed output | Middle ground; needs care so the gate does not become a no-op |

**Checkpoint**: two independently prepared changes, one merged, and the other still mergeable without
touching its counts — demonstrated, not argued.

### Phase 6: Grade what every session carries (US5)

**Objective**: each of the 8 carried items gets a verdict — changes behaviour, does not, or
unmeasured — with the strength of the evidence stated beside it.

Starts with `.claude/rules/README.md` (15 % of the load, a catalogue rather than a rule), because it
is the cheapest item to test and the most likely to be inert.

**Checkpoint**: no item is graded "changes behaviour" on a small sample without that sample being
named as signal, not proof (EF-...4 of US5).

### Phase 7: Durability (US6, US7)

**Objective**: portability verdicts transcribed from evidence already in hand (never investigated),
and the decision record left readable by someone who was not present.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **The pass removes a guardrail whose prevented harm left no trace** | High — the spec names this as structurally invisible | Medium | EF-014 is binding: never decide by counting. EF-012 arbitrates by irreversibility, not by evidence volume |
| **Enumeration misses a source** | High — silently voids EF-001 | Medium | Four sources enumerated by tool, plus a non-vacuity control; the record states the method, so a reader can challenge it |
| **The pass adds guardrails while removing them** | Medium — self-contradiction | Medium | D1 defers the drift guard until the record exists; the enumerator refuses nothing |
| **US5's behaviour verdicts rest on tiny samples** | Medium — a wrong "does not change behaviour" removes something load-bearing | High | Verdicts recorded as signal with sample size stated; "unmeasured" is a permitted and honest outcome |
| **US4's fix breaks the anti-drift property** | Medium — counters were introduced to stop doc rot, which was real | Medium | Whichever option wins must keep a check that *recomputes*; T401 requires a mutation proof that the new gate still fails on real drift |
| **Scope creep from 18 to ~34 entries** | Medium — pass never finishes | Medium | D2 allows enumerate-all / grade-hooks-only, with the omission stated explicitly rather than hidden |
| **Removals break installed projects** (~20 installations) | High | Low | `init`/`update` copy only `scripts/hooks/*.sh`; anything removed there must be checked against the update path, as the private-names guard was |

---

## Dependencies and Execution Order

```
Phase 1 (Enumerate) ──┬──▶ Phase 2 (Grade)  ──▶ Phase 3 (Native coverage) ──▶ Phase 4 (Retire)
                      │
                      └──▶ Phase 6 (Carried material)  [independent of the guardrail half]

Phase 5 (Bookkeeping) ─── independent of all of the above; can start immediately

Phases 4, 5, 6 ──────────▶ Phase 7 (Durability)
```

Phase 5 is deliberately **not** gated on the record: it fixes a friction that is felt now, was
demonstrated four times today, and does not depend on any grading outcome.

---

## Complexity

**Complex.** Not for its code — there is almost none — but because the spec's requirements are
adversarial by design: they forbid the shortcuts that would make the work quick (inheriting a count,
reading documentation as evidence, deciding by arithmetic). The expensive phases are 2, 3 and 6;
Phases 1 and 5 are tractable and deliver value on their own.

---

## Validation Criteria

### Gate 1 — before starting
- [x] Spec approved and rebased onto current `main`
- [x] D2 answered (option A — enumerate all, grade all); D1 deferred to T604 by design
- [x] Plan reviewed — **agreed starting point: Phase 5 (bookkeeping)**, which is independent of the
      record and delivers on its own

### Gate 2 — before each merge
- [ ] Suite green (2 138 baseline)
- [ ] `shellcheck` clean on any new script
- [ ] Counts consistent (until Phase 5 changes the mechanism)

### Gate 3 — pass complete
- [ ] Every enumerated item carries a grade, both harms, and a decision (EF-001…EF-006)
- [ ] Every removal names the failure mode now uncovered (EF-006)
- [ ] No decision rests on comparing counts (EF-014)
- [ ] Every native-coverage claim is backed by an observation on this repository (EF-015)
- [ ] Two prepared changes demonstrated non-invalidating (EF-009)
- [ ] A reader who was not present can say why each removed guardrail went (US7)

---

## Notes

- The spec's reframing note (port dropped, justification corrected rather than discarded) is the
  reason this plan does not carry a portability workstream. US6 transcribes what was already
  measured; it opens nothing.
- `mistral-base` was closed on 2026-08-29, on the same grounds as the Codex thread. Neither is a
  dependency of this pass.
- This session is itself evidence for US2 and US4 and should be cited in the record: four merges,
  three forced rebases, and a guardrail (`private-names-check.sh`) found to fail open under a git
  error — a guardrail whose own failure mode was silent success.

---

**Version**: 1.0 | **Created**: 2026-08-29 | **Last modified**: 2026-08-29
