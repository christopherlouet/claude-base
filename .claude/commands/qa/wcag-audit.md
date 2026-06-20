# WCAG-AUDIT Agent (Accessibility)

Accessibility audit based on WCAG 2.1/2.2 and the axe-core reference.

## Audit target
$ARGUMENTS

## Objective

Identify accessibility violations in the code and propose concrete fixes to reach WCAG 2.1/2.2 level AA.

## Workflow

- Scan UI files (components, pages, layouts, CSS)
- Audit the 11 categories: images, forms, keyboard, buttons/links, colors, ARIA, structure, tables, frames, deprecated, WCAG 2.2
- Classify each issue by impact (Critical/Serious/Moderate/Minor)
- Distinguish violations (auto-detectable) from needs-review (manual verification)
- Identify priority fixes with file:line

## Impact levels

| Level | Definition | Action |
|--------|-----------|--------|
| **Critical** | Completely blocks access | Fix immediately |
| **Serious** | Significant impact on usability | Fix before release |
| **Moderate** | Hinders user experience | Plan a fix |
| **Minor** | Desirable improvement | Backlog |

## Audit categories

| # | Category | Key rules | WCAG |
|---|-----------|------------|------|
| 1 | Images/media | alt, SVG, object, video, autoplay | 1.1.1, 1.2.2, 1.4.2 |
| 2 | Forms | labels, select, errors, autocomplete | 4.1.2, 3.3.1, 1.3.5 |
| 3 | Keyboard | focus, traps, skip-link, scrollable, nested | 2.1.1, 2.1.2, 2.4.1 |
| 4 | Buttons/links | accessible names, descriptive links | 4.1.2, 2.4.4 |
| 5 | Colors | AA ratios, color alone, UI elements | 1.4.3, 1.4.1, 1.4.11 |
| 6 | ARIA | attrs, roles, relations, aria-hidden | 4.1.2, 1.3.1 |
| 7 | Structure | lang, title, headings, landmarks, regions | 3.1.1, 2.4.2, 1.3.1 |
| 8 | Tables | th, scope, headers, caption | 1.3.1 |
| 9 | Frames | title, uniqueness, focus | 4.1.2, 2.1.1 |
| 10 | Deprecated | blink, marquee, meta-refresh, autoplay | 2.2.1, 2.2.2 |
| 11 | WCAG 2.2 | target-size 44x44px, focus-not-obscured | 2.5.8, 2.4.11 |

## Expected output

### Summary
- **Overall score**: [X/100]
- **WCAG level reached**: [A/AA/AAA]
- **Violations**: [N] (Critical: X, Serious: X, Moderate: X, Minor: X)
- **Needs Review**: [N]

### Violations
| Impact | Category | WCAG | Element | File:line | Fix |
|--------|-----------|------|---------|---------------|------------|

### Needs Review
| Category | Element | File:line | Required verification |
|-----------|---------|---------------|---------------------|

### Priority recommendations
1. [Critical] ...
2. [Serious] ...
3. [Moderate] ...

### Complementary tools
For a complete runtime audit, use as a complement:
- **axe-core**: `npx @axe-core/cli http://localhost:3000` (automated audit)
- **Playwright + axe**: `@axe-core/playwright` (E2E accessibility tests)
- **Pa11y**: `npx pa11y http://localhost:3000` (CLI audit)
- **Lighthouse**: Accessibility tab in Chrome DevTools

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/qa:qa-audit` | Full audit (includes a11y) |
| `/qa:qa-design` | Full UI/UX audit |
| `/qa:qa-chrome` | Visual browser tests |
| `/growth:growth-seo` | SEO (indirect impact of a11y) |

---

IMPORTANT: Accessibility is not optional - audit the 11 categories systematically.

IMPORTANT: Classify each issue by impact level (Critical/Serious/Moderate/Minor).

YOU MUST reach at minimum WCAG 2.1 level AA.

YOU MUST distinguish violations from needs-review.

NEVER ignore Critical accessibility errors.

Think hard about the experience of users with disabilities.
