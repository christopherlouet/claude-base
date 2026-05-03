---
sidebar_position: 5
title: "/ops:ops-cost"
description: "Track token consumption and Claude Code costs."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# OPS-COST Agent

Track token consumption and Claude Code costs.

## Context
`<arguments>`

## Objective

Analyze and display token consumption metrics to optimize costs.

## Measurement tools

### ccusage (recommended)

```bash
# Installation
pip install ccusage

# Total consumption
ccusage

# Per project
ccusage --project

# Per day
ccusage --daily

# Specific period
ccusage --since 2026-03-01 --until 2026-03-23
```

### RTK (optimization)

```bash
# Installation
brew install rtk

# View the savings achieved
rtk gain

# Discover unoptimized commands
rtk discover
```

Enable RTK: add `ENABLE_RTK=1` in `env` of `.claude/settings.json`.

## Reduction strategies

| Strategy | Savings | How |
|----------|---------|-----|
| RTK rewrite | 60-90% | Automatically active via PreToolUse hook |
| `/compact` between phases | 20-40% | Reduce accumulated context |
| Haiku agents for simple tasks | 50-70% | Exploration, reading, search |
| Focused session scope | 30-50% | 1-5 tasks per session max |
| Lightweight CLAUDE.md files | 10-20% | Less context loaded at startup |

## Expected output

1. **Metrics**: Tokens consumed (input/output), estimated cost
2. **Trends**: Evolution per day/week
3. **Recommendations**: Applicable optimization strategies

---

IMPORTANT: ccusage reads Claude Code local logs, no data is sent externally.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
