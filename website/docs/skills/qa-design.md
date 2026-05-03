---
sidebar_position: 39
title: "qa-design"
description: "UI/UX design audit and verification of web best practices. Trigger when the user wants to audit the design, verify the UI/UX, or improve the user interface."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-design

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> UI/UX design audit and verification of web best practices. Trigger when the user wants to audit the design, verify the UI/UX, or improve the user interface.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep` |
| **Keywords** | `design`, `invalid field`, `image`, `1 item(s)` |

## Detailed description

# UI/UX Design Audit

## Objective

Audit a web interface against 100+ rules covering accessibility, forms, animations, typography, images, performance, navigation, dark mode, and internationalization.

## Audit categories

```
┌──────────────────────────────────────────────────────────────────┐
│                      UI/UX AUDIT                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. ACCESSIBILITY       ARIA, contrast, focus, keyboard          │
│  2. FORMS               Validation, feedback, autofill           │
│  3. ANIMATIONS          Performance, reduced-motion, timing      │
│  4. TYPOGRAPHY          Hierarchy, readability, responsive       │
│  5. IMAGES              Alt text, lazy loading, formats          │
│  6. UI PERFORMANCE      Layout shift, first paint, bundle        │
│  7. NAVIGATION          Breadcrumbs, mobile menu, deep links     │
│  8. DARK MODE           CSS variables, images, contrast          │
│  9. TOUCH INTERACTIONS  Target size, swipe, gestures             │
│  10. INTERNATIONALIZATION  RTL, dates, plurals, translations    │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Accessibility

### Critical rules

| # | Rule | Verification |
|---|------|-------------|
| A1 | Minimum contrast 4.5:1 (normal text) | Check CSS colors |
| A2 | Minimum contrast 3:1 (large text, icons) | Check CSS colors |
| A3 | Labels on all form fields | `<label for="">` or `aria-label` |
| A4 | Alt text on all informative images | `<img alt="">` non-empty |
| A5 | Full keyboard navigation | Tab, Enter, Escape, Arrow keys |
| A6 | Visible focus on interactive elements | `:focus-visible` style |
| A7 | Correct ARIA roles | `role`, `aria-*` attributes |
| A8 | No purely visual content | Text alternatives |
| A9 | Logical heading structure | h1 > h2 > h3, no skipping |
| A10 | Skip to content link | First focusable element |

### Patterns to look for

```
# Images without alt
<img[^>]*(?<!alt=")[^>]*>

# Buttons without accessible text
<button[^>]*>(\s*<(svg|img|i)[^>]*>\s*)<\/button>

# Inputs without label
<input(?![^>]*aria-label)(?![^>]*id=["'][^"']*["'][^>]*)[^>]*>

# Insufficient contrast (light colors on light background)
color:\s*#[def][def][def]|color:\s*#[cdef]{6}
```

## 2. Forms

| # | Rule | Detail |
|---|------|--------|
| F1 | Inline validation (not only on submit) | Show error on blur |
| F2 | Descriptive error messages | Not just "Invalid field" |
| F3 | Autocomplete attributes | `autocomplete="email"`, `"name"`, etc. |
| F4 | Submit button disabled if invalid | Or clear feedback |
| F5 | Required field indicator | `*` or explicit text |
| F6 | Correct input type | `type="email"`, `"tel"`, `"number"` |
| F7 | Minimum font size 16px on mobile | Avoids iOS zoom |
| F8 | Loading state on submit | Spinner or disabled |

## 3. Animations and transitions

| # | Rule | Detail |
|---|------|--------|
| AN1 | `prefers-reduced-motion` respected | Disable animations on request |
| AN2 | Duration < 400ms for micro-interactions | Fast feedback |
| AN3 | No flash/blink > 3Hz | Epilepsy risk |
| AN4 | CSS transitions preferred over JS | GPU performance |
| AN5 | `will-change` for heavy animations | Compositor optimization |

```css
/* prefers-reduced-motion pattern */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## 4. Typography

| # | Rule | Detail |
|---|------|--------|
| T1 | Clear visual hierarchy | Distinct sizes, weights, colors |
| T2 | Line length 50-75 characters | `max-width: 65ch` |
| T3 | Minimum line-height 1.5 for body text | Readability |
| T4 | No more than 2-3 fonts | Visual consistency |
| T5 | Minimum size 16px for body | Mobile readability |
| T6 | System font fallback defined | `font-family: 'Custom', system-ui, sans-serif` |

## 5. Images

| # | Rule | Detail |
|---|------|--------|
| I1 | Descriptive alt text | Not "image", not empty unless decorative |
| I2 | Lazy loading | `loading="lazy"` except above-the-fold |
| I3 | Explicit dimensions | `width` and `height` to avoid CLS |
| I4 | Modern format (WebP, AVIF) | With fallback |
| I5 | Responsive images | `srcset` and `sizes` |
| I6 | Optimized compression | < 100KB for UI images |

## 6. UI Performance

| # | Rule | Detail |
|---|------|--------|
| P1 | CLS < 0.1 | No layout shift |
| P2 | LCP < 2.5s | Largest Contentful Paint |
| P3 | FID < 100ms | First Input Delay |
| P4 | Skeleton/loading states | No blank page |
| P5 | Code splitting per route | Bundles < 200KB gzip |
| P6 | Inline critical CSS | Fast above-the-fold |

## 7. Navigation

| # | Rule | Detail |
|---|------|--------|
| N1 | Breadcrumbs on deep pages | User orientation |
| N2 | Accessible mobile menu | Hamburger + overlay |
| N3 | Easy back navigation | Predictable navigation |
| N4 | Active page indication | Menu highlight |
| N5 | Useful 404 page | Navigation links |
| N6 | Working deep links | Shareable URLs |

## 8. Dark Mode

| # | Rule | Detail |
|---|------|--------|
| D1 | CSS custom properties | `--color-bg`, `--color-text` |
| D2 | Adapted images | No white images on dark background |
| D3 | Sufficient contrast in dark | Recheck ratios |
| D4 | Smooth transition | `transition: background-color 0.2s` |
| D5 | Respect `prefers-color-scheme` | Automatic detection |

## 9. Touch interactions

| # | Rule | Detail |
|---|------|--------|
| TC1 | Touch targets >= 44x44px | Apple/Google minimum |
| TC2 | Spacing between targets >= 8px | Avoid tap errors |
| TC3 | No hover-only interactions | Touch alternatives |
| TC4 | Intuitive swipe if used | Natural direction |

## 10. Internationalization

| # | Rule | Detail |
|---|------|--------|
| I18N1 | Externalized text | No hardcoded strings |
| I18N2 | RTL support | `direction: rtl` compatible |
| I18N3 | Local date formats | No hardcoded US format |
| I18N4 | Plurals handled | No "1 item(s)" |

## Expected output

```markdown
## UI/UX Audit: [Project name]

### Overall score: X/100

### Results by category

| Category | Score | Issues |
|-----------|-------|--------|
| Accessibility | X/10 | [N issues] |
| Forms | X/10 | [N issues] |
| Animations | X/10 | [N issues] |
| Typography | X/10 | [N issues] |
| Images | X/10 | [N issues] |
| UI Performance | X/10 | [N issues] |
| Navigation | X/10 | [N issues] |
| Dark Mode | X/10 | [N issues] |
| Touch | X/10 | [N issues] |
| i18n | X/10 | [N issues] |

### Critical issues
- [CRITICAL] [file:line] - Description

### Recommended improvements
- [IMPORTANT] [file:line] - Description

### Suggestions
- [SUGGESTION] - Description
```

## Rules

- Check ALL categories, not just the obvious ones
- Prioritize issues by user impact
- Provide concrete solutions, not just findings
- Test on mobile AND desktop

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to design..."_
- _"I want to invalid field..."_
- _"I want to image..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: UI/UX Audit Checklist

# Example: UI/UX Audit Checklist

## Scenario
Audit a SaaS dashboard application for design consistency, usability, and accessibility.

## Audit Summary

| Category | Score | Issues Found |
|----------|-------|-------------|
| Visual Consistency | 5/10 | 8 issues |
| Typography | 6/10 | 4 issues |
| Spacing & Layout | 4/10 | 6 issues |
| Color & Contrast | 7/10 | 3 issues |
| Interaction Design | 5/10 | 5 issues |
| Accessibility | 4/10 | 7 issues |

## Visual Consistency Issues

| # | Issue | Location | Severity | Fix |
|---|-------|----------|----------|-----|
| 1 | 3 different button styles for same action | Dashboard, Settings, Profile | High | Standardize to design system `Button` component |
| 2 | Inconsistent border-radius (2px, 4px, 8px) | Cards, inputs, modals | Medium | Use `--radius-sm: 4px`, `--radius-md: 8px` tokens |
| 3 | Two different icon libraries (Lucide + HeroIcons) | Sidebar vs content area | Medium | Consolidate to Lucide icons |
| 4 | Shadow depth varies on same-level cards | Dashboard grid | Low | Use `--shadow-card` token consistently |

## Typography Issues

```
Found: 6 different font sizes used without system
Recommended scale (rem):
  --text-xs:  0.75    (12px) - labels, captions
  --text-sm:  0.875   (14px) - body small
  --text-base: 1      (16px) - body
  --text-lg:  1.125   (18px) - subheadings
  --text-xl:  1.25    (20px) - headings
  --text-2xl: 1.5     (24px) - page titles
```

## Spacing Issues

```
Found: Arbitrary margins (7px, 13px, 22px, 33px)
Recommended 4px grid:
  --space-1: 4px    --space-4: 16px    --space-8: 32px
  --space-2: 8px    --space-6: 24px    --space-12: 48px
```

## Accessibility Issues

| # | Issue | WCAG | Fix |
|---|-------|------|-----|
| 1 | Gray text on white: 2.8:1 contrast ratio | 1.4.3 AA (needs 4.5:1) | Darken to `#595959` |
| 2 | No focus indicators on interactive elements | 2.4.7 AA | Add `:focus-visible` outline |
| 3 | Form errors communicated only by color | 1.4.1 A | Add error icon + text message |
| 4 | Missing `aria-label` on icon-only buttons | 4.1.2 A | Add descriptive labels |
| 5 | Data table not navigable by keyboard | 2.1.1 A | Add `tabindex`, arrow key navigation |

## Recommended Actions

### Immediate (1 week)
1. Create CSS custom properties for colors, spacing, typography, shadows
2. Fix contrast ratio issues (WCAG compliance)
3. Add focus indicators globally

### Short-term (2-4 weeks)
4. Build/standardize component library (Button, Card, Input, Modal)
5. Replace arbitrary values with design tokens
6. Consolidate icon library

### Ongoing
7. Add Storybook for component documentation
8. Lint for design token usage (stylelint plugin)

## Key Decisions

- **Design tokens over hardcoded values**: Single source of truth, theme-able
- **4px spacing grid**: Consistent rhythm, easy mental math
- **WCAG AA minimum**: Legal compliance and better UX for all users
- **Component audit before redesign**: Fix consistency first, then iterate on aesthetics



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
