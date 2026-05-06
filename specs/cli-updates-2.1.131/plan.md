# Implementation Plan — CLI updates 2.1.126 → 2.1.131

**Date**: 2026-05-06
**Spec**: [spec.md](./spec.md)
**Status**: Plan — pending TDD / implementation

---

## Architecture

Documentation-only work, two pull requests.

```
.
├── docs/reference/
│   ├── best-practices.md           ← PR1, US-4 (CLI version refs)
│   ├── advanced-features.md        ← PR2, US-2 (plugin evaluation recipe)
│   ├── skills-catalog.md           ← PR2, US-1 (skill overrides modes)
│   └── hooks-reference.md          ← PR2, US-3 (MCP retry note)
├── README.md (or install guide)    ← PR1, US-5 (opt-in env var mention)
└── specs/cli-updates-2.1.131/
    ├── spec.md
    ├── plan.md (this file)
    └── transcripts/                ← gitignored, internal evidence
        ├── us1-skill-overrides.txt
        └── us2-plugin-url.txt

Memory (out of repo, no diff)
└── ~/.claude/projects/.../memory/
    ├── MEMORY.md                   ← US-6 index update
    └── project_socle_post_migration_todos.md ← US-6 close-out
```

No new directories under `docs/`. No changes to `presets/`, `scripts/`, `.claude/`, or `tests/`. No source code touched.

## Files to create / modify

### PR1 — Housekeeping (US-5 in repo, US-6 outside repo)

**Note 2026-05-06**: US-4 was originally in this PR but was closed audit-confirmed-moot when the foundation-wide grep showed all `CLI 2.1.x+` references are factual feature-introduction markers, not driftable claims. PR1 is reduced accordingly.

| File | Change | LOC est. |
|------|--------|----------|
| `README.md` (install section) | Add one-paragraph opt-in mention of `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` for brew/winget users | +6 |
| `specs/cli-updates-2.1.131/{spec.md,plan.md}` | New spec + plan (untracked files committed alongside PR1) | +400 |
| `~/.claude/.../memory/project_socle_post_migration_todos.md` | Mark items #1, #4, #8 as closed with reason | ±15 (memory, no PR diff) |
| `~/.claude/.../memory/MEMORY.md` | Update index entry to reflect closed items | ±1 (memory, no PR diff) |

PR1 diff target: ~6 LOC of substantive change + ~400 LOC of spec/plan documents (informational), 2 files in repo (excluding spec/plan).

### PR2 — Substantive (US-1 + US-2 + US-3)

| File | Change | LOC est. |
|------|--------|----------|
| `docs/reference/skills-catalog.md` | New "Skill overrides" section: 3 modes (off / user-invocable-only / name-only), one example per mode, neutral mapping note vs `foundation.skills.drop[]` | +35 |
| `docs/reference/advanced-features.md` | New "Evaluating a plugin before adoption" section adjacent to existing `--plugin-dir` mention (line 273): syntax for `--plugin-url <url>` and `--plugin-dir <archive.zip>`, ≤5 steps, link to marketplace audit policy | +30 |
| `docs/reference/hooks-reference.md` | New short paragraph on MCP transient auto-retry, conservative form, links to upstream changelog | +6 |

PR2 diff target: ~70 LOC, 3 files.

## Tasks (ordered)

Markers: `[P]` parallel-safe, `[BLOCKING]` must complete before next task, `[VERIF]` requires live Claude Code session, `[MEMORY]` outside repo.

### Phase 0 — Preflight

- **T001 [BLOCKING]** Rename current auto-branch `feature/auto-20260506-170752` to `feature/cli-2.1.131-housekeeping` for PR1 work. (`/git-rename` skill or manual `git branch -m`.)
- **T002 [MEMORY] [BLOCKING]** US-6: in `project_socle_post_migration_todos.md`, mark items #4 (`--dangerously-skip-permissions`) and #8 (`themes/monitors` deprecation) as closed with audit-confirmed-moot rationale. Update MEMORY.md index entry to drop them from the active list.

### Phase 1 — PR1 implementation (housekeeping doc)

- **~~T003~~** **DROPPED 2026-05-06** — US-4 closed audit-confirmed-moot (foundation grep showed all `CLI 2.1.x+` refs are factual feature-markers, not driftable).
- **T004 [P]** US-5: locate the canonical install guide. Likely candidates: `README.md` install section (lines 64–100) or `docs/guides/`. Add opt-in mention of `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` (audience: brew/winget users only; explicit "no effect on the curl one-liner install" disclaimer).
- **T005 [BLOCKING]** Run `bash scripts/test.sh` to confirm 455/455 tests pass and counts unchanged.
- **T006 [BLOCKING]** Commit PR1: one commit for US-5 (`docs(install): mention package-manager auto-update env var as opt-in`) plus a separate commit for the spec/plan documents (`docs(specs): add cli-updates-2.1.131 spec and plan`). Open PR1 with title `docs: housekeeping for CLI 2.1.131 (US-5 + spec/plan)`.

### Phase 2 — Live verification for PR2 (Q2=C policy)

- **T007 [VERIF] [BLOCKING]** US-1 live test: in a fresh Claude Code session (CC 2.1.131), set `skillOverrides` in `.claude/settings.local.json` to each of the three values (`off`, `user-invocable-only`, `name-only`) and observe behavior. Capture transcript at `specs/cli-updates-2.1.131/transcripts/us1-skill-overrides.txt`. Verify whether the new override coexists with `foundation.skills.drop[]` or supersedes it.
- **T008 [BLOCKING]** Prepare a minimal test plugin for US-2 verification: build a single-file skill in a temp dir, zip it. Resulting `.zip` is the fixture for `--plugin-dir` test. For `--plugin-url`, find a known publicly-accessible plugin .zip URL (Anthropic-published example is preferred; otherwise a GitHub release asset of any neutral plugin). NEVER reference a competitor in commit/PR text.
- **T009 [VERIF] [BLOCKING]** US-2 live test: in a fresh CC session, run `claude --plugin-url <url>` and `claude --plugin-dir <archive.zip>` (per the changelog, `--plugin-dir` accepts `.zip` since 2.1.128). Capture transcript at `specs/cli-updates-2.1.131/transcripts/us2-plugin-url.txt`. Confirm cleanup (the loaded plugin disappears at session end).

### Phase 3 — PR2 implementation (substantive doc)

- **T010 [BLOCKING]** Rename branch to `feature/cli-2.1.131-substantive` (or create from main if PR1 already merged).
- **T011 [P]** US-1: write the "Skill overrides" section in `docs/reference/skills-catalog.md` based on the T007 transcript. Include: 3 modes named, one example each, neutral mapping note vs `foundation.skills.drop[]`, explicit "presets are not migrated in this iteration" disclaimer.
- **T012 [P]** US-2: write the "Evaluating a plugin before adoption" recipe in `docs/reference/advanced-features.md` adjacent to the existing `--plugin-dir` mention (line 273). Recipe ≤5 steps. Disclaimer at the top points to marketplace audit policy. Cleanup section explicit.
- **T013 [P]** US-3: write the MCP transient auto-retry note in `docs/reference/hooks-reference.md`. Use the conservative form ("auto-retried; see upstream changelog for the bound and failure classification") per spec resolution. No live test, no transcript.
- **T014 [BLOCKING]** Run `bash scripts/test.sh`. Verify 455/455.
- **T015 [BLOCKING]** Commit PR2 atomically: one commit per US. Open PR2 with title `docs: skill overrides + plugin evaluation + MCP retry (US-1 + US-2 + US-3)`.

### Phase 4 — Wrap-up

- **T016 [MEMORY]** Update `project_socle_post_migration_todos.md`: mark items #1, #3, #5, #6, #7, #9 as DONE with PR references. Update MEMORY.md index to reflect that the CLI 2.1.131 backlog is closed.

## Risks

| # | Risk | Likelihood | Mitigation |
|---|------|-----------|------------|
| R1 | `scripts/test.sh` doc-validation hooks (counts) flag the new doc sections as drift | Low | Doc sections inside existing files do not move counts (counts track agents/commands/skills, not doc lines). Sanity-check the counters file before committing |
| R2 | `skillOverrides` only applies at user settings scope, not project — invalidating part of US-1's example | Medium | T007 transcript verifies scope. If project-scope unsupported, document the user-scope-only behavior and adjust the spec mid-flight |
| R3 | The new `skillOverrides` mechanism conflicts at runtime with `foundation.skills.drop[]` causing unexpected behavior | Medium | T007 explicitly tests coexistence. If conflict, document precedence and recommend a single mechanism |
| R4 | No publicly-accessible neutral `.zip` plugin URL exists for US-2 `--plugin-url` test, forcing self-hosting | Medium | T008 prepares fixture. As fallback, host a minimal dummy plugin as a GitHub release asset on a personal repo (cite as "example plugin", no endorsement) |
| ~~R5~~ | ~~Hard-coded CLI versions in T003 exist in places not yet identified~~ | **CLOSED 2026-05-06** — grep run, ~40 occurrences found, all factual feature-markers (non-drifty). T003 dropped, US-4 closed |
| R6 | Branch `feature/auto-20260506-170752` already has the spec untracked but no commits — renaming it is safe | None | `git branch -m` is local-only |
| R7 | Live tests require Claude Code 2.1.131 specifically; running on a stale local CC version produces a false negative | Low | T007/T009 begin with `claude --version` check |
| R8 | The MCP retry behavior wording in the upstream changelog is too thin to write a useful paragraph | Medium (US-3) | Already mitigated by the conservative form (Q2=C). If even the conservative form is too vague, drop US-3 from PR2 and track separately |

## Verification matrix

| US | Verification method |
|----|---------------------|
| US-1 | Live transcript T007 + post-merge: doc grep for the 3 mode strings (EF-001) |
| US-2 | Live transcripts T008/T009 + step count audit on the recipe (EF-003) + cross-reference grep to marketplace audit policy (EF-004) |
| US-3 | Doc grep for the upper-bound and failure-type wording (EF-005) |
| ~~US-4~~ | **CLOSED 2026-05-06** — audit-confirmed-moot, see plan.md ~~T003~~ and spec.md US-4 closure |
| US-5 | Doc grep + tone audit: opt-in language, no default behavior change (EF-007) |
| US-6 | Memory file diff: items #4 and #8 marked closed with reason (EF-008) |

## Estimated effort

| Phase | Wall time | Notes |
|-------|-----------|-------|
| Phase 0 | 5 min | Branch rename + memory close-out |
| Phase 1 (PR1) | 15 min | One small doc edit (US-5) + spec/plan commit + test.sh + PR |
| Phase 2 (live tests) | 30–40 min | T007 + T008 + T009, including transcript capture |
| Phase 3 (PR2) | 45 min | Three doc sections written from transcripts + test.sh + commits + PR |
| Phase 4 | 5 min | Memory wrap-up |
| **Total** | **~2 hours** | Sequential. Live tests and writing can interleave but stay within the same focused session |

## Out-of-plan reminders

- This plan does **not** touch presets (`presets/*/preset.json` unchanged) or scripts. Any preset migration to `skillOverrides` is a separate spec.
- Item #2 (`claude project purge` vs `uninstall.sh`) and item #5 (iTerm2) remain on the post-migration TODO as out-of-scope, per spec.
- The `feedback_review_copilot_autofix_prs.md` rule applies if any Copilot Autofix PR appears on PR1 or PR2 — review carefully before merging.
- The `feedback_release_flow_test_sh.md` rule applies: run `bash scripts/test.sh` once per PR, not before AND after each commit.
