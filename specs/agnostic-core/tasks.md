# Tasks: Agnostic Core Extraction (P1 delivery)

**Input**: Design documents from `specs/agnostic-core/`
**Prerequisites**: plan.md, spec.md

Task format: `[ID] [P?] [US?] Description` — [P] = parallelizable, [US?] = traceability.

---

## Phase 0: Baseline

- [ ] T001 — CI baseline: run full bats suite, record count and any pre-existing failures
- [ ] T002 — Audit `set -e`/`set -u` posture + jq fallbacks of the 8 target hooks (`scripts/hooks/{command-validator,secret-scan,destructive-ops,destructive-migration,bash-write-guard,pre-commit-tests,pre-push-ci,pre-deploy-build}.sh`) so sourcing libs cannot change behavior

## Phase 1: Foundation (blocking)

- [ ] T003 — [US1] Create `scripts/hooks/_core-helpers.sh`: relocate `strip_msg_values` from `_hook-helpers.sh` (which now sources it — single canonical copy preserved); direct tests in `tests/policy-structure.bats` scaffold + existing suite green

## Phase 2: US-1/US-2 — guard slices (TDD per slice: core tests RED → extract verbatim → shells GREEN)

- [ ] T004 — [US1][US2] Dangerous-commands slice: tests `tests/policy-dangerous-commands.bats` (direct corpus, no envelope) → `scripts/hooks/_policy-dangerous-commands.sh` (`validate_command()`, 9 category tables moved verbatim) → `command-validator.sh` reduced to thin shell
- [ ] T005 — [P] [US1][US2] Secrets slice: `tests/policy-secrets.bats` → `scripts/hooks/_policy-secrets.sh` (`scan_content_for_secrets()`, patterns + placeholder allowlist) → `secret-scan.sh` thin shell
- [ ] T006 — [P] [US1][US2] Destructive-SQL slice: `tests/policy-destructive-sql.bats` → `scripts/hooks/_policy-destructive-sql.sh` (command variant + migration-file variant) → `destructive-ops.sh` + `destructive-migration.sh` thin shells
- [ ] T007 — [P] [US1][US2] Write-targets slice: `tests/policy-write-targets.bats` → `scripts/hooks/_policy-write-targets.sh` (redirect/tee/sed -i/cp/dd target extraction) → `bash-write-guard.sh` thin shell
- [ ] T008 — [P] [US1][US2] Triggers slice: `tests/policy-triggers.bats` (incl. argument-ordering variants per lessons) → `scripts/hooks/_policy-triggers.sh` (`is_commit_command`/`is_push_command`/`is_deploy_command`) → 3 gate hooks use it

## Phase 3: US-3 — install integrity

- [ ] T009 — [US3] Add the 6 new `_*.sh` libs to `scripts/lib/minimal-manifest.txt`; `tests/manifest-hooks-coverage.bats` green
- [ ] T010 — [US3] Fresh-install self-application test: `claude-base init` into a temp dir, replay a deny/allow sample through the installed hooks, assert identical verdicts (extends an existing init test file or new `tests/policy-install.bats`)

## Phase 4: Contract + portability map

- [ ] T011 — [P] Write `specs/agnostic-core/adapter-contract.md` (inputs, verdict translation incl. exit-2 and JSON-deny styles, install wiring) — doc only
- [ ] T012 — [P] [US5] Write `specs/agnostic-core/portability-map.md` (per-hook classification) + drift check in `tests/policy-structure.bats` (every `scripts/hooks/*.sh` listed)

## Phase 5: Polish & Quality

- [ ] T013 — [US1] Structural invariants in `tests/policy-structure.bats`: (a) no category/pattern tables left in shells; (b) core files contain no harness tokens (`tool_input`, `hookSpecificOutput`, `exit 2`, `CLAUDE_`); (c) portability-map coverage
- [ ] T014 — Docs sync: `docs/reference/hooks-reference.md` core/shell note; run counts self-heal
- [ ] T015 — Audit: code review high + adversarial verify; fix loop to score 90
- [ ] T016 — PR (Conventional Commits, English, no AI attribution)

---

## Dependencies

```
T001,T002 ──▶ T003 ──▶ T004 ──▶ T005..T008 [P] ──▶ T009,T010 ──▶ T011,T012 [P] ──▶ T013..T016
```

T004 first among slices (settles the verdict/API conventions the other slices copy).

---

**Version**: 1.0 | **Created**: 2026-07-17
