# Spec: preset detection (data-driven) + per-preset end-to-end coverage

**Status**: Draft
**Date**: 2026-05-09
**Owner**: Chris
**Extends**: `specs/presets/spec.md` (the preset system itself)

---

## Summary

Make presets self-describe how to recognize the stack they target, so that running `new-project.sh` on an existing project surfaces the matching preset(s) without the user having to know their names. In parallel, add a per-preset end-to-end safety net so a regression of the v1.36.1 type (install completes, but the bootstrapped project is silently broken) is caught before release. Adding a new preset (e.g. `django`, `laravel`, `sveltekit`) must require zero changes to detection or test-orchestration code — only a new manifest and a small fixture.

## User Stories

### P1 — MVP

#### US-1 — Preset suggestion on existing project (maintainer running on his own work)

> **As** the maintainer running `new-project.sh` on an existing project,
> **I want** the foundation to recognize the stack and suggest the matching preset,
> **so that** I don't have to remember which preset name applies to which stack.

**Acceptance criteria**

- **Given** a project directory containing `next.config.js` and `next` listed in `package.json`,
  **when** I run `new-project.sh` on that directory,
  **then** the output contains a clear suggestion line referencing the preset `nextjs` and the corresponding install command.

- **Given** a project containing `manage.py` and `django` in `requirements.txt`,
  **when** I run `new-project.sh`,
  **then** the output suggests the preset `django` (once such a preset is added).

- **Given** a project where no preset's detection rule matches,
  **when** I run `new-project.sh`,
  **then** the behavior is unchanged from today (no suggestion line printed, type detection works as before).

#### US-2 — Adding a new preset requires no code change

> **As** the maintainer (or a future contributor) adding a new preset,
> **I want** to declare the detection rule inside the preset manifest itself,
> **so that** I never have to modify detection scripts or orchestration code.

**Acceptance criteria**

- **Given** a new preset manifest under `.claude/presets/<name>.json` with a valid detection block,
  **when** I run `new-project.sh` on a project matching that block,
  **then** the new preset appears in the suggestion output without any other file in the repository being modified.

- **Given** a new preset manifest with a fixture project under `tests/`,
  **when** I run the test suite,
  **then** the new preset's detection and bootstrap behavior are validated automatically.

#### US-3 — End-to-end safety net per preset

> **As** the maintainer preparing a release,
> **I want** every shipped preset to have an end-to-end test that bootstraps a real project and asserts it is functional,
> **so that** a regression of the v1.36.1 kind (hooks referenced but not shipped) is caught before release rather than after.

**Acceptance criteria**

- **Given** any maintainer-vouched preset,
  **when** the test suite runs,
  **then** there is at least one end-to-end test that bootstraps a target directory with that preset, then verifies the install passes the existing `validate.sh` and `doctor.sh` checks.

- **Given** the bootstrapped target directory after a preset install,
  **when** the test suite inspects the target's `.claude/settings.json`,
  **then** every hook script path referenced by `settings.json` resolves to a file that actually exists in the bootstrapped directory.

- **Given** the regression scenario of v1.36.1 (hook referenced in settings but missing on disk),
  **when** the corresponding end-to-end test runs against the bootstrapped target,
  **then** the test fails loudly with a message naming the missing file.

### P2 — Important

#### US-4 — Suggestion is also visible in the interactive flow

> **As** a user running `new-project.sh` interactively (no `--preset` flag),
> **I want** the suggested preset to be clearly distinguished in the type-selection menu,
> **so that** I don't miss the curated path even if I never read `--list-presets`.

**Acceptance criteria**

- **Given** an interactive run where a preset matches,
  **when** the type menu is displayed,
  **then** the preset suggestion appears as an additional menu entry placed at the top (e.g. "Use preset: nextjs (detected)") visually distinguished from the standard 11 type options, with a one-line description.

- **Given** two or more presets match,
  **when** the menu is displayed,
  **then** each matching preset appears as its own additional entry (no aggregated "preset" entry); the standard 11 type options follow.

- **Given** the user picks the preset entry,
  **when** the install proceeds,
  **then** it behaves as if `--preset <name>` had been passed and the standard type menu is not re-shown.

- **Given** the user picks one of the standard 11 type options instead,
  **when** the install proceeds,
  **then** the suggestion is ignored without further prompt; the install behaves exactly as today.

#### US-5 — Drift-guard between detection rule and target stack

> **As** the maintainer of a preset,
> **I want** an automated check that flags when a preset's detection rule no longer matches a representative fixture of its target stack,
> **so that** I learn about upstream renames (e.g. an upstream config file moved) before users complain.

**Acceptance criteria**

- **Given** a preset with a detection rule and a paired fixture under `tests/presets-fixtures/`,
  **when** the test suite runs,
  **then** a unit test asserts the rule matches the fixture; failure is loud and names the failing rule.

### P3 — Nice-to-have

#### US-6 — Standalone "what would you suggest" mode

> **As** a curious user,
> **I want** a way to print the suggested preset(s) without running an install,
> **so that** I can audit detection without committing to anything.

**Acceptance criteria**

- **Given** a project directory,
  **when** I run `new-project.sh --detect-only <path>`,
  **then** the output prints matching preset names and signal sources, then exits with status `0`. No files are written.

#### US-7 — Documentation and example for contributors

> **As** a future contributor proposing a preset,
> **I want** the detection-rule schema documented with examples,
> **so that** I can copy-paste rather than reverse-engineer the format.

**Acceptance criteria**

- **Given** a contributor reading `.claude/presets/README.md`,
  **when** they look at the format quick reference,
  **then** the detection rule structure is documented with at least two worked examples (one file-presence, one dependency-list).

## Functional Requirements

### Detection rule

- **EF-001** — Each preset manifest may declare an optional detection block. A manifest without one continues to work (silent: never auto-suggested).
- **EF-002** — The detection block supports recognising files by exact name and by glob pattern (e.g. `manage.py`, `astro.config.*`).
- **EF-003** — The detection block supports recognising the presence of a string in a named dependency-list file (e.g. `requirements.txt` containing `django`, `package.json` containing `"next"`).
- **EF-004** — The detection block supports a combinator with two operators: "all of these signals must match" and "at least one of these signals must match".
- **EF-005** — When `new-project.sh` runs on an existing project, every preset with a detection block is evaluated against that project. Matching presets are collected.
- **EF-006** — When zero presets match, the foundation behaves exactly as today.
- **EF-007** — When exactly one preset matches, a suggestion line is printed before the type prompt, naming the preset and the install command to use it.
- **EF-008** — When two or more presets match, all matching names are printed; the user picks one explicitly via flag or interactive choice.
- **EF-009** — A preset suggestion is informational by default in the non-interactive flow; the install does not auto-apply the preset without explicit user opt-in.
- **EF-010** — `validate-presets.sh` validates the detection block schema if present and rejects malformed blocks.
- **EF-011** — Every maintainer-vouched preset that ships a detection block also ships a fixture and a paired unit test asserting the rule matches the fixture.
- **EF-016** — When the user passes `--preset <name>` explicitly, detection is skipped entirely. No suggestion, note, or warning about other matching presets is printed. The explicit choice is honored without commentary, even if a different preset would have matched the same project.

### End-to-end coverage

- **EF-012** — Every maintainer-vouched preset has an end-to-end test that bootstraps a target directory using that preset, then runs `validate.sh` and `doctor.sh` against the target.
- **EF-013** — Every end-to-end preset test asserts that every hook script path referenced in the bootstrapped `settings.json` resolves to an existing file in the bootstrapped directory.
- **EF-014** — End-to-end tests run without the `claude` command-line tool installed; when an optional step depends on it (marketplace plugin install), the step is skipped with a clear note rather than failing the test.
- **EF-015** — Adding a new preset must require modifications only inside `.claude/presets/` and `tests/presets-fixtures/` (and possibly a single line in a generic test loop). No edits to detection scripts or orchestration code.

## Edge Cases

- **Multiple frameworks coexisting in one project** (e.g. a Flask service being migrated to FastAPI; both names appear in `requirements.txt`). The detection MUST report both matches and let the user pick. No silent winner.
- **`--preset` passed explicitly while detection would also match a different preset**. Detection is skipped; no warning printed (per EF-016). The explicit user intent is honored without commentary.
- **Generic marker files**. Detection rules MUST NOT use signals so weak that they would match unrelated projects (e.g. only `.gitignore`, only `README.md`, only `package.json` without a content check).
- **Target directory already has `.claude/`**. Detection runs as today; suggestion line still prints; the user keeps current re-install semantics.
- **`jq` missing on the host**. Detection step degrades gracefully: skipped with one warning line. The rest of `new-project.sh` continues unchanged.
- **`claude` CLI missing or older than 2.1.119**. The marketplace-plugin step inside the end-to-end test is skipped with a logged note. The rest of the assertions still run.
- **Detection rule typo**. The unit test paired with the preset (EF-011) catches the mismatch before merge.
- **End-to-end test target left on disk on test failure**. Test setup uses a temporary directory cleaned in teardown regardless of test outcome.
- **Cross-platform tooling differences**. Detection and test code must work on both GNU and BSD core utilities (already a known gotcha in this repo).

## Entities

| Entity | Purpose | Key attributes |
|---|---|---|
| **Detection rule** | Self-describes how a preset recognizes its target stack | files (list of names/globs), depFiles (list of {path, contains}), combinator (allOf or anyOf) |
| **Detection result** | What the foundation reports back to the user | matched preset names, signal source (which file/string triggered each match) |
| **Preset fixture** | A minimal directory used by tests to exercise a preset | small set of marker files (e.g. `manage.py` + a tiny `requirements.txt`) sufficient to trigger the matching rule |
| **End-to-end run** | One execution of bootstrap + validate + doctor against a fixture | preset name, target temp dir, exit codes, list of hook paths checked |

## Success Criteria

- **CS-001** — Adding a new preset (e.g. `django.json`) requires changes only inside `.claude/presets/` and `tests/presets-fixtures/`. Detection scripts and end-to-end orchestration code are not touched. Verified by inspecting the diff of the next preset PR.
- **CS-002** — All five currently shipped presets have a passing end-to-end run on every CI build.
- **CS-003** — A re-introduction of the v1.36.1 missing-hook regression on any preset path is caught by an existing end-to-end assertion. Verified by deliberately reverting the hook-shipping fix and observing the test fail with a precise message.
- **CS-004** — When `new-project.sh` runs on a directory containing `next.config.js` and a `package.json` with `next` in dependencies, the printed output contains the suggestion `nextjs`.
- **CS-005** — `validate-presets.sh` exits with status 1 when a preset declares a malformed detection block; the error message names the offending field.
- **CS-006** — Total test-suite runtime increase from this work is under 30 seconds in parallel mode (`scripts/test.sh`).
- **CS-007** — `--detect-only` (if implemented as P3) prints matching preset names and exits 0 without writing files. Verified by dry-run inspection.

## Out of Scope

- Auto-applying a detected preset without user opt-in. Detection always informs; install proceeds only on explicit choice.
- Confidence scoring (e.g. "75% match"). Match is boolean; either a rule fires or it does not.
- Detection over a remote source (URL, git ref). Only the local working directory is inspected.
- Modifying the content of the existing five presets beyond adding their detection blocks.
- Adding new presets (Django, Laravel, SvelteKit, etc.). Each new preset is a follow-up effort that consumes this spec as infrastructure.
- Calibrating the community contribution barrier (deferred until a real contributor signal lands).
- Auto-installing the suggested preset's marketplace plugins as part of detection.
- A long-lived "background detector" or watcher that updates suggestions when the target changes. Detection is one-shot at install time.
- Telemetry on which presets are detected or chosen.

## Clarification Points

1. **How should the suggestion appear in the interactive type menu?** — **RESOLVED 2026-05-09**: option (b). Each matching preset appears as an additional menu entry placed at the top, distinguished from the standard 11 type options. Picking a preset entry behaves as if `--preset <name>` had been passed; picking a standard option proceeds as today. See US-4 acceptance criteria for the full behavior.

2. **Should end-to-end tests run on every pull request, or only on release branches?** — **RESOLVED 2026-05-09**: every pull request, inside the existing main test job (no separate CI job). Justification: the current parallel test suite finishes in ~1 minute; five preset end-to-end runs at ~5–10 seconds each fit within the agreed 30-second budget (CS-006). Catching regressions on the PR that introduces them is more valuable than saving a minute pre-release. If the budget is later breached, the fallback is to split into a dedicated parallel job rather than to delay until release.

3. **Should the detection rule support negative signals (e.g. "match Flask but not if FastAPI is also present")?** — **RESOLVED 2026-05-09**: no for the first version. The combinator (`allOf`, `anyOf`) is sufficient for every concrete case identified across the five shipped presets and the next frameworks on the radar (Django, Laravel, SvelteKit). When two presets match (e.g. a project containing both Flask and FastAPI), both are listed and the user picks. A `notContains` or `notExists` operator can be added in a follow-up only when a real conflict makes the user choice unsatisfactory.
