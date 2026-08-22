# Plan: update lifecycle visibility

**Date**: 2026-05-09
**Spec**: [`spec.md`](./spec.md)
**Owner**: Chris

---

## Architecture overview

Five user stories touch four distinct surfaces of the codebase. The shape of the diff is intentionally small: no new top-level scripts, no new CLI subcommand, one new shared lib. The foundation's existing patterns (preset-aware update lib, common.sh helpers, bats tests) absorb everything.

```
scripts/
├── update.sh                        ← US-1, US-2, US-3, US-4 (call sites only)
├── new-project.sh                   ← US-1 (call site), US-2 (refactor source)
└── lib/
    ├── common.sh                    ← US-1 (write_foundation_marker helper)
    ├── preset-detect.sh             ← (no change)
    └── preset-recommendations.sh    ← NEW (US-2 + US-3 logic, extracted from
                                       new-project.sh's print_recommended_vendor_skills)

tests/
├── update.bats                      ← US-1, US-4 cases
├── update-presets.bats              ← US-2, US-3 cases
├── new-project.bats                 ← US-1 (init writes marker), regression
└── preset-recommendations.bats      ← NEW (unit tests for the extracted lib)

README.md                            ← US-5
docs/guides/TEAM-GUIDE.md            ← US-5
```

### Key architectural decisions

| Decision | Rationale |
|----------|-----------|
| Extract `print_recommended_vendor_skills` from `new-project.sh` into `lib/preset-recommendations.sh` | Same function called from two entry points (init, update). Avoids duplication. Lib is unit-testable. |
| Marker file written by a single helper `write_foundation_marker` in `lib/common.sh` | Every entry point that mutates a project (init, update) calls one helper. No drift. |
| Detection of installed skills uses pure filesystem checks (`[ -d ~/.claude/skills/<id> ]`) | No network, no API calls. Works offline. Honors the supply-chain trust model (we OBSERVE, never INSTALL). |
| `[OK]` / `[--]` / `[?]` markers reuse existing colored helpers | Visual consistency with the rest of update.sh output (success/warning/info). |
| Conflict listing in non-TTY dry-run is purely additive (new section, no removal) | Preserves any existing script that greps the current output. Backward compatible. |
| US-5 doc lives in two places (README short pointer + TEAM-GUIDE long form) | Discoverability (README is read first) without bloating the README. |

### Files to create

| File | Purpose | Estimated LoC |
|------|---------|---------------|
| `scripts/lib/preset-recommendations.sh` | Extracted print function + new detection logic | ~120 |
| `tests/preset-recommendations.bats` | Unit tests for the lib | ~80 |

### Files to modify

| File | Change | Estimated LoC delta |
|------|--------|---------------------|
| `scripts/lib/common.sh` | Add `write_foundation_marker`, `read_foundation_marker_from_project` helpers | +25 |
| `scripts/update.sh` | Call marker write after successful update; call recommendations re-print before final exit; emit conflicts section in non-TTY dry-run | +40 |
| `scripts/new-project.sh` | Replace inlined print with `source lib/preset-recommendations.sh`; call marker write at install end | -65 / +5 |
| `tests/update.bats` | New cases: marker written, marker refreshed, dry-run conflicts in non-TTY | +60 |
| `tests/update-presets.bats` | New cases: recommendations re-printed at end of update, indicator format | +40 |
| `tests/new-project.bats` | New case: marker present after init | +15 |
| `README.md` | New short section "Team setups & `.claude/` gitignored" with pointer to TEAM-GUIDE | +20 |
| `docs/guides/TEAM-GUIDE.md` | New section "Scope choices when `.claude/` is gitignored" with the three-question framework from EF-010 | +60 |
| `CHANGELOG.md` | Entry under `[Unreleased]` | +10 |

**Total estimate**: ~480 lines added, ~65 removed across 9 files (+1 new lib, +1 new test). Comfortably fits "standard feature" workflow scope (workflow.md "1-5 tasks").

---

## Tasks per User Story

Ordered for TDD: each task pair is **(test first, then implementation)**. Tasks within a US can be done in one commit each.

### US-1 — Foundation version marker (P1)

| # | Task | Test before code |
|---|------|------------------|
| T1.1 | Add `write_foundation_marker(target_dir, version)` helper in `lib/common.sh`. Writes `<target>/.claude/.foundation-version` with single-line version + newline. Idempotent. | `tests/common.bats` — write helper creates file, content matches, mkdir -p `.claude` if missing |
| T1.2 | Add `read_foundation_marker_from_project(target_dir)` helper. Returns version string or empty. | `tests/common.bats` — read returns content, returns empty for missing file |
| T1.3 | Call `write_foundation_marker` at end of `new-project.sh` install (after `print_recommended_vendor_skills` reorganisation in T2.1) | `tests/new-project.bats` — after `init`, marker exists with correct version |
| T1.4 | Call `write_foundation_marker` at end of `update.sh`, only when update succeeded AND not in dry-run | `tests/update.bats` — after `update`, marker exists; after `update --dry-run`, marker NOT modified |
| T1.5 | Add `update.sh --version` output to mention the project marker version when run inside a project (read via T1.2) | `tests/update.bats` — `update --version` from inside project shows project marker |

### US-2 — Recommendations re-printed at update (P1)

| # | Task | Test before code |
|---|------|------------------|
| T2.1 | Create `scripts/lib/preset-recommendations.sh`. Move `print_recommended_vendor_skills` from `new-project.sh`. Keep signature compatible. | `tests/preset-recommendations.bats` — function callable, prints expected sections for nextjs preset, returns 0 when no preset / no jq |
| T2.2 | Update `new-project.sh` to `source lib/preset-recommendations.sh` instead of defining the function inline. Remove the inlined definition. | Existing `tests/new-project.bats` continues to pass — regression check |
| T2.3 | In `update.sh`, after the final summary, source the lib and call `print_recommended_vendor_skills`, gated by `! $QUIET` and `[[ -n "$ACTIVE_PRESET_FILE" ]]` | `tests/update-presets.bats` — `update --preset nextjs` ends with the recommendations section; `update --quiet` does not |
| T2.4 | Verify the section appears AFTER the "Update completed" banner and Summary block (per EF-004 ordering) | `tests/update-presets.bats` — assert order in stdout via `awk` / `grep -n` |

### US-3 — Already-installed indicator (P2)

| # | Task | Test before code |
|---|------|------------------|
| T3.1 | Add `detect_skill_install_status(skill_id) -> "installed" / "not_installed" / "unknown"` in `lib/preset-recommendations.sh`. Logic: marketplace plugin (id contains `@`) → `unknown`; else check `~/.claude/skills/<id>` and `<project>/.claude/skills/<id>` → `installed` if either; else `not_installed`. | `tests/preset-recommendations.bats` — fake `~/.claude/skills/<id>` exists → installed; absent → not_installed; id with `@` → unknown |
| T3.2 | Modify `print_recommended_vendor_skills` to invoke `detect_skill_install_status` per item and prefix with `[OK]` / `[--]` / `[?]` markers. Use existing color helpers. | `tests/preset-recommendations.bats` — output contains `[OK]` for installed skill, `[--]` for missing, `[?]` for plugin |
| T3.3 | Add inline install pointer per item (the actual install command, not just URL). Source: hardcoded mapping by id-prefix (`vercel-` → `npx skills add vercel-labs/...`, `prisma-` → `npx skills add prisma/skills ...`, `*@claude-plugins-official` → `/plugin install ...`). | `tests/preset-recommendations.bats` — output contains the expected install commands per id |
| T3.4 | Verify NO_COLOR=1 still produces readable output (markers in plain text) | `tests/preset-recommendations.bats` — set NO_COLOR=1, assert no ANSI escape codes in output |

### US-4 — Dry-run conflicts in non-TTY (P2)

| # | Task | Test before code |
|---|------|------------------|
| T4.1 | In `update.sh`, when `$DRY_RUN && ${NON_INTERACTIVE:-false}` AND a file would have triggered an interactive prompt, append `rel_path` to a global array `DRY_RUN_CONFLICTS=()` instead of the silent `skipped` branch. | `tests/update.bats` — modified file in non-TTY dry-run → conflict tracked |
| T4.2 | After all directory walks, before the final summary, if `${#DRY_RUN_CONFLICTS[@]} > 0`, emit a section "Conflicts requiring decision (N)" listing each path. | `tests/update.bats` — section present in stdout when conflicts exist |
| T4.3 | Update the final summary to report conflict count separately from auto-skipped count | `tests/update.bats` — summary mentions both counts when conflicts exist |
| T4.4 | Confirm exit code remains 0 (per EF-008b) | `tests/update.bats` — assert `$?` is 0 even with conflicts in non-TTY dry-run |
| T4.5 | Confirm interactive TTY behavior unchanged (regression) | Existing `tests/update.bats` interactive cases still pass |

### US-5 — Documentation (P3)

| # | Task | Test |
|---|------|------|
| T5.1 | Add new section to `docs/guides/TEAM-GUIDE.md`: "When `.claude/` is gitignored — scope choices for plugins & skills". Cover (a) why someone gitignores `.claude/`, (b) consequence on project-scope plugins/skills propagation, (c) recommended scope per use case (table: user / project / local), (d) one concrete example each. | Manual review (no test framework for prose). Verify the three questions in EF-010 are answered. |
| T5.2 | Add short pointer to README.md (under existing "Team Guide" or new subsection) linking to the new TEAM-GUIDE section | Manual review — link works, section name matches. |
| T5.3 | Add CHANGELOG entry under `[Unreleased]` describing the lifecycle-visibility batch | Manual review |

---

## Execution order

Dependencies form a small DAG. Order respects them and groups related tests:

1. **T1.1, T1.2** — `lib/common.sh` helpers (foundation, no dependency)
2. **T2.1, T2.2** — Extract recommendations lib (foundation for US-3, decouples from new-project.sh)
3. **T1.3, T1.4, T1.5** — Wire marker write in init + update + version display
4. **T2.3, T2.4** — Wire re-print in update
5. **T3.1, T3.2, T3.3, T3.4** — Add indicator + install pointers
6. **T4.1, T4.2, T4.3, T4.4, T4.5** — Dry-run conflicts (independent, can be parallelized with US-3 if multiple sessions)
7. **T5.1, T5.2, T5.3** — Documentation (parallelizable with everything; recommended last so the changelog entry reflects the final shipped behavior)

Each numbered group is one commit. Total: 7 commits, ~480 LoC.

---

## Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Refactoring `print_recommended_vendor_skills` out of `new-project.sh` breaks existing init flow | Medium | High (regression on shipped feature) | T2.2 mandates regression test pass; verify by running `tests/new-project.bats` before T2.3 |
| Marker file conflicts with a project that already had `.claude/.foundation-version` for another reason | Very low | Low | The `.claude/` namespace is owned by Claude Code conventions; collision unlikely. If found in practice, update.sh already preserves user-modified files via the existing diff-and-prompt path. |
| Detection logic produces false positives (says "installed" when only an empty dir exists) | Low | Medium | T3.1 specifies "presence of `<id>` directory" — empty dir = installed (filesystem semantics). Document in spec edge case (already covered: "broken/empty SKILL.md = installed"). |
| Hardcoded install-pointer mapping (T3.3) drifts from reality when vendors change CLI | Medium | Medium | Mapping lives in one place (`preset-recommendations.sh`). Periodic re-verification = part of marketplace audit cadence. Issue documented as known maintenance burden. |
| Dry-run conflict listing changes stdout enough to break a downstream parser | Low | Low | Change is purely additive (new section between summary and end). No removals, no reorderings. CS-005 asserts the addition. |
| `--quiet` interaction missed in some entry point | Low | Low | T2.3 explicitly gates re-print on `! $QUIET`; one assertion suffices. |
| ShellCheck regression from new lib | Medium | Low | Run `scripts/lint.sh` before each commit. Lib follows same patterns as existing libs. |

---

## Verification strategy

Per CLAUDE.md mandate ("give Claude a way to verify"), each layer gets a verification:

| Layer | How verified |
|-------|--------------|
| Helpers (US-1 lib) | `tests/common.bats` — pure unit tests, no fs side effects beyond temp dirs |
| Lib (US-2/US-3) | `tests/preset-recommendations.bats` — unit tests with fake preset JSON + fake `~/.claude/skills/` |
| Integration (init writes marker) | `tests/new-project.bats` — full init in temp dir, assert marker present |
| Integration (update writes marker, re-prints) | `tests/update.bats` + `tests/update-presets.bats` — full update in temp dir, assert marker + recommendations |
| Dry-run conflicts | `tests/update.bats` — temp project with locally modified file, run `update --dry-run --yes`, assert conflicts section in stdout |
| Backward compat | Existing 536-test suite must continue to pass before any commit (per workflow.md baseline rule) |
| ShellCheck | `scripts/lint.sh` zero warnings on new + modified scripts |
| Manual smoke (installed project) | After implementation, re-run the same flow as today's session against a real installed project and verify the new behaviors fire (marker created, recommendations re-printed with indicators) |

---

## Out-of-band concerns

- **Versioning**: this is a behavior-additive change with one new file format (`.claude/.foundation-version`). No breaking change. Suitable for a **minor** bump (v1.38.0).
- **Migration**: no migration path needed — projects without a marker get one on next `update` (per US-1 third bullet). No `claude-base migrate` step.
- **Documentation surfaces** (beyond US-5): `docs/reference/commands.md` may need a one-line addition for the new flag if any (currently none planned). Verify at PR time.

---

## What this plan deliberately does NOT do

- No new CLI subcommand. Everything reuses `init` and `update`.
- No new flag in v1 (no `--no-recommendations`, no `--strict`). Defaults match clarify decisions.
- No auto-install of any third-party code. Detection is read-only.
- No richer marker content (timestamp, source URL, preset name) — single-line semver per clarify decision. Future spec can revisit.
- No active-conditional recommendations (auto-detect Prisma → mark prisma skills as recommended). Belongs to the separate "vendor skills install UX" spec, explicitly out of scope.
- No `claude-base sync-team` helper. Excluded by user's scope answer in /work-clarify.
