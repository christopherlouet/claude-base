# Spec: PostToolUse output rewriter (filter Bash noise + inline TS errors)

**Status**: Draft
**Date**: 2026-05-04
**Owner**: Chris

---

## Summary

When Claude works inside a foundation-equipped project, two recurring frictions waste turns and tokens. First, noisy commands (`npm audit`, `npm install`, build/test runs, equivalents in pnpm/yarn/bun, pytest, go test, cargo) flood the conversation with hundreds of irrelevant lines that the model has to skim before reaching the actionable summary. Second, type errors and lint errors detected by the foundation's existing post-edit hooks (`tsc`, `eslint`) currently arrive as separate side messages, decoupled from the edit that introduced them — Claude needs an extra round to correlate "the file I just wrote" with "the errors that appeared right after".

This work makes both signals tighter. Noisy outputs come back trimmed to what is actionable. Type and lint errors come back attached to the very edit that triggered them. Both behaviors are opt-out via a single environment variable each, both bail out silently when their dependencies or runtime support are missing, and both leave the existing foundation behavior untouched when disabled.

The intent is not new tooling — it is to take the foundation's existing post-tool feedback (which already runs) and route it into the channel where it has the most leverage on Claude's next decision.

## Goals

- **Less conversation noise**: long, low-signal command outputs become short, signal-only views before Claude reads them.
- **Tighter feedback loop**: type/lint errors are surfaced inside the result of the edit that caused them, not as a delayed side note.
- **Off by absence**: any project that does not opt in (older CLI, missing tools, opt-out flag) behaves exactly like today.
- **Foundation idempotence**: `validate-counts.sh`, `audit-socle.sh`, the existing test suite, and CI all remain green with zero changes to public counters/catalogs.

## Non-goals

- Auto-fixing the surfaced errors. Surfacing only.
- Rewriting outputs of tools that already have first-class support upstream (MCP tools — covered natively).
- Rewriting `Read` or `Glob` outputs. Stay focused on the two cases with measurable value.
- Streaming or live partial outputs.
- Dashboards / UI for "tokens saved". A debug log line is enough; visualization is its own work.
- Proposing this as a public plugin/marketplace artifact. That belongs in the formalised plugin API workstream.
- Coverage of every language: case #2 stays scoped to the hook events the foundation already wires (TS/JS for tsc + eslint). Other languages stay deferred to a follow-up.

## User stories

### US-1 (P1) — Noisy commands return only what's actionable

**As a** developer using claude-socle on a Node/Python/Go project
**I want** outputs of `npm audit`, `npm install`, build, test, lint and equivalents to be trimmed to errors, warnings, counts and exit summary before Claude reads them
**So that** Claude doesn't waste turns parsing 200 lines of progress logs to find the one failure.

**Given** a project with `package.json`, **when** Claude runs `npm audit` and the underlying output is 180 lines, **then** the result the model observes contains the vulnerability summary lines, the severity counts and the exit-code summary, and is ≤ 25 lines long.

**Given** a project with `package.json`, **when** Claude runs `npm install` and the underlying output is 200 lines of fetch/extract progress, **then** the result the model observes contains only the final summary (added/removed/changed counts, vulnerabilities line, exit code).

**Given** the underlying command exits non-zero, **when** the rewriter runs, **then** the last lines of stderr that contain the failure cause are preserved verbatim, and the exit code is preserved.

### US-2 (P1) — Type and lint errors surface alongside the edit

**As a** developer using claude-socle on a TypeScript project
**I want** any new `tsc` or `eslint` errors detected by the foundation's existing post-edit hooks to appear as part of the same edit's result
**So that** Claude treats them as immediate consequences of the edit, not as a separate informational message that may scroll past.

**Given** a TypeScript project with the foundation's hooks active, **when** Claude edits a file and the edit introduces a type error, **then** the result Claude sees for the edit ends with the error block (file, line, message), with a clear separator, in the same tool result envelope.

**Given** the same setup, **when** the edit is clean, **then** the result Claude sees is unchanged from today.

**Given** an `eslint` error appears alongside a `tsc` error, **when** both hooks fire, **then** both error blocks are attached to the same edit result and de-duplicated (one section per tool).

### US-3 (P1) — A single switch turns each behavior off

**As a** developer who hits an unexpected interaction between the rewriter and a custom build setup
**I want** to disable each behavior with one environment variable
**So that** I can isolate the cause without uninstalling the foundation.

**Given** `SKIP_BASH_OUTPUT_FILTER=1` in the environment, **when** Claude runs any noisy command, **then** the output Claude observes is identical to running without the foundation hooks.

**Given** `SKIP_INLINE_EDIT_ERRORS=1` in the environment, **when** Claude edits a TS/JS file, **then** the edit result Claude observes is identical to running without the foundation hooks (existing tsc/eslint hooks may still log to stdout as today, but the edit envelope itself is untouched).

### US-4 (P2) — A verbose mode keeps the original output

**As a** developer debugging a build issue
**I want** a flag that preserves the raw output for the next session
**So that** I can read the full log without disabling the rewriter system-wide.

**Given** `BASH_OUTPUT_FILTER_VERBOSE=1`, **when** the rewriter would normally trim, **then** the trimmed view is followed by a delimiter and the full original output, and Claude sees both.

### US-5 (P2) — Unsupported environments are signaled at startup, then degrade silently at runtime

**As a** developer on an older Claude Code version, in a container without `jq`, or on a runtime that doesn't yet support output replacement
**I want** to be informed once at session start if the rewriter cannot run, AND have each hook bail out silently if the runtime later refuses an envelope
**So that** I know whether the feature is active without surprises, and my session keeps working in any case.

**Given** a Claude Code version below the minimum supported (2.1.121), **when** the SessionStart hook fires, **then** a single visible message announces that the rewriter is disabled and points to the upgrade command. The session proceeds normally otherwise.

**Given** the runtime cannot honor an output rewrite at the per-hook level (missing `jq`, malformed stdin, edge runtime issue), **when** any rewriter hook runs, **then** the hook bails out with exit code 0 and no JSON envelope written, and the session proceeds with the unmodified output.

### US-6 (P3) — Filter savings are observable

**As a** maintainer
**I want** the rewriter to log how much it trimmed (lines kept / dropped, characters before / after)
**So that** the value of the filter can be measured over time without instrumenting the user's session.

**Given** a writable `/tmp` directory, **when** any filter rewrites an output, **then** a structured log line is appended to `/tmp/claude-rewriter.log` with timestamp, tool name, original size, filtered size, ratio.

## Functional requirements

### Filter (US-1)

- **FR-1**: An allowlist of command shapes triggers filtering. Default allowlist covers: `npm install`, `npm audit`, `npm test`, `npm run build`, `npm ci`, the same forms with `pnpm`, `yarn`, `bun`, plus `pytest`, `go test`, `go build`, `cargo build`, `cargo test`. Anything outside the allowlist passes through untouched. The allowlist is hardcoded for v1; user-extensible allowlists are a follow-up if benchmark data shows demand.
- **FR-2**: For each command shape, an actionable extraction rule preserves: error/warning markers, severity counts, summary lines (added/removed/vulnerabilities/passed/failed), the exit code, and the last N lines of output when exit code is non-zero (default N=20).
- **FR-3**: ANSI color codes are stripped from the filtered view.
- **FR-4**: When the original output is shorter than a threshold (default: 30 lines), the rewriter passes through unchanged. The filter must only kick in when there is noise to remove.
- **FR-5**: The filter never drops the exit code, never drops a line containing `error:` (case-insensitive), and never drops the final 5 lines.

### Inline (US-2)

- **FR-6**: When the foundation's post-edit `tsc --noEmit` runs after an `Edit` or `Write` and finds errors that mention the just-edited file, those errors are appended to the edit's result envelope under a clearly delimited section. The tool result status remains SUCCESS — the edit did happen on disk; the rewriter only annotates.
- **FR-7**: Same for `eslint`. Errors mentioning the just-edited file are appended.
- **FR-8**: The `tsc` and `eslint` sections are limited to a default of 20 lines each, with a "(N more elided, run `npx tsc` for full output)" footer if truncated.
- **FR-9**: If neither `tsc` nor `eslint` produces any error mentioning the file, the edit result is unchanged.
- **FR-10**: The post-edit hooks must remain non-blocking. If the inline rewriter cannot attach (e.g. a malformed CLI envelope), the edit result is left unchanged and the existing fallback behavior (tsc output as a side message) takes over.

### Cross-cutting

- **FR-11**: `SKIP_BASH_OUTPUT_FILTER=1` disables FR-1 through FR-5 entirely, with no side effect on FR-6+.
- **FR-12**: `SKIP_INLINE_EDIT_ERRORS=1` disables FR-6 through FR-10 entirely, with no side effect on FR-1+.
- **FR-13**: `BASH_OUTPUT_FILTER_VERBOSE=1` preserves the original output appended after the filtered view.
- **FR-14**: Both rewriters bail out (exit 0, no envelope) when `jq` is absent.
- **FR-15**: Both rewriters bail out when stdin is empty or unparseable.
- **FR-16**: Logs are appended to `/tmp/claude-rewriter.log` (one line per rewrite) only when `/tmp` is writable. Failure to write must never block the rewrite itself.
- **FR-17**: Both rewriters complete in under 200ms in the 95th-percentile case on outputs up to 10000 lines.
- **FR-18**: Both rewriters preserve the exit status the original tool would have surfaced — the rewrite is purely about Claude's view, not about whether downstream `onFailure: block` semantics fire.
- **FR-19**: A SessionStart capability probe reads the running Claude Code version. If the version is below 2.1.121 (the minimum that supports `updatedToolOutput` for non-MCP tools), a single-line visible notice is emitted: `[INFO] Hook output rewriter requires Claude Code 2.1.121+ — feature disabled, sessions will work as before. Upgrade: <command>`. The probe must complete in ≤ 100ms and never block session startup.
- **FR-20**: When the SessionStart probe detects an unsupported version, it sets an environment variable that downstream rewriter hooks check first to skip their work entirely (avoiding double-cost on unsupported runtimes).

### Migration path (existing projects)

- **FR-21**: The release that introduces this feature documents the migration path explicitly: existing projects must run `./scripts/update.sh -f --all` (or at minimum `--settings` AND `--hook-scripts` together) to get a coherent state. The CHANGELOG entry calls this out.
- **FR-22**: The new replacement hook script (subsuming the old inline tsc/eslint blocks per US-2 strategy A) detects at runtime whether the host's `.claude/settings.json` still references the old inline blocks (signal of partial update). If so, it emits a one-line notice once per session: `[INFO] claude-socle: settings.json appears to predate the output rewriter — re-run ./scripts/update.sh -f --all to enable. Continuing with legacy behavior.`
- **FR-23**: For interactive `update.sh` runs, the prompt for `.claude/settings.json` (currently defaulting to "n") changes to flag this release specifically: `Update .claude/settings.json? (recommended for this release — adds output rewriter)` with the default still "n" to preserve user customizations, but the prompt makes the cost of declining explicit.
- **FR-24**: The `update.sh -f --all` path remains a full overwrite of `.claude/settings.json` (no merge logic introduced). Users who customized settings are reminded by the existing backup mechanism (`commands.backup.<timestamp>`) and the new prompt copy from FR-23.

### Test fixtures

- **FR-25**: Test fixtures live under `tests/hook-output-rewriter/fixtures/` with two subdirectories: `bash/` and `inline-edit/`. Each scenario consists of two sibling files: `<scenario>.in.txt` (raw output captured from the underlying tool) and `<scenario>.expected.txt` (the trimmed view the rewriter must produce). Tests are written as bats files at `tests/hook-output-rewriter.bats`, reading the fixture pair and comparing rewriter output to `.expected.txt`.
- **FR-26**: The minimum fixture set covers SC-1 / SC-2 (10 Bash scenarios) and SC-3 (5 TypeScript edit-error pairs). Adding a new scenario means dropping in two files; no central index or registry to keep in sync.
- **FR-27**: Fixtures are designed to be reusable by Workstream 1 (the public benchmark): the same `.in.txt` / `.expected.txt` pairs can be cited verbatim as reproducible scenarios on the public benchmark page.

## Edge cases

- **Empty output**: pass through unchanged.
- **Single very long line** (e.g. minified bundle log): truncate with a `[... truncated, N chars elided ...]` marker.
- **Output already shorter than threshold**: pass through.
- **Mixed stdout/stderr interleaved**: treat the merged stream as the input; preserve order.
- **Concurrent post-edit hooks** (format → typecheck → lint, all on `Edit|Write`): the inline rewriter must produce a stable result regardless of execution order — last writer wins, but both error sections must end up attached.
- **File path mismatch**: `tsc` may report an error in `src/foo.ts` while the edit was on `src/bar.ts`. Only errors mentioning the edited file are attached. Errors elsewhere remain in the existing side-message channel.
- **`tsc` reports the error spans 4 lines (header + code frame)**: each error is preserved as a unit, never split.
- **The user explicitly captures the output** (`npm audit > out.txt`): the file on disk receives the original output (the rewriter only affects what Claude sees, not what shell redirection produces). The filtered view goes only to Claude.
- **A new noisy command appears in user code** (e.g. `nx build`, `turbo run`): not in the allowlist, passes through untouched. This is by design — the allowlist starts conservative.
- **CI environment where `/tmp` is volatile/read-only**: log line is dropped silently, rewriting continues normally.
- **Existing inline output already mentions the same error twice**: the rewriter does not de-duplicate at the line level beyond the per-tool section split (FR-7).
- **Partial update of an existing project** (`update.sh --hook-scripts` without `--settings` or vice versa): handled by FR-22 (script detects orphaned state and emits a one-line notice), the existing `|| true` discipline in `.claude/settings.json`, and FR-14/15 (silent bail-out on missing dependency). Worst case = legacy behavior continues, no breakage.

## Success criteria

- **SC-1**: On a representative `npm audit` against a 50-dependency project producing 180+ lines of output, the filtered view contains ≤ 25 lines and includes 100% of vulnerability/severity/exit-code lines.
- **SC-2**: On a curated benchmark of 10 noisy command captures (under `tests/hook-output-rewriter/fixtures/bash/`), no actionable line (error, warning, summary, exit code) is dropped in any of the 10 cases.
- **SC-3**: On a curated benchmark of 5 TypeScript edit+error pairs (under `tests/hook-output-rewriter/fixtures/inline-edit/`), Claude reaches a clean `tsc` in ≤ 2 follow-up turns with the inline pattern, vs ≤ 4 follow-up turns without (measured against a fresh session, same prompt).
- **SC-4**: With both `SKIP_*` flags set, the foundation behaves byte-identically to the prior release on the existing test suite.
- **SC-5**: `validate-counts.sh` and `audit-socle.sh` pass on the PR. New hooks pass `shellcheck`. New scripts are covered by `bats` tests.
- **SC-6**: Cumulative wall-clock latency added by both rewriters on a representative session (10 edits + 5 noisy commands) is ≤ 1.5s.

## Out of scope

- Coverage of Python type errors (`mypy`/`pyright`), Go vet, Rust `cargo check`, Dart analyzer in the inline rewriter — deferred to a follow-up once the TS/JS pattern is proven.
- Filtering of arbitrary user-defined commands. Allowlist only.
- Auto-fix proposals based on the surfaced errors.
- Replacing or removing the existing foundation post-edit hooks. Both rewriters layer on top.
- Cross-session metrics aggregation, dashboards, or visual reporting.
- Promotion to an external plugin published on the Claude marketplace. Stays internal to the foundation for this iteration.
- Coverage of MCP tool outputs (already supported natively before this work).

## Clarification points

1. ~~**Allowlist vs universal filter for US-1**~~ — **RESOLVED 2026-05-04**: hardcoded allowlist (FR-1). User-extensible variant deferred to a follow-up after benchmark data.
2. ~~**Edit-with-errors semantics for US-2**~~ — **RESOLVED 2026-05-04**: SUCCESS with annotations (FR-6). The edit happened on disk; the rewriter never downgrades the status — co-located error context is enough for Claude to self-correct without breaking the PostToolUse chain.
3. ~~**Capability detection at SessionStart vs runtime**~~ — **RESOLVED 2026-05-04**: SessionStart probe + visible one-line notice (FR-19, FR-20), backed by per-hook silent bail-out (FR-14, FR-15) as a safety net. The original recommendation (silent-only) was reversed because the value of the feature is partly perceptual; a user who installs the foundation expecting the rewriter and sees no effect would lose trust faster than they would gain from saving 50ms of startup.
