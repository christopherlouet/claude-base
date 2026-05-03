---
sidebar_position: 6
title: "/qa:qa-design"
description: "UI/UX design audit and verification of web best practices."
tags:
  - "qa"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--qa">QA</span>


# QA-DESIGN Agent

UI/UX design audit and verification of web best practices.

## Context
`&lt;arguments&gt;`

## Objective

Audit an interface against 100+ rules covering accessibility, forms, animations, typography, images, UI performance, navigation, dark mode, touch and internationalization.

## Workflow

- Scan UI files (components, CSS, pages)
- Verify accessibility (contrast, ARIA, focus, keyboard)
- Verify forms (validation, feedback, autocomplete)
- Verify animations (reduced-motion, performance, timing)
- Verify typography, images, UI performance
- Verify navigation, dark mode, touch targets, i18n
- Produce the report with scores per category

## Expected output

### Overall score: X/100

| Category | Score | Critical issues | Recommendations |
|-----------|-------|-----------------|-----------------|
| Accessibility | /10 | | |
| Forms | /10 | | |
| Animations | /10 | | |
| Typography | /10 | | |
| Images | /10 | | |
| UI Performance | /10 | | |
| Navigation | /10 | | |
| Dark Mode | /10 | | |
| Touch | /10 | | |
| i18n | /10 | | |

### Critical issues, quick wins, recommendations
[With file:line for each issue]

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/qa:wcag-audit` | Detailed WCAG accessibility audit |
| `/qa:qa-responsive` | Responsive/mobile audit |
| `/qa:qa-perf` | Detailed performance audit |
| `/dev:dev-design-system` | Design tokens and design system |

---

IMPORTANT: Cover all 10 categories, not just the obvious ones.

YOU MUST provide concrete solutions with file:line.

NEVER ignore accessibility - it is a legal obligation.

Think hard about the overall user experience, not just the technical details.


---

## See also

- [Back to QA commands](/docs/commands/qa)
- [All commands](/docs/commands)
