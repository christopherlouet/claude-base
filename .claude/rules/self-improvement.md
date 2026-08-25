# Self-Improvement Rules

A **personal, cross-project lessons referential**: when you learn something the user would want applied in *every* project, propose recording it. Lessons live in the user's own store at `~/.claude/rules/lessons.md`, which Claude Code loads into every project automatically — so a lesson captured once is recalled everywhere. This rule is **global** (always applies); it governs *how* lessons are captured, not file activation.

## When to propose a lesson (the reflex)

Propose **one** lesson only after a genuinely instructive moment — when **any** of:

- A fix took **more than one failed attempt** before it worked.
- The **user explicitly corrected** you (a preference, a wrong assumption, a "no, do it this way").
- The root cause was **non-obvious** (a surprising interaction, an easy-to-repeat trap).

Stay **silent** for routine work: typos, renames, obvious one-shot fixes, anything project-specific that won't recur elsewhere. A wrong proposal is worse than a missed one — when in doubt, don't propose.

## How to capture (human-gated, always)

1. **Generalize** — state a reusable *principle*, not an incident. Not "in <project> we forgot X" → but "X must always be done because Y". One sentence.
2. **Sanitize (mandatory)** — strip every project specific: project/company/person names, file paths, URLs, identifiers, **verbatim code/config snippets**, and **any secret/token**. If a lesson only makes sense with project specifics, it is **not** general — keep it as a local project memory instead, do not promote it.
3. **Recurrence check (before writing)** — the store is already in your context. If the lesson **recurs** (the same principle is already stored), do NOT add a second line: propose **bumping** the existing line's recurrence marker (`(seen N times)` → `(seen N+1 times)`; add `(seen 2 times)` on the first repeat) so the most-repeated lessons are easy to spot. Still human-gated — confirm the bump.
4. **Confirm** — show the one-line lesson and ask the user to **keep / edit / discard**. Never write without explicit confirmation.
5. **Append** on confirmation to `~/.claude/rules/lessons.md` (create it if absent). One short line per lesson, placed under its `## Topic` heading if one fits (create the heading if absent) — grouping keeps the store readable as it grows.

## Store format

A terse markdown file: optional `## Topic` headings group related lessons; each lesson is a one-line `- ` bullet; a recurring lesson carries a trailing `(seen N times)` marker. Headings are not lessons. Keep it append-friendly — a new lesson goes under (or as) a topic, never rewrites unrelated lines.

## Keep the store small (it costs context everywhere)

The store is loaded into every project, every session, so it must stay terse. The bound is **~2,000 characters** — the only target; the lesson count follows from it (**8–13**), never a quota to fill, and never strip a lesson's exemplars to fit one more in ([why](https://github.com/christopherlouet/claude-base/blob/main/docs/recipes/personal-lessons-referential.md)). When it approaches the budget, propose pruning (merge near-duplicates incl. recurrence twins, drop superseded lessons) rather than letting it grow. `claude-base lessons prune-check` reports `OVER` budget, `DUP:` lessons (section-aware), and `RECUR N:` for the most-repeated.

## Boundaries

- **Personal only.** Lessons are the user's. **Never** write a lesson into a project repo, the foundation, or any committed file — only into `~/.claude/rules/lessons.md`.
- **No automation.** Capture is this in-conversation reflex; there is no background job and no model-spending hook. Bootstrapping from existing notes and pruning are user-invoked via `/lessons`.
