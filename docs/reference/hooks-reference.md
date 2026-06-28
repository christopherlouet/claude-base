# Hooks (Claude Code 2.1+)

The project includes automatic hooks in `.claude/settings.json`:

## Available Hook Events

| Event | Type | Description |
|-------|------|-------------|
| `SessionStart` | command | Triggered at session startup (matchers: `startup`, `resume`, `clear`, `compact`) |
| `UserPromptSubmit` | command | When the user submits a prompt (validation, additional context) |
| `PreToolUse` | command/prompt | Before tool execution (matcher: `Edit\|Write`, `Bash`) |
| `PermissionRequest` | command/prompt | When a permission dialog is shown |
| `PostToolUse` | command | After successful tool execution |
| `PostToolUseFailure` | command | After a tool failure |
| `SubagentStart` | command | Sub-agent startup |
| `SubagentStop` | command/prompt | End of sub-agent execution |
| `Stop` | command/prompt | When Claude finishes responding |
| `StopFailure` | command | When a turn ends on an API error (rate limit, auth failure) — CLI 2.1.78+ |
| `Setup` | command | Project initialization (`init`) and maintenance (`maintenance`) |
| `Notification` | command | Notifications (`permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`) |
| `PreCompact` | command | Before context compaction (matchers: `manual`, `auto`) |
| `PostCompact` | command | After context compaction |
| `SessionEnd` | command | End of session |
| `TeammateIdle` | command | When a teammate agent becomes idle (Agent Teams) |
| `TaskCreated` | command | When a task is created via `TaskCreate` (CLI 2.1.84+) |
| `TaskCompleted` | command | When a task is marked completed |
| `WorktreeCreate` | http | Hook `type: "http"` invoked on worktree creation, must return `hookSpecificOutput.worktreePath` (CLI 2.1.84+) |
| `InstructionsLoaded` | command | When CLAUDE.md and rules are loaded |
| `Elicitation` | command | When an MCP server requests structured input |
| `ElicitationResult` | command | When the user responds to an MCP Elicitation |
| `PermissionDenied` | command | After a permission denial by the auto mode classifier. Return `{retry: true}` to retry |
| `CwdChanged` | command | When the working directory changes |
| `FileChanged` | command | When a file is modified |

## Hook Types

| Type | Description |
|------|-------------|
| `command` | Executes a bash script (deterministic, fast) |
| `prompt` | Evaluated via a Haiku LLM (contextual, intelligent) - for `Stop`, `SubagentStop`, `PreToolUse` |
| `http` | Sends a JSON POST to a URL (external webhook) - CLI 2.1.70+ |

## Hook Properties

| Property | Description |
|-----------|-------------|
| `async` | `true` to run in the background without blocking (CLI 2.1.70+) |
| `onFailure` | `"block"` to block, `"ignore"` to continue |
| `timeout` | Timeout in milliseconds |
| `if` | Activation condition using permission rules syntax (CLI 2.1.90+) |
| `additionalContext` | Additional context string injected into the PreToolUse hook (CLI 2.1.110+) |

### `defer` permission (PreToolUse)

PreToolUse hooks can return `"defer"` as a permission decision. The headless session pauses at the tool call and can resume with `-p --resume` to re-evaluate the hook. Useful for CI/CD workflows requiring human approval.

### MCP transient retry (CLI 2.1.128+)

When a hook interacts with an MCP server, transient connection failures are auto-retried by the runtime. Hook authors do not need to wrap MCP calls in custom retry logic for transient cases (the typical "server momentarily unavailable" pattern). Permanent failures are not retried.

### `terminalSequence` field (CLI 2.1.141+)

Hook JSON output gained a `terminalSequence` field that emits raw terminal escape sequences — desktop notifications, window-title updates, and the bell — without requiring a controlling terminal. Useful for background or daemonized hooks that want to surface status outside the Claude Code TUI. See the [upstream changelog](https://code.claude.com/docs/en/changelog) for the exact escape codes accepted.

The exact retry bound and the failure-classification heuristics are tuned upstream and may evolve between releases — refer to the [Claude Code changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) for the canonical behavior at the version you target.

## Configured Hooks

| Hook | Trigger | Action |
|------|-------------|--------|
| **Session info** | SessionStart (startup) | Displays project information at startup |
| **Check node_modules** | SessionStart (startup) | Checks that node_modules exists if package.json is present |
| **Main protection** | PreToolUse (Edit/Write) | Blocks modifications on main/master |
| **Secrets detection** | PreToolUse (Write/Edit/MultiEdit) | Built-in zero-dependency scan blocks hardcoded provider secrets (AWS/Stripe/GitHub/Slack/Google/PEM) before writing; also runs gitleaks if installed. Placeholders ignored. Disable with `SKIP_SECRET_SCAN=1` (`scripts/hooks/secret-scan.sh`) |
| **Destructive migration** | PreToolUse (Write/Edit/MultiEdit) | Confirm+backup reminder before destructive DDL (DROP/TRUNCATE) in a migration file — closes the gap the Bash-only destructive guard misses. Disable with `SKIP_DESTRUCTIVE_CHECK=1` (`scripts/hooks/destructive-migration.sh`) |
| **Pre-commit tests** | PreToolUse (Bash git commit) | Runs tests before a commit. Detects and repairs Husky if needed |
| **Local pre-push CI** | PreToolUse (Bash git push) | Lint + type-check + tests before push. Disable with `SKIP_PRE_PUSH_CI=1` |
| **Destructive ops guard** | PreToolUse (Bash) | Blocks destructive DELETE/DROP/TRUNCATE/rm without confirmation |
| **Command validator** | PreToolUse (Bash) | Validates commands against 9 risk categories (fork bombs, pipe-to-shell, disk destruction, privilege escalation, **`git --no-verify` / `commit -n` gate-bypass**, etc.). Disable all with `SKIP_COMMAND_VALIDATOR=1`, or just the no-verify block with `SKIP_NO_VERIFY_CHECK=1` |
| **Config protection** | PreToolUse (Edit/Write/MultiEdit) | Blocks modifying an *existing* linter/formatter config (`.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `biome.json`, `ruff.toml`, `.markdownlint.*`) so a failing check is fixed in the code, not silenced. Creating a config is allowed; `pyproject.toml`/`tsconfig.json` and test fixtures are exempt. Disable with `SKIP_CONFIG_PROTECTION=1` |
| **Auto-format TS/JS** | PostToolUse (Edit/Write) | Prettier on TS/JS files |
| **Auto-format Python** | PostToolUse (Edit/Write) | Ruff/Black on .py files |
| **Auto-format Go** | PostToolUse (Edit/Write) | gofmt on .go files |
| **Auto-format Rust** | PostToolUse (Edit/Write) | rustfmt on .rs files |
| **Auto-format Dart** | PostToolUse (Edit/Write) | dart format on .dart files |
| **Auto-format Lua** | PostToolUse (Edit/Write) | stylua on .lua files |
| **Inline edit errors (output rewriter)** | PostToolUse (Edit/Write) | Runs tsc + eslint on edited TS/JS files and appends errors to the tool result envelope (CLI 2.1.121+). Disable: `SKIP_INLINE_EDIT_ERRORS=1`. Replaces the former inline tsc + eslint blocks. |
| **Auto-install** | PostToolUse (Edit package.json) | npm/yarn/pnpm/bun install |
| **Auto-sync Python** | PostToolUse (Edit pyproject.toml) | uv sync or pip install |
| **Auto pub get** | PostToolUse (Edit pubspec.yaml) | flutter/dart pub get |
| **Auto go mod tidy** | PostToolUse (Edit go.mod) | go mod tidy |
| **Auto cargo check** | PostToolUse (Edit Cargo.toml) | cargo check |
| **Coverage check** | PostToolUse (Edit test files) | Checks test coverage |
| **Substance gate** | PostToolUse (Edit/Write/MultiEdit) | Advisory: runs `scripts/substance-check.sh` on the edited test/source file and surfaces hollow tests (no-assertion / always-true / skipped / empty) and implementation stubs (`not implemented`/`NotImplementedError`/`panic("TODO")`) that coverage % misses. Never blocks (exit 0 always). Disable: `SKIP_SUBSTANCE_CHECK=1` |
| **Setup init** | Setup (init) | Installs dependencies on first run |
| **Setup maintenance** | Setup (maintenance) | Periodic audit and updates |
| **Notification permission** | Notification (permission_prompt) | Logs permission requests |
| **Notification idle** | Notification (idle_prompt) | Logs when Claude is waiting for the user |
| **SubagentStop** | SubagentStop | Logs the end of sub-agents |
| **SessionEnd** | SessionEnd | Logs end of session |
| **PreCompact** | PreCompact | Logs before context compaction |
| **PostCompact** | PostCompact | Logs after context compaction (async) |
| **TeammateIdle** | TeammateIdle | Logs when a teammate becomes idle (async) |
| **TaskCompleted** | TaskCompleted | Logs when a task is completed (async) |
| **InstructionsLoaded** | InstructionsLoaded | Logs instruction loading (async) |
| **Elicitation** | Elicitation | Logs MCP Elicitation requests (async) |
| **ElicitationResult** | ElicitationResult | Logs MCP Elicitation responses (async) |
| **PermissionDenied** | PermissionDenied | Logs permissions denied by auto mode (async, CLI 2.1.111+) |
| **UserPromptSubmit** | UserPromptSubmit | Logs user prompt submissions (async) |
| **Prompt context injection** | UserPromptSubmit | Injects branch, modified files, LOC diff and `/assistant-auto` hint if no slash command (disable: `SKIP_PROMPT_CONTEXT=1`). Also injects a once-per-session **vendor-precedence** hint when a graduated vendor skill is installed (prefer it over the foundation pointer, vendor-precedence T3; pure-shell helper `_vendor-precedence-hint.sh`, disable: `SKIP_VENDOR_PRECEDENCE=1`) |
| **PostToolUseFailure** | PostToolUseFailure | Logs tool failures for debugging (async) |
| **Check .env** | SessionStart | Checks that .env is in .gitignore |
| **Third-party hooks warning** | SessionStart | Warns if custom hooks are detected |
| **CLI version probe** | SessionStart | Probes Claude Code version for the output rewriter (requires 2.1.121+). Writes `/tmp/claude-rewriter-supported` (`1` or `0`) consumed by post-edit and bash-output rewriter hooks |

## Git-native hooks (`.husky/`)

Distinct from the Claude Code hooks above (which live in `.claude/settings.json`):
these are standard **git** hooks, wired via `core.hooksPath=.husky`. They run for
**every** commit — by a human or an agent, in any tool — not only inside Claude
Code. `scripts/hooks/setup-deps.sh` wires `core.hooksPath` on Setup (idempotent,
and it repairs a stale absolute path left by a repo rename); for a manual clone,
run `git config core.hooksPath .husky` once.

| Hook | Action |
|------|--------|
| `pre-commit` → **counts self-heal** | When a commit stages a counted artifact (`.claude/{commands,agents,skills,rules}/**` or `tests/*.bats`), runs `scripts/sync-counts.sh`: regenerates the derived count files and `git add`s them, so a stale count can never reach CI. No-op (and node-free) for any other commit. Blocks only if counts drifted and regeneration is unavailable. Disable with `SKIP_COUNTS_SYNC=1`. |
| `pre-push` → **preflight** | Runs the foundation's own CI gates locally before a push (`scripts/preflight.sh --fast`: shellcheck · `validate-counts.sh` · `manifest-hooks-coverage`), so failures surface locally instead of post-push. Mirrors `ci.yml`; `scripts/preflight.sh --full` adds the complete bats suite. Bypass once with `SKIP_PREFLIGHT=1`. |

`scripts/sync-counts.sh` mirrors the CI **"Counts gate"**: it regenerates and
stages the same derived path set the CI diffs (`counts.json`, `README.md`,
`CLAUDE.md`, `docs/`, `website/docs/`, the Docusaurus config). `--check` runs the
read-only `validate-counts.sh` instead (no regeneration, no staging).

## Output rewriter (CLI 2.1.121+)

Three coordinated hooks that exploit `hookSpecificOutput.updatedToolOutput` to tighten Claude's feedback loop on PostToolUse Bash and Edit/Write events.

| Hook | Event | Role |
|------|-------|------|
| `check-cli-version.sh` | SessionStart | Probes `claude --version` and writes `/tmp/claude-rewriter-supported` (`1` if >= 2.1.121, `0` otherwise). On unsupported CLI, prints a one-line notice. |
| `bash-output-filter.sh` | PostToolUse (Bash) | Trims allowlisted noisy command outputs (`npm`/`pnpm`/`yarn`/`bun` install/audit/test/build, `pytest`, `go test`/`build`, `cargo build`/`test`/`check`) to actionable lines. Outputs below 30 lines pass through unchanged. |
| `post-edit-typecheck-and-lint.sh` | PostToolUse (Edit\|Write) | Replaces the former inline tsc + eslint blocks. Runs `tsc --noEmit` (TS/TSX) + `eslint` (TS/TSX/JS/JSX), grep filters for the just-edited file, appends errors as a delimited section to the Edit/Write tool result envelope. Status stays SUCCESS. |

All three hooks bail out silently if the sentinel reports unsupported, if `jq` is absent, or if their respective opt-out env var is set. The Bash filter and inline-edit hook share the helpers in `_hook-helpers.sh` (sourced, not registered).

Migration path: existing projects must run `claude-base update -f --all <project>` to get the consolidated `.claude/settings.json`. If only `--hook-scripts` ran, `post-edit-typecheck-and-lint.sh` will detect the legacy state at runtime (old `npx tsc --noEmit` references in `.claude/settings.json`) and emit a one-line notice once per session.

## Hook Environment Variables

| Variable | Usage |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Disable main branch protection |
| `SKIP_PRE_COMMIT_TESTS=1` | Disable pre-commit tests |
| `SKIP_COUNTS_SYNC=1` | Disable the git pre-commit counts self-heal (`.husky/pre-commit`) |
| `SKIP_PREFLIGHT=1` | Skip the git pre-push foundation gates (`.husky/pre-push` → `scripts/preflight.sh`) |
| `SKIP_COMMAND_VALIDATOR=1` | Disable ALL command security validation (every category) |
| `SKIP_NO_VERIFY_CHECK=1` | Disable ONLY the `git --no-verify`/`-n` gate-bypass block (keeps the other 8 categories active) |
| `SKIP_CONFIG_PROTECTION=1` | Disable the linter/formatter config-protection hook |
| `SKIP_SECRET_SCAN=1` | Disable the built-in hardcoded-secret scan (`scripts/hooks/secret-scan.sh`) |
| `SKIP_SUBSTANCE_CHECK=1` | Disable the substance gate (advisory hollow-test / stub detector) |
| `SKIP_PRE_PUSH_CI=1` | Disable local pre-push CI check |
| `SKIP_DESTRUCTIVE_CHECK=1` | Disable destructive operations protection |
| `SKIP_PROMPT_CONTEXT=1` | Disable repo context injection on free-form prompts |
| `SKIP_VENDOR_PRECEDENCE=1` | Disable the once-per-session installed-vendor precedence hint |
| `SKIP_BASH_OUTPUT_FILTER=1` | Disable the Bash output filter (output rewriter) |
| `SKIP_INLINE_EDIT_ERRORS=1` | Disable the inline edit errors hook (output rewriter) |
| `BASH_OUTPUT_FILTER_VERBOSE=1` | Keep both filtered and original views in the rewritten output |
| `BASH_OUTPUT_FILTER_THRESHOLD=<N>` | Override the noise threshold (default 30 lines) below which Bash outputs pass through unchanged |
| `HOOK_REWRITER_SENTINEL=<path>` | Override the capability sentinel path (default `/tmp/claude-rewriter-supported`). Used by tests to isolate parallel runs under `$BATS_TEST_TMPDIR` |
| `HOOK_REWRITER_METRIC_LOG=<path>` | Override the bash filter metric log path (default `/tmp/claude-rewriter.log`). Same testing rationale |
| `HOOK_LEGACY_NOTICE_SENTINEL=<path>` | Override the legacy notice sentinel base path (default `/tmp/claude-base-legacy-warned`, suffixed with `.PPID`). Same testing rationale |

## Log Files

Logging hooks write to `/tmp/` (append mode, cleared on restart):

| File | Content |
|---------|---------|
| `/tmp/claude-sessions.log` | Startup, end of session, compaction, tasks |
| `/tmp/claude-agents.log` | Sub-agent and teammate activity |
| `/tmp/claude-notifications.log` | Permissions and user waits |
| `/tmp/claude-mcp.log` | MCP Elicitation events |
| `/tmp/claude-permissions.log` | Permissions denied by the auto mode classifier |
| `/tmp/claude-prompts.log` | User prompt submissions (timestamps) |
| `/tmp/claude-failures.log` | Tool failures with tool name |
| `/tmp/claude-rewriter.log` | Output rewriter activity (tool name, original / filtered line counts) |
