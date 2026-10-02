---
name: writing-skills
description: Guide for creating new skills for the Claude Code foundation. Trigger when the user wants to create a skill, add a command, or extend the foundation.
---

# Creating New Skills

## Objective

Framework for creating quality skills for the Claude Code foundation, respecting the existing conventions and structure.

## Skill structure

```
.claude/skills/<skill-name>/
└── SKILL.md
```

### SKILL.md format

```yaml
---
name: my-skill
description: Clear description of the skill. Trigger when [activation context].
---

# Skill Title

## Objective
[Clear description of what the skill does]

## Instructions
[Detailed instructions, structured in steps]

## Expected output
[Expected output format]

## Rules
[Mandatory rules for the skill]
```

## Available Frontmatter Fields (Claude Code 2.1+)

All fields available in the YAML frontmatter of a skill:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Skill name (default: folder name). Lowercase, digits, hyphens (max 64 chars) |
| `description` | Recommended | What the skill does and when to use it. Claude uses this to decide when to load the skill |
| `allowed-tools` | No | Tools pre-approved for the skill's turn (grants, never restricts). The foundation declares none: the project's permission settings decide; add one precise, reviewed rule such as `Bash(npm test:*)` only for a truly unattended need |
| `context` | No | Omit it (default): the skill runs inline and sees the conversation. `fork` (the only value) runs it in a sub-agent that sees NONE of the conversation — only for a self-contained job such as a report or a batch over the repo |
| `background` | No | With `context: fork` only. Since CC 2.1.218 forked skills run in the BACKGROUND by default (async result, narrower background tool set, edits bypass `/rewind` checkpoints). Set `false` to block in-turn — the foundation default for workflow skills |
| `model` | No | Forked skills only in this foundation: the subagent's model (`sonnet`, `opus`, `haiku`, `inherit`). On an inline skill it switches the SESSION's model for the rest of the turn, so leave it out |
| `agent` | No | Sub-agent type when `context: fork` (`Explore`, `Plan`, `general-purpose`, or custom agent) |
| `disable-model-invocation` | No | `true` = manual invocation only (Claude cannot auto-load). Default: `false` |
| `user-invocable` | No | `false` = invisible in the `/` menu (background skills). Default: `true` |
| `argument-hint` | No | Autocompletion hint shown in the `/` menu. E.g.: `[issue-number]` or `[filename] [format]` |
| `hooks` | No | Hooks scoped to the skill lifecycle (PreToolUse, PostToolUse, Stop) |

### Variable substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[N]` | Argument by index (0-based) |
| `$N` | Shortcut for `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | Current session ID |

### Dynamic context injection

Use the backtick-bang syntax to inject live data:
- Example: `!` followed by backtick then `gh pr diff` then backtick
- The command runs BEFORE Claude sees the content
- The result replaces the placeholder
- Outside auto mode the command must be allowed, or the invocation aborts. The foundation's settings allow `Bash`; a project that narrowed them allows the precise command in its own permission settings (e.g. `Bash(gh pr diff:*)`). Foundation skills still declare no `allowed-tools`

Example:
```markdown
## PR Context
- Diff: !`gh pr diff`
- Files: !`gh pr diff --name-only`
```

### Frontmatter best practices

- SKILL.md < 500 lines (move detail to reference files via `supporting files`)
- Description budget: 15,000 chars max (variable `SLASH_COMMAND_TOOL_CHAR_BUDGET`)
- Supporting files: `examples/`, `scripts/`, `reference.md` in the skill folder
- Use `disable-model-invocation: true` for skills that should only be launched manually (e.g.: commit, PR, plan)
- Use `user-invocable: false` for context/background skills that Claude loads automatically (state-management, api-mocking)
- No `model` on an inline skill (it would switch the user's session model); on a forked skill, pick the subagent's tier by cost
- Use `argument-hint` to guide the user on the expected parameters

## Skill quality checklist

### Structure

```
[ ] Valid YAML frontmatter (name, description)
[ ] kebab-case name
[ ] Description with trigger context
[ ] No `allowed-tools` (the foundation pre-approves nothing)
[ ] No `context` (inline) unless the skill is a self-contained job; forking is a review decision (the forked set is pinned in tests/skills-frontmatter.bats)
[ ] If forked: background: false (block in-turn; omit only for a deliberately detached skill)
```

### Content

```
[ ] Clear objective in 1-2 sentences
[ ] Instructions structured as numbered steps
[ ] Relevant code examples
[ ] Expected output with template
[ ] Explicit rules and constraints
[ ] ASCII diagram if complex workflow
```

### Quality

```
[ ] Actionable (not just informative)
[ ] Specific (not generic)
[ ] Testable (verifiable results)
[ ] Standalone (no dependency on other skills)
[ ] Consistent with the foundation's conventions
```

## Foundation conventions

### Naming

| Type | Convention | Examples |
|------|------------|----------|
| Dev skills | `dev-*` | `dev-tdd`, `dev-debug`, `dev-api` |
| QA skills | `qa-*` | `qa-review`, `qa-security` |
| Ops skills | `ops-*` | `ops-docker`, `ops-ci` |
| Doc skills | `doc-*` | `doc-generate`, `doc-changelog` |
| Growth skills | `growth-*` | `growth-seo`, `growth-cro` |
| Biz skills | `biz-*` | `biz-model`, `biz-mvp` |
| Legal skills | `legal-*` | `legal-rgpd` |
| Data skills | `data-*` | `data-pipeline` |
| Workflow skills | `work-*` | `work-explore`, `work-plan` |
| Meta skills | Descriptive name | `parallel-agents`, `session-handoff` |

### Content patterns

```
1. ASCII workflow diagram (if applicable)
2. Numbered steps with subsections
3. Tables for quick references
4. Code blocks with specified language
5. "Expected output" section with template
6. "Rules" section with IMPORTANT/NEVER/YOU MUST
```

### Tools by skill type

| Skill type | Recommended tools |
|------------|-------------------|
| Read-only (audit, review) | Read, Glob, Grep |
| Development | Read, Write, Edit, Bash, Glob, Grep |
| Infrastructure | Read, Write, Edit, Bash, Glob, Grep |
| Documentation | Read, Write, Edit, Glob, Grep |
| Analysis | Read, Glob, Grep |

## Also create the associated files

### Command (optional)

```
.claude/commands/<domain>/<name>.md
```

Format: detailed prompt with `$ARGUMENTS`, workflow, expected output, related agents.

### Agent (optional)

```
.claude/agents/<name>.md
```

Format: YAML frontmatter with model, permissionMode, disallowedTools, skills, hooks.

### Rule (optional)

```
.claude/rules/<name>.md
```

Format: frontmatter with paths, contextual rules per file type.

## Creation workflow

```
1. IDENTIFY the need (which problem does this skill solve?)
2. NAME according to conventions (domain-action)
3. DEFINE nothing to pre-approve: `allowed-tools` grants, never restricts, and the foundation declares none
4. WRITE the SKILL.md with the template
5. CREATE the associated command if manual invocation is needed
6. CREATE the associated agent if isolated execution is needed
7. TEST the skill (invoke it and verify the result)
8. DOCUMENT in CLAUDE.md (skills table)
```

## Rules

- One skill = one single responsibility
- Description with mandatory trigger context
- Minimal tools (no Write if the skill doesn't modify anything)
- Run inline (no `context`) unless the skill needs no conversation at all
- Concrete examples, no abstract theory
- Expected output clearly defined
