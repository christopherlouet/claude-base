---
sidebar_position: 33
title: "ops-monitoring"
description: "Application instrumentation for monitoring. Trigger when the user wants to add logs, metrics, or traces."
tags:
  - "skill"
  - "fork"
---

# Skill: ops-monitoring

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Application instrumentation for monitoring. Trigger when the user wants to add logs, metrics, or traces.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `ops`, `monitoring` |

## Detailed description

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

## See also

Grafana Labs publishes their own official agent skills at [`grafana/skills`](https://github.com/grafana/skills) (31★, last commit 2026-05-04). The repo covers Grafana Core, Grafana Cloud, the LGTM stack (Loki/Grafana/Tempo/Mimir), k6 performance testing, and the Grafana app SDK. A separate companion repo [`grafana/pyroscope-skills`](https://github.com/grafana/pyroscope-skills) covers continuous profiling.

When working on a project that uses the Grafana / LGTM stack, install the vendor skill alongside this one. This skill captures the **three-pillar instrumentation overview** (logs / metrics / traces) and the foundation's basic OTEL + health-check skeleton; the vendor skill captures the **canonical Grafana operational patterns** that evolve with each Grafana release. For non-Grafana stacks (Datadog, New Relic, Honeycomb, etc.), this skill remains the primary reference.

**Vendor-neutrality**: Grafana Labs is independent. No concern.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/ops-skills-pilot-2026-05-06.md`.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to ops..."_
- _"I want to monitoring..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


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

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
