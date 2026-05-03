# Tasks: counts.json source of truth + CI gate

**Branch**: `feature/counts-source-of-truth`
**Plan**: [plan.md](./plan.md)

Conventions: `T###` task ID, `[P]` parallelizable, `[USX]` user story trace.

---

## Phase 1 — Foundation (30 min)

- **T001** [US1] Create `website/scripts/utils/counts-types.ts` with `Counts` interface (commands, agents, skills, rules, tests, testFiles, byDomain: Record<string, number>)
- **T002** [US1] Create `website/scripts/generate-counts.ts` that scans `.claude/{commands,agents,skills,rules}/` + `tests/*.bats`, returns a `Counts` object, writes JSON to repo root
- **T003** [US1] Wire `generateCounts()` as the FIRST step in `website/scripts/generate-all.ts` (before doc generators so they can read it later if needed)
- **T004** [US1] Verify `website/tsconfig.json` has `resolveJsonModule: true` (add if missing)
- **T005** [US1] Run `npm --prefix website run generate` once → commit the produced `counts.json` to the branch
- **T006** [US1] Smoke test: temporarily delete `.claude/commands/data/data-pipeline.md`, regen, confirm `counts.commands === 130`, restore

## Phase 2 — TS consumers (30 min)

- **T010** [US1] [P] Refactor `website/src/components/Stats.tsx` — `SOCLE_STATS` reads from `counts.json`
- **T011** [US1] [P] Refactor `website/src/components/FeatureComparison.tsx` — replace 3 string literals with `counts.commands.toString()` etc.
- **T012** [US1] [P] Refactor `website/src/pages/index.tsx` — 4 `FeatureItem.title` use template literals from counts
- **T013** [US1] [P] Refactor `website/sidebars.ts` — 9 domain category labels use `\`WORK (${counts.byDomain.work})\`` etc.
- **T014** [US1] [P] Refactor `website/docusaurus.config.ts` — navbar dropdown (3) + footer (1) labels from counts
- **T015** [US1] Run `npm --prefix website run build` → assert success + open `build/index.html` and confirm correct counts

## Phase 3 — Markdown markers + injector (1h)

- **T020** [US3] Create `website/scripts/inject-counts-md.ts` — accepts a list of `{file, markerKey}` mappings, regex-replaces marker contents with values from counts.json
- **T021** [US3] Add markers to `website/docs/intro/index.md` — Key numbers table (4) + Domains table (9)
- **T022** [US3] Add markers to `website/docs/intro/architecture.md` — 8 occurrences
- **T023** [US3] [P] Add markers to `website/docs/reference/cheatsheet.md` — footer line
- **T024** [US3] [P] Add markers to `README.md` — L20, L363, L465 (test layout)
- **T025** [US3] [P] Add markers to `CLAUDE.md` — narrative count refs
- **T026** [US3] [P] Add markers to `docs/CHEATSHEET.md` — ASCII art header + footer
- **T027** [US3] [P] Add markers to `docs/ARCHITECTURE.md` — `## File structure (30 rules)` heading
- **T028** [US3] Wire `injectCountsMd()` after `syncDocs()` in `generate-all.ts`
- **T029** [US3] Tampering test: change one `<!-- count:commands -->130<!-- /count -->` → regen → verify it's restored to 131

## Phase 4 — CI gate + cleanup (15 min)

- **T030** [US2] Add "Counts gate" step to `.github/workflows/ci.yml`: `npm --prefix website ci && npm --prefix website run generate && git diff --exit-code`
- **T031** [US2] Fix `.github/workflows/ci.yml:47` stale `Bats: 258 tests` — replace with static `Bats: see job logs` OR compute dynamically
- **T032** [US2] Prune redundant Layer 1 checks in `scripts/validate-counts.sh` for: Stats.tsx, FeatureComparison.tsx, index.tsx, docusaurus.config.ts, sidebars.ts (now covered by gate). Keep CLAUDE.md, README.md, intro/architecture.md, intro/index.md, cheatsheet.md (covered by markers but kept for defense in depth)
- **T033** [US2] Update `tests/validate-counts.bats` — remove tests that asserted on now-pruned checks, add a smoke test that the gate runs `generate-counts.ts` correctly
- **T034** [US2] Run full local validation: `bats tests/*.bats && bash scripts/validate-counts.sh && npm --prefix website run build && git diff --exit-code`
- **T035** [US2] Drift simulation: edit `counts.json` to wrong value → assert `git diff --exit-code` would fail in CI

## Acceptance gate

Before opening the PR:
- [ ] All T-tasks completed
- [ ] `npm --prefix website run build` exit 0, no broken links
- [ ] `bats tests/*.bats` 100% green (with documented retired tests if any)
- [ ] `bash scripts/validate-counts.sh` exit 0
- [ ] `git diff --exit-code` after fresh `npm run generate` is empty
- [ ] Manual: spot-check Welcome page hero (Stats), nav dropdown counts, footer counts, intro/index Key numbers table
- [ ] CHANGELOG.md updated under `## [Unreleased]` with entry under "Changed" + "Fixed" (CI gate is a tooling improvement, drift fix is a bug fix)
