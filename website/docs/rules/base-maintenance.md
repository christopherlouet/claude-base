---
sidebar_position: 5
title: "base-maintenance"
description: "Any addition, removal or rename in `.claude/` silently breaks the docs and tests if counters are not kept in sync. The PostToolUse hook `base-integrit"
tags:
  - "rule"
  - "base-maintenance"
---

# Rules: base-maintenance

> Any addition, removal or rename in `.claude/` silently breaks the docs and tests if counters are not kept in sync. The PostToolUse hook `base-integrity-check` warns but does not block — discipline is 

## Affected files

These rules apply to files matching the following patterns:

- `.claude/skills/**`
- `.claude/agents/**`
- `.claude/commands/**`
- `.claude/rules/**`
- `.claude/settings.json`
- `scripts/hooks/**`

## Detailed rules

# Foundation Maintenance

## Principle

Any addition, removal or rename in `.claude/` silently breaks the docs and tests if counters are not kept in sync. The PostToolUse hook `base-integrity-check` warns but does not block — discipline is on whoever makes the change.

## Mandatory checklist before commit

| Check | Command | Blocking |
|-------|---------|----------|
| Doc counters consistent | `./scripts/validate-counts.sh` | Yes |
| SessionStart message up to date | Inspect `.claude/settings.json` (hardcoded commands / agents) | Yes if addition/removal |
| Catalog up to date | Check `docs/reference/agents-catalog.md` and `docs/reference/skills-catalog.md` | Yes |
| Rules README up to date | `.claude/rules/README.md`: row + header counter | Yes if new rule |
| Structural audit | `./scripts/audit-base.sh` | Recommended |
| Shellcheck on new hooks | `shellcheck scripts/hooks/*.sh` | Yes |

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

NEVER duplicate counter information anywhere other than the files listed above — centralize in `validate-counts.sh` as the source of truth.

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
