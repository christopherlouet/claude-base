# Personal cross-project lessons referential

A **personal memory of lessons** that carries across **all your projects** (and machines), so you never repeat the same mistake from scratch. It is yours: claude-base ships the *mechanism*, never your lessons.

> Mechanism: the [`self-improvement`](../../.claude/rules/self-improvement.md) rule (the capture reflex) + the [`/lessons`](../../.claude/commands/lessons.md) command. The lessons themselves live only in your home directory.

## How it works

- **The store** is a single file: `~/.claude/rules/lessons.md`. It is created the first time you confirm a lesson. Each lesson is a one-line `- ` bullet, optionally grouped under a `## Topic` heading so the file stays readable as it grows.
- **Recall is automatic.** Claude Code loads everything under `~/.claude/rules/` into *every* project session, so a lesson you confirm once is in context everywhere — no import, no command.
- **Capture is a human-gated reflex.** After a genuinely instructive moment (a fix that took several attempts, an explicit correction from you, a non-obvious root cause), the assistant proposes **one** short, generalized, sanitized lesson and asks you to keep / edit / discard it. Nothing is stored without your confirmation.
- **Recurring mistakes are counted, not duplicated.** If the same lesson comes up again, you are offered to bump a `(seen N times)` marker on the existing line instead of adding a second copy — so the most-repeated lessons are easy to spot and prioritize.
- **It stays small.** The store is loaded into every session, so it is bounded — **4,000 characters** by default, yours to set — see [Why the bound is a character count](#why-the-bound-is-a-character-count) below. When it fills up, you are prompted to prune (`/lessons --prune` reports over-budget, duplicates, and the most-repeated lessons).

## Why the bound is a character count

The cost is context, so **characters are the bound** and the lesson count is a *consequence* of it —
never a second target, and never a quota to fill.

A lesson that actually fires carries a one-line principle **plus the two or three exemplars that make
it recognizable in the moment**. Measured on a real store after three months of use, that averages
~260 characters, and a lesson that recurs grows longer than one that does not: each bump adds an
exemplar. So the default of **4,000 characters holds roughly 15 lessons**.

Compressing below that to fit more in is a false economy: the exemplars are precisely what let you
recognize the trap when you are in it. A store of twenty abstract one-liners costs the same context
and fires less often.

**The bound is a trigger, not a capacity.** Reaching it means "prune now", so pick a value your
store can sit under between pruning passes. A bound that is over budget every day gets ignored, and
then it protects nothing. Set yours once in `~/.claude/settings.json`:

```json
{ "env": { "LESSONS_BUDGET": "6800" } }
```

That `env` block reaches only the processes Claude Code starts, so `/lessons --prune` and any
`prune-check` Claude runs use it, but your own terminal does not. For a manual run, also
`export LESSONS_BUDGET=6800` in your shell profile, or pass the budget as an argument (which always
wins): `claude-base lessons prune-check ~/.claude/rules/lessons.md 6800`. The check counts bytes, which
matches characters for mostly-ASCII text.

> **Where the numbers come from.** The first bound, ~2,000, was borrowed from Hermes (~2,200) and
> never measured against a Claude Code store. It was first paired with "~15–20 lessons", which
> needed 100–133 chars per lesson (corrected 2026-08-25 to 8–13). The one real store then stayed
> over it through two pruning passes and settled at ~5,200 characters for 17 lessons. The default
> moved to 4,000 in 2026-09. It is still a starting point, not an optimum: whether a lesson in
> context actually changes behaviour is the open measurement.

## Privacy

- Lessons are **personal**. They are written only to `~/.claude/rules/lessons.md` — **never** into a project repo, the foundation, or any committed file.
- Every lesson is **sanitized** before it is written: project names, file paths, URLs, identifiers, and secrets are stripped. A lesson is a reusable *principle*, not an incident.
- If you sync the store (below), prefer a **private** destination.

## Starting from what you already learned (bootstrap)

If you used Claude Code before this feature, your past lessons already exist as per-project `feedback` memories. A one-time backfill proposes the general, recurring ones for promotion:

```
/lessons --bootstrap
```

It scans your existing per-project memories and proposes candidates (each generalized, sanitized, and confirmed by you). It is a one-off action you trigger — never a background job. A brand-new user simply starts on the reflex.

## Keeping it small (prune)

```
/lessons --prune
```

Reports whether the store is over budget and proposes merges (near-duplicates) and drops (superseded lessons); nothing deleted without your confirmation.

## Syncing across machines (bring your own transport)

`~/.claude/` is local to each machine — Claude Code does not sync it. claude-base does **not** provide a sync service; the store is just one file, so point any transport at it. Recommended, in order of fit:

| Transport | Cloud? | Repo? | Notes |
|-----------|--------|-------|-------|
| **Private git repo** (recommended) | optional | yes (private) | Versioned history of your lessons; free on GitHub/GitLab. Track only `~/.claude/rules/lessons.md` (and any other files you want), keep the repo **private**. |
| **Syncthing** | no | no | Peer-to-peer folder sync between your machines, no cloud, no repo, encrypted in transit. Best fit for "private, multi-machine, no repo, no cloud". |
| **Cloud-drive folder** (iCloud / Dropbox / Drive) | yes | no | Simplest if you already use one; the provider handles conflicts. |

Whatever you choose, the store stays a single relocatable file — the transport owns conflict resolution. Because the file is append-mostly, conflicts are rare.

## What this is NOT

- Not a community/shared lessons list — it is **personal**.
- Not a conversation-history search ("how did we do X last time").
- Not a background agent — capture is in-conversation, prune/bootstrap are commands you run.
- Not a replacement for Claude Code's native per-project memory or its consolidation (Auto Dream) — it adds the *cross-project* layer those don't provide.
