# Tasks — Substance gate

Branch: `feat/substance-gate` · TDD (tests before code). `[P]` parallelizable · `[US?]` trace.
Decisions: advisory v1 · static-only · one detector reused by hook + qa + rules.

## Phase 1 — de-risk EF-008 (zero self-false-positives) FIRST

- **T001** `[US3]` RED: `tests/substance-check.bats` — assert `substance-check.sh tests/`
  (the foundation's REAL bats suite) produces **0 findings**. (Fails: script absent.)
- **T002** `[US3]` GREEN (skeleton): `scripts/substance-check.sh` — arg parsing
  (`[paths…] --tests-only --code-only --format --quiet`), language dispatch by
  extension, bats real-assertion recognizer (`[ `/`[[ `/`run `/`assert*` + status),
  fail-safe default (unknown/ambiguous → no finding). Make `tests/` scan return 0.
- **T003** `[US3]` shellcheck clean; T001 green.

## Phase 2 — hollow-test scanner (US-1), language by language

- **T010** `[US1]` RED: fixtures `tests/fixtures/substance/ts/{hollow,substantive}/`
  (no-assertion, always-true, it.skip, empty/TODO | real-expect, not.toThrow,
  snapshot, table-driven) + bats cases asserting flag/no-flag.
- **T011** `[US1]` GREEN: TS/JS hollow scanner (block extract + assertion idiom +
  narrow always-true + skip + empty). T010 green; no regression on T001.
- **T012** `[P][US1][US5]` Python fixtures + scanner (assert/pytest.raises; skip marks; pass-only).
- **T013** `[P][US1][US5]` Go fixtures + scanner (t.Error/Fatal/assert; t.Skip).
- **T014** `[US1]` bats hollow fixtures (a `skip`-only test, an assertion-less @test) + cases.
- **T015** `[US1]` shellcheck; re-run `substance-check.sh tests/` ⇒ still 0 (CS-003).

## Phase 3 — stub scanner (US-2)

- **T020** `[US2]` RED: code fixtures per lang `…/stub/` (not-implemented throw,
  NotImplementedError, panic, pass-only, hardcoded-return) + substantive impls + cases.
- **T021** `[US2]` GREEN: stub scanner (non-test code), with inline opt-out marker +
  favor-not-flagging on ambiguity (edge-7). T020 green.
- **T022** `[US2]` shellcheck; full `tests/substance-check.bats` green.

## Phase 4 — integration (US-4), advisory only

- **T030** `[US4]` `scripts/hooks/substance-check.sh` — PostToolUse; reads stdin
  `.tool_input.file_path`; runs detector on that file IF it's a test file; emits
  `hookSpecificOutput.additionalContext` on findings; **exit 0 ALWAYS**; bail on
  `SKIP_SUBSTANCE_CHECK=1` / jq absent. + bats for the hook (advisory, never exit 2).
- **T031** `[US4]` Register in `.claude/settings.json` PostToolUse (`Edit|Write|MultiEdit`);
  validate `jq . settings.json`.
- **T032** `[US4]` Add the hook to `scripts/lib/minimal-manifest.txt` (manifest drift-
  guard — #410 lesson). Run `tests/manifest-hooks-coverage.bats`.
- **T033** `[US4]` qa checklist: `.claude/skills/qa-review/SKILL.md` (+ qa-loop agent)
  — a "test substance" step running `substance-check.sh` over the diff.
- **T034** `[US4]` Pointer line in `.claude/rules/verification.md` + `tdd-enforcement.md`.
- **T035** `[US4]` `docs/reference/hooks-reference.md` — Configured Hooks row +
  `SKIP_SUBSTANCE_CHECK` env-var row.

## Phase 5 — advisory/opt-out/fail-safe (US-7)

- **T040** `[US7]` Tests: `SKIP_SUBSTANCE_CHECK=1` skips; ambiguous/unknown file → no
  finding; generated-file exclusion; output shape has {kind, hint} (CS-006).

## Phase 6 — audit & ship

- **T050** `shellcheck scripts/substance-check.sh scripts/hooks/substance-check.sh`.
- **T051** Full `./scripts/test.sh` (or full bats) — 0 fail; `validate-counts.sh` OK
  (pre-commit self-heals counts on commit).
- **T052** `substance-check.sh .` over the whole repo → review findings (expect ~0 on
  real code; any true positive is a real hollow test to fix or doc).
- **T053** `/qa:qa-loop "score 90"` (the audit caught a real P0 last feature — expect
  scrutiny on false-positive/negative balance of the heuristics).
- **T054** Commit (Conventional, no AI attribution) → PR to main.

## Ordering / parallelism

- **T001–T003 first** (EF-008 is the make-or-break constraint; prove 0 self-FP before building).
- TS → then Py/Go in parallel (`[P]`). Stub scanner (Phase 3) independent of hollow (Phase 2).
- Integration (Phase 4) after the detector is solid. Audit last.

## Definition of Done

- CS-001 (100% hollow/stub fixtures flagged) · CS-002 (0% substantive flagged) ·
  CS-003 (0 findings on our `tests/`) all green.
- Advisory hook never exits 2; `SKIP_SUBSTANCE_CHECK` + fail-safe tested.
- shellcheck clean; settings.json valid; hook in manifest; counts OK; full suite green
  on Linux + macOS; qa-loop ≥ 90. PR opened. (US-6 run-aware NOT in scope — P3.)
