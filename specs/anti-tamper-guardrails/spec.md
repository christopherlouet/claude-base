# Spec — Anti-tamper guardrails (config-protection + block-no-verify)

## Summary

Two small guardrails that stop an AI coding agent from *defeating claude-base's own
quality gates* instead of satisfying them: blocking edits to existing
linter/formatter configuration files (so the agent fixes the code, not the rule),
and blocking the `--no-verify` escape hatch on commit/push (so the pre-commit and
pre-push checks cannot be skipped). The value: claude-base's verification moat
becomes tamper-resistant, not merely advisory — closing the two most common ways an
agent makes a red gate "go green" without improving the work.

Inspired by verified mechanisms in `affaan-m/ecc` (`config-protection.js`,
`block-no-verify.js`), re-implemented to claude-base hook conventions. Theme tie-in:
this is the "anti-gaming of quality gates" frontier — the same family as a future
test-substance gate.

---

## User Stories

### P1 — MVP

#### US-1 — Block tampering with linter/formatter configs
**As a** maintainer relying on claude-base's quality gates,
**I want** the agent to be stopped when it tries to modify an existing
linter/formatter configuration file,
**So that** a failing lint/format check is fixed in the source code, not silenced by
loosening the rules.

Acceptance criteria:
- **Given** an existing linter/formatter config file (e.g. `.eslintrc.json`,
  `eslint.config.mjs`, `.prettierrc`, `biome.json`, `ruff.toml`,
  `.markdownlint.json`)
  **When** the agent attempts to edit or overwrite it
  **Then** the action is blocked and the agent receives a message telling it to fix
  the underlying code rather than relax the configuration.
- **Given** no such config file exists yet
  **When** the agent creates one for the first time
  **Then** the action is allowed (bootstrapping a project is legitimate).
- **Given** a file that is NOT a recognized linter/formatter config (any normal
  source/test/doc file)
  **When** the agent edits it
  **Then** the guardrail does not interfere.
- **Given** the guardrail is explicitly disabled by the operator
  **When** the agent edits a config file
  **Then** the action is allowed (documented escape hatch).

#### US-2 — Block the `--no-verify` bypass on commit and push
**As a** maintainer relying on pre-commit/pre-push checks,
**I want** the agent to be stopped when it tries to commit or push while skipping
those checks,
**So that** the secret-scan, tests-before-commit, and CI-before-push gates cannot be
bypassed in a single flag.

Acceptance criteria:
- **Given** a commit or push command carrying `--no-verify`
  **When** the agent runs it
  **Then** the action is blocked with a message explaining the gates exist for a
  reason.
- **Given** a commit or push command carrying the short bypass form (`-n` where it
  means no-verify)
  **When** the agent runs it
  **Then** the action is blocked.
- **Given** a normal commit or push (no bypass flag)
  **When** the agent runs it
  **Then** the guardrail does not interfere.
- **Given** the existing command-guard is disabled by the operator
  **When** the agent runs a `--no-verify` command
  **Then** the action is allowed (single, already-documented escape hatch — no new
  toggle introduced).

### P2 — Important

#### US-3 — Discoverable, documented, low-friction
**As a** developer onboarding to claude-base,
**I want** both guardrails documented and individually disable-able,
**So that** I understand why an action was blocked and can opt out deliberately
without disabling unrelated protections.

Acceptance criteria:
- **Given** a block occurs
  **When** the agent (or developer reading the log) sees the message
  **Then** the message states what was blocked, why, and how to proceed (fix source /
  remove the bypass flag) — not a bare "denied".
- **Given** the foundation's hook documentation
  **When** a developer reads it
  **Then** both guardrails, their trigger conditions, and their disable switches are
  listed.

### P3 — Nice-to-have

#### US-4 — False-positive resistance on look-alike paths
**As a** developer with config-shaped filenames that are not actually active configs,
**I want** the guardrail to avoid blocking edits that only superficially resemble a
config,
**So that** legitimate work is not interrupted.

Acceptance criteria:
- **Given** a file whose name merely contains a config keyword as a substring (e.g. a
  doc named `eslint-config-guide.md`, a fixture, or a config sample under a
  tests/examples directory)
  **When** the agent edits it
  **Then** the guardrail does not block it (it matches recognized config *filenames*,
  not arbitrary substrings).

---

## Functional Requirements

- **EF-001** — config-protection MUST block modification of an *existing* recognized
  linter/formatter config file via any file-writing action (single edit, multi-edit,
  or full overwrite).
- **EF-002** — config-protection MUST allow first-time creation of a config file
  (target does not yet exist).
- **EF-003** — The recognized set MUST cover, at minimum: ESLint (legacy `.eslintrc*`
  and flat `eslint.config.*`), Prettier (`.prettierrc*`), Biome (`biome.json`,
  `biome.jsonc`), Ruff (`ruff.toml`, `.ruff.toml`), and markdownlint
  (`.markdownlint.json`, `.markdownlint.{yml,yaml}`).
- **EF-004** — config-protection MUST deliberately EXCLUDE `pyproject.toml` (it mixes
  project metadata with optional tool config; blocking it would obstruct legitimate
  work).
- **EF-005** — config-protection MUST be disable-able via a dedicated switch
  (`SKIP_CONFIG_PROTECTION=1`) independent of other hooks.
- **EF-006** — block-no-verify MUST block `git commit` and `git push` invocations
  that carry `--no-verify`, including when chained (`&&`, `;`) or wrapped in common
  shells.
- **EF-007** — block-no-verify MUST block the short bypass form (`-n` on `git commit`)
  where it denotes no-verify, without blocking unrelated commands that merely contain
  `-n`.
- **EF-008** — block-no-verify MUST be implemented as a new category of the existing
  command guard, reusing its single disable switch (no new toggle).
- **EF-009** — Both guardrails MUST block by the foundation's standard mechanism
  (exit-to-block) and MUST emit a human-readable reason that names the file/command
  and the corrective action.
- **EF-010** — Both guardrails MUST fail safe: if their input cannot be parsed, they
  MUST NOT crash the agent's action silently in a way that bypasses the check; an
  unparseable case errs toward not-blocking only where blocking would break normal
  workflow, and this behavior MUST be covered by a test.
- **EF-011** — Both guardrails MUST be covered by automated tests (the foundation's
  shell test suite), including positive blocks, allowed cases, the disable switch, and
  the look-alike false-positive case.
- **EF-012** — Documentation gates MUST be updated: the hooks reference, the hook
  wiring registration, and any count/catalog markers the foundation enforces.

---

## Edge Cases

1. **First-time config creation** — target file absent → allowed (EF-002). Must
   distinguish "create" from "modify".
2. **Config under tests/examples/fixtures** — an intentionally-shipped sample config
   (e.g. a fixture used by claude-base's own tests) must not be blocked; scope the
   match so the foundation's own test fixtures keep working.
3. **Multi-edit targeting a config** — a batched edit whose target is a protected
   config must be blocked the same as a single edit (EF-001).
4. **`--no-verify` chained / quoted** — `git add -A && git commit --no-verify -m x`,
   or with extra spacing, must still be caught (EF-006).
5. **Benign `-n`** — `git commit -n` (no-verify) blocked, but a command like
   `grep -n`, `echo -n`, or `git log -n 5` MUST NOT be blocked (EF-007).
6. **Unrelated `--no-verify` mentions** — a commit message or filename literally
   containing the text "--no-verify" must not cause a false block (match the flag in
   command position, not anywhere in the payload).
7. **Missing parser (jq absent)** — follow the existing command-validator precedent
   (fail safe toward extra blocks, never a silent bypass) and cover with a test.
8. **Disable switches** — each switch independently verified (EF-005, EF-008).
9. **Case/extension variants** — `.eslintrc.JSON`, `eslint.config.ts` vs `.mjs` —
   recognized set must cover the documented variants.

---

## Entities

Not a data feature. The only structured artifacts are:
- **Recognized-config set** — the curated list of protected filenames/patterns
  (EF-003), with `pyproject.toml` explicitly excluded (EF-004).
- **Bypass-flag patterns** — the command patterns denoting a verification bypass
  (EF-006/007).

---

## Success Criteria

- **CS-001** — 100% of the acceptance criteria in US-1 and US-2 pass as automated
  tests (new bats cases), with zero regressions in the existing hook test suites.
- **CS-002** — Editing an existing recognized config is blocked; creating a new one is
  allowed; editing a non-config is untouched — all three demonstrated by tests.
- **CS-003** — `git commit/push --no-verify` blocked; `git commit -n` blocked;
  `grep -n` / `git log -n 5` / a message containing "--no-verify" NOT blocked — all
  demonstrated by tests.
- **CS-004** — Each disable switch turns its guardrail off, verified by a test.
- **CS-005** — The foundation's full shell test suite and its counts/doc gates pass
  (no broken markers, hooks reference updated).
- **CS-006** — Net new surface stays small (two focused guardrails; block-no-verify
  adds no new hook file and no new toggle) — consistent with the reduction stance.

---

## Out of Scope

- The `gateguard-fact-force` "investigate-before-first-edit" gate (separate, larger,
  third-party-vendored — handle via curation later).
- A test-substance / anti-hollow-test gate (related theme, separate spec).
- Protecting non-lint/format configs (CI workflow files, `tsconfig.json`,
  `package.json`, `.gitignore`, etc.) — out of scope for v1; revisit only with
  evidence.
- Any change to the *content* of the existing quality gates (secret-scan,
  tests-before-commit, CI-before-push) — these guardrails protect those gates, they do
  not modify them.
- Tiered enable-profiles (`minimal/standard/strict`) from ECC's dispatcher model —
  not adopted.
- Multi-harness portability — claude-base stays Claude-Code-native.

---

## Clarification Points — RESOLVED

1. **pyproject.toml stance** — ✅ RESOLVED 2026-06-26: **exclude entirely** (EF-004).
   No partial-file parsing; an agent loosening `[tool.ruff]` inside pyproject is an
   accepted gap for v1 (simplicity > completeness here).
2. **`tsconfig.json`** — ✅ RESOLVED 2026-06-26: **OUT of scope for v1.** Recognized
   only as a future candidate (loosening `strict` to pass typecheck is on-theme, but
   tsconfig is edited legitimately too often to block safely in v1). Revisit with
   evidence.
3. **config-protection disable granularity** — ✅ RESOLVED (default): single global
   `SKIP_CONFIG_PROTECTION=1` switch for v1. A per-file allowlist is deferred unless a
   real automated-flow need appears.
