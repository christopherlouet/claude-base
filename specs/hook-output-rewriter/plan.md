# Plan: PostToolUse output rewriter (Bash filter + inline TS errors)

**Branch**: `feature/hook-output-rewriter`
**Date**: 2026-05-04
**Spec**: [spec.md](./spec.md)
**Status**: Validated (5/5 clarifications resolved)

---

## Summary

Add two PostToolUse hooks that exploit the new `hookSpecificOutput.updatedToolOutput` envelope (Claude Code 2.1.121, April 2026) to tighten Claude's feedback loop on foundation-equipped projects:

1. **`bash-output-filter.sh`** — trims noisy outputs (`npm install`, `npm audit`, build/test/install across npm/pnpm/yarn/bun, pytest, go test, cargo) to only actionable lines before Claude reads them.
2. **`post-edit-typecheck-and-lint.sh`** — replaces the two existing inline tsc + eslint PostToolUse blocks with a single script that **inlines** any errors mentioning the just-edited file into the Edit/Write tool result envelope. Status stays SUCCESS — the rewriter only annotates.

Both scripts share a small helper (`_hook-helpers.sh`) for stdin parsing, jq envelope construction, and capability gating. A SessionStart probe (`check-cli-version.sh`) signals once when the CLI is below 2.1.121, and sets an env var that downstream rewriter hooks read to skip work.

Existing `.claude/settings.json` is overwrite-updated by `update.sh -f --all`; for partial updates the new script self-detects the orphaned state via FR-22 and emits one notice.

## Technical context

| Aspect | Choice | Notes |
|---|---|---|
| Language | Bash 4+ (with portable patterns) | macOS BSD utilities expected to work — covered in Phase 5 audit |
| Output envelope | `jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: .}}'` | Same pattern as existing `prompt-context.sh` and `socle-integrity-check.sh`, just with `updatedToolOutput` instead of `additionalContext` |
| Allowlist (Bash) | Hardcoded array of regex shapes in `bash-output-filter.sh` | Per FR-1 and clarification Q1 (resolved) |
| ANSI strip | `sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g'` | Tested on BSD sed in Phase 5 |
| Capability probe | `claude --version` parsed as `MAJOR.MINOR.PATCH`, compared to `2.1.121` | One probe per session (SessionStart), result cached in `CLAUDE_REWRITER_SUPPORTED` env |
| Tests | bats with fixture pairs (`.in.txt` / `.expected.txt`) | Matches existing convention (`tests/*.bats`) |
| CI | Existing `.github/workflows/ci.yml` runs `bats tests/*.bats` and `shellcheck scripts/hooks/*.sh` | No new job needed |

### Constraints

- Do not break the existing post-edit feedback loop. Users disabling the new behavior (`SKIP_INLINE_EDIT_ERRORS=1`) must see the same tsc/eslint output they see today (just as a side message, not inlined).
- Do not change the public contract of `update.sh` other than the prompt copy (FR-23).
- Do not add any new agent/command/skill/rule (no `validate-counts.sh` impact). Only new hook scripts and test files.
- All changes pass: `bats tests/*.bats` + `shellcheck scripts/hooks/*.sh` + `bash scripts/validate-counts.sh` + `bash scripts/audit-socle.sh`.

## Constitution check

- [x] Follows project conventions (Bash hooks under `scripts/hooks/`, bats under `tests/`, kebab-case files)
- [x] Consistent with existing architecture (extends the established `hookSpecificOutput` JSON envelope used by 2 hooks today)
- [x] No over-engineering (no new dependency, no new framework — just bash + jq, both already required)
- [x] Tests planned (bats with `.in.txt`/`.expected.txt` fixture pairs per FR-25/26/27)
- [x] No new repo-level counters introduced (no agent/skill/command/rule), avoiding drift surface

## Architecture

### File layout (new)

```
scripts/hooks/
├── _hook-helpers.sh                  # Shared bail-out + envelope helpers (sourced)
├── check-cli-version.sh              # SessionStart probe (FR-19/20)
├── bash-output-filter.sh             # PostToolUse Bash, US-1/3/4
└── post-edit-typecheck-and-lint.sh   # PostToolUse Edit|Write, US-2/3 (replaces 2 inline blocks)

tests/
├── hook-output-rewriter.bats         # All tests for the two scripts
└── hook-output-rewriter/
    └── fixtures/
        ├── bash/
        │   ├── npm-install-clean.in.txt           npm-install-clean.expected.txt
        │   ├── npm-install-warnings.in.txt        npm-install-warnings.expected.txt
        │   ├── npm-audit-vulns.in.txt             npm-audit-vulns.expected.txt
        │   ├── npm-audit-clean.in.txt             npm-audit-clean.expected.txt
        │   ├── npm-test-fail.in.txt               npm-test-fail.expected.txt
        │   ├── npm-test-pass.in.txt               npm-test-pass.expected.txt
        │   ├── npm-build-fail.in.txt              npm-build-fail.expected.txt
        │   ├── pnpm-install.in.txt                pnpm-install.expected.txt
        │   ├── pytest-fail.in.txt                 pytest-fail.expected.txt
        │   └── go-test-fail.in.txt                go-test-fail.expected.txt
        └── inline-edit/
            ├── tsc-single-error.in.txt            tsc-single-error.expected.txt
            ├── tsc-multi-errors.in.txt            tsc-multi-errors.expected.txt
            ├── tsc-other-file.in.txt              tsc-other-file.expected.txt
            ├── eslint-single.in.txt               eslint-single.expected.txt
            └── tsc-and-eslint.in.txt              tsc-and-eslint.expected.txt
```

### File layout (modified)

| File | Change | Why |
|---|---|---|
| `.claude/settings.json` | Add SessionStart hook for `check-cli-version.sh`. Replace the two inline PostToolUse Edit\|Write blocks (tsc, eslint) with a single block calling `post-edit-typecheck-and-lint.sh`. Add new PostToolUse Bash block calling `bash-output-filter.sh`. | FR-6/7/19/20, US-2 strategy A |
| `scripts/update.sh` | Update interactive prompt copy at the settings.json prompt (line 539) per FR-23 | FR-23 |
| `docs/reference/hooks-reference.md` | Add new section "Output rewriter (CLI 2.1.121+)" listing the new hooks, env vars, log path. Update `## Hook Environment Variables` table. | FR-19, FR-22 |
| `CHANGELOG.md` | New entry under `## [Unreleased]`: Added (output rewriter), Changed (settings.json hooks consolidation), Migration note (FR-21) | FR-21 |
| `.claude/rules/socle-maintenance.md` | No counter change. Verify "shellcheck on new hooks" line still applies (it does). | none |

### Data flow

```
PostToolUse Edit|Write fires
        │
        ▼
post-edit-typecheck-and-lint.sh
  ├─ source _hook-helpers.sh
  ├─ bail-out if CLAUDE_REWRITER_SUPPORTED != 1   ───► fall through to legacy stdout
  ├─ parse stdin (tool_input.file_path, tool_response)
  ├─ run tsc --noEmit | grep <file>
  ├─ run eslint <file>
  ├─ if no errors: emit pass-through envelope (tool_response unchanged)
  ├─ else: build annotated text, emit
  │        {"hookSpecificOutput":{"hookEventName":"PostToolUse","updatedToolOutput":"<original>\n\n--- Type errors:\n<tsc>\n--- Lint:\n<eslint>"}}
  └─ exit 0
```

```
PostToolUse Bash fires
        │
        ▼
bash-output-filter.sh
  ├─ source _hook-helpers.sh
  ├─ bail-out if CLAUDE_REWRITER_SUPPORTED != 1
  ├─ bail-out if SKIP_BASH_OUTPUT_FILTER=1
  ├─ parse stdin (tool_input.command, tool_response)
  ├─ match command against allowlist; if no match → exit 0 (no envelope)
  ├─ if output < threshold lines → exit 0
  ├─ apply per-shape extraction → trimmed view
  ├─ if BASH_OUTPUT_FILTER_VERBOSE=1: append delimiter + raw output
  ├─ emit
  │   {"hookSpecificOutput":{"hookEventName":"PostToolUse","updatedToolOutput":"<trimmed>"}}
  ├─ append metric line to /tmp/claude-rewriter.log (best-effort)
  └─ exit 0
```

```
SessionStart fires
        │
        ▼
check-cli-version.sh
  ├─ claude --version → parse semver
  ├─ if < 2.1.121: echo notice + exit 0 (do not set env var)
  └─ if >= 2.1.121: emit envelope setting CLAUDE_REWRITER_SUPPORTED=1 for the session
```

## Phases

### Phase 1 — Foundation: helpers + capability probe (1h)

Build the small substrate every other phase reuses. Nothing user-visible yet.

**Tasks**: T001-T008 (see tasks.md)

**Validation**: `bats tests/hook-output-rewriter.bats -f "Phase 1"` passes; `shellcheck` clean on the 2 new scripts.

**Done when**: capability probe correctly detects supported / unsupported versions; helper functions tested with synthetic stdin JSON.

### Phase 2 — Bash output filter (4h) [P with Phase 3]

Implement US-1, US-3 (Bash side), US-4. The bigger of the two scripts.

**Tasks**: T010-T029 (see tasks.md)

**Validation**: 10 fixture pairs all pass; `SKIP_BASH_OUTPUT_FILTER=1` produces byte-identical pre-foundation behavior; `BASH_OUTPUT_FILTER_VERBOSE=1` keeps both views.

**Done when**: All 10 Bash fixtures round-trip; metric log is appended; SC-1 met on `npm-audit-vulns` fixture; SC-2 holds across the 10.

### Phase 3 — Inline edit errors (3h) [P with Phase 2]

Implement US-2 and US-3 (inline side). Smaller script but more sensitive (touches the existing tsc/eslint hooks).

**Tasks**: T030-T049 (see tasks.md)

**Validation**: 5 fixture pairs all pass; `SKIP_INLINE_EDIT_ERRORS=1` falls back to legacy stdout (same lines as before); `tsc-other-file.in.txt` confirms errors in unrelated files are NOT pulled into the edit envelope.

**Done when**: All 5 inline-edit fixtures round-trip; the two old inline blocks in `.claude/settings.json` are removed and replaced by the single new block; legacy detection (FR-22) emits notice when expected.

### Phase 4 — Migration & docs (1h)

Cover the upgrade path for existing claude-socle-using projects.

**Tasks**: T050-T058 (see tasks.md)

**Validation**: `update.sh -f --all` on a fixture project applies all changes coherently; interactive `update.sh` shows the new prompt copy; `docs/reference/hooks-reference.md` documents the new env vars and minimum CLI version.

**Done when**: CHANGELOG entry written; hooks-reference.md updated; update.sh prompt updated; README is unchanged (no counter delta).

### Phase 5 — Audit & manual validation (1h)

Tie everything together and run the full audit gate.

**Tasks**: T060-T067 (see tasks.md)

**Validation**: see acceptance gate below.

**Done when**: all gates green; one real Claude session captured as evidence (saved transcript or screenshot in PR description) showing the trimmed output and inlined errors in action.

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Hook execution order in PostToolUse Edit\|Write changes between CLI versions | Med | Med | Don't rely on order. The new script reads `tool_response` from stdin (whatever it is), and the envelope replaces it whole. |
| Concurrent format → typecheck race (Prettier rewrites file before tsc reads it) | Med | Low | Acceptable. tsc reads from disk; whichever version is on disk is the truth. Document in spec. Add a fixture covering "edit triggers prettier reformat then tsc". |
| BSD sed vs GNU sed for ANSI strip | Med | Med | Use only POSIX-portable sed flags (`-E`); covered by Phase 5 audit on macOS once the multi-OS CI workstream lands; flag as known-limitation otherwise. |
| `claude --version` output format changes | Low | Low | Probe is best-effort; on parse failure, set `CLAUDE_REWRITER_SUPPORTED=0` (silent legacy mode), no notice emitted. |
| Existing user has heavily customized `.claude/settings.json` | Low | High (for that user) | `update.sh` interactive default stays "n" (preserves user customizations). New prompt copy explicitly explains what they lose by declining. |
| Allowlist too narrow → user expects filtering on `nx build` and gets nothing | High | Low | Documented as "Out of scope" in spec. Allowlist hardcoded for v1; the metric log on `/tmp/claude-rewriter.log` will surface candidate commands for v2 expansion. |
| `updatedToolOutput` semantics evolve in newer CLI | Low | Med | Capability probe is version-floor only. We don't probe ceiling. If a future CLI breaks the envelope, we'll see it in tests on the next bats run on that CLI. |
| Performance regression on large outputs (10k+ lines) | Low | Med | FR-17 caps at 200ms p95. Phase 5 includes a perf check fixture (10k-line synthetic input). |
| Scope creep: "while we're in there, also support cargo check" | Med | Med | Stick to the spec's allowlist + 5 inline-edit fixtures. New languages = follow-up issue. |

## Acceptance gate

Before opening the PR:

- [ ] All T001-T067 tasks completed
- [ ] `bats tests/hook-output-rewriter.bats` 100% green (15 fixture pairs + cross-cutting tests)
- [ ] `bats tests/*.bats` (full suite) still green — no regression on existing tests
- [ ] `shellcheck scripts/hooks/*.sh` exit 0 on the 4 new/modified scripts
- [ ] `bash scripts/validate-counts.sh` exit 0
- [ ] `bash scripts/audit-socle.sh` exit 0 (no new agent/skill/rule = no counter delta expected)
- [ ] Manual session A — supported CLI: trigger an Edit on a TS file with a type error → verify error block appended to Edit result; trigger `npm audit` → verify trimmed view
- [ ] Manual session B — `SKIP_INLINE_EDIT_ERRORS=1` and `SKIP_BASH_OUTPUT_FILTER=1` both set → verify byte-identical legacy behavior (stdout side-messages, full Bash output)
- [ ] Manual session C — old settings.json (simulated by reverting to pre-PR settings.json on a copy of the repo) → verify FR-22 legacy-detection notice fires once
- [ ] CHANGELOG.md updated with Added (output rewriter) + Changed (settings.json consolidation) + Migration note
- [ ] PR description includes 1 transcript snippet of the trimmed view in action (proof for SC-1)
