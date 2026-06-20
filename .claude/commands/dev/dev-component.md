# Agent DEV-COMPONENT

Generate a complete UI component — or a custom React hook — with tests, types and documentation.

## Request context
$ARGUMENTS

## Objective

Create a complete React component (or a reusable custom **hook**) following the TDD approach:
types first, then tests (RED), implementation (GREEN), refactoring and Storybook.

## Custom hook mode

When the request is a hook rather than a component:
- Define the hook (problem, parameters, return, side effects) and its types (`Options`, `Return`) with JSDoc.
- Write tests with `renderHook` (initial state, success, errors, refetch, options change).
- Implement (useState/useEffect/useCallback/useMemo); clean up side effects (AbortController, clearTimeout, removeEventListener) — no memory leaks.
- Output: `use[HookName].ts` + `use[HookName].test.ts` + export in `index.ts` + usage docs.

## Workflow

- Define the component: name, framework, props/API, internal state, variants
- Create the types (`[ComponentName].types.ts`) with JSDoc
- Write the tests (`[ComponentName].test.tsx`): render, variants, click, disabled, className
- Implement the component (`[ComponentName].tsx`) with forwardRef, clsx, CSS modules
- Create the Storybook stories (`[ComponentName].stories.tsx`) with argTypes
- Verify: typed props, disabled handling, modular CSS, tests >80%, accessibility (aria-*, role, tabIndex)

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
| `/dev:dev-tdd` | Complementary tests / TDD cycle |
| `/qa:wcag-audit` | Component accessibility audit |
| `/qa:qa-design` | Verify responsive/UI design |

---

IMPORTANT: Always type props with explicit interfaces.

YOU MUST add tests for each prop and behavior.

NEVER forget accessibility (aria-label, role, keyboard navigation).

Think hard about the component's API before coding.
