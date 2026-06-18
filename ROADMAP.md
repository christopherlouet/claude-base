# Roadmap

Forward-looking backlog for claude-base, derived from a 2026-06-18 competitive
analysis against the Claude Code foundation/framework landscape (oh-my-claudecode,
claude-code-templates, SuperClaude, claude-toolbox, trailofbits/claude-code-config,
shinpr/ai-coding-project-boilerplate, moai-adk, and others).

**Where we stand.** claude-base is best-in-class among its direct peers on
*engineering discipline*: an enforced Explore → Specify → Plan → TDD → Audit → Commit
workflow, verification + safety hooks, stack-aware path-scoped rules, auto-detected
presets, an opt-in module system, a community-skill curation engine, and a real
(1100+) bats test suite with CI. The gap is **distribution and onboarding**, not
capability — peers with a fraction of the engineering rigor have far more adoption
because they are easier to discover and to start with.

**Guiding principle for this roadmap: consolidate before adding.** Our biggest
functional weakness is surface volume, not missing features. Adding capability
worsens onboarding — the dimension that most limits adoption. So reduction and
distribution come before new features.

Priorities are ordered P0 (highest leverage) → P4 (strategic bets needing a
decision). Effort: **S** ≈ hours, **M** ≈ a few sessions, **L** ≈ multi-PR.

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
- [ ] **Decide the target** (maintainer): full targeted consolidation (4 waves) vs Wave-1-only
  (collapse the 13 passthrough agents — safest zero-loss win). Then execute wave by wave
  via the module-change loop (bats RED→GREEN, counts regen, one PR per wave).
- [ ] Re-run the tri-modal (command vs agent vs skill) overlap analysis interrupted
  in a prior session (carried over from the deep-analysis backlog).

## P1 — Popularization (move the adoption needle)

- [x] **README value proposition** (S). Lead with a concrete, factual one-line value
  prop and the differentiators, not just the workflow philosophy. *(done)*
- [ ] **Get listed in awesome-claude-code** (hesreallyhim, 47k★) and VoltAgent (S).
  Highest-traffic discovery channel; a listing PR can outperform months of commits.
- [ ] **Component gallery in the Docusaurus site** (S–M). Generate a searchable,
  installable catalog from `foundation.json` — SEO + shareable per-item URLs. Reuses
  assets already generated for the site.
- [ ] **Demo media** (S). A short asciinema/GIF of `init` → auto-detected preset →
  a verification hook catching an error, at the top of the README and site.
- [ ] **Native plugin channel — design first** (M, see P4). A naive
  `.claude-plugin/marketplace.json` does NOT work for us: the native plugin model
  loads `commands/ agents/ skills/ hooks/hooks.json` at the plugin root, but our
  hooks live in `settings.json` and our path-scoped rules + presets + modules are a
  claude-base convention with no native-plugin equivalent. Shipping a plugin as-is
  would silently drop the verification/safety hooks and stack rules — i.e. the
  differentiators. Needs a design decision (ship a curated subset? wait for
  plugin hooks/rules parity?) before any manifest lands. Tracked in P4.

## P2 — Double-use features (serve both quality and adoption)

- [ ] **`doctor` / health-check command** (S–M). Diagnose the installed config in the
  *user's* repo: are hooks firing, is MCP wired, is settings.json sane, is the
  foundation version drifted? Would have caught the #330/#331 silent-no-op hooks bug
  AND the downstream settings drift seen on a consumer project. Demo-able, builds
  trust, and directly serves the verification ethos. *(source: davila7 `--health-check`)*

## P3 — Craft reinforcement (deepen the lead; low adoption impact)

- [ ] **Reference-graph validator** (M). Lint broken links / orphaned files across the
  command+agent+skill corpus and `@docs/...` includes. A natural sibling of
  `validate-counts`. *(source: claude-toolbox `plugin-graph`)*
- [ ] **Behavioral evals for skills/agents** (M). Fixture → hidden prompt → assertions,
  graded by a sub-agent against captured output. Tests *reasoning* ("does qa-security
  catch this injection?"), not just wiring — the one thing 1100+ structural tests
  don't cover. *(source: claude-toolbox `evals/`)*
- [ ] **Stub / hollow-test substance gate** (M). Detect stubs (`throw "not implemented"`,
  hardcoded returns) and assertion-free tests that coverage % misses. Closes a TDD
  gaming hole. *(source: shinpr `runnableCheck`)*
- [ ] **Security hardening pack** (S–M). Hard numeric quality limits (function length,
  complexity, params, line width, zero-warnings); supply-chain defaults (exact
  version pins, `minimumReleaseAge`, `ignore-scripts`, GH actions pinned to SHA);
  a credential read-deny list + `/sandbox` pairing note. *(source: trailofbits)*
- [ ] **Stop-hook anti-rationalization gate** (M). Reject completion when the final
  message contains cop-outs ("pre-existing", "out of scope", problems-listed-not-fixed).
  *(source: trailofbits)*
- [ ] Small guardrail rules (S each): "adopt a pattern as canonical only if ≥3 files
  across directories use it"; numeric auto-stop triggers in the workflow rule
  ("5+ files changed → report scope"); checked-in ADRs for architectural decisions.

## P4 — Strategic bets (need an explicit decision)

- [ ] **Native plugin distribution model** (M–L). Decide how claude-base maps to the
  `/plugin` channel without losing hooks/rules. Options: ship core-as-plugin (commands
  + agents + skills) with hooks/rules still installed via the CLI and documented as
  such; or wait for native plugin hooks/rules parity. Resolves the P1 blocker.
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
