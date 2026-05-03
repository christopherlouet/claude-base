---
name: ops-monitoring
description: Application instrumentation for monitoring. Trigger when the user wants to add logs, metrics, or traces.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
disable-model-invocation: true
---

# Monitoring Instrumentation

## 3 Pillars of Observability

1. **Logs** - Discrete events
2. **Metrics** - Numerical measurements
3. **Traces** - Request paths

## Structured Logs (Node.js)

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  base: { service: 'api', env: process.env.NODE_ENV },
});

logger.info({ userId: '123', action: 'login' }, 'User logged in');
logger.error({ err, requestId }, 'Request failed');
```

## Prometheus Metrics

```typescript
import { Counter, Histogram, Registry } from 'prom-client';

const httpRequests = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
});

const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Request duration',
  labelNames: ['method', 'path'],
  buckets: [0.1, 0.5, 1, 2, 5],
});
```

## OpenTelemetry Traces

```typescript
import { trace } from '@opentelemetry/api';

const tracer = trace.getTracer('my-service');

async function processOrder(orderId: string) {
  return tracer.startActiveSpan('processOrder', async (span) => {
    span.setAttribute('orderId', orderId);
    try {
      // ... processing
    } finally {
      span.end();
    }
  });
}
```

## Health Checks

```typescript
app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/ready', async (req, res) => {
  const dbOk = await db.query('SELECT 1');
  res.status(dbOk ? 200: 503).json({ db: dbOk });
});
```
