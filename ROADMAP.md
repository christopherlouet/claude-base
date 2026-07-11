# Roadmap

Forward-looking backlog for claude-base, derived from a 2026-06-18 competitive
analysis against the Claude Code foundation/framework landscape (oh-my-claudecode,
claude-code-templates, SuperClaude, claude-toolbox, trailofbits/claude-code-config,
shinpr/ai-coding-project-boilerplate, moai-adk, and others).

**Where we stand.** claude-base is best-in-class among its direct peers on
*engineering discipline*: an enforced Explore → Specify → Plan → TDD → Audit → Commit
workflow, verification + safety hooks, stack-aware path-scoped rules, auto-detected
presets, an opt-in module system, a community-skill curation engine, and a real
(1600+) bats test suite with CI. The gap is **distribution and onboarding**, not
capability — peers with a fraction of the engineering rigor have far more adoption
because they are easier to discover and to start with.

**Recently shipped (2026-06-26/27).** A GitHub veille (incl. `affaan-m/ecc`,
`oh-my-claudecode`) crystallised an **"anti-gaming of quality gates"** thread:
#410 anti-tamper guardrails (config-protection: block weakening an existing
linter/formatter config; `git --no-verify`/`-n` gate-bypass block, with a granular
`SKIP_NO_VERIFY_CHECK` opt-out). Also #408 (a self-healing pre-commit so derived
counts can never drift into CI — it also repaired a stale `core.hooksPath`) and
#407 (curation watch-list license-note re-probe). The anti-gaming thread continues
in P3 (substance gate, anti-rationalization gate). A second finding **reopens the
plugin question**: hooks *do* ship in a native plugin via `hooks/hooks.json` — the
old "hooks can't be a plugin" blocker was overstated (see P1/P4).

**Guiding principle for this roadmap: consolidate before adding.** Our biggest
functional weakness is surface volume, not missing features. Adding capability
worsens onboarding — the dimension that most limits adoption. So reduction comes
before new features.

> **Current working priority (2026-06-27, maintainer): craft / quality / safety
> depth — NOT distribution.** The competitive analysis correctly identifies
> distribution & onboarding as the *market-adoption* gap, but that is explicitly
> **not** what we are working on right now. **P1 (Popularization) and the
> adoption-oriented P4 bets are PARKED** until the maintainer chooses to pursue
> them. The active focus is the **anti-gaming-of-quality-gates thread** (P3) plus
> the items that deepen generated-code quality & stability: the substance gate,
> measuring whether rules actually fire, the `doctor` diagnostic, and the security
> hardening pack. When in doubt, prefer a depth/safety item over a reach item.

> **Status refresh (2026-07-11).** A 5-agent full-project analysis re-baselined this
> roadmap: shipped items are now checked below, and a "route to stable" (functional
> bugs, test-suite honesty, docs truth, native-reduction pointers, prevention gates)
> was executed ahead of the next roadmap cycle. The one open STRATEGIC item carried
> forward is the **multi-LLM eval column** (P3, rule-efficacy follow-up) — the missing
> number behind the foundation-value question.

Priorities are ordered P0 (highest leverage) → P4 (strategic bets needing a
decision). Effort: **S** ≈ hours, **M** ≈ a few sessions, **L** ≈ multi-PR.
*(Priority numbers reflect strategic leverage for adoption; the maintainer's
current working order, above, intentionally differs — quality/safety first.)*

---

## P0 — Consolidation audit (decide the reduction target with data)

The v3/v4 catalog-reduction roadmap (modules opt-in, lean core) shipped in
2026-06. This is a **new consolidation round** justified by the competitive
analysis: oh-my-claudecode leads the category with ~28 commands / ~19 agents,
while our core carries far more. A first scan shows the surplus is **not** empty
wrappers (only ~2 pointer agents, ~2 short commands) — so the audit must target
**overlap, redundancy, and vendor-graduation candidates**, not hollow files.

- [x] **Data-driven catalog audit** (done 2026-06-18 — see `specs/consolidation-audit-2026-06/audit.md`).
  Finding: the surface is mostly earned (≈70% of items genuinely distinct), not bloated —
  aggressive lean-to-20 is NOT supported. Targeted consolidation yields ~110 cmd / ~48
  agents / 53 skills (−18-20 cmds, −13 passthrough agents). Sequenced into 4 waves.
- [x] **Decide the target** (maintainer): decided AND executed — all 4 waves shipped and
  released in v5.0.0 (2026-06-20, #335-#355): ~130→106 commands, 63→45 agents.
- [ ] Re-run the tri-modal (command vs agent vs skill) overlap analysis interrupted
  in a prior session (carried over from the deep-analysis backlog).

## P1 — Popularization (move the adoption needle) — ⏸️ PARKED (not the current priority)

- [x] **README value proposition** (S). Lead with a concrete, factual one-line value
  prop and the differentiators, not just the workflow philosophy. *(done)*
- [ ] **Get listed in awesome-claude-code** (hesreallyhim, 47k★) and VoltAgent (S).
  Highest-traffic discovery channel; a listing PR can outperform months of commits.
- [ ] **Component gallery in the Docusaurus site** (S–M). Generate a searchable,
  installable catalog from `foundation.json` — SEO + shareable per-item URLs. Reuses
  assets already generated for the site.
- [ ] **Demo media** (S). A short asciinema/GIF of `init` → auto-detected preset →
  a verification hook catching an error, at the top of the README and site.
- [ ] **Native plugin channel — design first** (M, see P4). Blocker is **narrower
  than previously thought**: hooks *do* ship in a plugin via `hooks/hooks.json` (same
  stdin contract) — confirmed 2026-06-27 — so the verification/safety hooks ARE
  plugin-distributable after a move from `settings.json`. What stays non-native: the
  `paths:`-scoped rules' auto-activation, presets, and modules (claude-base
  conventions). So the realistic path is a **dual-track**: keep the `init` CLI as the
  full-fidelity install (settings env, permissions, path-rules engine) and ship a
  **plugin edition** (commands + agents + skills + hooks, rules-as-static-or-hook-
  injected) purely as a discovery on-ramp into the marketplaces. Needs the design
  decision before any manifest lands. Tracked in P4.

## P2 — Double-use features (serve both quality and adoption)

- [x] **`doctor` / health-check command** — shipped (`scripts/doctor.sh`, 29 checks; exit
  semantics pinned by tests 2026-07-11). Diagnose the installed config in the
  *user's* repo: are hooks firing, is MCP wired, is settings.json sane, is the
  foundation version drifted? Would have caught the #330/#331 silent-no-op hooks bug
  AND the downstream settings drift seen on a consumer project. Demo-able, builds
  trust, and directly serves the verification ethos. *(source: davila7 `--health-check`)*

## P3 — Craft reinforcement (deepen the lead; low adoption impact)

**Anti-gaming-of-quality-gates thread** (stop the agent from defeating its own
gates instead of satisfying them — the foundation's safety/discipline moat):

- [x] **Anti-tamper guardrails** (#410, 2026-06-27): `config-protection` blocks
  weakening an existing linter/formatter config; CATEGORY 9 blocks `git --no-verify`
  / `commit -n`. Advisory nudge on the agent (not a hard boundary), with a granular
  `SKIP_NO_VERIFY_CHECK` opt-out. *(source: affaan-m/ecc, verified + re-implemented.)*
- [x] **Stub / hollow-test substance gate** — shipped 2026-06-27 (#415: substance-check.sh
  + PostToolUse hook + qa/rule wiring). Detect
  stubs (`throw "not implemented"`, hardcoded returns) and assertion-free tests that
  coverage % misses (a test counts as evidence only if it ran AND exercised an
  acceptance criterion). Closes the TDD-gaming hole. *(source: shinpr `runnableCheck`.)*
- [ ] **Stop-hook anti-rationalization gate** (M) — same thread. Reject completion when
  the final message contains cop-outs ("pre-existing", "out of scope",
  problems-listed-not-fixed). *(source: trailofbits.)*

- [x] **Measure whether path-scoped rules actually fire & help** — shipped 2026-06-27
  (#416, eval/rule-efficacy): verdict is MODEL-DEPENDENT (Opus largely redundant, Haiku
  needs the rules) → rules are multi-LLM portability insurance. Multi-LLM eval column
  (more samples + a non-Claude GEN_CMD) is the remaining strategic follow-up. Open question
  surfaced this session: it is unverified whether the 32 `.claude/rules/*.md`
  (`paths:` frontmatter) genuinely reach the model at edit time and change output, or
  are inert docs (sources disagree: repo README says auto-activated, an older memory
  says "soft nudge / no inject"). A blind A/B (worktree with vs without the rule) +
  a trigger-detection probe would settle it before investing in "better" rules.
  Prerequisite to any rule-quality work; pairs with behavioral evals below.
- [ ] **Reference-graph validator** (M). Lint broken links / orphaned files across the
  command+agent+skill corpus and `@docs/...` includes. A natural sibling of
  `validate-counts`. *(source: claude-toolbox `plugin-graph`)*
- [ ] **Behavioral evals for skills/agents** (M). Fixture → hidden prompt → assertions,
  graded by a sub-agent against captured output. Tests *reasoning* ("does qa-security
  catch this injection?"), not just wiring — the one thing 1600+ structural tests
  don't cover. *(source: claude-toolbox `evals/`)*
- [ ] **Security hardening pack** (S–M). Hard numeric quality limits (function length,
  complexity, params, line width, zero-warnings); supply-chain defaults (exact
  version pins, `minimumReleaseAge`, `ignore-scripts`, GH actions pinned to SHA);
  a credential read-deny list + `/sandbox` pairing note. *(source: trailofbits)*
- [ ] Small guardrail rules (S each): "adopt a pattern as canonical only if ≥3 files
  across directories use it"; numeric auto-stop triggers in the workflow rule
  ("5+ files changed → report scope"); checked-in ADRs for architectural decisions.

## P4 — Strategic bets (need an explicit decision)

- [ ] **Native plugin distribution model** (M–L). Decide the dual-track from P1: a
  plugin edition carries commands + agents + skills + **hooks** (`hooks/hooks.json`,
  now confirmed viable); the `paths:`-scoped rules either ship as static files or get
  hook-injected at edit time; presets/modules stay CLI-only. The `init` CLI remains
  the full-fidelity "pro" install; the plugin is the reach/on-ramp channel. Resolves
  the P1 blocker. First step: a spike scaffolding `.claude-plugin/plugin.json` +
  `hooks/hooks.json` and testing with `claude --plugin-dir`.
- [ ] **Stateful downstream template-sync** (M). A `template-state.json` with version,
  variables (model/effort), and `sync_exclusions[]`, plus a conflict-aware settings.json
  merge — so consumer projects resync foundation fixes (incl. security fixes) without
  clobbering customizations. Directly addresses the observed downstream settings/hook
  drift. *(source: claude-toolbox `template:sync`; also: a `update --ignore <file>`
  per-file protect flag, shinpr.)*
- [ ] **Per-task model routing** (M–L). Auto-select Opus/Sonnet/Haiku per subtask to cut
  token cost. Extends the existing effort/model-tier guidance. *(source: oh-my-claudecode)*
- [ ] **Multi-provider generation** (L). Generate a Codex/Cursor variant from a single
  source. Doubles addressable users but dilutes Claude-specific hook enforcement —
  decide whether vendor-agnostic reach is worth weakening the safety layer.
  *(source: claude-toolbox `generate-kodex`, oh-my-agent, moai-adk.)*
- [ ] **Local cost/usage analytics report** (M). Parse `~/.claude/projects/*.jsonl` into
  an offline token/cost report (no hosted backend, to honor the security stance).
  *(source: davila7 `--analytics`.)*

---

## Positioning note

claude-base's differentiators (enforced discipline, verification + safety, stack
conventions, curation) are **complementary** to what runtime orchestrators like
oh-my-claudecode optimize (autonomous multi-agent fleets, model routing,
multi-provider). The strategic risk is chasing their orchestration and arriving
second on their turf. The opportunity is to be **the discipline-and-safety layer
that orchestrators lack** — usable alongside them, not against them.
