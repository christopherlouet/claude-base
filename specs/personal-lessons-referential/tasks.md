# Tasks — Personal cross-project "lessons learned" referential

> Plan: `specs/personal-lessons-referential/plan.md`. `[P]` = parallelizable. `[USx]` = traceability.

## Phase 1 — P1 MVP (capture rule + store convention + recall)

- **T001** `[US1][US3]` Write `.claude/rules/self-improvement.md` — global rule (no `paths:`). Content (terse): the human-gated capture reflex; the "hard problem" triggers (>1 failed attempt OR explicit user correction OR non-obvious root cause); the mandatory **generalize + sanitize** step (no project names/paths/URLs/secrets); the append target `~/.claude/rules/lessons.md`; the ~2,000-char bound + "propose prune when full"; the privacy/never-in-repo note. Keep it short (it loads in every project).
- **T002** `[US2][US7]` Write `docs/recipes/personal-lessons-referential.md` — what the store is, recall is automatic (native), the privacy model, and **BYO sync recipes** (private git repo = recommended; Syncthing = no-cloud-no-repo; cloud-drive). State claude-base ships no sync.
- **T003** `[US1]` Register the rule: `.claude/rules/README.md` (new row + "Available rules (N)" 31→32 + priority-order entry). Follow base-maintenance checklist.
- **T004** Run `npm --prefix website run generate` → regenerate `website/docs/**`; then `scripts/validate-counts.sh` must pass. Commit `counts.json` + mirror.
- **T005** `CHANGELOG.md` `[Unreleased]` Added entry (personal cross-project lessons mechanism; data stays user-owned).
- **T006** `[P]` Verify (verification rule, manual/model): the rule reads correctly, is terse, and a lesson written to `~/.claude/rules/lessons.md` is visibly loaded in another project (smoke test). Confirm nothing wrote into the repo.

> Gate at end of Phase 1: `validate-counts` + `audit-base.sh` + `audit-docs.sh` green; rule size measured and acceptably small.

## Phase 2 — P2 (command modes + deterministic helper, TDD)

- **T010** `[US6]` RED: `tests/lessons.bats` for `scripts/lessons.sh bootstrap-scan` — fake `$HOME/.claude/projects/<slug>/memory/` trees with `feedback` memories (general vs project-specific), assert scan lists the general/recurring candidates and skips project-specific ones; empty/no-memory → clean no-op. (HOME overridden, jq mocked, no `timeout`.)
- **T011** `[US5]` RED: `tests/lessons.bats` for `scripts/lessons.sh prune-check` — store over budget → over-budget verdict + suggested drops; under budget → ok; near-duplicate detection.
- **T012** `[US5][US6]` GREEN: implement `scripts/lessons.sh` (`bootstrap-scan`, `prune-check`) to pass T010/T011. Memory root is a parameter defaulting to `$HOME/.claude`. shellcheck `-S warning` clean.
- **T013** `[US4][US5][US6]` Extend `.claude/commands/lessons.md`: add `--promote` (explicit capture via the same generalize+sanitize+confirm path), `--prune` (calls `prune-check`, then guided human-gated consolidation), `--bootstrap` (calls `bootstrap-scan`, then per-candidate generalize+sanitize+confirm). Update the "read-only" note. Keep default `--list` behavior.
- **T014** `[P]` Update `docs/reference/commands.md` (and any catalog) for the new `/lessons` modes; finalize sync recipes doc cross-links.
- **T015** Regen mirror + `validate-counts` + `audit-docs` green; run full `scripts/test.sh`.

> Gate at end of Phase 2: full bats suite green; new helper covered ≥80%; shellcheck clean; structural gates green.

## Phase 3 — P3 (nice-to-have, defer)

- **T020** `[US8]` Optional topic grouping in the store + `prune-check` awareness of sections.
- **T021** `[US9]` Recurrence signal: when the same lesson is proposed again, increment a "seen N times" marker instead of duplicating (helper dedupe already lays groundwork).

## Cross-cutting

- **X01** No LLM hooks anywhere (billing-safe) — the reflex is rule instruction, prune/bootstrap are user-invoked.
- **X02** The lessons data file `~/.claude/rules/lessons.md` is never added to the repo (.gitignore not needed since it lives outside any repo; just never `git add` it).
- **X03** Adversarial review before PR (per the proven session loop): focus on privacy (sanitize completeness), the rule's terseness/context cost, and the helper's HOME-isolation in tests.
