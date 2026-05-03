# WORK-BATCH Agent

Autonomous and sequential execution of user stories from a PRD file (JSON or Markdown).

## Context
$ARGUMENTS

## Objective

Process a backlog of stories in autonomous mode: for each story, TDD cycle + atomic commit.

## Workflow

For each story (priority order P1 → P2 → P3):

1. **LOAD**: Read the story and its acceptance criteria
2. **TDD**: Red-Green-Refactor
3. **COMMIT**: `feat(scope): US-XXX description`
4. **REPORT**: Save to `.claude/output/batch/progress.json`

## PRD Format

The PRD file can be in JSON (`prd.json`) or Markdown (`prd.md`). See the `work-batch` skill for detailed formats.

## Guardrails

- Max 10 stories per batch
- STOP if 2 consecutive stories fail
- Atomic commit after each story
- Automatic resume if `progress.json` exists

## Expected output

- Each story implemented and committed
- Progress file updated
- Final summary with completed/failed stories

---

IMPORTANT: One commit = one story. No giant multi-story commits.

NEVER continue if tests fail on a story.
