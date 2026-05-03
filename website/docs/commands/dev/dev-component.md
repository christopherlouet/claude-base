---
sidebar_position: 5
title: "/dev:dev-component"
description: "Generate a complete UI component with tests, types and documentation."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-COMPONENT

Generate a complete UI component with tests, types and documentation.

## Request context
`&lt;arguments&gt;`

## Objective

Create a complete React component following the TDD approach:
types first, then tests (RED), implementation (GREEN), refactoring and Storybook.

## Workflow

- Define the component: name, framework, props/API, internal state, variants
- Create the types (`[ComponentName].types.ts`) with JSDoc
- Write the tests (`[ComponentName].test.tsx`): render, variants, click, disabled, className
- Implement the component (`[ComponentName].tsx`) with forwardRef, clsx, CSS modules
- Create the Storybook stories (`[ComponentName].stories.tsx`) with argTypes
- Verify: typed props, disabled handling, modular CSS, tests &gt;80%, accessibility (aria-*, role, tabIndex)

## Expected output

- `[ComponentName].tsx` - Main component
- `[ComponentName].types.ts` - TypeScript types
- `[ComponentName].test.tsx` - Unit tests
- `[ComponentName].stories.tsx` - Storybook documentation
- `[ComponentName].module.css` - Styles
- `index.ts` - Export

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-hook` | Create an associated hook |
| `/dev:dev-test` | Complementary tests |
| `/qa:wcag-audit` | Component accessibility audit |
| `/qa:qa-responsive` | Verify responsiveness |

---

IMPORTANT: Always type props with explicit interfaces.

YOU MUST add tests for each prop and behavior.

NEVER forget accessibility (aria-label, role, keyboard navigation).

Think hard about the component's API before coding.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
