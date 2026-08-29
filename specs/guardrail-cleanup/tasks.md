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

## Phase 1: Enumerate — US1 (blocking)

**Goal**: a reproducible list of everything in this repository that refuses an action, drawn from all
four sources, so that completeness can be *established* rather than asserted (EF-001).

**⚠️ No grading task may start before this phase is finished.**

- [ ] **T001** [US1] Write `scripts/guardrail-inventory.sh` — enumerate from `scripts/hooks/*.sh`
      (classify `exit 2` = blocking, exclude `_`-prefixed shared libraries), `.husky/*`,
      the `scripts/preflight.sh` gate chain, and `.github/workflows/*.yml` job steps. Emit one stable,
      sorted row per item: `source | name | blocking|advisory | invoked-from`. **Reports only —
      it must refuse nothing and exit 0 always.** macOS bash 3.2 safe.
- [ ] **T002** [US1] Cross-check the enumerator against `.claude/settings.json`: 49 hook invocations
      across 17 events map many-to-one onto 27 scripts. Any declared hook with no script, or script
      with no declaration, is a finding — record it, do not silently reconcile.
- [ ] **T003** [P] [US1] Write `tests/guardrail-inventory.bats`: per-source enumeration; output is
      stable and sorted; **non-vacuity control** — hiding a known guardrail from the enumerator must
      make it fail (a test that cannot fail proves nothing).
- [ ] **T004** [US1] Run the enumerator on the real foundation and reconcile with the spec's figure.
      Expected: 18 from `scripts/hooks/` (10 + 8, confirmed while planning) plus the git-hook and CI
      gates. **Record the delta and its cause in `inventory.md`, as the answer to EF-001's "how
      completeness was established".**

**Checkpoint**: the list is reproducible by one command; hiding a guardrail breaks the test.

---

## Phase 2: Grade what refuses — US1, US2 *(requires D2)*

**Goal**: every enumerated item carries a grade bounded by its evidence, both harms, and an
irreversible/recoverable classification.

**Independent test**: a reader who was not present opens `inventory.md`, picks any guardrail, and
finds its grade and the specific evidence that earned it.

- [ ] **T101** [US1] Create `specs/guardrail-cleanup/inventory.md` with the row schema:
      `item | source | grade A/B/C/D | evidence | harm prevented | irreversible? | harm caused
      (dated) | portability | decision | rationale`. **No score column and no totals row** — EF-014
      forbids deciding by arithmetic, and a column of numbers invites exactly that.
- [ ] **T102** [P] [US2] Mine the caused-harm column from evidence, not memory: `git log` for
      revert/loosen/fix commits naming a guardrail, the three blocked-work episodes the spec cites,
      and today's `private-names-check.sh` fail-open. Each entry dated, with what was blocked and how
      it was resolved.
- [ ] **T103** [P] [US1] Mine the prevented-harm column: catches recorded in commit messages, PR
      bodies and `docs/GUARDRAILS.md`. Where nothing is found, write **"preventive, nothing
      recorded"** — never leave the cell blank (EF-003, EF-004).
- [ ] **T104** [US1] Classify each item's prevented harm as **irreversible** (published secret,
      erased history) or **recoverable** (bad commit, failed check). Where both apply, state which
      case the classification refers to (EF-012).
- [ ] **T105** [US1] Probe every **grade D** item (never observed to fire): is it dormant, or does it
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

## Phase 4: Decide and retire — US3

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

## Phase 5: Stop the bookkeeping serialising work — US4 *(independent, can start now)*

**Goal**: accepting one prepared change stops invalidating another (EF-009); a change that adds
nothing counted carries no counting update (EF-010).

**Independent test**: prepare two independent changes, accept one, and the other is still acceptable
without touching its counts.

- [ ] **T401** [US4] Choose between plan options A (stop tracking derived counts), B (merge driver)
      and C (CI recomputes). Judge against the measurement: `counts.json` 63 % / `README.md` 69 % of
      95 commits, **zero** bookkeeping-only commits — so the target is *invalidation*, not clutter.
      Option B adds a mechanism that must be maintained, which this pass exists to reduce.
- [ ] **T402** [US4] Implement the chosen option across `scripts/sync-counts.sh`,
      `scripts/validate-counts.sh`, `.github/workflows/ci.yml`, `counts.json`, `README.md`.
- [ ] **T403** [US4] **Mutation proof that the anti-drift property survives**: introduce real drift
      and prove the new gate still fails. The counters exist because doc rot was real; a fix that
      quietly turns the gate into a no-op is worse than the friction it removes.
- [ ] **T404** [US4] Demonstrate EF-009 end to end: two prepared branches, merge one, show the other
      still merges without a counts touch. **Demonstrated, not argued.**

**Checkpoint**: the demonstration in T404 passes, and T403 proves the gate can still fail.

---

## Phase 6: Grade what every session carries — US5

**Goal**: each carried item is graded **changes behaviour / does not / unmeasured**, with the strength
of the evidence stated (EF-…4 of US5).

**Note**: this half is graded by a *different* criterion from the guardrails — carried material has no
harm to prevent, so it earns its place only by changing what the assistant does. Applying the
guardrail criterion here would pass everything.

- [ ] **T501** [US5] Create `specs/guardrail-cleanup/carried-material.md` with the 8 measured items
      and their sizes (35 162 bytes total, ~8 k tokens — measured 2026-08-29 against a live session).
- [ ] **T502** [US5] Start with **`.claude/rules/README.md`** (5 441 B, 15 % of the load): it is a
      *catalogue describing the 32 rules*, carried into every session only because it lacks a
      `paths:` frontmatter. Cheapest to test, most likely inert.
- [ ] **T503** [P] [US5] For each item, distinguish **useful** from **needs carrying** — reference
      material consulted on demand does not need to be present unprompted (US5 criterion 3).
- [ ] **T504** [US5] Reuse the existing eval harness (`tests/eval-rule-efficacy.bats` and siblings)
      rather than building a new one. Prior result — rule efficacy is **model-dependent** — must be
      carried into every verdict here.
- [ ] **T505** [US5] Record every small-sample verdict **as signal, never as proof**, with the sample
      size beside it. "Unmeasured" is a permitted outcome; an item dropped on judgement must say so.
- [ ] **T506** [US5] Act on the verdicts: relocate, add `paths:` scoping, or remove. State for each
      what a session loses.

**Checkpoint**: no item graded on an unstated sample; every drop names what is lost.

---

## Phase 7: Durability — US6, US7

- [ ] **T601** [P] [US7] Ensure every removed guardrail's reason **and** evidence remain in
      `inventory.md`, so it is not re-added by someone who only sees the gap.
- [ ] **T602** [P] [US7] Independent read-through: a reader who was not present picks three removed
      items and states why each went. Failure here is a defect in the record, not in the reader.
- [ ] **T603** [US1] Re-run `scripts/guardrail-inventory.sh` and confirm the record still matches the
      repository after all removals.
- [ ] **T604** [D1] **Now** decide whether the drift guard ships — with the record complete, EF-011 is
      satisfied and the decision can be judged by the same criteria as every other guardrail.

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
