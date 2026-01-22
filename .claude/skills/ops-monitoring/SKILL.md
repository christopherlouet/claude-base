---
name: ops-monitoring
description: Instrumentation d'applications pour monitoring. Declencher quand l'utilisateur veut ajouter des logs, metriques, ou traces.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Monitoring Instrumentation

## 3 Piliers de l'Observabilite

1. **Logs** - Events discretes
2. **Metriques** - Mesures numeriques
3. **Traces** - Chemins de requetes

## Logs Structures (Node.js)

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  base: { service: 'api', env: process.env.NODE_ENV },
});

logger.info({ userId: '123', action: 'login' }, 'User logged in');
logger.error({ err, requestId }, 'Request failed');
```

## Metriques Prometheus

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

## Traces OpenTelemetry

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
  res.status(dbOk ? 200 : 503).json({ db: dbOk });
});
```
