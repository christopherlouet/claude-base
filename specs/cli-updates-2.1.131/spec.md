# CLI updates integration: 2.1.126 → 2.1.131

**Date**: 2026-05-06
**Status**: Specification — pending plan
**Scope**: Documentation and configuration updates to bring claude-base in sync with the Claude Code releases shipped between 2.1.126 (2026-05-01) and 2.1.131 (current local at time of writing)

---

## Summary

Five Claude Code releases shipped between 2026-05-01 and the date of this spec, introducing new configuration options (granular skill overrides), new install patterns (plugin fetched from a URL or a local archive), clarified runtime behavior (MCP auto-retry), and minor environment variables (package-manager auto-update). The foundation must reflect these so users following its docs benefit from the new options without having to read the upstream changelog themselves.

User value: a developer who follows claude-base's recommendations stays current with the upstream tool, with the foundation acting as a curated digest of what is worth adopting and what is noise.

## User Stories

### P1 — Must-have (MVP)

#### US-1: Granular skill overrides documented

> As a **claude-base user with a curated preset**, I want to **know the three modes available for selectively disabling or hiding bundled skills**, so that **I can override only what conflicts with a vendor skill I prefer, without dropping the bundled skill entirely**.

**Acceptance criteria**

- **Given** the skills documentation, **when** I read the section on overrides, **then** I can identify the three modes (full off / user-invocable-only / name-only) and a one-line use case for each.
- **Given** a preset that uses the existing exclusion mechanism, **when** I read the migration note, **then** I can decide whether to migrate to the new mechanism or stay on the existing one.
- **Given** the documentation, **when** I copy the example snippet, **then** the snippet is self-contained and works without external context.

#### US-2: Try-before-curate plugin recipe

> As a **claude-base user evaluating a plugin before adopting it**, I want a **documented recipe to load a plugin from a URL or a local archive without committing to it in a preset**, so that **I can validate the plugin against my workflow before requesting it for permanent inclusion**.

**Acceptance criteria**

- **Given** the recipes catalog, **when** I follow the "evaluate a plugin" recipe, **then** I can load a plugin in a temporary session in under five steps.
- **Given** the recipe, **when** I read the cleanup section, **then** I know how to remove the plugin from my session without residue.
- **Given** the foundation's empty `marketplacePlugins` policy, **when** I read the recipe, **then** the recipe explicitly aligns with the validation-first policy (it does not contradict it).

#### US-3: MCP transient retry behavior documented

> As a **claude-base user writing a hook that interacts with an MCP server**, I want to **know that the runtime auto-retries transient MCP failures**, so that **I do not implement custom retry logic that would conflict with the runtime's behavior**.

**Acceptance criteria**

- **Given** the hooks reference, **when** I look up MCP-related sections, **then** I find a paragraph describing the auto-retry policy and its bounds.
- **Given** the paragraph, **when** I read it, **then** I learn whether I should still wrap MCP calls in custom retry logic (yes / no / conditional).

#### US-4: Doc CLI references stay durable — **CLOSED 2026-05-06 (audit-confirmed-moot)**

Original story:

> As a **maintainer of claude-base**, I want **CLI version references in the documentation to point to a moving target rather than a frozen number**, so that **the docs do not silently drift each time a new CLI version ships**.

**Closure rationale**: foundation-wide grep of `CLI 2\.1\.[0-9]+\+?` returned ~40 occurrences. **Every single one is a "feature introduced in version X" minimum-version marker** (e.g., `## Automatic Memory (CLI 2.1.76+)`, `## Output rewriter (CLI 2.1.121+)`). These markers are factual and non-drifty by construction: the feature was introduced at that version and the marker stays valid forever. There is **no "recommended version: 2.1.108" claim anywhere in the foundation** that could go stale. The drift surface is empty.

EF-006 ("at most one location hard-codes a CLI minor") is rejected: every feature-marker must cite its exact minimum, otherwise the reader cannot know whether their CC version supports the feature.

### P2 — Important (not blocking)

#### US-5: Package-manager auto-update opt-in mention

> As a **claude-base user who installed Claude Code via a package manager (Homebrew, WinGet)**, I want a **brief mention of the env var that enables background upgrades**, so that **I can opt into automatic updates without searching the upstream changelog**.

**Acceptance criteria**

- **Given** the install guide, **when** I look for "stay up to date", **then** I find a one-paragraph opt-in mention with the env var name and target audience (Homebrew / WinGet only).
- **Given** the mention, **when** I read it, **then** it is clearly opt-in and not a default recommendation (no behavior change for users who do not opt in).

### P3 — Nice-to-have / housekeeping

#### US-6: Close items rendered moot by the audit

> As a **maintainer of claude-base**, I want **the post-migration TODO memory to mark the two audit-confirmed-moot items as resolved**, so that **the backlog reflects reality and does not surface them again in future sessions**.

**Acceptance criteria**

- **Given** the audit found no `permissions.deny` path under `.claude/`, **when** I read the TODO memory, **then** the `--dangerously-skip-permissions` impact item is marked closed with the reason ("no impacted deny rule in the foundation").
- **Given** the audit found no top-level `themes` or `monitors` keys in any preset manifest, **when** I read the TODO memory, **then** the manifest deprecation item is marked closed with the reason ("no occurrence to migrate").

## Functional Requirements

| ID | Requirement | Verification |
|----|-------------|--------------|
| EF-001 | The skills overrides documentation lists the three modes by name | Doc grep for the three mode strings |
| EF-002 | The skills overrides documentation includes one self-contained example per mode | Visual inspection of the example block |
| EF-003 | The plugin evaluation recipe has at most five steps from "I want to try plugin X" to "the plugin is loaded in my session" | Step count |
| EF-004 | The plugin evaluation recipe explicitly references the validation-first policy and links to the marketplace audit methodology | Cross-reference grep |
| EF-005 | The MCP retry paragraph states the upper bound (number of retries) and the failure types covered (transient vs permanent) | Doc grep |
| ~~EF-006~~ | ~~At most one location in the foundation docs hard-codes a specific CLI minor version~~ | **DROPPED 2026-05-06** — premise rejected by audit (see US-4 closure) |
| EF-007 | The install guide mentions the package-manager auto-update env var only as an opt-in, not as a default | Doc grep + tone audit |
| EF-008 | The TODO memory entry for the CLI updates list reflects the post-spec status of every item (active, closed, out of scope) | Memory file review |
| EF-009 | All new documentation is in English | Language audit |
| EF-010 | No new content references competitors by name | Doc grep |

## Verification Policy

RESOLVED 2026-05-06 (option C, pragmatic mix):

- **US-1 (skill overrides) and US-2 (plugin URL/.zip)**: live verification required before documenting. Open a Claude Code session, reproduce each described behavior, capture a transcript. Documentation is written from the transcript, not from the upstream changelog wording. Rationale: these are user-facing configuration features where wording errors have a direct cost on the reader.
- **US-3 (MCP retry)**: no live test required. The documentation stays at the conservative form "auto-retried; see upstream changelog for the bound and failure classification". Rationale: the doc itself defers authority to upstream, so a test would not improve accuracy.
- **US-4, US-5, US-6**: no live test required (doc-refresh, opt-in mention, memory close-out — no upstream behavior to verify).

Estimated overhead: ~30–40 min for the two live tests. Transcripts archived under `specs/cli-updates-2.1.131/transcripts/` (gitignored).

## Edge Cases

- **The upstream feature behaves differently than documented in the changelog.** Mitigation: every documented behavior is verified against a real Claude Code session before merge; the doc cites the upstream changelog as the authoritative source.
- **A future CLI release deprecates one of the new features before the doc ships.** Mitigation: the freshness rationale (EF-006) explicitly tells the reader to consult the upstream changelog if in doubt; the doc itself is dated.
- **The skill overrides mechanism conflicts with the existing exclusion array used in presets.** Mitigation: the doc states which mechanism wins and provides a migration path; presets are not changed in this spec (out of scope, see below).
- **The plugin evaluation recipe is misread as a recommendation to skip the marketplace policy.** Mitigation: the recipe opens with a disclaimer pointing to the validation-first policy and the marketplace audit methodology.
- **A reader copies the auto-update env var assuming it works for the curl-based install.** Mitigation: the mention explicitly scopes it to package-manager installs and states "no effect on the curl one-liner install".

## Entities

No data entities. This work is documentation and a memory-file update.

## Success Criteria

| ID | Metric | Target |
|----|--------|--------|
| CS-001 | Items closed without action in the backlog | 2 (the moot items) |
| CS-002 | New documentation pages or sections shipped | 3 (skill overrides, plugin recipe, MCP retry note) |
| ~~CS-003~~ | ~~Doc references updated to a durable CLI-version form~~ | **DROPPED 2026-05-06** with EF-006 |
| CS-004 | Preset manifests modified | 0 (no preset behavior change in this scope) |
| CS-005 | Tests added or modified | 0 expected (documentation-only); if any doc-validation hook needs adjustment, add a regression test |
| CS-006 | Foundation version bump | Patch (no behavior change for existing users), unless a new opt-in env var is exposed in scripts (then minor) |

## Out of Scope

The following items were considered during the audit but are explicitly excluded from this spec.

- **Replacement of `scripts/uninstall.sh` by `claude project purge`.** The current script is 330 lines covering backup, dry-run, and `.gitignore` cleanup. The upstream command may not cover all of these. Decision: keep `uninstall.sh` until a sandbox test confirms feature parity. Track separately.
- **iTerm2 / macOS terminal clipboard guide.** The audience signal for macOS-specific iTerm2 setup is unclear; opening this without a user request risks shipping documentation that nobody reads. Track as a candidate for a future contribution.
- **Migration of presets from the existing skill-exclusion array to the new override mechanism.** This spec only documents the new mechanism; it does not change any preset. Migration would be a separate spec touching the five presets and consumer scripts.
- **Annoucements (LinkedIn, blog).** No external communication is planned for this iteration. The foundation has shipped doc-only updates without announcement before; same pattern applies here.
- **Items shipped between 2.1.131 and the date the work starts** (if any). If the maintainer starts the work after a new CLI release, they should re-run the audit step from the explore phase before specifying an extended scope.

## Clarification Points

1. **Splitting strategy** — RESOLVED 2026-05-06 (option B): two pull requests. PR1 = housekeeping (US-6 memory close-out + US-5 package-manager auto-update opt-in mention). PR2 = substantive doc additions (US-1 skill overrides + US-2 plugin evaluation recipe + US-3 MCP retry note). **Note**: US-4 was originally part of PR1 but is now closed audit-confirmed-moot, so PR1 is reduced. Boundary rationale: PR1 changes nothing in the user's mental model, PR2 introduces new capabilities to learn.

2. **Handling of US-3 (MCP retry)** — RESOLVED 2026-05-06: conservative form ("auto-retried; see upstream changelog for the bound and failure classification"). This is consistent with the verification policy resolved above (US-3 has no live test).

3. **CS-006 versioning policy** — RESOLVED 2026-05-06: patch bump for both PR1 and PR2. Rationale: PR1 is doc-only (CLI version refresh + memory close-out + opt-in env var mention). PR2 is doc-only (three new doc sections, no script change). The env var `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` is not wired into `install.sh` because the foundation's installer installs claude-base itself, not Claude Code via brew/winget — the env var concerns the user's Claude Code install, which is orthogonal.

## New Clarifications Added During /work:work-clarify (2026-05-06)

4. **Doc verification policy** — RESOLVED (Q2, option C, pragmatic mix): live verification required for US-1 + US-2; conservative wording without live test for US-3; no test for US-4/US-5/US-6. Detail in the "Verification Policy" section above.

5. **Plugin recipe location** — RESOLVED (Q3, option B): the US-2 recipe is added as a new section in `docs/reference/advanced-features.md`, adjacent to the existing `--plugin-dir` mention. No new doc file is created. If the recipe grows beyond ~50 lines, extract to `docs/guides/` later.
