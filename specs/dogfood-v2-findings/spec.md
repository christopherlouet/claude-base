# Dogfood findings — v2.0.0 release readiness

> **Status**: post-release audit · captured 2026-05-22 (same day as v2.0.0 cut)
> **Method**: maintainer ran `claude-base update --dry-run --all` against a private project last synced to v1.32 (pre-Wave-1), observed friction without performing the actual update.
> **Outcome**: 6 frictions identified, ordered by impact below. No regression introduced; the project was not modified.

## Why this spec exists

v2.0.0 shipped the "workflow framework + curator" positioning pivot ([`foundation-positioning-review/spec.md`](../foundation-positioning-review/spec.md)). The release was technically clean (CI green, release workflow successful) but had never been exercised end-to-end on a real user project before publication. This audit is the first dogfood pass.

The findings below are not deal-breakers for v2.0.0 — the upgrade path *works* — but each represents friction a real user would hit on first contact with the major version. Fixing them lifts the threshold from "works with effort" to "works without thinking", which is the v2.0.0 positioning promise.

## Findings

### 1. Dispatcher CLI absent from PATH after extended period

**Symptom**: a user who installed claude-base months ago via `curl | bash` no longer has `~/.local/bin/claude-base` on their system. The symlink and `~/.local/share/claude-base` are both missing. The project's `.claude/` directory still exists locally with 3 backup folders (`.claude/commands.backup.2026-04-16`, `.2026-05-04`, `.2026-05-09`) confirming the project was updated 3 times before drift.

**Impact**: user cannot run `claude-base update` without first re-installing the dispatcher. The v2.0.0 migration guide in CHANGELOG.md does not mention this scenario.

**Likely cause**: OS housekeeping, partial filesystem migration, manual cleanup, or a one-off `rm` that wasn't intended to remove the dispatcher. The exact cause is hard to reproduce; the *recovery* is what matters.

**Proposed fix** (low effort): add a "If the CLI is missing, re-run the installer" troubleshooting line to the v2.0.0 CHANGELOG entry + a brief section to `docs/guides/TROUBLESHOOTING-GUIDE.md`. The installer is already idempotent (`install.sh` handles re-install via `--update` or fresh install if target dir absent).

**Effort**: ~15 min documentation PR.

---

### 2. Counter delta is wrong in `update` output

**Symptom**: `claude-base update --dry-run --all` against a v1.32 install prints:

```
[INFO] Commands: 131 → 131
```

Both numbers are wrong relative to the actual transition. v2.0.0 has 128 commands (Wave 2/3 removed 3). The expected output would be:

```
[INFO] Commands: 131 → 128 (-3 deprecated)
```

**Impact**: user reads "131 → 131" and assumes nothing is removed, then is surprised when `validate` later reports drift, or when slash commands they relied on (e.g. `/doc:doc-i18n`) silently disappear.

**Likely cause**: `scripts/update.sh` computes the delta against locally-modified count rather than the foundation's `counts.json`. The exact location of the bug needs investigation — likely a `find | wc -l` over the project's current state, before/after, instead of a diff against the foundation manifest.

**Proposed fix**: read `counts.commands` from the foundation's `counts.json`, compare against the project's actual count, print the real delta. Add a bats regression test.

**Effort**: ~1h investigation + fix + test.

---

### 3. `--dry-run` poses interactive prompts (CRITICAL for agents/CI)

**Symptom**: `claude-base update --dry-run --all` issues `[y/n/d]` prompts on every "modified" file. Sample output:

```
[?] work-flow-release.md has been modified. What to do?
  [y] Overwrite  [n] Skip  [d] View diff
```

When stdin closes (no TTY / piped invocation / agent loop), the subshell receives EOF on the first prompt and dies. Subsequent commands fail because the shell state is corrupted.

**Impact**: dry-run is unusable in any non-interactive context: CI, agents driving claude-base, scripts wanting to preview an update. The whole point of `--dry-run` (predict-before-act) is defeated when it requires the same interaction as the real run.

**Proposed fix**: in `scripts/update.sh`, treat `--dry-run` as implying `--yes` for the *display* side — log "would skip" / "would overwrite" deterministically without prompting. The current `--yes` flag exists but does NOT compose with `--dry-run` to suppress prompts. This should compose.

**Effort**: ~1h fix + add bats test that pipes empty stdin into `update --dry-run --all` and asserts it completes with exit 0.

**Severity**: blocking for anyone driving claude-base from automation (the agent ecosystem this foundation is designed for).

---

### 4. "Has been modified" message is misleading after major foundation releases

**Symptom**: after v2.0.0, `update` reports the following 9 files as "has been modified" against the v1.32 baseline:

```
work-flow-release.md, dev-rag.md, dev-document.md, growth-seo.md,
growth-localization.md, biz-pricing.md, data-pipeline.md,
ops-monitoring/SKILL.md, dev-i18n/SKILL.md
```

The user has not edited any of these locally. The message *should* communicate "this file changed in the foundation between v1.32 and v2.0.0 — review the diff to confirm you want the new version". The current message implies the user themselves modified the file.

**Impact**: a user who knows they haven't touched the file panics ("did I edit this and forget?"), opens the diff, sees foundation-source-code changes, and is confused. Slows down adoption of major versions specifically — minor patches have fewer diffs and less surface for misreading.

**Proposed fix**: in the file-comparison logic, distinguish "user-modified" (local mtime > install mtime) from "foundation-changed" (foundation hash != current install hash). Show different messages:

- *User-modified*: "You have local changes. Overwrite? [y/n/d]"
- *Foundation-changed*: "Foundation updated this file. View the new version? [y/n/d]"

**Effort**: ~2h — the local vs foundation hash distinction requires a small refactor of the comparison function.

---

### 5. `--clean` implicit behaviour with `--all` is undocumented

**Symptom**: `update --dry-run --all` (without explicit `--clean`) prints:

```
[DRY-RUN] rm -rf .claude/commands
[DRY-RUN] rm -rf .claude/skills
[DRY-RUN] rm -rf .claude/agents
...
```

`--all` apparently implies `--clean`. The help text lists them as separate flags without noting the implication.

**Impact**: a cautious user passes `--all` expecting "update everything" not "delete everything then put it back". Discovery of the `rm -rf` lines mid-dry-run is alarming even if the behaviour is correct.

**Proposed fix**: either (a) make `--clean` truly separate from `--all` (require explicit opt-in for the delete step), or (b) document that `--all` implies `--clean` in the help text and add a banner at the start of the update:

```
[INFO] --all enabled: this will replace .claude/{commands,skills,agents,...}
       entirely. Use --no-clean to preserve user-added files.
```

**Effort**: ~30 min documentation + flag composition cleanup, no behaviour change required.

---

### 6. Version-pinning mechanism: gap analysis (REVISED 2026-05-22)

> **Original framing was wrong.** Initial spec entry claimed the foundation lacked a per-project version marker. Post-write audit found `write_foundation_marker` (in `scripts/lib/common.sh:540`) IS wired into `new-project.sh:1196, 1261, 1784` (init) and `update.sh:1593` (post-update). The marker file is `<target>/.claude/.foundation-version`, tested by 3 bats files (`new-project.bats`, `update.bats`, `common.bats`). Friction was overstated by failing to `grep "write_foundation_marker"` (used the literal filename `.foundation-version` instead, missing the indirect calls). Lesson reinforced [[feedback-verify-code-claims]].

**What's actually in place** (verified 2026-05-22):

- ✓ `.foundation-version` written on every `init` (`new-project.sh:1196/1261/1784`).
- ✓ `.foundation-version` written on every successful `update` (`update.sh:1593`, skipped in dry-run).
- ✓ Pre-flight read in `update.sh:215-217`: shows `project: <version>` in the banner when a marker exists.
- ✓ Tests assert: marker is written on init, written on update, NOT modified by dry-run.

**What's actually still gapping** (smaller scope):

1. **Backfill for pre-marker projects**: projects that haven't been `update`d since the marker mechanism shipped (e.g. observed in one project on the maintainer's machine) have no `.foundation-version`. *Auto-resolves on first real `update`*, so this is friction the user hits once and never again. No fix needed — just verify the first-update path handles a missing marker gracefully (it does today: writes the marker post-update, no error on missing pre-state).

2. **Pre-flight delta not shown**: `update.sh:215-217` prints `project: 1.41.2` in the banner but does NOT compare against the foundation's current `$VERSION` to print `1.41.2 → 2.0.0 (major)`. Minor UX gap — a delta line would tell the user "you're about to make a major version jump" at a glance.

3. **No version-specific migration hook**: `update.sh` reads the previous version but never branches on it. There's no mechanism like `if old_version < 2.0.0 then run_v2_migration_steps`. This is *nice-to-have*, not blocking — claude-base hasn't yet needed a major migration that couldn't be expressed via the existing file-overwrite + orphan-detection flow.

**Revised severity**: low. Gap #1 self-heals, #2 is cosmetic, #3 is speculative.

**Proposed fix** (if any work is done at all): add ~5 lines to the banner in `update.sh` to compute `<previous> → <new>` and tag it `(patch / minor / major)`. Skip gap #3 entirely until a real migration justifies the framework cost.

**Effort**: ~30 min if scoped to #2 only. ~0 if deferred.

---

## Prioritization

| # | Friction | Severity | Effort | Status |
|---|---|---|---|---|
| 3 | `--dry-run` interactive | **CRITICAL (agents/CI)** | ~1h | ✅ **fixed in PR #248** (merged 2026-05-22) |
| 2 | Counter delta wrong | medium | ~1h | ✅ **fixed in PR #251** (merged 2026-05-22) |
| 4 | "Modified" message | medium | ~2h | ⏳ next — UX polish |
| 6 | Pre-flight version delta UI | low (REVISED) | ~30 min | ⏳ pending — see revised entry above; marker mechanism already exists |
| 5 | `--clean` doc | low | ~30 min | ⏳ pending — doc-only |
| 1 | CLI re-install doc | low | ~15 min | ⏳ pending — doc-only |

**Aggregate effort**: ~6 hours across 6 PRs. Could be batched into 2-3 PRs if a maintainer wants atomic shipping (e.g. #3+#6 as the "automation-friendly update" PR, #2+#4 as the "update UX clarity" PR, #1+#5 as the "v2.0.0 docs polish" PR).

## Out of scope

This audit ran against one project on one preset (Next.js, pre-Wave-1 baseline). Friction unique to other presets (`fastapi`, `astro`, `homelab-proxmox`, `cli-tools`, `phaser`, `playwright`, `pulumi`, `apollo`, `mongodb`, `react-vite-spa`) is not covered. A subsequent dogfooding pass on `homelab-proxmox` (the rare preset) and `cli-tools` (the empty-vendor-skills preset) would surface preset-specific bugs that this report does not catch.

## Related memories

- [[project-foundation-positioning-review]] — the parent strategic work that v2.0.0 closes
- [[feedback-verify-code-claims]] — the dogfooding mindset this audit operationalises
