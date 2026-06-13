# Foundation Extension Guide

> How to customize and extend the claude-base foundation for your own projects.

> **Dual audience**: this guide covers two distinct cases.
>
> - **You are extending your user project** (adding custom commands/rules/skills): your `@imports` in `CLAUDE.md` should point to `@.claude/docs/...` (since the foundation's documentation is installed under `.claude/docs/` on your side).
> - **You are contributing to the claude-base repo**: the foundation's `@imports` point to `@docs/...` (the foundation keeps its documentation directly under `docs/`). See also [CONTRIBUTING.md](https://github.com/christopherlouet/claude-base/blob/main/CONTRIBUTING.md).

## Overview

The foundation is designed to be extended. Four main extension points exist:

| Element | Location | Purpose |
|---------|----------|---------|
| Rules | `.claude/rules/` | Apply conventions based on file type |
| Skills | `.claude/skills/` | Encapsulate a reusable workflow |
| Agents | `.claude/agents/` | Orchestrate a workflow with a dedicated LLM |
| Hooks | `.claude/settings.json` | Automate pre/post tool actions |

---

## 1. Create a custom Rule

Rules are Markdown files with YAML frontmatter that define constraints and conventions. They activate automatically when Claude modifies a file matching the declared paths.

### Frontmatter format

```yaml
---
paths:
  - "**/*.vue"
  - "**/components/**"
---

# Vue Rules

## Conventions
- IMPORTANT: Use the Composition API (not Options API)
- YOU MUST declare props with defineProps<T>()
```

The frontmatter is optional. Without `paths`, the rule applies globally to all interactions.

### Location

Create the file in `.claude/rules/`:

```
.claude/rules/vue.md
.claude/rules/my-framework.md
```

### Complete example: rule for Svelte

```markdown
---
paths:
  - "**/*.svelte"
  - "**/src/lib/**"
  - "**/src/routes/**"
---

# Svelte Rules

## Component structure

| Element | Convention | Example |
|---------|-----------|---------|
| Script | `<script lang="ts">` | Always TypeScript |
| Stores | Native Svelte stores | `writable<User \| null>(null)` |
| Props | `export let prop: Type` | Explicit typing required |

## Conventions

- IMPORTANT: Prefer Svelte stores over an external state manager
- YOU MUST type all exported props
- NEVER use `any` in Svelte components
- File naming: PascalCase for components, kebab-case for routes

## Lifecycle

- Prefer `onMount` over `beforeUpdate` for side effects
- Required cleanup in `onDestroy` for subscriptions
```

### Test the trigger

Modify a `.svelte` file and verify in the Claude Code session that the rule appears loaded. Rules are displayed in session information at startup (`InstructionsLoaded` hook).

To force reload: restart a session or use `/clear`.

---

## 2. Create a Skill

A skill is a `SKILL.md` file in a subfolder of `.claude/skills/`. It encapsulates a complete workflow with its instructions, examples and constraints.

> Since CLI 2.1.x, **slash commands and skills are unified**: each skill automatically gets a `/slash-command` interface. Files in `.claude/commands/` continue to work for compatibility, but the recommended approach for any new workflow is `.claude/skills/`. The foundation keeps `.claude/commands/` only for namespaced shortcuts (e.g., `/work:work-pr`).

### Folder structure

```
.claude/skills/my-skill/
├── SKILL.md          # Required definition
├── examples/         # Concrete examples (optional)
└── references/       # Reference files (optional)
```

### SKILL.md format

```yaml
---
name: my-skill
description: What the skill does. Trigger when the user [context].
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[project-name] [options]"
---

# Skill Title

## Purpose
Description in 1-2 sentences.

## Instructions

1. Step 1
2. Step 2
3. Step 3

## Expected output
Output format.

## Rules
- IMPORTANT: Critical rule
- NEVER: What must never be done
```

### Available frontmatter fields

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `name` | No | kebab-case | Skill name (default: folder name) |
| `description` | Recommended | text | Trigger context |
| `allowed-tools` | No | list | Tools authorized without confirmation |
| `context` | No | `fork` | Execution in an isolated sub-agent |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` | Model to use |
| `argument-hint` | No | text | Autocompletion in the `/` menu |
| `disable-model-invocation` | No | `true`/`false` | Manual invocation only |
| `user-invocable` | No | `true`/`false` | Visible in the `/` menu |

### Best practices

- Limit SKILL.md to 500 lines maximum. Move detail to `examples/` or `references/`
- Declare only the necessary tools (least privilege principle)
- Always use `context: fork` for isolation
- Write the `description` with the trigger context: Claude uses this field to automatically decide when to load the skill
- Prefer tables over prose for quick references

### Tools by skill type

| Skill type | Recommended tools |
|------------|-------------------|
| Read-only (audit, review) | `Read`, `Glob`, `Grep` |
| Development | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| Documentation | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Analysis | `Read`, `Glob`, `Grep` |
| Infrastructure | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |

### Complete example: changelog generation skill

```yaml
---
name: changelog-entry
description: Generates a CHANGELOG.md entry from recent commits. Trigger when the user wants to document a release or update the changelog.
allowed-tools:
  - Read
  - Edit
  - Bash
  - Glob
context: fork
model: sonnet
argument-hint: "[version] [since-tag]"
---

# Generate a Changelog Entry

## Purpose

Analyze Git commits since the last tag and generate a CHANGELOG.md entry
formatted according to Keep a Changelog.

## Instructions

1. Read the existing CHANGELOG.md to understand the format used
2. Retrieve commits: `git log <since-tag>..HEAD --oneline`
3. Group commits by type (feat, fix, refactor, docs, etc.)
4. Generate the entry in Keep a Changelog format
5. Insert at the beginning of CHANGELOG.md, after the title

## Output format

\`\`\`markdown
## [1.2.0] - 2026-04-03

### New features
- Clear description of the feature (ref: commit abc123)

### Fixes
- Description of the bug fixed (ref: commit def456)
\`\`\`

## Rules

- NEVER modify existing changelog entries
- IMPORTANT: Use the ISO date format (YYYY-MM-DD)
- Exclude style and chore commits unless significant
```

---

## 3. Create an Agent

An agent is a `.md` file in `.claude/agents/`. It combines a YAML frontmatter (sub-agent configuration) with Markdown instructions (behavior).

### Agent format

```yaml
---
name: my-agent
description: Short description. Trigger when [usage context].
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
permissionMode: default
skills:
  - my-skill
---

# Agent MY-AGENT

Body of the agent's instructions.
```

### Agent frontmatter fields

| Field | Description |
|-------|-------------|
| `name` | Agent identifier (kebab-case) |
| `description` | Automatic activation context |
| `tools` | Authorized tools (comma-separated) |
| `model` | `sonnet`, `opus`, `haiku` |
| `permissionMode` | `default`, `acceptEdits`, `bypassPermissions` |
| `skills` | List of skills to load |
| `hooks` | Hooks scoped to the agent's lifecycle |

### When to use agent vs skill vs command

| Need | Solution | Reason |
|------|----------|--------|
| Reusable workflow with instructions | Skill | Invokable via `/name`, shared between agents |
| Isolated execution with dedicated LLM | Agent | Sub-agent with its own context |
| Sequence of bash commands | Command `.md` | Prompt without additional LLM |
| Automation without interaction | Hook | Executes a script at the right moment |

### Complete example: dependency audit agent

```yaml
---
name: deps-audit
description: Audit of obsolete or vulnerable dependencies. Trigger when the user wants to check or update project dependencies.
tools: Read, Bash, Glob, Edit
model: sonnet
permissionMode: default
---

# Agent DEPS-AUDIT

Analyzes project dependencies and produces a report classified by criticality.

## Workflow

1. Detect the package manager (npm, pnpm, yarn, pip, go mod)
2. Run the vulnerability audit (`npm audit`, `pip-audit`, etc.)
3. Identify outdated dependencies
4. Classify by criticality: CRITICAL > HIGH > MEDIUM > LOW
5. Propose an update plan

## Output

Structured report with:
- Vulnerability table by level
- Update commands to execute
- Dependencies to watch (potential breaking changes)

## Rules

- NEVER automatically update major dependencies without confirmation
- IMPORTANT: Check breaking changes before proposing a major update
```

### Agent naming

Follow the existing `domain-action` convention:

| Domain | Prefix | Examples |
|--------|--------|----------|
| Development | `dev-` | `dev-api`, `dev-tdd`, `dev-debug` |
| Quality | `qa-` | `qa-review`, `qa-security` |
| Operations | `ops-` | `ops-deploy`, `ops-docker` |
| Documentation | `doc-` | `doc-generate`, `doc-changelog` |
| Business | `biz-` | `biz-model`, `biz-mvp` |
| Workflow | `work-` | `work-explore`, `work-plan` |

---

## 4. Create a Hook

Hooks allow automating actions at specific moments in the lifecycle of a Claude Code session. They are configured in `.claude/settings.json` (global hooks) or in the frontmatter of an agent/skill (scoped hooks).

### Hook types

| Type | Description | Use case |
|------|-------------|----------|
| `command` | Executes a bash script | Validation, formatting, logging |
| `prompt` | Evaluated via a Haiku LLM | Smart contextual verification |
| `http` | POST JSON to a URL | External webhook, CI/CD |

### Available events

| Event | Trigger | Typical usage |
|-------|---------|---------------|
| `SessionStart` | Session start | Display project info, check prereqs |
| `PreToolUse` | Before tool execution | Validate, block, transform |
| `PostToolUse` | After successful execution | Format, lint, notify |
| `Stop` | End of Claude response | Final validation, logging |
| `PreCompact` | Before context compaction | Save state |
| `SessionEnd` | End of session | Cleanup, report |

### Hook properties

| Property | Description |
|----------|-------------|
| `type` | `command`, `prompt`, or `http` |
| `command` | Bash script to execute (type `command`) |
| `matcher` | Filter on tool name (regex) |
| `timeout` | Timeout in milliseconds |
| `onFailure` | `"block"` or `"ignore"` |
| `async` | `true` for background execution |

### When to use async

| Situation | async | Reason |
|-----------|-------|--------|
| Logging, monitoring | `true` | Does not block the workflow |
| Blocking validation | `false` | Must execute before continuing |
| Auto formatting | `false` | Must finish before the next tool |
| External webhook | `true` | Non-blocking network latency |

### Example: PostToolUse hook to format SQL

In `.claude/settings.json`, `hooks` section:

```json
{
  "PostToolUse": [
    {
      "description": "Format SQL files with sqlfluff",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'if command -v sqlfluff >/dev/null 2>&1; then FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *.sql ]]; then sqlfluff fix --dialect ansi \"$FILE\" 2>/dev/null && echo \"[SQL] Formatted: $FILE\"; fi; fi'",
          "timeout": 10000,
          "onFailure": "ignore"
        }
      ]
    }
  ]
}
```

### Example: PreToolUse hook for business validation

```json
{
  "PreToolUse": [
    {
      "description": "Prevent modification of production configuration files",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *prod* ]] || [[ \"$FILE\" == *production* ]]; then echo \"BLOCKED: Modification of a production file detected. Use ALLOW_PROD_EDIT=1 to force.\"; if [ \"$ALLOW_PROD_EDIT\" != \"1\" ]; then exit 1; fi; fi'",
          "timeout": 5000,
          "onFailure": "block"
        }
      ]
    }
  ]
}
```

### Hooks in settings.local.json

For hooks specific to your machine (not committed):

```json
// .claude/settings.local.json
{
  "hooks": {
    "PostToolUse": [
      {
        "description": "Desktop notification after each modification",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'notify-send \"Claude Code\" \"File modified\" 2>/dev/null || true'",
            "timeout": 3000,
            "async": true,
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

---

## 5. Customize CLAUDE.md

`CLAUDE.md` is the project's main configuration file. It is loaded at every session.

### @import pattern

```markdown
@path/to/file.md
```

Imported files are injected directly into the context. Use for bulky references that are not necessary for every session.

Files always loaded (imports in this project):
- `@docs/reference/best-practices.md`
- `@docs/reference/project-structures.md`

### What belongs where

| Element | Location | Reason |
|---------|----------|--------|
| Mandatory workflow | `CLAUDE.md` | Applies to the whole team |
| Code conventions | `CLAUDE.md` or rules | Depending on whether contextual or global |
| Personal preferences | `~/.claude/memory/` | Not committed, personal |
| Conventions per language | `.claude/rules/<lang>.md` | Active only on the relevant files |
| Architecture decisions | `~/.claude/memory/` | Memorized per session |
| Long references | Separate file with `@import` | Avoids overloading the context |

### Recommended content for CLAUDE.md

```markdown
# My Project

> Short project description

## Workflow

[Adapt the mandatory workflow to the project's context]

## Conventions

[Project-specific conventions, not covered by rules]

## References

| Topic | File |
|-------|------|
| Architecture | `docs/ARCHITECTURE.md` |
| API | `docs/api/README.md` |
```

### What must not be put in CLAUDE.md

- Secrets, credentials, tokens (use `.env`)
- Information that changes often (dependency versions, etc.)
- Content duplicated from rules (useless, increases context)
- History of decisions (use CHANGELOG.md or git log)

---

## 6. Contribute to the foundation

### Fork and PR workflow

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/<you>/claude-base.git
cd claude-base

# 3. Create a feature branch
git checkout -b feature/my-python-typing-skill

# 4. Create or modify files
# 5. Test manually in a Claude Code session
# 6. Verify counter consistency
./scripts/validate-counts.sh

# 7. Commit using Conventional Commits
git commit -m "feat(skills): add python-typing skill for strict type annotations"

# 8. Push and create the PR
git push origin feature/my-python-typing-skill
gh pr create --title "feat(skills): add python-typing skill" --body "..."
```

### Naming conventions

| Type | Convention | Example |
|------|-----------|---------|
| Skills | `domain-action` | `dev-typing`, `qa-mutation` |
| Agents | `domain-action` | `dev-typing`, `qa-mutation` |
| Rules | language/framework name | `svelte.md`, `fastapi.md` |
| Commands | `domain/action.md` | `dev/dev-typing.md` |
| Branches | `feature/xxx`, `fix/xxx` | `feature/svelte-rule` |
| Commits | Conventional Commits | `feat(rules): add svelte rule` |

### Pre-PR checklist

```
[ ] The skill/agent has a kebab-case name following the domain-action convention
[ ] The YAML frontmatter is valid (name, description, allowed-tools)
[ ] The description contains the trigger context
[ ] Declared tools are the minimum necessary
[ ] context: fork is present for skills
[ ] The file is under 500 lines
[ ] Code examples are relevant and functional
[ ] validate-counts.sh passes without error
[ ] Reference documentation is updated if necessary
```

### validate-counts.sh compliance

When you add a skill, an agent, a rule or a command, several documentation files must be updated to reflect the new counters:

| File | Counter to update |
|------|-------------------|
| `README.md` | Number of commands |
| `CLAUDE.md` | Number of commands, agents, skills |
| `docs/reference/agents-catalog.md` | File header |
| `website/src/pages/index.tsx` | Homepage statistics |
| `website/docs/intro/architecture.md` | Architecture counters |

Run `./scripts/validate-counts.sh --fix` to identify inconsistencies. Manually correct numerical values in the flagged files.

### Quality PR structure

```markdown
## Description
Add a `svelte` skill for Svelte 5 development conventions.

## Motivation
The foundation did not cover Svelte. This skill activates Composition API conventions,
prop typing, and store management automatically on `.svelte` files.

## Changes
- `.claude/skills/dev-svelte/SKILL.md`: new skill
- `.claude/rules/svelte.md`: associated rule
- `docs/reference/skills-catalog.md`: entry added
- Counters updated in README.md, CLAUDE.md, website

## Tests
- Tested manually by modifying a .svelte file in a Claude Code session
- validate-counts.sh passes

## Checklist
- [x] Naming conventions respected
- [x] validate-counts.sh OK
- [x] Documentation updated
```

---

## 7. Native plugin migration: current state

Claude Code shipped a native plugin system between CLI 2.1.119 and 2.1.126 (April-May 2026). At first glance, porting `claude-base` to a native plugin (`claude plugin install claude-base`) would unlock distribution via the Anthropic marketplace. **This is not the path the foundation has taken — yet.**

### Why we kept the standalone `.claude/` foundation

A research pass on May 4, 2026 against the official plugin docs ([code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)) surfaced three documented gaps that prevent a clean port today:

| Gap | Impact on `claude-base` |
|---|---|
| **Rules (`.claude/rules/`) are not a plugin component** | The 30 path-specific rules in this foundation cannot ship via plugin. Users would need to copy them manually post-install. |
| **`settings.json` scope inside plugins is limited** to `agent` and `subagentStatusLine` | Plugins cannot configure `permissions`, `env`, or top-level `hooks` for the user's session. Foundation defaults (deny lists, env, ~15 PostToolUse hooks) cannot be auto-installed. |
| **No first-install / setup callback** | `scripts/new-project.sh` (the foundation orchestrator) has no equivalent. A plugin user gets skills/agents/commands immediately but no workspace setup. |

For a foundation whose value sits in the **integration of all four extension types plus settings + setup logic**, losing two of those layers (rules + settings + setup) is a non-starter today.

### When porting will make sense

Re-evaluate when at least 2 of the 3 gaps land:

- Plugin manifests gain a `rules/` contribution type
- Plugin `settings.json` scope expands to include at least `permissions` and `env`
- A documented `postInstall` / setup hook arrives for plugins

Track the [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) for these features. Realistic window: 6-12 months.

### For contributors who want to publish their own pack

If you've extended the foundation with a thematic pack (e.g. a `stripe-pack`, a `rails-pack`) and want it shareable today **without depending on `claude-base`**, native plugins are a solid option:

- Manifest format: `.claude-plugin/plugin.json` (JSON, not YAML)
- Repo layout: `commands/`, `agents/`, `skills/`, `hooks/hooks.json` at the plugin root
- Installation: `claude plugin install <github-org>/<repo>`
- Marketplace: list it on [claudemarketplaces.com](https://claudemarketplaces.com/) once stable
- Reference: [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)

Note that as of May 2026 the marketplace is dominated by **single-purpose plugins** (1-5 skills each). Foundation-scale plugins are rare; smaller atomic packs align better with current ecosystem conventions.

### What if you want both

A pragmatic interim pattern: **keep `claude-base` as your project's `.claude/` template** (for the integrated foundation experience), and **layer external native plugins on top** for vertical-specific additions (e.g. install a community Stripe plugin alongside the foundation). The two systems coexist cleanly — they read different config namespaces.

---

## 8. Author a preset

A **preset** is a curated stack bundle that, on `claude-base init --preset <name>`, configures the foundation (rules / commands / agents / skills filter, defaults, marketplace pointers) for a specific stack. The catalogue lives under `.claude/presets/`.

### Pick the right tier

Three tiers, with different bars to ship :

| Tier | Authority source | Bar | Manifest content |
|---|---|---|---|
| `maintainer-vouched` | The maintainer's prod use | ≥ 3 months production use + monthly review commitment | Opinionated `foundation.skills.keep` / `drop` filter, curated `marketplacePlugins`, `recommendedVendorSkills`, `defaults` (CI/hooks/MCP/Docker/designStyle) |
| `community-curated` | A community contributor's prod use | Signed maintenance commitment ≥ 1 year, issue-first proposal | Same as maintainer-vouched but lives under `.claude/presets/community/` |
| `vendor-pointer` | The vendor's authorship of the pointed-to skill (validated via the marketplace-audit methodology) | Vendor source already validated in `docs/recipes/recommended-vendor-skills.md`. No prod-use claim required from the shipper. | **Forbidden**: `foundation.skills.*`, `marketplacePlugins`, `defaults` overrides. **Required**: `recommendedVendorSkills` with ≥ 1 entry, simple `detect` (1 signal exactly). |

The `vendor-pointer` tier is the **lowest-cost contribution path** for stacks where a vendor publishes a canonical skill suite (Phaser, Playwright, Apollo, MongoDB, Pulumi…). See [`specs/presets-vendor-pointer-tier/spec.md`](../../specs/presets-vendor-pointer-tier/spec.md) for the full enforcement rules (EF-003/004/005).

### Minimal manifest (vendor-pointer)

```json
{
  "$schema": "https://github.com/christopherlouet/claude-base/blob/main/specs/presets/schema.json",
  "name": "myvendor",
  "displayName": "MyVendor (vendor-pointer)",
  "description": "Pointer-only preset for MyVendor. Surfaces the canonical skill suite at install time.",
  "version": "1.0.0",
  "status": "vendor-pointer",
  "appliesToTypes": ["generic"],
  "detect": {
    "combinator": "anyOf",
    "depFiles": [
      {"path": "package.json", "contains": "\"myvendor\":"}
    ]
  },
  "recommendedVendorSkills": [
    {
      "id": "myvendor/skills",
      "url": "https://github.com/myvendor/skills",
      "rationale": "Canonical MyVendor skill suite. Verified via gh api on YYYY-MM-DD — N stars, MIT, not archived.",
      "condition": "always"
    }
  ],
  "categories": ["api-backend"],
  "outOfScope": [],
  "relatedPresetsWanted": []
}
```

### Declare a `categories[]` for menu discovery

When `claude-base init` runs on an empty directory without `--preset` / `--type`, a pre-detection prompt asks "What are you building?" with an 8-entry intent taxonomy (locked enum, mirrored by [`specs/presets/roadmap.md`](../../specs/presets/roadmap.md) §"Category taxonomy") :

`web-frontend` · `api-backend` · `mobile-desktop` · `game-interactive-media` · `data-database` · `infra-devops` · `cli-automation` · `other-generic`

A preset declares `categories: [<slug>]` to opt into the filtered menu after the user picks a category. Multi-category is allowed for legitimately cross-cutting cases (e.g. `["web-frontend", "api-backend"]` for `nextjs` or `playwright`). Validation is strict-enum — see [`specs/preset-category-prompt/spec.md`](../../specs/preset-category-prompt/spec.md). Omitting the field keeps the preset accessible via auto-detection, `--preset` flag, and `claude-base preset list` (soft migration — no breaking change).

### Workflow

1. **Read** `specs/presets/spec.md` (format) and the tier-specific spec (`specs/presets-vendor-pointer-tier/spec.md` if vendor-pointer).
2. **Verify the vendor source** via `gh api repos/<owner>/<repo>` for stars / last commit / archived flag / license, then apply the **advice-neutrality** filter (does the skill's *advice* push lock-in or steer users off their stack/Claude?) and **disclose the publisher as provenance** — identity is not a veto. See `docs/recipes/recommended-vendor-skills.md` for the full methodology.
3. **Draft the manifest** under `.claude/presets/<name>.json` (or `community/<name>.json` for community-curated).
4. **Create a paired fixture** under `tests/presets-fixtures/<name>/` matching the detect rule.
5. **Add bats tests** (positive accept + fixture-pairing) in `tests/presets.bats`.
6. **Update the roadmap** (`specs/presets/roadmap.md` §"Shipped …" and §"Vendor-pointer candidates" if applicable).
7. **Update the catalogue** (`.claude/presets/README.md` table row).
8. **Regenerate counts** via `npm --prefix website run generate` (auto-bumps `counts.json#presets` + README badges).
9. **Run the gauntlet** : `./scripts/validate-presets.sh`, `./scripts/validate-counts.sh`, `./scripts/audit-base.sh`, `bats tests/presets.bats`.
10. **Open a PR** referencing the spec. The `categories[]` enum, the tier rules, and the drift-guard taxonomy test will catch most mistakes in CI.

---

## Recap of locations

```
.claude/
├── rules/              # Rules per language/framework
│   ├── python.md       # Activated on **/*.py
│   └── my-framework.md
├── skills/             # Reusable skills
│   └── my-skill/
│       ├── SKILL.md    # Required definition
│       └── examples/
├── agents/             # Sub-agents with dedicated LLM
│   └── my-agent.md
├── commands/           # Commands invokable by /domain:name
│   └── domain/
│       └── my-command.md
└── settings.json       # Project-wide hooks
    settings.local.json # Local hooks not committed
```
