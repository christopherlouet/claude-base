# Phase 1 — the enumeration, and how completeness was established

**Date**: 2026-08-29
**Tasks**: T001–T004 (US1)
**Tool**: `scripts/guardrail-inventory.sh` — reports, refuses nothing, exits 0 always
**Tests**: `tests/guardrail-inventory.bats`

EF-001 asks the record to state **how** completeness was established, not to assert that it was.
This file is that statement. It enumerates; it grades nothing — grading is Phase 2, and the two are
separated because they fail differently: enumeration fails by omission, which is silent and fatal,
while grading fails by overclaim, which review can catch.

---

## The method

Four sources are read independently and reconciled **against each other**, because any single list
is exactly what the spec's own edge case warns about — *"a guardrail exists but is not listed
anywhere"*.

| # | Source | What it yields | How an item is classified |
|---|---|---|---|
| 1 | `scripts/hooks/*.sh` | 18 guardrails | can the script `exit 2`? |
| 2 | `.claude/settings.json` | 31 inline declarations, in 16 event groups | same test, applied to the inline command |
| 3 | `.husky/*` | 3 git hooks, plus what each invokes | a git hook refuses by non-zero exit |
| 4 | `.github/workflows/*.yml` | 29 named steps | a CI step refuses a merge (decision D2) |

Underscore-prefixed files in source 1 are **excluded**, and the justification is a measurement rather
than a naming convention: all nine are **never declared** in `settings.json`, so they are libraries
that other hooks source, not hooks themselves.

Reproduce with `scripts/guardrail-inventory.sh`. Output is `source | name | kind | invoked-from`,
`LC_ALL=C`-sorted, so a diff between two runs means the repository really changed.

---

## The result

```
29  ci             .github/workflows/*.yml
18  hooks          scripts/hooks/*.sh          (10 blocking · 8 advisory)
16  settings.json  inline declarations         (31 declarations, grouped by event)
 3  husky          .husky/*
```

### Reconciliation with the spec's figure (T004)

The spec scopes the first half to *"18 items, ten blocking and eight advisory"*.

**That figure is confirmed** — by two independent measurements that were made to agree (see the
discrepancy below). It is also **one source out of four**. The three others ship things that refuse
an action and appear in none of it:

| Not in the 18 | Why it was missed |
|---|---|
| `scripts/private-names-check.sh` | lives in `scripts/`, not `scripts/hooks/` — which is also why `init`/`update` never ship it to installed projects |
| `scripts/preflight.sh`'s 5–6 gates | invoked by `.husky/pre-push`, one level below the hook |
| `npx commitlint`, `npx lint-staged` | invoked by git hooks, not scripts of ours |
| ~16 CI steps that can fail a PR | a different source entirely |

So the **blocking tier is roughly 37, not 10**, and the **advisory tier is 39, not 8** — the latter
because of the 31 inline declarations.

### The 31 inline declarations, and the reassuring half of that finding

`.claude/settings.json` declares 49 hook invocations across 17 events, but only 18 of them name a
script. The other **31 are inline shell commands**, invisible to any script-based inventory, and they
had never been enumerated.

**None of them can refuse.** Verified: not one contains an `exit 2`. So the blocking picture is
unchanged by their discovery, which is the good news. But all 31 *run* — on every session, or every
tool use — and that cost has never been counted. They belong to Phase 6's question (what does a
session carry?) as much as to this one.

### Cross-check for dangling references

- 18 declared hook scripts, **all present on disk** — no declaration points at a missing file.
- 9 scripts present but never declared — all nine underscore-prefixed, i.e. the libraries.
- **0 orphans in either direction.**

---

## What the enumeration itself got wrong first

The tool's first version classified `pre-commit-tests.sh` as **advisory**. A separate manual
measurement called it **blocking**. One of the two had to be wrong.

The tool was. Its pattern required whitespace or end-of-line after the `2`, and the real script
writes `…; exit 2; }` inside a brace group — terminated by a semicolon. The count came out **9/9**
instead of 10/8, and it looked perfectly plausible.

Two things are worth keeping from that:

1. **The bug was found by disagreement, not by review.** Reading the pattern again would not have
   revealed it; running a second, independent measurement did. Where a number matters, measure it
   twice by different means.
2. **A plausible wrong answer is the dangerous kind.** 9/9 raised no eyebrow. Had the two
   measurements not been compared, the pass would have graded a blocking guardrail as advisory and
   the error would have propagated into every later decision about it.

The pattern now treats any non-digit as a terminator (so `exit 20` is still not `exit 2`), and
strips comments first, so a script that merely *documents* how blocking works is not counted as
blocking. All three cases are pinned by tests.

---

## A false positive found by shipping this phase — evidence for US2

`scripts/substance-check.sh`, the foundation's anti-hollow-test detector, **failed this PR's own
test file in CI** while the local suite was green. Dated entry for the *caused harm* column.

**Cause, isolated by bisection then confirmed in two arms.** The finding was *"empty test body"* on a
test with a four-line body. The bats branch of the scanner counts braces to find where a test block
ends, and it counts them on the raw line — without stripping strings, and without skipping comments.
A comment containing a closing brace inside backticks therefore closes the block early; the body
collapses to comment lines only, all of which are skipped, and the test reads as empty.

| Arm | Fixture | Verdict |
|---|---|---|
| trial | comment containing a lone closing brace in backticks | **flagged** "empty test body" |
| control | the same comment without it | clean |

**The repair already exists in the same file.** The JavaScript branch strips single-line string,
template and char literals before counting, and its comment states the exact failure mode: *"a lone
`}` inside a string cannot close the block early"*. The bats branch never received the same
treatment — one line, `scripts/substance-check.sh:84`, against the model at line 175.

**Not fixed here, and the trade-off is stated rather than hidden.** EF-011 forbids repairing a
guardrail before the record is complete, and that discipline has been applied to four other
pre-existing findings today. The comment was rephrased instead — which unblocks the work while
leaving the defect in place for the next person. That is a real cost, accepted knowingly: the
foundation's own lesson is that editing content to appease a scanner keeps the scanner's bug alive.
It is recorded here with its reproduction and its one-line fix so Phase 2 or 4 can act on evidence
rather than rediscover it.

### ✅ Repaired in Phase 4 — and the one-line fix was not the whole fix

The bats branch now strips single-line literals before counting braces, as the JavaScript branch
did. Two things the record did not anticipate came out of doing it:

1. **The model it was copied from was itself defective.** The naive `/"[^"]*"/` mispairs on an
   embedded `\"`, so it can delete an *opening* brace while leaving its closing one — the opposite
   of the JS branch's own comment, which claimed stripping "only REMOVES braces, never a new false
   positive". Copying it verbatim turned a passing Go fixture in this repository into a false
   *no-assertion*. The stripping is now escape-aware in **all three** branches (bats, JS, Go),
   measured in two arms on the same well-formed fixture: naive flags a real test, escape-aware is
   clean.
2. **The first well-formed fixture was not well-formed.** `"x \\" } "` escapes a *backslash*, so
   the string really does end and the brace really is code — the scanner was right and the fixture
   was wrong. Caught by the arms disagreeing with the direct probe, not by reading. A plausible
   wrong answer again, and again only visible from two measurements.

**Two traps in writing the tests, both worth the next person's time.** A fixture written through a
heredoc reaches the scanner *already transformed*: bats rewrites a literal `@test` line even inside
heredoc data, so the fixture contained no test at all and the arms passed green while measuring
nothing. And a closing brace at column 0 inside a heredoc terminates the enclosing `@test` in bats'
own parser, silently truncating an arm to its first line. Both failures looked like passes. Fixtures
are built with `printf`, like every other fixture in that file, for exactly these reasons.

Proven by mutation: restoring the naive scanner fails **seven** arms, including the EF-008 scan of
the foundation's own `tests/` — the same failure that started this entry.

**Why it matters beyond itself**: the local suite passed and CI did not. The detector is invoked
through a bats case that runs it over `tests/`, and it landed in shard 4 — so the failure was real,
reproducible locally on demand, and simply not surfaced by the way the suite was run first.

---

## Two gradings this enumeration already suggests

Recorded here, decided in Phase 2:

- **`preflight.sh` gates skip silently when their tool is absent.** The script says so plainly:
  *"a missing tool SKIPS the gate"*. That is the spec's own worst case — a guardrail that stops
  running while the belief that it protects you remains. It needs a probe, not an opinion: how often
  does a gate actually skip on a real machine?
- **`preflight` duplicates CI.** The same five checks live in `scripts/preflight.sh` and in
  `ci.yml`. Duplication is not automatically waste — local-first feedback is the stated reason — but
  it is two places to feed, which is precisely the criterion this pass applies.

---

## What this phase deliberately did not do

- **No drift guard.** A bats test asserting that every guardrail on disk appears in the record would
  keep this file true, and it is exactly what the foundation's own conventions call for. It is
  **deferred to T604** (plan decision D1): that test would itself be a new guardrail, and EF-011
  forbids deciding to add one before the record is complete. Adding it here would be the pass
  breaking its own rule on its first move.
- **No grading.** Every row above is unjudged. Phase 2 attaches evidence, both harms, and the
  irreversible/recoverable classification.
