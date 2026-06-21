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
3. **Confirm** — show the one-line lesson and ask the user to **keep / edit / discard**. Never write without explicit confirmation.
4. **Append** on confirmation to `~/.claude/rules/lessons.md` (create it if absent). One short line per lesson.

## Keep the store small (it costs context everywhere)

The store is loaded into every project, every session, so it must stay terse — target **~2,000 characters / ~15–20 lessons**. When it approaches the budget, propose pruning (merge near-duplicates, drop superseded lessons) rather than letting it grow.

## Boundaries

- **Personal only.** Lessons are the user's. **Never** write a lesson into a project repo, the foundation, or any committed file — only into `~/.claude/rules/lessons.md`.
- **No automation.** Capture is this in-conversation reflex; there is no background job and no model-spending hook. Bootstrapping from existing notes and pruning are user-invoked via `/lessons`.
