# LESSONS Command

Lists the `feedback` memories captured for the current project (and globally) — the "lessons" learned from user corrections.

## Context
$ARGUMENTS

## Objective

Provide an overview of the self-improvement system: which rules, counter-examples, or preferences have already been recorded to avoid repeating the same mistakes.

## Usage

```
/lessons              # List all feedback memories for the project (read-only)
/lessons <keyword>    # Filter by keyword (e.g., /lessons test, /lessons git)
/lessons --promote    # Capture the lesson just learned into the personal store
/lessons --bootstrap  # One-off: backfill the personal store from existing memories
/lessons --prune      # Keep the personal store under its size budget
```

The `--promote`, `--bootstrap`, and `--prune` modes feed the **personal
cross-project lessons store** at `~/.claude/rules/lessons.md` (loaded into every
project by Claude Code). They follow the [`self-improvement`](https://github.com/christopherlouet/claude-base/blob/main/.claude/rules/self-improvement.md)
rule: every write is **generalized + sanitized + human-confirmed**, and the
lessons are personal — never committed to any repo.

## Modes

### `--promote` (explicit capture — fallback to the reflex)

For when the in-conversation reflex didn't fire but you want to keep a lesson:

1. Take the lesson just learned, **generalize** it to a one-line principle and
   **sanitize** it (strip project/company/person names, paths, URLs, identifiers,
   verbatim snippets, secrets).
2. **Check for recurrence** — the store is in your context. If the same principle
   is already stored, propose **bumping** its `(seen N times)` marker instead of
   adding a duplicate (`(seen 2 times)` on the first repeat, then N+1).
3. Show it and ask the user to **keep / edit / discard** (or confirm the bump).
4. On confirmation, write to `~/.claude/rules/lessons.md` (create if absent):
   append the new lesson as a `- ` bullet under its matching `## Topic` heading
   (create the heading if none fits), or apply the recurrence bump. If it can't
   be generalized, keep it as a local project memory instead.

### `--bootstrap` (one-off backfill)

Seed the store from lessons you already accumulated, so you don't start from scratch:

1. Run `claude-base lessons bootstrap-scan` (lists existing `feedback` memories
   across all your projects as `project<TAB>name<TAB>description` candidates).
2. For each candidate, decide if it is **general/recurring** (worth applying
   everywhere) or project-specific (skip). Generalize + sanitize the keepers.
3. Propose the keepers and let the user confirm each; append the confirmed ones.
   This is a one-time action — not a background job.

### `--prune` (stay within budget)

1. Run `claude-base lessons prune-check` (prints `OK`/`OVER size/budget`, `DUP:`
   lines for duplicates — section-aware, so `## Topic` headings and a lesson's
   `(seen N times)` twin are handled — and `RECUR N:` for the most-repeated
   lessons).
2. If `OVER` or duplicates exist, propose merges (near-duplicates, incl. folding
   a duplicate into a single `(seen N times)` line) and drops (superseded
   lessons). Surface the high-`RECUR` lessons as keepers. **Never delete without
   explicit confirmation.**

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
| Keyword filter with no match | Message "No memory matches '<keyword>'" |
| Orphan memory (file without an entry in MEMORY.md) | WARN, suggest re-indexing |

---

IMPORTANT: This command is read-only. To add a lesson, the system prompt handles it automatically when the user makes a correction (signal detected by `prompt-context.sh`).

NEVER modify or delete a feedback memory without explicit confirmation from the user.
