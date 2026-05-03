---
sidebar_position: 18
title: "react"
description: "export function MyComponent( title, onAction : Props)  const [state, setState] = useStatestring('');"
tags:
  - "rule"
  - "react"
---

# Rules: react

> export function MyComponent(\{ title, onAction \}: Props) \{ const [state, setState] = useState&lt;string&gt;('');

## Affected files

These rules apply to files matching the following patterns:

- `**/*.tsx`
- `**/components/**`
- `**/hooks/**`
- `**/pages/**`
- `**/app/**`

## Detailed rules

# React Rules

## Components

- Use functional components with hooks
- One component per file
- PascalCase naming for components
- Typed props with interface or type

## Hooks

- `use` prefix for all custom hooks
- Follow the rules of hooks (order, conditionals)
- Extract complex logic into custom hooks
- Document hooks with JSDoc

## State Management

- useState for simple local state
- useReducer for complex local state
- Context for limited shared state
- Zustand/Redux for complex global state

## Performance

- Use React.memo for pure components
- useMemo for expensive calculations
- useCallback for functions passed as props
- Avoid unnecessary re-renders

### Render optimization patterns
- State colocation: push state down to the lowest possible component to limit the re-rendered tree
- Composition (children as props): pass JSX as props to avoid re-renders on parent state changes
- Split context: separate contexts by change frequency (do not mix stable and volatile data)
- `useDeferredValue` / `useTransition` to prioritize urgent updates (React 18+)

### Data fetching patterns
- Server Components (Next.js App Router): server-side fetch, zero client JS
- Suspense + `use()` for declarative loading boundaries
- SWR/React Query: cache, dedup, revalidation, optimistic updates
- Prefetch on hover/focus for likely routes (`router.prefetch()`)
- Parallel fetching (`Promise.all`) and waterfall avoidance: hoist fetches as high as possible

## React design patterns

| Pattern | Usage |
|---------|-------|
| **Custom Hooks** | Encapsulate reusable stateful logic (modern default) |
| **Compound Components** | Declarative API like `&lt;Tabs&gt;&lt;Tab/&gt;&lt;/Tabs&gt;` via internal Context |
| **Render Props / children function** | Share logic when hooks are insufficient (rare today) |
| **Container / Presentational** | Separate fetch/state (container) from rendering (presentational) |
| **Provider** | Inject dependencies/theme via Context |
| **HOC** | Legacy -- prefer hooks unless a specific need (ErrorBoundary class) |

## Rendering strategies (Next.js / frameworks)

- **CSR**: authenticated dashboards, dynamic user content
- **SSR**: SEO + fresh data (e-commerce, feeds)
- **SSG**: static content (docs, blog, marketing)
- **ISR**: SSG hybrid with revalidation (catalogs)
- **RSC (Server Components)**: Next.js App Router default, zero JS by default
- **Streaming SSR + Suspense**: fast TTFB, progressive content

## Patterns

```tsx
// Sample component
interface Props {
  title: string;
  onAction: () => void;
}

export function MyComponent({ title, onAction }: Props) {
  const [state, setState] = useState<string>('');

  return (
    <div>
      <h1>{title}</h1>
      <button onClick={onAction}>Action</button>
    </div>
  );
}
```

## Anti-patterns

- NEVER use `any` for props
- NEVER mutate state directly
- Avoid side effects in render
- Avoid indexes as keys in lists

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
