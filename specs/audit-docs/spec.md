# Spec: `audit-docs.sh` — Doc drift firewall

> **Status: ✅ Shipped** — doc-drift firewall live since PR #201 (2026-05-19), CI-gated via `tests/audit-docs.bats`.

**Status**: Draft (planning, not yet validated)
**Date**: 2026-05-19
**Owner**: Chris

---

## Summary

Add a CI-gated audit script that catches **syntactic doc drift** — paths, command verbs, CLI flags, script references, and npm-script references that no longer match the live foundation state. Closes the gap left by the existing audit stack (`validate-counts.sh` covers counters, Docusaurus build covers internal links, bats taxonomy drift-guard covers one specific case). Targets the class of bugs that shipped silently for weeks before a user spot-checked one page (the `~/.claude-base/` install path drift in PR #199, the 5 hard-coded prose counters in PR #200). Future drifts of the same shape get caught in CI before merge.

## Locked context (from exploration)

| Decision | Resolution |
|---|---|
| Integration point | New audit step in `scripts/audit-base.sh` |
| Allowlist storage | Inside the script itself (bash arrays at the top), one-line edit to extend |
| Languages / deps | Plain bash + grep + jq (already required by foundation) |
| Detection-only | No auto-fix in this MVP |
| Audit scope | Hand-maintained docs only ; auto-generated mirrors (commands/, agents/, skills/, rules/ under `website/docs/`) are excluded since they reflect their sources and don't drift independently |

## Locked decisions (resolved during /work:work-clarify)

| Decision | Resolution | Resolved on |
|---|---|---|
| File scope | **Explicit allowlist of 8 globs** as in EF-010. Adding a new doc directory = 1-line edit. Auto-generated mirrors stay excluded. | 2026-05-19 |
| Verb pattern strictness | **Whitelist + context-aware** — pattern `claude-base <verb>` where `<verb>` matches the KNOWN_VERBS whitelist. Words outside the whitelist (`is`, `in`, `for`, `a`, …) are silently ignored as English prose. A new verb added to `bin/claude-base` requires a 1-line update to the whitelist. | 2026-05-19 |
| Env var bypass | **MVP includes 5 per-category env vars** — `AUDIT_DOCS_SKIP_PATHS=1`, `_VERBS=1`, `_FLAGS=1`, `_SCRIPTS=1`, `_NPM=1`. Last-minute escape hatch for false positives blocking a release. ~10 lines bash, established pattern in the foundation. | 2026-05-19 |

## User Stories

### P1 — MVP

**US-1 — Drift caught before merge**
- **As a** foundation maintainer (or PR contributor)
- **I want** the CI to fail when a doc page introduces a path / command / flag / script reference that doesn't match the live state
- **So that** silent drift cannot accumulate undetected on `main` between feature work

Acceptance criteria:
- Given a PR introduces a doc edit that mentions a verb, flag, path, script, or npm script that does not exist (or is not on the allowlist)
- When the CI runs the foundation audit pipeline
- Then the audit fails with a non-zero exit code AND the offending file:line is printed

**US-2 — Clear error messages**
- **As a** PR contributor who hit the audit gate
- **I want** the error output to name the offending file, line number, category, and the specific drift
- **So that** I can fix the issue without reading the script's source code

Acceptance criteria:
- Given the audit detects a drift
- When the script exits
- Then the output contains, for each offender, at minimum: file path, line number, the category of drift (path / verb / flag / script / npm), and the offending substring

**US-3 — Integration with existing audit pipeline**
- **As a** maintainer wiring the script into the foundation
- **I want** the audit to run as a step inside `scripts/audit-base.sh`
- **So that** every existing CI / pre-commit / manual invocation of the foundation audit automatically picks it up — no new pipeline step to maintain

Acceptance criteria:
- Given `./scripts/audit-base.sh` is invoked
- When the audit pipeline runs
- Then a new step prints a recognizable banner (e.g. "Auditing docs for drift") and either succeeds silently or fails with the drift report
- And the overall exit code of `audit-base.sh` is non-zero if drift was detected

### P2 — Important

**US-4 — Allowlist easy to extend**
- **As a** maintainer adding a new legitimate path / verb / flag / script / npm-script over time
- **I want** to extend the allowlist with a single-line edit to a clearly-labelled bash array at the top of the script
- **So that** legitimate additions never trigger a false positive after one line of maintenance

Acceptance criteria:
- Given a new legitimate verb is added to `bin/claude-base`
- When I add the verb to the corresponding allowlist array in `audit-docs.sh`
- Then docs that reference the new verb are accepted by the audit

**US-5 — Per-category escape hatch**
- **As a** maintainer debugging a false positive that I cannot fix immediately
- **I want** to disable a specific category of check via an environment variable
- **So that** I can unblock a release while still running the other categories

Acceptance criteria:
- Given an environment variable named per the EF below is set
- When the script runs
- Then the matching category is skipped (printed as "skipped: $REASON" rather than executed) and exit code reflects only the remaining categories

**US-6 — Regression coverage of the 2 historical drifts**
- **As a** maintainer confident the script earns its keep
- **I want** explicit regression tests that recreate the historical drifts caught by PRs #199 and #200
- **So that** I have evidence the script would have caught them and will catch their recurrence

Acceptance criteria:
- Given a temporary fixture containing the `~/.claude-base/` typo (PR #199 scenario) OR a hard-coded counter outside a marker (PR #200 scenario)
- When the audit runs against the fixture
- Then the audit exits non-zero AND the relevant category is named in the output

### P3 — Nice-to-have

**US-7 — Verbose mode for debugging**
- **As a** maintainer extending the script
- **I want** a `--verbose` flag that prints the extraction patterns and intermediate matches
- **So that** I can debug false negatives without instrumenting the script

Acceptance criteria:
- Given `--verbose` is passed
- When the script runs
- Then it prints per-category: the grep pattern used, the count of raw matches, the count after deduplication, and the count after allowlist filtering

**US-8 — Single-category execution**
- **As a** maintainer iterating on one specific category
- **I want** to run only one category via a flag (e.g. `--category paths`)
- **So that** I get faster feedback during development

Acceptance criteria:
- Given `--category <name>` is passed where `<name>` is one of the 5 categories
- When the script runs
- Then only that category is executed (others are skipped silently) and the exit code reflects only that category

## Functional Requirements

| ID | Requirement |
|---|---|
| **EF-001** | The audit MUST extract path references matching `~/[\w./-]+` from hand-maintained doc files (per the file-scope EF) and classify each match against an in-script allowlist of known prefixes. Unknown prefixes MUST trigger a drift report entry. |
| **EF-002** | The audit MUST extract `claude-base <verb>` invocations from doc text and cross-check each `<verb>` against the verb list embedded in `bin/claude-base`. Unknown verbs MUST trigger a drift report entry. The check MUST distinguish actual command invocations from English prose where "claude-base" is followed by a non-verb word (e.g., "claude-base is", "claude-base in"). |
| **EF-003** | The audit MUST extract `claude-base init --<flag>` and `claude-base update --<flag>` patterns from doc text and cross-check each flag against the argument-parsing of `scripts/new-project.sh` and `scripts/update.sh` respectively. Unknown flags MUST trigger a drift report entry. |
| **EF-004** | The audit MUST extract `./scripts/<X>.sh` references from doc text (EXCLUDING `.claude/rules/*.md` files, which describe USER project scripts not claude-base scripts) and cross-check each `<X>.sh` against `ls scripts/*.sh`. Missing files MUST trigger a drift report entry. |
| **EF-005** | The audit MUST extract `npm --prefix website run <X>` and `(cd website && npm run <X>)` patterns from doc text and cross-check each `<X>` against `website/package.json#scripts`. Unknown scripts MUST trigger a drift report entry. Generic `npm run dev` / `npm run build` / `npm run test` patterns OUTSIDE a website-prefixed context are out of scope (user-project examples). |
| **EF-006** | The audit MUST be callable as a step from `scripts/audit-base.sh`. Its non-zero exit code MUST propagate to `audit-base.sh`'s exit code. |
| **EF-007** | The audit's output MUST be human-readable AND machine-grepable. Each drift line MUST contain (in order): file path, line number, category name, offending substring. Format MAY be `file:line: [category] message`. |
| **EF-008** | The script MUST exit `0` when no drift is detected, `1` when any drift is detected. Other exit codes (e.g., `2` for unusable environment like missing `jq`) MAY be used for tooling failures. |
| **EF-009** | At least one bats test MUST exist per category (paths, verbs, flags, scripts, npm). At least one regression bats test MUST recreate each of the 2 historical drifts (PR #199 `~/.claude-base/` path, PR #200 hard-coded prose counter scenario) and assert the script detects them. |
| **EF-010** | The audit's file scope MUST be hand-maintained documentation: `docs/**/*.md`, `website/docs/intro/**/*.md`, `website/docs/concepts/**/*.md`, `website/docs/examples/**/*.md`, `website/docs/tutorials/**/*.md`, `website/docs/workflow/**/*.md`, `website/docs/guides/**/*.md`, `website/docs/reference/**/*.md`. The auto-generated mirrors (`website/docs/agents/`, `website/docs/commands/`, `website/docs/skills/`, `website/docs/rules/`) MUST be excluded — they reflect their in-tree sources and don't drift independently. |
| **EF-011** | The script MUST support per-category disable via environment variables `AUDIT_DOCS_SKIP_PATHS=1`, `AUDIT_DOCS_SKIP_VERBS=1`, `AUDIT_DOCS_SKIP_FLAGS=1`, `AUDIT_DOCS_SKIP_SCRIPTS=1`, `AUDIT_DOCS_SKIP_NPM=1`. A skipped category MUST be reported as "skipped" in the output but MUST NOT affect the exit code. |
| **EF-012** | On the current `main` state (pre-script integration), the audit MUST detect zero drift (the foundation has just shipped doc hygiene for both historical drifts in PRs #199 and #200). |
| **EF-013** | The audit MUST distinguish remote URLs (`https://github.com/.../scripts/X.sh`) from local script references (`./scripts/X.sh`). Remote URLs MUST NOT be flagged as missing local scripts. |
| **EF-014** | The audit's runtime on the full repo MUST be under 5 seconds on a typical developer machine (Linux, SSD). This is a soft guarantee, not a hard CI gate, but the script SHOULD NOT introduce noticeable CI slowdown. |
| **EF-015** | The script MUST NOT name any specific end-user project (per the durable foundation rule). All allowlist entries MUST be foundation-internal or generic placeholders. |

## Edge Cases

| Case | Expected handling |
|---|---|
| A doc contains `claude-base is a foundation` (prose with "claude-base" followed by a verb-like word) | The verb extractor MUST recognise this as prose, not a command invocation. The pattern should require either a code-block context OR a recognised verb after `claude-base`. |
| A doc references `https://github.com/foo/scripts/deploy.sh` (remote URL with `scripts/X.sh` substring) | The script-existence check MUST NOT flag this because the path is not local. Pattern MUST require `./scripts/...` (or unambiguous local form). |
| A doc embeds an example showing `./scripts/deploy.sh deploy` inside a code block of a rule file (`.claude/rules/deploy-safety.md`) | Excluded by EF-010 (rules describe user-project scripts). |
| A path inside a code-block representing terminal output (e.g., `Version: ...`) contains `<!-- ... -->` markers | The path extractor MUST NOT match HTML comment content. |
| A path crosses a line break (e.g., `~/.claude/\nfoo`) | The extractor MAY miss this case (out of scope for v1). Documented as a known limit. |
| `jq` is not installed | Script exits with code `2` and a clear "missing dependency" message. Audits gracefully don't fail the CI (handled by audit-base.sh's error tolerance). |
| Counter assertions in prose (`"11 presets"`) when a marker is in place above on the same page | Not detectable by this audit (covered by `validate-counts.sh` markers and the recent PR #200 manual fix). Acknowledged limit. |
| A future tier-renames-existing-verb (e.g. `claude-base init` renamed to `claude-base bootstrap`) | When the verb list in `bin/claude-base` is updated, the allowlist in `audit-docs.sh` must be updated too — single-line edit. If a maintainer forgets, the audit catches it AT MERGE time on whichever PR ships first. |

## Entities

### Allowlist

The script ships 5 bash arrays as the source of truth for what each category considers "known":

| Array | Purpose | Initial values |
|---|---|---|
| `KNOWN_PATH_PREFIXES` | Path prefixes accepted as legitimate references | `~/.claude/` (Claude Code config), `~/.local/share/claude-base/` (canonical install), `~/.local/bin/` (dispatcher symlink), `~/.bashrc` (OS standard reference), `~/dev/vendor-skills/` (user-suggested vendor clone location) |
| `KNOWN_VERBS` | Verbs accepted after `claude-base` | `init`, `update`, `validate`, `preset`, `uninstall`, `version`, `help` (mirrors `bin/claude-base` case) |
| `KNOWN_INIT_FLAGS` | Flags accepted after `claude-base init` | `--simple`, `--all`, `--minimal`, `--preset`, `--type`, `--list-presets`, `--detect-only`, `--ci`, `--hooks`, `--mcp`, `--docker`, `--no-mcp`, `--no-preset`, `--yes`, `-y`, `--skip-prompts`, `--install-only`, `--presets-dir` (mirrors `scripts/new-project.sh`) |
| `KNOWN_UPDATE_FLAGS` | Flags accepted after `claude-base update` | mirrors `scripts/update.sh` (filled in plan phase from grep output) |
| `KNOWN_NPM_SCRIPTS` | npm scripts accepted in website context | derived from `jq '.scripts | keys[]' website/package.json` at audit time (live, not hard-coded) |

### Drift report

| Field | Purpose |
|---|---|
| File path | The doc file containing the drift |
| Line number | The 1-indexed line within the file |
| Category | One of: `paths`, `verbs`, `flags`, `scripts`, `npm` |
| Offending substring | The exact string that triggered the report |

## Success Criteria

| ID | Metric | Target |
|---|---|---|
| **CS-001** | Script exit code on the current clean `main` state | `0` |
| **CS-002** | Script exit code on a fixture reintroducing the PR #199 drift (`~/.claude-base/` in a doc) | `1` (drift detected, category `paths`) |
| **CS-003** | Script exit code on a fixture reintroducing the PR #200 drift (hard-coded `(23 commands)` in a CHEATSHEET-shaped fixture) | This drift is NOT detected by this audit (it's a counter drift, owned by `validate-counts.sh`). Acknowledged out-of-scope ; documented in spec. |
| **CS-004** | Script exit code on a fixture with an unknown CLI flag (e.g., `claude-base init --foo`) | `1` (drift detected, category `flags`) |
| **CS-005** | Script exit code on a fixture with a missing local script (e.g., `./scripts/nuclear.sh`) | `1` (drift detected, category `scripts`) |
| **CS-006** | Script exit code on a fixture with an unknown npm script (e.g., `npm --prefix website run nonsense`) | `1` (drift detected, category `npm`) |
| **CS-007** | `./scripts/audit-base.sh` exits non-zero when `audit-docs.sh` reports drift | Yes |
| **CS-008** | New bats tests added | `≥ 6` (one per category + one regression for PR #199 + one for the verb/flag categories) |
| **CS-009** | Script runtime on the full repo | `< 5 seconds` (soft target) |
| **CS-010** | Per-category disable env vars work | `AUDIT_DOCS_SKIP_<CATEGORY>=1` causes the matching category to print "skipped" and not affect exit code |
| **CS-011** | False-positive rate on a curated sample of 10 hand-picked doc paragraphs | `0` (zero false positives in the sample) |
| **CS-012** | `./scripts/validate-counts.sh` and `./scripts/audit-base.sh` exit 0 after the script ships | Yes (no regression on other audits) |

## Out of Scope

- **Semantic drift detection** — claims about features that no longer work (e.g., "this preset auto-installs marketplace plugins" when the behavior changed). Would need either a human read-through or an LLM pass. Out of scope for this MVP.
- **Auto-fixing detected drift** — the script reports only. Maintainer fixes the drift in a follow-up commit.
- **Page-by-page LLM audit** — covered by manual review when a user signals a specific issue.
- **Counter drift in prose** — the `validate-counts.sh` script already owns this for marker-wrapped counters. PR #200 wrapped 5 historical cases ; new prose counters added without markers would slip through this audit. Acknowledged limit ; addressing requires a separate counter-prose linter, out of scope here.
- **Docusaurus internal link validation** — already handled by the Docusaurus build step on the Deploy Documentation workflow.
- **Auto-generated mirror content** (`website/docs/agents/`, `commands/`, `skills/`, `rules/`) — these reflect in-tree sources and don't drift independently.
- **`.claude/rules/*.md` files** — describe user-project scripts and patterns, not claude-base internals. Excluded by EF-010.
- **External URL validity** — `https://...` link liveness is out of scope (separate tool, e.g., `lychee`, could be added later).
- **`docs/` source vs `website/docs/` mirror drift** — already caught by the existing `validate-counts.sh` post-regen diff check.
- **Markdown lint / formatting** — separate concern, not a drift category.
- **JSON/YAML schema validation** of code blocks — separate concern, not a drift category.
- **Renaming an existing verb / flag** — the maintainer must update both `bin/claude-base`/`scripts/new-project.sh` AND the corresponding allowlist array in `audit-docs.sh`. This is a one-line edit explicitly named in the workflow ; no auto-sync.
- **Adding new flag categories** beyond `init` and `update` (e.g., `claude-base preset --foo`) — covered by EF-002 (the verb itself is checked) but flag-level coverage for sub-verbs is out of scope for v1.

## Clarification Points

_All 3 clarifications resolved during `/work:work-clarify` on 2026-05-19. See "Locked decisions (resolved during /work:work-clarify)" at the top of this spec for the binding answers. Original questions kept below for traceability._

1. **File scope** — resolved: explicit allowlist of 8 globs (EF-010).
2. **Verb-pattern strictness** — resolved: whitelist + context-aware. Pattern matches the KNOWN_VERBS array ; prose words are silently ignored.
3. **Per-category env-var escape hatch** — resolved: 5 env vars (`AUDIT_DOCS_SKIP_{PATHS,VERBS,FLAGS,SCRIPTS,NPM}=1`) included in MVP per EF-011.

---

## Cross-references

- Historical drifts that motivated the spec: PR #199 (`~/.claude-base/` install path drift, 10 occurrences, lived on `main` since the doc was written) ; PR #200 (5 hard-coded prose counters wrapped in markers, latent drift only).
- Audit ecosystem this slots into: `scripts/audit-base.sh` (umbrella, 168 checks), `scripts/validate-counts.sh` (counter markers), `scripts/validate-presets.sh` (preset JSON schema), Docusaurus build (internal links), bats T013 (taxonomy↔roadmap drift-guard).
- Memory anchors active for the plan phase: `feedback_verify_code_claims` (every allowlist entry MUST be grep'd against the live code), `feedback_bsd_seq_zero_range` (any bash array iteration MUST guard zero-range), `feedback_no_project_names` (EF-015), `feedback_counts_ci_gate` (the audit MUST NOT interfere with the counts regen pipeline).
