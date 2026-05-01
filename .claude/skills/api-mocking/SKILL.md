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

# API Mocking

## Triggers

- "mock API"
- "MSW"
- "test without backend"
- "fake API"
- "stub endpoint"

## Tools

| Tool | Usage | Install |
|------|-------|---------|
| MSW | Browser/Node | `npm i -D msw` |
| nock | Node only | `npm i -D nock` |
| json-server | REST fake | `npm i -D json-server` |
| Mirage JS | Browser | `npm i -D miragejs` |

## MSW Setup (Recommended)

### Installation

```bash
npm install -D msw
npx msw init public/ --save
```

### Structure

```
src/
├── mocks/
│   ├── handlers.ts      # Request handlers
│   ├── server.ts        # Node server (tests)
│   └── browser.ts       # Browser worker (dev)
└── ...
```

### Handlers

```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  // GET /api/users
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'John' },
      { id: 2, name: 'Jane' },
    ]);
  }),

  // POST /api/users
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: 3, ...body },
      { status: 201 }
    );
  }),

  // Error simulation
  http.get('/api/error', () => {
    return HttpResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }),
];
```

### Server (Tests)

```typescript
// src/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

### Test Setup

```typescript
// vitest.setup.ts or jest.setup.ts
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from './src/mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Browser (Dev)

```typescript
// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

```typescript
// main.tsx (development only)
async function enableMocking() {
  if (process.env.NODE_ENV !== 'development') return;

  const { worker } = await import('./mocks/browser');
  return worker.start();
}

enableMocking().then(() => {
  ReactDOM.render(<App />, document.getElementById('root'));
});
```

## Patterns

### Override per test

```typescript
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';

test('handles error', async () => {
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json(null, { status: 500 });
    })
  );

  // Test error handling...
});
```

### Delay simulation

```typescript
http.get('/api/slow', async () => {
  await delay(2000); // 2 seconds
  return HttpResponse.json({ data: 'slow response' });
});
```

### Auth simulation

```typescript
http.get('/api/protected', ({ request }) => {
  const authHeader = request.headers.get('Authorization');

  if (!authHeader?.startsWith('Bearer ')) {
    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  return HttpResponse.json({ secret: 'data' });
});
```

## Nock (Node.js)

```typescript
import nock from 'nock';

beforeEach(() => {
  nock('https://api.example.com')
    .get('/users')
    .reply(200, [{ id: 1, name: 'John' }]);
});

afterEach(() => {
  nock.cleanAll();
});
```

## Best Practices

| Practice | Description |
|----------|-------------|
| Type-safe | Use the same types as the real API |
| Realistic | Simulate delays and errors |
| Isolated | Reset between each test |
| Maintained | Keep up to date with the API |
