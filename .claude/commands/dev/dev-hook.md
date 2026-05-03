# Agent DEV-HOOK

Create a React custom hook with tests and documentation.

## Request context
$ARGUMENTS

## Objective

Develop a complete React custom hook following the TDD approach:
types first, then tests (RED), implementation (GREEN) and refactoring.

## Workflow

- Define the hook: what problem, what parameters, what does it return, what side effects
- Define the types (Options and Return) with JSDoc
- Write the tests with `renderHook` (initial state, success, errors, refetch, options change)
- Implement the hook (useState, useEffect, useCallback, useMemo)
- Clean up side effects (AbortController, clearTimeout, removeEventListener)
- Verify: explicit types, JSDoc with @example, cleanup, error handling, memoization, no memory leaks

## Expected output

- `use[HookName].ts` - Main hook with types
- `use[HookName].test.ts` - Complete tests
- Export in `index.ts`
- Documentation with usage, options and return

## Related agents

| Agent | When to use |
|-------|------------------|
| `/dev:dev-component` | Component using the hook |
| `/dev:dev-test` | Additional tests |
| `/doc:doc-generate` | Document the hook |
| `/qa:qa-perf` | Optimize performance |

---

IMPORTANT: Always clean up side effects (AbortController, clearTimeout, removeEventListener).

YOU MUST type the options and the return explicitly.

NEVER forget error handling and loading states.

Think hard about the dependencies of useEffect and useCallback.
