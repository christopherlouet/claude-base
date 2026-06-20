# Claude Code Best Practices (Boris Cherny)

## Verification: The Quality Multiplier

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Always give Claude a way to validate its work:

| Complexity | Method | Example |
|------------|---------|---------|
| Simple | Bash command | `npm run lint`, `npm run typecheck` |
| Moderate | Test suite | `npm test`, `pytest`, `go test` |
| Complex | Browser/Simulator | Playwright, Chrome DevTools, mobile emulator |

Integration: PostToolUse hooks (auto-format, type-check, lint), PreToolUse on commit (mandatory tests), QA agents (`/qa:qa-audit`).

## Recommended Model

> "I use Opus with adaptive thinking for everything." -- Boris Cherny

_(Fable 5 sits one tier above Opus 4.8 for the hardest long-horizon work — see the table below.)_

| Context | Model | Rationale |
|----------|--------|---------------|
| Most demanding / long-horizon autonomous work | **Fable 5** (`claude-fable-5`) | Anthropic's most capable model — deepest reasoning, long-horizon agentic runs. Reach for it **deliberately**: ~$10/$50 per MTok (2× Opus 4.8) |
| Complex tasks (default) | **Opus 4.8** | Most advanced reasoning, adaptive thinking, 1M context, `xhigh` effort |
| Audits and analyses | **Sonnet** | Good speed/quality balance |
| Simple tasks | **Haiku** | Fast for trivial operations |

> **Fable 5 vs Opus 4.8:** Opus 4.8 stays the default for complex work. Fable 5 (1M context by default, 128K output, same tokenizer as Opus 4.8) is a **costlier escalation** — 2× Opus per token — for the hardest long-horizon tasks, not a drop-in replacement.

**Proactively flag the escalation.** When a session turns into a long-horizon *chantier* — a multi-PR migration, a deep audit, or a large refactor that visibly exceeds Opus 4.8's comfort zone — say so and suggest escalating the model to Fable 5 (`/model`, or relaunch with `--model claude-fable-5`). It is a deliberate, costlier choice (2× Opus) and there is **no `fable` tier alias**, so Claude cannot switch itself mid-session — surface the recommendation and let the user decide. Don't suggest it for routine work where Opus 4.8 is the right default.

## Advanced Prompting

| Avoid | Prefer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Techniques: "Grill me on these changes", "Prove to me this works", "Knowing everything you know now, implement the elegant solution".

See `docs/guides/PROMPTING-GUIDE.md` for the complete guide.

## Effort Levels

> Match the level of reasoning to the task.

| Task | Effort | Why |
|-------|--------|----------|
| Exploring code, reading files | `low` | No need for deep reasoning |
| Implementing a standard feature | `medium` | Speed/quality balance |
| Designing an architecture, audit, complex debug | `high` | Deep reasoning required |
| Critical system architecture, advanced security audit | `xhigh` | Maximum reasoning (Opus 4.8 required) |

Command: `/effort low`, `/effort medium`, `/effort high`, `/effort xhigh` (interactive slider).

> Effort tunes reasoning depth **on the current model**; it is not a model upgrade. For the hardest long-horizon work, escalating the *model* to Fable 5 (`claude-fable-5`, ~2× Opus 4.8) is the distinct, costlier lever — see "Recommended Model" above.

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
