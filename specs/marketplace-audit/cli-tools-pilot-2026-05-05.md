# Marketplace audit pilot — `cli-tools` preset

**Date**: 2026-05-05
**Status**: Pilot complete — verdict applied (no plugins added, recipe shipped)
**Scope**: First domain audited under the methodology in `specs/marketplace-audit/spec.md`

---

## Why this pilot

The four maintainer-vouched presets all ship with `marketplacePlugins: []` (zero plugins at v1) by deliberate policy: "plugin curation is added incrementally as each one is validated in real production use, not assumed." This pilot tests whether the methodology can produce defensible additions, on the smallest preset surface (`cli-tools`).

## Methodology applied

The methodology rejects star-count and influencer signal in favour of cross-reference across real-product repos. Briefly:

1. Identify candidate plugins relevant to the preset's stated scope (Python or Shell automation, GitHub helpers, headless scripts).
2. Source signal from `gh search code` queries on `path:.claude/settings.json` for each candidate plugin id.
3. Filter the resulting repos against a "real-product" bar: not dotfiles, not config kits, not awesome-lists, not portfolios, not templates. The repo's primary purpose must be a product, library, service or civic tool — not a meta-config artifact.
4. Require a minimum of 3 qualifying repos before considering a plugin for inclusion.
5. Verify maintenance signal: recent commits on the plugin itself, no chronic open bugs, ideally backed by a funded organisation rather than a solo author.
6. Apply a final policy filter: positioning, vendor neutrality, ecosystem alignment with Anthropic.

## Candidates evaluated

Four plugins surfaced from the official marketplace `anthropics/claude-plugins-official` plus the `astral-sh/claude-code-plugins` third-party marketplace.

### `pyright-lsp@claude-plugins-official`

- Source: official marketplace
- Purpose: Microsoft Pyright language server for Python type checking
- Real-product cross-reference: not found in qualifying repos
- Maintenance signal: multiple open infrastructure bugs as of early 2026 — race condition between LSP manager initialization and plugin loading (issues #14803, #15413, #16214, #31468 on `anthropics/claude-code`); `lspServers` config not propagated from `marketplace.json` (#16219); all LSP plugins missing `.lsp.json` (#379 on `claude-plugins-official`)
- **Verdict**: REJECT — active infrastructure bugs make this unsuitable for a bundled recommendation today

### `greptile@claude-plugins-official`

- Source: official marketplace
- Purpose: AI-powered PR code review backed by full-codebase indexing
- Real-product cross-reference: not found in qualifying repos
- Maintenance signal: two distinct OAuth registration bugs documented in successive months — "Cannot POST /register" (#21208, January 2026) and "SDK auth failed: Incompatible auth server" (#45518, April 2026)
- **Verdict**: REJECT — auth layer not stable; also out of scope for headless / CI-friendly cli-tools persona

### `commit-commands@claude-plugins-official`

- Source: official marketplace
- Purpose: `/commit` and `/commit-push-pr` commands
- Real-product cross-reference: not found in qualifying repos
- Maintenance signal: no specific bugs
- **Verdict**: REJECT — overlaps with claude-base's existing `/work:work-commit` and `/work:work-pr` commands; adds noise, not value

### `astral@astral-sh`

- Source: third-party marketplace `astral-sh/claude-code-plugins`
- Purpose: skills for Astral's Python toolchain — `uv` (package manager), `ruff` (linter/formatter), `ty` (type checker + LSP); invoked via `/astral:uv`, `/astral:ruff`, `/astral:ty`
- Real-product cross-reference: **13+ qualifying repos** identified via `gh search code 'astral@astral-sh' --filename settings.json`. Sample (after filtering 16 dotfiles, 4 templates, 3 portfolios/showcases): `vinta/hal-9000`, `turquoisehealth/pricepoints`, `zenml-io/kitaru`, `anam-org/metaxy`, `AI-Riksarkivet/ra-hcp`, `AI-Riksarkivet/ra-anno`, `codeforpdx/tenantfirstaid`, `ryan-pip/pulumi-fivetran`, `qarax/qarax`, `Sunsilkk/ml_management_v2`, `SteffenPL/fiji-mcp`, `gillisandrew/keyatlas`, `shoriminimoe/novamoc`
- Maintenance signal: healthy. Plugin maintained by Astral (a funded company); pure instructional skill content (no executable surface, low security risk); underlying tools `uv` and `ruff` are independently dominant in modern Python (uv ~126M downloads/month, ruff 30M+ weekly downloads). One open issue ("LSP not used in git worktrees") is a minor scope limitation.

#### Policy filter applied

Astral was acquired by OpenAI on 2026-03-19 ([OpenAI announcement](https://openai.com/index/openai-to-acquire-astral/), [Astral blog](https://astral.sh/blog/openai)). Tools remain MIT-licensed; the team is joining OpenAI's Codex effort.

The signal-and-maintenance evaluation **passes** the methodology bar. The policy filter, however, raises a positioning concern specific to claude-base:

- claude-base is a configuration kit for **Claude Code (Anthropic)**.
- Bundling `astral@astral-sh` in `cli-tools.json` would publish an implicit endorsement of OpenAI-acquired tooling in a kit aimed at Anthropic's ecosystem.
- The MIT license protects the code but does not protect against future roadmap drift toward Codex-specific integration, attention migration of the Astral team toward Codex, or feature gating behind OpenAI APIs in subsequent versions.
- For users who deliberately chose Claude Code over Codex, the bundling would publish a dissonant signal.

#### Verdict

REJECT for `marketplacePlugins` inclusion **on positioning grounds**, despite the strong technical and adoption signal.

The technical merit of `uv`/`ruff`/`ty` is acknowledged. Users who want this toolchain integration should not face friction obtaining it.

## Outcome

| Action | Status |
|---|---|
| `cli-tools.json` `marketplacePlugins` | **Stays `[]`** — no change |
| Recipe documenting the choice | **Shipped**: `docs/recipes/python-toolchain-options.md` |
| Methodology trace | **This document** |
| Re-evaluation trigger | If the Astral team publishes a roadmap that diverges meaningfully from neutral OSS support — or if equivalent neutral plugins ship for `pdm`/`mypy` — revisit in 6-12 months |

## Friction analysis for users who want `astral@astral-sh`

The decision must not create unreasonable friction for users who legitimately want `uv`/`ruff`/`ty`. Today's opt-in path:

1. `claude plugin install astral@astral-sh` — one Claude Code native command
2. Add to `.claude/settings.json`:
   ```json
   { "enabledPlugins": { "astral@astral-sh": true } }
   ```

Total: ~30 seconds. The recipe at `docs/recipes/python-toolchain-options.md` documents this explicitly with copy-paste snippets. The default `update.sh` does not touch `settings.json`, so the user's manual entry is preserved on subsequent foundation updates unless `--settings` is explicitly requested.

## Future improvement — landed same day

A `--add-plugin <id>` flag on `scripts/update.sh`, mirroring the existing `--add-hook` pattern, eliminates the residual friction of `update.sh --settings` overwriting manual additions. Shipped in a follow-up PR same day (v1.33.0). 8 bats tests cover the helper.

## Methodology gaps observed

1. **GitHub code search availability is essential.** The earlier WebSearch-only attempt could not cross-reference real-product repos at file-content granularity. `gh search code` with the `--filename` flag is the right tool — and was decisive here.
2. **Repo classification is manual.** Distinguishing dotfiles / templates / config kits from real product repos required eyeballing repo names and READMEs. A future iteration could automate the filter via repo metadata (topics, has releases, primary language, age).
3. **Marketplace adoption tracker** (e.g. `quemsah/awesome-claude-plugins`) reports a single number per plugin, conflating dotfiles and real-product usage. Direct enumeration via `gh search code` was more useful for this audit.

## Lessons for subsequent preset audits

- The methodology works. Cross-reference via `gh search code` produces interpretable, defensible signal in under one hour.
- The policy filter is non-negotiable. A plugin can clear every technical bar and still be the wrong choice for positioning reasons; that case must be documented.
- Honesty in REJECT verdicts strengthens the kit's credibility. Naming why a plugin was rejected — including positioning reasons — is more valuable than silently omitting it.
- "Recipe instead of bundle" is a viable third option when a candidate is technically strong but politically dissonant.
