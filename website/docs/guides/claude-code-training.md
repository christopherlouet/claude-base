---
sidebar_position: 0
title: "Claude Code Training"
description: "Complete training on Claude Code, prerequisite before using the foundation"
tags:
  - "guide"
  - "training"
---

# Claude Code Training

This guide is the mandatory prerequisite before using claude-base. It teaches you how to master Claude Code itself — Anthropic's CLI tool — before adding the foundation's configuration layer on top.

| Module | Topic | Duration |
|--------|-------|----------|
| 1 | Discovery | 30 min |
| 2 | Basic interaction | 45 min |
| 3 | Permissions and security | 30 min |
| 4 | Native commands | 30 min |
| 5 | Context and memory | 30 min |
| 6 | Keyboard shortcuts | 15 min |
| 7 | Advanced configuration | 30 min |
| 8 | Practical workflows | 30 min |
| 9 | Troubleshooting | 15 min |

**Total estimated duration: 3h45**

---

## Module 1: Discovery (30 min)

### What is Claude Code?

Claude Code is not a chatbot, nor an IDE plugin. It's an agent — a program that can reason, plan, and act autonomously in your development environment.

| Tool | Type | What it does | What it does not do |
|------|------|--------------|---------------------|
| ChatGPT / Claude.ai | Chatbot | Answers questions, explains code | Read your files, run commands |
| GitHub Copilot | IDE Copilot | Code autocomplete in the editor | Act outside the editor, chain tasks |
| Claude Code | CLI agent | Reads your files, writes code, runs commands, chains dozens of operations | (nothing — it can do everything in your project) |

The practical difference: with a chatbot, you copy-paste your code into the chat and copy the answer back into your file. With Claude Code, it directly reads `src/api/users.ts`, modifies it, runs the tests, and commits — without you touching anything.

### Where to use Claude Code

Claude Code works in several environments:

| Environment | How | Use case |
|-------------|-----|----------|
| Terminal | `claude` in any shell | Main usage, full access |
| VS Code | Official extension or integrated terminal | Develop without leaving the editor |
| JetBrains | Official plugin (IntelliJ, WebStorm, etc.) | Same thing for the JetBrains ecosystem |
| Desktop App | Native Anthropic application | Long sessions with enriched interface |
| Web | claude.ai/code | Quick access from anywhere |

### Available plans

| Plan | Price | Models included | Specifics |
|------|-------|-----------------|-----------|
| Pro | ~$20/month | Sonnet, Haiku | Personal use |
| Max | ~$100/month | Opus, Sonnet, Haiku | 5x more tokens, `auto` mode |
| Team | ~$25/user/month | Opus, Sonnet, Haiku | Collaboration, `auto` mode |
| Enterprise | Negotiated | All | SSO, audit logs, data residency |
| API | Pay-per-token | All | CI/CD integration, headless scripts |

The `auto` mode (which automatically approves actions) is available starting from the Max, Team, and Enterprise plans. On the Pro plan, Claude Code asks for confirmation for each action.

### Installation

**macOS / Linux (curl):**
```bash
curl -fsSL https://claude.ai/install.sh | sh
```

**macOS (Homebrew):**
```bash
brew install claude
```

**Windows (winget):**
```powershell
winget install Anthropic.ClaudeCode
```

**Verification:**
```bash
claude --version
```

### First launch

```bash
# In any project folder
cd my-project
claude
```

On first launch, Claude Code opens your browser to authenticate with your Anthropic account. After authentication, you are returned to the terminal with the `>` prompt indicating that Claude Code is ready.

### Interface: understanding what you see

```
> Explain the main entry point of this project        ← your prompt

  Reading src/index.ts...                              ← tool call (file read)
  Reading package.json...                              ← tool call

  The entry point is `src/index.ts`. It imports       ← Claude's response
  Express, configures the middlewares, and starts the
  server on the port defined in .env.

  [3 tool calls, 1.2k tokens]                          ← costs
>                                                       ← ready for the next interaction
```

The "tool calls" are the actions Claude Code performs: reading a file, running a command, writing code. You see them in real time.

---

## Module 2: Basic interaction (45 min)

### Typing a natural prompt

No special syntax needed. Speak normally:

```
> Fix the null pointer error in getUserById
> Add input validation to the registration form
> Write unit tests for the CartService class
> Refactor this function to be more readable
> Explain why the CI is failing
```

Claude Code understands the context of your project. It reads the relevant files before answering.

### The `!` prefix for direct bash

To run a shell command without going through Claude:

```bash
!ls -la
!git status
!npm test
!docker ps
```

Useful when you want to see something quickly without Claude interpreting it.

### `@` to mention files

```
> @src/services/auth.ts why can this function return undefined?
> compare @src/v1/api.ts and @src/v2/api.ts
> add tests for @src/utils/validators.ts
```

Autocomplete works: type `@src/` and Tab to navigate the tree.

### Multiline input

When your prompt is long or contains code:

| Method | How |
|--------|-----|
| `\` + Enter | Continue on the next line |
| Option+Enter (macOS) | New line without sending |
| Ctrl+J | New line without sending (universal) |

Example:
```
> Refactor this function:\
  function calculate(a, b) { return a + b; }\
  It must handle null cases and return 0 by default
```

### Copy-paste images

On macOS and Linux with clipboard support: `Ctrl+V` pastes an image directly into the prompt. Useful for sharing screenshots of errors, UI mockups, or diagrams.

```
> [Ctrl+V — screenshot of a TypeScript error]
  Explain this error and fix it
```

### Vim mode

If you prefer vim navigation to edit your prompts:

```
/vim
```

Type `/vim` to toggle. The `i` (insert), `Esc` (normal), `dd` (delete line), `yy`/`p` (copy/paste) modes are available.

### Voice input

On macOS with microphone access: hold `Space` to dictate your prompt. Releasing sends the transcription.

### Prompt history

| Action | Shortcut |
|--------|----------|
| Previous prompt | Up Arrow |
| Next prompt | Down Arrow |
| Search in history | Ctrl+R then type |

---

### Claude Code tools

Claude Code uses "tools" to act. You see them execute in real time during a response.

| Tool | Role | Example of use |
|------|------|----------------|
| `Read` | Read a file | Read `src/index.ts` |
| `Write` | Create a file | Create `src/utils/format.ts` |
| `Edit` | Modify an existing file | Fix a function |
| `Bash` | Run a shell command | `npm test`, `git status` |
| `Glob` | Find files by pattern | All `*.test.ts` |
| `Grep` | Search for content in files | All occurrences of `userId` |
| `Agent` | Launch a sub-agent | Delegate a complex analysis |
| `WebFetch` | Download a URL | Read a library's docs |
| `WebSearch` | Search on the web | Find the solution to an error |
| `NotebookEdit` | Modify a Jupyter notebook | Add a Python cell |
| MCP tools | Capabilities added by plugins | GitHub, database, Slack... |

MCP (Model Context Protocol) tools are extensions. The foundation configures several (GitHub, filesystem, memory). See Module 7.

---

## Module 3: Permissions and security (30 min)

### The permission dialog

When Claude Code wants to execute an action, it displays a dialog:

```
Claude wants to run:
  rm -rf dist/

[Allow] [Deny] [Always Allow]
```

| Choice | Effect |
|--------|--------|
| Allow | Authorizes this action only once |
| Deny | Denies this action, Claude finds another approach |
| Always Allow | Authorizes this action for the entire session |

### The 5 permission modes

| Mode | Description | Who can use it |
|------|-------------|----------------|
| `default` | Asks for confirmation for each action | Everyone |
| `acceptEdits` | Auto-approves file modifications, asks for the rest | Everyone |
| `plan` | Read-only, Claude can read but not modify or execute | Everyone |
| `auto` | Approves everything except explicitly dangerous actions | Max, Team, Enterprise, API |
| `bypassPermissions` | Approves absolutely everything (dangerous, to avoid) | API only |

**`plan` mode** is particularly useful: Claude reads your code and proposes a detailed plan without touching anything. You validate, then you change mode to execute.

### Switching modes during a session

`Shift+Tab` cycles between the modes available for your plan. The mode indicator is displayed in the prompt.

### Configuring permissions in settings.json

To allow or deny specific tools permanently:

```json
{
  "allowedTools": ["Read", "Write", "Edit", "Bash"],
  "disallowedTools": ["WebSearch", "WebFetch"]
}
```

Practical example — allow everything except destructive commands:
```json
{
  "disallowedTools": ["Bash(rm *)", "Bash(git push --force)"]
}
```

You can restrict `Bash` to specific commands with the `Bash(command)` syntax.

---

## Module 4: Native commands (30 min)

### Built-in slash commands

These commands are available in any Claude Code session, without additional configuration.

| Command | Description | When to use it |
|---------|-------------|----------------|
| `/help` | Displays the help and the list of commands | Anytime |
| `/compact` | Compacts the context while preserving the essentials | Long session, before changing phase |
| `/clear` | Erases the entire conversation | New unrelated topic |
| `/config` | Opens the settings in the editor | Modify the configuration |
| `/cost` | Displays token consumption and session costs | Monitor costs |
| `/doctor` | Diagnoses installation and configuration issues | When something doesn't work |
| `/effort` | Changes the reasoning level (low / medium / high) | Adapt the depth of analysis |
| `/fast` | Toggles fast mode (same model, accelerated output) | Simple tasks, save time |
| `/model` | Changes model (Opus, Sonnet, Haiku) | Match the model to the task |
| `/memory` | Displays all loaded instructions (CLAUDE.md, rules, etc.) | Debug the context |
| `/resume` | Resumes a previously named session | Continue an interrupted session |
| `/rewind` | Returns to the previous checkpoint (before the last modification) | Undo a modification that broke everything |
| `/theme` | Changes the visual theme (dark, light, etc.) | Personal preference |
| `/terminal-setup` | Configures Shift+Enter in your terminal | Initial installation |
| `/vim` | Toggles vim mode for editing prompts | Vim preference |
| `/btw` | Asks a quick question without polluting the session context | Side questions |
| `/desktop` | Opens the session in the Desktop application | Switch to desktop mode |
| `/schedule` | Creates a recurring scheduled task | Automation |
| `/loop` | Repeats a prompt at regular intervals | Monitoring, polling |

### Examples of use

```bash
# See how much this session has cost
/cost

# Switch to read-only mode before letting Claude analyze
/effort high
# then ask for the architectural analysis

# Go back after a catastrophic modification
/rewind

# Switch model for a quick task
/model haiku

# Quick question on a detail without impacting the session
/btw what is the difference between null and undefined in TypeScript?
```

---

## Module 5: Context and memory (30 min)

### The context window

Claude Code uses a "context window" — the total amount of information it can process at once (conversation, files read, command results).

| Model | Context | Approximate equivalent |
|-------|---------|------------------------|
| Haiku 4.5 | 200k tokens | ~150,000 words |
| Sonnet 4.6 | 200k tokens | ~150,000 words |
| Opus 4.7 | 1M tokens | ~750,000 words (~5 novels) |

When the context is full, responses become less accurate (Claude "forgets" the beginnings of the session). `/compact` solves this problem.

### CLAUDE.md: the project instructions file

`CLAUDE.md` is a Markdown file placed at the root of your project. Claude Code reads it automatically at the start of each session. It's your way to give permanent instructions without retyping them every time.

**Three levels of CLAUDE.md:**

| Level | Location | Versioned? | Typical content |
|-------|----------|------------|-----------------|
| Project | `/my-project/CLAUDE.md` | Yes (git) | Conventions, workflow, doc references |
| User | `~/.claude/CLAUDE.md` | No (personal) | Personal preferences, preferred code style |
| Subfolder | `/my-project/src/CLAUDE.md` | Yes | Instructions specific to this module |

**Minimal example of CLAUDE.md:**
```markdown
# My Project

## Conventions
- TypeScript strict mode, no `any`
- Tests with Vitest, 80% minimum coverage
- Commits in Conventional Commits

## Stack
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL
```

**@imports to include other files:**

Rather than putting everything in CLAUDE.md, you can include other files:

```markdown
# My Project

@.claude/docs/reference/best-practices.md
@.claude/docs/reference/project-structures.md
```

These files are loaded automatically. Useful to avoid having a 500-line CLAUDE.md.

### Auto-memory

Claude Code automatically memorizes your preferences and decisions in `~/.claude/memory/`. This information persists between sessions.

```
# Claude does it automatically when you say:
"Remember that I prefer functional components over classes"
"Remember that this project uses yarn, not npm"
```

To force an explicit memorization: say "remember that..." followed by what you want to retain.

### When to use `/compact` vs `/clear`

| Situation | Action | Why |
|-----------|--------|-----|
| Long session, same topic | `/compact` | Preserves the essential context, frees up space |
| Context almost full | `/compact` | Avoids losing quality |
| Between two phases (Explore → Plan) | `/compact` | Restart with a clean base |
| New unrelated topic | `/clear` | Start over from scratch |
| Claude seems to "lose track" | `/compact` | Recondense key information |

`/compact` is almost always preferable to `/clear`: it preserves decisions and conventions learned during the session.

### Automatic context compaction

When the context reaches ~90% of its capacity, Claude Code compacts automatically. You'll see a message:

```
Context compacted. Summary preserved.
```

This happens without your intervention.

### Named sessions

```bash
# Start a session with a name
claude -n "feature-auth"

# Later, resume exactly where you left off
claude -r "feature-auth"

# Or from inside a session
/resume feature-auth
```

Useful for long features that span several days.

### Checkpoints and `/rewind`

Claude Code automatically saves a checkpoint before each modification. If an operation breaks everything:

```bash
/rewind
```

Returns to the exact state before the last modification. Faster than `git stash` or `git checkout`.

---

## Module 6: Keyboard shortcuts (15 min)

### Complete reference

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel the current generation |
| `Ctrl+D` | Quit Claude Code |
| `Ctrl+G` | Open the prompt in an external editor |
| `Ctrl+L` | Redraw the display (useful if the terminal is corrupted) |
| `Ctrl+O` | Verbose mode (display all tool call details) |
| `Ctrl+R` | Search in prompt history |
| `Ctrl+T` | Display the list of current tasks |
| `Ctrl+B` | Move the task to the background |
| `Esc` + `Esc` | Quick rewind / summarize |
| `Shift+Tab` | Cycle between permission modes |
| `Alt+P` | Change model |
| `Alt+T` | Toggle thinking (visible reasoning) |
| `Alt+O` | Toggle fast mode |

### Editing text in the prompt

| Shortcut | Action |
|----------|--------|
| `Ctrl+K` | Delete from cursor to end of line |
| `Ctrl+U` | Delete from beginning of line to cursor |
| `Ctrl+Y` | Paste what was deleted with Ctrl+K or Ctrl+U |
| `Ctrl+A` | Go to the beginning of the line |
| `Ctrl+E` | Go to the end of the line |
| `Alt+F` | Move forward one word |
| `Alt+B` | Move back one word |

### Configuring Shift+Enter

By default, `Enter` sends the prompt. To configure `Shift+Enter` as "new line" in your terminal:

```bash
/terminal-setup
```

This command modifies your terminal's configuration (iTerm2, Ghostty, etc.) so that `Shift+Enter` inserts a new line.

---

## Module 7: Advanced configuration (30 min)

### Settings files

Claude Code loads settings in this order (from most general to most specific):

| File | Scope | Versioned? | Usage |
|------|-------|------------|-------|
| `~/.claude/settings.json` | All your projects | No | Global personal preferences |
| `.claude/settings.json` | This project (entire team) | Yes | Shared project configuration |
| `.claude/settings.local.json` | This project (you only) | No (gitignore) | Local overrides, API keys |

More specific settings override more general settings.

**Example of `.claude/settings.json`:**
```json
{
  "model": "claude-sonnet-4-6",
  "allowedTools": ["Read", "Write", "Edit", "Bash", "Glob", "Grep"],
  "env": {
    "NODE_ENV": "development"
  }
}
```

### Effort levels

The effort level controls the depth of Claude's reasoning. The higher the effort, the more Claude thinks — and the more time and tokens it consumes.

| Level | Command | When to use it | Example |
|-------|---------|----------------|---------|
| low | `/effort low` | Explore code, read files, simple questions | "What does this file do?" |
| medium | `/effort medium` | Implement a standard feature, fix a bug | "Add email validation" |
| high | `/effort high` | Design an architecture, major refactoring, audit | "Refactor the auth module" |
| max | `/effort max` | Complex debug, critical security (Opus 4.7 only) | "Find the memory leak" |

### Available models

| Model | Strength | Use case | Speed |
|-------|----------|----------|-------|
| Opus 4.7 | Best reasoning, 1M context | Architecture, audit, complex debug | Slow |
| Sonnet 4.6 | Quality/speed balance | Daily development | Medium |
| Haiku 4.5 | Very fast | Simple tasks, rephrasing, questions | Fast |

Switch model:
```bash
/model opus     # Opus 4.7
/model sonnet   # Sonnet 4.6 (default)
/model haiku    # Haiku 4.5
```

Or on the command line:
```bash
claude --model claude-opus-4-6
```

### Fast mode

`/fast` or `Alt+O` activates a mode where Claude produces responses faster with the same model. Useful for rephrasing, clarification questions, or when maximum quality is not necessary.

### Hooks

Hooks are shell commands automatically executed at specific moments in the Claude Code lifecycle.

| Hook | When it triggers | Typical usage |
|------|------------------|---------------|
| `SessionStart` | At the beginning of each session | Load the environment, display a message |
| `PreToolUse` | Before a tool is executed | Validate, block dangerous commands |
| `PostToolUse` | After a tool is executed | Auto-format, lint, type-check |
| `Notification` | When Claude wants to notify you | Send a system notification |

**Example: auto-format after each file modification**

In `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$CLAUDE_TOOL_RESULT_PATH\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

This hook runs Prettier automatically each time Claude modifies or creates a file.

### MCP (Model Context Protocol)

MCP is a standard protocol that allows connecting Claude Code to external services. An "MCP server" is a program that exposes additional tools.

**What does an MCP server bring?**

| MCP Server | Tools added | Example of use |
|------------|-------------|----------------|
| `@modelcontextprotocol/server-github` | Read PRs, create issues | "Create an issue for this bug" |
| `@modelcontextprotocol/server-filesystem` | Extended access to the filesystem | Read files outside the project |
| `@modelcontextprotocol/server-memory` | Structured persistent memory | Store architecture decisions |
| `@modelcontextprotocol/server-postgres` | Read/write to database | "How many active users this month?" |

**Configure in `.mcp.json`:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

MCP servers are disabled by default in claude-base for security reasons. Enable only those you need.

---

## Module 8: Practical workflows (30 min)

### Exploring an unknown project

```bash
cd unknown-project
claude "explain this project: what does it do, what's the stack, and where should I start?"
```

Claude automatically reads `package.json`, `README.md`, the main files and gives you a structured overview.

### Fixing a bug

The most effective method: paste the exact error message.

```bash
# Option 1: paste the error directly
claude "TypeError: Cannot read properties of undefined (reading 'userId')
  at getUserProfile (src/api/users.ts:42:18)
  Fix this."

# Option 2: let Claude find the error
claude "The tests are failing. Investigate and fix."
```

### Creating a feature

```bash
claude "Add email verification to the registration flow:
- Send a verification email after registration
- Add a /verify-email endpoint that validates the token
- Block login until email is verified
Use the existing mailer service in src/services/mailer.ts"
```

The more precise you are, the better the result. Indicate the existing files to reuse, the constraints, the expected behaviors.

### Creating a commit and a PR

```bash
# Commit only
claude "commit my changes with a descriptive conventional commit message"

# Commit + push + GitHub PR
claude "commit, push, and create a PR for these changes. Title: Add email verification"
```

### Code review

```bash
# Review of local changes
claude "review the changes I've made. Check for bugs, security issues, and style."

# Review of a GitHub PR (with MCP GitHub configured)
claude "review PR #42 and leave inline comments"
```

### Refactoring

```bash
claude "refactor src/services/payment.ts for readability:
- extract helper functions
- add JSDoc comments
- reduce function complexity
Keep the same behavior — all tests must still pass"
```

### Git worktrees: working in parallel

Git worktrees allow having several branches checked out at the same time in different folders. With Claude Code, you can launch several sessions in parallel on independent features.

```bash
# Create a worktree for a feature
git worktree add ../my-project-auth feature/auth

# Launch Claude Code in this worktree
cd ../my-project-auth
claude -n "feature-auth"

# Meanwhile, in another terminal
cd my-project
claude -n "feature-dashboard"
```

The two Claude Code sessions run in parallel and don't interfere. This is the recommended pattern for maximum productivity.

### Piping: sending content from stdin

```bash
# Analyze a log file
cat server.log | claude -p "summarize the errors in the last hour"

# Analyze the output of a command
npm test 2>&1 | claude -p "explain which tests failed and why"

# Reformat JSON
cat data.json | claude -p "convert this JSON to a markdown table"
```

### Headless mode in CI

```bash
# In a CI pipeline, without interaction
claude -p "run the tests, fix any failures, and report what you changed"

# With a specific model and a token limit
claude -p "check for security vulnerabilities" --model claude-haiku-4-5
```

The `-p` (print) flag activates non-interactive mode: Claude executes the task and exits. Ideal for automated pipelines.

---

## Module 9: Troubleshooting (15 min)

### Symptom / solution table

| Symptom | Probable cause | Solution |
|---------|----------------|----------|
| Claude answers off-topic | Context too long or polluted | `/compact` then ask the question again |
| Claude "forgets" instructions | CLAUDE.md misconfigured | `/memory` to check what is loaded |
| Too many permission dialogs | `default` mode active | `Shift+Tab` to switch to `acceptEdits` |
| Very slow session | Model too powerful for the task | `/model haiku` or `/fast` |
| File not found by Claude | Ambiguous relative path | Use `@path/full.ts` or an absolute path |
| MCP server doesn't start | Configuration error | Check `.mcp.json`, consult logs with `--debug` |
| "context too long" error | Context window exceeded | `/compact` immediately |
| Claude does something unexpected | Prompt too vague | Be more specific, describe the expected state |
| Catastrophic modification | Bug in the refactoring | `/rewind` to go back before the modification |
| Claude can't find packages | node_modules environment missing | `!npm install` to install the dependencies |

### `/doctor`: automatic diagnosis

```bash
/doctor
```

Checks: authentication, connectivity, Claude Code version, MCP configuration, settings. Displays a report with the detected issues and suggested solutions.

### Debug mode

To get detailed logs:

```bash
claude --debug
```

Displays all API calls, loaded configurations, MCP errors. Useful to diagnose advanced configuration problems.

### Update

```bash
# Check the current version
claude --version

# Update
npm update -g @anthropic-ai/claude-code
# or
brew upgrade claude
```

---

## Transition to the foundation

You now master Claude Code. Here's what claude-base adds on top:

**Without the foundation**, Claude Code is a powerful but "blank" agent. At each session, you have to explain your conventions, your workflow, what you expect from it.

**With the foundation**, these instructions are pre-configured and activated automatically:

| What the foundation adds | Description |
|--------------------------|-------------|
| <!-- count:commands -->129<!-- /count --> commands (`/work:*`, `/dev:*`, `/qa:*`, `/ops:*`) | Pre-written workflows for common tasks |
| <!-- count:agents -->62<!-- /count --> specialized agents | Sub-processes for audit, security, tests, etc. |
| <!-- count:skills -->53<!-- /count --> skills | Behaviors triggered by keywords |
| <!-- count:rules -->30<!-- /count --> rules | Code conventions activated automatically based on the modified files |
| Structured workflow | Explore → Specify → Plan → TDD → Audit → Commit |

The concrete difference: instead of typing "run the tests, check coverage, fix issues, audit security, then commit", you type `/work:work-flow-feature "my feature"` and the foundation orchestrates everything.

### Next steps

- [Foundation Quick Start](/docs/intro/quick-start) — Install and configure the foundation in 5 minutes
- [Learning Path](/docs/guides/learning-path) — From novice to expert in 9h30

---

*This guide covers Claude Code CLI version 2.x. Commands and shortcuts may vary depending on updates.*
