# Tasks: Trim the foundation to what intermittent maintenance can keep true

**Input**: [`spec.md`](./spec.md), [`plan.md`](./plan.md)
**Prerequisites**: plan.md reviewed; **D1 and D2 answered before Phase 2**
**Baseline**: `main` @ `2a74c23f`, suite 2 138 green

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** — parallelisable (different files, no dependency)
- **[US1…US7]** — traceability to the spec's user stories
- Exact paths in every description

---

## Phase 1: Enumerate — US1 (blocking) ✅ **DONE**

> Outcome: the spec's "18 items, ten blocking and eight advisory" is **confirmed** for
> `scripts/hooks/` — and covers one source of four. The blocking tier is ~37, the advisory tier 39,
> the latter because `.claude/settings.json` holds **31 inline declarations** that no inventory had
> ever listed (none can refuse — verified). The enumerator's own first version was wrong in a
> plausible way (9/9 instead of 10/8) and was caught by cross-checking two independent measurements,
> not by review. See [`enumeration.md`](./enumeration.md).

**Goal**: a reproducible list of everything in this repository that refuses an action, drawn from all
four sources, so that completeness can be *established* rather than asserted (EF-001).

**⚠️ No grading task may start before this phase is finished.**

- [x] **T001** [US1] Write `scripts/guardrail-inventory.sh` — enumerate from `scripts/hooks/*.sh`
      (classify `exit 2` = blocking, exclude `_`-prefixed shared libraries), `.husky/*`,
      the `scripts/preflight.sh` gate chain, and `.github/workflows/*.yml` job steps. Emit one stable,
      sorted row per item: `source | name | blocking|advisory | invoked-from`. **Reports only —
      it must refuse nothing and exit 0 always.** macOS bash 3.2 safe.
- [x] **T002** [US1] Cross-check the enumerator against `.claude/settings.json`: 49 hook invocations
      across 17 events map many-to-one onto 27 scripts. Any declared hook with no script, or script
      with no declaration, is a finding — record it, do not silently reconcile.
- [x] **T003** [P] [US1] Write `tests/guardrail-inventory.bats`: per-source enumeration; output is
      stable and sorted; **non-vacuity control** — hiding a known guardrail from the enumerator must
      make it fail (a test that cannot fail proves nothing).
- [x] **T004** [US1] Run the enumerator on the real foundation and reconcile with the spec's figure.
      Expected: 18 from `scripts/hooks/` (10 + 8, confirmed while planning) plus the git-hook and CI
      gates. **Record the delta and its cause in `inventory.md`, as the answer to EF-001's "how
      completeness was established".**

**Checkpoint**: the list is reproducible by one command; hiding a guardrail breaks the test.

---

## Phase 2: Grade what refuses — US1, US2 ✅ **DONE for everything that can refuse**

> Outcome: every tier that refuses an action is graded — ten blocking hooks and the CI tier — apart
> from the `.husky`/`preflight` chain, which is measured but undecided. The advisory and inline
> tiers belong to Phase 6's criterion, not this one.
>
> Three results the plan did not anticipate. **T105 found a real security gap** (bare-root deletion
> uncovered, closed in #513) while asking a much smaller question. **The spec's own worst case is now
> measured**: `preflight` announces success while a gate did not run, indistinguishably from a full
> run. And the scale needed a grade it did not have — *not exercisable here* — for five guardrails
> that are conditional on project shape and inert in this repository but not in the installed ones.
>
> **T106 (portability) is deliberately unchecked**: EF-007 permits recording only what was already
> measured, and for every entry in this record the honest verdict is "not measured". Writing that
> down is the task; opening work to find out is what EF-007 forbids.
>
> No removal candidate was produced. The pass called "cleanup" has so far found one hole and two
> guardrails needing repair.

**Goal**: every enumerated item carries a grade bounded by its evidence, both harms, and an
irreversible/recoverable classification.

**Independent test**: a reader who was not present opens `inventory.md`, picks any guardrail, and
finds its grade and the specific evidence that earned it.

- [x] **T101** [US1] Create `specs/guardrail-cleanup/inventory.md` with the row schema:
      `item | source | grade A/B/C/D | evidence | harm prevented | irreversible? | harm caused
      (dated) | portability | decision | rationale`. **No score column and no totals row** — EF-014
      forbids deciding by arithmetic, and a column of numbers invites exactly that.
- [x] **T102** [P] [US2] Mine the caused-harm column from evidence, not memory: `git log` for
      revert/loosen/fix commits naming a guardrail, the three blocked-work episodes the spec cites,
      and today's `private-names-check.sh` fail-open. Each entry dated, with what was blocked and how
      it was resolved.
- [x] **T103** [P] [US1] Mine the prevented-harm column: catches recorded in commit messages, PR
      bodies and `docs/GUARDRAILS.md`. Where nothing is found, write **"preventive, nothing
      recorded"** — never leave the cell blank (EF-003, EF-004).
- [x] **T104** [US1] Classify each item's prevented harm as **irreversible** (published secret,
      erased history) or **recoverable** (bad commit, failed check). Where both apply, state which
      case the classification refers to (EF-012).
- [x] **T105** [US1] Probe every **grade D** item (never observed to fire): is it dormant, or does it
      not run at all? A guardrail that cannot be triggered may simply be dead — the spec names this
      explicitly. Probing is instrumentation, **not** grounds for removal.
- [ ] **T106** [P] [US6] Transcribe portability verdicts **already measured** — travels / lost /
      arrives broken — from the July import run. Anything unmeasured is written "not measured".
      **This task opens no investigation** (EF-007); if it starts to, stop and drop it.

**Checkpoint**: no blank cells; every grade is bounded by the evidence beside it.

---

## Phase 3: Demonstrate native coverage — US1, EF-015/016

**Goal**: no guardrail is removed because the platform "now does it" unless that was *observed here*.

- [ ] **T201** [US1] List the guardrails suspected of native overlap. Source the suspicion, and note
      that on the day this was decided **two of this repository's own comments asserted the opposite
      of what the tool actually did** — documentation is not evidence.
- [ ] **T202** [US1] For each: disable the guardrail, trigger the real case on this repository,
      observe whether the platform refuses, record what was observed in
      `specs/guardrail-cleanup/native-coverage.md`. One factor varied per arm.
- [ ] **T203** [US1] A demonstration producing no refusal is recorded **"not covered"**. One that
      cannot be safely staged is recorded **"unproven"** — and unproven items are **kept** (EF-016).

**Checkpoint**: every native-coverage claim in the record points at an observation, not a doc.

---

## Phase 4: Decide, repair, retire — US3

> **The pass called "cleanup" has no removal candidate.** Grading every tier that can refuse an
> action produced zero. What it produced instead is a repair list: seven defects, each measured and
> recorded at the time it was found, none fixed then (EF-011). Phase 4 is therefore mostly T306 —
> and that outcome is itself the finding, so it is written here rather than quietly reinterpreted.
>
> Ordered by value, highest first; the order is the evidence, not taste. **All seven are done**, plus
> an eighth found while the pass was running — see (8) below, which had no task ID for days.
>
> **They are not one commit each.** Five commits carry them: #515, #516, #517 (which bundles four),
> #518 and #519. The PR is named on every item, because a repair list a reader cannot map back to
> the history is an archaeology exercise, not a record.
>
> Four of the seven turned out to be guardrails that *reported* something they had not established:
> a success line for a gate that never ran, a clean verdict from a scan with nothing in it, four
> keys checked out of six, and a test asserting the presence of a word rather than the behaviour it
> named. That is one failure mode, not four — and it is the one the spec was written around.

- [x] **T306** [US3] Repair the seven recorded defects, tests before code, and a
      **mutation proof per repair** — a repair whose test cannot fail restores the exact class of
      silence this pass exists to remove.
  - [x] **(1)** [#515] `preflight` announces success while a gate did not run — **the spec's own worst
        case, measured**. Repair is a *reporting contract*, not a regex: the skip stays non-blocking,
        but a gate that could not run is never reported as one that passed. Shipped with four
        mutants, each killed by its own arm; one hollow arm caught and hardened.
  - [x] **(2)** [#516] `substance-check.sh`'s bats branch counts braces on the raw line — a closing brace
        in a comment closes the block early and the test reads as empty. The repair was supposed to
        be the JavaScript branch's one line; **that model was itself defective** (naive stripping
        mispairs on an embedded escaped quote and can delete an *opening* brace, which flagged a
        real test here as hollow), so all three branches are now escape-aware. Seven arms detect
        the old scanner, including the EF-008 scan of the foundation's own tests.
  - [x] **(3)** [#517] `validate-counts.sh` refuses a document that *quotes* a marker: quoting and violating
        are indistinguishable to the scanner. Blocked real work on 2026-08-29. Fenced blocks and
        inline code spans are now documentation; measured side effect on the tree: **none**.
  - [x] **(4)** [#517] No anti-vacuity floor on the marker scan — stripping all markers leaves the gate
        green. An empty gate is a green gate. The floor stores **no number** (that would be one more
        counter to feed): each structural key must have at least one live marker.
  - [x] **(5)** [#517] `_check_core` has no script-level coverage: a mutant disabling it survives the suite.
        Covered through the script now; that exact mutant dies, and by its own arm only.
  - [x] **(6)** [#517] The marker gate validates 4 of 6 live keys — `presets` and `marketplaceAuditPilots`
        fall through `*) continue ;;`, and `byDomain.*` never matches (the pattern excludes the dot).
        Coverage measured: **87 of 147 markers before, 147 after**; an unknown key is reported, not
        skipped.
  - [x] **(7)** [#518] `tests/ci-workflows.bats` does not earn its title: 4 of 5 classes asserted, and its
        `grep VERSION` matches the surrounding prose instead of the regex. This is the test that let
        a documentation gap through on 2026-08-29. Now extracts the regex and asserts path-matching
        behaviour per class, both ways. Measured against five mutations of the real hook: the old
        test killed **one of five**, the new one **five of five**.

  - [x] **(8)** [#519] `tests/audit-docs.bats` planted its fixtures **in the shared checkout** (a file
        under `templates/`, an appended line in `README.md`) while a third case audits that same
        checkout, under `bats --jobs`: the suite mutated the tree it was auditing. Surfaced by a
        macOS job red on a PR whose diff cannot reach that scanner, green on re-running the identical
        commit. Measured: the checkout is dirty in **71 of 268** samples before, **0 of 281** after;
        widening the window makes the failure deterministic, but **32 runs at the real window did not
        reproduce it**, so the causal link to that particular red is *unproven and stays unproven*.
        A control case (a fake root with nothing planted must audit clean) is what makes the positive
        arms mean anything. **This repair had no task ID and appeared in no list** until T602 asked a
        reader to audit it and the reader could not find it.


**What the eight repairs cost, in tests (added 2026-08-31 — T602 found no cost stated anywhere).**

| repair | PR | test lines | `@test` cases added |
|---|---|---:|---:|
| (1) preflight reporting contract | #515 | +96 / −0 | 7 |
| (2) substance-check brace counting | #516 | +82 / −0 | 8 |
| (3)(4)(5)(6) marker gate, four defects | #517 | +158 / −0 | 14 |
| (7) ci-workflows behaviour pinning | #518 | +51 / −14 | 3 |
| (8) audit-docs shared-state race | #519 | +39 / −17 | 1 |
| **total** | 5 commits | **+426 / −31** | **33** |

The two negative columns are rewrites, not deletions of coverage: (7) replaced substring assertions
with behavioural ones, (8) moved the fixtures out of the shared checkout.

**Was the hazard class swept, or only the two cases? (T602 asked; measured 2026-08-31.)** Swept, for
the pattern that caused it: a redirect, `sed -i`, `rm -rf` or `mkdir` whose target is `$BASE_DIR`
appears **0 times** across `tests/*.bats` today. The check is not a blind zero — run against the
pre-repair `tests/audit-docs.bats` (`4452c22d^`) the same pattern finds **1**, which is the faulty
form itself. What remains uncovered: `cp` *from* `$BASE_DIR` into a temporary directory is common and
harmless, so the pattern deliberately ignores it; a future test writing through an indirection this
pattern does not name would not be caught by it. There is no guard for this, by choice — see D1.

**Goal**: an explicit decision per entry; removals executed completely.

- [ ] **T301** [US3] Apply the decision rule (EF-013): where evidence points both ways,
      **irreversible keeps, recoverable removes**. Any departure states its reason in the entry.
      **No decision may cite the count of one column against the other** (EF-014).
- [ ] **T302** [US3] For every keep, write the one-sentence justification. For every removal, state
      **the failure mode now uncovered and whether anything else covers it** (EF-006).
- [ ] **T303** [US3] Execute removals — script, its tests, its `.claude/settings.json` declaration,
      and its `docs/GUARDRAILS.md` row, in one commit per guardrail. A test that existed only to
      cover a removed guardrail is removed with it **and named in the record**.
- [ ] **T304** [US3] Check every removal against the installation path: `init`/`update` copy only
      `scripts/hooks/*.sh`, so a removal there reaches ~20 installed projects while one in `scripts/`
      does not. State the reach of each removal.
- [ ] **T305** [US3] State the resulting count **and the reason for it**, so a later reader can tell
      a decision from an accumulation (EF-005 §3).

**Checkpoint**: suite green; no doc or declaration references anything removed.

---

## Phase 5: Stop the bookkeeping serialising work — US4 ✅ **DONE — shipped in #510**

> Outcome: a fourth option beat the three planned ones. `tests` and `testFiles` were the only
> counters that **verify themselves** (CI runs the suite on every PR), so a stored figure told a
> reader nothing; the structural counters do not verify themselves and stayed untouched. Measured
> field-level churn justified the target: `tests` moved 112 count-lines and `testFiles` 48, while
> commands/skills/rules/presets moved zero. EF-009 demonstrated in two arms on a throwaway clone;
> the anti-drift property proven to survive by mutation on the real repository. Confirmed in
> practice afterwards: adding a test file now moves no counted artifact at all.
> See [`us4-demonstration.md`](./us4-demonstration.md).

**Goal**: accepting one prepared change stops invalidating another (EF-009); a change that adds
nothing counted carries no counting update (EF-010).

**Independent test**: prepare two independent changes, accept one, and the other is still acceptable
without touching its counts.

- [x] **T401** [US4] Choose between plan options A (stop tracking derived counts), B (merge driver)
      and C (CI recomputes). Judge against the measurement: `counts.json` 63 % / `README.md` 69 % of
      95 commits, **zero** bookkeeping-only commits — so the target is *invalidation*, not clutter.
      Option B adds a mechanism that must be maintained, which this pass exists to reduce.
- [x] **T402** [US4] Implement the chosen option across `scripts/sync-counts.sh`,
      `scripts/validate-counts.sh`, `.github/workflows/ci.yml`, `counts.json`, `README.md`.
- [x] **T403** [US4] **Mutation proof that the anti-drift property survives**: introduce real drift
      and prove the new gate still fails. The counters exist because doc rot was real; a fix that
      quietly turns the gate into a no-op is worse than the friction it removes.
- [x] **T404** [US4] Demonstrate EF-009 end to end: two prepared branches, merge one, show the other
      still merges without a counts touch. **Demonstrated, not argued.**

**Checkpoint**: the demonstration in T404 passes, and T403 proves the gate can still fail.

---

## Phase 6: Grade what every session carries — US5

**Goal**: each carried item is graded **changes behaviour / does not / unmeasured**, with the strength
of the evidence stated (EF-…4 of US5).

**Note**: this half is graded by a *different* criterion from the guardrails — carried material has no
harm to prevent, so it earns its place only by changing what the assistant does. Applying the
guardrail criterion here would pass everything.

- [x] **T501** [US5] Create `specs/guardrail-cleanup/carried-material.md` with the 8 measured items
      and their sizes (35 162 bytes total, ~8 k tokens — measured 2026-08-29 against a live session).
      **Re-measured by a second route: identical to the byte.**
- [x] **T502** [US5] Start with **`.claude/rules/README.md`** (5 441 B, 15 % of the load): it is a
      *catalogue describing the 32 rules*, carried into every session only because it lacks a
      `paths:` frontmatter. **Scoped to `.claude/rules/**`; the priority ladder — the only part that
      instructs — moved to `CLAUDE.md`. Carried load 35 162 → 30 046 bytes (−14.5 %).** Nothing that
      *reads* the file is affected: all three consumers read it from disk and already skip README.
- [x] **T503** [P] [US5] For each item, distinguish **useful** from **needs carrying** — reference
      material consulted on demand does not need to be present unprompted (US5 criterion 3). Done for
      all eight, each verdict labelled *structural*, *judgement* or *unmeasured*.
- [x] **T504** [US5] Reuse the existing eval harness (`tests/eval-rule-efficacy.bats` and siblings)
      rather than building a new one. Prior result — rule efficacy is **model-dependent** — must be
      carried into every verdict here. **Its scoring half is offline; its generation half is manual
      and billing-gated, and no such run was authorised — so no behavioural verdict is claimed.**
- [x] **T505** [US5] Record every small-sample verdict **as signal, never as proof**, with the sample
      size beside it. "Unmeasured" is a permitted outcome; an item dropped on judgement must say so.
      Every verdict carries its evidence class; nothing was dropped on judgement alone.
- [x] **T506** [US5] Act on the verdicts: relocate, add `paths:` scoping, or remove. State for each
      what a session loses. **One item acted on**; what a session loses is the 32-row inventory, and
      it keeps the ladder. The rest need the billing-gated eval or a content split of their own.

**Checkpoint**: no item graded on an unstated sample; every drop names what is lost.

---

## Phase 7: Durability — US6, US7

- [x] **T601** [P] [US7] Ensure every removed guardrail's reason **and** evidence remain in
      `inventory.md`, so it is not re-added by someone who only sees the gap. **Vacuously satisfied
      and worth saying so: nothing was removed.** What the record must instead survive is the
      opposite — someone reading a repair as a removal.
- [x] **T602** [P] [US7] Independent read-through: a reader who was not present picks three removed
      items and states why each went. Failure here is a defect in the record, not in the reader.
      **Adapted**: nothing was removed, so the question became *why was each of three repairs made,
      and what did it cost* — asked of `preflight`, "a marker gate", and the `audit-docs` checks,
      named as areas with no figure or finding supplied.
      **Run 2026-08-31 by a reader with no context of this pass. Verdict: NO.**
      Each repair is reconstructible *in isolation* — the reader recovered the defects, the evidence
      and the numbers unaided, which is the part that cost the most to write. What the record does
      not support is understanding the pass **as a whole**. Three findings, worst first:
      1. *"Phase 3 never became necessary — nothing was a candidate"* reported an **unrun phase as a
         conclusion**, and contradicted the `config-protection.sh` entry naming it a strong Phase 3
         candidate. Phase 3 was the only route to a removal, so zero removals was **untested**, not
         established. Fixed in `inventory.md`.
      2. The repair set **could not be enumerated from the record**: "seven defects, one commit each"
         against five commits, one bundling four — and repair (8), the very one this task asked the
         reader to audit, appeared in **no list and had no ID**. Fixed above.
      3. **87 / 147 against 93 / 24 files, never reconciled and neither scope defined**; the reader
         reproduced neither. Re-measured with the gate's exact scope and reconciled in
         `us4-demonstration.md`: **93 was the dot-blind count, produced by the very pattern the
         repair fixed** — the defect measuring itself.
      Still open from that read-through, recorded rather than fixed here: `bash-write-guard.sh` is
      kept with recoverable harm and a dated block but **no argued EF-013 departure**; the
      `.husky`/`preflight` chain (~9 gates) is ungraded while the record claims every refusing tier
      is graded; the `audit-docs` repair never says whether the shared-state hazard **class** was
      swept beyond the two cases fixed; and no engineering cost (tests added, suite delta) is stated
      for any repair.
- [x] **T603** [US1] Re-run `scripts/guardrail-inventory.sh` and confirm the record still matches the
      repository after all removals. **Confirmed after the seven repairs**: 29 CI gates · 18 hooks
      (10 blocking / 8 advisory) · 31 inline declarations · 3 git hooks — the inline figure
      cross-checked by a second, independent count straight from `.claude/settings.json`
      (49 invocations across 27 scripts), because that is the number that was plausibly wrong once
      before.
- [x] **T604** [D1] **Now** decide whether the drift guard ships — with the record complete, EF-011 is
      satisfied and the decision can be judged by the same criteria as every other guardrail.
      **Decision: it does not ship.** The harm is recoverable, an existing tested command already
      re-derives the truth, and the guard would demand a hand-written graded entry before any new
      guardrail could land — the *blocks all work* failure mode, on the most expensive feeding
      requirement in the repository. Reasoning and what it leaves uncovered: [`decision-d1.md`](./decision-d1.md).

---

## Parallelisation

| Can run together | Why |
|---|---|
| T102, T103, T106 | Different columns of the record, different sources |
| T003 | Independent of T001's implementation once the output shape is fixed |
| Phase 5 (all) | Touches the counts mechanism only — no overlap with the record |
| Phase 6 (T503) | Different file, different criterion, different half of the spec |

**Never parallel**: Phase 1 → Phase 2 (grading an incomplete list voids EF-001); T301 → T303
(deciding and removing in one step loses the rationale); T402 → T403 (the proof must run against the
implemented change).

---

## Traceability

| Story | Tasks |
|---|---|
| US1 — grade by evidence | T001–T004, T101, T103–T105, T201–T203, T603 |
| US2 — record harm caused | T102 |
| US3 — retire what fails | T301–T305 |
| US4 — stop the bookkeeping | T401–T404 |
| US5 — justify what is carried | T501–T506 |
| US6 — portability already measured | T106 |
| US7 — record a stranger can read | T601, T602 |
| D1 — drift guard decision | T604 (deliberately last) |

---

## Suggested order

1. **Phase 5** — independent, friction felt today (four merges, three forced rebases), delivers alone.
2. **Phase 1** — cheap, unblocks everything, and its finding (18 covers one of four sources) is
   already half-established.
3. **Phase 2 → 3 → 4** — the expensive core; needs D2.
4. **Phase 6** — the larger measured cost, but a separate criterion and a separate chantier.
5. **Phase 7** — closes the pass, and only then D1.
