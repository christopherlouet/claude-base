---
paths:
  - ".claude/skills/**"
  - ".claude/agents/**"
  - ".claude/commands/**"
  - ".claude/rules/**"
  - ".claude/settings.json"
  - "scripts/hooks/**"
---

# Foundation Maintenance

## Principle

Any addition, removal or rename in `.claude/` silently breaks the docs and tests if counters are not kept in sync. The PostToolUse hook `base-integrity-check` warns but does not block — discipline is on whoever makes the change.

## Generated artifacts — never hand-edit `website/docs/`

`website/docs/` is **fully auto-generated** from `docs/` and `.claude/` by `npm --prefix website run generate`:

- `sync-docs.ts` mirrors `docs/` → `website/docs/{reference,guides,concepts}` (adds Docusaurus frontmatter, rewrites links, escapes MDX).
- `generate-{command,agent,skill,rule}-docs.ts` produce the per-resource pages from `.claude/` (that is why `website/docs/` has ~364 files vs ~21 in `docs/`).

Every generated file carries a `<!-- Auto-generated from docs/ - DO NOT EDIT -->` banner.

| Do | Don't |
|----|-------|
| Edit the **sources**: `docs/`, `templates/`, `.claude/` | Edit any file under `website/docs/` by hand — it is overwritten on the next generate |
| After editing a source doc or a `.claude/` resource, run `npm --prefix website run generate` and commit the regenerated `website/docs/` alongside | Push a source change without regenerating — the committed mirror goes stale |

CI enforces this: the `ci.yml` **"Counts gate"** re-runs `generate` and fails the PR via `git diff --exit-code` on `docs/`, `website/docs/`, `counts.json`, `README.md`, `CLAUDE.md` and the Docusaurus config if the committed output is out of sync.

## Mandatory checklist before commit

| Check | Command | Blocking |
|-------|---------|----------|
| Doc counters consistent | `./scripts/validate-counts.sh` | Yes |
| SessionStart message up to date | Inspect `.claude/settings.json` (hardcoded commands / agents) | Yes if addition/removal |
| Catalog up to date | Check `docs/reference/agents-catalog.md` and `docs/reference/skills-catalog.md` | Yes |
| Rules README up to date | `.claude/rules/README.md`: row + header counter | Yes if new rule |
| Structural audit | `./scripts/audit-base.sh` | Recommended |
| Shellcheck on new hooks | `shellcheck scripts/hooks/*.sh` | Yes |
| Self-application test on a new guardrail/tool | Run it against the REAL foundation in a bats test (see below) | Yes — for any new hook / validator / detector / gate |

## Self-application tests (every guardrail / tool)

A foundation **guardrail, validator, detector, or gate** (a hook, a `scripts/*.sh`
that inspects the repo, a drift-guard) MUST ship with a **self-application test**:
a bats case that runs the tool against the **real foundation** (no mocks) and
asserts the expected outcome — in addition to any fixture/fake unit tests.

**Why.** Fixture/fake tests verify the *runner logic*; only running the tool on
the real repo verifies its *behavior*. Repeatedly, the self-application test is the
one that caught the real bug while the unit tests stayed green:

- `substance-check.sh` → asserts **0 findings on the foundation's own `tests/`**
  (caught self-false-positives: heredoc'd `@test`, bats `skip` env-guards).
- `preflight.sh` → an integration case running the **real fast gates** on the repo
  (caught a `shellcheck` version-drift the env-faked gate tests missed).
- `manifest-hooks-coverage.bats` → every `settings.json` hook ships in the manifest
  (caught the unshipped `config-protection.sh` — only in CI, before this rule).
- `sync-counts.sh` → the pre-commit healed **its own PR's** count drift.

**How.** Alongside the fakes, add ≥1 test that:
1. runs the tool on the real repo (or the real `tests/`/`scripts/`/`.claude/`), and
2. asserts the real result — usually "**passes / 0 findings on a clean tree**",
3. **plus** that it is not trivially empty — it still flags a known-bad fixture.

The "0 on our own corpus" assertion is also a **standing regression guard**: it
fails the day a real drift appears.

## Files to update when adding / removing

### New command (`.claude/commands/<ns>/<cmd>.md`)

- `README.md`: "Available Commands (N)" line + inline mention
- `CLAUDE.md`: "N commands" counter
- `website/src/pages/index.tsx`: `'N Commands'`
- `website/docs/intro/architecture.md`: `Commands (N)`
- `website/docs/intro/index.md`: `Commands N`
- `website/docs/reference/cheatsheet.md`: `N Commands | M Agents`
- `website/src/components/FeatureComparison.tsx`: `commands: 'N'`
- `website/docusaurus.config.ts`: `Commands (N)`
- `docs/reference/commands.md`: catalog entry

### New agent (`.claude/agents/<ns>/<agent>.md`)

- All `agents: 'N'` / `Agents (N)` / `N sub-agents` files
- `docs/reference/agents-catalog.md`: entry with description + use case
- `.claude/settings.json` SessionStart hook (agents counter)

### New skill (`.claude/skills/<skill>/SKILL.md`)

- All `skills: 'N'` / `N Skills`
- `docs/reference/skills-catalog.md`: entry with trigger conditions
- `CLAUDE.md`: "N skills" counter

### New rule (`.claude/rules/<rule>.md`)

- `.claude/rules/README.md`: row in the table + "Available rules (N)" counter
- `website/docs/reference/rules.md` if present
- "Priority order" section if the rule has a specific priority level

## Red Flags — STOP immediately

| Signal | Reaction |
|--------|----------|
| Adding a `.claude/*.md` file without updating counters | STOP — run `./scripts/validate-counts.sh` |
| Renaming a rule / agent / skill | STOP — search for all references with Grep before commit |
| Modifying `.claude/settings.json` without local test | STOP — start a Claude session and check the SessionStart hook |
| Hook exceeding its timeout | STOP — profile before push, a slow hook blocks every prompt |
| New hook without `|| true` or bail-out | STOP — a hook that fails breaks the session for everyone |

## Absolute rules

IMPORTANT: NEVER push a commit that adds/removes in `.claude/` without having run `./scripts/validate-counts.sh`.

IMPORTANT: A `UserPromptSubmit` or `PostToolUse` hook must always bail out quickly (exit 0) if its dependency is missing (`jq`, `gh`, `git`). A hook that errors breaks the UX.

IMPORTANT: The counters hardcoded in the SessionStart hook are the first thing the user sees when opening Claude Code — a wrong number gives the impression of a poorly maintained foundation.

NEVER commit a script in `scripts/hooks/` without shellcheck + real-world testing.

IMPORTANT: A new guardrail / validator / detector / gate MUST ship a self-application test (run it on the real foundation, assert the outcome) — fixture/fake tests alone repeatedly stayed green while the tool was broken on the real repo.

NEVER duplicate counter information anywhere other than the files listed above — centralize in `validate-counts.sh` as the source of truth.
