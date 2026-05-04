# Tasks: PostToolUse output rewriter (Bash filter + inline TS errors)

**Branch**: `feature/hook-output-rewriter`
**Plan**: [plan.md](./plan.md)

Conventions: `T###` task ID, `[P]` parallelizable inside the same phase, `[USX]` user story trace.

Phase 2 and Phase 3 are independent and can run in parallel after Phase 1 completes.

---

## Phase 1 — Foundation: helpers + capability probe (1h)

- **T001** [US5] Create `scripts/hooks/_hook-helpers.sh` with sourceable functions: `hook_bail_if_disabled <env_var>`, `hook_read_stdin_json` (echoes parsed JSON or bails), `hook_emit_envelope <event_name> <key> <value>` (wraps with `jq -Rs`), `hook_strip_ansi`. Header notes: NOT a hook by itself; sourced by other hooks.
- **T002** [US5] Create `scripts/hooks/check-cli-version.sh` (SessionStart hook). Reads `claude --version`, parses semver, compares to `2.1.121`. If unsupported: prints one-line notice and exits 0 without setting envelope. If supported: emits envelope with `additionalContext` setting `CLAUDE_REWRITER_SUPPORTED=1` (or alternative mechanism per Claude Code's actual env-var passing model — verify with a probe in T003).
- **T003** [US5] Probe in a sandbox: confirm whether SessionStart hooks can set persistent env vars for the session via `hookSpecificOutput`. If not, fall back to a sentinel file at `/tmp/claude-rewriter-supported-${PPID}` checked by downstream scripts. Document the chosen mechanism in `_hook-helpers.sh` header.
- **T004** [US5] Add SessionStart hook entry in `.claude/settings.json` calling `check-cli-version.sh` (timeout 2000ms).
- **T005** [US5] [P] Create `tests/hook-output-rewriter.bats` skeleton with `setup()` creating tmp dirs + `teardown()` cleanup; first test asserts `_hook-helpers.sh` is sourceable and exposes the documented functions.
- **T006** [US5] [P] Add bats tests for `check-cli-version.sh`: (a) supported version → exit 0 + correct envelope; (b) unsupported version → notice on stdout + no envelope; (c) `claude --version` returns garbage → silent fallback to unsupported.
- **T007** [US5] Run `shellcheck scripts/hooks/_hook-helpers.sh scripts/hooks/check-cli-version.sh` → exit 0.
- **T008** [US5] Phase 1 acceptance: `bats tests/hook-output-rewriter.bats -f "Phase 1"` 100% green; `shellcheck` clean on the 2 new scripts.

## Phase 2 — Bash output filter (4h) [P with Phase 3]

### Script body (T010-T017)

- **T010** [US1] Create `scripts/hooks/bash-output-filter.sh` with: shebang, `set -u`, source `_hook-helpers.sh`, bail-out chain (capability, `SKIP_BASH_OUTPUT_FILTER`, missing jq, empty stdin, parse failure).
- **T011** [US1] Implement allowlist matcher: regex array covering `npm install`, `npm audit`, `npm ci`, `npm test`, `npm run build`, `pnpm install`, `pnpm audit`, `pnpm test`, `pnpm run build`, `yarn install`, `yarn add`, `yarn test`, `yarn run build`, `bun install`, `bun add`, `bun test`, `bun run build`, `pytest`, `go test`, `go build`, `cargo build`, `cargo test`, `cargo check`. Function `is_command_allowlisted <cmd>`.
- **T012** [US1] Implement threshold guard: if input has < 30 lines (configurable via `BASH_OUTPUT_FILTER_THRESHOLD`, default 30), emit no envelope (passthrough).
- **T013** [US1] Implement ANSI stripping using `_hook-helpers.sh` helper.
- **T014** [US1] Implement extraction logic per command shape:
  - `npm install` / `pnpm/yarn/bun install` → keep "added/removed/changed" summary, vulnerabilities line, errors, exit code.
  - `npm audit` → keep severity counts, total vulnerabilities, top-N findings (cap at 10), exit code.
  - `npm test` / equivalents → keep test summary lines (passed/failed/skipped/total), failure blocks (test name + first 5 lines of error), exit code.
  - `npm run build` → keep error/warning lines + last 20 lines on non-zero exit.
  - `pytest` → keep `=== FAILURES ===` block, summary, exit code.
  - `go test` → keep `--- FAIL` blocks, `FAIL` summary, `ok` lines, exit code.
  - `cargo build` / `cargo test` → keep `error[E...]:` blocks, warnings, summary, exit code.
- **T015** [US1] Implement non-zero exit safety: when exit code ≠ 0, always include the last 20 lines of output (FR-2).
- **T016** [US4] Implement verbose mode: if `BASH_OUTPUT_FILTER_VERBOSE=1`, append `\n--- Original output ---\n<raw>` after the trimmed view.
- **T017** [US6] Implement metric logging: append `<ISO8601> tool=Bash cmd=<short> orig_lines=<n> filtered_lines=<m> ratio=<n/m>` to `/tmp/claude-rewriter.log` (best-effort, redirect errors to /dev/null).

### Wiring (T018)

- **T018** [US1] Add PostToolUse Bash hook entry in `.claude/settings.json` calling `bash-output-filter.sh` (timeout 5000ms, onFailure: ignore). Position: AFTER all the existing PreToolUse Bash hooks fire (PostToolUse) and BEFORE any other PostToolUse Bash hook (none today).

### Fixtures (T020-T029)

- **T020** [US1] [P] Create fixture `npm-install-clean.in.txt` (~150 lines real capture) + `.expected.txt` (~5 lines: added/removed/audited + exit 0).
- **T021** [US1] [P] Create fixture `npm-install-warnings.in.txt` + `.expected.txt`.
- **T022** [US1] [P] Create fixture `npm-audit-vulns.in.txt` (~180 lines) + `.expected.txt` (≤25 lines, all severity lines preserved). This pair backs SC-1.
- **T023** [US1] [P] Create fixture `npm-audit-clean.in.txt` (under threshold, passthrough) + `.expected.txt` identical to input.
- **T024** [US1] [P] Create fixture `npm-test-fail.in.txt` (jest output with 3 failures) + `.expected.txt` (failures + summary).
- **T025** [US1] [P] Create fixture `npm-test-pass.in.txt` + `.expected.txt`.
- **T026** [US1] [P] Create fixture `npm-build-fail.in.txt` (webpack/vite failure) + `.expected.txt`.
- **T027** [US1] [P] Create fixture `pnpm-install.in.txt` + `.expected.txt`.
- **T028** [US1] [P] Create fixture `pytest-fail.in.txt` + `.expected.txt`.
- **T029** [US1] [P] Create fixture `go-test-fail.in.txt` + `.expected.txt`.

### Tests (T040-T044) — owned by Phase 2 even though numbered later

- **T040** [US1] Add bats tests parameterized over the 10 fixture pairs: each pair is one bats test; test asserts byte-equality between `bash-output-filter.sh < <(in.txt envelope wrapper)` and the expected output.
- **T041** [US3] Bats test: `SKIP_BASH_OUTPUT_FILTER=1` → script exits 0 with no envelope, regardless of input.
- **T042** [US4] Bats test: `BASH_OUTPUT_FILTER_VERBOSE=1` → output contains both trimmed view AND `--- Original output ---` delimiter AND raw input.
- **T043** [US1] Bats test: command outside allowlist (e.g. `ls -la`) → exits 0 with no envelope.
- **T044** [US6] Bats test: after a successful filter run, `/tmp/claude-rewriter.log` contains a new line matching the expected metric format.

### Phase 2 acceptance

- **T045** [US1] `bats tests/hook-output-rewriter.bats -f "Phase 2"` 100% green (10 fixture tests + 5 cross-cutting tests).
- **T046** [US1] `shellcheck scripts/hooks/bash-output-filter.sh` exit 0.
- **T047** [US1] SC-1 numerical check: on `npm-audit-vulns` fixture, filtered view ≤ 25 lines and contains 100% of severity/vulnerability lines (asserted in bats).

## Phase 3 — Inline edit errors (3h) [P with Phase 2]

### Script body (T030-T036)

- **T030** [US2] Create `scripts/hooks/post-edit-typecheck-and-lint.sh` with: shebang, `set -u`, source `_hook-helpers.sh`, bail-out chain (capability, `SKIP_INLINE_EDIT_ERRORS`, missing jq, empty stdin, file_path missing, file extension not in `.ts/.tsx/.js/.jsx`).
- **T031** [US2] Implement file-ext routing: TS/TSX runs both tsc + eslint; JS/JSX runs eslint only.
- **T032** [US2] Implement tsc invocation: `if [ -f tsconfig.json ] && [ -f node_modules/.bin/tsc ]; then npx tsc --noEmit 2>&1 | grep -F "$file_path" | head -20; fi`. Capture into `TSC_OUTPUT`.
- **T033** [US2] Implement eslint invocation: `if [ -f node_modules/.bin/eslint ]; then npx eslint "$file_path" --max-warnings 0 2>&1 | head -20; fi`. Capture into `ESLINT_OUTPUT`.
- **T034** [US2] If both `TSC_OUTPUT` and `ESLINT_OUTPUT` are empty: exit 0 with no envelope (FR-9).
- **T035** [US2] Build annotated `updatedToolOutput`: take the original `tool_response` from stdin, append `\n\n--- Type errors (tsc) ---\n<TSC_OUTPUT>` and/or `\n\n--- Lint errors (eslint) ---\n<ESLINT_OUTPUT>`. Status remains SUCCESS (FR-6 clarified).
- **T036** [US2] Implement legacy-state detection (FR-22): on first run per session, check whether `.claude/settings.json` still references the old inline `npx tsc --noEmit 2>&1 | head -20` pattern. If yes, `echo` a one-line notice once (sentinel at `/tmp/claude-socle-legacy-warned-${PPID}`).

### Wiring (T037)

- **T037** [US2] Edit `.claude/settings.json`: REMOVE the two inline PostToolUse Edit\|Write hooks "Type-check TypeScript after modification" and "ESLint check after JS/TS modification" (lines 232-251 in current file). REPLACE with one entry calling `post-edit-typecheck-and-lint.sh` (timeout 30000ms, onFailure: ignore). Verify the auto-format hook still fires BEFORE this one (so prettier writes the file before tsc reads it).

### Fixtures (T050-T054)

- **T050** [US2] [P] Create fixture `tsc-single-error.in.txt` (raw tsc output mentioning `src/foo.ts`) + `.expected.txt` (the same error block, formatted).
- **T051** [US2] [P] Create fixture `tsc-multi-errors.in.txt` (3 errors in same file) + `.expected.txt`.
- **T052** [US2] [P] Create fixture `tsc-other-file.in.txt` (errors in `src/bar.ts` while edit was on `src/foo.ts`) + `.expected.txt` (empty / unchanged tool_response — these errors are NOT pulled in per FR-6).
- **T053** [US2] [P] Create fixture `eslint-single.in.txt` + `.expected.txt`.
- **T054** [US2] [P] Create fixture `tsc-and-eslint.in.txt` + `.expected.txt` (both sections appended in order).

### Tests (T055-T059)

- **T055** [US2] Bats parameterized test over the 5 inline-edit fixture pairs.
- **T056** [US3] Bats test: `SKIP_INLINE_EDIT_ERRORS=1` → script exits 0 with no envelope (legacy stdout path takes over).
- **T057** [US2] Bats test: edit on `.py` file → script exits 0 (out of scope, FR-9 deferred to follow-up).
- **T058** [US2] Bats test: legacy-state detection — synthetic settings.json with old inline blocks → notice emitted once on first invocation, NOT on subsequent.
- **T059** [US2] Phase 3 acceptance: `bats tests/hook-output-rewriter.bats -f "Phase 3"` 100% green; `shellcheck scripts/hooks/post-edit-typecheck-and-lint.sh` exit 0.

## Phase 4 — Migration & docs (1h)

- **T060** [US-N/A] Update `scripts/update.sh` line 539 prompt copy: `"Update .claude/settings.json?"` → `"Update .claude/settings.json? (recommended for this release — adds output rewriter)"`. Default stays "n". Verify `bats tests/update.bats` still green.
- **T061** [US-N/A] Update `docs/reference/hooks-reference.md`:
  - Add new section "Output rewriter (CLI 2.1.121+)" describing the 3 new hooks
  - Add `SKIP_BASH_OUTPUT_FILTER`, `SKIP_INLINE_EDIT_ERRORS`, `BASH_OUTPUT_FILTER_VERBOSE`, `BASH_OUTPUT_FILTER_THRESHOLD` to `## Hook Environment Variables`
  - Add `/tmp/claude-rewriter.log` to `## Log Files`
  - Mention in the Configured Hooks table the 3 new entries (replacing the 2 inline tsc/eslint rows)
- **T062** [US-N/A] Update `CHANGELOG.md` `## [Unreleased]`:
  - Added: "PostToolUse output rewriter — trims noisy Bash command outputs and inlines tsc/eslint errors into Edit/Write results (requires Claude Code 2.1.121+)"
  - Changed: "Consolidated the inline tsc + eslint PostToolUse hooks into a single script for clearer flow and exact-output rewriting"
  - Migration note: "Existing projects: run `./scripts/update.sh -f --all <project>` to get the new hooks. Partial updates are detected at runtime and the foundation falls back to legacy behavior with a one-line notice."
- **T063** [US-N/A] [P] Verify `validate-counts.sh` and `audit-socle.sh` are unaffected (no agent/command/skill/rule added). Run both, expect exit 0.
- **T064** [US-N/A] Manual: open a fresh terminal, run `./scripts/update.sh --dry-run --all /path/to/test-project` → confirm new prompt copy is shown for settings.json.

## Phase 5 — Audit & manual validation (1h)

- **T065** [US-N/A] Manual session A (supported CLI): start `claude` in this repo, trigger an `Edit` on a tmp `.ts` file with a type error → confirm tsc errors appear in the SAME Edit tool result (not as a side message). Then ask Claude to run `npm audit` in a tmp Node project with vulns → confirm trimmed view.
- **T066** [US-N/A] Manual session B (disabled): export `SKIP_INLINE_EDIT_ERRORS=1` and `SKIP_BASH_OUTPUT_FILTER=1`; repeat session A → confirm legacy behavior (stdout side messages, full Bash output).
- **T067** [US-N/A] Manual session C (legacy settings.json): clone repo to `/tmp/test-legacy`, restore the pre-PR `.claude/settings.json`, install only the new hook scripts → start `claude`, edit a TS file with an error → confirm the FR-22 notice fires once, then legacy stdout behavior takes over.
- **T068** [US-N/A] Performance check: synthesize a 10000-line input, pipe through `bash-output-filter.sh`, time it. Assert ≤ 200ms (FR-17).
- **T069** [US-N/A] Capture one transcript snippet of the trimmed view in action — paste into the PR description as evidence for SC-1.

## Acceptance gate

Before opening the PR:

- [ ] T001-T069 all completed
- [ ] `bats tests/hook-output-rewriter.bats` 100% green (15 fixture pairs + ~10 cross-cutting tests)
- [ ] `bats tests/*.bats` (full suite) still green — no regression
- [ ] `shellcheck scripts/hooks/*.sh` exit 0
- [ ] `bash scripts/validate-counts.sh` exit 0
- [ ] `bash scripts/audit-socle.sh` exit 0
- [ ] Manual sessions A, B, C all behave per spec
- [ ] CHANGELOG entry written and consistent with FR-21
- [ ] PR description includes 1 transcript snippet for SC-1
