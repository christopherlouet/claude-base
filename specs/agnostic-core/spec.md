# Specification — Agnostic Core Extraction

> Separate the foundation's decision logic (the "core") from the assistant-specific plumbing (the "shell"), so the same discipline and safety guarantees can later run on other coding assistants — without changing anything for current users.

## 1. Summary

claude-base's value (safety guards, workflow discipline, curated content) is currently welded to one assistant's conventions. This work extracts that value into an assistant-neutral core, kept behind thin per-assistant shells, with **zero behavior change** for existing users. It prepares — but does not implement — support for additional assistants.

## 2. User Stories

### P1 — Guard decision logic extracted (MVP)

**US-1 — Portable guard verdicts**
As the maintainer, I want each safety guard's decision logic (what is dangerous, what is blocked, why) separated from the plumbing that talks to the assistant, so that the same protections can later be offered on other assistants without rewriting or forking them.

- Given the existing corpus of dangerous and legitimate commands, When the decision logic is exercised on its own (no assistant involved), Then it returns exactly the verdicts the guards return today (same blocks, same allows, same reasons).
- Given a guard evaluates an input, When it reaches a verdict, Then the verdict is expressed as data (allow/deny + human-readable reason), and only the thin per-assistant layer translates that verdict into the assistant's convention.
- Given the full existing test suite, When it runs after the extraction, Then every test passes unchanged (the assistant-facing behavior is byte-identical).

**US-2 — Core independently verifiable**
As the maintainer, I want the extracted decision logic to be testable directly, so that a future port to another assistant can be validated against the same reference tests without simulating the current assistant.

- Given the extracted core, When its dedicated tests run, Then they exercise verdicts without constructing any assistant-specific input envelope.
- Given a change to a decision table, When tests run, Then a wrong verdict is caught by the core tests alone (not only through the assistant-facing tests).

**US-3 — Nothing breaks for installed projects**
As a user of the foundation, I want projects initialized or updated after this change to behave exactly as before, so that the refactor is invisible to me.

- Given a fresh project initialization, When the guards run in that project, Then every shipped protection works identically (all supporting files are installed together; no guard fails from a missing piece).
- Given the install-manifest coverage checks, When they run, Then every newly introduced shared file is covered.

### P2 — Installer seam: select, then emit

**US-4 — Selection separated from writing**
As the maintainer, I want the installer's "what to ship" decision (detection, presets, modules, tiers, filters) separated from its "where and how files land" step, so a future target option can reuse the selection unchanged.

- Given a chosen preset/module/tier combination, When the selection step runs, Then it produces an explicit, inspectable list of items to ship, before anything is written.
- Given that list, When the writing step runs for the current assistant, Then the resulting installed project is identical to what today's installer produces for the same choices.
- Given a dry-run, When it is requested, Then the reported list matches exactly what a real run would install.

### P3 — Portability map

**US-5 — Every component classified**
As the maintainer, I want each shipped component (guards, content categories) recorded as portable or assistant-only, so that a future port knows at a glance what it gets, what it adapts, and what it skips.

- Given the classification record, When a component is added or removed, Then a check flags the record if it is out of date.
- Given the record, When read, Then it states for each guard whether its decision logic is shared, and for each content category the known porting constraints.

## 3. Functional Requirements

| ID | Requirement | Measure |
|----|-------------|---------|
| EF-001 | All existing tests pass unchanged after extraction | Full suite green (≥ current count), zero test edits required for P1 |
| EF-002 | Each portable guard's verdict is computable from plain inputs (a command string, a file path, file content) with no assistant envelope | Demonstrated by direct core tests per guard |
| EF-003 | Verdicts are data (decision + reason); assistant-convention translation lives only in the thin per-assistant layer | No decision pattern/table remains in any per-assistant layer |
| EF-004 | Extracted core has dedicated direct tests | ≥ 1 direct test file per extracted core unit |
| EF-005 | Newly introduced shared files ship on init/update and are covered by the install-manifest checks | Manifest checks green; fresh-install guard self-test passes |
| EF-006 | Guards with no portable decision logic are identified and left untouched | Classification record lists them explicitly |
| EF-007 | (P2) Selection produces an explicit selected-set; writing consumes only that set | Dry-run list ≡ real install content |
| EF-008 | Existing portability constraints are preserved (macOS bash 3.2, ASCII in executed strings, no new runtime dependency) | Existing portability checks green |
| EF-009 | Generated artifacts (counts, catalogs, website mirror) remain coherent | Counts gate green |

## 4. Edge Cases

- A guard's verdict must be identical when the optional JSON parser is unavailable (existing fallback paths keep working through the extraction).
- Payload-vs-flag distinction is preserved: a trigger word inside a commit message or document body must still not cause a block (the message-stripping behavior moves with the core, unduplicated).
- A project initialized with an older version then updated must end up with the complete new file set (no orphan shell without its core).
- Guards that are inherently assistant-only (output rewriting, version probing, self-integrity) keep working exactly as today and are excluded from extraction.
- The single-shared-copy rule holds: no decision logic may exist in two files (past divergent copies shipped bugs).

## 5. Entities

- **Verdict** — outcome of a guard evaluation: decision (allow/deny/advise) + human-readable reason.
- **Core unit** — assistant-neutral decision logic for one guard (or shared helper), directly testable.
- **Shell** — thin per-assistant layer: reads the assistant's input, calls core units, translates the verdict to the assistant's convention.
- **Selected set** (P2) — explicit list of items chosen for installation, independent of destination.
- **Portability record** (P3) — classification of each component: shared / adapted / assistant-only, with constraints.

## 6. Success Criteria

| ID | Criterion | Target |
|----|-----------|--------|
| CS-001 | Zero behavior change | Full suite green; no assistant-facing test modified for P1 |
| CS-002 | Coverage of extraction | All guards with portable decision logic (per exploration: ~8 guards + 3 shared helpers) have their core extracted and directly tested |
| CS-003 | Thin shells | No decision pattern remains outside core units; each shell reduced to input-reading + verdict translation |
| CS-004 | Port-readiness | A written adapter contract describes exactly what a new assistant shell must implement (inputs, verdict translation, install wiring) |
| CS-005 | (P2) Seam proven | Same choices → identical installed tree through the selected-set path |

## 7. Out of Scope

- Any second-assistant emitter or `--target` option (later phase).
- Command→skill conversion, cross-reference rewriting, AGENTS.md generation, content body rewriting.
- Changes to the assistant-only guards (output rewriters, version probe, self-integrity, setup plumbing) beyond keeping them working.
- Any competitor-product-named artifact in the repo (neutral core/shell vocabulary only).
- Marketplace plugin installation changes.
- New features, new guards, new content.

## 8. Clarification Points

1. **Batching**: P1 (guards core) and P2 (installer seam) as separate deliveries? Recommendation: yes — P1 first, own PR; P2 only after P1 is merged.
2. **Adapter contract depth**: document the second-assistant verdict translation (JSON-deny style) now as specification-only, or defer until the corresponding live spike? Recommendation: document now (cheap, testable on paper), implement never in this chantier.
3. **P3 record form**: human-maintained document with a drift check, or generated? Recommendation: human-maintained + drift check (matches existing practice).
