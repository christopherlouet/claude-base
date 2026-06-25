# Advanced Features

## Output Styles

10 interaction modes in `.claude/output-styles/`: `teaching`, `explanatory` (recommended), `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`, `debug`, `metrics`.

## Specification Templates

Templates in `.claude/templates/` for the Explore → Specify → Plan → TDD → Audit → Commit workflow:

| Template | Used by |
|----------|-------------|
| `spec-template.md` | `/work:work-specify` |
| `plan-template.md` | `/work:work-plan` |
| `tasks-template.md` | `/work:work-plan` |

Structure: `specs/[feature]/` contains `spec.md`, `plan.md`, `tasks.md`, `clarifications.md` (opt).

Conventions: `P1`=MVP, `P2`=Important, `P3`=Nice-to-have, `[P]`=parallelizable, `[US1]`=User Story 1.

Proxmox templates (Terraform) available in `.claude/templates/proxmox/`.

## Automatic Memory (CLI 2.1.76+)

Claude Code automatically saves and recalls memories as work progresses (preferences, decisions, project context). Memories are stored in `~/.claude/memory/`.

| To memorize | To put in CLAUDE.md | To put in rules/ |
|-------------|------------------------|---------------------|
| Personal preferences | Project conventions | Per-language/framework rules |
| Architecture decisions | Mandatory workflow | Code patterns |
| Team context | Documentation references | Verification checklist |

Best practices:
- Let Claude memorize preferences and decisions (avoids repetition)
- Keep in CLAUDE.md what is shared with the team (versioned in git)
- Do not duplicate: if it is in CLAUDE.md, no need to memorize it
- Use "remember that..." to force an explicit memorization

## Effort Levels (CLI 2.1.76+)

`/effort` command to control the reasoning level (interactive slider since v2.1.111):

| Level | Command | Use case |
|--------|----------|-------------|
| `low` | `/effort low` | Exploration, formatting, simple tasks |
| `medium` | `/effort medium` | Standard development, fixes |
| `high` | `/effort high` | Architecture, audit, complex refactoring, debug |
| `xhigh` | `/effort xhigh` | Maximum reasoning — critical system architecture, advanced security audit (Opus 4.8 required) |

Recommendations per foundation workflow:

| Phase | Recommended effort |
|-------|-------------------|
| `/work:work-explore` | low |
| `/work:work-specify`, `/work:work-plan` | high |
| `/dev:dev-tdd` | medium |
| `/qa:qa-audit`, `/qa:qa-security` | high or xhigh |
| `/work:work-commit` | low |

## Named Sessions (CLI 2.1.76+)

`--name` / `-n` flag to name a session at startup:

```bash
claude --name "feature-auth"
claude -n "fix-login-bug"
```

Combine with git worktrees for isolated and identifiable sessions:

```bash
git worktree add ../myapp-auth -b feature/auth
cd ../myapp-auth && claude -n "auth-feature"
```

## VSCode URI Handler (CLI 2.1.76+)

Open a Claude Code tab programmatically from VSCode:

```
vscode://anthropic.claude-code/open
```

Useful for: CI/CD integration, setup scripts, notification hooks.

## Fable 5 (most capable tier)

`claude-fable-5` is Anthropic's most capable widely released model — the tier **above** Opus 4.8 for the most demanding reasoning and long-horizon autonomous work. 1M context (default and max), 128K output, same tokenizer as Opus 4.8. Pricing is **~$10/$50 per MTok — 2× Opus 4.8** — so reach for it deliberately, not as a default.

Behaviourally it differs from Opus 4.8: thinking is always on (the raw chain of thought is never returned) and individual turns on hard tasks can run several minutes — plan for streaming and async check-ins. Opus 4.8 remains the documented default; Fable 5 is the costlier escalation when a task genuinely exceeds it. For the API-level caveats when building with the SDK (no `thinking:{type:"disabled"}`, no assistant prefill, refusal classifiers, 30-day data retention), see the `dev-ai-integration` agent.

## Opus 4.8

Current frontier model (released 2026-05-28, supersedes Opus 4.7). **Defaults to `high` effort.** Anthropic reports it is roughly **4× less likely than Opus 4.7 to let a flaw in code it has written pass unremarked** — a strong asset for the TDD and Audit phases of the workflow.

Adaptive Thinking: Claude automatically adjusts the depth of its reasoning based on the complexity of the task. Replaces `budget_tokens` (deprecated). 4 effort levels (`low`, `medium`, `high`, `xhigh`) to guide reasoning.

**1M token context window by default** on the Claude API, Amazon Bedrock and Vertex AI (no longer a beta opt-in). 128k output tokens, automatic Context Compaction. Reasoning is interleaved between tool calls (interleaved thinking) for agentic workflows.

`xhigh` unlocks Opus 4.8's maximum reasoning (introduced as a tier in v2.1.111). Auto mode available for Max subscribers (intelligent automatic permissions). Fast mode runs on Opus 4.8 (also available on 4.7/4.6).

## Checkpoint / Rewind

Claude Code automatically saves the state of the code before each modification (checkpoint). To return to a previous state:

| Method | Action |
|---------|--------|
| `Esc` × 2 | Cancel the last modification and return to the checkpoint |
| `/rewind` | Choose a specific checkpoint in the history |
| `/undo` | Alias of `/rewind` (CLI 2.1.108+) |

Recommended in the TDD Refactor phase: if the refactoring breaks the tests, `/rewind` (or `/undo`) is faster than a manual git revert.

## Session Recap (CLI 2.1.108+)

`/recap` generates a structured summary of the session: decisions made, files modified, work state. Configurable in `/config`.

| Situation | Action |
|-----------|--------|
| Return after a break | `/recap` to recover the context |
| After `/compact` | `/recap` to verify what has been kept |
| Resumed session | Automatic recap on resume (if enabled in `/config`) |

## Fast Mode (Research Preview)

Same Opus 4.8 model, 2.5x faster output. Toggle with `/fast`. Premium cost (see Anthropic pricing).

| Use case | Recommendation |
|-------------|----------------|
| Exploration, commits, simple tasks | Fast mode suitable |
| Architecture, audit, complex debug | Standard mode recommended |

## Context Compaction

Compaction automatically summarizes the context when the window approaches its limit. Manual trigger with `/compact`.

| Command | Effect | When to use |
|----------|-------|----------------|
| `/compact` | Summarizes the context, keeps the essentials | Between long workflow phases |
| `/clear` | Erases the entire context | Total topic change |
| _(auto)_ | Automatic compaction if necessary | Long sessions without action required |

Associated hooks: `PreCompact` (before compaction, matcher `manual` or `auto`) and `PostCompact` (after). See `docs/reference/hooks-reference.md`.

## Claude Code Action (GitHub)

Official Anthropic action to integrate Claude into GitHub workflows. Reviews PRs, responds to @claude mentions, implements changes.

| Scenario | Trigger | Template |
|----------|------------|----------|
| Automatic PR reviews | `pull_request: opened, synchronize` | `.claude/templates/github-actions/claude-review.yml` |
| Security review (critical files) | `pull_request: paths: src/auth/**, src/api/**` | `.claude/templates/github-actions/claude-security-review.yml` |
| @claude mention | `issue_comment: @claude` | Included in `claude-review.yml` |

Prerequisites: an **Anthropic API key** (pay-per-use) or a cloud provider (Bedrock, Vertex, Foundry). The Max plan (interactive OAuth) does not work in CI/CD.

Quick setup: `/install-github-app` in Claude Code, or add `ANTHROPIC_API_KEY` in the GitHub secrets then copy the template into `.github/workflows/`.

Source: [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action)

## Agent Teams (Experimental)

Parallel coordination of agent teams. Activation: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `.claude/settings.json`.

Modes: `auto` (default), `in-process`, `tmux`. Command: `/work:work-team "description"`.

See `.claude/skills/agent-teams/SKILL.md` for the full documentation.

### Subagent reliability (CLI 2.1.113+)

A subagent stuck for more than 10 minutes without progress fails with an explicit error message instead of remaining in a silent hang. Isolated worktrees grant Read/Edit on the files of their own worktree. Permission dialog crashes during tool requests by a teammate are fixed (CLI 2.1.114+).

### Cross-session messaging hardening (CLI 2.1.166+)

Messages relayed via `SendMessage` from other Claude sessions no longer carry user authority: a teammate or remote session cannot approve permissions or trigger privileged actions on the user's behalf. Treat inter-agent messages as data, not as user instructions.

## Dynamic Workflows (Opus 4.8)

Introduced with Opus 4.8: a native **Workflow** capability that orchestrates work across **tens to hundreds of agents in the background** for large, complex tasks. Unlike the two mechanisms above, control flow is **deterministic and scripted** (loops, conditionals, fan-out, fan-in) rather than model-driven — you describe the structure (pipeline, parallel fan-out, adversarial verification) and the harness drives the agents.

Ask Claude to "create a workflow that…" and it generates a script orchestrating the fleet. Typical shapes:

| Shape | When to use |
|-------|-------------|
| **Pipeline** | Each item flows through N stages independently (migrate → verify per file) — no barrier between stages |
| **Parallel fan-out** | Independent tasks that must all complete before the next step (multi-dimension review) |
| **Adversarial verify** | Spawn N skeptics per finding; keep only what survives a majority refute — kills plausible-but-wrong results |
| **Loop-until-dry** | Unknown-size discovery (bugs, edge cases): keep spawning finders until K rounds find nothing new |

### When to use which mechanism

| Mechanism | Coordination | Best for |
|-----------|-------------|----------|
| `parallel-agents` skill | Task-based fan-out, manual | A handful of independent sub-tasks within one session |
| Agent Teams (experimental) | Inter-agent messaging, live | Long-running collaborative work with a lead + teammates |
| **Dynamic Workflows** | Deterministic script, background | Scale (dozens–hundreds of agents): audits, migrations, exhaustive review |

> Explicit opt-in: dynamic workflows can spawn many agents and consume a large token budget — they run only when you request that scale, not by inference.

## MCP Configuration

MCP servers in `.mcp.json` (all disabled by default):

| Server | Usage |
|--------|-------|
| `filesystem` | Advanced file access |
| `memory` | Persistent memory |
| `github` | GitHub integration |
| `postgres` | PostgreSQL connection |
| `puppeteer` | Browser automation |
| `slack` | Team communication |
| `sentry` | Error monitoring |
| `linear` | Project management |

To enable: `"enabled": true` in `.mcp.json`. Environment variables in `.env`.

### MCP Channels

MCP servers can push messages into a session via `--channels`. Available through channel plugins (Telegram, Discord, iMessage) that install as MCP servers.

| Channel | Plugin | Usage |
|---------|--------|-------|
| Telegram | `telegram-channel` | Messages and commands from Telegram |
| Discord | `discord-channel` | Messages from a Discord server |
| iMessage | `imessage-channel` | Messages from iMessage (macOS) |
| Slack | `slack` (native MCP) | Slack notifications and messages |

Activation: `claude --channels` at startup. Channels have access to the filesystem, MCP and git of the local session.

Permission relay: channels declaring the `permission` capability can relay approval requests to your phone.

### MCP Elicitation (CLI 2.1.76+)

MCP servers can request structured input from the user during a task via interactive dialogs. Associated hooks: `Elicitation` (request) and `ElicitationResult` (response).

### Managed Agents — private MCP & sandbox (Enterprise)

As of May 2026, **Claude Managed Agents** can run in a **sandbox you control** and connect to your **private MCP servers** — both the execution environment and the services it reaches stay within your enterprise boundaries. Paired with **Compliance API** integrations (security/compliance tooling), this lets IT and security teams govern Claude across the platform. Enterprise-only; out of scope for the local foundation, listed here as a pointer. See the [Anthropic news feed](https://www.anthropic.com/news).

### MCP OAuth RFC 9728 (CLI 2.1.85+)

Automatic discovery of Protected Resource Metadata for OAuth MCP servers. Simplifies OAuth 2.1 authentication by exposing the authorization server URL via a standard endpoint. Servers can provide a `headersHelper` and use the `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` environment variables.

### MCP Step-up Authorization (CLI 2.1.84+)

RFC support for step-up authorization: MCP servers can return a `403 insufficient_scope` to trigger a refresh token with an extended scope. Useful for sensitive operations that require reauthentication without breaking the session.

### MCP Result Size Override (CLI 2.1.84+)

MCP tools can declare `_meta["anthropic/maxResultSizeChars"]` (up to 500K) to override the result persistence limit. Useful for tools that return large payloads (exports, reports, diffs).

## Async Hooks (CLI 2.1.70+)

`"async": true` property to run a hook in the background without blocking the session. Recommended for logging and notification hooks. Security hooks (gitleaks, pre-commit tests) must remain synchronous.

| Hook | Mode | Reason |
|------|------|--------|
| SessionStart, PreToolUse, PostToolUse, Setup | **sync** | Critical actions (security, formatting) |
| SessionEnd, PreCompact, PostCompact, SubagentStop, Notification | **async** | Logging, no impact on the workflow |
| TeammateIdle, TaskCompleted, InstructionsLoaded | **async** | Observability, non-blocking |
| Elicitation, ElicitationResult | **async** | MCP logging |

## HTTP Hooks (CLI 2.1.70+)

`"http"` type to send a JSON POST to an external URL (webhook). Generic webhook configuration example:

```json
{
  "type": "http",
  "url": "https://your-webhook-url.example.com/hook",
  "headers": { "Authorization": "Bearer ${WEBHOOK_TOKEN}" },
  "timeout": 5000,
  "async": true
}
```

Recommendations: always `async: true` and `onFailure: "ignore"` to avoid blocking the session if the remote service is unavailable.

## Claude Code Security (Enterprise/Team)

Vulnerability scanning tool that reasons about code beyond traditional static analysis — data flows, interactions between components, and architectural patterns.

**Claude Security** entered **public beta on 2026-05-22** for Claude Enterprise customers: it scans code repositories for vulnerabilities and generates proposed fixes. It is the productized form of **Project Glasswing**, whose first quantified results (also 2026-05-22) reported 10,000+ high/critical-severity vulnerabilities found across widely used internet software via ~50 partner organizations.

Prerequisites: Enterprise or Team plan. Complement to `/qa:qa-security` (local, OWASP-based) for an in-depth audit. See [Anthropic announcement](https://www.anthropic.com/news/claude-code-security).

## CLAUDE.md @imports

`@path/to/file` syntax to import files. Relative and absolute paths supported, recursive imports (max 5 levels). View loaded imports with `/memory`.

## Plugins

Ecosystem of community extensions for Claude Code. A plugin can contain skills, agents, hooks and MCP servers.

| Action | Command |
|--------|----------|
| Load a local plugin (directory or `.zip`) | `claude --plugin-dir ./my-plugin` |
| Load a remote plugin | `claude --plugin-url https://example.com/my-plugin.zip` |
| Namespaced skills | `/my-plugin:skill-name` |
| Plugin executables | Files in `bin/` invocable as Bash commands |

Plugins can be distributed via an Anthropic-managed directory. Setting `disableSkillShellExecution` to disable shell execution in unverified plugins.

### Evaluating a plugin before adoption (CLI 2.1.128+)

Both `--plugin-dir <path>` (local directory or `.zip`) and `--plugin-url <url>` (remote `.zip`) are session-scoped: the plugin is loaded for the current `claude` invocation only and disappears at session end. They are repeatable, so multiple plugins can be combined for a single trial. This is the foundation's recommended way to validate a plugin against your workflow before requesting it for permanent inclusion in a preset's `marketplacePlugins` list — consistent with the validation-first policy described in [`docs/recipes/recommended-vendor-skills.md`](../recipes/recommended-vendor-skills.md).

Recipe — try a plugin without committing to it:

1. **Get the plugin**. Either clone the repo (`git clone <repo>`) or download the release `.zip` to a temp dir.
2. **Validate the manifest**. Run `claude plugin validate <unzipped-path>`. The validator reads `<path>/.claude-plugin/plugin.json`; pass an unzipped directory, not a `.zip` (the validator reads the path argument as a JSON file). Confirm at minimum `name`, `version`, `description` are present; `author` is recommended.
3. **Load it transiently**. Either `claude --plugin-dir ./plugin/` or `claude --plugin-dir ./plugin.zip` or `claude --plugin-url <url>`. The plugin is active for this session only.
4. **Use the plugin in your real workflow**. Invoke its skills (`/<plugin-name>:<skill>`), trigger its hooks, exercise the surface you care about. Take notes.
5. **Cleanup is automatic**. Exit the session — no installed state remains. Repeat with `--plugin-dir`/`--plugin-url` if you want to compare with another plugin or against the un-augmented baseline.

If after this trial the plugin is worth adopting, raise an issue or pull request against the relevant preset under [`.claude/presets/`](../../.claude/presets/) with the validation evidence (the marketplace-audit methodology under [`specs/marketplace-audit/`](../../specs/marketplace-audit/) describes the bar).

## Scheduled Tasks (Cloud)

Recurring jobs executed on Anthropic's cloud infrastructure. Useful for ongoing operational tasks without an active local session.

| Use case | Description |
|-------------|-------------|
| PR reviews | Automatic review of pull requests |
| CI monitoring | Continuous monitoring of the CI pipeline |
| Dependency audits | Periodic audit of dependencies |
| Doc syncing | Documentation synchronization |

Configuration via `/tasks`, `/schedule` or the API. Requires a Pro/Max/Team/Enterprise plan.

See also **Routines** (section above) for more complex automated workflows combining prompts, repos and connectors.

## Computer Use

Direct integration in Claude Code (Pro/Max). Allows opening files, launching dev tools, clicking and navigating in the interface without additional setup.

Useful for: visual tests, UI interactions, workflows requiring a browser or emulator.

## Routines (CLI 2.1.108+)

Routines are automated workflows that run on Anthropic's cloud infrastructure. A routine combines a prompt, one or more repos, and connectors into a single configuration executable on schedule, via API, or on a GitHub event.

| Property | Description |
|-----------|-------------|
| Prompt | The instructions to execute |
| Repos | One or more target repositories |
| Connectors | MCP servers, GitHub events, API triggers |
| Execution | Anthropic cloud — runs even with laptop turned off |

Use cases with the foundation:

| Routine | Description | Foundation equivalent |
|---------|-------------|------------------|
| Automatic PR reviews | Review every new PR | `/qa:qa-review` in cloud version |
| Periodic audit | Weekly security/quality audit | `/qa:qa-audit` in scheduled version |
| Automatic standup | Daily activity summary | `/ops:ops-standup` in cloud version |
| Dependency check | Audit deps every Monday | `/ops:ops-deps` in scheduled version |

Configuration via the Anthropic console or `/schedule`. Requires a Pro/Max/Team/Enterprise plan.

## Ultraplan and Ultrareview (CLI 2.1.101+)

Cloud commands that delegate work to parallel agents on Anthropic's infrastructure.

| Command | Description | When to use |
|----------|-------------|----------------|
| `/ultraplan` | Plan in cloud: draft, review in a web editor, remote or local execution | Complex architecture, multi-file plans |
| `/ultrareview` | Parallel multi-agent review in cloud | Large PRs, in-depth reviews |

`/ultraplan` automatically creates a cloud environment on first launch. The plan can be revised via a web editor before execution.

`/ultrareview` launches several agents in parallel for a more exhaustive review than local `/qa:qa-review`. Ideal for PRs of more than 500 lines.

### Local /code-review --fix (CLI 2.1.152+)

The local `/code-review` flow gained `--fix`: review findings are **applied automatically to the working tree** instead of only being reported. Combine with the foundation's `qa-loop` (audit + iterative fix to score 90) for a tight local loop, or `--comment` to post findings as inline PR comments. The same release added native **skill management** (list/enable skills from within Claude Code) — complementary to the foundation's `writing-skills` / `base-maintenance` conventions.

> **Rate limits**: Anthropic **doubled Claude Code rate limits** (May 2026) for developers, startups and enterprises — fewer throttling interruptions on agentic/parallel workloads.

## TUI Fullscreen (Research Preview, CLI 2.1.89+)

Alternative rendering mode that takes control of the terminal surface like `vim` or `htop`. "Fullscreen" refers to taking over the drawing surface, **not** to maximizing the window.

Activation: `/tui fullscreen` (CLI 2.1.110+) or `CLAUDE_CODE_NO_FLICKER=1` before launch. Deactivation: `/tui default`.

### Three key benefits

| Benefit | Impact |
|----------|--------|
| Flicker-free | No more flickering in VS Code terminal, tmux, iTerm2 on long sessions |
| Constant memory | Only visible messages in the render tree → flat RAM even on conversations of several hours |
| Mouse support | Click-to-expand tool results, click URLs/file paths, click-and-drag selection with auto-copy |

Visual signal: in fullscreen, the prompt input stays **fixed at the bottom** instead of scrolling up with the output.

### Associated commands

| Mode | Command | Description |
|------|----------|-------------|
| Fullscreen | `/tui fullscreen` | Activates the mode (persists via the `tui` setting) |
| Default | `/tui default` | Deactivates the mode |
| Status | `/tui` | Displays the active renderer |
| Focus | `/focus` | Condensed view: prompt + 1 line per tool + final response (separable from `/tui`) |
| Transcript | `Ctrl+O` | Toggle transcript mode with `less`-style navigation |

### Navigation in fullscreen

| Shortcut | Action |
|-----------|--------|
| `PgUp` / `PgDn` | Half-screen scroll (or `Fn+↑`/`Fn+↓` on Mac) |
| `Ctrl+Home` / `Ctrl+End` | Start / end of conversation |
| `Ctrl+O` then `/` | Search in the transcript |
| `Ctrl+O` then `[` | Dump the conversation into the terminal's native scrollback |
| `Ctrl+O` then `v` | Open the transcript in `$EDITOR` |

### Environment variables

| Variable | Usage |
|----------|-------|
| `CLAUDE_CODE_NO_FLICKER=1` | Activates fullscreen at startup (equivalent to the `tui` setting) |
| `CLAUDE_CODE_DISABLE_MOUSE=1` | Keeps flicker-free + flat memory, but disables mouse capture (useful in SSH/tmux) |
| `CLAUDE_CODE_SCROLL_SPEED` | Scroll wheel speed multiplier (1-20, terminal-dependent default) |

### tmux compatibility

- Requires `set -g mouse on` in `~/.tmux.conf` for the scroll wheel
- **Incompatible with `tmux -CC`** (iTerm2 integration mode)

## Push Notifications (CLI 2.1.110+)

Claude can send push notifications to mobile when Remote Control is enabled. Useful for long background tasks.

Activation: enable Remote Control + "Push when Claude decides" in `/config`. Claude notifies at task end or when a human decision is necessary.

## `/loop` Command

Run a prompt or command at regular intervals:

```bash
/loop 5m "run tests and report failures"   # every 5 minutes
/loop "check CI status"                     # auto-paced by Claude (CLI 2.1.101+)
```

Alias: `/proactive` (CLI 2.1.105+). Without an interval, Claude auto-determines the optimal frequency.

Wakeup control: `Esc` cancels pending wakeups (CLI 2.1.113+), a "Claude resuming /loop wakeup" message confirms restart at each tick.

## Monitor Tool (CLI 2.1.98+)

Native tool that spawns a watcher in the background and streams its events into the conversation: each event arrives as a new transcript message that Claude reacts to immediately. Replaces `Bash sleep` loops that block an entire turn.

| Use case | Example prompt |
|-------------|-------------------|
| Application log tail | `Tail server.log and notify me as soon as a 5xx appears` |
| Babysit CI on a PR | `Watch the CI of this PR and auto-fix the lints` |
| Watch a dev server | `Watch npm run dev and restart on crash` |
| Track a training run | `Monitor the training log and alert on loss spike` |

Recommended pairing with `/loop` (auto-pace): Claude chooses Monitor over polling when the source emits events directly.

Foundation integration: Monitor is useful in `/qa:qa-loop`, `/ops:ops-ci-fix`, and long-running `/loop` workflows where a bash sleep loop would be the alternative.

## `/autofix-pr` (CLI 2.1.92+)

Enables **PR auto-fix on Claude Code Web** from the terminal for the PR of the current branch. After push, Claude monitors the CI and review comments and pushes fixes until green without requiring an active local session.

```bash
git push -u origin feature/auth
/autofix-pr
```

| When to use | Description |
|----------------|-------------|
| Long CI cycle | Lints, tests, type-check looping on small fixes |
| PR with many review nits | Renames, formats, docstrings requested in review |
| Asynchronous work | You want to leave the terminal and let Claude finish |

Complement to `/work:work-pr`: `/work:work-pr` creates the PR, `/autofix-pr` makes it converge autonomously. Requires Claude Code on the web (Pro/Max/Team/Enterprise).

## `/powerup` Command

Interactive lessons and animated demos to discover Claude Code's features. Useful for onboarding new users.

## `/less-permission-prompts` (CLI 2.1.111+)

Scans session transcripts and proposes optimized permission allowlists. Reduces the number of permission prompts without compromising security.

Useful for: onboarding (generating initial permissions), sessions with too many prompts, team configuration optimization.

Since CLI 2.1.166, deny rules accept glob patterns in the tool-name position (e.g., `"*"` denies all tools, `mcp__github__*` denies every GitHub MCP tool) — useful to deny whole tool families instead of listing each tool.

## Advanced Prompt Caching (CLI 2.1.108+)

| Variable | TTL | Description |
|----------|-----|-------------|
| `ENABLE_PROMPT_CACHING_1H` | 1 hour | Extended prompt cache for long sessions (API key, Bedrock, Vertex, Foundry) |
| `FORCE_PROMPT_CACHING_5M` | 5 minutes | Forces 5 min TTL (useful if telemetry is disabled) |

Enable in `.claude/settings.local.json` (not committed):

```json
{
  "env": {
    "ENABLE_PROMPT_CACHING_1H": "1"
  }
}
```

## Advanced Environment Variables

| Variable | Description |
|----------|-------------|
| `CLAUDE_CODE_NO_FLICKER=1` | Alt-screen rendering without flicker (virtualized scrollback) |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` | Strips credentials from subprocess env variables |
| `MCP_CONNECTION_NONBLOCKING=true` | Skip waiting for MCP connection in `-p` mode (headless/CI) |
| `ENABLE_PROMPT_CACHING_1H=1` | 1-hour prompt cache (significant savings) |
| `FORCE_PROMPT_CACHING_5M=1` | Force 5-minute prompt cache |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Opt-in/out of the PowerShell tool on Windows (CLI 2.1.111+) |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY=1` | Forces the session recap even if telemetry is disabled (CLI 2.1.108+) |
| `CLAUDE_CODE_PERFORCE_MODE=1` | Edit/Write fail on read-only files with `p4 edit` hint (CLI 2.1.98+) |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | Configures the streaming inactivity watchdog (CLI 2.1.84+) |
| `OTEL_LOG_RAW_API_BODIES=1` | Emits full API request/response bodies via OpenTelemetry (CLI 2.1.113+) |
| `MAX_THINKING_TOKENS=0` | Disables thinking, including on models that think by default — same effect as `--thinking disabled` or the per-model toggle (CLI 2.1.166+) |

## Advanced Settings

| Setting | Description |
|---------|-------------|
| `fallbackModel` | Up to three fallback models tried in order when the primary is overloaded or unavailable; unexpected API errors retry on the fallback automatically (CLI 2.1.166+) |
| `disableSkillShellExecution` | Disables inline shell execution in skills, commands and plugins |
| `managed-settings.d/` | Drop-in directory for policy fragments (Team/Enterprise) |
| `sandbox.network.deniedDomains` | Blocks specific domains even under a wildcard `allowedDomains` (CLI 2.1.113+) |
| `sandbox.failIfUnavailable` | Exit with error if sandbox enabled but unavailable (CLI 2.1.83+) |
| `modelOverrides` | Maps picker entries to custom model IDs (Bedrock Application Inference Profile ARNs, etc.) (CLI 2.1.84+) |
| `worktree.sparsePaths` | Sparse-checkout for large monorepos with `claude --worktree` (CLI 2.1.76+) |
| `autoScrollEnabled` | Disables auto-scroll in fullscreen mode (CLI 2.1.110+) |
| `showThinkingSummaries` | Generates extended thinking summaries (default now `false` — CLI 2.1.108+) |
| `disableDeepLinkRegistration` | Prevents registration of the `claude-cli://` protocol handler (CLI 2.1.83+) |
| `feedbackSurveyRate` | Admin sample rate of the session quality survey (CLI 2.1.76+) |
| `forceRemoteSettingsRefresh` | Blocks startup until remote managed settings are refreshed (policy) |
| Theme `"Auto (match terminal)"` | Automatically follows the terminal's dark/light mode (CLI 2.1.111+) |

## LSP (Language Server Protocol)

Semantic code navigation via `.lsp.json`. Activation: `export ENABLE_LSP_TOOL=1`.

12 supported languages (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS).

LSP for: symbol definitions, references, diagnostics. Grep for: textual searches.
See `.claude/rules/lsp.md` for detailed rules.

## Marketplace Curation Engine

A deterministic, **billing-safe** system that keeps the recommended vendor-skill list
current — observe-and-propose only, never auto-install. Two scheduled jobs:

- **Nightly rot-watch** (`scripts/curation-watch.sh`) — **LLM-free → $0 tokens**. Re-verifies
  every recommended/pointed skill (archived / abandoned / sustained popularity-collapse /
  license-change / **content-drift vs the pinned ref**) and emits ONE digest. Opt-in,
  fail-safe GitHub emission: `--emit-issue` (propose-only) and `--emit-pr --draft` (low-risk
  re-pin, gated by a pin-time safety screen).
- **Monthly discovery** (`scripts/curation-discover.sh`) — model-using under a **hard token
  budget + fail-safe** (the 2026-06-15 agentic-billing change). Trust + safety gates run
  first (LLM-free); only survivors reach the advice-neutrality + fit judge. Flags
  *moat-encroachment* as a strategic signal, never an auto-candidate.

Deploy both as cron/systemd timers — the monthly job uses a **dedicated, capped API key**
in its own env, never mixed with the $0 nightly path. See
[`docs/recipes/curation-bot-deploy.md`](https://github.com/christopherlouet/claude-base/blob/main/docs/recipes/curation-bot-deploy.md). Policy:
advice-neutrality + provenance (not publisher-veto); foundation-vs-vendor precedence in
[`.claude/rules/vendor-precedence.md`](https://github.com/christopherlouet/claude-base/blob/main/.claude/rules/vendor-precedence.md).
