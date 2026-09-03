# D1 — should the record get a drift guard? **No.**

**Task T604, deliberately taken last.** A test asserting that every guardrail on disk appears in
`inventory.md` would keep the record true, and the foundation's own conventions call for exactly that
kind of guard. It was deferred through the whole pass because EF-011 forbids deciding to add a
guardrail before the record is complete — adding it earlier would have been the pass breaking its own
rule on its first move.

The record is now complete. The decision can be taken by the same criteria as every other entry, and
by those criteria the answer is **do not ship it**.

## The criteria, applied

**1. What harm would it prevent, and is it irreversible?** A record that silently goes stale — and
staleness here is exactly the failure mode the pass is built around, so this is not a small thing.
But it is **recoverable**, and cheaply: `scripts/guardrail-inventory.sh` regenerates the truth in one
command, reports only, and never refuses anything. EF-013 says recoverable harm argues for not
adding.

**2. Does it survive abandonment?** No — and this is decisive. The record's row schema is
`item | source | grade | evidence | harm prevented | irreversible? | harm caused | portability |
decision | rationale`. A guard demanding an entry per guardrail demands **all of that**, written by
hand, before any new guardrail can land. Under the intermittent maintenance this foundation actually
gets, that is the first of the two failure modes the spec names as worse than absence: *a guard that
blocks all work*. The pass exists to remove things that must be fed; this would add the most
expensive feeding requirement in the repository.

**3. Can it even be built honestly?** `inventory.md` is a narrative — prose, tables, sections that
argue. Making it machine-checkable means coupling a parser to that prose, which turns every rewording
into a build failure and pushes the record towards a shape a checker likes rather than a shape a
reader understands. US7 asks for a record a stranger can read. Those two goals pull apart.

## What is uncovered by saying no — stated, per EF-006

**The record can go stale, and nothing will announce it.** A guardrail added six months from now will
not appear here, and a reader may take the record as current when it is not.

Two things bound that, neither of them a guard:

- **The enumerator already exists, is tested, and refuses nothing.** Running
  `scripts/guardrail-inventory.sh` re-derives the real list from all five sources in one command. The
  record's job is to hold *dated evidence and reasoning*; the live list is regenerated, not stored.
- **T603 set the precedent for using it.** At the end of this pass the enumerator was re-run and
  reconciled with the record — 29 CI gates, 18 hooks (10 blocking / 8 advisory), 31 inline
  declarations, 3 git hooks, confirmed by a second independent count from `.claude/settings.json`
  (49 invocations across 27 scripts). Doing that again is the freshness check, and it costs one
  command whenever someone cares. **Re-run 2026-09-02** after the fifth source landed: the same
  figures, plus 26 native `permissions.deny` rules (18 blocking / 8 literal-only). This paragraph
  going stale on the day the enumerator grew a source is itself the argument the decision records —
  a fact stated in one place rots in every unguarded copy of it.

So the mitigation is: **the record carries a date, not a promise of currency.** That is a weaker
claim than a guard would give, and it is the honest one.

## The shape of this decision is the pass's own argument

This pass spent four phases repairing guardrails that reported more than they had established, and
found **zero** to remove. It would be a poor ending to close by adding one that must be fed forever,
to protect a document, against a failure that one existing command already detects.

Declining is not a claim that the drift does not matter. It is the same trade the rest of the record
makes: **keep what survives being ignored, refuse what needs feeding.**
