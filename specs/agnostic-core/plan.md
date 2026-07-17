# Implementation Plan: Agnostic Core Extraction

**Branch**: `feature/agnostic-core-extraction`
**Date**: 2026-07-17
**Spec**: [spec.md](./spec.md)
**Status**: In progress

---

## Summary

Extract the harness-neutral decision logic ("policy core") of the safety guards out of the Claude-Code-facing hook scripts, leaving each hook as a thin shell (read harness input → call core → translate verdict). Zero behavior change: the full existing suite must pass unmodified. Deliver P1 (guards core) in this PR; P2 (installer seam) and further work ship separately.

---

## Technical Context

| Aspect | Choice | Notes |
|--------|--------|-------|
| **Language/Version** | Bash (macOS 3.2-compatible) | Existing hard constraint; no assoc arrays, ASCII in executed strings |
| **Framework** | none | plain shell + jq (with existing no-jq fallbacks) |
| **Main dependencies** | jq (optional), gitleaks (optional) | unchanged |
| **Tests** | bats (`tests/*.bats`, suite ~1787) | new direct core tests are additive |
| **Target platform** | Linux + macOS CI | existing matrix |

### Constraints

- `init`/`update` copy hooks with a **flat glob** `cp scripts/hooks/*.sh` (`scripts/new-project.sh:1198-1207`) → core libs MUST be flat `_`-prefixed files in `scripts/hooks/`, no subdirectory.
- Every new file must be added to `scripts/lib/minimal-manifest.txt` (drift guard: `tests/manifest-hooks-coverage.bats`).
- Single-copy rule: `strip_msg_values` and path classifiers must keep exactly one canonical definition (divergent copies shipped bugs — see `_hook-helpers.sh` header).
- No competitor-product names in code; neutral "core/policy vs shell/harness" vocabulary.
- Counts gate: new test files change counters — pre-commit self-heal regenerates.

### Verdict convention (core API)

A core policy function takes plain inputs (command string, file path, content), prints the human-readable deny reason on stdout, and returns non-zero on deny / zero on allow. No stdin parsing, no `exit`, no stderr, no harness JSON anywhere in core files. Shells own: stdin envelope parsing, `exit 2` + stderr (Claude Code convention), and any future harness translation.

---

## Constitution/Conventions Check

- [x] Follows project conventions (existing `_`-prefixed lib pattern: `_hook-helpers.sh`, `_sensitive-paths.sh`)
- [x] Consistent with existing architecture (extends the already-started shared-lib seed)
- [x] No over-engineering (no emitter, no second harness, no speculative abstraction — only the seam the spike proved is needed)
- [x] Tests planned (direct core tests + existing suite as regression oracle)

---

## Project Structure

### Documentation (this feature)

```
specs/agnostic-core/
├── spec.md               # Functional specification
├── plan.md               # This file
├── tasks.md              # Task breakdown
├── adapter-contract.md   # What a new harness shell must implement (CS-004)
└── portability-map.md    # Per-component portable/harness-only classification (P3)
```

### Source Code (P1 layout)

```
scripts/hooks/
├── _core-helpers.sh                 # NEW: strip_msg_values + shared core utilities (relocated)
├── _policy-dangerous-commands.sh    # NEW: 9-category tables + validate_command()
├── _policy-secrets.sh               # NEW: secret patterns + scan function
├── _policy-destructive-sql.sh       # NEW: DDL/DELETE policy (shared: ops + migration)
├── _policy-write-targets.sh         # NEW: bash write-target extraction policy
├── _policy-triggers.sh              # NEW: commit/push/deploy trigger detection
├── _hook-helpers.sh                 # MOD: CC-glue helpers; sources _core-helpers.sh (compat)
├── _sensitive-paths.sh              # unchanged (already pure core)
├── command-validator.sh             # MOD: thin shell
├── secret-scan.sh                   # MOD: thin shell
├── destructive-ops.sh               # MOD: thin shell
├── destructive-migration.sh         # MOD: thin shell
├── bash-write-guard.sh              # MOD: thin shell
├── pre-commit-tests.sh              # MOD: trigger via _policy-triggers.sh
├── pre-push-ci.sh                   # MOD: trigger via _policy-triggers.sh
├── pre-deploy-build.sh              # MOD: trigger via _policy-triggers.sh
└── (assistant-only hooks unchanged: post-edit-typecheck-and-lint, bash-output-filter,
     check-cli-version, setup-deps, base-integrity-check, substance-check,
     main-branch-guard*, config-protection*, prompt-context*)
```

\* `config-protection` already delegates policy to `_sensitive-paths.sh`; `main-branch-guard` and `prompt-context` are classified in the portability map but not restructured in P1 (small/no policy tables to move, or P2+ candidates).

---

## Impacted Files

### To create

| File | Responsibility |
|------|----------------|
| `scripts/hooks/_core-helpers.sh` | Canonical `strip_msg_values` + shared pure utilities |
| `scripts/hooks/_policy-dangerous-commands.sh` | Dangerous-command categories + `validate_command()` |
| `scripts/hooks/_policy-secrets.sh` | Secret pattern table + `scan_content_for_secrets()` |
| `scripts/hooks/_policy-destructive-sql.sh` | Destructive DDL/DELETE detection (command + migration-file variants) |
| `scripts/hooks/_policy-write-targets.sh` | Extract write targets from bash commands (`>`, `tee`, `sed -i`, `cp`, `dd`) |
| `scripts/hooks/_policy-triggers.sh` | `is_commit_command()` / `is_push_command()` / `is_deploy_command()` |
| `specs/agnostic-core/adapter-contract.md` | Documented contract for any future harness shell |
| `specs/agnostic-core/portability-map.md` | Per-hook classification: core-extracted / assistant-only |

### To modify

| File | Modification |
|------|--------------|
| `scripts/hooks/command-validator.sh` | Becomes thin shell over `_policy-dangerous-commands.sh` |
| `scripts/hooks/secret-scan.sh` | Thin shell over `_policy-secrets.sh` |
| `scripts/hooks/destructive-ops.sh` | Thin shell over `_policy-destructive-sql.sh` |
| `scripts/hooks/destructive-migration.sh` | Thin shell over `_policy-destructive-sql.sh` |
| `scripts/hooks/bash-write-guard.sh` | Thin shell over `_policy-write-targets.sh` (+ `_sensitive-paths.sh`) |
| `scripts/hooks/pre-commit-tests.sh` | Trigger detection from `_policy-triggers.sh` |
| `scripts/hooks/pre-push-ci.sh` | Trigger detection from `_policy-triggers.sh` |
| `scripts/hooks/pre-deploy-build.sh` | Trigger detection from `_policy-triggers.sh` |
| `scripts/hooks/_hook-helpers.sh` | `strip_msg_values` moves to `_core-helpers.sh`; kept sourced for compat |
| `scripts/lib/minimal-manifest.txt` | Add the 6 new lib files |
| `docs/reference/hooks-reference.md` | Document the core/shell split (base-maintenance rule) |

### Tests to add

| File | Coverage |
|------|----------|
| `tests/policy-dangerous-commands.bats` | Direct verdicts on the deny/allow corpus (no envelope) |
| `tests/policy-secrets.bats` | Direct pattern matches + placeholder allowlist |
| `tests/policy-destructive-sql.bats` | Direct DDL/DELETE verdicts (command + migration content) |
| `tests/policy-write-targets.bats` | Direct target-extraction cases |
| `tests/policy-triggers.bats` | Trigger detection incl. argument-ordering variants |
| `tests/policy-structure.bats` | Structural guards: no policy tables left in shells; core files free of harness tokens (`tool_input`, `exit 2`, `hookSpecificOutput`); portability-map drift check |

---

## Chosen Approach

### Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Claude Code (today)              future harness (not in this PR)    │
│        │ stdin JSON                        │                         │
│        ▼                                   ▼                         │
│  SHELL: command-validator.sh        SHELL: <harness adapter>         │
│   - parse .tool_input.command        - parse its own envelope        │
│   - call core                        - call SAME core                │
│   - deny → stderr + exit 2           - deny → its own convention     │
│        │                                   │                         │
│        └───────────────┬───────────────────┘                         │
│                        ▼                                             │
│  CORE: _policy-*.sh  (pure functions: string in → verdict out)       │
│         _core-helpers.sh (strip_msg_values)  _sensitive-paths.sh     │
└──────────────────────────────────────────────────────────────────────┘
```

### Rationale

The repo already proved this pattern twice (`_hook-helpers.sh`, `_sensitive-paths.sh`) after divergent-copy bugs; the extraction completes it. Moving code **verbatim** (same regexes, same preprocessing order) into sourced functions, with the existing 1787-test suite as the regression oracle, minimizes behavioral risk. Flat `_`-prefix files inherit the install pipeline and manifest guards for free.

### Alternatives considered

| Alternative | Why rejected |
|-------------|--------------|
| `scripts/hooks/lib/` subdirectory | Flat `cp *.sh` in init would silently not ship it (known gotcha) |
| Rewrite guards in a portable language | Massive risk/effort, violates zero-behavior-change and minimal-code ladder |
| Extract only `command-validator` | Leaves 5 other guards welded; the deny-path seam is the same everywhere, cost is incremental |
| Do P2 (installer seam) in the same PR | Scope-management rule: separate concerns, one PR per focused change |

---

## Implementation Phases

### Phase 0: Baseline (blocking)

- [ ] T001 — CI baseline: full suite run, record count/failures pre-existing
- [ ] T002 — Verify jq-fallback paths and `set -u`/`set -e` posture of each target hook (sourcing must not change them)

### Phase 1: Core helpers foundation (blocking for US-1)

- [ ] T003 — `_core-helpers.sh` (strip_msg_values relocation, compat sourcing) + direct tests

### Phase 2: US-1/US-2 — per-guard extraction (TDD, one slice per guard family)

Each slice: RED = direct core tests written first from the existing corpus → GREEN = extract verbatim + wire shell → existing bats stay green.

- [ ] T004 — dangerous-commands slice (biggest)
- [ ] T005 — secrets slice
- [ ] T006 — destructive-sql slice (2 hooks, 1 core)
- [ ] T007 — write-targets slice
- [ ] T008 — triggers slice (3 gates)

### Phase 3: US-3 — install integrity

- [ ] T009 — manifest additions + manifest tests green
- [ ] T010 — fresh-install self-application test (init to temp dir → guards behave identically there)

### Phase 4: Contract + map (CS-004, P3)

- [ ] T011 — `adapter-contract.md`
- [ ] T012 — `portability-map.md` + drift check in `policy-structure.bats`

### Phase 5: Polish & Quality

- [ ] T013 — `policy-structure.bats` (no-policy-in-shells, no-harness-in-core)
- [ ] T014 — docs sync (`hooks-reference.md`), counts self-heal
- [ ] T015 — audit loop (code review + adversarial verify) until score 90
- [ ] T016 — PR

---

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Subtle verdict drift during move (preprocessing order, quoting, lowercase context) | High | Medium | Move verbatim; existing 1787 suite as oracle; direct core tests written BEFORE extraction from current behavior |
| New lib not shipped → orphan shell in installed projects | High | Medium | Flat `_` files + manifest additions + T010 fresh-install self-application test |
| `set -e`/`set -u` interaction when sourcing libs | Medium | Medium | T002 posture check; libs define functions only, no top-level commands |
| macOS bash 3.2 regressions | Medium | Low | Follow existing idioms; CI macOS matrix; no new constructs |
| Counts/docs gate breakage | Low | High | Pre-commit self-heal; T014 explicit sync |
| Scope creep into P2/emitter | Medium | Medium | Out-of-scope list in spec; P2 = separate PR |

---

## Dependencies and Execution Order

```
Phase 0 ──▶ Phase 1 (T003) ──▶ Phase 2 (T004..T008, sequential by slice; T005-T008 independent of each other after T003/T004 conventions settle)
Phase 2 ──▶ Phase 3 (T009-T010) ──▶ Phase 4 (T011-T012) ──▶ Phase 5
```

---

## Validation Criteria

### Gate 2 (before merge)
- [ ] Full suite green (≥ baseline count), zero modifications to existing assistant-facing tests
- [ ] `policy-structure.bats` green (thin-shell + core-purity invariants)
- [ ] Manifest + fresh-install self-application green
- [ ] Audit score ≥ 90

---

**Version**: 1.0 | **Created**: 2026-07-17
