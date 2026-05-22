---
name: api-mocking
description: API mock configuration for tests. Trigger when the user wants to mock APIs, use MSW, or test without a backend.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
context: fork
user-invocable: false
---

# API Mocking (pointer)

MSW handler API, browser/node setup, install commands and request-interception internals are canonical at vendor docs and drift on each release:

- **MSW** — [mswjs.io](https://mswjs.io) (recommended default; browser worker + Node server, single handler set)
- **nock** — [github.com/nock/nock](https://github.com/nock/nock) (Node-only HTTP interception)
- **json-server** — [github.com/typicode/json-server](https://github.com/typicode/json-server) (full REST fake server from a JSON file)
- **Mirage JS** — [miragejs.com](https://miragejs.com) (browser-only, models + factories)

## Tool selection (version-agnostic)

```
Need to mock HTTP for tests/dev?
├── Browser AND Node from one handler set → MSW
├── Node-only unit tests, low ceremony → nock
├── Need a stateful REST fake server (CRUD) → json-server
└── Browser-only with relational fixtures (factories) → Mirage JS
```

## Foundation discipline (keep across releases)

- **Type-safe mocks**: derive mock payloads from the same TypeScript types as the real API (e.g. shared `types/api.ts`). A mock that compiles against stale types is the #1 source of mock-prod divergence.
- **Reset between tests**: always `resetHandlers()` (MSW) or `cleanAll()` (nock) in `afterEach` — leaked state across tests is a debugging tax.
- **Realistic failure modes**: simulate 5xx/timeouts/auth errors, not just happy paths. The mock is only useful if it exercises the same edge cases as prod.
- **Unhandled = error**: in tests use `onUnhandledRequest: 'error'` (MSW) so a typo'd URL fails loudly instead of silently passing.

## See also

- `dev-tdd` — mocks live in test setup; this skill activates from TDD work
- `qa-e2e` — Playwright/Cypress tests often layer MSW for deterministic stubs
- `dev-testing-setup` — wires the global `setupServer` into vitest/jest config
