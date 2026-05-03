---
sidebar_position: 5
title: "/lessons"
description: "Lists the `feedback` memories captured for the current project (and globally) — the \"lessons\" learned from user corrections."
tags:
  - "other"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--other">Autres</span>


# LESSONS Command

Lists the `feedback` memories captured for the current project (and globally) — the "lessons" learned from user corrections.

## Context
`<arguments>`

## Objective

Provide an overview of the self-improvement system: which rules, counter-examples, or preferences have already been recorded to avoid repeating the same mistakes.

## Usage

```
/lessons              # List all feedback memories for the project
/lessons <keyword>    # Filter by keyword (e.g., /lessons test, /lessons git)
```

## Workflow

1. **Locate the memory directory**
    - Per-project: `~/.claude/projects/<project-slug>/memory/`
    - Global: `~/.claude/memory/` (if it exists)
2. **Filter feedback memories**
    - Read `MEMORY.md` and each `feedback_*.md` file
    - Extract the `type: feedback` frontmatter for sorting
3. **Summary**
    - For each memory, display:
      - Title + short description
      - **Why** (initial reason)
      - **How to apply** (when to apply the rule)
4. **Optional filtering**
    - If a keyword is passed, keep only the memories whose title, description, or content matches

## Expected output

```
=== Feedback memories for this project ===

1. Manual review of infra PRs
   user reviews and merges infra PRs himself, no auto-merge even when CI is green
   Why: prior incidents with auto-merge missing context
   How to apply: never enable Dependabot auto-merge for infra repos

2. Claude Max works headless on user VMs
   `claude setup-token` is the official path for cron/CI on Max
   Why: Max plan supports headless via setup-token
   How to apply: do not default to Routines for automation projects

=== Global feedback memories (cross-project) ===
(none if ~/.claude/memory/ is empty)
```

## Special cases

| Situation | Action |
|-----------|--------|
| No memory | Informative message + link to the auto-memory doc |
| Memory without `type: feedback` | Ignore (only list feedback) |
| Keyword filter with no match | Message "No memory matches '&lt;keyword>'" |
| Orphan memory (file without an entry in MEMORY.md) | WARN, suggest re-indexing |

---

IMPORTANT: This command is read-only. To add a lesson, the system prompt handles it automatically when the user makes a correction (signal detected by `prompt-context.sh`).

NEVER modify or delete a feedback memory without explicit confirmation from the user.


---

## See also

- [Back to Autres commands](/docs/commands/other)
- [All commands](/docs/commands)
