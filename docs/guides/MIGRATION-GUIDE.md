# Migration Guide — Bilingual Documentation Translation with Claude

> **Status**: Reference document. Generated from the FR → EN migration of the
> claude-socle repository (April 2026). Replicable on any project with a
> similar markdown-heavy documentation surface.

This guide describes the harness in `scripts/migration/` and how to adapt it
to translate a project's documentation from one language to another using
Claude Code in headless mode.

## When to use this harness

This harness is designed for projects where:

- Documentation is markdown-heavy (hundreds of files, hundreds of thousands
  of words)
- Consistent terminology matters (a single FR term must always map to the
  same EN term)
- Internal references are critical (slash commands, file paths, anchors,
  frontmatter keys must be preserved character-for-character)
- The work fits in 2-4 overnight headless runs (Claude Max subscription,
  not API)

For smaller projects (< 50 files), manual translation is faster than setting
up the harness. For very large projects (millions of words), professional
translation services are likely cheaper than Claude Max session quotas.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  inventory.sh ──────▶ inventory.json (per-tier file lists)       │
│                              │                                   │
│                              ▼                                   │
│  glossary.yaml ──┐    translate-batch.sh                         │
│  blacklist.txt ──┼──▶  ├── recovery.sh init/list-pending         │
│  prompt-template ┘     ├── build-prompt.py (substitute)          │
│                        ├── claude --print (Max headless)         │
│                        ├── validate-translation.sh               │
│                        │   ├── check-refs.sh                     │
│                        │   ├── check-structure.sh                │
│                        │   └── check-glossary.sh                 │
│                        └── recovery.sh mark-done + git commit    │
│                              │                                   │
│                              ▼                                   │
│                       create-tier-pr.sh ──▶ GitHub PR            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Concepts

### Tier

A logical grouping of files translated as one batch and shipped as one PR.
Tiers are ordered by criticality:

- **Tier 1**: showcase content (README, top-level docs, rules) — reviewed
  by a human before merge, sets the tone for the rest
- **Tier 2-N**: incremental content — opened as draft PRs after the
  overnight run, sampled in the morning, merged after sampling

The split into 4 tiers in claude-socle was chosen to match natural
boundaries (audience-facing vs internal config vs auto-generated). Adapt
to your project's structure.

### Glossary

A YAML file (`glossary.yaml`) listing canonical translations:

```yaml
locked_at: null  # set by lock-glossary.sh
terms:
  - fr: socle
    en: foundation
    forbidden: [scaffold, base, framework]
    context: "central concept of the project"
  - fr: boucle
    en: loop
    forbidden: [cycle, iteration]
    context: "cycle is reserved for Red-Green-Refactor"
```

The glossary is **locked** before the second night run. Locking prevents
silent drift if someone modifies it mid-migration. Lock = setting
`locked_at` and per-term `locked: true` + creating a git tag.

### Blacklist

A flat-text file (`blacklist.txt`) of substrings that must appear
character-for-character in the translated output:

- All slash commands (`/work:work-explore`, `/dev:dev-tdd`, …)
- All paths visible in prose (`docs/guides/PROMPTING-GUIDE.md`)
- All frontmatter keys (`name:`, `type:`, `description:`)
- All identifier-like strings (`SKIP_PROMPT_CONTEXT`, env vars, technical
  identifiers)

Word-boundary matching is used: `/work:work-explore` is correctly
distinguished from `/work:work-explorer`.

### State

A JSON file per tier (`state-tier-N.json`) tracking translation status
per file:

```json
{
  "tier": 1,
  "files": [
    { "path": "README.md", "status": "draft",
      "checksum_source": "abc123…" }
  ]
}
```

Statuses: `todo` → `draft` → `reviewed` → `merged`. The runner only
processes `todo` files. Recovery from a crashed batch is automatic: re-run
the batch, it picks up where it left off.

### Validators

Three validators run after each translation, before commit:

- **check-refs.sh** — verifies blacklisted terms, slash commands, and file
  paths appear in the translated output as often as in the source
- **check-structure.sh** — verifies heading counts (H1/H2/H3), code fence
  count, and frontmatter keys are identical
- **check-glossary.sh** — verifies forbidden translations don't appear
  (with code-block exclusion to avoid false positives)

Validators are TDD-tested. Their bats tests live in `tests/migration/`.

## Setup checklist

1. **Inventory your scope**

   Adapt `scripts/migration/inventory.sh` to your tier definitions. Run it
   to produce `inventory.json` and review the file counts and word counts.

2. **Seed the glossary**

   Identify recurring terms in your source language (frequency analysis
   helps; `grep -roE '[a-zA-Zàâéèêëïîôùûüç]+' . | sort | uniq -c | sort -rn |
   head -200`). Add them to `glossary.yaml` with their canonical EN
   translations and forbidden alternatives. 50-100 terms is typically
   enough.

3. **Build the blacklist**

   List every slash command, file path pattern, frontmatter key, and
   identifier that must NOT be translated. The validator catches missing
   blacklist items in the diff between source and translated output.

4. **Adapt the prompt template**

   `scripts/migration/translate-prompt.md` defines the instructions Claude
   sees. The hard rules section is critical: it tells Claude what to
   preserve verbatim (frontmatter keys, slash commands, paths, code
   blocks). Test the prompt on 3-5 sample files before launching the full
   batch.

5. **Pre-flight**

   - Verify `claude --print "Bonjour"` works headlessly on your VM (you
     should get a translation back). Use `claude setup-token` for headless
     auth on Claude Max.
   - Ensure `bats tests/migration/` is green.
   - Adjust the CI workflow to tolerate a bilingual phase
     (`scripts/validate-counts.sh --mixed` in the claude-socle case).

6. **Branch strategy**

   We chose 4 PRs successive on `main` (one per tier). Each tier branches
   from `main`, after the previous tier merges. Rollback is granular.
   Avoid the "long branch merged at the end" pattern — it creates an
   unmergeable PR and defeats the purpose of incremental delivery.

## Running the migration

### Pre-flight test (single file, real Claude)

Always run a single-file test before the overnight batch. This validates
the prompt and the harness end-to-end, with the smallest possible blast
radius.

```bash
# Render the prompt for a specific file (no Claude call):
scripts/migration/translate-batch.sh --print-prompt README.md > /tmp/prompt.txt
# Read /tmp/prompt.txt to verify it looks right.

# Then translate one file with --no-commit so you can inspect manually:
scripts/migration/translate-batch.sh --tier 1 --limit 1 --no-commit
git diff README.md   # inspect the translation
# If unsatisfactory: git restore README.md, adjust prompt, retry.
```

### Overnight batch

```bash
# Launch in background with logging:
nohup scripts/migration/translate-batch.sh --tier 1 \
    > specs/migration-fr-en/nuit-1.log 2>&1 &
echo $! > specs/migration-fr-en/nuit-1.pid

# Monitor from another shell:
scripts/migration/status.sh --watch        # dashboard
tail -f specs/migration-fr-en/nuit-1.log   # raw log
```

### Recovery

If a batch crashes mid-night, `state-tier-N.json` retains the per-file
progress. Simply relaunch:

```bash
scripts/migration/translate-batch.sh --tier 1
# Picks up from where it stopped (skips files already in "draft" status).
```

## Lessons learned (claude-socle)

These notes summarize what worked and what we'd do differently next time.

### What worked

- **TDD on validators**: writing the bats tests before the validator
  scripts caught several bugs in the regex word-boundary logic.
- **State file granularity per file**: easy to reason about, easy to
  recover, easy to display progress.
- **Tier 1 with hybrid review (method D)**: 1.5-2h human review of the
  showcase content, automated validators on the rest. Catches the
  "looks weird in EN" cases that automated tools can't see, while keeping
  the review budget reasonable.
- **Glossary lock before tier 2**: the human review of tier 1 may
  uncover terminology choices to revise. Locking after tier 1 review
  ensures all subsequent tiers use the validated vocabulary.

### What we'd do differently

- **Smaller initial scope estimate**: we estimated 410k words from a
  naïve `find` + `wc`. Reality was 254k (~38% less) because website docs
  are auto-generated from `.claude/*` and didn't need separate translation.
  Always verify what's auto-generated before counting.
- **Earlier safety guard for --dry-run**: the runner initially wrote
  DRY-RUN markers into real files when `--root` defaulted to the script's
  own repo. The fix was a one-line check, but caught only after the bug
  triggered.
- **Pre-built prompt rendering mode**: `--print-prompt <file>` was added
  late. It's invaluable for prompt iteration; should be in the harness
  from day 1.

### Pitfalls to avoid

- **Don't use `--bare`** with Claude Max + `setup-token` unless you've
  verified it works. `--bare` is API-key-only by design.
- **Don't translate identifiers** (variable names, function names) even
  if they're in the source language. Renaming them is a separate refactor
  and can break downstream code/tests. The default rule: translate
  comments, keep identifiers.
- **Don't auto-merge tier PRs**. Even tiers 2-4 (draft) deserve a sample
  before merge. Drift can creep in subtly.

## Adapting to a different project

Most of the harness is project-agnostic. The parts you'll customize:

- `scripts/migration/inventory.sh` — tier definitions (which files belong
  where)
- `specs/migration-fr-en/glossary.yaml` — your terminology
- `specs/migration-fr-en/blacklist.txt` — your project's intraduisibles
- `scripts/migration/translate-prompt.md` — domain-specific instructions
  (e.g., "preserve French legal terminology in section X")

The validators and runner are generic and can be lifted as-is.

## Related

- `specs/migration-fr-en/spec.md` — original spec for the claude-socle
  migration
- `specs/migration-fr-en/plan.md` — original plan
- `specs/migration-fr-en/journal.md` — execution log of the 4 nights
- `tests/migration/` — TDD tests for the validators and the runner
