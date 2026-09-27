---
max_turns: 3
timeout_seconds: 180
allowed_tools: [Skill, Read, Glob, Grep, Write, Edit]
tags: [campaign, positive, hard]
---

`node checkout.js` prints the right total for the first order, but orders 2 and 3 come out 20% too low, and they have no coupon. It only happens after an order with a coupon. I can't see why. Can you track it down?
