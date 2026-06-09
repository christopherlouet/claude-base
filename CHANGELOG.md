# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

> **Language note**: from v1.31.0 onwards, all entries are in English.
> Earlier entries (v1.30.x and before) remain in their original French
> as a historical record of the project's pre-i18n era.

## [Unreleased]

### Added

- **Preset command & agent filtering** (`foundation.commands` / `foundation.agents`).
  A preset may now scope the installed catalog of commands and agents the same way it
  already scoped skills, via `drop` (blacklist) or `keep` (whitelist) lists supporting
  exact item names and the `domain:<name>` form. Shipped across four sessions
  (S1–S4, specs/presets-commands-agents-filter/, US-1 through US-3):
  - `scripts/lib/catalog-filter.sh`: shared SSOT for domain resolution, `domain:<name>` +
    exact-item matching, and the protected floor (`work` + `assistant`/`assistant-auto`
    are never removable — EF-111).
  - Install-time filter (`scripts/new-project.sh`): `apply_catalog_filters()` reduces a
    real install; `--dry-run` lists removals; a no-filter preset is byte-identical to a
    full install.
  - Update-time filter (`scripts/update.sh`): excluded commands/agents are skipped
    (COPY-only — never deletes on-disk), reported on a distinct `Filtered by preset` line;
    `--no-preset` restores the full catalog.
  - Validation (`scripts/validate-presets.sh`): rejects `drop` XOR `keep`, floor and
    horizontal-domain (`biz`/`legal`/`growth`, owned by modules) removal, and vendor-pointer
    tier filters; warns on unknown item names.
  - **`nextjs` preset adopts the filter** (v1.1.0): excludes the command/agent counterparts
    of its already-dropped skills (`dev-flutter`, `ops-mobile-release`, `ops-opnsense`,
    `ops-proxmox`, `ops-infra-code`, `data-pipeline`) — 6 fewer commands, 5 fewer agents.
- **Foundation modules: installable horizontal domain modules** (`biz`, `legal`, `growth`).
  Implemented across four sessions (S1–S4), covering specs/foundation-modules/ (US-1 through US-5):
  - `claude-base add <module>` / `claude-base remove <module>` / `claude-base modules` CLI verbs.
  - Module-aware update: `update --all` refreshes installed modules and skips absent ones.
  - Preset `defaultModules[]` field: a preset may declare which modules to install by default;
    init summary advertises the rest with `claude-base add` hints.
  - `scripts/validate-presets.sh` validates `defaultModules[]` (known names, non-array error,
    forbidden on vendor-pointer tier EF-210).
  - `scripts/module.sh`: add/remove commands with dry-run, idempotency, conflict handling.
  - `scripts/lib/modules/`: bundle manifests for `biz` (11 commands + 4 agents), `legal`
    (5 commands + 4 agents), `growth` (11 commands + 6 agents + growth-cro skill).
  - `docs/reference/commands.md`: `claude-base add/remove/modules` section.
  - `.claude/presets/README.md`: `defaultModules` field documentation.

### Changed

- **`nextjs` preset now filters commands and agents (v1.0.0 → v1.1.0).** Existing `nextjs`
  projects that run `claude-base update` will no longer be offered the 6 commands / 5 agents
  matching its dropped skills (`dev-flutter`, `ops-mobile-release`, `ops-opnsense`,
  `ops-proxmox`, `ops-infra-code`, `data-pipeline`); already-installed copies are left on disk
  untouched (COPY-only). Run `update --no-preset` to re-install the full catalog (the
  next update copies the excluded files back in; nothing is deleted in the meantime).
- **⚠ BREAKING — `.claude/.foundation-version` marker replaced by `.claude/foundation.json` manifest** (EF-205).
  The legacy plain-text version marker is no longer written by `claude-base init` or `claude-base update`.
  All foundation tooling reads the JSON manifest first; `update` creates the manifest and removes the
  marker on first contact with a legacy project (migration is automatic and reported).
  **The migration only runs through `claude-base update`**: on a legacy project, run `update`
  once before using the `add`/`remove`/`modules` verbs (they require the manifest and will
  point you at `update` otherwise).
  **Impact for external readers**: any script, CI step, or tool that reads
  `.claude/.foundation-version` directly must be updated to read
  `.claude/foundation.json` (field `version`). Example migration:
  ```bash
  # before
  cat .claude/.foundation-version
  # after
  jq -r '.version' .claude/foundation.json
  ```

- **docs: refresh model references to Opus 4.8** (Anthropic news, week of 2026-05-22). Bumped every `Opus 4.7` → `Opus 4.8` and corrected the latest-Opus model ID `claude-opus-4-6` → `claude-opus-4-8` across `docs/`, `website/docs/`, `templates/` and `.claude/` (CHANGELOG/specs left untouched as historical record). Updated the `dev-ai-integration` SDK matrix to `Opus 4.8, Sonnet 4.6, Haiku 4.5`.
- **docs: Opus 4.8 facts** — defaults to `high` effort, **1M context window now default** (not beta) on API/Bedrock/Vertex, ~4× less likely than 4.7 to let a self-authored code flaw pass. Reflected in `advanced-features.md`, `best-practices.md`, `templates/FAQ.md`, `website/docs/concepts/advanced-features.md`.

### Added

- **docs: Dynamic Workflows section** (`advanced-features.md` + website mirror) — native Opus 4.8 Workflow capability orchestrating tens–hundreds of background agents with deterministic control flow, plus a "which mechanism" comparison vs `parallel-agents` and Agent Teams.
- **docs: pointers** for week-of-2026-05-22 Anthropic releases — Claude Security public beta / Project Glasswing, `/code-review --fix` (CLI 2.1.152) auto-applying to the working tree + native skill management, doubled Claude Code rate limits, and Managed Agents private-MCP sandbox + Compliance API.

## [2.0.0] - 2026-05-22

**Major release — positioning pivot.** No CLI breaking change; the major-version bump reflects a strategic repositioning of the foundation under a `workflow framework + curator` framing.

The Strategic memo at [`specs/foundation-positioning-review/spec.md`](specs/foundation-positioning-review/spec.md) (PR #226, merged 2026-05-21) opened a 5-phase review of the foundation. The premise: a 1-maintainer foundation cannot systematically be deeper or fresher than a 6,700+ community skill ecosystem refreshed daily, so each foundation resource has to justify its existence under a 4-tier rubric (KEEP-AS-IS / KEEP+POINT-TO-VENDOR / REDUCE-TO-POINTER / DEPRECATE).

Phases 0-5 closed between 2026-05-21 and 2026-05-22 across 18 PRs. Cumulative LOC removed from foundation skill content: **~1.5 KLOC across 15 reduction/deprecation PRs**, without losing the foundation's unique angles (workflow integration, anti-drift CI, path-rules, hooks, foundation discipline that survives vendor releases).

### Migration guide

**No CLI breaking change.** `claude-base init / update / validate / uninstall / preset` all behave identically to v1.41.2. Tests, presets, hooks, rules — unchanged.

**What changed in the skill layer**: 7 skills + 3 commands + 2 agents were either reduced to vendor pointers (with a thin foundation-discipline overlay) or deprecated outright. If you had **inline reliance** on the previous code examples in any of these skills, you now need to install the corresponding vendor skill from [`docs/recipes/recommended-vendor-skills.md`](docs/recipes/recommended-vendor-skills.md):

| Foundation skill (reduced or removed) | Install vendor replacement for depth |
|---|---|
| `dev-prisma` (Wave 1) | `prisma/skills` |
| `dev-supabase` (Wave 1) | `supabase/agent-skills` |
| `dev-shadcn` (Wave 1) | shadcn canonical skill (in main repo) |
| `growth-seo` (Wave 1) | `AgriciDaniel/claude-seo` |
| `biz-pricing` (Wave 1) | `coreyhaines31/marketingskills/pricing` |
| `state-management` (Wave 3) | Zustand / Redux Toolkit / Jotai / TanStack Query official docs |
| `api-mocking` (Wave 3) | MSW (`mswjs.io`) |
| `feature-flags` (Wave 3) | LaunchDarkly / Unleash / ConfigCat / OpenFeature |
| `ops-docker` (Wave 3) | Docker official + Snyk + Hadolint |
| `git-worktrees` (Wave 3) | `git-scm.com/docs/git-worktree` |
| `qa-chrome` (Wave 3) | `ChromeDevTools/chrome-devtools-mcp` |
| `qa-perf` (Wave 3) | `addyosmani/web-quality-skills` |
| `data-analytics` (Wave 2, **DEPRECATED**) | use `/growth:growth-analytics` — the cohort/RFM SQL angle was merged in |
| `doc-i18n` (Wave 2, **DEPRECATED**) | use the foundation's existing `dev-i18n` skill |
| `dev-prompt-engineering` (Wave 2, **DEPRECATED**) | ecosystem of community prompt-engineering skills — see marketplace |

The recipe now ships a [By stack](docs/recipes/recommended-vendor-skills.md#by-stack-quick-lookup) matrix at the top — find your detected preset (nextjs / fastapi / astro / react-vite-spa / etc.) and install the listed required + recommended vendor skills.

### Changed

- **README pivot to "workflow framework + curator" framing** (this PR). Top pitch states both roles explicitly. "How it fits" section explains the rationale (1-maintainer can't out-update 6,700+ community skills daily, so we curate + ship workflow). vs-marketplace subsection makes the curator pattern primary instead of an apologetic addendum, and forward-references the Phase 6 vision.

- **Recipe `recommended-vendor-skills.md` gains a `By stack` matrix** (this PR). Quick-lookup section at the top, additive to the existing per-domain organisation. Covers all 11 validated presets plus cross-stack growth/marketing skills.

### Phased work summary

- **Phase 0** (spec.md, PR #226) — Strategic memo: 4-tier rubric, ~150 resources scored by 3 parallel research agents, verdict distribution recorded.
- **Phase 1** (PR #227) — Recipe enrichment: added `coreyhaines31/marketingskills`, `PostHog/skills`, `resend/resend-skills`, `AgriciDaniel/claude-seo` + growth-skills-pilot trace. `marketplaceAuditPilots` 4 → 5.
- **Phase 2 — Wave 1 REDUCE** (PRs #228-#232) — 5 resources reduced to vendor pointers: `growth-seo`, `biz-pricing`, `dev-shadcn`, `dev-prisma`, `dev-supabase`. `biz-mvp` and `biz-okr` deferred from this wave when vendor verification fell through (weak community signal at the time).
- **Phase 3 — Wave 2 DEPRECATE** (PRs #233-#235) — 3 resources removed: `doc-i18n` (overlapped foundation's `dev-i18n`), `dev-prompt-engineering` (no foundation-unique angle), `data-analytics` (MERGE variant — cohort/RFM SQL reinjected into `growth-analytics` first in a `feat` commit, then deleted in a `docs` commit). Counters: commands 130→128, agents 63→61, skills 54→53, byDomain.data 3→2.
- **Phase 4 — Wave 3 REDUCE** (PRs #236, #237, #238, #240, #241, #242, #243) — 7 resources reduced: `git-worktrees`, `state-management`, `api-mocking`, `feature-flags`, `ops-docker` skill, `qa-chrome`, `qa-perf`. Wave 3 cumulative -1,418 LOC. The `feature-flags` PR also dropped the unreferenced 324-LOC `examples/feature-toggle.md` (orphan); same pattern applied to `ops-docker/examples/multi-stage.md`. The `qa-perf` PR fixed an obsolete metric (FID → INP, per Google March 2024 Web Vitals update).
- **Phase 5 — Repositioning + v2.0.0** (this PR) — README pivot + Recipe per-stack matrix + this CHANGELOG entry + VERSION bump.
- **Phase 6 — Curator bindings** (vision captured in #239) — Operationalises the curator claim post-v2.0.0: preset schema gains `vendorSkills.{required,recommended,optional}[]`, `claude-base init` surfaces recommendations as a single Y/n prompt. Vision-only at v2.0.0; implementation lands in v2.1+.

## [1.41.2] - 2026-05-20

Patch release. Six PRs since v1.41.1, same day — three bug fixes (one **critical** for every `curl | bash` user), one security CVE patch, plus the first asciinema GIF embedded in the README and an honest positioning vs `github/spec-kit`. No new commands/agents/skills/rules/presets ; no breaking change.

Counters : `tests` 692 → **695** (+3 dispatcher symlink regression tests + minor adjustments). All other counts unchanged.

### Fixed

- **🔴 Critical : dispatcher symlink resolution** (#220). The `bin/claude-base` dispatcher computed `BASE_ROOT` via `dirname + cd + pwd` without resolving symlinks — but `install.sh` creates `~/.local/bin/claude-base` as a symlink to `~/.local/share/claude-base/bin/claude-base`. Result : **every user installed via `curl | bash` had a broken CLI** :
  - `claude-base version` → `vunknown` (VERSION file not found at wrong BASE_ROOT)
  - `claude-base init/update/validate/preset` → `No such file or directory` for the underlying script
  Why CI didn't catch it : the bats suite always invoked the dispatcher directly from a foundation clone, never through a symlink. The bug only manifested for the documented one-liner install flow. Fix : portable bash idiom walking symlinks (works on Linux + macOS without coreutils / GNU `readlink -f`). +2 bats regression tests reproducing the symlink invocation. Discovered while building the asciinema demo recording inside a clean Docker container.

- **Security : bump `ws` to 8.20.1** (#219, [Dependabot alert #43](https://github.com/christopherlouet/claude-base/security/dependabot/43)). Moderate-severity uninitialized-memory-disclosure in `ws >= 8.0.0 < 8.20.1`. Resolved transitively (via `webpack-dev-server`) by `npm audit fix` — no manual override needed. 3-line diff in `website/package-lock.json`. No production impact (`ws` is only used by the Docusaurus dev server, doesn't ship in the built site).

- **Docusaurus rendering : strip count markers from fenced code blocks** (#218). The `inject-counts-md.ts` regen pipeline wrote `<!-- count:KEY -->NNN<!-- /count -->` everywhere uniformly. MDX strips HTML comments outside code fences but leaves them as **literal text inside fences**, so the markers leaked as visible text on /docs/intro/architecture and 7 other pages. User-reported via screenshot. Fix : strip the comment-wrappers inside code fences only (kept outside fences where the regen pipeline still uses them for auto-bump). +1 bats regression test scanning every `.md` for marker-in-fence (CI-gated).

### Added

- **Asciinema demo recording scaffolding** (#221). New `website/demo/{Dockerfile.demo,scenario.sh,record.sh,README.md}` to regenerate the README "60-second tour" GIF reproducibly :
  - Isolated Docker container (Ubuntu 24.04 + Node + Claude Code CLI, non-root `demo` user matching host UID 1000)
  - asciinema rec wrapping a `docker run` with the host's `~/.claude/` mounted into a writable temp copy (slash commands need to write back ; the host's real auth state is never touched)
  - Renders the GIF via `agg --speed 1.5`
  - `bash website/demo/record.sh` end-to-end (~60-90s for the recording, depending on Claude API latency)
  - Auto-regen explicitly NOT wired to CI (Anthropic auth can't be exposed to CI secrets safely)

- **Real asciinema GIF embedded in README** (#222). Replaces the previous static "60-second tour" prose with `60-second-tour.gif` (123 KB, 40s playback). Shows real `curl | bash` install + real `claude-base init --preset nextjs` + real `claude --print '/assistant How to use /dev:dev-tdd?'` reply with markdown coloring (H1 cyan, H2 yellow, inline code green, **bold**), Unicode braille `thinking...` spinner during the API wait, and a closing CTA. Reproducible via `bash website/demo/record.sh`.

### Changed

- **README positioning vs `github/spec-kit`** (#223). github/spec-kit (103K stars, by GitHub) is the canonical Spec-Driven Development toolkit covering `/speckit.{specify,plan,tasks,implement}` across 30+ AI agents. claude-base shares vocabulary ('Specify → Plan → Tasks'), risking visitor confusion. New `## How it fits in the AI-coding ecosystem` section with a dedicated `### vs Spec Kit` subsection + 10-row comparison table. Positions claude-base as the **Claude-Code-native discipline layer** (TDD enforced + qa-loop audit + 30 path-rules + hooks + anti-drift CI) complementary to spec-kit's multi-agent SDD primitives. Investigated whether claude-base could ship as a spec-kit extension : architecturally incompatible (no rules engine, no hooks-into-`settings.json`, no presets-with-vendor-pointers in spec-kit's manifest schema). Drop the idea, position side-by-side honestly.

## [1.41.1] - 2026-05-20

Patch release. Twelve PRs since v1.41.0, all polish — 3 bug fixes + 2 test-coverage additions + 7 documentation cleanups. No new commands/agents/skills/rules/presets ; no breaking change.

Counters : `tests` 659 → **692** (+33 bats), `commands/agents/skills/rules/presets` unchanged.

### Fixed

- **`scripts/ide.sh --dry-run` end-to-end** (#210). The `--dry-run` flag was advertised in `--help` but only partially functional : the lib-helper `run_cmd` skipped `mkdir`, but 10 heredoc-style file writes bypassed the dry-run gate and either errored (VSCode/IntelliJ : `cat: .vscode/settings.json: No such file or directory`) or silently wrote the file (Vim case). Introduced a new `write_file` helper in `scripts/lib/common.sh` (drop-in replacement for `cat > "$path" <<EOF`, symmetric to `copy_file` / `copy_dir`) and migrated the 10 call sites. The flag now works end-to-end ; 4 new bats tests cover the regression class.

- **`scripts/bump-version.sh` obsolete steps removed** (#212). The release-flow bumper had four steps but two were silent no-ops since PR #206 :
  - Step 2 looked for the static `release-v${VER}-blue` badge URL that was replaced by a dynamic shields.io GitHub-release endpoint.
  - Step 4 looked for the `${MINOR}.x | Actuel` row in a French versioning-policy table that was rewritten as the generic "Upgrades & Changelog" pointer.
  Each release emitted two `[!] pattern not found, may already drift` warnings — noise mainteners learn to ignore. Removed both steps cleanly, renumbered the remaining two, added a historical-note comment to prevent reinstatement. Surfaced by 10 new bats tests covering the release flow's dry-run path.

- **Dispatcher CLI naming canonicalized end-to-end** (#216). Running `claude-base preset list` (or auto-detection hints) leaked the underlying script names in user-visible output : `Use: new-project.sh --preset <name> <path>`, `Try: new-project.sh --preset <name> <path>`. The dispatcher help also advertised `(alias for new-project.sh)`. Introduced an env-var-gated `cli_usage` helper that switches between `claude-base <verb>` (dispatcher mode) and `./scripts/X.sh` (direct foundation-contributor mode), wired through 4 call sites in `new-project.sh` + `diff.sh`. The canonicalization PR #202 sweep now extends to runtime output.

### Added

- **`tests/validate-presets.bats`** (#211) — 16 new tests covering preset manifest validation : JSON syntax rejection, required-field detection, status enum, name pattern (kebab-case), defaults shape, foundation.skills XOR (drop ⊕ keep), vendor-pointer tier semantics, marketplacePlugins shape, plus a regression test that all <!-- count:presets -->11<!-- /count --> shipped foundation presets validate cleanly. Closes the highest-value gap in the scripts/ bats coverage matrix — `validate-presets.sh` is invoked by `audit-base.sh` on every PR.

- **`tests/bump-version.bats`** (#212) — 10 new tests covering the release flow's bump step in `--dry-run` mode (CI-safe, no fixture repo needed). Argument validation (missing arg, non-semver formats), dry-run safety (VERSION + README hashes byte-for-byte unchanged), and a regression test that the script's sed patterns still match the real README. The regression test was the canary that surfaced the obsolete-steps bug fixed above.

- **`tests/dispatcher.bats` CLI-naming assertions** (#216) — 3 new tests : the dispatcher emits `claude-base init` in `preset list` footer ; dispatcher `--help` no longer leaks "alias for new-project.sh" ; foundation-contributor path (direct script invocation) still keeps the raw script name in its hint.

### Changed

- **README front-door rewrite** (#203, #205-#209) — five-PR sweep on `README.md` :
  - Rewrote the first ~130 lines for HN/Reddit-style first-time visitors : opinionated tagline, 30-second `Try it` block, `Is it for you?` persona-fit table, `What you get on disk` tangible artifact, static `60-second tour` with realistic terminal output, `How it fits in the Claude Code ecosystem` promoted above the fold.
  - Replaced the ~100-line file-by-file tree in the Structure section with a 13-row architecture-level table pointing to Docusaurus for file-by-file detail.
  - Wrapped the 9 by-domain command counts in `<!-- count:byDomain.X -->` markers so they stay in sync via the regen pipeline.
  - Killed 3 hard-coded counts (gitleaks `24+` rules, presets `6 maintainer-vouched + 5 vendor-pointer` breakdown, 19-row test-layout enumeration) — replaced with anchors-only tables + pointers to the source-of-truth file.
  - Trimmed 6 verbose sections (IDE Integration, Pre-commit Hooks setup, Default Permissions table, gitleaks install, bats install, Production Readiness self-scores) by pointing to upstream docs instead of duplicating setup instructions.
  - Fixed 4 visible drifts : `.claude/` tree listing 4 of 7 directories, "canonical 7-step workflow" mention, CI/CD section listing 3 of 6 workflows, stale "Migration & Breaking Changes" section frozen at v1.10/v1.30. Replaced the migration section with a generic "Upgrades & Changelog" pointer.
  - Editorial consistency : added `recipes/` + `learning-path.md` pointers in Documentation, dropped phantom `dev-supabase` step from the Mobile Flutter walkthrough, surfaced `claude-base init --type react` as the preferred template-install path.

  Net : README 720 → 536 lines (-184, -25%). All counts now in markers or self-counting tables.

- **`docs/reference/agents-catalog.md` H2 counts wrapped in markers** (#213). 9 section headers (`## WORK-: Main Workflow (15)`, `## DEV-: Development (23)`, ...) had hardcoded counts — same anti-pattern eliminated from README in #205. Wrap all 9 with `<!-- count:byDomain.X -->N<!-- /count -->` so the regen pipeline keeps them in sync. Also fixed `docs/README.md` tree (missed `recipes/` directory) and the last user-facing `./scripts/update.sh` reference in `docs/recipes/python-toolchain-options.md`.

- **`website/docs/intro/` pages canonicalized on `claude-base` CLI** (#214). The Docusaurus intro/ pages still documented the pre-dispatcher install flow that PR #202 fixed everywhere else. Replaced 5 stale `~/.local/share/claude-base/scripts/X.sh` invocations with the dispatcher form across `intro/installation.md` Method 1 / Update section / Troubleshooting, plus the `curl ... /scripts/new-project.sh | bash` recipe in `intro/quick-start.md`. Dropped hardcoded `(6 maintainer-vouched + 5 vendor-pointer)` tier breakdown from `intro/what-is-claude-code.md`. Corrected the `concepts/index.md:114` skill reference from non-existent `"security-audit"` to canonical `qa-security`.

- **`AGENTS.md` (root cross-tool entry point) cleanup** (#215). Two latent drifts that PR #202 and PR #213 missed because both passes touched only files under `docs/` and `website/docs/` — but AGENTS.md is at repo root and is read by Codex / Cursor / Copilot / Gemini CLI : `./scripts/new-project.sh --preset` → `claude-base init --preset` (canonical), and hardcoded `30 rules covering ...` wrapped in `<!-- count:rules -->` marker. Plus renamed `website/docs/tutorials/opnsense-firewall.md` → `09-opnsense-firewall.md` to close the 01-08, **gap**, 10-12 file-tree numbering gap (Docusaurus strips numeric prefixes when deriving IDs, so URLs and sidebar entries are unchanged).

## [1.41.0] - 2026-05-19

Minor release. Post-v1.40.0 follow-up focused on **doc-drift hardening** and **front-door UX**. Headline addition: a new **`scripts/audit-docs.sh` doc drift firewall** integrated into `audit-base.sh` — catches 5 syntactic drift categories (paths, claude-base verbs, init/update flags, local scripts, npm scripts) before merge, with per-category env-var bypass and 14 new bats tests. Two doc hygiene PRs canonicalize user-facing docs on the `claude-base` CLI dispatcher (no more `./scripts/X.sh` confusion for post-install users) and rewrite the README front-door for HN/Reddit-style first-time visitors (30s pitch, persona-fit table, "What you get on disk" tangible artifact, 60-second tour). Two `Fixed` entries close pre-existing latent drift (install path, hard-coded counter prose).

Counters : `tests` 645 → 659 (+14 audit-docs bats). No new commands/agents/skills/rules/presets. Behaviour-additive across the board, no breaking change.

### Changed

- **README front-door rewrite**. Replaces the kitchen-sink "What is it?" feature
  list with a 30-second tagline + Try it block + "Is it for you?" persona-fit
  table + reordered "How it fits in the Claude Code ecosystem" promoted above
  the fold. Adds a "What you get on disk" tangible-artifact section and a
  static "60-second tour" with realistic terminal output (asciinema placeholder
  for when a real recording lands). The detailed appendix pieces (three-tier
  preset breakdown, category prompt, cross-tool AGENTS.md compatibility,
  long-term direction with vendor-neutrality stance) move to a "Going deeper"
  section near the bottom, off the front-door bounce path. Demystifies the big
  numbers (131 commands ≠ 131 to learn ; mandatory workflow is 5 slash-commands).
  Motivated by fresh-eyes analysis : a HN-arriving dev needs "what is it / is
  it for me / show me / let me try" answered in 30 seconds, not after 70 lines
  of feature list.

  Latent drifts caught and fixed in passing : `website/docs/intro/index.md`
  had the stale `curl ... /scripts/new-project.sh | bash` recipe that PR #202
  missed ; `docusaurus.config.ts` tagline dropped the Audit phase (5-phase
  workflow instead of 6).

- **Docs canonicalized on the `claude-base` CLI**. The dispatcher
  (`claude-base init / update / validate / uninstall`) is now the
  canonical entry point in user-facing docs ; direct `./scripts/X.sh`
  invocations are framed as advanced/internal access only. Touches
  README, CLAUDE.md, QUICKSTART, PROMPTING-GUIDE, TEAM-GUIDE,
  recipes (saas-monetization, python-toolchain-options),
  hooks-reference (mirrored), installation.md, learning-path.md, and
  `website/docs/reference/scripts.md` (restructured to lead with the
  dispatcher CLI and surface direct-script access as an advanced
  fallback). In-repo contributor commands normalized to
  `./bin/claude-base init` instead of `./scripts/new-project.sh`.
  Stale `curl ... /scripts/new-project.sh | bash` recipe replaced
  with the canonical `curl ... /install.sh | bash` one-liner.
  Behaviour unchanged ; scripts remain callable directly. Motivated
  by ergonomic consistency : after `curl|bash` install, users have
  `claude-base` on PATH and should not need to know about
  `./scripts/` layout.

### Added

- **Doc drift firewall: `scripts/audit-docs.sh`**. Catches 5 categories of
  syntactic drift in hand-maintained docs that the existing gates miss:
  unknown `~/X` claude-related path prefixes, unknown `claude-base <verb>`
  invocations, unknown `claude-base init|update --<flag>` flags, references
  to missing `./scripts/<X>.sh`, and unknown `npm --prefix website run <X>`
  scripts. Each category is allowlisted from a small bash array at the top
  of the script — 1-line edit to extend. Wired into `audit-base.sh` as a
  new step. Exits non-zero on any drift ; per-category bypass via
  `AUDIT_DOCS_SKIP_{PATHS,VERBS,FLAGS,SCRIPTS,NPM}=1`. Historical bugs that
  would have been caught earlier: PR #199 (`~/.claude-base/` install path
  drift, 10 occurrences, latent for months). Threat model focuses on
  foundation-path typos — generic user paths (`~/.ssh`, `~/.kube`,
  `~/.zshrc`) are out of scope. Spec :
  `specs/audit-docs/spec.md`. +14 bats tests (zero-FP gate against the
  real foundation repo included).

### Fixed

- **Latent counter drift: hard-coded numbers wrapped in `<!-- count:* -->` markers**.
  Doc audit pass identified 5 hard-coded counter references in
  prose that would silently drift when new artifacts ship:
  `website/docs/intro/index.md` ("See all 11 presets") and
  `docs/CHEATSHEET.md` ASCII boxes (DEV 23 / QA 16 / OPS 34 /
  GROWTH 11 commands). All wrapped in `count:presets` /
  `count:byDomain.{dev,qa,ops,growth}` markers — the auto-regen
  pipeline now owns them. Values currently match counts.json,
  but the next preset/command added in any of those domains
  will auto-bump these instead of going stale.

- **Doc drift: install path corrected to `~/.local/share/claude-base/`**.
  `website/docs/intro/installation.md` previously documented the
  install location as `~/.claude-base/` (10 occurrences). The
  canonical path per `install.sh:33` is `$HOME/.local/share/claude-base`
  (XDG Base Directory spec). User following the doc literally would
  clone to a non-canonical location ; the docs now match the script.

## [1.40.0] - 2026-05-19

Minor release. Two-week burst of foundation-level features around preset discovery and curation, plus a documentation hygiene sweep that surfaces them across README / EXTENDING-GUIDE / Docusaurus public pages. Headline additions: a new **`vendor-pointer` preset tier** (5 instances shipped: phaser, playwright, pulumi, apollo, mongodb), an **interactive category prompt** in `claude-base init` (8-entry intent taxonomy), an **`AGENTS.md`** cross-tool entry point at repo root, and an **optional `categories[]` field** on the preset manifest schema. All 11 shipped presets retrofitted in the same delivery. Counter `presets` 6 → 11 ; `vendorSkillsValidated` 16 → 17 ; `tests` 620 → 645 (+25 bats tests).

Behaviour-additive across the board, no breaking change. The category prompt is silently skipped on non-TTY, `--skip-prompts`, `--yes`, `--preset`, `--type`, or when auto-detect already produced a match — default flow for existing users unchanged.

### Changed

- **Surface preset system in the Docusaurus public-facing pages**.
  Four website intro pages updated to reflect the foundation's
  composition layer (11 presets across 3 tiers) that was
  shipped over the past 2 weeks but invisible on the public
  site: `index.md` (Welcome) adds a Presets row to the Key
  numbers table + a stack-specific install snippet;
  `what-is-claude-code.md` augments the "4 components" framing
  with a 5th "composition layer" paragraph; `quick-start.md`
  gains two new install options (Option 3 `--preset` + Option 4
  interactive category prompt with the 8-entry taxonomy
  rendered inline); `architecture.md` gains a "Presets" section
  in Main components covering the 3 tiers + AGENTS.md cross-tool
  entry point. Pure documentation hygiene.

- **Surface category prompt + AGENTS.md in README; new `Author a preset` section in EXTENDING-GUIDE**.
  Two recent user-facing additions were under-documented despite
  being shipped : the pre-detection category prompt (PR #192)
  and the `AGENTS.md` cross-tool entry point (PR #187). The
  README's "Presets" section now describes the 8-entry intent
  taxonomy + when the prompt fires, and a new "Cross-tool
  compatibility" paragraph names `AGENTS.md` and the SKILL.md
  open-standard angle. `docs/guides/EXTENDING-GUIDE.md` gains a
  new "## 8. Author a preset" section covering the 3 tiers
  (maintainer-vouched / community-curated / vendor-pointer),
  a minimal manifest example, the `categories[]` field, and a
  10-step workflow. Pure documentation hygiene — no code change.

- **Fix preset list drift in README and canonical catalogues**.
  Five drifts corrected: `README.md` "Why claude-base" line + the
  later "Presets" subsection listed only 6 presets while the
  auto-bumped badge said 11 (the 5 vendor-pointer instances
  shipped #185-#191 were never named in the narrative);
  `.claude/presets/README.md` text still said "1 vendor-pointer
  preset (`phaser`)" frozen at PR #185; the manifest-shape
  example in the same file lacked `vendor-pointer` in the
  status enum; `specs/presets/spec.md` status header was frozen
  at "1 vendor-pointer". Pure documentation hygiene — the README
  now lists all 11 presets across their 3 tiers and links to the
  canonical catalogue + the vendor-pointer tier spec.

- **Mark 4 shipped specs as Validated**. `specs/marketplace-audit/`
  (Living document, 4 audit pilots in use), `specs/archive/vendor-skills-game-dev/`
  (shipped #183), `specs/presets-vendor-pointer-tier/` (shipped #185,
  5 instances live), `specs/preset-category-prompt/` (shipped #192).
  Status headers updated with PR references and live-deliverable
  pointers. Pure documentation hygiene — no functional change.

### Added

- **Pre-detection category prompt + `categories[]` schema extension**.
  When a user runs `claude-base init` on an empty directory (or a
  script-created directory) with no `--preset`/`--type` flag and
  auto-detection produces no match, a new prompt asks "What are
  you building?" with an 8-entry taxonomy locked to the roadmap
  (Web frontend / API-Backend / Mobile-Desktop / Game-Interactive
  media / Data-Database / Infra-DevOps / CLI-Automation /
  Other-Generic). The chosen category filters the subsequent
  type-and-preset menu down to relevant entries. The preset
  manifest schema gains an optional `categories: [string]` field
  (strict enum validated by `validate-presets.sh`); presets without
  it remain accessible via detect / `--preset` / `claude-base
  preset list` (soft migration, no breaking change for community
  contributors). All 11 shipped presets retrofitted with their
  category in the same delivery. The prompt is silently skipped
  on non-TTY, `--skip-prompts`, `--yes`, `--preset`, `--type`, or
  when auto-detect already produced a match (5 guards combined).
  Default choice is "Other / Generic" (regression-safe: falls back
  to the full unfiltered menu). Cross-cutting tool-presets like
  `playwright` declare multi-category (`["web-frontend",
  "api-backend"]`) to appear in both contexts where E2E tests
  actually run. Counter `presets` unchanged at 11; `tests` grows
  to 645 (+10 new bats tests including a drift-guard that compares
  the lib taxonomy vs the roadmap section at every CI run). New
  library `scripts/lib/category-map.sh` holds the 8-entry enum,
  the category-to-types mapping, and the `ask_category` /
  `apply_category_choice` helpers. Spec at
  [`specs/preset-category-prompt/`](./specs/preset-category-prompt/).

- **`mongodb` vendor-pointer preset (5th instance of the tier)**.
  Surfaces `mongodb/agent-skills` (Apache-2.0, 114★, verified
  2026-05-19, last commit 2026-05-18) at install time on projects
  whose `package.json` contains `"mongodb":` (colon-anchored
  substring — disambiguates from `mongodb-memory-server`,
  `@types/mongodb`, `mongodb-runner`, etc. that would all match
  a bare `mongodb` substring). The paired fixture intentionally
  includes `mongodb-memory-server` as a `devDependency` to
  validate the disambiguation in a regression test. Mongoose ODM
  remains a separate hypothetical candidate per the strict
  1-entry detect rule (EF-005). MongoDB Inc. is independent
  (no vendor-neutrality concern). Counter `presets` 10 → 11
  (auto-regenerated).

- **`apollo` vendor-pointer preset (4th instance of the tier)**.
  Surfaces `apollographql/skills` (MIT, 72★, verified 2026-05-19,
  last commit 2026-05-14) at install time on projects whose
  `package.json` contains `"@apollo/client"`. The vendor's skill
  suite covers Apollo Client, Apollo Server 5, Apollo Connectors,
  Federation 2, and Apollo Kotlin — but the strict 1-entry detect
  rule (EF-005) forces a choice; this preset targets the dominant
  client-side use case. Server-side Apollo (`@apollo/server`,
  `@apollo/gateway`) and Apollo Kotlin are documented in
  `outOfScope` for a hypothetical follow-up `apollo-server` preset.
  Apollo GraphQL Inc. is independent (no vendor-neutrality
  concern). Counter `presets` 9 → 10 (auto-regenerated).

- **`pulumi` vendor-pointer preset (3rd instance of the tier)**.
  Surfaces `pulumi/agent-skills` (Apache-2.0, 48★, verified
  2026-05-18, last commit 2026-05-13) at install time on projects
  containing a `Pulumi.yaml` config file. Exercises the `files[1]`
  shape of the EF-005 detect rule (vs `depFiles[1]` used by phaser
  and playwright) — first vendor-pointer with a file-presence
  detect rather than dependency-substring. Pulumi is independent
  (no vendor-neutrality concern). Counter `presets` goes from 8
  to 9 (auto-regenerated). Follows the pattern established by
  the `phaser` and `playwright` presets.

- **`playwright` vendor-pointer preset (2nd instance of the tier)**.
  Surfaces `microsoft/playwright-cli` (Apache-2.0, 10,457★, verified
  2026-05-18, last commit 2026-05-07) at install time on projects
  whose `package.json` contains `"@playwright/test"`. Vendor-
  neutrality accepted **case-by-case** per the foundation policy:
  Microsoft owns Playwright (created 2020, pre-OpenAI commercial
  deepening), de-facto standard for E2E testing. Counter `presets`
  goes from 7 to 8 (auto-regenerated). Follows the pattern
  established by the `phaser` preset; same vendor-pointer tier
  rules (no `foundation.skills` filter, no `marketplacePlugins`,
  no `defaults`, single-entry `detect`).

- **`AGENTS.md` cross-tool entry point at repo root**. Thin index
  (~45 lines) signaling SKILL.md open standard compliance to
  Codex / Cursor / Copilot / Gemini CLI and other Agent
  Skills-compatible tools. Points to `CLAUDE.md` for the full
  workflow, `.claude/skills/` / `.claude/rules/` / `.claude/agents/`
  / `.claude/presets/` for the artifacts, and names the foundation's
  key conventions. Zero functional change — existing skills already
  use the standard frontmatter (`name` + `description`); Claude-
  specific extensions (`allowed-tools`, `context: fork`, `model`)
  are tolerated by other tools as unknown fields.

- **Third preset tier `vendor-pointer` + first instance `phaser`**.
  Introduces a new preset tier alongside `maintainer-vouched` and
  `community-curated` for thin pointer-only manifests whose authority
  comes from the vendor (validated via the marketplace-audit
  methodology) rather than from maintainer production use. The tier
  forbids `foundation.skills` filters, `marketplacePlugins`, and
  `defaults` overrides; requires `recommendedVendorSkills[]` with ≥1
  entry; requires a simple `detect` rule (exactly 1 signal entry,
  `files[1]` XOR `depFiles[1]`). First instance `phaser` wraps the
  `phaserjs/phaser/skills/` entry shipped previously, so a user
  creating a Phaser-based project receives the vendor pointer at
  install time via the existing `print_recommended_vendor_skills`
  pipeline. Counter `presets` goes from 6 to 7 (auto-regenerated).
  5 candidate vendors (Apollo, Pulumi, MongoDB, Grafana, Playwright)
  named in the roadmap for follow-up PRs. Spec at
  [`specs/presets-vendor-pointer-tier/`](./specs/presets-vendor-pointer-tier/).

- **Vendor-skill pointer for game development**.
  `docs/recipes/recommended-vendor-skills.md` gains a Phaser entry
  pointing to the vendor-published skill suite at
  `phaserjs/phaser/skills/` (28 SKILL.md files, MIT, independent,
  39,638★ verified 2026-05-18). `specs/presets/roadmap.md` gains a
  `Game / Interactive media` subsection under "What is NOT covered"
  acknowledging the gap, with a signpost to the existing
  contribution path. Counter `vendorSkillsValidated` goes from 16
  to 17 (auto-regenerated). No bundled skill or preset added.
  Spec at [`specs/archive/vendor-skills-game-dev/`](./specs/archive/vendor-skills-game-dev/).

### Changed (additional)

- **Documentation refresh for Claude Code 2.1.141 / 2.1.142**. Surface
  six recent CLI behaviors across the foundation docs without any
  behavioral change to the foundation itself:
  - `docs/reference/best-practices.md` — note **Auto Dream / Dreaming**
    (Anthropic managed memory) as complementary to the existing
    file-based auto-memory system; document the Rewind menu's
    **"Summarize up to here"** entry (CLI 2.1.141).
  - `docs/reference/hooks-reference.md` — document the new
    **`terminalSequence`** hook JSON field (CLI 2.1.141) for
    desktop notifications / window titles / bells without a TTY.
  - `docs/recipes/recommended-vendor-skills.md` — new
    **"Install-time tips (CLI 2.1.141+)"** section covering the
    `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` env var and plugin
    dependency enforcement on `enable` / `disable`.
  - `.claude/skills/git-worktrees/SKILL.md` — document
    **`worktree.bgIsolation`** and **`worktree.baseRef`**
    settings (CLI 2.1.141+).
  - `.claude/skills/agent-teams/SKILL.md` and
    `.claude/skills/parallel-agents/SKILL.md` — document the new
    `claude agents` flags (`--add-dir`, `--settings`,
    `--mcp-config`, `--plugin-dir`, `--permission-mode`,
    `--model`, `--effort`, …) shipped in CLI 2.1.142, and
    Anthropic's **Agent View** research preview as a
    complementary cross-process session monitor.

- **Commit batch-2 marketplace-audit plan**. `specs/marketplace-audit/batch-2-plan-2026-05-18.md`
  (151 lines, finalized plan for legal + growth audits against
  `anthropics/claude-plugins-official` — narrowed comparator,
  3-bucket verdict matrix, no-rubric, count-drift acknowledged)
  was sitting untracked in the working tree through the entire
  feature burst. Committed for visibility to future sessions.
  Planning artifact; pilots execute in follow-up sessions.

### Fixed

- **Docusaurus broken-link fix for `EXTENDING-GUIDE §8`**.
  `docs/guides/EXTENDING-GUIDE.md` §8 "Author a preset" (shipped
  earlier in this release) introduced 3 relative links
  (`../../specs/presets-vendor-pointer-tier/spec.md`,
  `../../specs/preset-category-prompt/spec.md`,
  `../../specs/presets/roadmap.md`) that the Docusaurus build
  couldn't resolve because `specs/` is not synced to
  `website/docs/`. Added the 3 paths to `LINK_MAP` in
  `website/scripts/sync-docs.ts` to rewrite them to GitHub URLs
  during the doc sync — same pattern as existing
  `../../.claude/presets/` and `../../specs/marketplace-audit/`
  entries. Deploy Documentation workflow on `main` is restored.

- **vite bumped to `^6.4.2` in react-vite-spa fixture**. The
  `tests/presets-fixtures/react-vite-spa/package.json` stub
  declared `"vite": "^5.0.0"`. Bumped to `^6.4.2` (silences
  Dependabot, no exploit surface because the fixture is a
  string-match target only — `npm install` is never executed
  on it). See "Security" below for the underlying CVE detail.

### Security

- **CVE-2026-39365 / GHSA-4w7w-66w2-5vf9** (medium severity, vite
  path-traversal in optimized-deps `.map` handling, range `≤ 6.4.1`,
  patched in `6.4.2`). Fixed by bumping the `react-vite-spa`
  fixture to `^6.4.2`. The fixture is a stub `package.json` used
  only for detect-rule string matching (no `npm install`, no vite
  dev server start) — practical exploit surface is zero, but the
  bump silences Dependabot durably and tracks current versions.

## [1.39.0] - 2026-05-13

Minor release. Ships the 6th maintainer-vouched preset (`react-vite-spa`)
for React Single-Page Apps built on Vite + React Router, anchored on the
maintainer's actual production stack. Bundled with a foundational runtime
extension the preset depends on: support for `keep`-style skills filters
(whitelist), mutually exclusive with the existing `drop`-style filter
(blacklist). The 5 previously shipped presets keep their `drop` form and
are entirely unchanged.

Behaviour-additive across the board, no breaking change. +27 tests
(593 → 620). Spec lives at
[`specs/archive/preset-react-vite-spa/`](./specs/archive/preset-react-vite-spa/).

### Added

- **6th maintainer-vouched preset `react-vite-spa`** — React Single-Page
  Apps built on Vite + React Router. First preset to use the new
  `keep`-style filter (whitelists 47 of 54 foundation skills); drops
  `dev-flutter`, `dev-nextjs`, `ops-mobile-release`, `ops-proxmox`,
  `ops-opnsense`, `ops-infra-code`, `data-pipeline`. Detection rule is
  strict `allOf`: any `vite.config.*` AND `react-router-dom` in
  `package.json` — avoids false positives on Astro / Vue+Vite /
  Svelte+Vite. Bundles ZERO marketplace plugins at v1; ships with 4
  audit-validated `recommendedVendorSkills` entries (vercel-labs +
  frontend-design always; shadcn-ui + lingui conditional). Compatible
  with a Capacitor wrap for mobile distribution. Spec lives at
  [`specs/archive/preset-react-vite-spa/`](./specs/archive/preset-react-vite-spa/).

- **Runtime support for `keep`-style skills filter** in preset manifests
  (`foundation.skills.keep[]`), mutually exclusive with the existing
  `drop[]` form. A preset declaring `keep:` whitelists the listed skills
  during bootstrap and update; every other foundation skill is skipped.
  `validate-presets.sh` enforces the XOR at validation time. The 5
  previously shipped presets (`nextjs`, `astro`, `fastapi`, `cli-tools`,
  `homelab-proxmox`) continue to use `drop` and are unchanged. Spec
  lives at [`specs/archive/preset-react-vite-spa/`](./specs/archive/preset-react-vite-spa/).

## [1.38.0] - 2026-05-10

Minor release. Closes the lifecycle-visibility gap between
`claude-base init` (which prints a curated welcome with vendor-skill
recommendations) and `claude-base update` (which used to be silent).
After `init` produces a project, the foundation now leaves traceable
signals across the entire project lifetime: a foundation-version
marker, a re-printed recommendation list with install-status indicators
and inline install pointers, and visible dry-run conflicts in non-TTY
mode. A new TEAM-GUIDE section documents the scope choices when
`.claude/` is gitignored.

Behaviour-additive across the board — no breaking change. +57 tests
(536 → 593). Spec lives at
[`specs/archive/update-lifecycle-visibility/`](./specs/archive/update-lifecycle-visibility/).

**Foundation version marker** (US-1). Every project now carries a
`.claude/.foundation-version` file with the foundation `VERSION` that
last produced or updated it. `init` writes it on bootstrap, `update`
refreshes it on every successful run (skipped in dry-run), and
`update --version` surfaces it when invoked from inside a project so
you can compare against the foundation's CLI version without parsing
git history.

**Recommendations re-printed at update** (US-2). The active preset's
`recommendedVendorSkills` list, previously shown only by `init`, is
now re-printed at the end of `update` so users discover (and
rediscover) opt-in vendor skills throughout the project lifecycle.
Gated by `--quiet` and skipped when no preset governs the run.

**Install-status indicators** (US-3). Each recommendation item is now
prefixed with `[OK]` (already installed in user-global or project
scope) / `[--]` (not installed) / `[?]` (marketplace plugin handle —
filesystem cannot tell). An inline install pointer follows the URL
line: `claude plugin install <id>` for marketplace handles,
`git clone --depth 1 <url>` for GitHub vendor repos, kept aligned
with [`docs/recipes/recommended-vendor-skills.md`](./docs/recipes/recommended-vendor-skills.md).
Detection is pure filesystem (no network, no Claude CLI invocation),
honoring the foundation's "observe, never install" supply-chain rule.

**Dry-run conflicts in non-TTY** (US-4). `update --dry-run -y` used
to silently warn `X skipped (use --force to overwrite)` and bump a
single `Skipped:` counter for every locally-modified file. CI runners
only saw a number; the actual filenames were buried. The new behavior
collects those files into a "Conflicts requiring decision (N)"
section before the summary, splits the count from `Skipped:`, and
keeps exit code 0 (per the dry-run-is-informational contract).
Interactive TTY runs are byte-identical to before.

**Team setup pattern documented** (US-5). New section in
[`docs/guides/TEAM-GUIDE.md`](./docs/guides/TEAM-GUIDE.md#when-claude-is-gitignored--scope-choices-for-plugins--skills)
covering "When `.claude/` is gitignored": why a team would do that,
what it breaks for project-scope plugins/skills, and which scope
(`user` / `project` / `local`) to use per use case. README entry now
links directly to it.

Spec lives at [`specs/archive/update-lifecycle-visibility/`](./specs/archive/update-lifecycle-visibility/).

## [1.37.0] - 2026-05-09

Minor release. Closes the preset story across three coordinated additions:
**data-driven preset detection** (matching presets surface automatically
when running on an existing project, both inside the interactive type
menu and via the new `--detect-only` audit flag), **per-preset
end-to-end coverage** with a hook drift-guard against the v1.36.1
regression class, and **preset-aware updates** that keep the active
filter coherent across the entire project lifecycle (no more silent
drift back to the unfiltered foundation on `update --all`). Adding a
new preset is now mechanical — a `.json` manifest with a `detect`
block plus a small fixture, no code change required. The README and
`.claude/presets/` docs are updated to surface the new behaviour.

Three specs land alongside the code as the historical record:
- [`specs/presets-detection-and-e2e/`](./specs/presets-detection-and-e2e/) — detection + E2E
- [`specs/presets-update-aware/`](./specs/presets-update-aware/) — preset-aware updates
- [`specs/presets/`](./specs/presets/) — original preset system (v1)

### Added

- **Preset-aware updates.** `claude-base update` (and `scripts/update.sh`)
  now respects the active preset's skill filter so a project bootstrapped
  with `--preset X` no longer drifts back to the unfiltered foundation
  on every `update --all`. The active preset is determined at update
  time by the existing `scan_presets()` library shipped earlier today
  — no new persisted state on disk. Two new flags:
  - `--preset <name>` overrides auto-detection and applies the named
    preset's filter (resolves official then community presets).
  - `--no-preset` disables filtering for this run; behaviour identical
    to today's `update --all` (kept as the explicit opt-out path).
  Mutually exclusive with each other. When two or more presets match
  a project without an explicit override, `update` refuses to proceed
  and instructs the user to disambiguate (no silent precedence).
  When an active preset is set, `update` prints one line:
  `Active preset: <name> (<source>) — skill filter applied`. When no
  preset is active, the output is byte-identical to today's. The
  filter is COPY-only — files already on disk are never deleted, so
  user customizations under a dropped-skill directory survive intact.
  `--dry-run` lists the skills the active preset will skip. See
  `specs/presets-update-aware/spec.md`.

- **Detected presets surface inside the interactive type menu.** When
  `claude-base init` (or `new-project.sh`) runs interactively on an
  existing project, every preset whose `detect` rule matches now
  appears as an additional menu entry placed at the top of the type
  menu — labelled `Use preset: <name>` and visually distinguished
  from the standard 11 type options that follow (renumbered to start
  at N+1, where N is the number of matches). Picking a preset entry
  behaves as if `--preset <name>` had been passed; picking a
  standard type proceeds as today. The information banner that
  previously appeared in interactive mode is removed (it would
  duplicate the new menu entries); the banner is kept in
  non-interactive flows (`-y`, `--simple`) where there is no menu.
  See `specs/presets-detection-and-e2e/spec.md` (US-4).

- **Paired fixture-rule drift-guard.** Every preset that ships a
  `detect` block now ships a paired fixture under
  `tests/presets-fixtures/<preset>/` containing the minimal marker
  files that should match the rule (e.g.
  `tests/presets-fixtures/nextjs/next.config.js` +
  `package.json` with the `next` dependency). A new bats case per
  preset asserts `scan_presets` returns the preset's own name when
  given its fixture. If upstream renames a marker file (e.g. Astro
  changes `astro.config.mjs`), the paired test fails loudly with
  the rule that no longer matches its own fixture. See
  `specs/presets-detection-and-e2e/spec.md` (US-5).

- **`--detect-only` standalone audit mode.** `new-project.sh
  --detect-only PATH` (and `claude-base init --detect-only PATH`)
  scans the target directory against every preset's `detect` rule
  and prints matching preset names to stdout, then exits 0 without
  performing any install. Mutually exclusive with `--preset`
  (an explicit choice makes detection moot). See
  `specs/presets-detection-and-e2e/spec.md` (US-6, P3).

- **Documentation: `detect` block format reference.**
  `.claude/presets/README.md` gains a section describing the
  optional `detect` block schema with two worked examples (Next.js
  files + depFiles, FastAPI depFiles across three Python manifest
  formats), the combinator semantics, the standalone audit usage,
  and a pointer to the paired-fixture drift-guard. See
  `specs/presets-detection-and-e2e/spec.md` (US-7, P3).

- **Data-driven preset detection.** Each preset manifest gains an
  optional `detect` block that self-describes how to recognize its
  target stack: `files` (file names or simple globs) and/or `depFiles`
  (`{path, contains}` pairs), combined via `allOf` or `anyOf`
  (default `anyOf`). When `new-project.sh` runs on an existing
  project, every available preset is evaluated against the directory
  and matching presets are surfaced as an info line — "Detected
  stack — preset matches: nextjs / Try: new-project.sh --preset
  nextjs <path>". Adding a new preset (e.g. `django.json`) now
  requires only a manifest with a `detect` block; no edits to
  `scripts/lib/detection.sh` or to `new-project.sh`. When `--preset`
  is passed explicitly, detection is skipped entirely (the explicit
  user intent wins, no commentary about other matches). The four
  maintainer-vouched presets `nextjs`, `fastapi`, `astro`, and
  `homelab-proxmox` ship with a `detect` block; `cli-tools` stays
  without one (target too generic to detect reliably). See
  `specs/presets-detection-and-e2e/spec.md` (US-1, US-2).

- **Per-preset end-to-end test suite (`tests/preset-e2e.bats`).** For
  each maintainer-vouched preset, `bats` bootstraps a target
  directory via `new-project.sh --preset`, runs `validate.sh -q` and
  `doctor.sh` against it, then asserts every `scripts/hooks/*.sh`
  path referenced by the bootstrapped `settings.json` resolves to
  an existing file in the target tree — drift-guard against the
  v1.36.1 regression class (install completes, hooks point at
  missing files). A self-check test deletes a referenced hook
  post-bootstrap and asserts the helper fires with a precise
  "Missing hooks" message, so the assertion is real and not
  silently passing. The existing `tests/manifest-hooks-coverage.bats`
  guards the source manifest; this new suite guards the
  bootstrapped output, which is what end users actually run. See
  `specs/presets-detection-and-e2e/spec.md` (US-3).

### Changed

- **`scripts/validate-presets.sh` enforces the optional `detect`
  block schema.** Rejects manifests with `combinator` outside
  `{allOf, anyOf}`, with both `files` and `depFiles` empty (a
  detection rule with no signals is meaningless), or with `depFiles`
  entries missing `path` or `contains`.

## [1.36.1] - 2026-05-08

Patch release. Critical fix for `--minimal` installs: the manifest used by
`scripts/export-minimal.sh` only shipped one of the 7 hook scripts referenced
by the source `.claude/settings.json`, leaving fresh minimal installs with
hooks pointing at missing files. A drift-guard bats test now prevents the
same regression from recurring.

### Fixed

- **`--minimal` install ships every hook script referenced by
  `.claude/settings.json`.** Previously the minimal manifest only listed
  `prompt-context.sh`, while `settings.json` referenced 7 distinct
  `scripts/hooks/*.sh` files. Fresh minimal installs ended up with
  hooks pointing at missing files (observed on `claude-i18n-migration`,
  bootstrapped via `--minimal`, where every Bash command silently
  bypassed `command-validator.sh` because the script did not exist on
  disk). Manifest now ships the 6 missing hooks plus the shared
  `_hook-helpers.sh` library sourced by 3 of them.

### Added

- **Drift-guard test (`tests/manifest-hooks-coverage.bats`)**: every
  `scripts/hooks/*.sh` referenced by the source `.claude/settings.json`
  must be listed in `scripts/lib/minimal-manifest.txt`, and the helper
  is shipped whenever a sourcing hook is shipped. Prevents the same
  drift from recurring.

## [1.36.0] - 2026-05-06

Curation + UX release. Two more marketplace audit pilots (qa-* and ops-*)
bring the cumulative coverage to **38 candidates evaluated, 14 vendor
pointers added** across 4 domains. The recommended vendor skills are
now **printed at the end of `claude-base init`**, so users discover
the curated complements at install time rather than having to read the
recipe. The README gains a "Strategy & trajectory" section documenting
the foundation's long-term position alongside the official Claude Code
marketplace, and the `work-flow-release` command doc gains performance
notes that save ~7 minutes per release.

### Changed

- **`work-flow-release` agent: performance notes added** to the command
  documentation. Two practical tips: (1) use `bash scripts/test.sh`
  (parallel, ~1 min) instead of `bats tests/*.bats` (sequential, ~4-5 min)
  — 4.5x speedup on the 455-test suite via GNU parallel + 8 jobs;
  (2) run the test suite ONCE per release, after all doc/version bumps
  are done, since CHANGELOG and version banners cannot break tests by
  construction. Net saving observed on the v1.32–v1.35 releases:
  ~7 minutes per release flow that was lost to slow sequential invocation
  + redundant re-runs.

### Added

- **`recommendedVendorSkills` per preset** (printed at the end of
  `claude-base init`): each preset now ships a curated list of vendor
  skills sourced from the marketplace audit pilots. The list is printed
  at install time, separated into "Always pair with this preset" vs
  "Add if your project uses these tools" (conditional). The user opts
  in manually via the install commands documented in the recipe; the
  foundation does NOT auto-install third-party code. This is **N1** in
  the strategic discussion of automation levels — N2 (interactive
  prompts) and N3 (full auto) are deferred until ≥70% of validated
  vendors migrate to the official Claude Code marketplace (currently
  ~21%, ~3 of 14). 5 new bats tests cover schema validation, Always
  vs conditional separation, and the empty-list case (cli-tools).
  All 5 vouched presets populated.
- **README "Strategy & trajectory" section**: documents claude-base's
  long-term position alongside the official Claude Code marketplace
  (not in opposition to it). Three mechanisms explained: per-domain
  marketplace audits, vendor-neutrality policy, recommended vendor
  skills per preset. Explicit roadmap for re-evaluating automation
  (N2/N3) once marketplace adoption stabilises.
- **Marketplace audit pilot — `ops-*` skills (10 skills)**: fourth audit
  conducted under the methodology in `specs/marketplace-audit/spec.md`.
  Findings: 7 KEEP-OURS (ops-ci, ops-ci-fix, ops-docker, ops-mobile-release,
  ops-opnsense, ops-proxmox, ops-standup), 3 POINT-TO-VENDOR/COMMUNITY:
  `mongodb/agent-skills` for ops-database, `antonbabenko/terraform-skill`
  + `pulumi/agent-skills` for ops-infra-code, `grafana/skills` for
  ops-monitoring. ops-mobile-release HOLDS (Fastlane skill stale + Android
  incomplete; re-evaluate later). ops-ci-fix and ops-standup are
  workflow-specific with no marketplace equivalent — claude-base's
  irreducible value. All 4 sources verified via `gh api`. No vendor
  required CASE-BY-CASE review (no Microsoft/Google ambiguity here).
  Full trace in `specs/marketplace-audit/ops-skills-pilot-2026-05-06.md`.
- **`## See also` sections in 3 ops-* SKILL.md files**: `ops-database`,
  `ops-infra-code`, `ops-monitoring` now point to the validated vendor
  sources. The ops-infra-code attribution footer (already crediting
  antonbabenko) was upgraded to a full `## See also` framing alongside
  the new Pulumi pointer.
- **`docs/recipes/recommended-vendor-skills.md` extended** with 4 new
  vendor entries (MongoDB, antonbabenko/terraform-skill, Pulumi, Grafana).

### Cumulative across 4 audits

- 38 skills/plugins evaluated across 4 domains
- 14 vendor pointers added
- 17 KEEP-OURS verdicts (claude-base skills retained)
- Trend: vendor-published skills accelerating in 2026; claude-base's
  workflow-specific skills (ops-ci-fix, ops-standup, ops-opnsense, etc.)
  remain irreducible value with no marketplace equivalent.

- **Marketplace audit pilot — `qa-*` skills (7 skills)**: third audit
  conducted under the methodology in `specs/marketplace-audit/spec.md`.
  Findings: 1 KEEP-OURS (qa-tech-debt), 1 GAP-OUTSCOPE-POINTER (qa-design),
  5 POINT-TO-VENDOR/COMMUNITY: Anthropic `code-review` plugin (qa-review),
  `addyosmani/web-quality-skills` (qa-perf), `ChromeDevTools/chrome-devtools-mcp`
  (qa-chrome), `agamm/claude-code-owasp` + Semgrep plugin (qa-security),
  `microsoft/playwright-cli` (qa-e2e, accepted under case-by-case
  vendor-neutrality review per the memory rule on Microsoft tools predating
  their OpenAI commercial relationship). All vendors verified via
  `gh api repos/<owner>/<repo>` (existence, maintenance, neutrality).
  QA domain is the strongest vendor-signal of the three audits done so
  far. Full trace in `specs/marketplace-audit/qa-skills-pilot-2026-05-06.md`.
- **`## See also` sections in 5 qa-* SKILL.md files**: `qa-review`,
  `qa-perf`, `qa-chrome`, `qa-security`, `qa-e2e` now point to the
  validated vendor sources. The qa-e2e entry includes an explicit
  vendor-neutrality disclosure for the Microsoft/Playwright case.
- **`docs/recipes/recommended-vendor-skills.md` extended** with the 6
  new qa-domain entries (Anthropic code-review, Addy Osmani web-quality,
  Chrome DevTools MCP, agamm OWASP, Semgrep, Microsoft Playwright with
  case-by-case framing). Recipe "Last verified" date bumped to 2026-05-06.

## [1.35.0] - 2026-05-06

Curation release: a fifth maintainer-vouched preset (`astro`, content/
static-first web), the dev-* marketplace audit pilot identifying 6 vendor
skills worth pointing to (Supabase, Prisma, Apollo, Vercel, shadcn,
Anthropic frontend-design), and a centralised recipe documenting how
to install each validated vendor skill. The kit's surface stays
conservative; the new value is in **better discovery** of canonical
vendor sources alongside the foundation.

### Added

- **Recipe `docs/recipes/recommended-vendor-skills.md`** — actionable
  companion to the marketplace audit pilots. Lists the 6 vendor skills
  validated by the dev-* audit (Supabase, Prisma, Apollo, Vercel,
  shadcn/ui, Anthropic frontend-design), the 2 stack-specific ones
  (Lingui, Callstack RN), the install command per vendor (with
  fallbacks where the install method is not yet stable), and the
  vendors explicitly **rejected** with reasons (Astral on positioning
  grounds, Greptile and pyright-lsp on technical grounds, commit-commands
  on overlap grounds). Re-evaluation triggers documented (vendor
  acquisition, install method change, repo archival, quarterly review).
  Each `## See also` section in the 6 dev-* skills now points to this
  recipe alongside the pilot trace.

### Documentation

- The 6 `## See also` sections in `dev-supabase`, `dev-prisma`,
  `dev-graphql`, `dev-nextjs`, `dev-shadcn`, `dev-frontend-design`
  now cross-link to `docs/recipes/recommended-vendor-skills.md` for
  the actionable install command. The previous version pointed only
  to the pilot trace (analysis); now it also points to the recipe
  (action). No content removed.

- **Marketplace audit pilot — `dev-*` skills (17 skills)**: second audit
  conducted under the methodology in `specs/marketplace-audit/spec.md`,
  applied to all 17 `dev-*` skills. Findings: 9 KEEP-OURS, 6 POINT-TO-VENDOR
  (tool vendors publish their own skill), 2 GAP-OUTSCOPE-POINTER (community
  has narrower or stack-specific coverage). 0 POINT-TO-COMMUNITY — no
  non-vendor community skill cleared the cross-reference bar. Tool vendors
  validated: Supabase (`supabase/agent-skills`), Prisma (`prisma/skills`),
  Apollo GraphQL (`apollographql/skills`), Vercel Labs (`vercel-labs/agent-skills`),
  shadcn/ui (`shadcn-ui/ui/skills/shadcn`, in-repo), Anthropic
  (`anthropics/claude-code/plugins/frontend-design`). All 6 vendors verified
  via `gh api` (existence, maintenance, vendor-neutrality). Outcome:
  documentation-only updates (no skill deletions, no counter changes).
  Full trace in `specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`.
- **`## See also` sections in 6 SKILL.md files**: `dev-supabase`,
  `dev-prisma`, `dev-graphql`, `dev-nextjs`, `dev-shadcn`, `dev-frontend-design`
  now point to the canonical vendor skill alongside our skill. Framing:
  our skill captures **opinionated workflow patterns** (TDD, security
  defaults, foundation conventions); the vendor skill captures the
  **canonical API/stack patterns** that evolve with each vendor release.
  Users get the best of both worlds: install both.
- **Preset `outOfScope` updates**:
  - `nextjs.json` mentions `vercel-labs/agent-skills` (`react-best-practices`)
    for canonical Vercel guidance.
  - `astro.json` mentions `lingui/skills` for Lingui-based content sites.
- **Fifth preset: `astro`** — Astro + TypeScript + Content Collections for
  developers building content-heavy sites: marketing pages, documentation
  sites, blogs, landing pages. First preset for a non-Next.js web framework,
  validating that the preset pattern works for stacks structurally distinct
  from React/Next.js. Astro's islands architecture lets users mix
  React/Vue/Svelte/Solid components selectively, so this preset keeps the
  broader frontend toolkit (`dev-frontend-design`, `dev-shadcn`,
  `dev-react-perf`, `qa-chrome`, `qa-design`, `qa-perf`, `dev-i18n`) and
  only filters out 7 clearly non-applicable skills (mobile, homelab-specific
  ops, the Next.js framework specifically, infra-code, data pipelines).
  Bundles ZERO marketplace plugins at v1 — Astro-specific plugin curation
  will be added incrementally as validated. Default `designStyle: editorial`
  (matches content/marketing/docs aesthetic). See `.claude/presets/astro.json`.
  Catalogue grows to 5 maintainer-vouched presets: nextjs, homelab-proxmox,
  cli-tools, fastapi, astro.

## [1.34.0] - 2026-05-05

Identity and distribution release: the project is renamed `claude-socle` →
`claude-base` for English-language consistency, a unified CLI dispatcher
`bin/claude-base` exposes coherent verbs (`init`, `update`, `validate`,
`preset list/show`, `uninstall`), and a one-liner installer makes
`curl | bash` the recommended install path. The GitHub repo is renamed
at the same time; old URLs continue to redirect automatically.

### Added

- **One-liner install script `install.sh`**: clones the foundation to
  `~/.local/share/claude-base` and symlinks the dispatcher into
  `~/.local/bin/claude-base` so `claude-base init/update/validate/...`
  works from any directory after a single `curl | bash` invocation. The
  script refuses to run as root, never modifies shell rc files (the
  symlink lives in `~/.local/bin`, which most modern distros put on
  `PATH` automatically), and supports `--target`, `--bin`, `--update`,
  `--dry-run`. 14 bats tests in `tests/install.bats` cover help,
  argument validation, dry-run, idempotent re-install detection,
  refusal to overwrite non-git directories, and security disclaimers.
  README "Installation" section reorganised: Option 1 is now the
  one-liner, Option 2 keeps the manual `git clone` path for users who
  prefer to pin a specific version, Option 3 keeps the cp-only
  minimal install.
- **Unified CLI dispatcher `bin/claude-base`**: a thin shell router that
  exposes user-facing verbs (`init`, `update`, `validate`, `preset list`,
  `preset show <name>`, `uninstall`, `version`, `help`) and forwards to
  the existing scripts under `scripts/`. The underlying scripts remain
  callable directly — the dispatcher is purely additive. Adds a coherent
  CLI surface so users no longer need to remember the path to each script.
  17 bats tests in `tests/dispatcher.bats` cover help, version, preset
  list/show, arg forwarding to the four wrapped scripts, and unknown-verb
  error handling. Usage example: `claude-base init --preset fastapi
  ./my-api`. New `preset show NAME` prints the JSON manifest of a preset
  (uses `jq` if available, falls back to `cat`).

### Changed

- **Project renamed `claude-socle` → `claude-base`** for English-language
  consistency with the rest of the codebase (the FR→EN migration in v1.31.0
  left the project name as the only French-coded element). The new name is
  shorter, EN-native, and matches the vocabulary already used throughout the
  documentation. The GitHub repo is renamed at the same time
  (`christopherlouet/claude-socle` → `christopherlouet/claude-base`); old
  URLs continue to redirect via GitHub's automatic 301. Internal renames:
  `SOCLE_DIR` → `BASE_DIR` (bash), `SKIP_SOCLE_INTEGRITY` → `SKIP_BASE_INTEGRITY`
  (env var), `SOCLE_STATS` → `BASE_STATS` (TypeScript constant), files
  `socle-maintenance.md` → `base-maintenance.md`,
  `socle-integrity-check.sh` → `base-integrity-check.sh`,
  `audit-socle.sh` → `audit-base.sh`. Historical CHANGELOG entries
  (v1.32.0 and earlier) keep their original `claude-socle` references —
  those releases were genuinely shipped under the old name.

## [1.33.0] - 2026-05-05

Maintenance and ecosystem release: a 4th maintainer-vouched preset
(`fastapi`), the first marketplace plugin audit pilot under the
methodology in `specs/marketplace-audit/spec.md`, a recipe documenting
three Python toolchain paths, and a new `update.sh --add-plugin` helper
that closes the friction gap for users opting into marketplace plugins.

### Added

- **`update.sh --add-plugin <id>` flag**: idempotent helper that adds
  an entry to `enabledPlugins` in a project's `.claude/settings.json`
  without overwriting other keys. Mirrors the existing `--add-hook`
  pattern. Useful when a user wants to opt into a marketplace plugin
  (e.g. `astral@astral-sh`) and avoid losing the entry if a later
  `update.sh --settings` overwrites the file. 8 bats tests cover the
  helper (idempotent re-run, `--dry-run`, missing settings.json,
  preservation of existing keys).
- **Marketplace plugin audit pilot — `cli-tools` preset**: first audit
  conducted under the methodology in `specs/marketplace-audit/spec.md`,
  using `gh search code` to cross-reference plugin adoption across real-product
  repos (filtering out dotfiles, templates, config kits, portfolios). Four
  candidates evaluated: `pyright-lsp@claude-plugins-official` (rejected —
  active LSP infrastructure bugs), `greptile@claude-plugins-official`
  (rejected — recurrent OAuth bugs), `commit-commands@claude-plugins-official`
  (rejected — overlaps with foundation `/work:work-commit`), and
  `astral@astral-sh` (rejected on positioning grounds). The Astral
  toolchain plugin had strong technical and adoption signal (13+ qualifying
  real-product repos) but was rejected because Astral was acquired by
  OpenAI on 2026-03-19; bundling OpenAI-acquired tooling in an
  Anthropic-ecosystem kit would publish a dissonant signal. Outcome:
  `cli-tools.json` `marketplacePlugins` stays `[]`. Full trace in
  `specs/marketplace-audit/cli-tools-pilot-2026-05-05.md`.
- **Recipe: `docs/recipes/python-toolchain-options.md`**: documents
  three paths for picking a Python toolchain inside `cli-tools` or
  `fastapi` projects — Astral (perf-first, OpenAI-adjacent),
  vendor-neutral (pdm/poetry + flake8/black + mypy), or PyPA defaults
  (pip + venv + flake8 + mypy). Includes opt-in instructions for the
  `astral@astral-sh` plugin and a decision matrix. Aligned with the
  established "stack-essential agnostic, recipes = product opinion"
  doctrine.
- **Fourth preset: `fastapi`** — FastAPI + Pydantic + SQLAlchemy/async ORM
  for developers building HTTP APIs, LLM-backed services, or async data
  ingestion endpoints in Python. Filters out 12 non-applicable skills
  (frontend stacks, mobile, homelab-specific ops, browser-bound QA).
  Keeps `dev-api`, `dev-auth`, `dev-graphql`, `dev-prompt-engineering`
  (LLM API backends), `dev-supabase`, `ops-database`, `ops-docker`,
  `ops-monitoring`, `qa-perf`, `qa-security`. Bundles ZERO marketplace
  plugins at v1 — Python-specific plugin curation will be added
  incrementally as validated. Default `docker: true` (containerised
  deployment is the dominant pattern), `designStyle: editorial`.
  See `.claude/presets/fastapi.json`. With this PR, the maintainer-vouched
  preset catalogue grows to 4: nextjs, homelab-proxmox, cli-tools, fastapi.

## [1.32.0] - 2026-05-05

Headline release: PostToolUse output rewriter (Claude Code 2.1.121+),
preset system with 3 maintainer-vouched presets (nextjs, homelab-proxmox,
cli-tools), and a multi-OS CI matrix that brings macOS to first-class
support after a focused portability sweep.

### Added

- **Third preset: `cli-tools`** — Python or Shell automation tools,
  GitHub API helpers, headless-friendly scripts. Targets developers
  building CLI utilities, dependency analyzers, code-mod tooling, or
  ops automation that runs in CI/cron without a UI. Filters out 13
  app/UI/mobile/infra-heavy skills. Bundles ZERO marketplace plugins
  at v1. Default `designStyle: terminal` (matches headless CLI usage).
  See `.claude/presets/cli-tools.json`. With this PR, the 3
  maintainer-vouched presets in `specs/presets/roadmap.md` pipeline
  are all live.
- **Second preset: `homelab-proxmox`** — Proxmox VE + Terraform + Ansible
  + monitoring (Prometheus/Grafana). Targets sysadmins running
  infrastructure-as-code on a personal or small-team Proxmox cluster.
  Filters out 10 app/UI/mobile-only skills (`dev-flutter`, `dev-shadcn`,
  `dev-nextjs`, `dev-react-perf`, `dev-frontend-design`,
  `ops-mobile-release`, `growth-cro`, `qa-chrome`, `qa-responsive`,
  `qa-design`). Bundles ZERO marketplace plugins at v1 — Terraform-specific
  plugins will be added incrementally as validated. Default
  `designStyle: cockpit` (matches infra/ops aesthetic).
  See `.claude/presets/homelab-proxmox.json`.
- **First preset: `nextjs` + preset system mechanism**: `./scripts/new-project.sh --preset nextjs <path>`
  installs the foundation with stack-specific filters applied. The first concrete
  preset ships alongside the install mechanism (parsing, filtering, plugin install
  capability check). The `nextjs` preset is intentionally minimal at v1: it filters
  out 6 clearly-out-of-stack skills (Flutter, Proxmox, OPNsense, mobile-release,
  infra-code, data-pipeline) and bundles ZERO marketplace plugins. Plugins will
  be added incrementally in follow-up PRs as each one is validated in real
  production use, not assumed from name. See `.claude/presets/nextjs.json`,
  `.claude/presets/README.md`, `specs/presets/spec.md`.
- New `--list-presets` flag to discover available presets with their status tier.
- New `scripts/validate-presets.sh` — jq-based JSON schema check for preset
  manifests. Runs on each preset PR via the existing CI (called by `bash scripts/lint.sh`).
- New tests `tests/presets.bats` (16 tests) covering manifest validation, filter
  behavior on real install, capability fallback, and CLI flag composition.
- New recipe `docs/recipes/saas-monetization.md` — the first opt-in recipe
  documenting subscription/billing patterns for those who need them, kept
  deliberately separate from the `nextjs` preset (preset = stack essentials,
  recipe = product opinion).

### Added (output rewriter)

- **PostToolUse output rewriter (#116)**: three coordinated hooks that
  exploit the new `hookSpecificOutput.updatedToolOutput` envelope
  (Claude Code 2.1.121+) to tighten the feedback loop on foundation-equipped
  projects.
  - `bash-output-filter.sh` (PostToolUse Bash) trims noisy outputs of
    allowlisted package-manager / build / test commands
    (npm/pnpm/yarn/bun install/audit/test/build, pytest, go test/build,
    cargo build/test/check) to actionable lines only. Threshold guard
    skips outputs under 30 lines.
  - `post-edit-typecheck-and-lint.sh` (PostToolUse Edit|Write)
    consolidates the former two inline tsc + eslint blocks into a single
    script that **inlines** type/lint errors mentioning the just-edited
    file into the Edit/Write tool result envelope. Status stays SUCCESS;
    annotations are appended under delimited sections.
  - `check-cli-version.sh` (SessionStart) probes `claude --version` and
    sets a sentinel consumed by the two PostToolUse hooks. On older
    CLIs, prints one notice and falls back silently.
- 12 test fixtures under `tests/hook-output-rewriter/fixtures/`
  (6 Bash, 6 inline-edit) covering the 6 distinct extractor branches.
- 45 new bats tests (`tests/hook-output-rewriter.bats`).
- Hook env vars: `SKIP_BASH_OUTPUT_FILTER`, `SKIP_INLINE_EDIT_ERRORS`,
  `BASH_OUTPUT_FILTER_VERBOSE`, `BASH_OUTPUT_FILTER_THRESHOLD`.
- Metric log at `/tmp/claude-rewriter.log` (one line per rewrite).

### Added (CI / docs)

- **macOS-latest in the CI matrix (#122)**: Bats + ShellCheck + counts
  gate now run on macOS in addition to Ubuntu. The macOS column is
  marked `experimental: true` so portability regressions surface
  without blocking merges. After the portability sweep below, both
  columns pass green at v1.32.0.
- **Native plugin migration status (#117)**: `docs/guides/EXTENDING-GUIDE.md`
  now documents which parts of the foundation could move to native
  Claude Code plugins (CLI 2.1.121+) and the three structural gaps
  that currently block a full port (rules not a plugin component,
  `settings.json` plugin scope, no setup callback). The foundation
  stays standalone; revisit when 2/3 gaps land.

### Fixed (macOS / BSD portability)

A focused sweep so every script works identically on Ubuntu (GNU coreutils)
and macOS (BSD coreutils). Each fix is small in isolation but together
they unblock first-class macOS support.

- `date +%s%N` (GNU-only nanoseconds) replaced with a portable
  `now_ms` helper that prefers `python3`, falls back to `gdate`,
  then `date`, then second-resolution as a last resort (#125).
- `readlink -f` (GNU) replaced with a `realpath` fallback chain
  in `scripts/export-minimal.sh` (#126).
- `sed -i` invocations made portable across BSD (`-i ''`) and GNU
  (`-i`) via a small wrapper in `scripts/lib/common.sh` (#127).
- `grep -P` (Perl regex, GNU-only) replaced with `grep -oE` (POSIX
  ERE) — same semantics for the patterns we use (#128).
- `#!/bin/bash` shebangs replaced with `#!/usr/bin/env bash` so
  Homebrew's bash 5+ is picked up on macOS (Apple ships bash 3.2,
  which lacks features we rely on) (#129).
- `seq 0 -1` guarded for BSD (which counts down) so empty preset
  marketplace plugin arrays don't loop (#129).
- `[[:space:]]` and `($|[^[:alnum:]_])` replace `\s` and `\b` in
  `scan_drift` patterns for BSD grep ERE compatibility (#129).
- `BSD wc -l` whitespace padding stripped via `tr -d '[:space:]'`
  in `validate-counts.sh` count assignments — the silent killer
  of literal string equality on macOS (#129).
- `scripts/new-project.sh --simple --dry-run` no longer exits 1 on
  bash 5+: the `find | wc | tr` pipeline under `set -e` + `pipefail`
  was killing the assignment when the directory didn't exist (#123).

### Changed

- `scripts/new-project.sh`: gains `--preset NAME` and `--list-presets` flags.
  `--preset` composes with existing `--type`, `--ci`, `--hooks`, `--mcp`,
  `--docker`, `--style` flags (preset's defaults apply only when the user
  did not pass the corresponding flag, so user choice always wins).
- `.claude/settings.json`: the two PostToolUse Edit|Write blocks
  "Type-check TypeScript" and "ESLint check" are removed and replaced
  by a single block calling `post-edit-typecheck-and-lint.sh`.
  Behavior parity is preserved when the new feature is disabled
  (`SKIP_INLINE_EDIT_ERRORS=1` falls back to legacy stdout side-messages).
- `scripts/update.sh`: the interactive prompt for `.claude/settings.json`
  now flags this release explicitly and warns when declining.
- `actions/setup-node` bumped from v4 to v6 in `.github/workflows/`
  (Dependabot, #115).

### Notes

- The preset format is **JSON** (not YAML as initially drafted in the planning
  spec). Pivot reason: the codebase has no YAML parser (`yq` is not a hard
  dependency) but `jq` is required by 4+ existing hooks, `update.sh`, and
  `validate-counts.sh`. JSON + jq is consistent with `settings.json`,
  `.mcp.json`, `counts.json`. The choice is documented in `specs/presets/spec.md` § "JSON schema".

### Migration

- **Existing projects**: run `./scripts/update.sh -f --all <project>` to
  get the new hooks coherently. Partial updates
  (e.g. `--hook-scripts` without `--settings`) are detected at runtime
  by `post-edit-typecheck-and-lint.sh` and trigger a one-line notice
  once per session pointing to the correct command.
- **Older CLIs (< 2.1.121)**: the SessionStart probe emits a single
  visible notice on session start and the rewriter hooks remain
  inactive. No upgrade is forced; sessions work as before.

---

## [1.31.2] - 2026-05-03

Maintenance release: anti-drift counter infrastructure now permanent
(counts.json + CI gate), MDX escape pipeline rewritten to fix visible
`&lt;` / `&gt;` text in rendered docs, Welcome page hero counter drift
fixed.

### Added

- **Single source of truth for counters (#110)**: new `counts.json` at
  the repo root, generated by `website/scripts/generate-counts.ts` from
  filesystem scans. Schema covers commands, agents, skills, rules, tests,
  testFiles and per-domain command subtotals (work/dev/qa/ops/...).
- **CI gate against counter drift (#110)**: `.github/workflows/ci.yml`
  runs `npm --prefix website run generate && git diff --exit-code` on
  every PR. Adding/removing a `.claude/{commands,agents,skills,rules}/`
  file without re-running the generator now fails CI.
- **Markdown count markers (#110)**: 18 instrumented `.md` files use
  `<!-- count:KEY -->NNN<!-- /count -->` markers updated by a new
  `inject-counts-md.ts` step. The shields.io tests badge in `README.md`
  is also auto-rewritten.
- **`escape-mdx-content.ts` shared helper (#111)** with 14 unit tests
  via `node:test`/`tsx`. Replaces 3 duplicated copies of the
  fenced-only escape function.

### Fixed

- **Welcome page hero counter drift (#109)**: `Stats.tsx` had been
  showing 123/59/42/24 for multiple versions while the real counts are
  131/63/54/30. `validate-counts.sh` did not include the file.
- **Same drift in `what-is-claude-code.md` (#110)**: the 4-row component
  table said 126/62/44/25. All four cells fixed and instrumented.
- **MDX escape leaking into inline code spans (#111)**:
  `` `<arguments>` `` was being HTML-encoded to `` `&lt;arguments&gt;` ``
  in 158 generated files. Cause: the regex only skipped fenced code
  blocks, not inline backticks.
- **Markdown blockquotes broken by over-escaped `>` (#111)**: every
  `> quoted text` line in `PROMPTING-GUIDE`, `TEAM-GUIDE`,
  `EXTENDING-GUIDE` and rules descriptions rendered as plain
  paragraphs starting with `&gt;`. `escapeMdx` now only escapes what
  is genuinely JSX-dangerous (`{`, `}`, `<`).
- **Pre-encoded HTML entities double-escaped**: `&lt;` was becoming
  `&amp;lt;` (rendered literally). Dropped the `&` escape from
  `escapeMdx`.

### Changed

- **Workflow phrasing aligned on canonical 6-step (#110)**: 4 work
  commands (`work-explore`, `work-plan`, `work-commit`, `work-specify`),
  `.claude/rules/workflow.md` (full restructure with new
  `### 2. SPECIFY` section, renumbered 3-6), `.claude/rules/README.md`
  and 2 tutorials now reflect Explore → (Brainstorm) → Specify → Plan
  → TDD → Audit → Commit.
- **`sync-docs.ts` now preserves count markers and inline-code regions**
  when copying `docs/` → `website/docs/`.
- **CI workflow stale "Bats: 258 tests" string** replaced with
  "see job logs for the test count" (no maintenance needed).
- **Validate-counts.sh pruned of redundant Layer 1 checks** (-69 lines)
  now covered by the CI gate. Layer 2 narrative scan extended with
  two new patterns (`Label (N available)`, multi-column table cell).
- **GitHub repo description updated** to `130+/60+/50+` fuzzy form +
  homepage URL added pointing to the Docusaurus site.

---

## [1.31.1] - 2026-05-03

Hardening release: 5 CodeQL alerts closed, Docusaurus URLs cleaned up,
canonical 6-step workflow now reflected in onboarding pages and tutorials.

### Fixed

- **Documentation cohesion (#107)**: 6 onboarding/tutorial pages still showed the legacy 4-step workflow (Explore → Plan → Code → Commit). They now reflect the canonical 6-step workflow documented in `CLAUDE.md`: Explore → **Specify** → Plan → TDD → **Audit** → Commit. Pages updated: `intro/quick-start.md`, `workflow/explore-plan-code-commit.md`, `guides/migration.md`, `tutorials/01-first-project.md`, `tutorials/02-feature-react.md`, `tutorials/03-api-rest-node.md`. Promoted `qa-review` / `qa-security` references to the canonical `qa-loop "score 90"`.
- 6 auto-regenerated MDX-escape touch-ups in `website/docs/{commands,concepts,reference,rules}/` produced by `website/scripts/generate-*.ts` after the `escapeMdx` fix.

### Changed

- **3 French-named tutorial files renamed to English (#107)**: leftover from the FR→EN migration shipped in v1.31.0. `01-premier-projet.md` → `01-first-project.md`, `05-audit-securite.md` → `05-security-audit.md`, `10-projet-complet.md` → `10-complete-project.md`. Old URLs (`/docs/tutorials/premier-projet`, etc.) preserved via a new `@docusaurus/plugin-client-redirects` configuration — no broken external links.
- **CI workflow rename (#105)**: `.github/workflows/codeql.yml` → `security.yml`. The file ran ShellCheck + Gitleaks but never CodeQL (Default Setup runs separately). Filename now matches what the workflow does. README badge URL updated.

### Security

- **5 CodeQL alerts closed (#106)**:
  - **HIGH (3)** in `website/scripts/utils/parse-frontmatter.ts`:
    - `escapeMdx()` was missing `&` and `\` escaping. An input like `&lt;script&gt;` would survive untouched and render as `<script>` in MDX, enabling XSS via frontmatter-injected content. Fixed escape order: `&` → `\\` → `\{}` → `<>` so already-encoded entities stay literal and braces don't get ambiguous backslashes.
    - `serializeFrontmatter()` did not escape `\` before `"`. Input `foo\bar` produced invalid YAML; input `"; key: x` could break out of the quoted scalar.
  - **MEDIUM (2)** in `.github/workflows/{ci,pr-check}.yml`: missing explicit `permissions:` block, jobs ran with the default `GITHUB_TOKEN` scope (read+write across contents/issues/PRs). Added least-privilege blocks (`contents: read` on `ci.yml`, `contents: read` + `pull-requests: read` on `pr-check.yml`).
- **GitHub CodeQL Default Setup enabled** for TypeScript files in `website/`. Documented in README "Security measures" section.

---

## [1.31.0] - 2026-05-03

### Added

#### Migration FR→EN (2026-04-30 → 2026-05-03)
- **Full repository localization to English**: 537 files translated across 8 sequential tiers (~285k words). The project's primary language is now English, opening the door to international contributors.
- Tier breakdown: Tier 1 (44 showcase + rules), Tier 2 (194 agents + commands), Tier 3 (96 skills + hooks), Tier 4 (77 website Docusaurus), Tier 5 (51 user templates + Terraform + missed markdown), Tier 6 (49 scripts + tests + CI + ROOT misc), Tier 7 (13 final missed), Tier 8 (13 settings.json + Docusaurus generators).
- 29 auto-generated docs in `website/docs/{commands,agents,skills,rules}/` regenerated in EN via `npm run generate`.
- 7 files intentionally remain bilingual: `scripts/hooks/prompt-context.sh` (FR/EN feedback detection), `scripts/update.sh` (legacy FR section detection in user CLAUDE.md cleanup), 5 `.bats` tests with bilingual output assertions.
- CHANGELOG: header in EN with transition note; entries before v1.31.0 preserved in original FR as project history.

#### Sync Claude Code March-April 2026
- **Monitor Tool docs** (CLI 2.1.98+): new section in `docs/reference/advanced-features.md` describing the native tool that streams background events into the conversation. Use cases: tail logs, babysit CI, watch dev server. Recommended pairing with `/loop` auto-pace.
- **`/autofix-pr` docs** (CLI 2.1.92+): dedicated section in `advanced-features.md` + entry in the Recommended Workflows table of `CLAUDE.md`. Enables PR auto-fix on Claude Code Web from the terminal for the current branch.
- **March-April 2026 regression note** in `TROUBLESHOOTING-GUIDE.md`: default `medium` effort + broken thinking caching + 25-word system prompt, resolved in v2.1.101 on April 10.

### Fixed

- **`scripts/update.sh` finally syncs `scripts/hooks/`**: the scripts referenced by `settings.json` (`command-validator.sh`, `prompt-context.sh`, `setup-deps.sh`, `socle-integrity-check.sh`) were previously missing after `update.sh --all` because the sync function ignored this directory. Result: `settings.json` pointed to non-existent scripts and the SessionStart/PreToolUse hooks failed silently. New `--hook-scripts` flag (included in `--all`), with idempotency, preservation of customizations and automatic `chmod +x`.
- README test layout counter: 23 files → 17 files (post-extraction of `tests/migration/`).

### Removed

- **`scripts/themes/`**: 25 files of out-of-mission terminal aliases (eza/ls colored aliases, gnome-terminal/starship installers). Preserved in git history if needed: `git log --all -- scripts/themes/`.
- **`scripts/migration/`, `tests/migration/`, `specs/migration-fr-en/`, `docs/guides/MIGRATION-GUIDE.md`**: the FR→EN translation harness extracted to a standalone repository: [christopherlouet/claude-i18n-migration](https://github.com/christopherlouet/claude-i18n-migration). Battle-tested on this very migration, with multi-language roadmap (v1.0 FR→EN → v3.0 multi-target parallel).

---

## [1.30.0] - 2026-04-28

### **BREAKING CHANGE — relocalisation de la doc socle vers `.claude/docs/`**

Avant cette version, `new-project.sh --simple` et `update.sh --upgrade-claude-md` copiaient la documentation du socle (`docs/reference/`, `docs/guides/`, `docs/ARCHITECTURE.md`, `docs/WORKFLOWS.md`) directement dans le dossier `docs/` du projet utilisateur. Cela posait deux problemes :

1. **Collisions** : tout projet ayant son propre `docs/ARCHITECTURE.md` (ex : un projet d'infra avec un schema Mermaid) le voyait ecrase pendant l'install/update.
2. **Pollution** : la doc du socle se melangeait a la doc du projet, sans marqueur clair de propriete.

A partir de v1.30.0, la doc socle est installee sous `.claude/docs/` (territoire du socle), et le `docs/` du projet utilisateur n'est plus jamais touche.

#### Modifie

- `new-project.sh --simple` et `--minimal` placent desormais la doc socle sous `.claude/docs/reference/` et `.claude/docs/guides/`. Le dossier `docs/` du projet n'est plus cree ni modifie.
- `new-project.sh` ne copie plus `docs/ARCHITECTURE.md` ni `docs/WORKFLOWS.md` (meta-docs sur le socle, accessibles via le repo GitHub et le website Docusaurus).
- `update.sh` detecte automatiquement les installs legacy (`docs/reference/` + `@docs/reference/...` dans `CLAUDE.md`) et les migre vers `.claude/docs/`. Les guides modifies localement par l'utilisateur sont preserves. Backup `CLAUDE.md.backup.*` cree avant migration.
- `update.sh --upgrade-claude-md` reecrit les `@imports` de `@docs/reference/...` vers `@.claude/docs/reference/...` et ecrit toujours sous `.claude/docs/`.
- `CLAUDE.md` genere pour les utilisateurs : `@imports` et tables de reference pointent desormais vers `.claude/docs/...`.
- `scripts/lib/minimal-claude-md.template` et `scripts/lib/minimal-manifest.txt` alignes sur le nouveau layout.
- Helper `rewrite_claude_md_paths()` ajoute a `scripts/lib/common.sh` (DRY entre `new-project.sh` et `update.sh`).

#### Migration

**Automatique** : `./scripts/update.sh --upgrade-claude-md /chemin/vers/projet` migre l'install legacy vers le nouveau layout. Idempotent : executable plusieurs fois sans casser.

**Manuelle** : la procedure pas-a-pas detaillee n'est plus distribuee dans le repo (le guide `MIGRATION-v1.30.md` a ete retire avant la release publique). Si vous avez besoin du diff exact, consultez les notes de la release v1.30.0 sur GitHub ou l'historique de ce CHANGELOG.

#### Precisions techniques

- Le **repo socle** (ce repo) conserve `docs/` comme source de verite — coherent avec le website Docusaurus et la doc historique (`CHEATSHEET.md`, `GUIDE.md`, etc.). La migration ne concerne que les **projets utilisateurs**.
- La rule `socle-maintenance.md` n'est pas modifiee : ses chemins `docs/reference/...` parlent du repo socle, pas des projets utilisateurs.

---

## [1.29.0] - 2026-04-20

### Ajoute

#### Nouveaux skills (47 → 53)
- **Skill `dev-prisma`** : Prisma ORM (schema, migrations dev/prod, queries type-safe, transactions, N+1 detection, cursor pagination, Accelerate cache, singleton HMR-safe). Complete l'agent `dev-prisma` existant par un skill proactif auto-declenche sur `schema.prisma` (#77)
- **Skill `dev-i18n`** : internationalisation web et mobile (next-intl, react-i18next, vue-i18n, formatjs, flutter_localizations ARB). Pluriels ICU, format date/nombre, extraction strings, RTL, SEO multi-langue. Gap majeur : aucune couverture i18n auparavant (#77)
- **Skill `dev-frontend-design`** : design UI distinctif avec direction artistique forte. Bannit les fonts overused (Inter, Roboto, Arial, Space Grotesk) et force un choix de direction (terminal, cockpit, vitality, editorial, glass, signal) avant de coder. Inspire du skill Anthropic #1 (305K installs sur skills.sh)
- **Skill `dev-shadcn`** : integration et customisation de shadcn/ui (composants Radix + Tailwind copy-paste). Install, theming via CSS variables, dark mode, patterns de customisation, pieges courants (cn, FormField, DialogTitle)
- **Skill `dev-nextjs`** : developpement Next.js App Router (Server Components, Server Actions, Route Handlers, caching, streaming, middleware, Metadata API). Complete la rule passive `nextjs` par un skill proactif
- **Skill `dev-auth`** : implementation auth web moderne (better-auth, Lucia v3, NextAuth/Auth.js, Clerk, Supabase Auth). Sessions cookie vs JWT, password hashing argon2id, OAuth, 2FA, RBAC/ABAC, pieges de securite OWASP

#### Nouvelles rules (26 → 29)
- **Rule `vue.md`** : Composition API (`<script setup>`), composables avec prefixe `use`, Pinia pour state management (Vuex deprecated), Nuxt 3+ (`useFetch`, `useState`, `navigateTo`, `server/api/`), anti-patterns (Options API, `watch` pour derivations, Vuex) (#80)
- **Rule `svelte.md`** : Svelte 5 runes (`$state`, `$derived`, `$effect`, `$props`), table de migration Svelte 4 → 5, SvelteKit (`+page.server.ts`, form actions, load functions), callback props > `createEventDispatcher`, `{@render children?.()}` > `<slot />` (#80)
- **Rule `astro.md`** : Islands Architecture (zero JS par defaut), client directives (`client:visible` par defaut), Content Collections avec validation Zod type-safe, modes rendering (static / hybrid / server), View Transitions (Astro 3+) (#80)

#### Nouveaux hooks (14 → 17 events configures)
- **Hook `PermissionDenied`** (CLI 2.1.111+) : log les permissions refusees par l'auto mode classifier dans `/tmp/claude-permissions.log`. Utile pour tuner les allowlists avec `/less-permission-prompts` (#79)
- **Hook `UserPromptSubmit`** : log les timestamps de submission de prompt dans `/tmp/claude-prompts.log`. Fondation pour un futur `/socle:stats` (#79)
- **Hook `PostToolUseFailure`** : log les echecs d'outils avec leur nom dans `/tmp/claude-failures.log`. Complete `PostToolUse` pour une observabilite complete des tool calls (#79)

#### Happy Path par defaut (routing semantique) (#83)
- **Hook `prompt-context.sh`** (`scripts/hooks/`) : injecte automatiquement branche, fichiers modifies, LOC diff, memoire perso et hint `/assistant-auto` pour chaque prompt libre sans slash command. Desactivable avec `SKIP_PROMPT_CONTEXT=1`
- **Rewrite `assistant-auto`** : passe d'un mapping lexical de 112 lignes (table de 80 lignes a maintenir) a 78 lignes en routing semantique a partir de l'intention + du contexte injecte. Regles de priorite explicites (securite > memoire > taille > specifique)
- **Section "Happy Path par Defaut"** dans `CLAUDE.md` + mise a jour `docs/reference/hooks-reference.md`
- **12 bats tests** pour `prompt-context.sh` (contrat de sortie, contenu, robustesse hors repo git)

#### Tooling
- **`scripts/audit-socle.sh`** : audit de la sante du socle (frontmatter skills/agents, rules registration dans README, liens doc relatifs, counts via `validate-counts.sh`) (#81)
- **Template `CLAUDE.nextjs.md`** : dedie Next.js App Router (Server Components, Server Actions, data fetching Next 15+, Route Handlers, stack 2026 Prisma/better-auth/shadcn/next-intl/Zod). Distinct du generique `CLAUDE.react.md` (#81)
- **Workflow `dependabot-auto-merge`** : auto-merge des patches de securite et minor GitHub Actions, comment sur les major updates

#### Sync Claude Code 2.1.109 → 2.1.114 (#85)
- **3 hook events documentes** dans `docs/reference/hooks-reference.md` : `StopFailure` (CLI 2.1.78+, turn termine sur erreur API), `TaskCreated` (CLI 2.1.84+), `WorktreeCreate` (CLI 2.1.84+, hook `http` retournant `worktreePath`)
- **Settings avances** : `sandbox.network.deniedDomains` (2.1.113), `sandbox.failIfUnavailable` (2.1.83), `modelOverrides` (2.1.84, ARNs Bedrock custom), `autoScrollEnabled` (2.1.110), `showThinkingSummaries` (defaut `false` desormais), `disableDeepLinkRegistration` (2.1.83), `feedbackSurveyRate` (2.1.76), `forceRemoteSettingsRefresh` (policy), theme `"Auto (match terminal)"` (2.1.111)
- **Variables d'environnement** : `CLAUDE_CODE_USE_POWERSHELL_TOOL` (2.1.111), `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` (2.1.108), `CLAUDE_CODE_PERFORCE_MODE` (2.1.98), `CLAUDE_STREAM_IDLE_TIMEOUT_MS` (2.1.84), `OTEL_LOG_RAW_API_BODIES` (2.1.113)
- **MCP evolutions** : OAuth RFC 9728 Protected Resource Metadata (2.1.85), step-up authorization via `403 insufficient_scope` (2.1.84), override `_meta["anthropic/maxResultSizeChars"]` jusqu'a 500K (2.1.84)
- **Fiabilite subagents** (2.1.113+) : hang > 10 min echoue avec erreur claire, worktrees isoles avec Read/Edit sur leur propre worktree, fix crash dialog permission teammate (2.1.114)
- **`/loop` Esc** annule les wakeups en attente (2.1.113)
- **Guide d'extension** : note sur l'unification `.claude/skills/` ↔ `.claude/commands/` (skills recommandes pour nouveaux workflows)

### Modifie
- **Compteur skills** : 47 → 53 dans `docs/reference/skills-catalog.md`
- **Compteur rules** : 26 → 29 dans `.claude/rules/README.md`
- **Compteur hooks events** : 14 → 17 events configures dans `.claude/settings.json`
- **Docusaurus** : upgrade 3.9.2 → 3.10.0 avec override `serialize-javascript@^7.0.5` (#76)
- **Refactor `ops-proxmox/SKILL.md`** : 650 → 215 lignes + 4 references (`terraform-modules.md` 303L, `cloud-init.md` 65L, `backup-ha.md` 85L, `troubleshooting.md` 151L). Pattern identique a `ops-infra-code` (#82)
- **`generate-skill-docs.ts`** : reecriture des liens `references/*.md` en URLs GitHub absolues pour le build Docusaurus (#82)
- **`docs/guides/TROUBLESHOOTING-GUIDE.md`** : 3 entrees ajoutees (migration CLI binaire natif 2.1.113, subagent hang > 10 min, crash dialog permission teammate)

### Corrige
- **`command-validator.sh`** : utilise `CLAUDE_PROJECT_DIR` au lieu d'un chemin relatif fragile (#78)

### Securite
- **29 vulnerabilites resolues** (12 high, 16 medium, 1 low) — toutes dans les transitives webpack de Docusaurus : RCE GHSA-5c6j-r48x-rmvq (`serialize-javascript`) + DoS GHSA-qj8w-gfj5-8c6v (#76)
- **Bash hardening documente** (CLI 2.1.113) dans `.claude/rules/security.md` : paths `/private/{etc,var,tmp,home}` traites dangereux, deny rules resistent aux wrappers `env`/`sudo`/`watch`/`ionice`/`setsid`, `Bash(find:*)` n'auto-approuve plus `-exec`/`-delete`, UI-spoofing fix sur commentaires multilignes. Exemple de `permissions.sandbox` documente (#85)

---

## [1.28.0] - 2026-04-17

### Ajoute

#### Synchronisation Claude Code (Q1 + Apr 2026)
- **Opus 4.7 + effort `xhigh`** : nouveau modele et niveau de raisonnement maximum (best-practices.md, advanced-features.md, TEAM-GUIDE.md) (#70, #71)
- **Routines** : workflows automatises cloud (prompts + repos + connecteurs sur schedule, API ou GitHub events) (#70)
- **`/ultraplan` et `/ultrareview`** : commandes cloud multi-agents pour plan et review (#70)
- **`/recap`** : resume de session (decisions, fichiers modifies, etat du travail) (#70)
- **`/undo`** : alias de `/rewind` (CLI 2.1.108+) (#70)
- **`/less-permission-prompts`** : scan de transcripts pour optimiser les allowlists (#70)
- **`/team-onboarding`** : generation automatique de guide d'onboarding teammate (#70)
- **`/proactive`** : alias de `/loop` avec auto-pacing (#70)
- **TUI Fullscreen enrichi** : 3 benefices cles (flicker-free, memoire constante, support souris), raccourcis clavier, `CLAUDE_CODE_DISABLE_MOUSE`, `CLAUDE_CODE_SCROLL_SPEED`, compatibilite tmux (#70, #71)
- **Prompt Caching 1h** : `ENABLE_PROMPT_CACHING_1H` et `FORCE_PROMPT_CACHING_5M` (CLI 2.1.108+) (#70)
- **Push Notifications** : notifications mobile via Remote Control (#70)
- **Hook `additionalContext`** : propriete PreToolUse pour enrichir le contexte (CLI 2.1.110+) (#70)
- **Sync Q1 2026** : adaptive thinking, Fast Mode, MCP Channels, `/rewind`, context compaction (#58)

#### Nouvelles rules
- **Rule `design-style`** : 6 directions artistiques (terminal, cockpit, vitality, editorial, glass, signal) (#66)
- **Rule `service-worker`** : NEVER cache HTML navigations, bump cache version (8fbfb4e)
- **Rule `performance`** enrichie avec patterns.dev 2026 (#69)
- **Rule `react`** enrichie avec patterns.dev 2026 (#69)
- **Rule `nextjs`** : RSC, data fetching, caching, App Router (#05f05ee)

#### Nouveaux skills et enrichissements
- **Skill `work-brainstorm`** : ideation structuree avant specification (#68)
- **Skill `ops-standup`** : briefing matinal cross-repo (#68)
- **Skill `ops-ci-fix`** : diagnostic et reparation autonome pipelines CI/CD (#68)
- **Skill `dev-tdd` enrichi** : cycle Red-Green-Refactor detaille avec exemples (#68)
- **Audit step adaptatif** : phase Audit apres TDD avec `/qa:qa-loop "score 90"` (#4bcdc07)
- **Command validator** : 8 categories de risque bloquees (#05f05ee)
- **Workflows quick/batch** : `/work:work-quick`, `/work:work-batch "prd.json"` (#05f05ee)
- **Cost tracking** : `/ops:ops-cost` pour suivi tokens et couts (#05f05ee)

#### Documentation et site Docusaurus
- **6 nouveaux guides** : Python, Go, Auth, Testing, Database, Observability (#64)
- **Guide Claude Code Training** : prerequis au socle pour debutants (#62)
- **Learning path novice → pro** : 2259 lignes (#17791bb)
- **Capstone project TaskFlow** : SaaS end-to-end (#63)
- **Docusaurus UX debutant → avance** : navigation enrichie (#61)
- **Training guide** comme prerequis (#62)
- **Website auto-sync** : `docs/` → `website/docs/` via `sync-docs.ts` (#59, #6a08f35, #72)
- **Examples dans navbar** + anchor fixes (#3a3dcf2)
- **7 pages manquantes regenerees** : ops-ci-fix, ops-standup, work-brainstorm, design-style, etc. (#72)

#### Scripts
- **`check-updates.sh`** : verification des mises a jour CLI et skills (#8856834)
- **`new-project.sh` modularise** : lib/ modules pour faciliter la maintenance (#dea4169)
- **`bump-version.sh`** : mise a jour centralisee de la version dans tous les fichiers

### Modifie
- **Modeles** : references Opus 4.6 → Opus 4.7 dans toute la documentation (22 occurrences)
- **Effort levels** : ajout de `xhigh` dans tous les tableaux
- **Gestion du contexte** : `/recap` et `/undo` dans workflow.md
- **Variables d'env** : `ENABLE_PROMPT_CACHING_1H`, `FORCE_PROMPT_CACHING_5M`, `CLAUDE_CODE_DISABLE_MOUSE`, `CLAUDE_CODE_SCROLL_SPEED`
- **Fast Mode** : documente comme "meme modele Opus 4.7, sortie 2.5x plus rapide"

### Corrige
- **Compteurs stales** : documentation mise a jour (126 commands, 62 agents, 44 skills) (#b2f6195, #9b1846f, #a09ab36)
- **Broken anchor** website (#3a3dcf2)
- **Shellcheck** cross-file global variables (#4fe2f4c)

### Chore
- **Archive des specs implementees** : a11y, check-updates, sync-q1-v2, docs-update-v1.25 (#d7fc33d, #32cedf9)
- **Bump GitHub Actions** (#67)

---

## [1.27.0] - 2026-03-19

### Ajoute
- **Agent `qa-loop`** : boucle autonome audit → fix → test → re-audit avec criteres d'arret (score cible, max iterations, detection regression) (#46)
- **Agent `ops-deploy`** : deploiement securise avec checklist pre-deploy, post-deploy health checks et commande de rollback (#46)
- **Rule `research`** : verifier les capacites natives du framework avant d'implementer une solution custom (#46)
- **Rule `deploy-safety`** : checklist pre-deploiement (env vars, cookies secure, CSP, migrations DB, logs Docker) (#46)
- **Rule `migration-safety`** : checklist migration de framework avec table des pieges courants et caches a vider (#46)
- **Hook pre-push CI** : lint + type-check + tests avant chaque push, supporte Node.js/Python/Go (desactivable avec `SKIP_PRE_PUSH_CI=1`) (#46)
- **Hook destructive ops guard** : bloque DELETE/DROP/TRUNCATE/rm sur donnees sans confirmation (desactivable avec `SKIP_DESTRUCTIVE_CHECK=1`) (#46)
- **Gate operations destructives** : workflow dry-run obligatoire dans verification.md (compter → echantillonner → confirmer → backup → executer) (#46)
- **CI baseline check** : etape 0 dans workflow.md pour distinguer erreurs CI pre-existantes des nouvelles (#46)
- **Scope guard** : guidance dans workflow.md pour decouper les sessions trop ambitieuses (15+ taches = regressions) (#46)
- **7 pages Docusaurus** : qa-loop, ops-deploy, research, deploy-safety, migration-safety (commands + agents + rules) (#46)

### Modifie
- **`update.sh` securise** : `update_directory()` utilise le diff par fichier au lieu de `cp -r` aveugle, protege docs projet (ARCHITECTURE.md, WORKFLOWS.md, guides/) (#46)
- **Hook pre-commit ameliore** : detecte Husky non installe et tente reparation auto, supporte Python (pytest) et Go (go test) (#46)
- **Agent `ops-docker`** : enrichi avec checklist pre-deploiement et directives logs Docker (#46)
- **Skill `parallel-agents`** : prevention des conflits de fichiers inter-agents avec carte des fichiers et file-locking (#46)
- **CLAUDE.md** : ajout workflows `qa-loop` et `ops-deploy` dans le tableau recommande (#46)
- **Compteurs mis a jour** : 123 commands, 59 agents, 42 skills, 24 rules dans toute la documentation (#46)

### Corrige
- **ShellCheck SC2034** : variable `total` inutilisee supprimee dans update.sh (#46)
- **Husky templates** : restaures comme templates pour new-project.sh (supprimes par erreur) (#46)
- **Compteurs stales** : 27+ fichiers avec anciens compteurs (120/121 commands, 37/57 agents, 41 skills, 21 rules) corriges (#46)

### Securite
- **Pre-push CI hook** : empeche de pousser du code qui ne passe pas lint/typecheck/tests (#46)
- **Destructive ops guard** : empeche les suppressions en masse de donnees sans confirmation (#46)
- **Deploy safety rule** : empeche le deploiement de configs dev en production (#46)

---

### Refactore
- **Renommage `qa-a11y` → `wcag-audit`** : agent, commande et documentation renommes dans tout le codebase (#45)

### Ajoute (accessibilite)
- **Rule `accessibility` enrichie** : 100+ regles inspirees d'axe-core, audit WCAG 2.1 AA complet (#45)

### Modifie (dependances)
- **`bats-core/bats-action`** : 3.0.1 → 4.0.0 (#28)

### Modifie (hooks)
- **RTK desactive par defaut** : necessite `ENABLE_RTK=1` pour activer (#44)
- **`update.sh --add-hook rtk`** : ajout de hooks sans ecraser settings.json (#42)
- **RTK token optimizer** : integration optionnelle, -60-90% tokens (#41)

### Corrige
- **ShellCheck warnings** : corrections dans update.sh (#43)

## [1.26.0] - 2026-03-14

### Ajoute
- **Sync CLI 2.1.76** : 6 nouveaux hooks (PostCompact, TeammateIdle, TaskCompleted, InstructionsLoaded, Elicitation, ElicitationResult) avec mode async (#30)
- **Securite hooks/MCP** : hooks SessionStart pour verification .env/.gitignore et warning hooks tiers (#30)
- **Documentation CLI 2.1.76** : memoire automatique, /effort levels, --name sessions nommees, VSCode URI handler (#37)
- **3 guides domaine** : INFRA-GUIDE.md (30 ops), BIZ-GUIDE.md (11 biz), GROWTH-GUIDE.md (11 growth) (#34)
- **2 output styles** : debug (Error/RootCause/Evidence/Fix) et metrics (numbers-first, trend arrows) (#34)
- **15 exemples skills** : ops-ci, ops-docker, ops-monitoring, ops-database, dev-supabase, dev-flutter, dev-graphql, dev-refactor, dev-error-handling, qa-perf, qa-tech-debt, qa-design, data-pipeline, doc-generate, growth-cro (#36)
- **Script generate-commands-doc.sh** : generation automatique de docs/reference/commands.md avec --output et --check (#34)
- **.mcp.env.example** : documentation des variables d'environnement MCP (#33)
- **Rule precedence** : matrice de priorite des rules dans rules/README.md (security > verification > tdd > language > framework) (#33)
- **Gate Function** : enrichissement de la rule verification avec 5 etapes obligatoires et Red Flags (#31)
- **Documentation** : sections async hooks, HTTP hooks, worktree.sparsePaths, Claude Code Security, MCP Elicitation dans advanced-features.md (#30)

### Modifie
- **Commands trimmes -85%** : 121 commandes de 41,527 a 6,116 lignes (avg 343 → 50 lignes/fichier), skills comme source de verite (#34, #35)
- **Agents trimmes -61%** : 57 agents de 7,079 a 2,784 lignes (avg 124 → 48 lignes/fichier), 0 agents > 80 lignes (#36)
- **Scripts securises** : fix injection commande dans new-project.sh (node -e, sed), safe_mktemp dans update.sh, fix awk injection (#38)
- **Scripts refactores** : detect_stack() decoupe en 8 sous-fonctions, update_directory() remplace 5 fonctions identiques, main() data-driven (#38)
- **Modeles agents** : biz-mvp, biz-competitor, biz-personas, growth-seo, doc-generate passes de haiku a sonnet (#33)
- **Hooks logging en async** : SessionEnd, PreCompact, SubagentStop, Notification passes en mode non-bloquant (#30)
- **VERSION dynamique** : new-project.sh et update.sh lisent VERSION depuis le fichier (#38, #39)
- **Compteurs dynamiques** : new-project.sh utilise find au lieu de comptes hardcodes (#33)
- **Commandes namespace** : toutes les references utilisent /category:command au lieu de /category-command (#39)

### Corrige
- **2 tests en echec** : smoke test CLAUDE.md > 100 lignes (ajuste a 30), update.sh @imports skip detection (#32)
- **detect_database()** : utilise find -exec au lieu de xargs fragile (#39)
- **copy_socle_dir()** : protection contre les repertoires vides (glob safety) (#39)
- **generate_smart_claude_md** : extraction test tools reecrite (etait pipe casse) (#39)

### Supprime
- **4 specs archivees** : agent-teams, opnsense-iac, doc-improvements, claude-code-sync-2026 deplaces vers specs/archived/ (#33)
- **~38,000 lignes de duplication** : methodologie retiree des commands et agents (vit dans les skills) (#35, #36)

### Securite
- **5 vulnerabilites corrigees** : injection node -e, injection sed, mktemp sans verification, injection awk, quoting variables (#38, #39)
- **Documentation risques depots tiers** : 3 vecteurs d'attaque (hooks, MCP, env vars) documentes dans security.md (#30)
- **--restore option** : update.sh permet de restaurer depuis un backup (#38)

---

## [1.25.1] - 2026-02-06

### Ajoute
- **Documentation Docusaurus** : mise a jour complete pour combler les ecarts avec le socle v1.25.0
  - Page [Fonctionnalites Avancees](/docs/concepts/advanced-features) dans Concepts : Opus 4.6, Agent Teams, Plugins, LSP, MCP, @imports
  - Page [Bonnes Pratiques](/docs/guides/best-practices) dans Guides : recommandations Boris Cherny (verification, modele, prompting, sessions paralleles, commit-push-pr)
  - Style `explanatory` documente dans la page Output Styles (recommande par Boris Cherny)

### Modifie
- Compteurs Docusaurus corriges : Skills 41 → 42 (navbar, footer, index), WORK 11 → 12 (sidebar, index)
- Concepts passe de 9 a 10 concepts cles (ajout Fonctionnalites Avancees)
- Sidebar mise a jour avec les 2 nouvelles pages (concepts + guides)
- Guide index enrichi avec la page Bonnes Pratiques

---

## [1.25.0] - 2026-02-06

### Ajoute
- **Agent Teams** : integration native de l'orchestration multi-agents (TeammateTool)
  - Skill `agent-teams` avec documentation complete (activation, architecture, modes, raccourcis)
  - 4 patterns pre-configures : Audit (3-4 agents), Feature (2-3 agents), Debug (3-5 agents), Review (3 agents)
  - Commande `/work:work-team` avec detection automatique du pattern adapte
  - Workflow en 5 etapes : Analyser → Creer → Coordonner → Synthetiser → Cleanup
  - Support tmux (split-panes) et mode in-process
  - Raccourcis clavier : Shift+Up/Down (navigation), Shift+Tab (delegate), Ctrl+T (task list)
- **Documentation** : reference croisee Agent Teams dans le skill `parallel-agents`
- **CLI** : flag `--teammate-mode` documente (auto, in-process, tmux)

### Modifie
- Compteurs mis a jour : 121 commandes, 42 skills (README, website, docs)
- Section WORK passe de 11 a 12 commandes dans le catalogue

---

## [1.24.2] - 2026-02-06

### Ajoute
- **GitHub Pages** : deploiement automatique de la documentation Docusaurus
  - Workflow `docs.yml` : ajout des jobs `upload-pages-artifact` et `deploy-pages`
  - Permissions `pages: write` et `id-token: write` configurees
  - Site accessible sur https://christopherlouet.github.io/claude-socle/

### Corrige
- **Workflow Specify** : ajout de l'etape manquante "Specify" dans 16 references
  - Toutes les occurrences affichent desormais le workflow complet en 5 etapes : Explore → Specify → Plan → TDD → Commit
  - Fichiers corriges : `docusaurus.config.ts`, pages intro, guides, FAQ, workflows, tutorials, `GUIDE.md`

---

## [1.24.1] - 2026-02-06

### Corrige
- **Website Docusaurus** : build casse corrige et ameliorations multiples
  - `sidebars.ts` : chemins orchestrateur corriges (`commands/assistant` → `commands/other/assistant`), compteurs domaines mis a jour (WORK 11, DEV 23, QA 15, GROWTH 11)
  - Liens casses corriges dans `concepts/orchestrator.md`, `workflow/choosing-workflow.md`, `workflow/tdd.md`, `examples/ops/opnsense-config.md`, `tutorials/opnsense-firewall.md`
  - `generate-command-docs.ts` : syntaxe commandes corrigee (`/command` → `/{domain}:{command}`), ajout etape Specify dans le guide rapide
  - `docusaurus.config.ts` : `onBrokenLinks` passe de `warn` a `throw`, migration `onBrokenMarkdownLinks` vers `markdown.hooks` (Docusaurus v4)

### Ajoute
- **Assets statiques** : `favicon.svg` et `social-card.svg` (Open Graph 1200x630)
- **Homepage** : workflow aligne avec CLAUDE.md (5 etapes : Explore → Specify → Plan → TDD → Commit)
- **`WorkflowDiagram.tsx`** : etape Specify ajoutee au `MAIN_WORKFLOW`
- **Accessibilite** : styles `:focus-visible` pour cards, boutons et liens dans `custom.css`
- **`FeatureComparison.tsx`** : refactorise avec props `columns` et `data` (retrocompatible)

---

## [1.24.0] - 2026-02-06

### Modifie
- **Documentation Opus 4.6** : mise a jour des references pour Claude Opus 4.6
  - `docs/reference/best-practices.md` : citation Boris Cherny et recommandations mises a jour (Opus 4.5 → 4.6), ajout section Adaptive Thinking (4 niveaux d'effort), mention Context Compaction
  - `docs/reference/advanced-features.md` : nouvelle section "Opus 4.6 : Nouvelles Capacites" (Adaptive Thinking, 1M contexte beta, 128k sortie, Context Compaction, Agent Teams)
  - `templates/FAQ.md` : fenetre de contexte mise a jour (200k → 1M beta), nouvelle FAQ Adaptive Thinking
  - `docs/ARCHITECTURE.md` : tableau des modeles enrichi avec contexte et sortie max
  - `dev-ai-integration` (agent, commande, page Docusaurus) : modeles Anthropic mis a jour, nouvel exemple Opus 4.6 avec Adaptive Thinking

### Corrige
- **`new-project.sh`** : copie de `docs/reference/`, `docs/guides/`, `docs/ARCHITECTURE.md` et `docs/WORKFLOWS.md` lors de l'installation
  - Les @imports de CLAUDE.md (`@docs/reference/*.md`) sont maintenant resolus dans les nouveaux projets
  - Les liens de navigation du CLAUDE.md vers les guides et l'architecture sont disponibles
- **`update.sh`** : `--upgrade-claude-md` copie aussi `docs/ARCHITECTURE.md`, `docs/WORKFLOWS.md` et `docs/guides/` en plus de `docs/reference/`

---

## [1.23.2] - 2026-02-06

### Corrige
- **Documentation Docusaurus** : correction de la coherence et suppression des fichiers dupliques
  - Suppression de 29 pages de skills dupliquees (anciens noms descriptifs)
  - Suppression de 2 fichiers assistant dupliques a la racine des commandes
  - Correction des compteurs dans 8+ fichiers (commands, agents, reference, concepts)
  - Reecriture complete de `agents-matrix.md` (37 → 57 agents)
  - Correction de `concepts/orchestrator.md` (compteurs et noms de skills obsoletes)
- **Pages manquantes** : creation des pages documentation absentes
  - `qa-chrome` : skill, agent et commande
  - `work-commit-push-pr` : commande
- **Matrices de reference** : ajout des commandes manquantes
  - DEV : 7 commandes ajoutees (dev-ai-integration, dev-design-system, dev-document, dev-prisma, dev-prompt-engineering, dev-rag, dev-trpc)
  - QA : 4 commandes ajoutees (qa-chrome, qa-design, qa-e2e, qa-tech-debt)
  - OPS : 6 commandes ajoutees (ops-observability-stack, ops-opnsense, ops-proxmox, ops-rollback, ops-serverless, ops-vercel)
  - GROWTH : 2 commandes ajoutees (growth-cro, growth-localization)

---

## [1.23.1] - 2026-02-03

### Corrige
- **Compteurs documentation** : correction des incohérences dans tous les fichiers
  - `Stats.tsx` : 100→120 commands, 37→57 agents, 24→41 skills, 15→21 rules
  - `website/docs/intro/index.md` : Rules 20→21, WORK 10→11
  - `website/docs/reference/index.md` : Commands 119→120, Rules 20→21, WORK 10→11
  - `WHEN-TO-USE-WHICH-AGENT.md` : 56→57 agents
  - `docs/ARCHITECTURE.md` : Skills 40→41, Agents 56→57, Rules 20→21
  - `.claude/skills/README.md` : 40→41 skills
- **`/assistant`** : ajout de `/work:work-commit-push-pr` dans le catalogue (11 WORK commands)

---

## [1.23.0] - 2026-02-03

### Ajoute
- **Bonnes pratiques Boris Cherny** : integration des recommandations du createur de Claude Code
  - Nouvelle section "Verification" dans CLAUDE.md (feedback loop = 2-3x qualite)
  - Nouvelle section "Modele Recommande" (Opus 4.5 avec thinking, mis a jour vers Opus 4.6 en v1.24)
  - Nouvelle section "Prompting Avance" ("Grill me", "Prove it", "elegant solution")
  - Nouvelle section "Sessions Paralleles" (git worktrees)
- **`/work:work-commit-push-pr`** : nouvelle commande combinee commit+push+PR (120 commands)
- **`docs/reference/best-practices.md`** : fichier de reference importe via @import
- **`docs/guides/PROMPTING-GUIDE.md`** : guide complet des techniques de prompting
- **Output style `explanatory`** : mode apprentissage avec explications detaillees (8 styles)
- **MCP servers** : ajout Slack, Sentry, BigQuery, Linear, Notion (13 servers)

### Modifie
- **`update.sh`** : amelioration de la mise a jour des @imports
  - Copie toujours `docs/reference/*` (mise a jour des fichiers)
  - Detecte et ajoute les @imports manquants dans CLAUDE.md existants
  - Ajoute automatiquement `@docs/reference/best-practices.md`
- **Skill `git-worktrees`** : enrichi avec le workflow Boris (aliases shell, worktree analyse, notifications)
- **Compteurs documentation** : mise a jour 119 → 120 commands

---

## [1.22.2] - 2026-02-02

### Modifie
- **README** : migration des commandes vers le format namespace, correction badge release, arbre structure et politique de versioning
- **CI** : bump actions/checkout, actions/setup-node et actions/cache via Dependabot

---

## [1.22.1] - 2026-02-02

### Supprime
- **setup-wizard.sh supprime** : le wrapper de compatibilite est retire, utiliser `new-project.sh --simple` directement

---

## [1.22.0] - 2026-02-02

### Modifie
- **setup-wizard.sh deprecie** : remplace par un wrapper de 14 lignes qui redirige vers `new-project.sh --simple`, eliminant 520+ lignes de code duplique

---

## [1.21.0] - 2026-02-02

### Ajoute
- **Auto-creation de branches** : les workflows feature/bugfix/release creent automatiquement une branche et une PR active

### Modifie
- **Commandes namespacees** : toutes les references de commandes utilisent le format namespace (`/work:work-explore` au lieu de `/work-explore`)

### Corrige
- **CI ShellCheck** : resolution de SC2155 (declare and assign separately) dans `update.sh`

---

## [1.20.0] - 2026-02-01

### Ajoute
- **Auto CLAUDE.md** : generation automatique du CLAUDE.md lors de `update.sh` si absent
- **Default .gitignore** : ajout de `.claude/` et `CLAUDE.md` dans le .gitignore par defaut des nouveaux projets
- **Migration CLAUDE.md** : option `--upgrade-claude-md` dans `update.sh` pour migrer les anciens projets vers les @imports

### Modifie
- **CLAUDE.md @imports** : refactoring du CLAUDE.md pour utiliser des @imports vers `docs/reference/` (commands, project-structures, agents-catalog, hooks-reference, skills-catalog, advanced-features)

### Corrige
- **CI workflows** : optimisation pour les repos prives (reduction de la consommation de minutes GitHub Actions)

---

## [1.19.1] - 2026-01-30

### Corrige
- **Compteurs documentation** : alignement des compteurs (120 cmd, 57 agents, 41 skills, 21 rules) dans README badge, Docusaurus config (navbar/footer), quick-start, commands/index, skills/index, CONTRIBUTING, assistant.md
- **Badge version README** : correction v1.17.0 → v1.19.0

---

## [1.19.0] - 2026-01-30

### Ajoute
- **Sync documentation officielle** : alignement avec code.claude.com (nouveau domaine docs Anthropic)
- **Nouveaux Hook Events** : `UserPromptSubmit`, `PermissionRequest`, `PostToolUseFailure`, `SubagentStart`, `Stop` documentes dans CLAUDE.md
- **Prompt-based hooks** : documentation du type `prompt` (evaluation LLM) en plus du type `command`
- **CLAUDE.md @imports** : documentation de la syntaxe `@path/to/file` pour importer des fichiers
- **Plugins system** : documentation du systeme de plugins (`.claude-plugin/plugin.json`, marketplace, namespacing)
- **SessionStart matchers** : documentation des matchers `startup`, `resume`, `clear`, `compact`
- **Notification types** : ajout de `auth_success` et `elicitation_dialog`

### Modifie
- **URLs documentation** : migration de `docs.anthropic.com` vers `code.claude.com` dans tous les fichiers MD
- **Hook Events CLAUDE.md** : table enrichie avec 13 events (etait 8), types command/prompt
- **docs/CHEATSHEET.md** : mise a jour complete avec tous les 120 commandes par categorie, accents corriges
- **docs/ALIASES.md** : enrichissement avec orchestrateur, nouveaux alias dev/qa/ops/growth
- **docs/GUIDE.md** : restructuration et enrichissement du guide complet
- **docs/GUIDE-UTILISATEUR.md** : mise a jour du guide utilisateur
- **docs/CUSTOMIZATION.md** : mise a jour du guide de personnalisation

---

## [1.18.0] - 2026-01-30

### Ajoute
- **LSP Configuration** : `.lsp.json` avec support de 12 langages (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS)
- **Regle LSP** : `.claude/rules/lsp.md` pour guider l'utilisation LSP vs Grep (navigation semantique)
- **Hooks Setup** : hook `Setup` avec `init` (install dependances) et `maintenance` (audit + update)
- **Hooks Notification** : hook `Notification` pour `permission_prompt` et `idle_prompt`
- **Hook SubagentStop** : log de fin des sub-agents pour tracabilite
- **Hook SessionEnd** : log de fin de session pour analytics
- **Hook PreCompact** : log avant compaction du contexte pour debugging
- **Skill qa-chrome** : tests visuels Chrome (debugging DOM, responsive, captures GIF)
- **Agent qa-chrome** : agent audit visuel Chrome (sonnet, Bash/Read/Grep/Glob)
- **Commande /qa-chrome** : commande pour invoquer les tests Chrome
- **Script setup-deps.sh** : script hook Setup detectant le type de projet et installant les dependances
- **Section CLI Flags** dans CLAUDE.md : 14 flags documentes (`--agent`, `--chrome`, `--teleport`, `--remote`, `--init`, `--maintenance`, `--max-budget-usd`, etc.)
- **Section LSP** dans CLAUDE.md : activation, langages supportes, guide LSP vs Grep
- **Section Bonnes Pratiques Skills** dans CLAUDE.md : taille, budget, frontmatter, substitutions, dynamic context injection

### Modifie
- **Hooks settings.json** : ajout de 5 nouveaux hook events (Setup, Notification, SubagentStop, SessionEnd, PreCompact)
- **Section Hooks CLAUDE.md** : reecrite avec tableau complet des 23 hooks configures et variables d'environnement
- **Skills frontmatter** : enrichissement de 26 skills avec `disable-model-invocation`, `argument-hint`, `model`, `user-invocable`
- **writing-skills/SKILL.md** : documentation complete des nouveaux champs frontmatter Claude Code 2.1+
- **Compteurs** : 120 commandes, 57 sub-agents, 41 skills, 21 regles (README, CLAUDE.md, website)

---

## [1.17.0] - 2026-01-29

### Securite
- **Mots de passe exemples** : remplacement de tous les `POSTGRES_PASSWORD=pass` par `${POSTGRES_PASSWORD:?required}` ou `${{ secrets.POSTGRES_PASSWORD }}` dans ops-docker, ops-ci, qa-automation
- **curl|sh** : remplacement du pattern `curl | sh` par download-then-execute dans `install-starship-theme.sh`
- **Avertissement curl|sh** : ajout d'un bloc securite dans `ops-vps.md` documentant le risque
- **CLAUDE.md** : enrichissement de la section Securite avec gestion des secrets, MCP security, curl|bash
- **Input validation** : ajout de `sanitize_input()` et `validate_input()` dans `scripts/lib/common.sh`

### Ajoute
- **`.claude/rules/README.md`** : index des 20 regles avec paths cibles et descriptions
- **`.claude/skills/README.md`** : mise a jour complete avec les 40 skills (etait 9)
- **CI validate-counts** : nouveau job `validate-counts` dans le pipeline CI
- **CI Semgrep SAST** : nouveau job `semgrep` (informatif) pour l'analyse statique de securite

### Corrige
- **validate-counts.sh** : exclusion des fichiers `README.md` du comptage (commands, agents, rules)

---

## [1.16.1] - 2026-01-29

### Corrige
- **Compteur DEV** : correction dans CLAUDE.md (24 → 23 commandes)
- **Compteur Skills** : correction dans CLAUDE.md (39 → 40 skills)
- **Index agents** : description mise a jour (37 → 56 sub-agents)
- **Workflows** : ajout de l'etape `/work-specify` dans les exemples de workflows
- **CI/docs** : echappement des chevrons dans dev-debug SKILL.md pour MDX
- **CI** : correction des erreurs ShellCheck et MDX build

### Ajoute
- **CONTRIBUTING.md** : guide de contribution avec setup, conventions et checklist
- **Synchronisation docs** : mise a jour complete de la documentation website (138 fichiers)

---

## [1.16.0] - 2026-01-28

### Ajouté
- **3 nouveaux agents** : `dev-document`, `growth-cro`, `qa-design`
  - `dev-document` (sonnet) : Génération de documents (PDF, DOCX, XLSX, PPTX)
  - `growth-cro` (haiku) : Optimisation du taux de conversion (CRO)
  - `qa-design` (haiku) : Audit UI/UX (100+ règles design web)
- **3 nouvelles commandes** : `/dev-document`, `/growth-cro`, `/qa-design`
- **7 nouveaux skills** :
  - `dev-document` : Génération de documents bureautiques
  - `growth-cro` : Optimisation CRO (conversion, signup, onboarding, paywall)
  - `qa-design` : Audit design UI/UX
  - `git-worktrees` : Développement parallèle avec git worktrees
  - `parallel-agents` : Orchestration d'agents parallèles (fan-out)
  - `session-handoff` : Transfert de contexte entre sessions IA
  - `writing-skills` : Guide pour créer de nouveaux skills
- **2 nouvelles règles** :
  - `nextjs.md` : Règles Next.js (RSC, App Router, data fetching, caching)
  - `verification.md` : Vérification avant completion (4 phases)
- **2 nouveaux scripts** :
  - `scripts/bump-version.sh` : Mise à jour unifiée de la version dans tous les fichiers
  - `scripts/validate-counts.sh` : Validation de la cohérence des compteurs (commands/agents/skills/rules)
- **Script thème GNOME Terminal** : `scripts/themes/install-gnome-terminal-theme.sh`

### Modifié
- **Skills enrichis** : Contenu étendu pour `dev-debug`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `qa-review`
- **Commandes enrichies** : `assistant`, `assistant-auto`, `doc-architecture`
- **Documentation complètement synchronisée** :
  - Tous les compteurs alignés sur 118 commands, 56 agents, 40 skills, 20 rules
  - README.md : badge version corrigé (v1.12.1 → v1.15.0), compteurs catégories corrigés
  - Website : 8 fichiers corrigés (index.tsx, architecture.md, quick-start.md, cheatsheet.md, FeatureComparison.tsx, docusaurus.config.ts, intro/index.md)
  - Politique de versioning mise à jour dans README.md

### Corrigé
- **Badge README.md** : Version affichée corrigée de v1.12.1 à v1.15.0 (maintenant v1.16.0)
- **Compteurs README.md** : dev (22→23), qa (12→14), ops (27→30), growth (9→11)
- **Website quick-start** : Version et compteurs obsolètes (v1.4.1/109/47 → v1.16.0/118/56)
- **Website architecture** : Compteurs mixtes corrigés (110/52/32/17 → 118/56/40/20)
- **Website index.tsx** : Compteurs homepage corrigés (108/45/27/17 → 118/56/40/20)
- **Website FeatureComparison** : Compteurs comparaison corrigés (100/37/24 → 118/56/40)
- **Website cheatsheet** : Compteurs footer corrigés (111/52/32/17 → 118/56/40/20)
- **Website docusaurus.config.ts** : Labels footer corrigés

### Technique
- Compteurs totaux : 118 commands (+0), 56 agents (+3), 40 skills (+7), 20 rules (+2)
- Nouveau script `bump-version.sh` pour éviter les désynchronisations futures
- Nouveau script `validate-counts.sh` pour validation CI des compteurs
- 38+ fichiers modifiés, ~1000 lignes ajoutées

---

## [1.15.0] - 2026-01-25

### Ajouté
- **Nouveaux hooks de qualité** (issus du retour d'expérience sur des projets utilisateurs réels)
  - `SessionStart` : Vérification de node_modules manquant
  - `PreToolUse` : Exécution des tests avant commit (désactivable via `SKIP_PRE_COMMIT_TESTS=1`)
  - `PostToolUse` : Type-check TypeScript (`tsc --noEmit`) après modification
  - `PostToolUse` : Vérification ESLint après modification JS/TS
  - `PostToolUse` : Vérification couverture de tests après modification de fichiers `.test.ts`

### Technique
- 5 nouveaux hooks dans `.claude/settings.json`
- Synchronisation des fonctionnalités depuis un projet utilisateur réel
- Variables d'environnement pour désactiver les hooks (SKIP_PRE_COMMIT_TESTS, ALLOW_MAIN_EDIT)
- Détection secrets gitleaks en PreToolUse (avant écriture) - pas de scan post-commit redondant

---

## [1.14.0] - 2026-01-24

### Ajouté
- **Collection de thèmes terminal** : 7 thèmes visuels complets dans `scripts/themes/`
  - Thèmes disponibles : matrix, cyberpunk, dracula, catppuccin, nord, gruvbox, tokyo-night
  - Chaque thème inclut 3 composants :
    - Configuration Starship (prompt) : `starship-themes/<theme>.toml`
    - Couleurs eza (listing moderne) : `eza-<theme>.sh`
    - Couleurs LS_COLORS (ls natif) : `ls-<theme>.sh`
  - Script d'installation interactif : `install-starship-theme.sh`
  - Documentation complète avec palettes de couleurs et aliases

### Technique
- 23 nouveaux fichiers de configuration de thèmes
- Support True Color (RGB 24-bit) pour tous les thèmes
- Aliases inclus : `ls`, `ll`, `la`, `lt`, `l`

---

## [1.13.0] - 2026-01-23

### Ajouté
- **Règle TDD Enforcement** : Nouvelle règle `.claude/rules/tdd-enforcement.md` pour déclencher proactivement le TDD
  - S'applique à tous les fichiers source (TS, JS, Dart, Python, Go, Rust, Java, C#, Ruby, PHP)
  - Mots-clés déclencheurs : "implémenter", "ajouter", "créer", "fixer", "corriger", "feature", "bugfix"
  - Exceptions définies : fichiers de config, documentation, refactoring mineur

- **Documentation Docusaurus** : Page `/docs/rules/tdd-enforcement` avec exemples et intégration

### Modifié
- **Skill dev-tdd** : Description élargie avec nouveaux mots-clés déclencheurs automatiques
- **Agent dev-tdd** : Description alignée avec le skill pour déclenchement étendu
- **Commandes dev-*** : Ajout de la section "Pré-requis TDD" obligatoire
  - `/dev-component` : Ordre de création TDD (types → tests → composant → stories)
  - `/dev-api` : Ordre de création TDD (spec → tests → handler → doc)
  - `/dev-hook` : Ordre de création TDD (types → tests → hook)
- **CLAUDE.md** : Compteur de règles mis à jour (17 → 18), documentation tdd-enforcement
- **Docusaurus** : Mise à jour de l'index des règles, skill TDD et workflow TDD avec cross-links

### Technique
- Score d'enforcement TDD amélioré de 5.4/10 à ~8/10
- Cross-linking établi entre rule, skill et workflow TDD

---

## [1.12.1] - 2026-01-22

### Ajouté
- **Documentation Docusaurus Skills** : 29 nouvelles pages de documentation pour les skills
  - Skills WORK : `work-commit`, `work-explore`, `work-plan`, `work-pr`
  - Skills DEV : `dev-api`, `dev-debug`, `dev-error-handling`, `dev-flutter`, `dev-graphql`, `dev-prompt-engineering`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `dev-tdd`
  - Skills DOC : `doc-changelog`, `doc-generate`
  - Skills OPS : `ops-ci`, `ops-database`, `ops-docker`, `ops-infra-code`, `ops-mobile-release`, `ops-monitoring`, `ops-opnsense`, `ops-proxmox`
  - Skills QA : `qa-e2e`, `qa-perf`, `qa-review`, `qa-security`, `qa-tech-debt`

### Modifié
- **Agent ops-opnsense** : Ajout des métadonnées standardisées (name, description, tools) dans le frontmatter
- **Documentation agents** : Mise à jour des métadonnées (outils, skills injectés)

### Corrigé
- **Tests smoke** : Mise à jour des noms de skills après harmonisation (test-driven-development → dev-tdd, etc.)

---

## [1.12.0] - 2026-01-22

### Ajouté
- **Support IaC OPNsense** : Configuration complète du firewall OPNsense via Terraform
  - Nouvelle commande `/ops-opnsense` pour gérer OPNsense en Infrastructure as Code
  - Nouvel agent `ops-opnsense` (modèle sonnet) avec skills infrastructure-as-code et opnsense-configuration
  - Nouveau skill `opnsense-configuration` avec patterns et bonnes pratiques

- **Templates Terraform OPNsense** (`.claude/templates/opnsense/`)
  - `provider-template.tf` : Configuration provider `browningluke/opnsense`
  - `interfaces-module.tf` : Interfaces WAN/LAN/VLAN avec gateway
  - `firewall-module.tf` : Règles firewall avec anti-lockout obligatoire
  - `nat-module.tf` : NAT outbound et port forwarding
  - `services-module.tf` : DHCP server et DNS Unbound
  - `aliases-module.tf` : Groupes d'adresses, ports et réseaux

- **Exemple complet Orange Box DMZ** (`examples/orange-box-dmz/`)
  - Configuration OPNsense derrière une box Orange en mode DMZ
  - 7 règles firewall (anti-lockout, web, DNS, NTP, ICMP, block-all)
  - DHCP, DNS forwarders Cloudflare, outputs avec résumé ASCII

- **Documentation Docusaurus**
  - Page commande `/ops-opnsense` (auto-générée)
  - Page agent `ops-opnsense` (auto-générée)
  - Page skill `opnsense-configuration` (auto-générée)
  - Exemple `opnsense-config.md` : Configuration complète avec code Terraform
  - Tutoriel `opnsense-firewall.md` : Guide pas-à-pas (45 min, niveau intermédiaire)

### Modifié
- **CLAUDE.md** : Ajout `/ops-opnsense` (115 commandes, 53 agents, 33 skills)
- **sidebars.ts** : OPS (24 → 30), ajout tutoriel et exemple OPNsense
- **Index pages** : Exemples et tutoriels mis à jour

### Corrigé
- **Provider OPNsense** : `allow_insecure_cert` → `allow_insecure` (attribut correct)

---

## [1.11.0] - 2026-01-22

### Ajouté
- **TDD obligatoire** dans le workflow d'implémentation
  - Le cycle Red-Green-Refactor devient obligatoire pour toute feature
  - Workflow mis à jour : Explore → Plan → **TDD** → Commit
  - Anti-pattern ajouté : "Coder AVANT d'écrire les tests"
  - Documentation Docusaurus mise à jour (13 fichiers)

- **Permissions optimisées** dans `settings.json`
  - `NotebookEdit` : Édition notebooks Jupyter sans confirmation
  - `TodoRead` / `TodoWrite` : Gestion todo list sans confirmation
  - `AskFollowup` : Questions de suivi sans confirmation
  - `mcp__*` : Tous les serveurs MCP autorisés

- **Nouveaux hooks d'auto-installation**
  - `pubspec.yaml` → `flutter pub get` automatique
  - `go.mod` → `go mod tidy` automatique
  - `Cargo.toml` → `cargo check` automatique

### Modifié
- **Deny list renforcée** (+10 patterns de sécurité)
  - `git restore .`, `git checkout .` bloqués
  - `rm -rf node_modules` bloqué
  - `shutdown`, `reboot`, `halt`, `poweroff` bloqués
  - Fork bomb et pipes dangereux bloqués

### Corrigé
- **CVE-2025-13465** : Patch lodash-es via npm overrides

### Documentation
- Mise à jour du workflow dans 13 fichiers Docusaurus
- WorkflowDiagram.tsx : Code → TDD dans les diagrammes
- FAQ et guides mis à jour

---

## [1.10.1] - 2026-01-22

### Corrigé
- **Correction settings.json** : Erreurs de syntaxe des permissions
  - `Bash(*)` → `Bash` (syntaxe correcte pour autoriser toutes les commandes)
  - Suppression du pattern fork bomb invalide
  - Ajout de `Task(*)` dans les permissions

### Ajouté
- **Tests de smoke** (`tests/smoke.bats`) : Validation rapide de l'intégrité du socle

### Documentation
- **README.md** : Mise à jour badges (250 tests), section migration v1.10.x
- **SECURITY.md** : Mise à jour versions supportées (1.8.x à 1.10.x)

---

## [1.10.0] - 2026-01-22

### Ajouté
- **Nouvel Agent**
  - `dev-tdd` : Agent TDD pour le développement guidé par les tests
- **3 nouvelles Commandes** (total: 114 commandes)
  - `/dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `/growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `/qa-tech-debt` : Identifier et prioriser la dette technique

### Modifié
- **Fusion de `install.sh` dans `new-project.sh`**
  - Nouveau mode `--simple` (ou `--install-only`) pour installation rapide
  - Options ajoutées : `--dry-run`, `--quiet`, `--verbose`, `--skip-prompts`
  - L'ancien comportement de `install.sh` est maintenant accessible via `new-project.sh --simple .`
- **Compteurs mis à jour** dans la documentation : 114 commandes, 52 agents, 32 skills

### Supprimé
- **`scripts/install.sh`** : Fonctionnalités fusionnées dans `new-project.sh --simple`
- **`tests/install.bats`** : Tests migrés vers les tests de `new-project.sh`

### Statistiques
- Commands: 114 (+3)
- Sub-Agents: 52 (+1)
- Skills: 32 (inchangé)

---

## [1.9.0] - 2026-01-20

### Modifié
- **Configuration settings.json optimisée**
  - Permissions génériques avec wildcards (npm, git, docker, terraform, etc.)
  - Support multi-stack : Node.js, Python, Go, Rust, Flutter, Docker, Kubernetes, Terraform
  - Wildcards pour Skills (`Skill(*)`) et MCP tools (`mcp__*`)
  - Scripts locaux via pattern relatif `Bash(./scripts/*:*)`
  - Hooks conditionnels vérifiant l'existence des outils avant exécution

### Supprimé
- **Hooks redondants**
  - Vérification npm install au démarrage
  - TypeScript type-check après modification (bruit)
  - ESLint check après modification (bruit)
  - Couverture de tests après modification (bruit)
  - Scan gitleaks post-commit (redondant avec PreToolUse)

### Sécurité
- **Deny list étendue**
  - `git reset --hard` bloqué
  - `rm -rf ~` bloqué
  - `sudo` et `su` bloqués
  - `chmod 777` bloqué
  - Commandes destructives bas niveau bloquées (mkfs, dd)

### Amélioré
- **Portabilité** : Plus de chemins absolus, configuration universelle
- **Moins d'interactions** : Permissions élargies réduisent les prompts
- **Maintenance** : settings.local.json minimal (11 lignes vs 135)

---

## [1.8.0] - 2026-01-20

### Ajouté
- **8 tutoriels progressifs** (`docs/tutorials/`)
  - 01 - Premier projet : workflow de base (débutant)
  - 02 - Feature React : composant et hook complets (débutant)
  - 03 - API REST Node.js : TDD et documentation OpenAPI (intermédiaire)
  - 04 - Flutter + Supabase : app mobile avec backend (intermédiaire)
  - 05 - Audit de sécurité : OWASP Top 10 (intermédiaire)
  - 06 - Pipeline CI/CD : GitHub Actions (intermédiaire)
  - 07 - Refactoring Legacy : approche méthodique (avancé)
  - 08 - Infrastructure Proxmox : Terraform et monitoring (avancé)

- **Guides utilisateur** (`docs/guides/`)
  - `faq.md` : 20+ questions fréquentes avec réponses détaillées
  - `troubleshooting.md` : 15+ problèmes courants et solutions
  - `migration.md` : guide complet de migration vers claude-socle

- **12 exemples de code** (`docs/examples/`)
  - Web : React component, custom hook, Next.js API route
  - Mobile : Flutter screen (Clean Architecture), BLoC pattern
  - API : REST endpoint, GraphQL resolver, tRPC procedure
  - Ops : Docker multi-stage, CI/CD pipeline, Terraform module, Proxmox VM

- **Composants React Docusaurus**
  - `TutorialCard.tsx` : cartes de tutoriel avec durée et difficulté
  - `DifficultyBadge.tsx` : badges beginner/intermediate/advanced

- **Diagrammes Mermaid**
  - Workflow principal dans `cheatsheet.md`
  - Arbre de décision dans `choosing-workflow.md`
  - Séquence dans `explore-plan-code-commit.md`
  - Vue d'ensemble architecture dans `intro/architecture.md`

### Modifié
- **Skill infrastructure-as-code** : suppression des liens vers fichiers de référence inexistants
- **Sidebars** : ajout des tutoriels, exemples et guides

### Corrigé
- Liens internes dans les tutoriels (suppression préfixes numériques des IDs)
- Lien vers agent `qa-tech-debt` (était incorrectement lié à commands)
- Lien vers guide ops (remplacé par exemples)

---

## [1.7.0] - 2025-01-20

### Ajouté
- **Option `--path` pour `new-project.sh`**
  - Permet de spécifier le dossier parent où créer le projet
  - Exemple : `./scripts/new-project.sh --path ~/projects mon-app`
  - Crée automatiquement le dossier parent s'il n'existe pas (avec confirmation)
  - Mode interactif : demande le dossier si non spécifié

### Corrigé
- **Synchronisation des compteurs dans les scripts**
  - `scripts/new-project.sh` : Compteurs mis à jour (111 commandes, 51 agents, 32 skills)
  - `scripts/install.sh` : Compteurs synchronisés
  - `scripts/learn.sh` : Compteurs synchronisés

---

## [1.6.1] - 2025-01-20

### Ajouté
- **Documentation Docusaurus Orchestrateur**
  - Catégorie "Orchestrateur (2)" dans le sidebar avec `/assistant` et `/assistant-auto`
  - Page `concepts/orchestrator.md` enrichie : guide de décision rapide, workflows par type de projet, agents activés, skills déclenchés
  - Section dédiée dans `commands/index.md` pour mettre en avant le point d'entrée unique

### Modifié
- **Consolidation de la documentation**
  - Suppression des pages dupliquées dans `commands/other/` (contenu fusionné dans orchestrator.md)
  - Liens corrigés dans toute la documentation
- **Compteurs mis à jour**
  - `reference/cheatsheet.md` : 111 Commands, 51 Agents, 32 Skills, 17 Rules
  - `intro/quick-start.md` : 111 commandes
  - `commands/index.md` : 111 commandes en 10 domaines + orchestrateur

### Supprimé
- `website/docs/commands/other/assistant.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/assistant-auto.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/index.md` (dossier supprimé)

---

## [1.6.0] - 2025-01-20

### Ajouté
- **4 nouveaux Agents** (total: 51 agents)
  - `dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `ops-migration` : Migrations de frameworks, versions et dépendances
  - `qa-tech-debt` : Identification et priorisation de la dette technique
- **3 nouveaux Skills** (total: 32 skills)
  - `api-mocking` : Configuration de mocks API avec MSW pour les tests
  - `state-management` : Patterns de state management (Redux, Zustand, Jotai)
  - `tech-debt-management` : Gestion et priorisation de la dette technique
- **1 nouvelle Command** (total: 110 commands)
  - `/ops-rollback` : Procédure de rollback sécurisée (Git, Vercel, K8s, Docker)
- **Documentation Docusaurus**
  - Nouveau chapitre `concepts/orchestrator.md` : Documentation dédiée de `/assistant` comme point d'entrée
  - `docs/README.md` : Index de navigation pour la documentation
  - 9 concepts clés documentés (ajout de l'Orchestrateur)
- **Guides améliorés**
  - `WEB-GUIDE.md` : Ajout section Architecture (React/Next.js et Vue.js)
  - `API-GUIDE.md` : Amélioration phase Testing avec objectifs de couverture

### Modifié
- **WHEN-TO-USE-WHICH-AGENT.md** : Guide de choix enrichi avec les 51 agents
- **CLAUDE.md** : Mise à jour sections agents, skills et commands
- **Concepts index** : L'Orchestrateur est maintenant le 1er concept recommandé aux nouveaux utilisateurs

### Corrigé
- Synchronisation de tous les compteurs dans la documentation (110 commandes, 51 agents, 32 skills)
- Compteurs dans README.md, CHEATSHEET.md, et toute la documentation Docusaurus
- Section legal agents tronquée dans CLAUDE.md

### Statistiques
- Commands: 110 (+1)
- Sub-Agents: 51 (+4)
- Skills: 32 (+3)
- Concepts documentés: 9 (+1 Orchestrateur)

---

## [1.5.0] - 2025-01-19

### Ajouté
- **Proxmox Infrastructure Support**
  - Nouvelle commande `/ops-proxmox` : Gestion complète Proxmox VE (VMs, LXC, réseau, stockage, backup)
  - Nouvel agent `ops-proxmox` : Provisioning infrastructure Proxmox avec Terraform
  - Nouveaux templates Terraform dans `.claude/templates/proxmox/` :
    - `provider-template.tf` : Configuration provider bpg/proxmox
    - `vm-module-template.tf` : Module VM QEMU/KVM avec cloud-init
    - `lxc-module-template.tf` : Module conteneur LXC
    - `infrastructure-template.tf` : Infrastructure complète multi-VMs/LXC
- **Infrastructure as Code**
  - Nouveau skill `infrastructure-as-code` : Terraform/OpenTofu avec best practices
  - Nouvel agent `ops-infra-code` : Création de modules Terraform, gestion state, HCL idiomatique
- **Scripts**
  - `install.sh` : Copie maintenant agents, rules, output-styles, templates
  - `new-project.sh` : Inclut templates et compteurs mis à jour
  - `update.sh` : Support des fichiers `.tf`, `.yaml`, `.yml`, `.json` pour les templates

### Corrigé
- Synchronisation des compteurs dans toute la documentation (109 commandes, 47 agents, 29 skills)
- `learn.sh` : Correction du nombre d'agents (était 85, maintenant 47)
- Documentation Docusaurus : Tous les compteurs mis à jour

### Statistiques
- Commands: 109 (était 108)
- Sub-Agents: 47 (était 45)
- Skills: 29 (était 27)
- Templates: 7 (nouveau dossier proxmox avec 4 templates)

---

## [1.4.1] - 2025-01-18

### Ajouté
- **Scripts**
  - Option `--templates` dans `update.sh` pour synchroniser `.claude/templates/`
  - Inclusion de templates dans `--all`, `--detect-orphans` et `--clean`
- **Documentation**
  - Nouvelle page `docs/concepts/templates.md` documentant les 3 templates de spécification
  - Mise à jour de l'index des concepts (8 concepts au lieu de 7)

### Corrigé
- Templates de spécification (spec, plan, tasks) maintenant synchronisés par `update.sh`

---

## [1.4.0] - 2025-01-18

### Ajouté
- **8 nouveaux Agents** (total: 45 agents)
  - DEV: `dev-design-system`, `dev-prisma`, `dev-trpc`, `dev-prompt-engineering`, `dev-rag`
  - OPS: `ops-serverless`, `ops-vercel`
  - QA: `qa-e2e`
- **3 nouveaux Skills** (total: 27 skills)
  - `e2e-testing` : Tests End-to-End avec Playwright/Cypress
  - `feature-flags` : Gestion de feature flags et déploiement progressif
  - `prompt-engineering` : Optimisation de prompts pour LLMs
- **2 nouvelles Rules** (total: 17 rules)
  - `accessibility.md` : WCAG 2.1 AA, patterns d'accessibilité
  - `performance.md` : Core Web Vitals, optimisation frontend
- **8 nouvelles Commands** (total: 108 commands)
  - `/dev-design-system` : Design tokens et bibliothèque de composants
  - `/dev-prisma` : ORM Prisma (schema, migrations, queries)
  - `/dev-trpc` : APIs type-safe avec tRPC
  - `/dev-prompt-engineering` : Optimisation de prompts LLM
  - `/dev-rag` : Systèmes RAG (Retrieval-Augmented Generation)
  - `/ops-serverless` : Déploiement serverless (Lambda, Vercel, CF Workers)
  - `/ops-vercel` : Configuration et déploiement Vercel
  - `/qa-e2e` : Tests End-to-End avec Playwright ou Cypress
- **Documentation**
  - `docs/QUICKSTART.md` : Guide de démarrage rapide en 5 minutes
  - `WHEN-TO-USE-WHICH-AGENT.md` : Guide de choix des agents

### Corrigé
- Cohérence des chiffres dans la documentation (108/45/27/17)

### Statistiques
- Commands: 108 (était 94)
- Sub-Agents: 45 (était 37)
- Skills: 27 (était 24)
- Rules: 17 (était 15)

---

## [1.3.0] - 2025-01-17

### Ajouté
- **Site de documentation Docusaurus** sur GitHub Pages
  - Documentation complète : 100 commandes, 37 agents, 24 skills, 15 rules
  - Auto-génération depuis les fichiers `.claude/`
  - Déploiement automatique via GitHub Actions
  - URL : https://christopherlouet.github.io/claude-socle/
- **37 Sub-Agents** avec contexte isolé (était 14)
  - DEV: `dev-component`, `dev-test`, `dev-flutter`, `dev-supabase`
  - OPS: `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring`
  - DOC: `doc-generate`, `doc-changelog`, `doc-explain`
  - LEGAL: `legal-rgpd`, `legal-payment`, `legal-privacy-policy`, `legal-terms-of-service`
  - DATA: `data-pipeline`, `data-analytics`, `data-modeling`
  - GROWTH: `growth-analytics`, `growth-landing`, `growth-funnel`
  - BIZ: `biz-mvp`, `biz-personas`
- **24 Skills** avec déclenchement automatique (était 9)
  - `flutter-development`, `supabase-development`, `react-performance`
  - `docker-containerization`, `ci-cd-pipeline`, `database-design`
  - `monitoring-instrumentation`, `documentation-generation`, `changelog-maintenance`
  - `refactoring`, `error-handling`, `graphql-development`
  - `mobile-release`, `data-pipeline`, `performance-optimization`
- **15 Rules modulaires** par langage
  - Nouvelles: `java.md`, `csharp.md`, `ruby.md`, `php.md`, `rust.md`
- **7 Output Styles** documentés avec exemples
  - `teaching`, `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`
- **4 Guides par domaine** dans `docs/guides/`
  - `WEB-GUIDE.md` (React/Next.js/Vue)
  - `MOBILE-GUIDE.md` (Flutter/Clean Architecture)
  - `API-GUIDE.md` (REST/GraphQL)
  - `DATA-GUIDE.md` (ETL/Airflow/dbt)
- **Documentation architecture** (`docs/ARCHITECTURE.md`)
  - Matrice Commands vs Agents vs Skills vs Rules
  - Diagrammes de flux de données
- **Diagrammes workflows** (`docs/WORKFLOWS.md`)
  - Flowcharts ASCII et Mermaid
  - Workflows: Feature, Bugfix, Release, Audit, Mobile, API, Data
- **Setup Wizard** (`scripts/setup-wizard.sh`)
  - Configuration interactive par type de projet
  - Détection automatique des technologies
  - Génération de settings.json personnalisé
- **6 nouvelles commandes OPS**
  - `/ops-grafana-dashboard` : Création dashboards Grafana avec templates
  - `/ops-observability-stack` : Déploiement Prometheus/Grafana/Loki
  - `/ops-k8s` : Déploiement Kubernetes (manifests, Helm)
  - `/ops-vps` : Déploiement VPS (OVH, Hetzner, DigitalOcean)
  - `/ops-mobile-release` : Publication App Store/Google Play avec Fastlane
  - `/growth-app-store-analytics` : Métriques stores mobiles

### Modifié
- **`/assistant`** : Orchestrateur intelligent amélioré
  - Catalogue complet des 94 commandes
  - Détection du type de projet (Web, Mobile, API, Data)
  - Workflows spécifiques par domaine
  - Références aux guides de domaine
- **CLAUDE.md** : Documentation complète mise à jour
  - 94 commandes, 37 agents, 24 skills, 15 rules
  - Section guides et documentation enrichie
- **`/ops-monitoring`** : Enrichi avec instrumentation complète
- Scripts `update.sh`, `validate.sh`, `new-project.sh` améliorés

### Statistiques
- Commands: 94 (était 88)
- Sub-Agents: 37 (était 14)
- Skills: 24 (était 9)
- Rules: 15 (était 10)
- Output Styles: 7 (documentés)
- Guides domaine: 4 (nouveaux)

## [1.2.0] - 2025-01-15

### Ajouté
- **Mode apprentissage interactif** (`learn.sh`) : Tutoriel pour maîtriser claude-socle
  - Tutoriel complet (15-20 min) avec 6 leçons
  - Mode rapide (5 min) pour l'essentiel
  - Apprentissage par agent spécifique (`--agent tdd`, `--agent commit`)
  - Quiz interactifs avec système de score et niveau
  - Couverture : workflow, agents, TDD, Conventional Commits
- **Intégration IDE** (`ide.sh`) : Configuration automatique des IDE
  - Support VSCode/Cursor : settings, tasks, extensions, snippets
  - Support IntelliJ IDEA : run configurations, code style, templates
  - Support Vim/Neovim : abréviations, mappings, autocmds
  - Commandes setup/check/remove pour chaque IDE
  - Option `--force` pour écraser les configurations existantes
- Fichier `.editorconfig` pour formatage cohérent
- Tests bats pour `learn.sh` (40+ tests)
- Tests bats pour `ide.sh` (50+ tests)

### Modifié
- README mis à jour avec documentation des nouvelles fonctionnalités
- Compteur de lignes de tests mis à jour (1664+ lignes)

## [1.1.0] - 2025-01-15

### Ajouté
- **Analyse CI/CD intelligente** : `new-project.sh` analyse maintenant les workflows existants et propose des améliorations
- Fonction `analyze_existing_cicd()` pour détecter 7 aspects de CI/CD (tests, lint, sécurité, cache, coverage, PR, release)
- Fonction `suggest_cicd_improvements()` avec score de qualité CI/CD
- Fonction `merge_cicd_workflows()` pour ajouter uniquement les workflows manquants
- Menu interactif pour choisir entre garder/améliorer/remplacer la CI/CD existante
- Tests bats pour `gitleaks.bats`
- Configuration `.gitleaks.toml` avec 24+ règles de détection de secrets

### Modifié
- `get_options()` propose maintenant des améliorations quand une CI/CD existe
- `create_project()` supporte les actions "merge" et "replace" pour la CI/CD
- Migration de `[ ]` vers `[[ ]]` pour la cohérence bash

### Sécurité
- Hook gitleaks pré-écriture pour détecter les secrets avant commit
- Hook post-commit pour scanner les secrets après commit

## [1.0.0] - 2025-01-14

### Ajouté
- **79 agents Claude Code** organisés par catégorie :
  - WORK (8) : Workflow principal (explore, plan, commit, pr)
  - DEV (10) : Développement (tdd, test, debug, refactor, api)
  - QA (8) : Qualité (review, security, perf, a11y, audit)
  - OPS (16) : Opérations (hotfix, release, deps, docker, ci)
  - DOC (9) : Documentation (generate, changelog, explain, onboard)
  - BIZ (11) : Business (model, market, mvp, pricing, pitch)
  - GROWTH (8) : Croissance (landing, seo, analytics, onboarding)
  - DATA (3) : Données (pipeline, analytics, modeling)
  - LEGAL (5) : Légal (docs, rgpd, payment, terms, privacy)
- **9 skills** avec déclenchement automatique contextuel
- **8 hooks** Claude Code (protection main, auto-format, type-check, gitleaks)
- Script `new-project.sh` pour créer/configurer des projets
- Script `install.sh` pour installer le socle dans un projet existant
- Script `validate.sh` pour valider une configuration Claude Code
- Script `doctor.sh` pour diagnostiquer l'environnement
- Script `diff.sh` pour comparer avec la version installée
- Script `update.sh` pour mettre à jour le socle
- Script `uninstall.sh` pour supprimer la configuration
- Librairie partagée `lib/common.sh` avec 30+ fonctions utilitaires
- 17 templates CLAUDE.md par stack (react, vue, node-api, python, go, rust, java, fullstack)
- Configuration pre-commit avec detect-secrets et commitlint
- Workflows GitHub Actions (ci.yml, pr-check.yml, release.yml)
- Documentation complète (guides, cheatsheet, workflows)

### Configuration
- Permissions granulaires pour Claude Code
- Protection automatique de la branche main/master
- Validation des commits (Conventional Commits)
- Auto-formatage TypeScript/JavaScript après modifications

## Types de changements

- `Ajouté` pour les nouvelles fonctionnalités
- `Modifié` pour les changements aux fonctionnalités existantes
- `Déprécié` pour les fonctionnalités qui seront supprimées
- `Supprimé` pour les fonctionnalités supprimées
- `Corrigé` pour les corrections de bugs
- `Sécurité` pour les vulnérabilités corrigées
