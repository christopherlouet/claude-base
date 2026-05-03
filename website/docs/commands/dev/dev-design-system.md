---
sidebar_position: 7
title: "/dev:dev-design-system"
description: "Creation and maintenance of design systems and component libraries."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-DESIGN-SYSTEM

Creation and maintenance of design systems and component libraries.

## Request context
`<arguments>`

## Objective

Create or audit a complete design system with tokens, primitive components,
composite components and patterns, all documented in Storybook.

## Workflow

- Define design tokens (semantic colors, typography, spacing, shadows, animations)
- Generate tokens with Style Dictionary (CSS variables, TypeScript, Tailwind)
- Create primitive components (Button, Input, Text, Icon, Badge) with variants (cva)
- Create composite components (Form, Modal, Dropdown, Table, Navigation)
- Define patterns (Auth Flow, Settings, Dashboard, Empty States)
- Implement theming (ThemeProvider, light/dark/system)
- Document each component in Storybook with stories and argTypes
- Ensure WCAG 2.1 AA accessibility on each component

## Expected output

Audit of the existing design system or creation plan by phases
(tokens > primitives > composites > documentation).

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-component` | Create components |
| `/qa:wcag-audit` | Accessibility |
| `/doc:doc-generate` | Documentation |

---

IMPORTANT: Tokens are the source of truth - never hardcoded values.

IMPORTANT: Each component must be accessible (WCAG 2.1 AA).

YOU MUST document each component in Storybook.

NEVER duplicate styles - use tokens.

Think hard about the consistency and reusability of the system.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
