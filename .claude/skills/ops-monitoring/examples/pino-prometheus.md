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
