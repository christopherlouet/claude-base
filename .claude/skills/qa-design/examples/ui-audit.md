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
