---
sidebar_position: 12
title: "Claude Code Best Practices (Boris Cherny)"
description: "These two lived here and in `CLAUDE.md`, which is carried into every session; the same fact in two places is how the anti-pattern lists in this reposi"
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Claude Code Best Practices (Boris Cherny)

## Verification and effort — moved

These two lived here and in `CLAUDE.md`, which is carried into every session; the same fact in two
places is how the anti-pattern lists in this repository drifted apart. They now have one home, in
the project's `CLAUDE.md`: give yourself the cheapest check that can fail, and match reasoning
depth to the task (`/effort`). This file keeps what is reference rather than instruction — consulted
on demand, not carried (`specs/guardrail-cleanup/carried-material.md`).

## Recommended Model

> "I use Opus with adaptive thinking for everything." -- Boris Cherny

_(Since 2026-09-22, **Opus 5.5** is the recommended default for complex work, and Anthropic's own model guidance says the same: start from Opus 5.5. It is also cheaper than the Opus 5 it replaces.)_

| Context | Model | Rationale |
|----------|--------|---------------|
| Complex tasks (default) | **Opus 5.5** (`claude-opus-5-5`) | Released 2026-09-22 (CC 2.1.280): `$4/$20` per MTok with cache reads at `$0.20` (Opus 5: `$5/$25`, `$0.50`), 1M context, 128K output. The `opus` alias resolves to it automatically (except on Microsoft Foundry), and it is Claude Code's default model on every subscription plan, Pro and Team Standard included |
| Extreme niche: demanding reasoning, long-horizon work | **Fable 5.2** (`claude-fable-5-2`) | `$8/$40` per MTok with cache reads at `$0.20`: **2× Opus 5.5 on input and output, the same per cache read**. A **rare, deliberate** choice — see the note below |
| Audits, analyses, high-volume agentic work | **Sonnet** (Sonnet 5.5) | `$2/$10` per MTok with cache reads at `$0.10`, 1M context; the default Sonnet on the Anthropic API since 2026-09-28 (CC 2.1.284) |
| Simple tasks | **Haiku** (Haiku 5.5) | `$0.10/$0.50` per MTok for prompts up to 100K tokens (`$0.50/$2.50` above), 1M context; the default Haiku on the Anthropic API since 2026-10-07 (CC 2.1.293) |

> **Opus 5.5 (since 2026-09-22):** the new default of the `opus` tier alias (no agent-frontmatter change needed), at a lower price than Opus 5 (`$4/$20` vs `$5/$25` per MTok, cache reads `$0.20` vs `$0.50`). Claude Code runs it at `medium` effort by default (Opus 5: `high`). Fast mode on it costs `$8/$40` per MTok and is still a research preview in Claude Code. Opus 5 and Opus 4.8 stay available but are no longer the recommendation. ([pricing](https://platform.claude.com/docs/en/about-claude/pricing), [models overview](https://platform.claude.com/docs/en/about-claude/models/overview))

> **Fable 5.2 after Opus 5.5 (updated 2026-11-14):** the "escalate to Fable for hard chantiers" advice stays **obsolete as a default** — and this is Anthropic's own guidance, which still calls Opus 5.5 the daily driver for most coding and knowledge work and says to reach for Fable when evals on an Opus model at higher effort still fall short.
>
> - **`claude-fable-5-2` is the default Fable model since 2026-11-09 (Claude Code 2.1.321)**, behind the `fable` alias (`/model claude-fable-5-1` still selects 5.1). It is **cheaper than 5.1**: `$8/$40` per MTok (5.1: `$10/$50`), cache reads `$0.20` (5.1: `$0.25`). Against Opus 5.5 (`$4/$20`, `$0.20`) that is 2× on input and output and **the same per cache read** — the gap narrowed, it did not close. Anthropic reports Fable 5.2 at `high` effort matching Opus 5.5 at `max` on one coding benchmark for about half the cost per task: a vendor figure on one benchmark, worth an eval of your own before it changes a default. ([pricing table](https://platform.claude.com/docs/en/about-claude/pricing), [announcement](https://www.anthropic.com/claude-fable-and-mythos-5-2))
> - **A `fable` alias exists.** Sub-agent `model:` frontmatter accepts `sonnet`, `opus`, `haiku` and `fable`, plus full ids and `inherit`. This foundation still **does not pin any agent to Fable** — that is a deliberate cost choice, no longer a limitation of the tool. The shipped `settings.json` holds it with an `ask` rule, `Agent(model:fable)` (parameter syntax, 2.1.178): a sub-agent launched explicitly on Fable asks first, auto mode included, instead of running silently; `ask` rather than `deny`, so the deliberate case stays open. It matches the Agent tool's `model` parameter only: a call without it is not asked — measured with an agent pinned `model: fable` in its frontmatter, which ran on Fable 5.1 with no prompt — so `tests/settings-guards.bats` also fails if any foundation agent or skill pins a Fable tier (`fable`, `best`, `claude-fable-*`) in its frontmatter. A rule added mid-session takes effect in the next session. The rule names the alias, so it follows each new Fable model with no change. In Claude apps gateway sessions `fable` and `best` still resolve to Fable 5 (2.1.260), so pick `claude-fable-5-2` explicitly via `/model` there.
>
> Availability: the Fable tier has been generally available since 2026-07-01; Mythos 5.2 is restricted to organizations verified through Anthropic's verification programs. ([Fable 5.2 announcement](https://www.anthropic.com/claude-fable-and-mythos-5-2), [what's new](https://platform.claude.com/docs/en/models/fable-5-2/whats-new-fable-5-2))

> **Sonnet 5.5 (since 2026-09-28):** replaces Sonnet 5 under the `sonnet` alias on the Anthropic API (Bedrock, Google Cloud and Foundry still resolve it to Sonnet 4.5) at the same `$2/$10` per MTok, with cache reads halved to `$0.10`. It is no longer Claude Code's default for subscription seats: Opus has been the default on every plan since 2026-09-22 (CC 2.1.280). This foundation recommends **Opus 5.5 for complex/critical work** (TDD, Audit, architecture) where the quality delta pays off, and Sonnet 5.5 for audits, analyses, and high-volume agentic passes where its price/perf shines.

## Advanced Prompting

| Avoid | Prefer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Techniques: "Grill me on these changes", "Prove to me this works", "Knowing everything you know now, implement the elegant solution".

See `docs/guides/PROMPTING-GUIDE.md` for the complete guide.

## Automatic Memory (CLI 2.1.76+)

Claude Code automatically remembers preferences, decisions, and project context in `~/.claude/memory/`.

| Memorize (auto) | CLAUDE.md (git) | Rules (auto-activated) |
|-------------------|-----------------|----------------------|
| Personal preferences | Project conventions | Per-language rules |
| Architecture decisions | Mandatory workflow | Code patterns |
| Team context | Documentation references | Verification checklist |

Do not duplicate: if it is in CLAUDE.md, no need to memorize it. Use "remember that..." to force an explicit memorization.

> **Note (since Code with Claude 2026, May 6)**: Anthropic also ships **Auto Dream / Dreaming**, a managed memory feature where a background subagent reviews recent transcripts and consolidates the memory directory between sessions. It is complementary to the file-based system above: Auto Memory captures notes during work, Auto Dream cleans them between sessions. See the [Claude managed agents blog post](https://claude.com/blog/new-in-claude-managed-agents) and the [Dreams API doc](https://platform.claude.com/docs/en/managed-agents/dreams).

## Parallel Sessions

> "The single biggest productivity unlock." -- Boris Cherny

Use git worktrees for 5+ Claude Code sessions in parallel. See the `git-worktrees` skill for details.

## Context Management

| Situation | Action | When |
|-----------|--------|-------|
| Long session, intact context | `/compact` | Between phases (Explore → Plan → TDD) |
| Total topic change | `/clear` | New unrelated task |
| Normal session | Let it be | Auto-compaction if needed |

## Quick Recovery

If a refactoring breaks everything: `/rewind` (or `/undo`, equivalent alias) returns to the last stable state. Faster than `git stash` or `git checkout`. Checkpoints saved automatically before each modification.

Since CLI 2.1.141, the Rewind menu also exposes a **"Summarize up to here"** entry that compresses earlier turns while keeping the recent ones intact — useful when the issue is context bloat rather than a broken change.

## Session Resume

`/recap` generates a summary of the current session — decisions made, files modified, work state. Useful to resume a session after a break or a `/compact`.

| Situation | Action |
|-----------|--------|
| Return after a break | `/recap` to recover the context |
| After `/compact` | `/recap` to verify what was kept |
| Onboarding on an existing session | `claude --resume <id>` then `/recap` |

Configurable via `/config` (enable/disable automatic recap on resume).

## Token Optimization

### Prompt Caching 1h (CLI 2.1.108+)

The `ENABLE_PROMPT_CACHING_1H` variable enables a 1-hour prompt cache instead of 5 minutes. Significantly reduces costs for long sessions.

Enable in `.claude/settings.local.json`:

```json
{
  "env": {
    "ENABLE_PROMPT_CACHING_1H": "1"
  }
}
```

Compatible with API key, Bedrock, Vertex, and Foundry. Alternative: `FORCE_PROMPT_CACHING_5M` to force the 5-minute TTL (useful if telemetry is disabled).

## Quick Command

`/work:work-commit-push-pr "description"` -- commit + push + PR in a single command.
