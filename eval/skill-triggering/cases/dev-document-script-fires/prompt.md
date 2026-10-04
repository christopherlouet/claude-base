---
max_turns: 3
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep, Write, Edit]
tags: [positive]
---

Write scripts/monthly-report.js, run by cron on the 1st of each month: it reads data/sales.csv and writes reports/<YYYY-MM>.pdf with a summary table per region.
