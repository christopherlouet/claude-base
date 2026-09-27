---
max_turns: 3
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep, Write, Edit]
tags: [campaign2, positive]
---

Our Node service crashes on any unhandled error. Put a consistent error-handling strategy in place: custom error classes, one middleware, proper HTTP codes.
