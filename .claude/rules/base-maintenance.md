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
| SessionStart banner counts | None — the hook computes them dynamically (`find … \| wc -l` in `.claude/settings.json`), so they cannot drift | No |
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

## Widening a detector pattern — measure the delta first

A guard built from regexes is tuned against invented examples and drifts. Reading
the patterns again proves nothing; **measure** what a change costs in false blocks:

```bash
scripts/validator-corpus.sh --summary   # before
# …widen the pattern…
scripts/validator-corpus.sh             # after: which commands now get refused
```

The corpus is the foundation's own commands — what CI executes and what the docs
tell a reader to run — because a refusal there is a self-contradiction.
`tests/validator-corpus.bats` pins the result: every refusal must be a reviewed
exception, so a widening that starts taxing ordinary documented commands fails
with the offending command named. Refusing *fewer* commands never fails.

Precedent: the loop guard shipped the literal `yes \|`, which refused
`echo YES || echo NO` while the real generator escaped as `yes|consumer`. It was
found by tripping over it in normal work, not by review.

## New shell-script portability (macOS bash 3.2)

CI runs a **macOS column** (system bash is **3.2**) alongside Linux. A new
`scripts/**.sh` that passes on Linux (bash 5) can still fail only on macOS — and
the failure is opaque (the script dies with no stdout; bats shows only the
assertion line). Write defensively:

- **No command-laden `${VAR:-…}` defaults.** A default like
  `${X:-cmd && y || echo "z"}` mis-parses on bash 3.2. Build the value with plain
  `if/elif/else` instead.
- **No empty-array expansion under `set -u`.** `${arr[@]}` / `${arr[*]}` on an
  empty array errors on 3.2. Use a counter + space-separated string, or drop `-u`.
- **ASCII only in EXECUTED strings** (echoed output, test-matched text). Non-ASCII
  (`…`, `✓`, em-dash) is fine in comments, risky in `echo`/`printf` on 3.2 locales.
- **Never assume CI runners share your local tools.** The GitHub **macOS runner
  ships no `shellcheck`**; a script that shells out to a tool must guard it
  (`command -v tool >/dev/null 2>&1 || skip-with-notice`) or it fails only on macOS.
  CI's Linux job is the authoritative run of each tool.

Catch it locally: `scripts/preflight.sh` runs the foundation gates pre-push, but
true bash-3.2 behavior only shows on the macOS CI column — keep new scripts simple.

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

IMPORTANT: The SessionStart banner counts are the first thing the user sees when opening Claude Code. They are computed dynamically by the hook (`find … | wc -l`), so they cannot drift — do NOT reintroduce a hardcoded number there.

NEVER commit a script in `scripts/hooks/` without shellcheck + real-world testing.

IMPORTANT: A new guardrail / validator / detector / gate MUST ship a self-application test (run it on the real foundation, assert the outcome) — fixture/fake tests alone repeatedly stayed green while the tool was broken on the real repo.

NEVER duplicate counter information anywhere other than the files listed above — centralize in `validate-counts.sh` as the source of truth.
