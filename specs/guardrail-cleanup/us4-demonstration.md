# US4 — what was measured, and what was demonstrated

**Date**: 2026-08-29
**Tasks**: T401 (choice), T403 (the anti-drift property survives), T404 (EF-009)
**Change**: `fix(counts): stop tracking the two counters that verify themselves`

This file exists because US7 asks for the reasoning, not only the outcome — including
the reasoning that turned out to be wrong on the first attempt.

---

## T401 — why these two counters, and not the others

The spec's evidence for US4 was "two files touched by a majority of commits over two months".
Confirmed over the last 95 commits:

| File | Commits touching it | Share |
|---|---:|---:|
| `counts.json` | 60 | 63 % |
| `README.md` | 66 | 69 % |

But **no commit touched only those two**. The bookkeeping never produced its own commits; it rode
along with real work. So the harm was never clutter — it was **serialisation**: a change prepared in
parallel was invalidated when an unrelated one landed first. In this session alone, four merges cost
three forced rebases, each with a counts resynchronisation and a full suite re-run.

Field-level churn says which numbers are responsible:

| Field | Count-lines changed | Field | Count-lines changed |
|---|---:|---|---:|
| `tests` | 112 | `commands` | 0 |
| `testFiles` | 48 | `skills` | 0 |
| `agents` | 4 | `rules` | 0 |
| | | `presets` | 0 |

**Churn alone would be a weak reason to remove something** — the spec forbids deciding by counting,
and "it moves a lot" is a count. The line actually drawn is **what verifies what**:

- The **test counters verify themselves.** CI runs the whole suite on every PR. A figure stored in a
  file therefore tells a reader nothing they do not already have, and a wrong one is caught by
  nothing, because nothing consults it.
- The **structural counters do not.** A doc claiming 106 commands while 107 exist is caught by
  `validate-counts.sh` and by no other mechanism.

Self-verifying counters go; the rest stay untouched. This also explains why plan options B (a git
merge driver) and C (CI-side recomputation) were dropped: both keep every number and add a mechanism
to be maintained, which is what this pass exists to reduce.

---

## T403 — the anti-drift property survived (mutation, on this repository)

The counters exist because doc rot was real. A fix that quietly turns the gate into a no-op is worse
than the friction it removes, because the belief that the docs are guarded survives with it. So the
property was **demonstrated by mutation on the real repository**, not argued:

| Arm | Action | Result |
|---|---|---|
| Baseline | run the validator on a clean tree | exit **0** |
| **Mutation** | set the `count:commands` marker in `README.md` to 999 | exit **1**, naming the file, the line and both numbers |
| Restore | put the file back | exit **0** |

A bats case pins the same property, so it cannot rot back into a no-op unnoticed.

---

## T404 — EF-009 demonstrated, and the first attempt that proved nothing

Two changes are prepared in parallel from the same base; one is accepted; the other must still be
acceptable without touching its counts. Run on a throwaway clone, in **two arms** — the control arm
runs the identical scenario against the state *before* the change:

| Arm | Base | Result |
|---|---|---|
| **Control** | `origin/main` (before) | B **conflicts** on `counts.json` |
| **Trial** | the change | B **merges cleanly** |

### The first attempt was vacuous, and the control arm is what caught it

In the first version both branches added **2 tests each**, so both wrote the same new value. Git saw
two identical edits and merged them without complaint — the control arm passed, and a one-armed run
would have been reported as success. Real branches add different amounts: this session's three PRs
added 4, 9 and 27 tests. With A adding 2 and B adding 5, the control arm conflicts as it should.

**A demonstration whose control cannot fail measures nothing.** That is the whole reason the control
arm exists, and it earned its place on its first use.

### A second false start, worth recording

An earlier run of this demonstration executed **in the real repository** instead of a clone: the
clone failed (`--local` uses hardlinks, and the destination was on another filesystem) and its error
was hidden by `2>/dev/null`; `cd` then failed while the later, independent commands still ran. Two
branches and a merge landed on the working branch, and a `git add -A` swept uncommitted work into a
demo commit. Everything was recovered from the reflog and `main` was never touched.

The script now carries three guards: no discarded output, `set -e`, and a working-directory
assertion re-checked immediately before **every** mutating operation rather than once at startup.

---

## Two guardrails blocked legitimate work while doing this — evidence for US2

Both are dated entries for the *caused harm* column of the record, and both were met in the course
of normal work rather than sought out:

1. **`validate-counts.sh` refused this very file.** Writing the mutation up with its literal marker
   syntax made the anti-drift scan read the example as a real drift and fail the pre-push gate. The
   scanner cannot distinguish a document *quoting* a marker from one *carrying* one.
   *Resolved by* describing the mutation in prose instead — the literal syntax added nothing to the
   record. The scanner was deliberately **not** widened: changing a guardrail mid-pass is what this
   pass exists to interrupt, and the case belongs in the record instead.

2. **`command-validator.sh` refused `git commit --no-verify`** inside a throwaway clone whose hooks
   had already been removed. The refusal is correct in general — it cannot know the repository is
   disposable — and the flag was simply unnecessary. Recorded because "the guard was right and still
   cost a cycle" is exactly the kind of entry the caused-harm column exists to hold.

Neither is offered as an argument for removal. EF-014 forbids deciding by counting these episodes,
and both guardrails also prevent things. They are recorded so the balance is visible.

---

## Accepted loss (EF-006)

A stale test count written into prose later is **no longer detected** — `scan_tests_drift` covered the
`tests-N passing` badge and the `(N files, M tests)` patterns anywhere in the docs.

- **Harm class**: recoverable — a wrong number in a README.
- **Covered by anything else?** No.
- **Replacement guard**: deliberately **not** added. EF-011 forbids deciding to add a guardrail
  before the record is complete, and this pass adding one mid-flight is exactly the reflex it exists
  to interrupt. Revisit with the rest of the record.

Two tests were removed with their subject and are named here, per T303:

- `scan_tests_drift: detects the 'tests-N passing' badge pattern`
- `scan_tests_drift: detects the '(N files, M tests)' Test layout pattern`

Suite: 2 138 → **2 140** (four added, two removed with their subject).
