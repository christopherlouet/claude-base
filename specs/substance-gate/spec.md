# Spec — Substance gate (anti-hollow-test / anti-stub)

## Summary

A guardrail that flags **non-substantive** work — hollow tests and implementation
stubs that satisfy "tests exist and pass" + a coverage % while proving nothing. It
makes the foundation's own rule explicit and checkable: a test counts as evidence
only if it *ran* and *exercises an acceptance criterion* (≥1 real, non-trivial
assertion), and a passing suite over stub code is not "done". The next step in the
anti-gaming-of-quality-gates thread (sibling of the #410 anti-tamper guardrails),
serving the maintainer's current priority: generated-code quality & stability.

## Background (the gap)

Today the TDD/verification doctrine + the 80%-coverage rule measure *existence* and
*pass/green*, not *substance*. The `verification` rule has a single line ("add
assertions on critical invariants"); `tdd-enforcement` and the qa audit check none
of the hollow-test patterns. So a green suite can hide: assertion-free tests,
always-true assertions, skipped/empty/TODO tests, tests that match zero cases, and
stub implementations. Coverage % does not catch these.

---

## User Stories

### P1 — MVP

#### US-1 — Flag hollow tests so they don't count as evidence
**As a** maintainer trusting "tests pass" as a quality signal,
**I want** tests that assert nothing meaningful to be flagged,
**So that** a green suite reflects real verification, not theater.

Acceptance criteria:
- **Given** a test with no assertion at all
  **When** the substance check runs
  **Then** it is reported as non-substantive, naming the file and test.
- **Given** a test whose only assertion is trivially always-true (e.g. asserting a
  literal equals itself / a constant truthy value)
  **When** the check runs
  **Then** it is flagged.
- **Given** a skipped or disabled test (the skip/disable markers of the language)
  **When** the check runs
  **Then** it is flagged as not-actually-run (with the count of skipped tests).
- **Given** an empty or TODO-only test body
  **When** the check runs
  **Then** it is flagged.
- **Given** a genuine test with ≥1 real assertion exercising behavior
  **When** the check runs
  **Then** it is NOT flagged (no false positive).

#### US-2 — Flag implementation stubs behind a green suite
**As a** maintainer,
**I want** stub implementations to be flagged even when the suite is green,
**So that** "done" means working code, not a placeholder that the tests don't pin.

Acceptance criteria:
- **Given** a function body that only throws "not implemented" / returns a hardcoded
  placeholder / is an empty or `pass`-only body in delivered (non-test) code
  **When** the check runs
  **Then** it is reported as a stub, naming the location.
- **Given** a legitimately implemented function
  **When** the check runs
  **Then** it is NOT flagged.

#### US-3 — Understand the foundation's own test style (no self-false-positives)
**As a** maintainer of claude-base (whose own suite is bats, asserting with shell
test brackets, not `expect`),
**I want** the check to recognize each supported style's real assertions,
**So that** the foundation's 1300+ legitimate tests are not flagged as hollow.

Acceptance criteria:
- **Given** the foundation's own bats suite
  **When** the check runs over it
  **Then** zero false positives are produced.
- **Given** a snapshot/golden test or a table-driven/parametrized test that asserts
  via the framework's idiom rather than a literal assertion call
  **When** the check runs
  **Then** it is not falsely flagged (recognized as substantive).

### P2 — Important

#### US-4 — Surface at the moment it matters, actionably
**As a** developer (or the agent) finishing work,
**I want** the substance result surfaced where decisions are made — when claiming
done / during the quality audit — with a clear, actionable list,
**So that** non-substantive work is caught before it's committed or accepted.

Acceptance criteria:
- **Given** the quality audit / verification step runs
  **When** non-substantive items exist
  **Then** they appear as findings with file, kind (hollow-test / stub), and a
  one-line "why".
- **Given** the result
  **When** read by a human or agent
  **Then** it states what to do (write a real assertion / implement the stub), not a
  bare verdict.

#### US-5 — Multi-language coverage
**As a** maintainer of projects in several stacks,
**I want** the check to cover at least the foundation's primary languages,
**So that** the guardrail is useful across the catalog.

Acceptance criteria:
- **Given** TypeScript/JavaScript, Python, Go, and shell/bats test files
  **When** the check runs
  **Then** each language's hollow-test and stub patterns are recognized.

### P3 — Nice-to-have

#### US-6 — Run-aware substance (did the assertion actually execute)
**As a** maintainer wanting stronger proof,
**I want** an optional deeper check that a test actually executed ≥1 assertion (not
just that one is present in source) and matched ≥1 case,
**So that** a test that silently runs zero cases is caught.

Acceptance criteria:
- **Given** a test file that matches zero runnable cases (0 tests collected)
  **When** the run-aware check is enabled
  **Then** it is flagged.

#### US-7 — Advisory by default, opt-out, honest about limits
**As a** developer,
**I want** the guardrail to be an advisory nudge with a disable switch and a stated
false-positive policy,
**So that** it never hard-blocks legitimate work on an imperfect static signal.

Acceptance criteria:
- **Given** the guardrail
  **When** it cannot determine substance with confidence
  **Then** it errs toward NOT flagging (no false block) and says so.
- **Given** a disable switch is set
  **When** the check would run
  **Then** it is skipped.

---

## Functional Requirements

- **EF-001** — Detect, in test files, each hollow pattern: no-assertion, always-true
  assertion, skipped/disabled test, empty/TODO body.
- **EF-002** — Detect, in delivered (non-test) code, stub patterns: not-implemented
  throw, hardcoded-placeholder return, empty/`pass`-only body.
- **EF-003** — Recognize the real-assertion idiom of each supported language
  (including bats shell-test assertions and framework snapshot/table idioms) so a
  substantive test is NOT flagged.
- **EF-004** — Support at least TS/JS, Python, Go, shell/bats.
- **EF-005** — Output, per finding: file (and test name/line where applicable), the
  kind (hollow-test / stub / skipped), and a one-line corrective hint.
- **EF-006** — Be **advisory** (report, with a documented opt-out); any hard-block
  behavior, if offered at all, must be opt-IN and is out of scope for the MVP unless
  resolved in Clarification 1.
- **EF-007** — Fail safe: on an unrecognized file/language or an ambiguous case, do
  NOT flag (favor zero false positives over completeness) — and this is testable.
- **EF-008** — Produce ZERO false positives on the foundation's own test suite
  (regression-guarded).
- **EF-009** — Run deterministically and offline for the static checks (no network,
  no model call); any run-aware check (US-6) is separately invokable.
- **EF-010** — Integrate with the foundation's quality flow so the result is visible
  at verification/audit time (exact integration point set by Clarification 3).

## Edge Cases

1. **bats assertions** (`[ "$status" -eq 0 ]`, `assert_*`) — must read as real
   assertions, else the foundation flags itself (US-3 / EF-008).
2. **Snapshot/golden tests** — assertion is implicit in `toMatchSnapshot()` / golden
   compare; must count as substantive.
3. **Table-driven / parametrized tests** — the assertion is inside a loop/param;
   must not be mistaken for "no assertion".
4. **Legitimate WIP skip** — a deliberately skipped test during red-phase TDD: flag
   it (it isn't evidence yet) but as informational, distinct from a hollow assert.
5. **Test helpers / fixtures / setup files** — files with no `@test`/`it`/`func Test`
   are not tests; must not be scanned as if they were.
6. **Always-true that is actually meaningful** — e.g. `expect(fn).not.toThrow()` has
   no value literal but IS substantive; the always-true detector must be narrow.
7. **Stub-shaped but intentional** — an interface/abstract method, a not-yet-built
   feature explicitly out of scope, a `NotImplementedError` that is the real intended
   behavior; favor not-flagging (EF-007) or allow an inline opt-out marker.
8. **Generated code** — generated test/impl files should be excludable.
9. **Mixed languages in one repo** — each file judged by its own language.

## Entities

Not a data feature. The structured artifacts:
- **Finding** — {file, location, kind (hollow-test | always-true | skipped | empty |
  stub), hint}.
- **Pattern set per language** — the hollow/stub patterns and the real-assertion
  idioms recognized for each supported language.

## Success Criteria

- **CS-001** — On a fixture corpus of known hollow tests and stubs (one per pattern,
  per language), the check flags 100% of them.
- **CS-002** — On a fixture corpus of substantive tests (incl. bats, snapshot,
  table-driven), the check flags 0% (zero false positives).
- **CS-003** — Run over the foundation's own `tests/` suite: 0 findings (EF-008).
- **CS-004** — Each supported language has at least one passing hollow-detect and one
  passing substantive-allow case.
- **CS-005** — The disable switch and the fail-safe (ambiguous → not flagged) are each
  covered by a test.
- **CS-006** — Findings are human/agent-actionable (kind + hint present) — asserted by
  a test on the output shape.

## Out of Scope

- Rewriting or replacing the existing coverage tooling (this complements it).
- Deep language-specific AST parsing for v1 (pattern/heuristic detection is enough;
  AST is a later enhancement).
- A hard, blocking PreToolUse gate on every test edit (false-positive risk on a
  static signal) — unless Clarification 1 chooses otherwise; default is advisory.
- Detecting *semantic* weakness (a test that asserts the wrong thing) — only
  structural hollowness/stubbing is in scope.
- Mutation testing (a heavier, separate technique).

## Clarification Points — RESOLVED (2026-06-27)

1. **Advise vs block** → ✅ **Advisory v1.** Warn on test-file edits + surface as a
   qa/verification gate; **no hard block.** An opt-in blocking mode is DEFERRED (not
   v1). Consistent with the anti-tamper guardrails' nudge philosophy. (Drops EF-006's
   conditional: no blocking mode ships in v1.)
2. **Static vs run-aware** → ✅ **Static-only v1.** Deterministic, offline (US-1/US-2/
   US-3). The run-aware check (US-6, 0-cases-collected / assertion-not-executed) is a
   **separate opt-in P3**, not in the MVP.
3. **Where it lives** → ✅ **One detector script = source of truth**, reused by (a) a
   PostToolUse advisory hook on test-file edits, (b) the qa-loop/qa-review checklist,
   and (c) referenced from the `verification` / `tdd-enforcement` rules. (US-3/EF-008
   zero-false-positive-on-our-own-suite is the hardest constraint and gates all three.)
