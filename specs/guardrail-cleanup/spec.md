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

**Scope, fixed 2026-08-25: the 18 things that refuse an action, and nothing else.** Ten of them
block; eight only advise. Five are already graded; **thirteen have never been graded at all**. The
rules, the reference material and the curation engine are out — see *Out of Scope*, which explains
what that choice deliberately leaves unmeasured.

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

### US4 — Stop the repeated bookkeeping from generating work (Priority: P2)

**As a** foundation maintainer
**I want** the repeated counting of what the foundation contains to stop producing commits and
blocking prepared changes
**So that** two people (or two changes) can work in parallel without invalidating each other

**Why P2**: real and measured — two files are touched by a majority of commits over two months, and
three prepared changes are currently blocked on nothing but stale counts. It is not P1 because it
does not change *what is shipped*, only the friction of shipping it. It gets worse mechanically once
a second assistant needs its own copy of the same records.

**Independent test**: prepare two independent changes; accept one; the other is still acceptable
without touching its counts.

**Acceptance criteria**:

1. **Given** two changes prepared in parallel that each add something counted, **When** one is
   accepted, **Then** the other does not become invalid through counting alone.
2. **Given** a change that adds nothing counted, **When** it is prepared, **Then** it carries no
   counting update at all.

---

### US5 — Know what survives the move before making it (Priority: P2)

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

### US6 — Leave a decision record a stranger can read (Priority: P3)

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
- **EF-015**: A guardrail MUST NOT be removed on the grounds that the platform now covers it unless
  that coverage has been **demonstrated on this repository**: disable the guardrail, trigger the real
  case it targets, observe whether the platform refuses, and record what was observed. Documented
  coverage is not evidence of coverage — on the day this was decided, two of this repository's own
  comments asserted the opposite of what the tool actually did.
- **EF-016**: A demonstration that produces no refusal MUST be treated as "not covered". A
  demonstration that cannot be run MUST be recorded as "unproven", never as "covered".
- **EF-014**: The record MUST NOT decide by comparing the two counts. **Prevented harm leaves no
  trace and caused harm always does**, so the counts are structurally biased against the guardrails
  that matter most: the one protecting against the only irreversible outcome in the set currently has
  zero recorded preventions and two recorded blocks. Counts MAY be reported; they MUST NOT be the
  criterion.

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
- **Everything that does not refuse an action** — decided 2026-08-25. The rules, the reference
  material and the curation engine are outside this pass. Two consequences are accepted knowingly
  rather than overlooked:
  - the **largest measured cost is left unmeasured**: the reference material carried into every
    session dwarfs the guardrails, and it is the part that arrives broken on the second assistant;
  - **no rule crosses the boundary either**, so the rules face the same portability question the
    guardrails do — just not in this pass.

  The scope was cut here because the guardrails are where the harm is *observed* (three episodes of
  blocked legitimate work in a single day), and because a pass that finishes is worth more than one
  that is still running when the port starts. A second pass over the wider surface is the natural
  successor, not a rejected alternative.

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
   2026-08-25: the 18 things that refuse an action, nothing else.** Ten block, eight advise; five are
   graded, thirteen are not. The wider surface — rules, reference material, curation engine — is
   deferred to a successor pass. The cost of that choice is written into *Out of Scope* rather than
   left implicit: the largest measured cost goes unmeasured for now.
