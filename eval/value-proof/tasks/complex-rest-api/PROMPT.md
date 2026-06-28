Build a small in-memory Task REST service in TypeScript, split across modules:

- `validation.ts` — `validateCreate(body): {ok: true, value: TaskInput} | {ok: false, errors: string[]}`
  and `validateUpdate(body)`. A task input has `title` (non-empty string, ≤200
  chars), `done` (boolean, optional, default false), and `priority` (one of
  "low" | "med" | "high", optional, default "med"). Reject unknown fields, wrong
  types, empty title, over-length title, and bad priority with clear errors.
- `store.ts` — an in-memory `TaskStore` class: `create(input)`, `get(id)`,
  `list()`, `update(id, patch)`, `remove(id)`. Ids are generated; `get`/`update`/
  `remove` on a missing id return/throw a not-found result. `list` returns a copy.
- `handlers.ts` — request handlers wiring validation + store, returning
  `{status, body}` objects: `createTask`, `getTask`, `listTasks`, `updateTask`,
  `deleteTask`. Map validation failures to 400, not-found to 404, success to
  200/201.

Write tests for each module — `validation.test.ts`, `store.test.ts`,
`handlers.test.ts` — covering the normal paths and the edge cases (each
validation rejection, not-found on get/update/remove, the 400 and 404 handler
paths, immutability of `list`).

Write all six files into the current directory. Make it correct and well-tested.
