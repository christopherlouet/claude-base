# Plan: claude-base — week of 2026-05-04 to 2026-05-10

**Goal**: move from ~8/10 to ~9/10 in a single week, via 5 buildable workstreams identified in the competitive audit on 2026-05-03.

**Vision**: become THE reference for "rigorous Claude Code config for serious teams". Not the most visible kit (davila7 keeps the lead with 22-24k stars), not the most volumetric one (rohitg00), but the kit that PROVES its value via tests + benchmark + real use cases.

## Principles

- Keep the **humble, iterative tone** (see memory `feedback_socle_copywriting_tone`)
- Each workstream must ship **independently** (no big bang)
- **Tests first** for anything touching code (TDD per CLAUDE.md)
- **CI gate stays green** on every PR
- **No scope creep**: 5 workstreams, not 7

## Recommended sequencing (by descending leverage)

### Workstream 1 — Public benchmark (impact +0.5 to +1.0, effort 1-2d) ★ HIGHEST LEVERAGE

**Problem**: the "rigour > volume" positioning is declarative, not proven. No competitor does this. The first one to do it credibly wins the argument.

**Deliverables**:
- `docs/BENCHMARK.md` (methodology + results)
- `specs/benchmark/scenarios/`: 3-5 reproducible scenarios
- Dedicated section on the Docusaurus website
- Short LinkedIn announcement (humble tone: "I wanted to measure whether claude-base actually adds anything")

**Candidate scenarios (pick 3-5)**:
1. Node.js + Express + Zod REST CRUD with tests
2. Fix a HIGH CodeQL alert in a TypeScript project
3. Integrate Stripe Checkout (with error handling + webhooks)
4. Refactor a 200-LOC legacy function → tests + clean code
5. Build a React feature + hook + tests + a11y audit
6. Dockerize a Python app + secrets management

**Metrics per scenario**:
- Wall-clock duration (human + Claude)
- Tokens consumed (via `/ops:ops-cost` or equivalent)
- Lines of test generated
- Final `qa-loop` score
- Regressions detected post-merge (1 week later)

**Honest methodology**:
- Run on Claude Pro/Max account, identical network settings
- If vanilla performs as well on some scenarios, **say so**
- No cherry-picking — publish ALL scenarios, even counter-examples
- Reproduction scripts public (under `specs/benchmark/scripts/`)

**Risk**: lengthy. If we slip past 2 days, cut down to 3 scenarios instead of 5. 3 done well beats 5 done shallowly.

### Workstream 2 — Formalised plugin/module API (impact +0.3, effort 1-2d)

**Problem**: `extending-guide.md` exists but the contract is ad-hoc. Nobody dares contribute an external pack without forking.

**Deliverables**:
- `specs/plugin-api/spec.md` (manifest + lifecycle)
- `.claude/modules/<name>/MODULE.md` format defined
- Refactor 1-2 existing packs (e.g. all of `legal/` into a module) as proof
- `docs/EXTENDING-GUIDE.md` updated with a concrete example

**Proposed manifest schema**:
```yaml
---
name: legal-pack
version: 1.0.0
author: christopherlouet
provides:
  commands: [legal-rgpd, legal-payment, ...]
  agents: [legal-payment, ...]
dependencies: []
---
```

**Acceptance test**: an external contributor can publish `claude-base-stripe-pack` and a user installs it via `./scripts/new-project.sh --add stripe-pack`.

### Workstream 3 — Multi-OS CI (impact +0.2, effort ~2h)

**Problem**: bats only runs on Ubuntu. The "works everywhere" credibility expected at 9+/10 is missing.

**Deliverables**:
- `.github/workflows/ci.yml` matrix `runs-on: [ubuntu-latest, macos-latest]`
- Fix any macOS bugs that surface (notably BSD `sed` vs GNU `sed`)
- Multi-OS badge in the README

**Low risk**: most bats are portable. Real concern: `validate-counts.sh` uses `find`, `grep -P`, which differ between macOS (BSD) and Linux (GNU).

### Workstream 4 — Dogfooding case study (impact +0.3, effort 1d)

**Problem**: no proof of real-world use beyond "the maintainer says it works".

**Deliverable**: `docs/CASE-STUDY.md`

**Content**:
- Factual narrative of the 7 PRs from Sunday 2026-05-03 (#107 → #113)
- Before/after for each PR: duration, context, what would have differed without claude-base
- Aggregate metrics: 7 PRs, 2 releases, 0 regressions, 319 tests green at every commit
- A "what claude-base did NOT save me from" section (honesty)

**Why it's credible**: it is real time, verifiable via git log + GitHub PRs. Zero marketing.

### Workstream 5 — Distribution (impact "unbounded" if it lands, effort ~3h)

**Problem**: visibility close to zero (~0 stars at D+7). Hard ceiling on growth without a community.

**Deliverables**:
- 60–90s asciinema demo: `new-project.sh` → `/work:work-flow-feature` → result
- PR on `hesreallyhim/awesome-claude-code` (already in `project_public_release_todos.md` as a D+1 TODO, currently late)
- Embed asciinema in the README

**What NOT to do**: no Reddit spamming, no HN cross-posting (humble tone). One PR, one asciinema, that's it. Quality does the rest.

## Suggested calendar (5 short sessions or 1 weekend sprint)

| Day | Workstream | Duration |
|---|---|---|
| Mon-Tue (evening) | Workstream 1 (benchmark) — pick scenarios + script setup | 2-3h × 2 |
| Wed (evening) | Workstream 1 — execution + write-up | 3-4h |
| Thu (evening) | Workstream 5 — asciinema + PR awesome-claude-code | 2-3h |
| Sat morning | Workstream 3 (multi-OS CI) + Workstream 4 (case study) | 4-5h |
| Sat afternoon | Workstream 2 (plugin API spec) | 3-4h |
| Sun | Workstream 2 (plugin API implementation + PR) | 4-5h |

**Total estimated**: ~25-30h across the week. Dense but realistic if motivation holds.

## End-of-week success criteria

By the end of the week of 2026-05-10:
- [ ] `docs/BENCHMARK.md` published with ≥3 reproducible scenarios
- [ ] `.claude/modules/` API documented + 1 example pack migrated
- [ ] CI green on Ubuntu + macOS
- [ ] `docs/CASE-STUDY.md` published
- [ ] Asciinema embedded in the README
- [ ] PR on awesome-claude-code merged

**Projected score**: 8.8-9.0/10 if everything ships.
**Next ceiling (9.5+)**: depends on traction (stars, external contributions) over 2-3 months. Out of scope here.

## Risks

| Risk | Mitigation |
|---|---|
| Scope creep (wanting more than 5 workstreams) | Stick to the list. New idea → memory roadmap, not next week. |
| Burnout after 7 PRs in a single Sunday | One workstream per evening, not five. The plan spans a week, not a day. |
| Benchmark takes 3 days instead of 2 | Cut to 3 scenarios. 3 done well beats 5 done shallowly. |
| awesome-claude-code PR rejected | Iterate on the pitch — not a tech blocker. |
| macOS CI flaky | Mark macOS `continue-on-error: true` initially, fix progressively. |

## Out of scope (next week or later)

- Automatic memory bank (competes with the native auto-memory in CLI 2.1.76+)
- npm CLI `npx claude-base init` (maintenance load > short-term benefit)
- Web UI for interactive browsing (1-2 days, after Workstream 2 if appetite remains)
- Docusaurus internationalisation (FR + EN, not urgent)
- Logo / visual identity
