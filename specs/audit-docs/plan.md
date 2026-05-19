# Implementation Plan: `audit-docs.sh` — Doc drift firewall

**Branch**: `feature/auto-20260519-163858` (rename to `feat/audit-docs-drift-firewall` via `/git-rename`)
**Date**: 2026-05-19
**Spec**: [`spec.md`](./spec.md)
**Status**: Draft

---

## Summary

Build `scripts/audit-docs.sh` — a bash audit script that catches 5 categories of syntactic doc drift (paths, claude-base verbs, CLI flags, script references, npm scripts). Integrated into `scripts/audit-base.sh` so it runs at every CI gate / pre-commit / manual audit. Replaces the manual hand-rolled grep audit done after the `~/.claude-base/` discovery, formalised as a CI-enforced firewall. TDD-driven : ≥6 failing bats tests first, then 5 audit functions (one per category), then audit-base.sh integration.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Primary artifact** | `scripts/audit-docs.sh` (new) | ~200 LOC bash, 5 audit functions + 1 dispatcher + 1 reporter |
| **Test framework** | Bats (existing `tests/audit-docs.bats` to create) | Heredoc fixtures, inline drift scenarios |
| **Dependencies** | Bash 4+, `grep`, `jq`, `find` | All already required by the foundation |
| **Allowlist source of truth** | Bash arrays inside the script | Live-derived for npm scripts (`jq` over `website/package.json`) ; hardcoded for verbs/flags/paths (1-line edit to extend) |
| **Integration** | New `audit_docs_drift` function in `audit-base.sh`, called between `audit_doc_links` and `audit_counts` | Existing audit pattern, no new pipeline step |
| **Runtime target** | < 5 s on full repo | Soft target ; 98 doc files × 5 categories × grep |
| **LOC estimate** | ~350 LOC across 3 hand-edited files (script + audit-base + bats) + CHANGELOG | Bigger than recent doc PRs ; real foundation feature |

### Live-derived allowlists (locked at plan time, verified via grep on current code)

```
KNOWN_VERBS=(init update validate preset uninstall version help)
                                                           # bin/claude-base case @ ~line 120

KNOWN_INIT_FLAGS=(--verbose --ci --hooks --mcp --docker --all --style
                  --skip-prompts --minimal --preset --presets-dir
                  --list-presets --detect-only --yes -y --type -t
                  --simple --install-only)
                                                           # new-project.sh @ lines 258-337

KNOWN_UPDATE_FLAGS=(--add-hook --add-plugin --agents --all --backup-only
                    --changelog --clean --detect-orphans --hook-scripts
                    --no-preset --preset --presets-dir --remove-orphans
                    --restore --rules --settings --skills --styles
                    --templates --upgrade-claude-md --verbose)
                                                           # update.sh

KNOWN_PATH_PREFIXES=(
  ~/.claude/               # Claude Code user config
  ~/.local/share/claude-base/  # canonical install per install.sh:33
  ~/.local/bin/            # dispatcher symlink target
  ~/.bashrc                # OS shell config
  ~/dev/vendor-skills/     # user-suggested vendor clone location
)

KNOWN_NPM_SCRIPTS=$(jq -r '.scripts | keys[]' website/package.json)
                                                           # live-derived
```

### File scope (locked at clarify time)

```
docs/**/*.md
website/docs/intro/**/*.md
website/docs/concepts/**/*.md
website/docs/examples/**/*.md
website/docs/tutorials/**/*.md
website/docs/workflow/**/*.md
website/docs/guides/**/*.md
website/docs/reference/**/*.md
```

Excluded (auto-generated mirrors of in-tree sources OR rules describing user-project scripts):

```
website/docs/agents/**       # mirror of .claude/agents/
website/docs/commands/**     # mirror of .claude/commands/
website/docs/skills/**       # mirror of .claude/skills/
website/docs/rules/**        # mirror of .claude/rules/ (user-project guidance)
```

### Memory anchors

- `feedback_verify_code_claims` — every allowlist entry above was grep'd against the live code during this plan
- `feedback_bsd_seq_zero_range` — any bash `for` loop with `seq` MUST guard `n -gt 0`
- `feedback_pr_title_no_quotes` — PR title MUST NOT contain inner double quotes
- `feedback_website_docs_mirror_sync` — running `npm run generate` after `docs/` edits is mandatory (this script doesn't edit docs, so not applicable, but tests must consider mirror state)
- `feedback_no_project_names` — EF-015 grep guard

---

## Constitution / Conventions Check

GATE — validate before starting:

- [ ] All 3 clarifications resolved (file scope, verb pattern, env var hatch) — see `spec.md` §"Locked decisions"
- [ ] Allowlists locked at plan time, verified via grep
- [ ] CI baseline captured (validate-counts, audit-base, bats)
- [ ] TDD cycle planned : failing tests committed BEFORE script implementation
- [ ] No memory anti-pattern violated

---

## Project Structure (this feature)

```
specs/audit-docs/
├── spec.md     # Functional spec (8 US, 15 EF, 12 CS, 3 CP resolved)
├── plan.md     # This file
└── tasks.md    # Task breakdown
```

---

## Impacted Files

### To create

| File | Responsibility | LOC |
|------|----------------|-----|
| `scripts/audit-docs.sh` | The audit script itself: 5 audit functions + dispatcher + reporter + env-var parsing | ~200 |
| `tests/audit-docs.bats` | ≥10 bats tests (5 positive + 5 negative per category + 2 regression) | ~250 |

### To modify

| File | Modification | LOC delta |
|------|--------------|-----------|
| `scripts/audit-base.sh` | Add new `audit_docs_drift()` function that invokes `audit-docs.sh` ; call it between `audit_doc_links` and `audit_counts` | +15 |
| `CHANGELOG.md` | One bullet under `[Unreleased] / ### Added` | +12 |

### Auto-regenerated (DO NOT hand-edit)

| File | Trigger | Mechanism |
|------|---------|-----------|
| `counts.json#tests` | New bats tests added | `npm --prefix website run generate` |
| `README.md` `<!-- count:tests -->` badge | Same | Same generator |

### Files NOT touched

- `.claude/skills/*`, `.claude/agents/*`, `.claude/presets/*` (no new bundled artifact)
- Any docs file (the audit only READS them ; fixing detected drift is a follow-up PR per finding)
- `tests/presets-fixtures/*` (no preset added)

---

## Chosen Approach

### Sequencing (TDD-driven)

```
Phase 1: Pre-verification + branch rename
         │
         ▼
Phase 2: TDD RED — ≥10 failing bats tests covering 5 categories + 2 regressions
         │
         ▼
Phase 3: TDD GREEN — implement audit-docs.sh in 5 sub-phases
         3a) skeleton + arg parsing + env-var hatch
         3b) audit_paths
         3c) audit_verbs
         3d) audit_flags (init + update)
         3e) audit_scripts
         3f) audit_npm
         │
         ▼
Phase 4: Integrate into audit-base.sh
         │
         ▼
Phase 5: Verify zero false-positive on current main (EF-012)
         │
         ▼
Phase 6: CHANGELOG + pre-commit guards
         │
         ▼
Phase 7: Commits + push + PR + watch CI + merge
```

### Rationale

- **TDD mandatory** (`.claude/rules/workflow.md`) — audit logic is pure functions ; perfectly TDDable.
- **One audit function per category** keeps the script reviewable in 5 small chunks.
- **Env-var hatch BEFORE per-category logic** (Phase 3a) so each category can independently honour `AUDIT_DOCS_SKIP_X=1` once written.
- **Integration LAST** : the standalone script must be green by itself before plugging into audit-base.sh (avoid CI noise during dev).
- **Phase 5 zero-false-positive check** is the most important gate — if current `main` produces any drift, the spec is wrong OR the implementation is wrong. Either way, must be fixed before merge.

### Alternatives considered

| Alternative | Why rejected |
|---|---|
| Put audit logic directly inside `audit-base.sh` as new functions | `audit-base.sh` would balloon ; 5 categories deserve their own file for review and per-category opt-out |
| Live-derive ALL allowlists (parse `bin/claude-base` AT runtime) | Brittle (regex-parsing bash) ; locked arrays are simpler and explicit, with a 1-line edit when verbs change |
| Use Python or Node for richer parsing | Adds a language dependency the foundation doesn't already have ; bash + grep + jq are sufficient for syntactic drift |
| Run audit on PRE-commit hook | Out of scope — `audit-base.sh` already covers CI ; pre-commit can be configured by the user separately |
| Detect AND auto-fix | Auto-fix is risky (changes file content silently) ; detection-only per spec |

---

## Implementation Phases

### Phase 1 — Pre-verification + branch rename (BLOCKING)

- T001 — Capture baseline (`validate-counts.sh`, `audit-base.sh`, `bats tests/*.bats` count).
- T002 — Verify bash 4+ + jq + grep + find are available.
- T003 — Rename branch to `feat/audit-docs-drift-firewall` via `/git-rename` (user-invoked).

**Checkpoint**: Baseline known. Branch named.

### Phase 2 — TDD RED (US-1 through US-6)

**Goal**: ≥10 failing bats tests, each targeting one EF.

⚠️ DO NOT create `scripts/audit-docs.sh` yet. Only `tests/audit-docs.bats`.

- T004 — Create `tests/audit-docs.bats` with `setup`/`teardown` mirroring `tests/presets.bats` patterns.
- T005 — [US1, EF-001] Negative: "rejects an unknown `~/X` path prefix". Fixture: temp doc containing `~/nonexistent-prefix/foo`. Assert exit 1, category `paths`.
- T006 — [US1, EF-001] Positive: "accepts a known `~/.local/share/claude-base/` path". Assert exit 0.
- T007 — [US1, EF-002] Negative: "rejects `claude-base nonexistentverb`". Assert exit 1, category `verbs`.
- T008 — [US1, EF-002] Prose-tolerance: "ignores `claude-base is a foundation` (English word after the binary)". Assert exit 0.
- T009 — [US1, EF-003] Negative: "rejects `claude-base init --foo`". Assert exit 1, category `flags`.
- T010 — [US1, EF-003] Positive: "accepts `claude-base init --preset nextjs`". Assert exit 0.
- T011 — [US1, EF-004] Negative: "rejects `./scripts/nuclear.sh`". Assert exit 1, category `scripts`.
- T012 — [US1, EF-004] Positive: "accepts `./scripts/test.sh`". Assert exit 0.
- T013 — [US1, EF-005] Negative: "rejects `npm --prefix website run nonsense`". Assert exit 1, category `npm`.
- T014 — [US1, EF-005] Positive: "accepts `npm --prefix website run generate`". Assert exit 0.
- T015 — [US6] Regression PR #199: "fixture with `~/.claude-base/` triggers `paths` drift". Assert exit 1.
- T016 — [US5, EF-011] Env-var hatch: "AUDIT_DOCS_SKIP_PATHS=1 ignores path drifts but still catches verbs". Assert exit code reflects only non-skipped categories.
- T017 — [EF-012] **Zero-FP-on-main**: "audit-docs.sh on the real repo exits 0". This is the most important test — if it fails, the implementation has a false positive.
- T018 — [EF-013] Remote-URL tolerance: "https://github.com/.../scripts/X.sh in a doc is NOT flagged as missing local script".
- T019 — Run `bats tests/audit-docs.bats` → expected: **all tests FAIL** (script doesn't exist). Confirm RED state explicitly.

**Checkpoint**: ≥15 bats tests RED. Baseline bats tests still pass (the new file doesn't touch existing).

### Phase 3 — TDD GREEN: implement `audit-docs.sh`

#### Phase 3a — Skeleton (US-5, EF-011)

- T020 — Create `scripts/audit-docs.sh` shebang + `set -euo pipefail` + sourcing `lib/common.sh`.
- T021 — Parse env vars `AUDIT_DOCS_SKIP_{PATHS,VERBS,FLAGS,SCRIPTS,NPM}=1` into flags.
- T022 — Parse args `--verbose`, `--category <name>`, `--help`.
- T023 — Define the 5 allowlist bash arrays (KNOWN_VERBS, KNOWN_INIT_FLAGS, KNOWN_UPDATE_FLAGS, KNOWN_PATH_PREFIXES) ; derive KNOWN_NPM_SCRIPTS via `jq`.
- T024 — Define the 8 file-scope globs and a helper `enumerate_scope_files()` that returns the list.
- T025 — Define `report_drift "<file>" "<line>" "<category>" "<message>"` accumulator and `final_exit()` aggregator.
- T026 — Run `bats tests/audit-docs.bats` → expected: all category tests still FAIL (categories not implemented yet) ; smoke tests on skeleton pass.

#### Phase 3b — `audit_paths` (US-1, EF-001)

- T027 — Implement `audit_paths()` : grep `~/[\w./-]+` patterns in scope files, classify each against KNOWN_PATH_PREFIXES, report drift on unknowns.
- T028 — Run bats → T005, T006, T015 pass. T017 (zero-FP) may still fail if other categories aren't ready ; check this category in isolation.

#### Phase 3c — `audit_verbs` (US-1, EF-002)

- T029 — Implement `audit_verbs()` : grep `claude-base [a-z][a-z-]*` patterns, filter against KNOWN_VERBS, report drift on unknown verbs ; explicitly NO drift for prose-words.
- T030 — Run bats → T007, T008 pass.

#### Phase 3d — `audit_flags` (US-1, EF-003)

- T031 — Implement `audit_flags()` : grep `claude-base init --[a-z-]+` (and `-[a-z]`) patterns, cross-check KNOWN_INIT_FLAGS ; same for `claude-base update --...` against KNOWN_UPDATE_FLAGS.
- T032 — Run bats → T009, T010 pass.

#### Phase 3e — `audit_scripts` (US-1, EF-004, EF-013)

- T033 — Implement `audit_scripts()` : grep `\./scripts/[a-z-]+\.sh` patterns, cross-check `ls scripts/*.sh`, EXCLUDE matches in `.claude/rules/**` files AND matches preceded by a URL scheme (http/https).
- T034 — Run bats → T011, T012, T018 pass.

#### Phase 3f — `audit_npm` (US-1, EF-005)

- T035 — Implement `audit_npm()` : grep `npm --prefix website run [a-z:-]+` and `(cd website && npm run [a-z:-]+)` patterns, cross-check KNOWN_NPM_SCRIPTS.
- T036 — Run bats → T013, T014 pass.

#### Phase 3g — Wire up dispatcher (US-8, EF-008)

- T037 — Implement `main()` : call each audit_X in sequence ; respect env-var skips ; respect `--category` flag ; print summary at end.
- T038 — Run bats → ALL category tests + T016 (env-var skip) pass. T017 (zero-FP) is the next target.

**Checkpoint**: GREEN per category. ≥14/15 bats green.

### Phase 4 — Integrate into `audit-base.sh`

- T039 — In `scripts/audit-base.sh`, add `audit_docs_drift()` function that calls `"$SCRIPT_DIR/audit-docs.sh"` and bubbles its exit code into `audit-base.sh`'s exit accumulation.
- T040 — Call `audit_docs_drift` from the main flow, between `audit_doc_links` and `audit_counts`.
- T041 — Run `./scripts/audit-base.sh` ; expect : if `audit-docs.sh` is clean, audit-base unchanged ; if drift, audit-base also fails.

### Phase 5 — Zero false-positive verification (EF-012, T017)

**Goal**: confirm current `main` produces zero drift.

- T042 — Run `./scripts/audit-docs.sh` on current branch ; capture full output.
- T043 — If exit 0 + no drift listed : T017 passes → proceed to Phase 6.
- T044 — If exit 1 or drift listed : EITHER extend the allowlist (legitimate omission discovered) OR fix the underlying doc drift (legitimate finding). Iterate until zero-FP.

**Checkpoint**: T017 passes. `audit-docs.sh` is silent-clean on the foundation.

### Phase 6 — Regen + CHANGELOG + pre-commit guards

- T045 — Run `npm --prefix website run generate` (tests count auto-bumped via the +new bats tests).
- T046 — Verify : `validate-counts.sh` exit 0, `audit-base.sh` exit 0 (now includes `audit_docs_drift` step).
- T047 — Add CHANGELOG bullet under `[Unreleased] / ### Added`.
- T048 — Grep diff for protected end-user project names ; expect empty.

### Phase 7 — Commits + push + PR + watch + merge

- T049 — 2 commits per `feedback_commit_splits` (test→feat split):
  - Commit A: `test(audit): add RED tests for doc drift firewall`
  - Commit B: `feat(audit): add audit-docs.sh + integrate into audit-base.sh`
- T050 — `git push -u origin HEAD`.
- T051 — `gh pr create` (NO inner double quotes in title per `feedback_pr_title_no_quotes`).
- T052 — Watch CI via `gh pr checks <N> --watch --fail-fast` (with sleep 10 first).
- T053 — On all-green: `gh pr merge <N> --squash --delete-branch`.

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Zero-FP target fails because the foundation has undetected drift today | High | Medium | Phase 5 explicit gate ; if drift found, fix-in-place OR extend allowlist with rationale ; never silence by relaxing the audit |
| `claude-base preset list` / `claude-base preset show` sub-verbs flagged as unknown | Medium | High | Pattern matches `claude-base <top-verb>` only ; `preset list`/`show` is `claude-base preset` (verb=preset) followed by `list` arg ; arg-after-verb not in scope |
| Allowlist drifts from real code over time (someone adds a flag without updating audit-docs.sh) | High | Medium | Documented in EF-002 / EF-003 ; mitigation : the audit IS the enforcement — first PR using the new flag fails the audit, the maintainer adds it to the allowlist as part of the same PR |
| `grep` regex escapes break on macOS BSD grep vs GNU grep | Medium | Medium | Use `grep -E` (extended regex) which is portable ; avoid `\b` boundaries which differ ; verify on macOS CI run |
| Runtime > 5s on full repo | Low | Low | Cache `enumerate_scope_files()` output, avoid re-greping the same file 5 times — single pass per file with multi-pattern grep if needed |
| `--style` flag in init might collide with prose `--style of the project` | Low | Low | Pattern matches `claude-base init --style` (anchored on `init`), not bare `--style` |
| New flag `--foo` is added to `new-project.sh` but the audit doesn't catch its absence from docs | N/A | — | Out of scope — the audit detects unknown flags in docs, not missing-from-docs flags. Inverse check (real flag → missing from docs) is a separate spec |
| Bats test for env-var hatch fails because subshell isn't inheriting | Medium | Medium | Use `env AUDIT_DOCS_SKIP_PATHS=1 ./scripts/audit-docs.sh` in bats fixture, not raw assignment |
| Regression test fixture (PR #199 scenario) accidentally introduces real drift in main | High | Low | Use temp-dir fixtures via `$TEST_DIR`, never edit real docs |

---

## Dependencies and Execution Order

```
Phase 1 (T001-T003) ◄── BLOCKS everything
       │
       ▼
Phase 2 (T004-T019) — TDD RED — ≥15 tests fail
       │
       ▼
Phase 3a (T020-T026) — Skeleton + env vars + scope helper
       │
       ▼
Phase 3b-f (T027-T036) — 5 audit functions, one at a time
       │
       ▼
Phase 3g (T037-T038) — Wire up dispatcher ; ≥14/15 tests green
       │
       ▼
Phase 4 (T039-T041) — Integrate into audit-base.sh
       │
       ▼
Phase 5 (T042-T044) — Zero-FP verification (CRITICAL)
       │
       ▼
Phase 6 (T045-T048) — Regen + CHANGELOG + guards
       │
       ▼
Phase 7 (T049-T053) — Commits + PR + merge
```

### Story dependencies

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US-1 (drift caught) | Phase 3g | All 5 categories in place |
| US-2 (clear errors) | Phase 3a | report_drift function shape locked |
| US-3 (audit-base integration) | Phase 4 | T039-T041 |
| US-4 (allowlist extend) | Phase 3a | Locked in arrays at top of script |
| US-5 (env var hatch) | Phase 3a | T021 + per-category guards |
| US-6 (regression tests) | Phase 2 | T015 (PR #199) + T009 (unknown flag) cover the shapes |
| US-7 (--verbose) | Phase 3a | T022 — argument parsing |
| US-8 (--category) | Phase 3g | T037 dispatcher |

### Parallelization opportunities

- T020-T026 (skeleton) is sequential.
- T027-T036 (5 audit functions) are independent — could theoretically be developed in parallel by 5 devs, but solo a sequential walk is simpler.
- T045-T048 (regen + CHANGELOG + guards) are 3-4 independent steps.

---

## Validation Criteria

### Gate 1 — Before starting
- [ ] All 3 clarifications resolved (spec §"Locked decisions")
- [ ] Allowlists locked at plan time (this doc)
- [ ] CI baseline captured

### Gate 2 — Mid-implementation (after Phase 3g)
- [ ] All 5 category-specific bats tests pass
- [ ] Env-var hatch test passes
- [ ] Regression test (PR #199 path) passes
- [ ] Baseline bats tests (87+ existing) still pass

### Gate 3 — Mid-implementation (after Phase 5)
- [ ] T017 (zero-FP on real repo) passes
- [ ] Any drift detected on `main` is either : a real bug fixed in-place, OR a legitimate allowlist omission added

### Gate 4 — Before commit (after Phase 6)
- [ ] All ≥15 new bats tests pass
- [ ] `./scripts/audit-base.sh` exits 0 (now includes new step)
- [ ] `./scripts/validate-counts.sh` exits 0
- [ ] `counts.json#tests` reflects new tests (auto-regen)
- [ ] Grep on protected names returns empty
- [ ] No file outside `scripts/`, `tests/`, `CHANGELOG.md`, `counts.json`, `README.md` (auto-badge) modified

### Gate 5 — Before merge
- [ ] CI green on Ubuntu + macOS Lint & Test (note: macOS uses BSD grep, watch for regex incompatibility)
- [ ] Validate PR check green
- [ ] No broken Docusaurus link

---

## Notes

- **Workflow scale**: medium. Single feature, 1 new script + 1 modified script + 1 new bats file. ~3-4h focused work.
- **TDD genuine** : 5 audit functions are pure logic, well-suited to bats.
- **Zero-FP gate is the hardest** : if current `main` produces drift, that itself is a finding ; spec EF-012 says zero drift. Phase 5 explicitly addresses this.
- **macOS portability** : `grep -E` on macOS BSD differs from GNU grep ; CI macOS run is the canary. Per `feedback_bsd_seq_zero_range`, don't trust GNU-only patterns.
- **Memory anchors used in plan**: `feedback_verify_code_claims` (allowlists derived from grep), `feedback_bsd_seq_zero_range` (loop guards), `feedback_pr_title_no_quotes` (PR title shape), `feedback_no_project_names` (T048).

**To avoid**:
- Implementing any `audit_X` function before its bats tests fail (TDD violation)
- Silencing a real drift detected in Phase 5 by extending the allowlist without rationale
- Adding a category to the script that isn't in the spec EF list
- Editing real docs in tests (always use `$TEST_DIR` heredoc fixtures)
- Renaming files / restructuring `audit-base.sh` beyond adding the new function

---

**Version**: 1.0 | **Created**: 2026-05-19
