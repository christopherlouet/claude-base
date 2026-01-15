# Agent MONITORING

Mise en place du monitoring, logging et alerting.

## Contexte
$ARGUMENTS

## Processus de mise en place

### 1. Analyser le projet

```bash
# Stack technique
cat package.json 2>/dev/null | grep -E "sentry|datadog|newrelic|pino|winston"
cat requirements.txt 2>/dev/null | grep -E "sentry|datadog|structlog|logging"

# Configuration existante
ls -la src/lib/logger* 2>/dev/null
ls -la src/config/monitoring* 2>/dev/null
grep -rn "console.log\|logger\." --include="*.ts" | head -10
```

### 2. Les 3 piliers de l'observabilité

```
┌─────────────────────────────────────────────────────────┐
│                    OBSERVABILITÉ                         │
├─────────────────┬─────────────────┬─────────────────────┤
│     LOGS        │    METRICS      │     TRACES          │
│                 │                 │                     │
│ Événements      │ Mesures         │ Parcours requêtes   │
│ textuels        │ numériques      │ distribuées         │
│                 │                 │                     │
│ Winston, Pino   │ Prometheus      │ OpenTelemetry       │
│ Datadog Logs    │ Datadog         │ Jaeger, Zipkin      │
└─────────────────┴─────────────────┴─────────────────────┘
```

### 3. Error Tracking (Sentry)

#### Installation
```bash
npm install @sentry/node @sentry/profiling-node
```

#### Configuration Node.js/Express
```typescript
// lib/sentry.ts
import * as Sentry from '@sentry/node';
import { ProfilingIntegration } from '@sentry/profiling-node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.npm_package_version,
  integrations: [
    new ProfilingIntegration(),
  ],
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  profilesSampleRate: 0.1,
});

export { Sentry };
```

#### Middleware Express
```typescript
// app.ts
import * as Sentry from '@sentry/node';

const app = express();

// RequestHandler crée une transaction par requête
Sentry.setupExpressErrorHandler(app);

// Après toutes les routes
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  Sentry.captureException(err);
  res.status(500).json({ error: 'Internal server error' });
});
```

#### Capturer des erreurs manuellement
```typescript
try {
  await riskyOperation();
} catch (error) {
  Sentry.captureException(error, {
    tags: { feature: 'payment' },
    extra: { userId, orderId },
  });
  throw error;
}
```

#### Frontend (React/Next.js)
```typescript
// lib/sentry-client.ts
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});
```

### 4. Logging structuré

#### Pino (Node.js - recommandé)
```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty' }
    : undefined,
  redact: {
    paths: ['req.headers.authorization', 'password', 'token'],
    censor: '[REDACTED]',
  },
  base: {
    service: 'my-api',
    version: process.env.npm_package_version,
  },
});

// Contexte par requête
export function createRequestLogger(req: Request) {
  return logger.child({
    requestId: req.id,
    userId: req.user?.id,
    path: req.path,
    method: req.method,
  });
}
```

#### Utilisation
```typescript
// Dans les handlers
app.get('/users/:id', async (req, res) => {
  const log = createRequestLogger(req);

  log.info({ userId: req.params.id }, 'Fetching user');

  try {
    const user = await userService.getById(req.params.id);
    log.info({ user: user.id }, 'User fetched successfully');
    res.json(user);
  } catch (error) {
    log.error({ error, userId: req.params.id }, 'Failed to fetch user');
    throw error;
  }
});
```

#### Niveaux de log
| Niveau | Usage |
|--------|-------|
| `fatal` | Erreur fatale, crash imminent |
| `error` | Erreur, mais l'app continue |
| `warn` | Situation anormale mais gérée |
| `info` | Événements business importants |
| `debug` | Détails pour le debugging |
| `trace` | Détails très fins |

### 5. Métriques (Prometheus)

#### Exposition des métriques
```typescript
// lib/metrics.ts
import { Registry, Counter, Histogram, collectDefaultMetrics } from 'prom-client';

export const registry = new Registry();

// Métriques par défaut (CPU, memory, etc.)
collectDefaultMetrics({ register: registry });

// Métriques custom
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

// Métriques business
export const ordersCreated = new Counter({
  name: 'orders_created_total',
  help: 'Total number of orders created',
  labelNames: ['status', 'payment_method'],
  registers: [registry],
});
```

#### Middleware Express
```typescript
// middleware/metrics.ts
import { httpRequestDuration, httpRequestTotal } from '../lib/metrics';

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

// Endpoint /metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.send(await registry.metrics());
});
```

### 6. Health Checks

```typescript
// routes/health.ts
import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { redis } from '../lib/redis';

const router = Router();

// Liveness: l'app tourne-t-elle?
router.get('/health/live', (req, res) => {
  res.json({ status: 'ok' });
});

// Readiness: l'app peut-elle servir du trafic?
router.get('/health/ready', async (req, res) => {
  const checks = {
    database: false,
    redis: false,
  };

  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = true;
  } catch (e) {
    // DB down
  }

  try {
    await redis.ping();
    checks.redis = true;
  } catch (e) {
    // Redis down
  }

  const allHealthy = Object.values(checks).every(Boolean);
  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'ok' : 'degraded',
    checks,
    timestamp: new Date().toISOString(),
  });
});

export { router as healthRouter };
```

### 7. Alerting

#### Règles d'alerte recommandées

| Métrique | Condition | Sévérité | Action |
|----------|-----------|----------|--------|
| Error rate | > 1% sur 5min | Critical | Page on-call |
| Latency P99 | > 2s sur 5min | Warning | Notification |
| CPU | > 80% sur 10min | Warning | Scale up |
| Memory | > 90% | Critical | Investigate |
| Disk | > 85% | Warning | Cleanup |
| 5xx responses | > 10/min | Critical | Investigate |

#### Sentry Alerts
```
Configuration Sentry:
1. Alerts → Create Alert Rule
2. Conditions:
   - First seen issue
   - Issue frequency > 10 in 1 hour
3. Actions:
   - Send Slack notification
   - Send email to team
```

#### Prometheus Alerting (alertmanager)
```yaml
# alerts.yml
groups:
  - name: api
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: HighLatency
        expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
```

### 8. Dashboard

#### Métriques clés à afficher

```
┌─────────────────────────────────────────────────────────┐
│                    DASHBOARD                             │
├───────────────┬───────────────┬─────────────────────────┤
│   Requests    │   Errors      │   Latency P50/P99       │
│   12.5k/min   │   0.1%        │   45ms / 230ms          │
├───────────────┴───────────────┴─────────────────────────┤
│                                                         │
│   [Graphe: Requêtes par minute sur 24h]                │
│                                                         │
├───────────────┬───────────────┬─────────────────────────┤
│   CPU         │   Memory      │   Disk                  │
│   34%         │   62%         │   45%                   │
├───────────────┴───────────────┴─────────────────────────┤
│                                                         │
│   [Graphe: Erreurs par type sur 24h]                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 9. Stack recommandée

#### Option 1: SaaS (recommandé pour débuter)
| Besoin | Outil | Coût |
|--------|-------|------|
| Errors | Sentry | Gratuit jusqu'à 5k events |
| Logs | Datadog / Logtail | Variable |
| Metrics | Datadog | Variable |
| Uptime | BetterUptime / Pingdom | Gratuit/Payant |

#### Option 2: Self-hosted
| Besoin | Outil |
|--------|-------|
| Errors | Sentry (self-hosted) |
| Logs | Loki + Grafana |
| Metrics | Prometheus + Grafana |
| Traces | Jaeger |
| Alerting | Alertmanager |

### 10. Checklist de mise en place

- [ ] Error tracking configuré (Sentry)
- [ ] Logging structuré implémenté
- [ ] Health checks exposés
- [ ] Métriques de base exposées
- [ ] Dashboard créé
- [ ] Alertes configurées
- [ ] Runbook documenté

## Output attendu

### Architecture monitoring
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    App      │────>│   Sentry    │────>│   Slack     │
│             │     └─────────────┘     │   Email     │
│             │     ┌─────────────┐     └─────────────┘
│             │────>│ Prometheus  │────>│  Grafana    │
│             │     └─────────────┘     └─────────────┘
└─────────────┘
```

### Configuration recommandée
| Composant | Outil | Configuration |
|-----------|-------|---------------|
| Errors | Sentry | DSN configuré |
| Logs | Pino | JSON structuré |
| Metrics | Prometheus | /metrics exposé |
| Dashboards | Grafana | Panels créés |
| Alerts | Sentry + Alertmanager | Rules définies |

### Code à implémenter
[Snippets prêts à l'emploi]

### Alertes configurées
| Alerte | Seuil | Notification |
|--------|-------|--------------|
| Error rate | > 1% | Slack + Email |
| Latency P99 | > 2s | Slack |
| Memory | > 90% | Email |

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/health` | Health check rapide |
| `/infra-code` | Provisionner monitoring |
| `/ci` | Intégrer dans CI/CD |
| `/perf` | Analyse performance |
| `/security` | Audit des logs |

---

IMPORTANT: Ne pas logger de données personnelles (RGPD) - utiliser la redaction.

YOU MUST avoir des health checks pour Kubernetes/load balancers.

NEVER ignorer les alertes - chaque alerte doit être actionnable.

Think hard sur ce qui est vraiment critique vs nice-to-have pour les alertes.
