# Spec: preset-aware updates — keep the preset filter coherent across the project lifecycle

**Status**: Draft
**Date**: 2026-05-09
**Owner**: Chris
**Builds on**: `specs/presets-detection-and-e2e/` (shipped 2026-05-09 in PR #160 + PR #161)

---

## Summary

When a project was bootstrapped with `--preset X`, every subsequent `claude-base update --all` currently re-introduces every skill that the preset deliberately dropped. The preset's filtering is honored at install time but silently violated on every update, leaving the user with a project that drifts back to the unfiltered foundation. This spec makes `update` reuse the existing detection mechanism so that the filter the user signed up for stays applied across the project's lifetime, without introducing any new persisted state.

## User Stories

### P1 — MVP

#### US-1 — Preset filter survives updates

> **As** a user who initialized my project with `--preset nextjs`,
> **I want** subsequent `claude-base update --all` runs to keep the same skill filter,
> **so that** my project stays scoped to the stack I chose, instead of drifting back to every skill in the foundation.

**Acceptance criteria**

- **Given** a project bootstrapped with `--preset nextjs` (which drops a known set of out-of-stack skills),
  **when** I run `claude-base update --all` against that project later,
  **then** the dropped skills are not re-introduced into the project.

- **Given** the same project,
  **when** I run `claude-base update --all` followed by listing the skills present in the project,
  **then** the resulting set matches what a fresh `claude-base init --preset nextjs` would produce.

#### US-2 — Manual override of the active preset

> **As** a user who knows my project's preset (e.g. because I just renamed something that broke auto-detection, or I want to temporarily lock to a specific preset),
> **I want** to pass `--preset <name>` to `claude-base update`,
> **so that** the update applies that preset's filter regardless of what the project content currently looks like.

**Acceptance criteria**

- **Given** any project directory and a valid preset name,
  **when** I run `claude-base update --preset nextjs --all <path>`,
  **then** the update applies the `nextjs` preset's filter without consulting the auto-detection result.

- **Given** an invalid or unknown preset name,
  **when** I pass `--preset <bogus>` to update,
  **then** the command fails with a clear error naming the missing preset, before performing any file change.

#### US-3 — Opt out of preset filtering

> **As** a user who deliberately wants the unfiltered foundation on this update (e.g. I'm migrating away from a preset, or I want to audit every skill),
> **I want** to pass `--no-preset` to `claude-base update`,
> **so that** the update behaves exactly as today (every skill is copied, no preset filter applied).

**Acceptance criteria**

- **Given** a project that would otherwise auto-detect a preset,
  **when** I run `claude-base update --no-preset --all <path>`,
  **then** the update copies every skill without applying any preset filter.

- **Given** the same `--no-preset` flag combined with `--preset <name>`,
  **when** I run the command,
  **then** it fails fast with a clear message stating the two flags are mutually exclusive.

### P2 — Important

#### US-4 — Visibility into which preset is active

> **As** a user running `claude-base update`,
> **I want** the foundation to print which preset is being applied (if any) and why (auto-detected vs explicit flag),
> **so that** I am never surprised by a silent filter change.

**Acceptance criteria**

- **Given** a project that auto-detects a preset,
  **when** update runs,
  **then** the output contains a line naming the preset and the source ("detected" or "via --preset").

- **Given** a project where no preset matches and no flag is passed,
  **when** update runs,
  **then** no extra line is printed about presets (silence preserves byte-identity with today's behavior — see CS-006).

#### US-5 — Dry-run shows the filtered plan

> **As** a user about to run a real update,
> **I want** `--dry-run` to show which skills will be skipped because of the active preset filter,
> **so that** I can audit the plan before any file is changed.

**Acceptance criteria**

- **Given** a project with an active preset (auto-detected or explicit),
  **when** I run `update --all --dry-run`,
  **then** the dry-run output explicitly lists the skills that the preset's filter would skip.

#### US-6 — Orphan detection respects the preset

> **As** a user running `update --detect-orphans` or `--remove-orphans` on a preset-installed project,
> **I want** skills the active preset deliberately dropped to NOT be reported as orphans,
> **so that** orphan-detection does not falsely flag intentionally-absent skills.

**Acceptance criteria**

- **Given** a project where the active preset drops skill `dev-flutter`,
  **when** I run `update --detect-orphans <path>`,
  **then** `dev-flutter` does not appear in the orphan list, even though it exists in the foundation but not in the project.

### P3 — Nice-to-have

#### US-7 — Ambiguity disambiguation

> **As** a user whose project happens to match two presets at once (rare but possible — e.g. a mono-repo with both Next.js and FastAPI markers),
> **I want** `update` to refuse to silently pick one,
> **so that** I am forced to be explicit about which preset's filter applies.

**Acceptance criteria**

- **Given** a project where `scan_presets` returns two or more preset names,
  **when** I run `update --all <path>` without `--preset` and without `--no-preset`,
  **then** the command exits non-zero with a message listing every match and instructing me to re-run with `--preset <name>` or `--no-preset`.

## Functional Requirements

### Detection at update time

- **EF-001** — When `update` is called without `--preset` and without `--no-preset`, the foundation evaluates the project directory against every available preset's `detect` rule (reusing the existing detection library shipped in PR #160).
- **EF-002** — When exactly one preset matches, that preset becomes the "active preset" for this update run; its skill filter is applied to all subsequent copy operations.
- **EF-003** — When zero presets match, no preset filter is applied; behavior is identical to today's `update`.
- **EF-004** — When two or more presets match, the command exits non-zero with a message listing every matching preset name and instructing the user to re-run with `--preset <name>` or `--no-preset`.

### Explicit override

- **EF-005** — `--preset <name>` overrides any auto-detection result; the named preset's filter is applied unconditionally.
- **EF-006** — `--preset <name>` where `<name>` does not resolve to a known preset (neither vouched nor community-curated) causes the command to exit non-zero with a clear error before any file change is made.
- **EF-007** — `--no-preset` disables both detection and filtering for this update run; the command behaves as today.
- **EF-008** — `--preset` and `--no-preset` are mutually exclusive; passing both causes a fast non-zero exit with a clear message.

### Filter application

- **EF-009** — The active preset's filter applies only to the skills directory copy step; commands, agents, rules, and other foundation components are unaffected (matches today's preset semantics).
- **EF-010** — When the active preset has an empty or absent skill-drop list, the filter is a no-op; behavior matches having no preset.
- **EF-011** — The filter is applied only to the COPY step (the update does not proactively delete skills the user may have customized that the preset would drop). The filter prevents re-adding dropped skills, not removing existing ones.

### Visibility

- **EF-012** — At the start of an update run, the foundation prints exactly one line stating which preset is active and how it was selected (`detected` vs `--preset`). When no preset is active (no match and no explicit flag, or `--no-preset`), the foundation prints nothing extra; the user sees output byte-identical to today's update (preserves CS-006 for non-preset users).
- **EF-013** — `--dry-run` output names every skill that the active preset's filter would skip.
- **EF-014** — `--detect-orphans` and `--remove-orphans` exclude from the orphan set any skill that the active preset's filter drops; those skills are intentionally absent.

### Backwards compatibility

- **EF-015** — On a project where no preset's `detect` rule matches AND no flag is passed, every observable update behavior (file copies, exit code, output structure) is identical to today's `update`. No regression for non-preset users.

## Edge Cases

- **No preset matches and no flag passed** — behavior identical to today (no filter applied, no warning).
- **Two or more presets match without explicit override** — command refuses to proceed (EF-004), forcing the user to disambiguate.
- **`--preset` for a project that no longer matches that preset's rule** — the explicit choice is honored without commentary; the user knows what they asked for.
- **`--preset` and `--no-preset` together** — fast fail with a clear message (EF-008).
- **Preset has no skill-drop list** — filter is a no-op (EF-010); the visibility line still states the preset is active.
- **The detection library cannot run** (missing dependency, malformed manifest, …) — degrade gracefully: no filter applied, a single warning printed, update proceeds. Users explicitly running `--preset <name>` are not affected because that path bypasses detection.
- **Project directory does not exist** — handled by the existing pre-flight check; no change.
- **A skill the user customized is also in the preset's drop list** — the customized skill stays untouched on disk; the filter only blocks re-adding from the foundation, never removes (EF-011). The user is responsible for cleaning up customized files if they want to fully match a preset.

## Entities

| Entity | Purpose | Key attributes |
|---|---|---|
| **Detection result** | What the foundation reports back from scanning the target directory | matching preset names (zero, one, or many) |
| **Active preset** | The preset whose filter will apply for this update run | preset name, source (auto-detected, explicit `--preset`, or "none") |
| **Skill drop list** | Skills the active preset removes from a fresh install | array of skill identifiers (already part of the existing manifest) |

## Success Criteria

- **CS-001** — A project bootstrapped with `claude-base init --preset nextjs ./X`, then updated with `claude-base update --all ./X`, has the same set of skills as a fresh `claude-base init --preset nextjs ./Y`. Verified by comparing directory listings.
- **CS-002** — The same project run through `claude-base update --no-preset --all ./X` ends up with every foundation skill present, including the ones the preset originally dropped.
- **CS-003** — A project that auto-matches two or more presets, run without `--preset` and without `--no-preset`, exits non-zero and the message names each matching preset.
- **CS-004** — `claude-base update --all --dry-run` on a preset-installed project lists, in plain text, every skill the active preset's filter will skip.
- **CS-005** — `claude-base update --detect-orphans` on a preset-installed project does not list any skill that the preset's filter drops as an orphan.
- **CS-006** — On a project where no preset matches and no flag is passed, the output lines, exit code, and modified files are byte-identical to today's `update --all` output (no regression).
- **CS-007** — Passing `--preset <unknown>` exits non-zero before any file change; running on the same project afterward shows zero modifications.

## Out of Scope

- **Persisting the active preset on disk** (no `_claudeBase` field added to `settings.json`, no `.claude/.preset` file). Detection is recomputed each run, by design.
- **Preset migration mechanics** (e.g. converting a project from `nextjs` to `astro`) — that is a separate, larger effort.
- **Changing the install-time behavior** of `claude-base init` or any of its flags.
- **Filtering commands, agents, rules, or output styles by preset** — the existing preset semantics filter only skills; this spec preserves that.
- **Auto-detecting a "best preset" when several match** — refuse and ask the user (EF-004), do not heuristically pick.
- **Removing skills already present on disk that the active preset would drop** — the filter blocks re-adding, never removes (EF-011). Active cleanup is left to the user.
- **Lowering the contribution barrier for community presets** (still deferred per the prior session's call).

## Clarification Points

1. **When two or more presets match without explicit override, refuse or pick the first?** — **RESOLVED 2026-05-09**: option (a). Refuse and instruct the user to re-run with `--preset <name>` or `--no-preset`. The cost of one extra command is far smaller than the cost of a wrong preset silently rewriting the project. EF-004 already encodes this behavior.

2. **Should `--preset` on update accept community-curated presets in `.claude/presets/community/`?** — **RESOLVED 2026-05-09**: option (a). Same resolution rules as `init` (official path searched first, then community). Consistency with `init` outweighs the extra caution; community presets already pass schema validation in CI, so the integrity guarantee is the same.

3. **Should the active preset filter also retroactively delete skills already present on disk that the preset would drop?** — **RESOLVED 2026-05-09**: option (a). The filter applies only to the COPY step (EF-011); skills already on disk are never deleted, even when the active preset would drop them. Users who customized those skills do not lose their work. Active cleanup is opt-in via `--remove-orphans` (preset-aware via EF-014).
