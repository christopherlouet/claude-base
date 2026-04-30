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

## Configured Hooks

| Hook | Trigger | Action |
|------|-------------|--------|
| **Session info** | SessionStart (startup) | Displays project information at startup |
| **Check node_modules** | SessionStart (startup) | Checks that node_modules exists if package.json is present |
| **Main protection** | PreToolUse (Edit/Write) | Blocks modifications on main/master |
| **Secrets detection** | PreToolUse (Write/Edit) | Gitleaks checks for secrets before writing |
| **Pre-commit tests** | PreToolUse (Bash git commit) | Runs tests before a commit. Detects and repairs Husky if needed |
| **Local pre-push CI** | PreToolUse (Bash git push) | Lint + type-check + tests before push. Disable with `SKIP_PRE_PUSH_CI=1` |
| **Destructive ops guard** | PreToolUse (Bash) | Blocks destructive DELETE/DROP/TRUNCATE/rm without confirmation |
| **Command validator** | PreToolUse (Bash) | Validates commands against 8 risk categories (fork bombs, pipe-to-shell, disk destruction, privilege escalation, etc.). Disable with `SKIP_COMMAND_VALIDATOR=1` |
| **RTK token optimizer** | PreToolUse (Bash) | Rewrites commands via RTK to reduce tokens (-60-90%). Disabled by default, enable with `ENABLE_RTK=1` |
| **Auto-format TS/JS** | PostToolUse (Edit/Write) | Prettier on TS/JS files |
| **Auto-format Python** | PostToolUse (Edit/Write) | Ruff/Black on .py files |
| **Auto-format Go** | PostToolUse (Edit/Write) | gofmt on .go files |
| **Auto-format Rust** | PostToolUse (Edit/Write) | rustfmt on .rs files |
| **Auto-format Dart** | PostToolUse (Edit/Write) | dart format on .dart files |
| **Auto-format Lua** | PostToolUse (Edit/Write) | stylua on .lua files |
| **Type-check** | PostToolUse (Edit/Write) | Checks TypeScript types |
| **ESLint** | PostToolUse (Edit/Write) | Lint JS/TS after modification |
| **Auto-install** | PostToolUse (Edit package.json) | npm/yarn/pnpm/bun install |
| **Auto-sync Python** | PostToolUse (Edit pyproject.toml) | uv sync or pip install |
| **Auto pub get** | PostToolUse (Edit pubspec.yaml) | flutter/dart pub get |
| **Auto go mod tidy** | PostToolUse (Edit go.mod) | go mod tidy |
| **Auto cargo check** | PostToolUse (Edit Cargo.toml) | cargo check |
| **Coverage check** | PostToolUse (Edit test files) | Checks test coverage |
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
| **Prompt context injection** | UserPromptSubmit | Injects branch, modified files, LOC diff and `/assistant-auto` hint if no slash command (disable: `SKIP_PROMPT_CONTEXT=1`) |
| **PostToolUseFailure** | PostToolUseFailure | Logs tool failures for debugging (async) |
| **Check .env** | SessionStart | Checks that .env is in .gitignore |
| **Third-party hooks warning** | SessionStart | Warns if custom hooks are detected |

## Hook Environment Variables

| Variable | Usage |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Disable main branch protection |
| `SKIP_PRE_COMMIT_TESTS=1` | Disable pre-commit tests |
| `SKIP_COMMAND_VALIDATOR=1` | Disable command security validation |
| `SKIP_PRE_PUSH_CI=1` | Disable local pre-push CI check |
| `SKIP_DESTRUCTIVE_CHECK=1` | Disable destructive operations protection |
| `SKIP_PROMPT_CONTEXT=1` | Disable repo context injection on free-form prompts |
| `ENABLE_RTK=1` | Enable RTK token optimization |

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
