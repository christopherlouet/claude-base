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

Save and transfer the context of a work session to enable efficient resumption in a later session or by another agent.

## When to use

- End of a work session (save the state)
- Task too complex for a single session
- Handoff between developers/agents
- Documentation of work in progress

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
- [x] [Task 2] - [Detail]

### In progress
- [ ] [Task 3] - [Current state, where it stands]
  - Modified files: [list]
  - Next step: [description]
  - Possible blocker: [description]

### To do
- [ ] [Task 4] - [Description]
- [ ] [Task 5] - [Description]

## Decisions made

| Decision | Reason | Rejected alternative |
|----------|--------|---------------------|
| [Choice 1] | [Why] | [Other option] |
| [Choice 2] | [Why] | [Other option] |

## Key files

| File | Role | State |
|---------|------|------|
| `src/xxx.ts` | [Description] | Modified / Created / To modify |
| `tests/xxx.test.ts` | [Description] | Modified / Created / To create |

## Patterns and conventions discovered

- [Pattern 1 from the codebase]
- [Naming convention]
- [Specific architecture]

## Problems encountered

| Problem | Solution/Workaround | Resolved? |
|----------|---------------------|----------|
| [Problem 1] | [Solution] | Yes/No |
| [Problem 2] | [Workaround] | Partial |

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

## Handoff workflow

### Save the context (end of session)

```
1. SUMMARIZE the work done
2. LIST the modified files (`git diff --stat`)
3. DOCUMENT the decisions made and why
4. IDENTIFY the remaining tasks and their priority
5. NOTE the unresolved problems
6. WRITE the .claude/handoff.md file
```

### Resume the context (start of session)

```
1. READ the .claude/handoff.md file
2. CHECK the repo state (`git status`, `git log`)
3. RUN the tests to confirm the state
4. IDENTIFY the next task to perform
5. CONTINUE the work
```

## Best practices

- Write the handoff DURING the work, not after
- Be specific about files and lines of code
- Include commands to check the state
- Document the decisions AND the reasons
- Mention the pitfalls and workarounds discovered

## Rules

- ALWAYS create a handoff before ending a complex work session
- ALWAYS include the modified files and their state
- ALWAYS document the architectural decisions
- NEVER assume the next session will have the same context
