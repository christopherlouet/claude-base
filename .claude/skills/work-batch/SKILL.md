---
name: work-batch
description: Sequential execution of user stories from a PRD file. Autonomous mode that implements and commits each story one by one. Trigger when the user wants to process a backlog, execute multiple stories, or launch an autonomous mode.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[path-to-prd.json or prd.md]"
---

# Batch Execution Mode

Autonomous and sequential execution of user stories from a PRD file.

## PRD file format

### JSON (`prd.json`)

```json
{
  "project": "project-name",
  "stories": [
    {
      "id": "US-001",
      "title": "Story title",
      "description": "Detailed description",
      "priority": "P1",
      "acceptance_criteria": [
        "Given X, When Y, Then Z"
      ],
      "files": ["src/module.ts", "src/module.test.ts"]
    }
  ]
}
```

### Markdown (`prd.md`)

```markdown
## US-001: Story title
**Priority**: P1
**Description**: Detailed description
**Acceptance criteria**:
- Given X, When Y, Then Z
**Files**: src/module.ts, src/module.test.ts
```

## Workflow per story

For each story in priority order (P1 → P2 → P3):

### 1. LOAD - Load the story

- Read the story from the PRD file
- Display the title and description
- Check prerequisites (files, dependencies)

### 2. IMPLEMENT - TDD cycle

- Write the tests first (RED)
- Implement the minimal code (GREEN)
- Refactor if necessary (REFACTOR)
- Verify the acceptance criteria

### 3. COMMIT - Save

- Run the tests: `npm test` / `pytest` / `go test`
- If tests OK: commit with `feat(scope): US-XXX description`
- If tests KO: STOP and report the blocker

### 4. REPORT - Update the state

- Mark the story as done in `.claude/output/batch/progress.json`
- Log the time and modified files
- Move on to the next story

## Progress file

Automatic save in `.claude/output/batch/progress.json`:

```json
{
  "started_at": "2026-03-23T10:00:00Z",
  "stories": {
    "US-001": { "status": "done", "commit": "abc1234", "files": ["..."] },
    "US-002": { "status": "in_progress" },
    "US-003": { "status": "pending" }
  }
}
```

## Resume after interruption

If `progress.json` exists, resume at the last `in_progress` or `pending` story.

## Guardrails

- Maximum 10 stories per batch (beyond that, split)
- STOP if 2 consecutive stories fail
- Each story must pass the tests before continuing
- Commit after each story (no giant commits)

---

IMPORTANT: Each story is an atomic commit. Do not accumulate changes.

NEVER continue if the tests fail on a story.

YOU MUST save the progress in `.claude/output/batch/progress.json`.
