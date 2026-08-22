# Tasks: `audit-docs.sh` — Doc drift firewall

**Input**: `specs/audit-docs/spec.md` + `specs/audit-docs/plan.md`
**Prerequisites**: spec (8 US, 15 EF, 12 CS, 3 CP resolved) + plan (7 phases, locked allowlists)
**Branch**: `feature/auto-20260519-163858` → rename to `feat/audit-docs-drift-firewall`

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]** : runnable in parallel
- **[US1..US8]** : traceability
- Exact file paths required

---

## Phase 1 — Pre-verification + branch rename (BLOCKING)

- [ ] **T001** Capture CI baseline :
  - `./scripts/validate-counts.sh` → record exit (expected `0`)
  - `./scripts/audit-base.sh` → record exit + checks count (expected `0`, 168 checks)
  - `bash scripts/test.sh` → record pass count (expected ≥645)
  - `jq '.tests' counts.json` → expected baseline
- [ ] **T002** Verify deps : `bash --version` ≥ 4 ; `jq --version` ; `grep -E` works ; `find` available.
- [ ] **T003** Rename branch via `/git-rename feat/audit-docs-drift-firewall` (slash command, user-invoked).

**Checkpoint**: Baseline known. Branch named.

---

## Phase 2 — TDD RED: failing bats tests (US-1, 5, 6)

⚠️ DO NOT create `scripts/audit-docs.sh` yet. Only `tests/audit-docs.bats`.

- [ ] **T004** Create `tests/audit-docs.bats` with `setup()` (create `TEST_DIR=$(mktemp -d)`) and `teardown()` (`rm -rf "$TEST_DIR"`). Source `tests/test_helper`.
- [ ] **T005** [US1, EF-001] Append test: `"audit-docs: rejects unknown ~/X path prefix"`. Heredoc fixture with `~/nonexistent-prefix/foo` in a temp doc. Run `audit-docs.sh --category paths` against it. Assert exit `1` AND output contains `paths` + the offending path.
- [ ] **T006** [US1, EF-001] Append: `"audit-docs: accepts known ~/.local/share/claude-base/ path"`. Assert exit `0`.
- [ ] **T007** [US1, EF-002] `"audit-docs: rejects claude-base nonexistentverb"`. Assert exit `1`, category `verbs`.
- [ ] **T008** [US1, EF-002] `"audit-docs: ignores claude-base is a foundation (English prose)"`. Assert exit `0`.
- [ ] **T009** [US1, EF-003] `"audit-docs: rejects claude-base init --foo"`. Assert exit `1`, category `flags`.
- [ ] **T010** [US1, EF-003] `"audit-docs: accepts claude-base init --preset nextjs"`. Assert exit `0`.
- [ ] **T011** [US1, EF-004] `"audit-docs: rejects ./scripts/nuclear.sh"`. Assert exit `1`, category `scripts`.
- [ ] **T012** [US1, EF-004] `"audit-docs: accepts ./scripts/test.sh"`. Assert exit `0`.
- [ ] **T013** [US1, EF-005] `"audit-docs: rejects npm --prefix website run nonsense"`. Assert exit `1`, category `npm`.
- [ ] **T014** [US1, EF-005] `"audit-docs: accepts npm --prefix website run generate"`. Assert exit `0`.
- [ ] **T015** [US6, EF-001] `"audit-docs: regression PR #199 — ~/.claude-base/ triggers paths drift"`. Assert exit `1`, category `paths`.
- [ ] **T016** [US5, EF-011] `"audit-docs: AUDIT_DOCS_SKIP_PATHS=1 ignores path drifts"`. Fixture with path drift + verb drift ; run with env var set ; assert exit `1` AND output contains `verbs` but NOT `paths`.
- [ ] **T017** [EF-012] **CRITICAL**: `"audit-docs on the real foundation repo exits 0 (zero-FP gate)"`. Run `./scripts/audit-docs.sh` against the live repo (no fixture). Assert exit `0`.
- [ ] **T018** [EF-013] `"audit-docs: https URL with scripts/X.sh substring is NOT flagged as missing local script"`. Heredoc with `https://github.com/foo/scripts/deploy.sh`. Assert exit `0`.
- [ ] **T019** Run `bats tests/audit-docs.bats`. Expected: **all 14 tests FAIL** (script doesn't exist). Confirm RED state explicitly for each ; record failure reason per test.

**Checkpoint**: 14+ tests RED. Baseline tests (≥645) still pass.

---

## Phase 3 — TDD GREEN: implement `scripts/audit-docs.sh`

### Phase 3a — Skeleton + env vars + scope helper

- [ ] **T020** Create `scripts/audit-docs.sh` with shebang `#!/usr/bin/env bash`, `set -euo pipefail`, source `lib/common.sh` (provides `info`, `error`, `success`, color vars).
- [ ] **T021** Parse env vars at top:
  ```bash
  SKIP_PATHS="${AUDIT_DOCS_SKIP_PATHS:-0}"
  SKIP_VERBS="${AUDIT_DOCS_SKIP_VERBS:-0}"
  SKIP_FLAGS="${AUDIT_DOCS_SKIP_FLAGS:-0}"
  SKIP_SCRIPTS="${AUDIT_DOCS_SKIP_SCRIPTS:-0}"
  SKIP_NPM="${AUDIT_DOCS_SKIP_NPM:-0}"
  ```
- [ ] **T022** Parse CLI args : `--verbose`, `--category <name>`, `--help`. Define `show_help()` printing usage.
- [ ] **T023** Define the 5 allowlist arrays at top (locked values from plan.md):
  ```bash
  KNOWN_VERBS=(init update validate preset uninstall version help)
  KNOWN_INIT_FLAGS=(--verbose --ci --hooks --mcp --docker --all --style \
                    --skip-prompts --minimal --preset --presets-dir \
                    --list-presets --detect-only --yes -y --type -t \
                    --simple --install-only)
  KNOWN_UPDATE_FLAGS=(--add-hook --add-plugin --agents --all --backup-only \
                      --changelog --clean --detect-orphans --hook-scripts \
                      --no-preset --preset --presets-dir --remove-orphans \
                      --restore --rules --settings --skills --styles \
                      --templates --upgrade-claude-md --verbose)
  KNOWN_PATH_PREFIXES=(\
    "~/.claude/" \
    "~/.local/share/claude-base/" \
    "~/.local/bin/" \
    "~/.bashrc" \
    "~/dev/vendor-skills/")
  # KNOWN_NPM_SCRIPTS derived live via jq below
  ```
- [ ] **T024** Derive `KNOWN_NPM_SCRIPTS` live via `jq -r '.scripts | keys[]' "$BASE_DIR/website/package.json"` into a bash array.
- [ ] **T025** Define `enumerate_scope_files()` returning all 8-glob matches via `find docs website/docs/{intro,concepts,examples,tutorials,workflow,guides,reference} -maxdepth 5 -type f -name '*.md' 2>/dev/null`. Cache the result in a global var to avoid re-finding.
- [ ] **T026** Define `report_drift()` accumulating `(file, line, category, message)` tuples into a global associative array. Define `final_report()` printing the accumulated drifts at end + setting exit code accordingly.

**Checkpoint**: Skeleton runs (exit 0, no drift, no audit yet). Smoke test `./scripts/audit-docs.sh --help`.

### Phase 3b — `audit_paths` (T005, T006, T015)

- [ ] **T027** Implement `audit_paths()`:
  ```bash
  audit_paths() {
      [[ "$SKIP_PATHS" = "1" ]] && { info "audit_paths: skipped"; return 0; }
      local files; mapfile -t files < <(enumerate_scope_files)
      [[ ${#files[@]} -eq 0 ]] && return 0
      while IFS=: read -r file line match; do
          # match is the captured path
          local known=0
          for prefix in "${KNOWN_PATH_PREFIXES[@]}"; do
              [[ "$match" == "$prefix"* ]] && { known=1; break; }
          done
          [[ "$known" = "0" ]] && report_drift "$file" "$line" "paths" "unknown path prefix: $match"
      done < <(grep -nEoH "~/[a-zA-Z0-9._/-]+" "${files[@]}" 2>/dev/null)
  }
  ```
- [ ] **T028** Run bats → T005, T006, T015 PASS.

### Phase 3c — `audit_verbs` (T007, T008)

- [ ] **T029** Implement `audit_verbs()`:
  ```bash
  audit_verbs() {
      [[ "$SKIP_VERBS" = "1" ]] && { info "audit_verbs: skipped"; return 0; }
      local files; mapfile -t files < <(enumerate_scope_files)
      while IFS=: read -r file line match; do
          # match: "claude-base WORD"
          local word; word="${match#claude-base }"
          # Check if word is in KNOWN_VERBS (treat anything outside as prose)
          local known=0
          for v in "${KNOWN_VERBS[@]}"; do
              [[ "$word" = "$v" ]] && { known=1; break; }
          done
          # If not a known verb AND looks like a command (lowercase letters/dashes only), flag
          # Plain English words (is, in, for, a, the, ...) just don't match the KNOWN_VERBS list
          # — they're silently ignored as prose per CP2 lock.
          # Drift only when the word LOOKS like a command verb but isn't whitelisted.
          # Heuristic: 4+ chars, all lowercase, no spaces — typo-of-verb candidates.
          if [[ "$known" = "0" ]] && [[ ${#word} -ge 4 ]] && [[ "$word" =~ ^[a-z][a-z-]+$ ]]; then
              # Final filter: against a tiny blacklist of common English short verbs (is/in/for/and/has/can/the)
              case "$word" in
                  is|in|for|and|has|can|the|this|that|with|from|into) continue ;;
              esac
              report_drift "$file" "$line" "verbs" "unknown claude-base verb: $word"
          fi
      done < <(grep -nEoH "claude-base [a-z][a-z-]+" "${files[@]}" 2>/dev/null)
  }
  ```
  Note: the hybrid whitelist + minimal blacklist approach handles both legitimate prose (`is`, `in`, `for` ignored) AND drift detection (a typo like `claude-base initt` would match `^[a-z][a-z-]+$` and be flagged).
- [ ] **T030** Run bats → T007, T008 PASS.

### Phase 3d — `audit_flags` (T009, T010)

- [ ] **T031** Implement `audit_flags()` — two passes : one for `init`, one for `update`:
  ```bash
  audit_flags() {
      [[ "$SKIP_FLAGS" = "1" ]] && { info "audit_flags: skipped"; return 0; }
      local files; mapfile -t files < <(enumerate_scope_files)
      # Pass 1: claude-base init --foo
      while IFS=: read -r file line match; do
          local flag; flag="${match##*--}"; flag="--${flag}"
          local known=0
          for f in "${KNOWN_INIT_FLAGS[@]}"; do
              [[ "$flag" = "$f" ]] && { known=1; break; }
          done
          [[ "$known" = "0" ]] && report_drift "$file" "$line" "flags" "unknown init flag: $flag"
      done < <(grep -nEoH "claude-base init[^\n]*--[a-z-]+" "${files[@]}" 2>/dev/null)
      # Pass 2: claude-base update --foo (same shape against KNOWN_UPDATE_FLAGS)
  }
  ```
- [ ] **T032** Run bats → T009, T010 PASS.

### Phase 3e — `audit_scripts` (T011, T012, T018)

- [ ] **T033** Implement `audit_scripts()`:
  ```bash
  audit_scripts() {
      [[ "$SKIP_SCRIPTS" = "1" ]] && { info "audit_scripts: skipped"; return 0; }
      local files; mapfile -t files < <(enumerate_scope_files)
      # EXCLUDE .claude/rules/** files (user-project script descriptors)
      local audit_files=()
      for f in "${files[@]}"; do
          [[ "$f" == *.claude/rules/* ]] && continue
          audit_files+=("$f")
      done
      while IFS=: read -r file line match; do
          # match: "./scripts/X.sh"
          local script="$match"
          # Skip if preceded by an http(s):// — but grep already split on line, need to re-check the original line
          local original; original=$(sed -n "${line}p" "$file")
          [[ "$original" =~ https?://[^\ ]*"$script" ]] && continue
          # Cross-check existence
          [[ -f "${BASE_DIR}${script:1}" ]] || \
              report_drift "$file" "$line" "scripts" "missing local script: $script"
      done < <(grep -nEoH "\./scripts/[a-z-]+\.sh" "${audit_files[@]}" 2>/dev/null)
  }
  ```
- [ ] **T034** Run bats → T011, T012, T018 PASS.

### Phase 3f — `audit_npm` (T013, T014)

- [ ] **T035** Implement `audit_npm()`:
  ```bash
  audit_npm() {
      [[ "$SKIP_NPM" = "1" ]] && { info "audit_npm: skipped"; return 0; }
      local files; mapfile -t files < <(enumerate_scope_files)
      while IFS=: read -r file line match; do
          # match: "npm --prefix website run X" OR "(cd website && npm run X)"
          local script; script="${match##* run }"
          # Cross-check KNOWN_NPM_SCRIPTS
          local known=0
          for s in "${KNOWN_NPM_SCRIPTS[@]}"; do
              [[ "$script" = "$s" ]] && { known=1; break; }
          done
          [[ "$known" = "0" ]] && report_drift "$file" "$line" "npm" "unknown website npm script: $script"
      done < <(grep -nEoH "(npm --prefix website run [a-z:-]+|cd website && npm run [a-z:-]+)" "${files[@]}" 2>/dev/null)
  }
  ```
- [ ] **T036** Run bats → T013, T014 PASS.

### Phase 3g — Wire up `main()` dispatcher (T037, T038)

- [ ] **T037** Implement `main()` :
  ```bash
  main() {
      local single_category=""
      while [[ $# -gt 0 ]]; do
          case "$1" in
              --category) single_category="$2"; shift 2 ;;
              --verbose) VERBOSE=1; shift ;;
              --help|-h) show_help; exit 0 ;;
              *) shift ;;
          esac
      done
      if [[ -n "$single_category" ]]; then
          case "$single_category" in
              paths) audit_paths ;;
              verbs) audit_verbs ;;
              flags) audit_flags ;;
              scripts) audit_scripts ;;
              npm) audit_npm ;;
              *) error "Unknown category: $single_category"; exit 2 ;;
          esac
      else
          audit_paths
          audit_verbs
          audit_flags
          audit_scripts
          audit_npm
      fi
      final_report
  }
  main "$@"
  ```
- [ ] **T038** Run bats → ALL 14 prior tests PASS. T016 (env-var hatch) PASS. T017 (zero-FP on real repo) is next.

**Checkpoint**: 14/15 GREEN. Skeleton + 5 categories + dispatcher live.

---

## Phase 4 — Integrate into `audit-base.sh`

- [ ] **T039** In `scripts/audit-base.sh`, define new function:
  ```bash
  audit_docs_drift() {
      info "Auditing docs for syntactic drift..."
      if "$SCRIPT_DIR/audit-docs.sh" >/dev/null 2>&1; then
          report_ok "audit-docs: no drift detected"
      else
          report_issue "audit-docs: drift detected (run scripts/audit-docs.sh for details)"
      fi
  }
  ```
- [ ] **T040** In `scripts/audit-base.sh` main flow, call `audit_docs_drift` between `audit_doc_links` (line ~234) and `audit_counts` (line ~269).
- [ ] **T041** Run `./scripts/audit-base.sh` ; assert exit `0`, output mentions `audit-docs: no drift detected`.

---

## Phase 5 — Zero-FP verification (CRITICAL, T017)

- [ ] **T042** Run `./scripts/audit-docs.sh` against current branch ; capture full output.
- [ ] **T043** Decision tree:
  - **If exit 0 + no drift listed** → T017 passes → proceed.
  - **If exit 1 with drift listed** → investigate each entry:
    - Legitimate finding → fix the underlying drift in a separate commit BEFORE merging this PR (e.g., extend allowlist OR fix doc text)
    - False positive → narrow the audit pattern in `audit-docs.sh` AND add a regression bats test that covers the false-positive shape
  - **If exit 2 (tooling failure)** → fix dependency issue
- [ ] **T044** Re-run until exit 0. Lock the final state.

**Checkpoint**: T017 GREEN. `audit-docs.sh` is silent-clean on the foundation.

---

## Phase 6 — Regen + CHANGELOG + pre-commit guards

- [ ] **T045** Run `npm --prefix website run generate` ; verify `counts.json#tests` reflects new bats count.
- [ ] **T046** Run gauntlet:
  - `./scripts/validate-counts.sh` → exit 0
  - `./scripts/audit-base.sh` → exit 0 (now includes new step)
  - `bash scripts/test.sh` → all pass
  - `npm --prefix website run test:scripts` → exit 0
- [ ] **T047** Add CHANGELOG bullet under `## [Unreleased]` / `### Added`:
  ```
  - **`scripts/audit-docs.sh` doc drift firewall**. New audit
    script catching 5 syntactic drift categories (paths, claude-base
    verbs, init/update CLI flags, local script references, website
    npm scripts) in hand-maintained docs. Integrated into
    `audit-base.sh` so CI gates on it. Allowlist locked in the
    script as bash arrays ; live-derives website npm scripts via
    jq. 5 per-category env-var bypasses for false-positive escape
    hatch. ≥14 new bats tests including 1 regression on PR #199
    drift scenario. Spec at `specs/audit-docs/`.
  ```
- [ ] **T048** Run the protected-name gate over the staged diff: `bash scripts/private-names-check.sh` → expect exit 0.

---

## Phase 7 — Commits + push + PR + watch + merge

- [ ] **T049** 2 commits per `feedback_commit_splits` (same-domain test→feat split):
  - Commit A: `test(audit): add RED tests for doc drift firewall`
    Files: `specs/audit-docs/{spec,plan,tasks}.md` + `tests/audit-docs.bats`
  - Commit B: `feat(audit): add audit-docs.sh + integrate into audit-base.sh`
    Files: `scripts/audit-docs.sh` (new) + `scripts/audit-base.sh` + `CHANGELOG.md` + auto-regen (`counts.json`, `README.md`)
- [ ] **T050** `git push -u origin HEAD`.
- [ ] **T051** Open PR via `gh pr create` ; **PR title MUST NOT contain inner double quotes** (per `feedback_pr_title_no_quotes`).
- [ ] **T052** Watch CI : `sleep 12 && gh pr checks <N> --watch --fail-fast`. Pay special attention to macOS Lint & Test (BSD grep may differ from GNU grep).
- [ ] **T053** On all-green: `gh pr merge <N> --squash --delete-branch`.

---

## Dependencies and Execution Order

```
Phase 1 (T001-T003)  ◄── BLOCKS everything
       │
       ▼
Phase 2 (T004-T019) — TDD RED — 14 tests fail
       │
       ▼
Phase 3a (T020-T026) — Skeleton + env + scope ◄── unlocks 3b-3f
       │
       ▼
Phase 3b (T027-T028) — audit_paths     (T005/T006/T015 green)
       │
       ▼
Phase 3c (T029-T030) — audit_verbs     (T007/T008 green)
       │
       ▼
Phase 3d (T031-T032) — audit_flags     (T009/T010 green)
       │
       ▼
Phase 3e (T033-T034) — audit_scripts   (T011/T012/T018 green)
       │
       ▼
Phase 3f (T035-T036) — audit_npm       (T013/T014 green)
       │
       ▼
Phase 3g (T037-T038) — main() dispatcher (T016 env-hatch green)
       │
       ▼
Phase 4 (T039-T041) — Integrate into audit-base.sh
       │
       ▼
Phase 5 (T042-T044) — Zero-FP verification (T017 green) ◄── CRITICAL
       │
       ▼
Phase 6 (T045-T048) — Regen + CHANGELOG + guards
       │
       ▼
Phase 7 (T049-T053) — Commits + PR + merge
```

### Story dependencies

| Story | Can start after | Notes |
|-------|-----------------|-------|
| US-1 (drift caught) | Phase 3g | All 5 categories live |
| US-2 (clear errors) | Phase 3a | `report_drift` shape locked |
| US-3 (audit-base integration) | Phase 4 | T039-T041 |
| US-4 (allowlist extend) | Phase 3a | T023 |
| US-5 (env var hatch) | Phase 3a + per-category | T021 + per-cat guards |
| US-6 (regression tests) | Phase 2 | T015 (PR #199 fixture) |
| US-7 (--verbose) | Phase 3a | T022 |
| US-8 (--category) | Phase 3g | T037 |

---

## Implementation Strategy

### MVP path (~3-4h focused work)

1. Phase 1 (~10 min)
2. Phase 2 RED (~60 min — write 14 bats tests, verify each fails for the expected reason)
3. Phase 3 GREEN (~90-120 min — 5 audit functions + dispatcher)
4. Phase 4 (~15 min — audit-base integration)
5. Phase 5 (~15 min — zero-FP verify) ◄── could be longer if real drift surfaces
6. Phase 6 (~15 min — CHANGELOG + regen)
7. Phase 7 (~30 min — 2 commits + PR + CI watch + merge)

### Solo strategy

Linear walk through phases. [P] markers within Phase 3 refer to the fact that each category could theoretically be parallel, but a sequential walk gives faster iteration on the bats feedback loop.

---

## Notes

- **TDD is mandatory** per `.claude/rules/workflow.md`. The audit script is pure logic — perfect for TDD.
- **Phase 5 is the highest-value gate** — if the audit catches drift on current main, that's its first earned-keep moment. Document any findings.
- **macOS portability** : `grep -nEoH` works on both GNU and BSD grep. Avoid GNU-specific `\b` word boundaries.
- **Memory anchors active**:
  - `feedback_verify_code_claims` — every allowlist entry derived from grep on live code (this plan)
  - `feedback_bsd_seq_zero_range` — no `seq` patterns in the script (uses while-read loops instead)
  - `feedback_pr_title_no_quotes` — T051 PR title constraint
  - `feedback_website_docs_mirror_sync` — N/A (audit doesn't edit docs)
  - `feedback_no_project_names` — T048 grep guard
  - `feedback_commit_splits` — T049 test→feat split

**To avoid**:
- Implementing any `audit_X` before its bats tests fail (TDD violation)
- Silencing a real drift in Phase 5 by extending allowlist without rationale
- Editing real docs during test development (`$TEST_DIR` heredoc fixtures only)
- Skipping macOS CI signal (BSD grep can surprise)
- Adding a 6th category not in the spec

---

**Version**: 1.0 | **Created**: 2026-05-19
