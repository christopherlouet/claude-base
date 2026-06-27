# Tasks — Anti-tamper guardrails

Branch: `feat/anti-tamper-guardrails` · TDD: tests before code (Red→Green→Refactor).
Legend: `[P]` parallelizable · `[US?]` traceability.

## Phase 0 — verify assumptions (do first, cheap)

- **T001** `[US1]` Capture a REAL MultiEdit payload shape — confirm `.tool_input.file_path`
  is present (and the field name for Edit/Write/MultiEdit). If different, adjust the plan's
  field. (Quick: inspect docs or craft a MultiEdit and log stdin.)

## Phase 1 — US-2 block-no-verify (P1)

- **T010** `[US2]` RED: add cases to `tests/command-validator.bats`:
  - blocks `git commit --no-verify -m x` (exit 2)
  - blocks `git push --no-verify`
  - blocks `git commit -n -m x` (standalone short no-verify)
  - does NOT block `grep -n foo file`, `git log -n 5`, `echo -n hi` (exit 0)
  - does NOT block `git commit -m "fix --no-verify mention"` (flag only in message)
- **T011** `[US2]` GREEN: add `# === CATEGORY 9: Verification bypass ===` to
  `scripts/hooks/command-validator.sh` before the final `exit 0`; anchor `-n` to
  `git commit` context. Reuse `SKIP_COMMAND_VALIDATOR=1` (already at top).
- **T012** `[US2]` shellcheck command-validator.sh; run `tests/command-validator.bats` green.

## Phase 2 — US-1 config-protection (P1) + US-4 (P3, folded)

- **T020** `[US1][US4]` RED: write `tests/config-protection.bats` (hermetic, craft stdin JSON):
  - blocks editing an EXISTING `.eslintrc.json` / `eslint.config.mjs` / `.prettierrc` /
    `biome.json` / `ruff.toml` / `.markdownlint.json` (exit 2)
  - ALLOWS creating a config that does NOT yet exist (exit 0) — EF-002
  - ignores a non-config file (exit 0)
  - `SKIP_CONFIG_PROTECTION=1` → exit 0 even on a config
  - `[US4]` does NOT block `eslint-config-guide.md` (basename ≠ config) nor a config
    under `tests/`/`fixtures/`/`examples/` (excluded dir)
  - does NOT block `pyproject.toml` / `tsconfig.json` (out of scope)
  - jq-absent path does not crash (fail-safe)
  - MultiEdit payload with `.tool_input.file_path` on a config → exit 2
- **T021** `[US1]` GREEN: implement `scripts/hooks/config-protection.sh`
  (`set -euo pipefail`; stdin→jq `.tool_input.file_path`; SKIP env; excluded-dir guard;
  basename match vs recognized set; existence check → block only if exists). Make executable.
- **T022** `[US1]` shellcheck config-protection.sh; run `tests/config-protection.bats` green.
- **T023** `[US1]` Register in `.claude/settings.json` PreToolUse:
  `{ "description":"Block edits to existing linter/formatter configs (disable with SKIP_CONFIG_PROTECTION=1)", "matcher":"Edit|Write|MultiEdit", "hooks":[{ "type":"command","command":"bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/config-protection.sh\"","timeout":5000,"onFailure":"block" }] }`.
  Validate `jq . .claude/settings.json`.

## Phase 3 — US-3 docs + toggles (P2)

- **T030** `[US3]` `docs/reference/hooks-reference.md`: add a Configured Hooks row
  (**Config protection** | PreToolUse (Edit/Write/MultiEdit) | …`SKIP_CONFIG_PROTECTION=1`);
  add env-var rows `SKIP_CONFIG_PROTECTION=1`; note `--no-verify` on the Command validator row.
- **T031** `[US3]` Confirm both disable switches are covered by a test (already in T010/T020).

## Phase 4 — Audit & ship

- **T040** Manual smoke: pipe crafted JSON into each hook, assert exit codes (config edit→2,
  create→0; `--no-verify`→2, `grep -n`→0).
- **T041** Full `./scripts/test.sh` (or targeted bats) + `shellcheck scripts/hooks/*.sh`.
- **T042** `validate-counts.sh` green (the #408 pre-commit will have staged regenerated
  markers when the new .bats files are committed).
- **T043** `/qa:qa-loop "score 90"`.
- **T044** Commit (Conventional, no AI attribution) → PR to main.

## Ordering / parallelism

- T001 first (de-risks T020/T021/T023).
- Phase 1 (US-2) and Phase 2 (US-1) are **independent** → `[P]` across phases once T001 done.
- Phase 3 docs after both hooks exist. Phase 4 last.

## Definition of Done

- All spec acceptance criteria (US-1/US-2) pass as bats tests; US-4 negatives green.
- shellcheck clean; settings.json valid; both `SKIP_*` toggles verified.
- `validate-counts.sh` green; full suite green on Linux + macOS in CI.
- qa-loop ≥ 90. PR opened.
