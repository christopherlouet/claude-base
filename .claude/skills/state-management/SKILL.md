---
name: state-management
description: State management patterns and implementation. Trigger when the user wants to manage global state, use Redux, Zustand, or other solutions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
user-invocable: false
---

# State Management (pointer)

Library APIs, install steps and idiomatic code drift on each release and are canonical at:

- **Zustand** — [docs.pmnd.rs/zustand](https://docs.pmnd.rs/zustand) (recommended default; 1.2kb, hooks-first)
- **Redux Toolkit** — [redux-toolkit.js.org](https://redux-toolkit.js.org) (enterprise scale, devtools)
- **Jotai** — [jotai.org](https://jotai.org) (atomic model, 2kb)
- **TanStack Query** — [tanstack.com/query](https://tanstack.com/query) (server state, NOT global client state)
- **React 19 built-ins** — [react.dev](https://react.dev) (`useReducer`, `useOptimistic`, `use(Context)`, Actions)

## Decision tree (version-agnostic)

```
Need shared state?
├── No → useState/useReducer
└── Yes →
    ├── Server state (fetch + cache + invalidate) → TanStack Query / SWR
    ├── Forms → React Hook Form
    ├── Small client state (<5 stores) → Zustand
    ├── Large client state (>5 stores) → Redux Toolkit
    └── Theme/Auth singletons → Context + useReducer
```

## Foundation discipline (keep across releases)

- **Client vs server state**: never put server state in a client store (Zustand/Redux). Use TanStack Query for fetched data; Zustand/Redux for UI state, filters, drafts.
- **Domain separation**: one store per domain, not one global store. Easier to test and lazy-load.
- **Granular selectors**: subscribe to slices, not whole stores — see [[dev-react-perf]] for re-render audit when a store change cascades.

## See also

- `dev-react-perf` skill — re-render diagnosis when selectors are too broad
- `dev-tdd` — store reducers/selectors test well in isolation (no DOM needed)
