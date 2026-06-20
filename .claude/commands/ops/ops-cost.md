# OPS-COST Agent

Track and optimize costs: Claude Code token consumption **and** cloud infrastructure (FinOps).

## Context
$ARGUMENTS

## Objective

Two complementary cost angles:
1. **Claude Code tokens** — analyze and display token consumption metrics to reduce usage cost.
2. **Cloud infrastructure (FinOps)** — identify opportunities to cut cloud spend without
   impacting performance or availability, with an actionable report.

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

## Reduction strategies

| Strategy | Savings | How |
|----------|---------|-----|
| `/compact` between phases | 20-40% | Reduce accumulated context |
| Haiku agents for simple tasks | 50-70% | Exploration, reading, search |
| Focused session scope | 30-50% | 1-5 tasks per session max |
| Lightweight CLAUDE.md files | 10-20% | Less context loaded at startup |

## Cloud infrastructure cost optimization (FinOps)

For the cloud-spend angle:

- Establish cost visibility (tags, per-provider tools).
- Right-size (CPU, memory, disk, network); schedule auto-stop for non-prod environments.
- Analyze commitments (Reserved, Savings Plans, Spot); spot orphan resources, CDN, ARM.
- Produce a report: current spend, identified savings, required effort — split into quick wins
  (< 1 week), medium- and long-term actions; define FinOps metrics to track.
- IMPORTANT: never optimize at the expense of availability or security; set budget alerts
  BEFORE optimizing; never delete resources without verifying actual usage.

## Expected output

1. **Token metrics**: tokens consumed (input/output), estimated cost, trends per day/week
2. **Cloud FinOps report**: current spend, savings, quick wins + medium/long-term actions
3. **Recommendations**: applicable optimization strategies (both angles)

---

IMPORTANT: ccusage reads Claude Code local logs, no data is sent externally.
