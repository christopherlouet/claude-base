---
max_turns: 3
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep, Write, Edit]
tags: [campaign2, positive]
---

Build a nightly job that pulls orders from Postgres, aggregates revenue per day and loads the result into BigQuery.
