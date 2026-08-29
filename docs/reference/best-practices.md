# Claude Code Best Practices (Boris Cherny)

## Verification and effort — moved

These two lived here and in `CLAUDE.md`, which is carried into every session; the same fact in two
places is how the anti-pattern lists in this repository drifted apart. They now have one home, in
the project's `CLAUDE.md`: give yourself the cheapest check that can fail, and match reasoning
depth to the task (`/effort`). This file keeps what is reference rather than instruction — consulted
on demand, not carried (`specs/guardrail-cleanup/carried-material.md`).

## Recommended Model

> "I use Opus with adaptive thinking for everything." -- Boris Cherny

_(Since 2026-07-24, **Opus 5** is the recommended default for complex work — near-Fable intelligence at half Fable's price.)_

| Context | Model | Rationale |
|----------|--------|---------------|
| Complex tasks (default) | **Opus 5** (`claude-opus-5`) | Released 2026-07-24: within ~0.5% of Fable 5's peak scores at **half the price** (`$5/$25` per MTok — same as Opus 4.8), 1M context, configurable effort. The `opus` alias resolves to it automatically |
| Extreme niche: the ~0.5% Fable still wins | **Fable 5** (`claude-fable-5`) | ~$10/$50 per MTok (2× Opus 5). Since Opus 5, a **rare, deliberate** choice — see the note below |
| Audits, analyses, high-volume agentic work | **Sonnet** (Sonnet 5) | 1M context, `$2/$10` per MTok — permanent since 2026-08-10 (the planned `$3/$15` rise was cancelled) vs Opus `$5/$25`. Claude Code's **default model** for subscription seats since 2026-06-30 |
| Simple tasks | **Haiku** | Fast for trivial operations |

> **Opus 5 (since 2026-07-24):** the new default of the `opus` tier alias (no agent-frontmatter change needed). Same price as Opus 4.8 with greatly improved performance: doubles Opus 4.8 on Frontier-Bench v0.1 and outperforms Fable 5 on OSWorld 2.0 at a third of the cost. Fast mode runs on it at `$10/$50` per MTok (~2.5× speed). Opus 4.8 is not deprecated (it serves as fallback) but is no longer the recommendation. ([Announcement](https://techcrunch.com/2026/07/24/anthropic-launches-opus-5/))

> **Fable 5 after Opus 5:** the "escalate to Fable for hard chantiers" advice is largely **obsolete** — Opus 5 lands within ~0.5% of Fable's peak at half the price, so Opus 5 absorbs the escalation role. Fable 5 remains relevant only where that last half-percent measurably matters (the hardest long-horizon autonomous runs) and there is still **no `fable` tier alias**: select it per-session via `/model` or `--model claude-fable-5`, deliberately. Availability note: Fable 5 has been generally available again since 2026-07-01 (the June export-control directive was lifted 2026-06-30; Mythos 5 stays restricted to a subset of US organizations). ([Anthropic statement](https://www.anthropic.com/news/claude-fable-5-mythos-5))

> **Sonnet 5 (since 2026-06-30):** Claude Code's own default for subscription seats — near-Opus-4.8 quality on many agentic tasks at roughly a third of the cost, native 1M context, `sonnet` alias absorbs it automatically. This foundation recommends **Opus 5 for complex/critical work** (TDD, Audit, architecture) where the quality delta pays off, and Sonnet 5 for audits, analyses, and high-volume agentic passes where its price/perf shines.

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
