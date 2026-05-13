# Spec: update lifecycle visibility — close the bootstrap → maintenance gap

**Status**: Validated — all 5 user stories shipped in PR #166 (v1.38.0, 2026-05-10)
**Date**: 2026-05-09
**Owner**: Chris
**Builds on**: `specs/presets-update-aware/` (shipped v1.37.0)

---

## Summary

When a user bootstraps a project with `claude-base init`, they get a soigné experience: preset auto-detection, foundation install, and a curated `recommendedVendorSkills` list printed at the end. Once they leave that bootstrap moment, every subsequent `claude-base update` runs silent: no version marker is left in the project, the recommended-vendor-skills list is never re-surfaced, and dry-run in non-TTY contexts produces a misleading "1 skipped" summary instead of listing what actually needed a decision. This spec closes that gap so the curation rigor that lives in the bootstrap also lives in the day-to-day maintenance loop, without any change to the supply-chain trust model (no auto-install of third-party code).

## User Stories

### P1 — MVP

#### US-1 — Foundation version traceable from inside the project

> **As** a user (or future me) opening a project I haven't touched in months,
> **I want** to know which version of the foundation last touched it,
> **so that** I can reason about what changed since, decide whether an update is needed, and debug drift between projects.

**Acceptance criteria**

- **Given** I run `claude-base init` (any preset) against a fresh directory,
  **when** the install completes,
  **then** the project contains a discoverable marker of the foundation version that produced it (file content matches the foundation's `VERSION` at install time).

- **Given** an existing project that already has a foundation version marker,
  **when** I run `claude-base update` (with any flag combination that touches files),
  **then** the marker is updated to the current foundation version.

- **Given** a project that has never had a marker (synced before this feature shipped),
  **when** I run `claude-base update`,
  **then** the marker is created at the current foundation version (no error, no prompt).

- **Given** the marker is present,
  **when** I run a command that introspects the project state (e.g. `claude-base validate` or any future status command),
  **then** the version is surfaced in the human-readable output.

#### US-2 — Recommended vendor skills resurface on every update

> **As** a user maintaining a project over time,
> **I want** the curated `recommendedVendorSkills` list to be re-printed at the end of `claude-base update`,
> **so that** I am periodically reminded of what complements my stack — including skills that were added to the curation list after my initial bootstrap.

**Acceptance criteria**

- **Given** a project bootstrapped with `--preset nextjs`,
  **when** I run `claude-base update` (any flag combination),
  **then** the same `recommendedVendorSkills` list that `claude-base init` would have printed appears at the end of the update output.

- **Given** the recommendation list contains a skill that was added to the preset's manifest **after** my project was bootstrapped,
  **when** I run `claude-base update`,
  **then** the new skill appears in the printed list (so the user discovers it).

- **Given** the user passed `--quiet` to `update`,
  **when** the update completes,
  **then** the recommendations list is suppressed (no noise in CI / scripted contexts).

### P2 — Important

#### US-3 — Visual cue on which recommended skills are already installed

> **As** a user reading the recommended-vendor-skills list at the end of `update`,
> **I want** each item to show whether it's already installed locally,
> **so that** I can focus on the items that are actually new to my environment, instead of re-reading the same install commands every time.

**Acceptance criteria**

- **Given** a recommended vendor skill that is already installed (detected by presence in user-global skill location),
  **when** the recommendations list is printed,
  **then** the item is annotated with a clear "already installed" indicator.

- **Given** a recommended vendor skill that is NOT installed,
  **when** the recommendations list is printed,
  **then** the item is annotated with a clear "not installed" indicator (and the install pointer remains visible).

- **Given** detection cannot be performed (e.g. the recommended item is a marketplace plugin, not a skill on disk),
  **when** the list is printed,
  **then** no false "already installed" claim is made; the item is shown as "status unknown" or simply unannotated.

- **Given** detection requires no network call,
  **when** the list is printed,
  **then** rendering completes within the same wall-clock budget as today's print (no perceptible slowdown).

#### US-4 — Dry-run in non-interactive contexts surfaces actual conflicts

> **As** a user running `claude-base update --dry-run` from a script, CI, or piped session,
> **I want** the output to clearly list files that *would* require a decision (conflicts) instead of silently auto-skipping them and reporting a misleading "1 skipped" summary,
> **so that** I can pre-flight an update accurately and make decisions before re-running interactively.

**Acceptance criteria**

- **Given** I run `update --dry-run` in a non-TTY context,
  **when** the script encounters a file that has been locally modified (would prompt in TTY),
  **then** the file is listed under a clearly labeled "conflicts requiring decision" section, with a count.

- **Given** the same context,
  **when** the dry-run completes,
  **then** the final summary reflects the real number of conflicts that would block a non-interactive run, not the auto-skipped count.

- **Given** I run `update --dry-run` in an interactive TTY,
  **when** the script encounters a modified file,
  **then** the existing interactive prompt behavior is preserved (no regression).

- **Given** there are no conflicts at all,
  **when** the dry-run completes in any context,
  **then** the conflicts section is omitted (no empty noise).

### P3 — Nice-to-have

#### US-5 — Team setup pattern documented for `.claude/`-gitignored projects

> **As** a maintainer onboarding a teammate to a project where `.claude/` is gitignored,
> **I want** an explicit documentation section that names this pattern and explains its consequences,
> **so that** the team understands why project-scope plugin/skill installs do not propagate, and which alternative scope (user-global) is recommended in this case.

**Acceptance criteria**

- **Given** a developer reads the README and/or `docs/guides/TEAM-GUIDE.md`,
  **when** they search for `.gitignore`, "team setup", or "scope",
  **then** they find a clearly named section explaining the `.claude/`-ignored pattern and its propagation consequences.

- **Given** that section,
  **when** the developer reads it,
  **then** it answers three questions: (a) why someone might gitignore `.claude/`, (b) what the consequence is for plugin/skill scope, (c) what the recommended workaround is (user-global scope, partial gitignore, or commit a recommended-skills manifest).

- **Given** the section,
  **when** a real-world example is needed,
  **then** at least one concrete recommendation per scope (`user`, `project`, `local`) is given, with the trade-off.

## Functional Requirements

| ID | Requirement |
|----|-------------|
| EF-001 | The foundation version produced by `claude-base init` MUST be discoverable from inside the project after install. The marker file MUST live at `.claude/.foundation-version`. |
| EF-001b | The marker file content MUST be a single line containing the foundation semantic version followed by a trailing newline (e.g. `1.37.0\n`). No JSON, no key-value, no metadata in v1 — keep parsing trivial (`cat` / `read`), no `jq` dependency. |
| EF-002 | Every `claude-base update` invocation that modifies files MUST refresh the project-side foundation version marker. |
| EF-003 | A project without a version marker MUST NOT cause `update` or `validate` to fail; the marker MUST be created on first eligible update. |
| EF-004 | The recommended-vendor-skills list of the active preset MUST be re-printed at the end of `claude-base update`, except in `--quiet` mode. The list MUST appear AFTER the existing "Update completed" banner and the Summary block (Added/Updated/Skipped), as the final section of the output. Rationale: preserves the existing scan path (banner → summary first), aligns with `new-project.sh` which already prints recommendations as its final section, keeps non-critical info skippable for users in a hurry. |
| EF-004b | Each recommended item MUST include an inline install pointer (the actual command to run, e.g. `npx skills add ...` or `/plugin install ...`) so the user can act without re-reading `docs/recipes/recommended-vendor-skills.md`. The recipe pointer (one line at the bottom of the section) MUST remain present for the curated rationale. |
| EF-005 | The recommended-vendor-skills list MUST visually indicate, per item, whether the skill is detectably already installed in the user's environment. The format MUST follow the existing claude-base text-marker convention (`[OK]`, `[--]`, `[?]`) used elsewhere in the scripts, with optional ANSI color via the existing `scripts/lib/common.sh` helpers. The format MUST remain readable when colors are disabled (`NO_COLOR=1` or non-TTY). |
| EF-005b | The marker semantics are: `[OK]` = installed (detection succeeded, file/dir present), `[--]` = not installed (detection succeeded, absent), `[?]` = status unknown (detection not applicable, e.g. marketplace plugin we cannot probe locally). Each line MUST also include the install-pointer source path or marketplace ID after a `--` separator so users can act without re-reading the recipe. |
| EF-006 | When detection is not possible for a given recommended item (e.g. marketplace plugin), the item MUST receive the `[?]` marker with a short reason annotation (e.g. `status unknown (plugin)`); it MUST NOT receive `[OK]` or `[--]`. |
| EF-007 | In non-TTY contexts, `update --dry-run` MUST list every file that would have triggered an interactive decision, under a clearly labeled section. |
| EF-008 | In non-TTY contexts, `update --dry-run`'s final summary MUST report the real conflict count (not the auto-skipped count). |
| EF-008b | `update --dry-run` MUST always exit with code 0 when the dry-run completes without internal error, regardless of whether conflicts are listed. Conflicts are surfaced in stdout (the listing + summary), not in the exit code. Rationale: preserve the "dry-run = informational, nothing was done, nothing failed" semantics; avoid breaking existing CI scripts that treat dry-run as always-OK. |
| EF-009 | The interactive TTY behavior of `update --dry-run` MUST be preserved without regression. |
| EF-010 | The README and team-guide MUST contain a discoverable section explaining the `.claude/`-gitignored pattern, its consequences, and recommended scope per use case. |
| EF-011 | None of the above MUST trigger any auto-install of third-party code (the supply-chain trust model documented in the README is preserved). |

## Edge Cases

- **Marker file deleted manually by the user** — next `update` recreates it silently; no warning needed.
- **Marker file contains an unknown / future version** (e.g. user downgraded the foundation) — `update` overwrites with the current version, no error; an info-level log line MAY mention the change.
- **Project on a foundation older than the one introducing the marker** — handled like a project that never had a marker (US-1, third bullet).
- **Recommended skill detection succeeds but the SKILL.md is broken / empty** — counts as installed for the purpose of US-3 (we trust filesystem presence; SKILL.md health is out of scope).
- **`recommendedVendorSkills` is empty for the active preset** — print nothing rather than an empty header.
- **Preset is not detected at all** (`--no-preset` or unknown stack) — still print whatever generic recommendations apply (or nothing); never crash.
- **Dry-run + no preset detected** — still emit the conflicts section if any conflicts exist; preset-awareness is orthogonal.
- **Dry-run with `--quiet`** — quiet supersedes; no recommendations and no conflicts list (only the final exit code matters).
- **`.claude/` gitignored AND user runs `claude-base init --scope project`** — out of scope of this spec (handled by user reading the new doc section, US-5).

## Entities

| Entity | Definition |
|--------|------------|
| **Foundation version marker** | A project-side artifact stating which `VERSION` of the foundation last produced or updated this project. **Location**: `.claude/.foundation-version` (decided in clarify session 2026-05-09). Hidden file under `.claude/` to avoid collision with projects that have their own top-level `VERSION` (Python/Go conventions, custom artefacts). Internal content is defined under "Marker content" in Functional Requirements. |
| **Recommended vendor skill** | An entry from the active preset's `recommendedVendorSkills` array (already a defined entity in the existing preset schema). |
| **Conflict** (in dry-run) | A file that exists in both the foundation and the project, where the project-side content differs from the foundation-side content, AND the user has not passed `--force`. |
| **Active preset** | The preset that `claude-base update` is operating under for this invocation (auto-detected, `--preset`-overridden, or `--no-preset`). |

## Success Criteria

| ID | Criterion |
|----|-----------|
| CS-001 | After `claude-base init` on a fresh directory, a single command (or a single file read) reveals the foundation version that produced the project. |
| CS-002 | After `claude-base update` on a project bootstrapped before this feature, the foundation version marker is present and matches the foundation's current `VERSION`, with no manual step. |
| CS-003 | After `claude-base update` on a project bootstrapped with `--preset nextjs`, the user sees the `recommendedVendorSkills` list printed at the end, with at least one item showing an "already installed" indicator (assuming the test environment has at least one of the recommended skills present in user-global scope). |
| CS-004 | When the active preset adds a new recommended vendor skill in version N+1 of the foundation, a user updating from N to N+1 sees the new item in the list (verifiable in changelog/test). |
| CS-005 | `claude-base update --dry-run` run in a piped context (e.g. `... \| cat`) on a project with at least one locally modified file emits a non-empty "conflicts requiring decision" section, and the final summary count matches the section count. |
| CS-006 | A teammate cloning a project where `.claude/` is gitignored finds, within 60 seconds of reading the README, a section that explains the implication and points to the recommended scope. |
| CS-007 | No new code path triggers a network install of third-party code without explicit user confirmation (manual code review + test that asserts `npx skills add` / `claude plugin install` is never invoked from `update.sh`). |
| CS-008 | Existing test suite (536 tests) continues to pass; new behaviors are covered by additional tests bringing the project's own coverage of changed files to ≥80%. |

## Out of Scope

- **Auto-installing recommended vendor skills** (even with confirmation). Belongs to a separate spec (the "vendor skills install UX" cluster from the brainstorm: P2.D `--show-install-commands`, conditional active recommendations, etc.).
- **Active conditionals on `recommendedVendorSkills`** (auto-detect Prisma in `package.json` → mark Prisma skills as actively recommended). Same separate spec.
- **Targeted marketplace audit** for niche stacks (Pino, Leaflet, node-cron). Belongs to the periodic audit cadence, not a feature spec.
- **`claude-base sync-team` helper** (regenerate a `recommended-skills.lock.json` manifest). Mentioned in brainstorm but excluded by the user's scope answer.
- **Changing the location or format of the foundation version marker after first ship.** This spec picks a format; revisiting it is its own future spec.
- **Surfacing the version marker in non-claude-base tooling** (e.g. badges in the project's README). Project-internal concern.
- **Backporting the marker to projects via a one-shot migration command.** The third US-1 bullet covers it implicitly via the next `update` run; no dedicated migration is shipped.

## Clarification Points

1. ~~**Marker location & format**~~ — **RESOLVED** (2026-05-09 clarify session): location is `.claude/.foundation-version`, content is a single-line semantic version (e.g. `1.37.0\n`). Rationale for location: avoids cohabitation conflict with projects that already use a top-level `VERSION` (Python, Go, custom artefacts), groups Claude-related state under `.claude/`. Rationale for content: trivial to parse, no `jq` dependency, no corruption risk on partial write, easy migration path if richer schema is needed later (next parser will detect single-line vs structured).

2. **`--quiet` interaction with the new recommendations re-print (US-2 / EF-004)** — Confirmed in EF-004 that `--quiet` suppresses the list. Open: should there be a separate `--no-recommendations` flag for users who want non-quiet output but no recommendations spam? **Default**: no separate flag in v1; revisit if asked.

3. **Detection scope for "already installed" indicator (US-3 / EF-005)** — Two locations to check: `~/.claude/skills/<id>` (skills installed via `npx skills -g` or copied) and `~/.claude/plugins/<id>` (plugins). Should we also detect project-scope (`./.claude/skills/<id>`)? **Default**: yes — check both user-global and project-local, prefer the most specific match.
