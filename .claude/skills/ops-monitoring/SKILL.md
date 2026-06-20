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

## Deploying the observability stack

Once the code is instrumented, deploy the backing stack (Prometheus + Grafana + Loki + Alertmanager).

- **Mode**: Docker Compose for dev/staging, Kubernetes + Helm for production (or Victoria Metrics / managed).
- **Prometheus**: `prometheus.yml` scrape configs + `alert.rules.yml`.
- **Alertmanager**: `alertmanager.yml` routes + receivers (Slack / PagerDuty / email).
- **Grafana**: provision datasources + dashboards.
- **Loki + Promtail**: log aggregation; add `node-exporter` + `cAdvisor` for system metrics.
- Persistent storage for metrics data; **never** expose Prometheus/Alertmanager without auth in production; configure alerts before going to prod and test the stack in staging first.

## See also

Grafana Labs publishes their own official agent skills at [`grafana/skills`](https://github.com/grafana/skills) (31★, last commit 2026-05-04). The repo covers Grafana Core, Grafana Cloud, the LGTM stack (Loki/Grafana/Tempo/Mimir), k6 performance testing, and the Grafana app SDK. A separate companion repo [`grafana/pyroscope-skills`](https://github.com/grafana/pyroscope-skills) covers continuous profiling.

When working on a project that uses the Grafana / LGTM stack, install the vendor skill alongside this one. This skill captures the **three-pillar instrumentation overview** (logs / metrics / traces) and the foundation's basic OTEL + health-check skeleton; the vendor skill captures the **canonical Grafana operational patterns** that evolve with each Grafana release. For non-Grafana stacks (Datadog, New Relic, Honeycomb, etc.), this skill remains the primary reference.

**Vendor-neutrality**: Grafana Labs is independent. No concern.

Install command and full list of validated vendor skills: `docs/recipes/recommended-vendor-skills.md`. Audit pilot trace: `specs/marketplace-audit/ops-skills-pilot-2026-05-06.md`.
