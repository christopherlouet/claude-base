# Plan — Personal cross-project "lessons learned" referential

> Spec: `specs/personal-lessons-referential/spec.md` · Design: `docs/designs/2026-06-21-personal-lessons-referential-design.md`
> Phase: PLAN. Next: `/dev:dev-tdd`.

## 1. Summary

Ship the **mechanism** for a personal, cross-project lessons referential. The data (lessons) is the user's, stored at `~/.claude/rules/lessons.md` and loaded natively into every project — claude-base never holds it. The work is mostly **convention + model-instruction** (a global capture rule + an extended `/lessons` command), with a small **deterministic shell helper** for the bootstrap scan and prune-budget math so those parts are testable.

## 2. Technical context

- **Propagation is native** (verified): a file under `~/.claude/rules/` is auto-loaded into every project session. So **no injection mechanism is built**; recall (US-2) is free.
- `~/.claude/` is **machine-local** → cross-machine (US-7) is bring-your-own sync, documented only.
- **Auto Dream is project-scoped** → it will NOT prune our user-level store → prune (US-5) is ours.
- **Key architectural reality:** rules and slash-commands are **prompts**, not programs. The capture reflex (US-1), generalize/sanitize (US-3), and the confirm step are **model-instruction** and are NOT behaviorally bats-testable. Only the deterministic mechanics (scan existing feedback memories, compute store size vs budget, list candidates, dedupe) are shell → those go into `scripts/lessons.sh` and ARE bats-tested.
- **Context-cost caution:** the capture rule is shipped into every project (`.claude/rules/`) AND the lessons store is loaded in every project. **Both must be terse** — the rule is concise instruction; the store is bounded (~2,000 chars / ~15–20 lessons).

## 3. Architecture

```
SHIPPED BY claude-base (in the repo)            USER-OWNED (runtime, never in repo)
────────────────────────────────────            ──────────────────────────────────
.claude/rules/self-improvement.md  ──instructs──▶  reflex: after a hard, generalizable
   (global rule, no paths, terse)                   fix → propose 1 sanitized lesson →
                                                     on confirm, append to ↓
.claude/commands/lessons.md  ──orchestrates──▶   ~/.claude/rules/lessons.md   (the store)
   (--list default, --promote, --prune,            (bounded; auto-loaded into EVERY
    --bootstrap)                                     project by Claude Code = free recall)
        │ calls (Bash) for deterministic work
        ▼
scripts/lessons.sh  (bootstrap-scan | prune-check)   reads ~/.claude/projects/*/memory/
   ← bats-tested                                       (existing per-project feedback memories)

docs/recipes/personal-lessons-referential.md  ── how-to: store, bootstrap, BYO sync recipes
```

Separation of concerns: the **rule** says *how to capture/sanitize*; the **command** orchestrates promote/prune/bootstrap; the **helper** does the deterministic file work; the **store** holds the data (user's). The foundation ships the first three, never the fourth.

## 4. Files to create / modify

### Create
| Path | Purpose | US | Phase |
|------|---------|----|----|
| `.claude/rules/self-improvement.md` | Global capture rule (terse): the human-gated reflex, the "hard problem" triggers, the mandatory generalize+sanitize, the append target, the bound | US-1, US-3 | 1 |
| `docs/recipes/personal-lessons-referential.md` | User how-to: what the store is, recall is automatic, bootstrap, **BYO sync recipes** (private repo / Syncthing / cloud), privacy guidance | US-7, US-6, US-2 | 1/2 |
| `scripts/lessons.sh` | Deterministic helper: `bootstrap-scan` (find promotable feedback memories across `~/.claude/projects/*/memory/`), `prune-check` (store size vs budget, list near-duplicates) | US-5, US-6 | 2 |
| `tests/lessons.bats` | bats for `scripts/lessons.sh` (scan, budget math, dedupe, empty cases) — gh/jq mocked, no `timeout` | US-5, US-6 | 2 |

### Modify
| Path | Change | US | Phase |
|------|--------|----|----|
| `.claude/commands/lessons.md` | Add modes: `--promote` (explicit capture, fallback), `--prune` (guided consolidation), `--bootstrap` (one-off backfill); call `scripts/lessons.sh` for the deterministic parts; update the "read-only" note | US-4, US-5, US-6 | 2 |
| `.claude/rules/README.md` | New rule row + bump "Available rules (N)" 31→32 + priority-order entry | US-1 | 1 |
| `counts.json` | rules count via regen | — | 1 |
| `website/docs/**` | regenerated mirror (`npm --prefix website run generate`) | — | 1/2 |
| `CHANGELOG.md` | `[Unreleased]` Added entry | — | 1/2 |
| `docs/reference/commands.md` | reflect the new `/lessons` modes if catalogued there | US-4 | 2 |

> The lessons data file `~/.claude/rules/lessons.md` is created at RUNTIME by the user/reflex and is **never** committed to this repo.

## 5. Phases

### Phase 1 — P1 MVP: capture rule + store convention + recall (mostly docs/rule)
The core "never repeat a mistake" loop. Deliverables: the global `self-improvement` rule (terse, with triggers + sanitize mandate + append target + bound), the recipes doc (store + automatic recall + privacy), README/counts/regen, CHANGELOG. **No shell, no bats** — validated by structural gates + the foundation's own verification rule (manual/model check that the rule reads correctly and the store loads). Honest note in the plan: P1 is instruction-only by nature.

### Phase 2 — P2: command modes + deterministic helper (TDD here)
`scripts/lessons.sh` (`bootstrap-scan`, `prune-check`) with `tests/lessons.bats` (RED→GREEN). Extend `/lessons` with `--promote`/`--prune`/`--bootstrap` wired to the helper. Sync recipes finalized. This is where TDD actually bites (the deterministic helper).

### Phase 3 — P3: nice-to-haves
Topic grouping in the store, recurrence ("seen N times") signal. Likely small helper additions + rule/command wording. Defer until P1/P2 proven.

## 6. Testability approach (explicit)

| Part | Testable? | How |
|------|-----------|-----|
| Capture reflex / generalize / sanitize / confirm (US-1, US-3) | No (model-instruction) | Structural gates (validate-counts, audit-base, `command-validator.bats` rule/command conventions) + the verification rule's manual/model check |
| Cross-project recall (US-2) | No (native platform) | Verified once via claude-code-guide; documented; manual smoke test |
| `scripts/lessons.sh bootstrap-scan` (US-6) | **Yes** | bats: fake `~/.claude/projects/<slug>/memory/` trees with `feedback` memories → scan lists the general/recurring candidates; empty tree → no-op |
| `scripts/lessons.sh prune-check` (US-5) | **Yes** | bats: store over/under the byte budget → correct over-budget verdict; near-duplicate detection |
| `/lessons` mode dispatch (US-4/5/6) | Partial | the command is a prompt, but its call into `scripts/lessons.sh` is shell — test the helper, smoke-test the dispatch |

bats conventions: gh/jq mocked, **no `timeout`** (macOS gate), `HOME` overridden to a temp dir so the scan reads a fake `~/.claude` (never the real one).

## 7. Risks & mitigations

| Risk | Sev | Mitigation |
|------|-----|------------|
| Reflex is model-instruction → may not fire, or fire too eagerly | Med | Crisp, conservative "hard problem" triggers in the rule; explicit `/lessons --promote` fallback; user can always decline |
| The shipped capture rule adds context cost to EVERY project | Med | Keep the rule terse (it competes for the same budget it polices); measure its size |
| Store bloat → context cost everywhere | Med | Hard bound (~2,000 chars) + `--prune`; high graduation bar baked into the rule |
| Privacy leak (project specifics/secrets into a synced store) | High | Prominent mandatory sanitize step in the rule; recipes recommend a **private** repo; `prune-check`/scan can flag obvious secrets patterns as a backstop |
| Helper reads/writes the wrong `~/.claude` in tests | Med | Override `HOME`/target dir in bats; the helper takes the memory root as a parameter, defaulting to `$HOME/.claude` |
| New rule breaks counts/docs gates | Low | Follow base-maintenance checklist: README row + priority + counts + `npm run generate` + validate-counts before commit |
| Scope creep into sync infra | Low | Docs-only for sync; no command/script that performs sync (locked out of scope) |

## 8. Complexity

**Medium.** Low code volume, but unusual shape: the value is mostly in well-crafted model-instruction (hard to test, easy to get subtly wrong) plus a small testable helper. The risk is in wording discipline (terseness, sanitize, triggers) and respecting the foundation's gates, not in algorithmic difficulty.

## 9. Out of scope (carried from spec)

Session-end LLM hook · any sync command/service · community/shared lessons · history/transcript search · re-implementing Auto Memory/Auto Dream · mining transcripts during bootstrap.
