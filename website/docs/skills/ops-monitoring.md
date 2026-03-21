---
sidebar_position: 26
title: "ops-monitoring"
description: "Instrumentation d'applications pour monitoring. Declencher quand l'utilisateur veut ajouter des logs, metriques, ou traces."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-monitoring

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Instrumentation d'applications pour monitoring. Declencher quand l'utilisateur veut ajouter des logs, metriques, ou traces.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `ops`, `monitoring` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux ops..."_
- _"Je veux monitoring..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Example: Structured Logging + Prometheus Metrics

# Example: Structured Logging + Prometheus Metrics

## Scenario
A Node.js API needs structured JSON logging for observability and Prometheus metrics for alerting.

## Structured Logging with Pino

```typescript
// src/lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => ({ level: label }),
  },
  redact: ['req.headers.authorization', 'password', 'token'],
  serializers: {
    err: pino.stdSerializers.err,
    req: pino.stdSerializers.req,
  },
});

// Usage in route handler
export function createOrder(req, res) {
  const log = logger.child({ requestId: req.id, userId: req.user.id });
  log.info({ orderId: order.id, amount: order.total }, 'order created');
  // Output: {"level":"info","requestId":"abc","userId":"u1","orderId":"o1","amount":99.99,"msg":"order created"}
}
```

## Prometheus Metrics

```typescript
// src/lib/metrics.ts
import { Counter, Histogram, Registry } from 'prom-client';

export const registry = new Registry();

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [registry],
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [registry],
});

// Middleware
export function metricsMiddleware(req, res, next) {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const labels = { method: req.method, route: req.route?.path || req.path, status_code: res.statusCode };
    end(labels);
    httpRequestTotal.inc(labels);
  });
  next();
}
```

## Metrics Endpoint

```typescript
// GET /metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.end(await registry.metrics());
});
```

## Key Decisions

- **Pino over Winston**: 5x faster, native JSON output, lower memory
- **Redact sensitive fields**: Authorization headers and passwords auto-masked
- **Child loggers**: Add `requestId` context without passing it everywhere
- **Histogram buckets**: Tuned for API latency (10ms to 5s range)
- **Route labels**: Group metrics by route pattern, not raw URL (avoids cardinality explosion)



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
