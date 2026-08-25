# Specification: Guardrail cleanup before the second-assistant chantier

**Branch**: `spec/guardrail-cleanup`
**Date**: 2026-08-25
**Status**: Draft
**Input**: User description: *"avant de commencer le chantier avec Codex, va falloir faire le ménage de ce qui n'était pas utile, par rapport à tes recommandations"*

---

## Summary

Before this foundation is carried to a second coding assistant, decide **from evidence rather than
from memory** which of its guardrails still earn their place. Every guardrail kept becomes a cost
paid twice — once on each assistant — plus a surface where the two can drift apart. The project
already owns the instrument that can answer this; it has never been pointed at its own guardrails.

**Scope, 2026-08-25.** Two halves, graded by two different criteria because they earn their place in
two different ways:

- **What refuses an action** — 18 items, ten blocking and eight advisory. Five are graded today;
  **thirteen have never been graded at all**. They earn their place by the harm they prevent.
- **What every session carries** — the reference material placed in front of the assistant
  unprompted, and **roughly four fifths of the shipped cost**. It prevents nothing, so it earns its
  place only by changing what the assistant does. *Reopened after the first scoping excluded it: the
  measurement showed the exclusion removed the answer along with the work.*

The rules and the curation engine stay out — see *Out of Scope*, which states what that still leaves
unmeasured rather than implying it is nothing.

---

## User Stories (prioritized)

### US1 — Grade every guardrail by the strength of its evidence (Priority: P1) 🎯 MVP

**As a** foundation maintainer
**I want** every guardrail the foundation ships to be graded by how strong the evidence behind it is
**So that** what I keep is decided by measurement instead of by whoever remembers why it was added

**Why P1**: this is the whole point. Without a graded inventory, "cleanup" is taste, and taste is
what produced the current situation — a set of guardrails that grew because each one seemed sensible
on the day it was written.

**Independent test**: a reader who was not present opens one record and, for any guardrail named,
finds its grade and the specific evidence that earned it.

**Acceptance criteria**:

1. **Given** the list of guardrails the foundation ships, **When** the grading pass completes, **Then**
   every one of them appears in the record — none is silently absent.
2. **Given** a guardrail that has demonstrably prevented a failure that really happened, **When** it is
   graded, **Then** the record names that occasion.
3. **Given** a guardrail with no failure it has been shown to prevent, **When** it is graded, **Then**
   the record says so explicitly — "preventive, nothing recorded" — rather than leaving the evidence
   unstated.
4. **Given** the completed record, **When** any grade is read, **Then** it claims no more than the
   evidence beside it supports.

---

### US2 — Record the harm a guardrail causes, not only the harm it prevents (Priority: P1)

**As a** foundation maintainer
**I want** each guardrail's own failures listed beside the failures it removes
**So that** the balance is honest instead of counting only one side

**Why P1**: today the record counts what each guardrail removes and never what it introduces. Under
that arithmetic every guardrail is a net gain by construction, so every future review reaches the
same conclusion. This story changes the *outcome* of US1 — it is not a refinement of it. Three
episodes in a single working day showed guardrails blocking legitimate work; none of those failures
existed before the guardrail did.

**Independent test**: pick any guardrail that has blocked legitimate work; the record shows that
episode against it, with a date and what was blocked.

**Acceptance criteria**:

1. **Given** a guardrail that has blocked legitimate work at least once, **When** the record is read,
   **Then** that episode appears against it, dated, saying what was blocked and how it was resolved.
2. **Given** a guardrail with no such episode, **When** the record is read, **Then** it states "none
   recorded" — an empty space must never stand for "none happened".
3. **Given** the completed record, **When** a guardrail is considered for keeping, **Then** both
   columns are visible in the same view.

---

### US3 — Retire what does not earn its place (Priority: P1)

**As a** foundation maintainer
**I want** the guardrails that fail the review actually removed
**So that** the surface I carry to a second assistant is one I can defend, line by line

**Why P1**: grading without acting changes nothing, and the cost this work exists to avoid is paid at
the moment of the port, not before it.

**Independent test**: after the pass, every guardrail still shipped can be justified in one sentence
from the record; every one removed has its removal reasoned in the same record.

**Acceptance criteria**:

1. **Given** a guardrail whose recorded cost exceeds what it is shown to prevent, **When** the decision
   is taken, **Then** it is either removed, or the reason for keeping it is written down — never kept
   by default.
2. **Given** a guardrail is removed, **When** the record is read, **Then** it states the failure mode
   that is now uncovered, and whether anything else still covers it.
3. **Given** the pass is complete, **When** the shipped set is counted, **Then** the count and the
   reason for it are stated, so a later reader can tell a decision from an accumulation.

---

### US4 — Stop the repeated bookkeeping from generating work (Priority: P1)

**As a** foundation maintainer
**I want** the repeated counting of what the foundation contains to stop producing commits and
blocking prepared changes
**So that** two people (or two changes) can work in parallel without invalidating each other

**Why P1** — *raised from P2 on 2026-08-25, on evidence*: this is the friction that is actually felt
day to day, and removing guardrails does not touch it. Two files are touched by a **majority of
commits over two months**; **three prepared changes are blocked on nothing but stale counts** right
now. It was ranked P2 on the argument that it does not change *what is shipped* — but the measured
cost of shipping turned out to be the larger of the two, and it **doubles mechanically** once a
second assistant needs its own copy of the same records. A pass that shrinks the shipped set while
leaving this in place would produce a smaller foundation that feels exactly as heavy.

**Independent test**: prepare two independent changes; accept one; the other is still acceptable
without touching its counts.

**Acceptance criteria**:

1. **Given** two changes prepared in parallel that each add something counted, **When** one is
   accepted, **Then** the other does not become invalid through counting alone.
2. **Given** a change that adds nothing counted, **When** it is prepared, **Then** it carries no
   counting update at all.

---

### US5 — Justify what every session carries, or stop carrying it (Priority: P1)

**As a** foundation maintainer
**I want** the material the foundation places in front of the assistant in *every* session to be
justified by evidence that it changes what the assistant does
**So that** I stop paying the largest measured cost for material that may never be consulted

**Why P1** — *scope reopened on 2026-08-25*: this was excluded when the pass was scoped to the
guardrails, on the argument that a finished narrow pass beats an unfinished wide one. The measurement
overturned it. The carried reference material is **the single largest cost of the shipped surface —
roughly four fifths of what a session carries before any work begins** — while the guardrails, which
the pass was built around, are a small fraction of it. Excluding it meant excluding the answer.

**This story is graded differently from US1, and that difference is the point.** A guardrail earns
its place by the harm it prevents. Carried material has no harm to prevent: it earns its place only
if it **changes behaviour**. The two cannot share a criterion, and applying the guardrail criterion
to carried material would pass everything.

**Independent test**: for any carried item, the record says whether its presence changed what the
assistant did — and if that was never measured, it says that instead of implying it was.

**Acceptance criteria**:

1. **Given** the material carried into every session, **When** the record is read, **Then** each item
   appears with its size and a verdict: **changes behaviour**, **does not**, or **unmeasured**.
2. **Given** an item graded "unmeasured", **When** a keep-or-drop decision is taken on it, **Then**
   the decision states that it rests on judgement, not on evidence.
3. **Given** an item that is reference material — consulted on demand rather than needed unprompted —
   **When** it is assessed, **Then** the record says whether it needs to be *carried* at all, as
   distinct from whether it is *useful*.
4. **Given** a measured verdict, **When** it is recorded, **Then** the strength of the evidence is
   stated with it; small-sample verdicts are recorded as signal, never as proof.

---

### US6 — Know what survives the move before making it (Priority: P2)

**As a** foundation maintainer
**I want** to know, for each thing the foundation ships, whether it survives being carried to the
second assistant
**So that** I stop investing in what does not travel

**Why P2**: measured on the real import path, the guardrails and the rules do not cross the boundary
at all, and the reference material arrives pointing at somewhere that does not exist. Knowing this
per item, before the port, is what makes the keep/drop decisions in US1–US3 answerable at all.

**Independent test**: pick any shipped item; the record says whether it travels intact, is lost
silently, or arrives broken.

**Acceptance criteria**:

1. **Given** the shipped inventory, **When** the record is read, **Then** each item carries one of
   three verdicts: travels, lost, or arrives broken.
2. **Given** an item recorded as lost or broken, **When** it is also recorded as worth keeping,
   **Then** the record says what would have to be built for it to travel.

---

### US7 — Leave a decision record a stranger can read (Priority: P3)

**As a** maintainer returning in six months
**I want** the reasoning kept, not only the outcome
**So that** a removed guardrail is not re-added by someone who only sees the gap

**Why P3**: pure durability. The work is correct without it; it only stops the next person repeating
it.

**Independent test**: a reader who was not present can say, for any removed guardrail, why it went.

**Acceptance criteria**:

1. **Given** a removed guardrail, **When** the record is read later, **Then** the reason and the
   evidence are both still there.

---

## Edge Cases

- **Evidence points both ways.** A guardrail has genuinely prevented a real failure *and* has
  genuinely blocked legitimate work. Which side wins, and does the answer change when the harm it
  prevents is irreversible (a published secret) versus recoverable (a bad commit)?
- **A failure mode that never recurred.** The guardrail may be working, or the failure may simply
  never have been likely. Absence of recurrence cannot distinguish the two — the record must say
  which it is claiming.
- **The platform now does it natively.** Settled: the overlap must be *shown*, not read. The live
  edge case is the one where the demonstration is impossible to stage — the guardrail targets
  something that cannot be safely triggered on a real repository. That entry is "unproven", and
  unproven is not a reason to remove.
- **The inventory is itself incomplete.** A guardrail exists but is not listed anywhere — the pass
  must be able to say it examined *everything*, not everything it knew about.
- **A guardrail nobody can trigger.** It has never fired in either direction. That is not evidence of
  value; it may be evidence it never runs at all.
- **Removal uncovers a second guardrail's assumption.** One guardrail was narrow because another was
  believed to cover the rest.

---

## Functional Requirements

- **EF-001**: Every guardrail the foundation ships MUST appear in the record; the record MUST state
  how completeness was established, not merely assert it.
- **EF-002**: Each entry MUST carry a grade whose claim is bounded by the evidence beside it, and the
  grading scale MUST distinguish "prevented something that really happened" from "prevents something
  by construction".
- **EF-003**: Each entry MUST record the occasions on which the guardrail blocked legitimate work,
  with a date and what was blocked.
- **EF-004**: Where no such occasion is recorded, the entry MUST say "none recorded" explicitly; a
  blank MUST NOT be readable as "none happened".
- **EF-005**: Each entry MUST carry an explicit keep-or-remove decision; no guardrail may remain by
  default or by omission.
- **EF-006**: Each removal MUST state the failure mode left uncovered and whether anything else
  covers it.
- **EF-007**: Each entry MUST state whether the guardrail survives being carried to the second
  assistant: travels, lost, or arrives broken.
- **EF-008**: The record MUST be readable as a single view in which both the prevented harm and the
  caused harm are visible together.
- **EF-009**: Accepting one prepared change MUST NOT invalidate another prepared change through
  bookkeeping alone.
- **EF-010**: A change that adds nothing counted MUST NOT be required to carry a bookkeeping update.
- **EF-011**: The record MUST be complete before any decision that adds a new guardrail is taken.
- **EF-012**: Each entry MUST classify the harm the guardrail prevents as **irreversible** (cannot be
  undone once it happens — a published secret, an erased disk) or **recoverable** (a commit on the
  wrong branch, a failed check). Where both apply, the entry MUST say which case the classification
  refers to.
- **EF-013**: Where a guardrail has both prevented real harm and blocked legitimate work, the
  keep-or-remove decision MUST follow EF-012: irreversible keeps it, recoverable removes it. A
  decision that departs from this MUST state why in the entry.
- **EF-014**: The record MUST NOT decide by comparing the two counts. **Prevented harm leaves no
  trace and caused harm always does**, so the counts are structurally biased against the guardrails
  that matter most: the one protecting against the only irreversible outcome in the set currently has
  zero recorded preventions and two recorded blocks. Counts MAY be reported; they MUST NOT be the
  criterion.

- **EF-015**: A guardrail MUST NOT be removed on the grounds that the platform now covers it unless
  that coverage has been **demonstrated on this repository**: disable the guardrail, trigger the real
  case it targets, observe whether the platform refuses, and record what was observed. Documented
  coverage is not evidence of coverage — on the day this was decided, two of this repository's own
  comments asserted the opposite of what the tool actually did.
- **EF-016**: A demonstration that produces no refusal MUST be treated as "not covered". A
  demonstration that cannot be run MUST be recorded as "unproven", never as "covered".
- **EF-017**: Every item the foundation places in front of the assistant unprompted MUST appear in
  the record with its size and one of three verdicts: **changes behaviour**, **does not**, or
  **unmeasured**.
- **EF-018**: Carried material MUST NOT be graded by the criterion used for guardrails. It prevents
  no harm, so the harm-prevented and irreversibility tests (EF-012, EF-013) MUST NOT be applied to
  it; applying them would pass every item by default.
- **EF-019**: Each carried item MUST be classified as needed **unprompted** or consulted **on
  demand**. An item that is only ever consulted on demand MUST have that recorded, whether or not it
  is kept — being useful and needing to be carried are different claims.
- **EF-020**: A verdict resting on a small sample MUST be recorded as signal, not as proof, and the
  sample size MUST be stated beside it.
- **EF-021**: A decision taken on an item graded "unmeasured" MUST state that it rests on judgement
  rather than evidence.
---

## Key Entities

| Entity | What it represents | Key attributes | Relations |
|--------|--------------------|----------------|-----------|
| **Guardrail** | One thing the foundation ships that refuses an action | name, what it refuses, whether it still runs | has one Verdict, many Episodes |
| **Prevention** | An occasion where the guardrail stopped a real failure | date, what was stopped, how it is known | belongs to a Guardrail |
| **Episode** | An occasion where the guardrail blocked legitimate work | date, what was blocked, how it was resolved | belongs to a Guardrail |
| **Portability verdict** | Whether the guardrail survives the move | travels / lost / arrives broken | belongs to a Guardrail |
| **Decision** | Keep or remove, and why | outcome, reason, what is left uncovered | belongs to a Guardrail |

---

## Success Criteria

- **CS-001**: 100 % of shipped guardrails appear in the record, and the method used to establish that
  completeness is stated.
- **CS-002**: Every kept guardrail carries either a named prevented failure or an explicit
  "preventive, nothing recorded" label — zero entries with an unstated basis.
- **CS-003**: Every entry carries a count of occasions it blocked legitimate work, including zero
  stated as "none recorded".
- **CS-004**: The number of guardrails shipped after the pass is stated together with the reason,
  and differs from the number before it — or, if it does not, the record says why keeping all of them
  was the conclusion.
- **CS-005**: Two changes prepared in parallel, each adding something counted, can both be accepted
  in sequence without either being edited for bookkeeping.
- **CS-006**: Every shipped item carries a portability verdict; zero items are unclassified.
- **CS-007**: No new guardrail is added between the start of this pass and its conclusion.
- **CS-008**: Every item carried into each session appears in the record with its size and a verdict;
  zero items are unlisted, and the share of the carried cost that has been graded is stated as a
  percentage rather than asserted as "all".
- **CS-009**: Every carried item is classified as needed unprompted or consulted on demand — zero
  unclassified.
- **CS-010**: After the pass, the cost carried into a session is stated as a before-and-after figure.
  A pass that leaves it unchanged is a valid outcome only if the record says why every item earned
  its place.
- **CS-011**: Two changes prepared in parallel can both be accepted without either being edited for
  bookkeeping — measured on two real changes, not asserted.

---

## Out of Scope

- **The port itself.** Carrying the foundation to the second assistant is the work this pass
  precedes, not part of it.
- **Adding guardrails.** Explicitly excluded for the duration — including the one currently proposed
  elsewhere. Deciding to add before having measured what exists is the exact pattern this pass
  exists to correct.
- **The two open questions that depend on this outcome** — the personal-store budget and the
  instruction-context work. Both are deferred until this record exists, because both would otherwise
  be decided without it.
- **Rewriting published history.**
- **Changing what the second assistant does.** Its behaviour is a constraint here, not a subject.
- **The rules and the curation engine** — still outside this pass, and the cost of that is stated
  rather than implied: **no rule crosses the boundary to the second assistant either**, so the rules
  face the same portability question as everything else — just not here. They are the natural third
  pass.
- ~~The reference material carried into every session~~ — **brought back into scope 2026-08-25**
  (US5). It was excluded on the argument that a narrow pass that finishes beats a wide one that does
  not; the measurement overturned that, since it is the largest single cost of the shipped surface.
  Excluding it would have left the pass measuring the small half.

---

## Clarification Points

1. ~~**When evidence points both ways, which side is the default?**~~ — **RESOLVED 2026-08-25:
   irreversibility decides.** A guardrail stays when the harm it prevents cannot be undone — a
   published secret, an erased disk — even if it blocks often; it goes when that harm is recoverable
   — a commit on the wrong branch can be moved. Friction is spent only against the permanent. See
   EF-012 and EF-013.
2. ~~**Is "the assistant now covers this natively" sufficient grounds for removal on its own?**~~ —
   **RESOLVED 2026-08-25: no. It must be demonstrated on this repository, by mutation.** Documented
   coverage is not evidence of coverage. See EF-015.
3. ~~**Does this pass cover only the guardrails, or the whole shipped surface?**~~ — **RESOLVED
   2026-08-25, then AMENDED the same day.** First answer: the 18 things that refuse an action,
   nothing else. Amended once the maintenance and the carried cost were actually measured — **the
   reference material carried into every session is back in scope** (US5), graded by its own
   criterion, because it is roughly four fifths of the shipped cost and the first scoping would have
   measured only the small half. The rules and the curation engine remain deferred.

   The amendment is recorded rather than overwritten: the first answer was reasonable on what was
   known when it was given, and a spec that hides its own reversals teaches the wrong lesson to
   whoever reads it next.
