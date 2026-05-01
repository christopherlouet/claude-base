# QA-RESPONSIVE Agent

Responsive and mobile-first audit of a web application.

## Context
$ARGUMENTS

## Objective

Verify that the application works correctly on all breakpoints (320px to 2560px), with a mobile-first approach, and adequate touch targets.

## Workflow

- Test the 7 breakpoints (320, 375, 425, 768, 1024, 1440, 2560)
- Verify structure (viewport, mobile-first CSS, flexbox/grid)
- Verify navigation (hamburger, touch targets >= 44px)
- Verify typography (>= 16px, line-height >= 1.5)
- Verify images (srcset, lazy loading, aspect ratio)
- Verify forms (inputs >= 44px, correct type, mobile keyboard)
- Test orientation (portrait + landscape)
- Verify touch interactions (tap, swipe, spacing >= 8px)

## Expected output

### Responsive Score: [X/100]
| Breakpoint | Status |
|------------|--------|
| Mobile 320-425px | OK/KO |
| Tablet 768px | OK/KO |
| Desktop 1024-1440px | OK/KO |

### Issues by breakpoint
| Breakpoint | Page | Issue | Severity |
|------------|------|-------|----------|

### Priority fixes
1. Critical: [Issue] -> [Solution]
2. Important: [Issue] -> [Solution]

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/qa:wcag-audit` | Mobile accessibility |
| `/qa:qa-perf` | Mobile performance |
| `/dev:dev-component` | Create responsive components |
| `/growth:growth-landing` | Responsive landing pages |

---

IMPORTANT: Always test on real devices, not just DevTools.

YOU MUST use the mobile-first approach (min-width, not max-width).

NEVER use fixed pixel widths for containers.

Think hard about the user experience on small screens.
