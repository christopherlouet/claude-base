# Design — Personal cross-project "lessons learned" referential

- **Date**: 2026-06-21
- **Status**: Approved design (pre-spec). Next: `/work:work-specify`.
- **Author**: brainstorm session (work-brainstorm)
- **Related**: `.claude/commands/lessons.md` (existing read-only viewer), auto-memory system, [[curation-vision-open-refinements]] (same observe→propose→human-gate shape), [[continuous-agent-fleets-not-for-claude-base]] (no autonomy / human-gate), [[anthropic-june15-2026-agentic-billing]] (billing-safe).

## 1. Context & problem

When using Claude Code across several personal projects, lessons learned in one project — a mistake made once, a hard-won fix, a preference — do not carry over to the others. Claude Code's auto-memory is **per-repository and machine-local**, so each project re-learns the same things and the same mistakes recur.

The goal, inspired by [Hermes](https://hermes-agent.org/) (Nous Research, MIT, Feb 2026) and its long-term self-improving memory, is to give claude-base users a **personal, cross-project "lessons learned" referential** so that *the more you use claude-base, the fewer times you repeat the same mistake* — a compounding-discipline effect that is the foundation's core differentiator.

**Explicitly NOT in scope** (decided during brainstorm): history search ("how did we do X last time"), community/shared lessons, rebuilding Anthropic-native pieces (Auto Memory, Auto Dream), and any sync infrastructure.

## 2. Locked decisions (brainstorm)

| # | Decision | Rationale |
|---|----------|-----------|
| Use-case | **(a)** "never repeat the same mistake twice" — lessons, not history search | Always-in-context guidance beats on-demand search for this goal |
| Audience | **Personal, per-user** — lessons NEVER enter the public claude-base repo | Each user's experience is their own; privacy; no community curation burden |
| Reach | Applies across **all** the user's projects **and** machines | The whole point is cross-project carry-over |
| Sync | **Bring-your-own transport** — private git repo, Syncthing, or a cloud-drive folder. claude-base stays sync-agnostic | Building sync = infra + cost, against reduction; native `~/.claude/` is machine-local |
| Architecture | **Pipeline "C"** — capture → generalize+sanitize (human-gated) → promote → propagate → recall | The disciplined graduation flow, not an auto-dump |
| Promote trigger | **(b) reflex-proposed** — Claude proposes a generalized lesson after a hard-won, generalizable fix; the human confirms/edits | Captures lessons even when the user doesn't think to; stays 100% human-gated |

## 3. Pivot resolved — native propagation (verified)

A `claude-code-guide` verification against current Claude Code docs settled the key unknown — *does a personal global store reach every project automatically?*

- ❌ There is **no native global auto-memory store**; auto-memory is **per-repository** and does not propagate across projects.
- ✅ **But three user-level surfaces ARE auto-loaded into every project session**:
  - `~/.claude/CLAUDE.md` — "user instructions", loaded in all projects.
  - **`~/.claude/rules/`** — "personal rules apply to every project on your machine; use for preferences that aren't project-specific."
  - `~/.claude/settings.json` hooks (e.g. `UserPromptSubmit`) — fire in every project.
  - `@~/...` home-relative imports in a CLAUDE.md are supported.
- ❌ **No native cross-machine sync** — `~/.claude/` is machine-local; the user must sync it (confirms BYO-transport).
- ℹ️ **Auto Dream** consolidates/prunes auto-memory but is **project-scoped and local** — it does NOT touch a user-level store, so pruning of our store is our responsibility.

**Bottom line:** propagation is essentially **free via `~/.claude/rules/`**. claude-base does not need to build any injection mechanism. This collapses the scope to *discipline only*.

**Consequence — a hard constraint:** a file under `~/.claude/rules/` is loaded into **every session of every project** → it is permanent context cost everywhere. The lessons store **must be bounded** (Hermes bounds its `MEMORY.md` to ~2,200 chars). This forces a **high graduation bar + active pruning** — which aligns perfectly with the reduction principle: only truly general, recurring lessons earn a permanent slot in every project's context.

## 4. Approaches explored

| Approach | What claude-base ships | Strengths | Weaknesses | Complexity |
|----------|------------------------|-----------|------------|------------|
| **A — Convention + thin skill** | A bounded user-level store convention (`~/.claude/rules/lessons.md`); a **capture rule** shipped into each project (instructs the reflex-propose); recall = free (native load); a light pruning routine; sync = docs | Tiny; maximizes native propagation; reduction-pure; honors human-gate & billing | Reflex is instruction-driven (followed, not enforced) → slightly less deterministic | **Low** |
| **B — + session-end hook** | A + a `Stop` hook that runs an LLM review each session to propose a lesson | Deterministic trigger | An LLM hook on every session = cost + **violates "hooks fast / LLM-free / billing-safe"**; spammy | Medium |
| **C — + sync helper** | B + a `lessons sync` command that scaffolds the transport | "Complete" | Re-does what `git`/Syncthing already do; pulls claude-base into the sync infra it explicitly rejected | High |

## 5. Decision

**Approach A.** claude-base ships the *discipline*; the platform does the *propagation*; the user does the *sync*.

- **B is rejected** as an anti-pattern: an LLM hook on every `Stop` violates the foundation's "hooks must be fast, LLM-free, billing-safe" rule and would spam. The reflex is better served by an in-conversation instruction that fires only when Claude genuinely just solved something hard.
- **C is rejected** as redundant + scope creep: `git push` / Syncthing already transport a folder; a doc recipe suffices.

The one downside of A — a non-enforced, instruction-driven reflex — is acceptable: it is the same contract as the rest of the foundation (rules are followed instructions, not blocking hooks), and it keeps cost and control on the right side.

## 6. Target architecture (Approach A)

```
   ┌─ in any project session ──────────────────────────────────────┐
   │  capture rule (shipped by claude-base into ./.claude/rules/)   │
   │     → Claude solves a hard, GENERALIZABLE problem              │
   │     → proposes a lesson, GENERALIZED + SANITIZED (no project   │
   │       specifics / secrets), human confirms or edits           │
   └───────────────────────────┬───────────────────────────────────┘
                               │ append (bounded)
                               ▼
        ~/.claude/rules/lessons.md   ← personal, user-level store
                               │
        (Claude Code natively loads it into EVERY project session)
                               │
                               ▼
   recall = free: the lesson is already in context everywhere
                               │
        user syncs ~/.claude/ via BYO transport (private repo / Syncthing / cloud)
```

### Components claude-base contributes

1. **Store convention** — `~/.claude/rules/lessons.md` (single bounded file to start; topic-split deferred). Documented layout + a one-line header marking it as the personal lessons store.
2. **Capture rule** — a rule shipped into each project (`.claude/rules/`) that instructs the reflex: *when you resolve a hard, generalizable problem, propose a one-line, generalized, sanitized lesson and, on confirmation, append it to `~/.claude/rules/lessons.md`*. Includes the **sanitize** mandate (strip project names, paths, secrets, anything project-specific) and the **generalize** mandate (a reusable principle, not "in <project> we forgot X").
3. **Promote/recall affordance** — extend the existing `/lessons` command: today it only *lists* feedback memories; add a `--promote` path (explicit fallback to the reflex) and surface the personal store. Recall itself needs no code (native load).
4. **Bounding/pruning** — a light routine (skill or `/lessons` subcommand) that keeps the store under a context budget (consolidate duplicates, drop superseded lessons). Human-gated; no LLM hook.
5. **Sync recipes (docs only)** — private git repo (recommended, versioned + free), Syncthing (no cloud, no repo), or a cloud-drive folder. claude-base only guarantees the store is a single relocatable file/dir.
6. **One-time bootstrap (backfill)** — so a user who used Claude Code *before* this feature doesn't start from scratch. The lessons they already accumulated ARE their per-project `feedback` auto-memories scattered across `~/.claude/projects/*/memory/`. A one-shot import scans those (the existing `/lessons` command already reads them), then **proposes** the general/recurring ones for promotion through the SAME generalize+sanitize+human-gate path into `~/.claude/rules/lessons.md`. Key distinction: this is the cross-project **scan** used as a **one-off backfill**, NOT an ongoing job — so it stays billing-safe (the recurring capture remains the in-conversation reflex). Out of scope for backfill: mining past transcripts (that's history-search / use-case (b), excluded, and LLM-costly); feedback memories are the already-curated signal. Degrades gracefully: a brand-new user has nothing to import and simply starts on the reflex.

### Principles honored

- **Reduction over features** — claude-base builds discipline only; native does propagation; the bound forces a high graduation bar.
- **Privacy** — personal store, never in the repo; mandatory sanitize step before any lesson is written.
- **Human-gate / no autonomy** — every promotion is confirmed by the user; no autonomous capture (consistent with the rejected agent-fleets stance).
- **Billing-safe** — no LLM hooks; the reflex is in-conversation, the promote/prune are user-invoked.
- **Don't rebuild Anthropic-native** — propagation, loading, and per-project consolidation (Auto Dream) are native; we only add the cross-project user-level layer they don't provide.

## 7. Open sub-decisions (for `/work:work-specify`)

1. **Store location**: `~/.claude/rules/lessons.md` (path-scopable, native-loaded) vs `~/.claude/CLAUDE.md` import vs a dedicated `~/.claude/rules/lessons/` topic-split dir. Lead: single `~/.claude/rules/lessons.md`, revisit topic-split if it grows.
2. **Context budget**: the concrete bound (Hermes uses ~2,200 chars). Pick a budget + a pruning trigger (size threshold? count?).
3. **Capture-rule placement**: ship the reflex rule into each project's `.claude/rules/` (consistent with how the foundation ships rules) vs document a one-time user-level `~/.claude/rules/` install. Lead: ship into projects, since the store is user-level and the reflex must fire everywhere.
4. **"Hard problem" signal**: how the reflex decides a moment is lesson-worthy without spamming (multi-attempt fix, an explicit user correction, a surprising root cause…). Needs crisp, conservative criteria.
5. **Relationship to existing `/lessons`** and to per-project feedback memories: does a promoted lesson also stay as a local feedback memory? Is there a "this local lesson recurred → promote it" path?
6. **First-run / bootstrap**: how the store and the BYO sync are initialized (a documented manual step vs a guided `/lessons` flow).

## 8. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Store bloats → context cost in every project | Hard bound + pruning routine; high graduation bar (general + recurring only) |
| Reflex too eager → proposal spam | Conservative, documented "hard problem" criteria; always one-line; human can always decline |
| Privacy leak (project specifics/secrets into a synced store) | Mandatory sanitize+generalize step in the capture rule; recommend a *private* repo if git is the transport |
| Instruction-driven reflex is inconsistent | Accepted trade-off; the explicit `--promote` path is the deterministic fallback |
| Sync conflicts across machines | BYO transport owns conflict resolution (git merge / Syncthing); store stays a simple append-mostly file to minimize conflicts |

## 9. Out of scope (explicit)

- Session-end LLM hook (Approach B) — billing/anti-pattern.
- A sync command/helper (Approach C) — redundant with git/Syncthing.
- Community/shared lessons referential — personal only.
- History/transcript search ("how did we do X") — different use-case (b), not chosen.
- Rebuilding Auto Memory / Auto Dream — native.

## 10. Next steps

1. `/work:work-specify` — user stories & acceptance criteria (capture reflex, promote, recall, prune, **one-time bootstrap/backfill**, sync docs), resolving the §7 sub-decisions.
2. `/work:work-plan` — files to create/modify (capture rule, `/lessons` extension, pruning routine, sync docs), risks.
3. TDD per the foundation workflow.
