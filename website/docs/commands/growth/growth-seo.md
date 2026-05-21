---
sidebar_position: 12
title: "/growth:growth-seo"
description: "SEO audit and optimization for organic search ranking."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# SEO Agent (pointer)

SEO audit and optimization for organic search ranking.

## Context
`<arguments>`

## Delegate to the vendor toolkit

`claude-base`'s prior `growth-seo` content is **superseded** by [`AgriciDaniel/claude-seo`](https://github.com/AgriciDaniel/claude-seo) — 28 SKILL.md, business-type auto-detection, 7-category scoring, DataForSEO/Firecrawl/Google integrations. Install + delegate:

```bash
git clone --depth 1 https://github.com/AgriciDaniel/claude-seo ~/dev/vendor-skills/claude-seo
~/dev/vendor-skills/claude-seo/install.sh ./
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"AgriciDaniel — `claude-seo`". Reduction rationale: [`specs/foundation-positioning-review/spec.md`](../../../specs/foundation-positioning-review/spec.md) Wave 1.

For Core Web Vitals work delegate to `/qa:qa-perf`; for accessibility (indirect SEO factor) to `/qa:wcag-audit`; for SEO performance tracking to `/growth:growth-analytics`.

---

NEVER sacrifice user experience for SEO.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
