---
max_turns: 3
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep, Write, Edit]
tags: [campaign2, positive]
---

Our frontend tests call the real payments API. Mock it with MSW so the tests run without a backend.
