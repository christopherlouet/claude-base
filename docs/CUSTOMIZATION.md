# Customization Guide

How to adapt claude-base to your specific needs.

---

## 1. Customize CLAUDE.md

### Recommended structure

```markdown
# Project [Name]

## Essential Commands
[npm/yarn/make commands specific to your project]

## Project Structure
[Tree with description of each folder]

## Code Conventions
[Rules specific to your team]

## Git & Commits
[Commit format, branches, workflow]

## Points of attention
[Common pitfalls, technical debt, sensitive areas]
```

### Emphasis keywords

Claude pays more attention to certain keywords:

| Keyword | Usage |
|---------|-------|
| `IMPORTANT:` | Critical rule to follow |
| `YOU MUST` | Absolute obligation |
| `NEVER` | Prohibition |
| `ALWAYS` | Always do it this way |
| `WARNING:` | Point of attention |

**Example:**
```markdown
## Security
- IMPORTANT: Always validate user inputs
- YOU MUST use parameterized queries
- NEVER log passwords or tokens
```

### Business context

Add business context so Claude understands better:

```markdown
## Business context
This project is a B2B e-commerce application.
- "Customers" are companies, not individuals
- A "cart" can contain thousands of items
- "Orders" go through a validation workflow
```

---

## 2. Create custom commands

### Location

- **Project**: `.claude/commands/` (shared via git)
- **Personal**: `~/.claude/commands/` (global)

> **Note**: The foundation's commands are organized into subdirectories by category
> (work/, dev/, qa/, ops/, doc/, biz/, growth/, data/, legal/).
> Your custom commands can be at the root of `.claude/commands/`
> or in a subdirectory of your choice.

### Structure of a command

```markdown
# Command name

Short description of what the command does.

## Context
$ARGUMENTS

## Instructions
1. Step 1
2. Step 2
...

## Expected output
[Output format]

---

[Additional instructions with IMPORTANT/YOU MUST]
```

### Example: Deployment command

`.claude/commands/deploy.md`:
```markdown
# DEPLOY Agent

Deploys the application to the specified environment.

## Environment
$ARGUMENTS

## Prerequisites
- [ ] Tests pass
- [ ] Build OK
- [ ] Changelog up to date

## Workflow

### Staging
```bash
npm run build
npm run deploy:staging
```

### Production
IMPORTANT: Requires manual approval
```bash
npm run build:prod
npm run deploy:prod
```

## Post-deployment
- [ ] Check healthchecks
- [ ] Monitor errors
- [ ] Notify the team

---

NEVER deploy to production without review.
```

Usage: `/deploy staging` or `/deploy production`

### Available variables

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Arguments passed to the command |

---

## 3. Configure permissions

### `.claude/settings.json` file

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm test:*)",
      "Bash(npm run lint:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(DROP TABLE:*)"
    ]
  }
}
```

### Permission patterns

| Pattern | Description |
|---------|-------------|
| `Bash(cmd:*)` | Allows `cmd` with all arguments |
| `Bash(cmd arg:*)` | Allows `cmd arg` with free continuation |
| `Edit` | File modification |
| `Write` | File creation |

### Permissions per environment

Create `.claude/settings.local.json` (gitignored) for more permissive local permissions:

```json
{
  "permissions": {
    "allow": [
      "Bash(docker:*)",
      "Bash(kubectl:*)"
    ]
  }
}
```

---

## 4. Configure hooks

### In `.claude/settings.json`

Hooks are configured directly in the `settings.json` file:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "description": "Protect main branch",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); if [ \"$branch\" = \"main\" ] || [ \"$branch\" = \"master\" ]; then echo \"Modification blocked on $branch\"; exit 1; fi'",
            "onFailure": "block"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "description": "Auto-format after edit",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### Hook types

| Hook | Trigger |
|------|---------|
| `SessionStart` | Session start (matchers: `startup`, `resume`, `clear`, `compact`) |
| `SessionEnd` | Session end |
| `UserPromptSubmit` | When the user submits a prompt (can inject context) |
| `PreToolUse` | Before using a tool (Edit, Write, Bash, Read…) |
| `PostToolUse` | After using a tool |
| `Stop` | When Claude finishes a response |
| `Notification` | System notifications (permissions, idle…) |

### Available matchers

| Matcher | Targeted tools |
|---------|----------------|
| `Edit` | File modifications |
| `Write` | File creation |
| `Bash` | Shell commands |
| `Read` | File reading |
| `Glob`, `Grep` | Search |
| `Edit\|Write` | Multiple tools (regex) |
| `*` | All tools |

### Environment variables

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Project root (equivalent to `pwd` at startup) |
| `$CLAUDE_SESSION_ID` | Unique session identifier |
| `$CLAUDE_FILE_PATH` | Path of the relevant file (PreToolUse/PostToolUse Edit/Write) |
| `$CLAUDE_TOOL_NAME` | Name of the tool used |

Hooks also receive the JSON payload on `stdin` (use `jq` to parse).

### Behavior on failure

| onFailure | Effect |
|-----------|--------|
| `block` | Blocks the action (PreToolUse only) |
| `continue` | Continues despite the error |
| (absent) | Continues by default |

---

## 5. Create custom skills

Skills are triggered automatically by Claude based on context (keywords in the conversation). Ideal for recurring patterns you don't want to invoke manually.

### Location

```
.claude/skills/
└── my-skill/
    ├── SKILL.md          # Frontmatter + main instructions
    ├── examples/         # (optional) Detailed examples
    └── references/       # (optional) Large references
```

### `SKILL.md` format

```yaml
---
name: my-skill
description: When to trigger this skill (keywords or context)
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
context: fork    # `fork` (recommended) or `inherit`
---

# My Skill

## Trigger

Activated when the user mentions:
- "pattern X"
- "approach Y"

## Instructions

[The full skill prompt — can be up to 500 lines]

## Examples

For large examples, move to `examples/` and include via link.
```

### Best practices

- **`context: fork`**: isolates the skill from the main conversation (recommended for complex workflows).
- **Limit `allowed-tools`**: principle of least privilege.
- **Precise description**: Claude uses the description to decide when to trigger, be specific.
- **Skills ≠ Agents**: a skill complements Claude; an agent is an isolated subprocess.

### Example: TypeScript code review skill

```yaml
---
name: review-typescript-strict
description: Activate when the user wants a strict TypeScript review (any, implicit types, null safety)
allowed-tools:
  - Read
  - Grep
  - Glob
context: fork
---

# Strict TypeScript Review

When the user requests a TypeScript review:

1. Detect explicit `any` (other than those justified in a comment).
2. Detect implicit types (parameters without type).
3. Check null safety (optional chaining, nullish coalescing).
4. Produce a report with line:column for each issue.
```

---

## 6. Integrate MCP servers

### `.mcp.json` file

> **Security important**: the foundation ships `.mcp.json` **empty** (`"mcpServers": {}`) — no MCP server runs by default. A server is active **only if listed** in `.mcp.json` (the format has no per-server `enabled` flag). A curated catalogue ships as **`.mcp.json.example`** (a reference file Claude does not load); copy the server blocks you need into `.mcp.json`, provide their env vars, and review their permissions. Project-scoped servers prompt for approval on first use.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

### Popular MCP servers

| Server | Package | Usage |
|--------|---------|-------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | Controlled file access |
| Postgres | `@modelcontextprotocol/server-postgres` | PostgreSQL queries |
| GitHub | `@modelcontextprotocol/server-github` | GitHub API (issues, PRs) |
| Puppeteer | `@modelcontextprotocol/server-puppeteer` | Browser automation |
| Fetch | `@modelcontextprotocol/server-fetch` | HTTP requests |
| Memory | `@modelcontextprotocol/server-memory` | Knowledge graph memory |

Full list: <https://github.com/modelcontextprotocol/servers>.

---

## 7. Adapt for your team

### Team conventions

Add to CLAUDE.md:

```markdown
## Team conventions

### Code review
- Minimum 1 approval required
- Author does not merge their own PR
- Squash merge preferred

### Communication
- Jira tickets format: PROJ-123
- Commits reference the ticket: "feat(PROJ-123): ..."

### Deployments
- Staging: automatic on develop
- Production: manual, Wednesdays only
```

### Onboarding

Create a specific onboarding command:

`.claude/commands/team-onboard.md`:
```markdown
# Team Onboarding

Guides the new developer through the project.

## Steps

1. **Architecture**: Explain the structure
2. **Setup**: Guide local installation
3. **Workflow**: Explain the dev process
4. **Conventions**: Present team rules
5. **Resources**: List important documentation

## Useful links
- Wiki: [link]
- Jira: [link]
- Slack: #channel-dev
```

### Sharing configurations

1. **Version** `.claude/` and `CLAUDE.md` in git
2. **Gitignore** `CLAUDE.local.md` and `.claude/settings.local.json`
3. **Document** custom commands in the README

---

## Best practices

1. **Start simple** - Add commands as needs arise
2. **Document commands** - Future you will thank you
3. **Test permissions** - Verify nothing dangerous is allowed
4. **Iterate** - Improve CLAUDE.md based on experience
5. **Share** - Good configurations benefit the whole team

---

## Troubleshooting

### Claude doesn't find my commands

- Check the path: `.claude/commands/name.md`
- Check that the file has the `.md` extension
- Restart Claude Code after adding

### Permissions don't work

- Check the JSON syntax
- Patterns are case-sensitive
- Use `:*` wildcards for arguments

### Hooks don't trigger

- Check `"enabled": true`
- Check that the command exists
- Consult the Claude logs
