---
name: session-handoff
description: Context transfer between AI sessions. Trigger when the user wants to save the context, resume a task, or hand off the work to another session.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Session Handoff

## Objective

Produce a **git-committable handoff document** (`.claude/handoff.md`) that transfers a work session's state to a *different* reader: another developer, another agent, another LLM, or a future session on another machine.

## Native features first

Claude Code natively covers resuming **your own** session — do not rebuild that here:

| Need | Native answer |
|------|---------------|
| Resume my own session | `claude --resume <id>` (full context) |
| Recap after a break or `/compact` | `/recap` |
| Persistent preferences/decisions across sessions | auto memory (`~/.claude/memory/`) |

**This skill's delta is the cross-boundary case**: native memory and `--resume` are personal and machine-local — they do not transfer to a teammate, a CI agent, another tool, or another workstation. A committed `handoff.md` does.

## When to use

- Handoff between developers/agents/tools (the reader is NOT this session's owner)
- Work continuing on another machine or in an environment without your `~/.claude`
- Documentation of work in progress that must live IN the repo

## Handoff format

### Context file: `.claude/handoff.md`

```markdown
# Session Handoff

**Date:** [YYYY-MM-DD HH:MM]
**Session:** [ID or description]
**Author:** [Human or agent]

## Project context

**Project:** [Name]
**Branch:** [Branch name]
**Current commit:** [Hash]

## Work state

### Done
- [x] [Task 1] - [Detail]

### In progress
- [ ] [Task 3] - [Current state, where it stands]
  - Modified files: [list]
  - Next step: [description]
  - Possible blocker: [description]

### To do
- [ ] [Task 4] - [Description]

## Decisions made

| Decision | Reason | Rejected alternative |
|----------|--------|---------------------|
| [Choice 1] | [Why] | [Other option] |

## Key files

| File | Role | State |
|---------|------|------|
| `src/xxx.ts` | [Description] | Modified / Created / To modify |

## Patterns and conventions discovered

- [Pattern 1 from the codebase]

## Problems encountered

| Problem | Solution/Workaround | Resolved? |
|----------|---------------------|----------|
| [Problem 1] | [Solution] | Yes/No |

## Notes for the next session

[Specific instructions, pitfalls to avoid, points of attention]

## Useful commands

```bash
# To resume
git checkout [branch]
npm test  # Check that everything passes
# Next step: [description]
```
```

## Best practices

- Write the handoff DURING the work, not after
- Be specific about files and lines of code
- Document the decisions AND the reasons
- Mention the pitfalls and workarounds discovered
- NEVER assume the reader has this session's context, memory, or machine

## Rules

- ALWAYS create a handoff before handing work across a person/agent/machine boundary
- ALWAYS include the modified files and their state
- ALWAYS document the architectural decisions
- For resuming YOUR OWN session, prefer the native features above — no handoff file needed
