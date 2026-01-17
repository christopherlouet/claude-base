# Agent MONITORING

Instrumentation du code pour le monitoring, logging et alerting.

## Contexte
$ARGUMENTS

## Processus de mise en place

### 1. Analyser le projet

```bash
# Stack technique
cat package.json 2>/dev/null | grep -E "sentry|datadog|newrelic|pino|winston|opentelemetry"
cat requirements.txt 2>/dev/null | grep -E "sentry|datadog|structlog|opentelemetry|prometheus"
cat go.mod 2>/dev/null | grep -E "sentry|zap|prometheus|otel"

# Configuration existante
ls -la src/lib/logger* 2>/dev/null
ls -la src/config/monitoring* 2>/dev/null
```

### 2. Les 3 piliers de l'observabilite

```
┌─────────────────────────────────────────────────────────┐
│                    OBSERVABILITE                         │
├─────────────────┬─────────────────┬─────────────────────┤
│     LOGS        │    METRICS      │     TRACES          │
│                 │                 │                     │
│ Evenements      │ Mesures         │ Parcours requetes   │
│ textuels        │ numeriques      │ distribuees         │
│                 │                 │                     │
│ Pino, Zap       │ Prometheus      │ OpenTelemetry       │
│ structlog       │ prom-client     │ Jaeger, Tempo       │
└─────────────────┴─────────────────┴─────────────────────┘
```

---

## Node.js / TypeScript

### Error Tracking (Sentry)

#### Installation
```bash
npm install @sentry/node @sentry/profiling-node
```

#### Configuration
```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/node';
import { ProfilingIntegration } from '@sentry/profiling-node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.npm_package_version,
  integrations: [new ProfilingIntegration()],
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  profilesSampleRate: 0.1,
});

export { Sentry };
```

#### Middleware Express
```typescript
import * as Sentry from '@sentry/node';

const app = express();
Sentry.setupExpressErrorHandler(app);

app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  Sentry.captureException(err);
  res.status(500).json({ error: 'Internal server error' });
});
```

### Logging structure (Pino)

```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty' }
    : undefined,
  redact: {
    paths: ['req.headers.authorization', 'password', 'token', 'email'],
    censor: '[REDACTED]',
  },
  base: {
    service: 'my-api',
    version: process.env.npm_package_version,
    env: process.env.NODE_ENV,
  },
});

export function createRequestLogger(req: Request) {
  return logger.child({
    requestId: req.id,
    userId: req.user?.id,
    path: req.path,
    method: req.method,
  });
}
```

### Metriques (Prometheus)

```typescript
// lib/metrics.ts
import { Registry, Counter, Histogram, collectDefaultMetrics } from 'prom-client';

export const registry = new Registry();
collectDefaultMetrics({ register: registry });

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 5],
  registers: [registry],
});

export const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [registry],
});

// Middleware
export function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status: res.statusCode.toString(),
    };
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
  });
  next();
}

// Endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.send(await registry.metrics());
});
```

### OpenTelemetry (Tracing)

```bash
npm install @opentelemetry/api @opentelemetry/sdk-node \
  @opentelemetry/auto-instrumentations-node \
  @opentelemetry/exporter-trace-otlp-http
```

```typescript
// lib/tracing.ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'my-api',
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.npm_package_version,
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

process.on('SIGTERM', () => {
  sdk.shutdown().then(() => process.exit(0));
});
```

---

## Python

### Error Tracking (Sentry)

```bash
pip install sentry-sdk[fastapi]  # ou [flask], [django]
```

```python
# lib/sentry.py
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.environ.get("SENTRY_DSN"),
    environment=os.environ.get("ENV", "development"),
    release=os.environ.get("VERSION"),
    traces_sample_rate=0.1 if os.environ.get("ENV") == "production" else 1.0,
    profiles_sample_rate=0.1,
    integrations=[FastApiIntegration()],
)
```

### Logging structure (structlog)

```bash
pip install structlog
```

```python
# lib/logger.py
import structlog
import logging

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer() if os.environ.get("ENV") == "production"
        else structlog.dev.ConsoleRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Utilisation
logger.info("user_created", user_id=user.id, email="[REDACTED]")
logger.error("payment_failed", order_id=order.id, error=str(e))
```

### Metriques (prometheus_client)

```bash
pip install prometheus-client
```

```python
# lib/metrics.py
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from fastapi import Response

REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=[0.01, 0.05, 0.1, 0.5, 1, 5]
)

# Middleware FastAPI
@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)

    return response

# Endpoint
@app.get("/metrics")
async def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

### OpenTelemetry (Tracing)

```bash
pip install opentelemetry-api opentelemetry-sdk \
  opentelemetry-instrumentation-fastapi \
  opentelemetry-exporter-otlp
```

```python
# lib/tracing.py
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

resource = Resource.create({
    "service.name": "my-api",
    "service.version": os.environ.get("VERSION", "unknown"),
    "deployment.environment": os.environ.get("ENV", "development"),
})

provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(OTLPSpanExporter(
    endpoint=os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4318/v1/traces")
))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Instrumenter FastAPI
FastAPIInstrumentor.instrument_app(app)
```

---

## Go

### Error Tracking (Sentry)

```bash
go get github.com/getsentry/sentry-go
```

```go
// lib/sentry.go
package lib

import (
    "log"
    "os"
    "github.com/getsentry/sentry-go"
)

func InitSentry() {
    err := sentry.Init(sentry.ClientOptions{
        Dsn:              os.Getenv("SENTRY_DSN"),
        Environment:      os.Getenv("ENV"),
        Release:          os.Getenv("VERSION"),
        TracesSampleRate: 0.1,
    })
    if err != nil {
        log.Fatalf("sentry.Init: %s", err)
    }
}

// Middleware Gin
func SentryMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        defer sentry.Recover()
        c.Next()
    }
}
```

### Logging structure (zap)

```bash
go get go.uber.org/zap
```

```go
// lib/logger.go
package lib

import (
    "os"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

var Logger *zap.Logger

func InitLogger() {
    var config zap.Config

    if os.Getenv("ENV") == "production" {
        config = zap.NewProductionConfig()
        config.EncoderConfig.TimeKey = "timestamp"
        config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
    } else {
        config = zap.NewDevelopmentConfig()
        config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
    }

    config.InitialFields = map[string]interface{}{
        "service": "my-api",
        "version": os.Getenv("VERSION"),
    }

    var err error
    Logger, err = config.Build()
    if err != nil {
        panic(err)
    }
}

// Utilisation
Logger.Info("user created",
    zap.String("user_id", user.ID),
    zap.String("action", "create"),
)

Logger.Error("payment failed",
    zap.Error(err),
    zap.String("order_id", order.ID),
)
```

### Metriques (prometheus/client_golang)

```bash
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

```go
// lib/metrics.go
package lib

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    HttpRequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )

    HttpRequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration in seconds",
            Buckets: []float64{0.01, 0.05, 0.1, 0.5, 1, 5},
        },
        []string{"method", "endpoint"},
    )
)

// Middleware Gin
func MetricsMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()
        duration := time.Since(start).Seconds()

        HttpRequestsTotal.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
            strconv.Itoa(c.Writer.Status()),
        ).Inc()

        HttpRequestDuration.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
        ).Observe(duration)
    }
}

// Handler
router.GET("/metrics", gin.WrapH(promhttp.Handler()))
```

### OpenTelemetry (Tracing)

```bash
go get go.opentelemetry.io/otel
go get go.opentelemetry.io/otel/sdk
go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp
go get go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin
```

```go
// lib/tracing.go
package lib

import (
    "context"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
    "go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
)

func InitTracer() func() {
    ctx := context.Background()

    exporter, err := otlptracehttp.New(ctx,
        otlptracehttp.WithEndpoint(os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")),
        otlptracehttp.WithInsecure(),
    )
    if err != nil {
        log.Fatal(err)
    }

    res := resource.NewWithAttributes(
        semconv.SchemaURL,
        semconv.ServiceName("my-api"),
        semconv.ServiceVersion(os.Getenv("VERSION")),
        semconv.DeploymentEnvironment(os.Getenv("ENV")),
    )

    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(res),
    )
    otel.SetTracerProvider(tp)

    return func() { tp.Shutdown(ctx) }
}

// Middleware Gin
router.Use(otelgin.Middleware("my-api"))
```

---

## Health Checks

```typescript
// Node.js
router.get('/health/live', (req, res) => {
  res.json({ status: 'ok' });
});

router.get('/health/ready', async (req, res) => {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
  };
  const healthy = Object.values(checks).every(Boolean);
  res.status(healthy ? 200 : 503).json({ status: healthy ? 'ok' : 'degraded', checks });
});
```

```python
# Python (FastAPI)
@app.get("/health/live")
async def liveness():
    return {"status": "ok"}

@app.get("/health/ready")
async def readiness():
    checks = {
        "database": await check_database(),
        "redis": await check_redis(),
    }
    healthy = all(checks.values())
    status_code = 200 if healthy else 503
    return JSONResponse({"status": "ok" if healthy else "degraded", "checks": checks}, status_code)
```

```go
// Go (Gin)
router.GET("/health/live", func(c *gin.Context) {
    c.JSON(200, gin.H{"status": "ok"})
})

router.GET("/health/ready", func(c *gin.Context) {
    checks := map[string]bool{
        "database": checkDatabase(),
        "redis":    checkRedis(),
    }
    healthy := true
    for _, v := range checks {
        if !v { healthy = false }
    }
    status := 200
    if !healthy { status = 503 }
    c.JSON(status, gin.H{"status": "ok", "checks": checks})
})
```

---

## Niveaux de log

| Niveau | Usage |
|--------|-------|
| `fatal` | Erreur fatale, crash imminent |
| `error` | Erreur, mais l'app continue |
| `warn` | Situation anormale mais geree |
| `info` | Evenements business importants |
| `debug` | Details pour le debugging |
| `trace` | Details tres fins |

---

## Regles d'alerte recommandees

| Metrique | Condition | Severite | Action |
|----------|-----------|----------|--------|
| Error rate | > 1% sur 5min | Critical | Page on-call |
| Latency P99 | > 2s sur 5min | Warning | Notification |
| CPU | > 80% sur 10min | Warning | Scale up |
| Memory | > 90% | Critical | Investigate |
| 5xx responses | > 10/min | Critical | Investigate |

---

## Checklist de mise en place

- [ ] Error tracking configure (Sentry)
- [ ] Logging structure implemente
- [ ] Health checks exposes (/health/live, /health/ready)
- [ ] Metriques Prometheus exposees (/metrics)
- [ ] OpenTelemetry configure (optionnel)
- [ ] Alertes configurees
- [ ] Donnees sensibles masquees (RGPD)

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/observability-stack` | Deployer Prometheus, Grafana, Loki |
| `/health` | Health check rapide |
| `/perf` | Analyse performance |
| `/security` | Audit des logs (RGPD) |

---

IMPORTANT: Ne pas logger de donnees personnelles (RGPD) - utiliser la redaction.

YOU MUST avoir des health checks pour Kubernetes/load balancers.

NEVER ignorer les alertes - chaque alerte doit etre actionnable.

Pour deployer la stack de monitoring (Prometheus, Grafana, Loki), utilisez `/observability-stack`.
