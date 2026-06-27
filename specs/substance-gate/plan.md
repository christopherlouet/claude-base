# Plan — Substance gate (anti-hollow-test / anti-stub)

Spec: `specs/substance-gate/spec.md` · Branch: `feat/substance-gate`
Complexity: **Medium–Large** — volume is small, but the per-language heuristics and
the **zero-false-positive-on-our-own-suite** constraint (EF-008) carry the risk.

Decisions (resolved): advisory v1 (no hard block) · static/offline only (run-aware
deferred) · one detector script reused by hook + qa checklist + rules.

## Architecture

### `scripts/substance-check.sh` (new — source of truth)
A deterministic, offline bash detector mirroring the `validate-counts.sh` /
`audit-base.sh` style. Reuses no execution.

```
substance-check.sh [paths…]            # default: scan git-diff or given files/dirs
  --tests-only | --code-only           # restrict to hollow-test vs stub scan
  --format text|json                   # findings output
  --quiet                              # suppress the no-findings line
Exit 0 always in advisory mode (findings go to stdout); non-zero only on usage error.
```
Per file → detect language by extension/shebang → run that language's scanners →
emit `Finding{file, line, kind, hint}`. **Fail-safe**: unknown language / ambiguous
block ⇒ no finding (EF-007).

#### Detection model (heuristic, no AST — EF-009)
Two scanners, each a per-language pattern set:

1. **Hollow-test scanner** (test files only). Extract each test block (awk, by the
   language's test-declaration + brace/indent), then within the block check for a
   **real-assertion idiom**; flag the block when it has none, or only an always-true
   literal, or is skipped, or is empty/TODO.
2. **Stub scanner** (non-test code). Flag a function body that is only a
   not-implemented throw / `NotImplementedError` / `panic("not implemented")` / a
   `pass`-only or empty body / a single hardcoded-literal return.

| Lang | Test decl | Real-assertion idiom (NOT hollow) | Skipped | Stub marker |
|------|-----------|-----------------------------------|---------|-------------|
| TS/JS | `it(`/`test(`/`describe(` | `expect(`, `assert`, `.to`, `.should`, `toMatchSnapshot` | `it.skip`/`xit`/`describe.skip` | `throw new Error('not impl…')`, hardcoded return-only |
| Python | `def test_`/`async def test_` | `assert `, `self.assert`, `pytest.raises`, `assertRaises` | `@pytest.mark.skip`/`@unittest.skip`/`@skip` | `raise NotImplementedError`, `pass`-only |
| Go | `func Test…(t *testing.T)` | `t.Error`/`t.Fatal`/`t.Errorf`/`assert.`/`require.`/`want != got` | `t.Skip(` | `panic("not implemented")`, `// TODO` empty |
| bats/sh | `@test` | `[ `/`[[ `/`assert`/`assert_*`/`run ` + status check | `skip` | n/a (shell) |

Always-true detector is **narrow** (EF/edge-6): only literal-vs-itself / constant
truthy (`expect(true).toBe(true)`, `assert True`, `assert 1 == 1`, `[ 1 -eq 1 ]`);
NOT `expect(fn).not.toThrow()` (substantive).

### Integration (3 reuse points — all advisory)
- **Hook** `scripts/hooks/substance-check.sh` — PostToolUse on `Edit|Write|MultiEdit`
  of a **test file** (path matches `*.test.*|*.spec.*|*_test.go|test_*.py|*.bats|tests/**`).
  Runs the detector on that one file; on a finding, emits a non-blocking notice
  (`hookSpecificOutput.additionalContext`, exit 0 — NEVER 2). Disable
  `SKIP_SUBSTANCE_CHECK=1`. Registered in `.claude/settings.json` PostToolUse.
- **qa checklist** — `.claude/skills/qa-review/SKILL.md` + `qa-loop`: add a "test
  substance" step that runs `substance-check.sh` over the diff and lists findings.
- **Rules** — one pointer line each in `.claude/rules/verification.md` and
  `tdd-enforcement.md` (a substantive test = ran + ≥1 real assertion; see the script).

### Fixture corpus
`tests/fixtures/substance/<lang>/` with `hollow/` (one file per pattern) and
`substantive/` (incl. snapshot, table-driven, `not.toThrow`, bats). Drives CS-001/002.

## Files

### Create
- `scripts/substance-check.sh` — the detector (US-1/2/3/5).
- `scripts/hooks/substance-check.sh` — advisory PostToolUse hook (US-4).
- `tests/substance-check.bats` — TDD suite (drives the detector over fixtures).
- `tests/fixtures/substance/{ts,py,go,bats}/{hollow,substantive}/…` — corpus.

### Modify
- `.claude/settings.json` — register the PostToolUse hook (`Edit|Write|MultiEdit`).
- `scripts/lib/minimal-manifest.txt` — **ship the new hook** (drift-guard
  `manifest-hooks-coverage.bats` will fail otherwise — learned the hard way in #410).
- `.claude/skills/qa-review/SKILL.md` (+ qa-loop agent) — substance checklist step.
- `.claude/rules/verification.md`, `.claude/rules/tdd-enforcement.md` — pointer line.
- `docs/reference/hooks-reference.md` — Configured Hooks row + `SKIP_SUBSTANCE_CHECK`.
- (auto by #408 pre-commit) counts/README/mirror — regenerated.

## Phases

1. **US-3 + EF-008 first (de-risk):** build the bats real-assertion recognizer and
   prove **0 findings on our own `tests/`** before anything else — the constraint that
   can sink the feature. TDD.
2. **US-1 hollow-test scanner** (TS/JS first, then Py/Go/bats) — TDD against fixtures.
3. **US-2 stub scanner** — TDD against fixtures.
4. **US-5 multi-language** — fold per-language tables in as US-1/2 progress (`[P]`).
5. **US-4 integration** — advisory hook + settings + manifest + qa checklist + rules.
6. **US-7 advisory/opt-out/fail-safe** — disable switch + ambiguous→no-flag tests.
7. **Audit** — shellcheck, full bats, `substance-check.sh` over the whole repo
   (expect 0), `/qa:qa-loop "score 90"`. (US-6 run-aware NOT built — P3.)

## Risks & mitigations

| Risk | Mitigation |
|------|-----------|
| **Self-false-positives on our bats suite** (EF-008) — kills trust | Phase 1 builds the recognizer against the real `tests/` and asserts 0 findings before expanding. CS-003 is a standing regression test. |
| **Per-test-block scoping in bash/awk is fragile** (multi-line, nested braces, Python indentation) | Conservative block extraction; on any parse ambiguity, fail-safe to NO finding (EF-007). Heuristic ≠ AST (explicitly out of scope). Prefer false-neg over false-pos. |
| **always-true detector too broad** (flags `not.toThrow`, negative assertions) | Keep it to literal-vs-self / constant-truthy only; fixture a `not.toThrow` as substantive (edge-6). |
| **Snapshot / table-driven / parametrized read as assertion-free** | Treat `toMatchSnapshot`/golden-compare and loop/param assertions as real idioms; fixture each as substantive (edge-2/3). |
| **Stub scanner flags legit abstract/interface/intended NotImplemented** | Scope to delivered code; allow an inline opt-out marker; favor not-flagging (edge-7). |
| **Performance over a large tree** | Default scope = git diff / passed paths; the hook scans ONE file; the full-repo scan is opt-in (audit). |
| **Manifest drift** (forgot to ship the hook) | Add to `minimal-manifest.txt` in the SAME change; the drift-guard bats catches it (#410 lesson). |
| **Advisory must never hard-block** | Hook exits 0 always; only emits `additionalContext`. A blocking mode is explicitly out of scope v1. |

## Verification

- `tests/substance-check.bats` over the fixture corpus (CS-001/002/004/005).
- `substance-check.sh tests/` ⇒ 0 findings (CS-003 / EF-008).
- `shellcheck scripts/substance-check.sh scripts/hooks/substance-check.sh`.
- Manual: pipe a crafted PostToolUse payload into the hook → advisory notice, exit 0.
- Full `./scripts/test.sh` + `validate-counts.sh` + `/qa:qa-loop "score 90"`.
