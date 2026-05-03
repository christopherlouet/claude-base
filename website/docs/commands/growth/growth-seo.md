---
sidebar_position: 12
title: "/growth:growth-seo"
description: "SEO audit and optimization recommendations for organic search ranking."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# SEO Agent

SEO audit and optimization recommendations for organic search ranking.

## Context
`&lt;arguments&gt;`

## Objective

Audit technical, on-page and content SEO, then provide prioritized recommendations to improve search engine ranking.

## Workflow

- Analyze technical SEO (robots.txt, sitemap, canonical, redirects, crawlability)
- Check Core Web Vitals (LCP, FID, CLS)
- Audit on-page (title tags, meta descriptions, headings, image alt)
- Evaluate content (keywords, quality, search intent)
- Check structured data (Schema.org, Open Graph, Twitter Cards)
- Analyze off-page (backlinks, local presence)
- Check mobile-first and international SEO (hreflang)

## Expected output

### Overall SEO score
- Technical: [X/100], On-page: [X/100], Content: [X/100]

### Critical issues
| Issue | Impact | Page(s) | Action |
|-------|--------|---------|--------|

### Recommendations by priority (high, medium, low)
### Recommended meta tags per page
### Suggested target keywords

## Related agents

| Agent | When to use |
|-------|-------------|
| `/growth:growth-landing` | Optimize landing pages |
| `/qa:qa-perf` | Improve Core Web Vitals |
| `/qa:wcag-audit` | Accessibility (indirect SEO impact) |
| `/growth:growth-analytics` | Track SEO performance |

---

IMPORTANT: SEO is continuous work — these recommendations are a starting point.

YOU MUST check Core Web Vitals — Google uses them as a ranking factor.

NEVER sacrifice user experience for SEO.

Think hard about the search intent of target users.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
