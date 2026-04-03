# Guide Observabilite

> Logs, metriques et traces pour des applications production fiables

## Les 3 Piliers de l'Observabilite

| Pilier | Definition | Use Case principal | Outils | Cout relatif |
|--------|------------|-------------------|--------|--------------|
| **Logs** | Evenements discrets horodates avec contexte | Debugger un comportement inattendu, audit trail | Loki, Elasticsearch, CloudWatch | Moyen (volume) |
| **Metriques** | Mesures numeriques agreges dans le temps | Alertes, dashboards, tendances de performance | Prometheus, Datadog, InfluxDB | Faible (scalable) |
| **Traces** | Chemin d'une requete a travers plusieurs services | Identifier la source d'une latence en systeme distribue | Jaeger, Tempo, Datadog APM | Eleve (sampling conseille) |

Les trois piliers sont complementaires : les metriques alertent, les logs expliquent, les traces localisent.

## Logging Structure

### Pourquoi le logging structure

| Logging non structure | Logging structure |
|-----------------------|-------------------|
| `"User 42 logged in from Paris"` | `{"event":"user.login","user_id":42,"city":"Paris"}` |
| Impossible a filtrer precisement | Filtrable par champ exact |
| Cout de parsing eleve | Parse zero-cost |
| Agregation manuelle | Agregation native (count, group by) |
| Correlation manuelle entre services | Correlation par `trace_id`/`request_id` |

### Niveaux de log

| Niveau | Quand l'utiliser | Exemple |
|--------|-----------------|---------|
| `DEBUG` | Developpement uniquement, detail interne | Valeur d'une variable intermediaire |
| `INFO` | Evenements metier normaux | Commande creee, utilisateur connecte |
| `WARN` | Situation anormale mais recuperee | Retry reussi apres echec reseau |
| `ERROR` | Erreur impactant une requete, action requise | Paiement echoue, base inaccessible |
| `FATAL` | Erreur bloquant tout le processus | Impossible de demarrer, config absente |

Regle : en production, le niveau minimum est `INFO`. Activer `DEBUG` uniquement sur demande explicite, jamais en permanence.

### Setup logger Node.js avec pino

```typescript
// src/utils/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: {
    service: process.env.SERVICE_NAME ?? 'api',
    version: process.env.npm_package_version,
    env: process.env.NODE_ENV,
  },
  redact: {
    paths: ['req.headers.authorization', '*.password', '*.token', '*.secret'],
    censor: '[REDACTED]',
  },
  formatters: {
    level(label) {
      return { level: label };
    },
  },
  timestamp: pino.stdTimeFunctions.isoTime,
});

// Logger enfant avec contexte request
export function createRequestLogger(requestId: string, userId?: string) {
  return logger.child({ request_id: requestId, user_id: userId });
}
```

```typescript
// Middleware Express : injecter request_id sur chaque requete
import { randomUUID } from 'crypto';

app.use((req, res, next) => {
  const requestId = (req.headers['x-request-id'] as string) ?? randomUUID();
  req.log = createRequestLogger(requestId, req.user?.id);
  res.setHeader('x-request-id', requestId);
  next();
});

// Utilisation dans un controller
export const createOrder = async (req: Request, res: Response) => {
  req.log.info({ items: req.body.items.length }, 'order.create.start');

  try {
    const order = await orderService.create(req.body);
    req.log.info({ order_id: order.id, total: order.total }, 'order.create.success');
    res.status(201).json({ data: order });
  } catch (err) {
    req.log.error({ err }, 'order.create.failed');
    throw err;
  }
};
```

### Setup logging structure Python avec structlog

```python
# src/utils/logger.py
import structlog
import logging

def configure_logging(level: str = "INFO") -> None:
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso", utc=True),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(
            logging.getLevelName(level)
        ),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
    )

log = structlog.get_logger()

# Utilisation avec contexte
async def create_order(order_data: OrderCreate, user_id: str) -> Order:
    bound_log = log.bind(user_id=user_id, items_count=len(order_data.items))
    bound_log.info("order.create.start")

    try:
        order = await order_service.create(order_data)
        bound_log.info("order.create.success", order_id=str(order.id), total=float(order.total))
        return order
    except Exception as exc:
        bound_log.error("order.create.failed", error=str(exc))
        raise
```

### Ce qu'il faut et ne faut pas logger

| Logger (DO) | Ne pas logger (DON'T) |
|-------------|----------------------|
| `request_id`, `trace_id` | Mots de passe, tokens, secrets |
| Duree de traitement (`duration_ms`) | Numeros de carte bancaire |
| Status HTTP de la reponse | Donnees personnelles non necessaires (PII) |
| Identifiant metier (`order_id`, `user_id`) | Corps de requete entier (peut contenir des secrets) |
| Type et message d'erreur | Stack traces en production (garder dans monitoring) |
| Nom du service, version, environnement | Donnees de sante (conformite RGPD) |

### Format JSON avec correlation IDs

```json
{
  "timestamp": "2026-04-03T10:22:14.312Z",
  "level": "info",
  "service": "order-api",
  "version": "2.4.1",
  "env": "production",
  "event": "order.create.success",
  "request_id": "01HV3K2M9P-abc123",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "user_id": "usr_789",
  "order_id": "ord_456",
  "duration_ms": 142
}
```

## Metriques

### Types de metriques

| Type | Definition | Exemple |
|------|------------|---------|
| **Counter** | Valeur monotone croissante, jamais negative | Nombre total de requetes, erreurs |
| **Gauge** | Valeur instantanee, peut monter ou descendre | Connexions actives, taille de file |
| **Histogram** | Distribution de valeurs (buckets configurables) | Latence de requete (p50, p95, p99) |
| **Summary** | Quantiles pre-calcules cote client | Identique a histogram, moins scalable |

Preferez les histogrammes aux summaries : ils permettent l'agregation entre instances.

### Methode RED (services)

Pour chaque service ou endpoint, mesurer :

| Signal | Metrique | Prometheus |
|--------|----------|------------|
| **R**ate | Requetes par seconde | `rate(http_requests_total[1m])` |
| **E**rrors | Taux d'erreur (%) | `rate(http_errors_total[1m]) / rate(http_requests_total[1m])` |
| **D**uration | Latence (p95, p99) | `histogram_quantile(0.95, http_request_duration_seconds)` |

### Methode USE (ressources)

Pour chaque ressource (CPU, memoire, disque, reseau) :

| Signal | Metrique | Seuil d'alerte |
|--------|----------|----------------|
| **U**tilization | Pourcentage utilise | > 80% sur 5 min |
| **S**aturation | Queue ou attente | > 0 en continu |
| **E**rrors | Erreurs systeme | Tout > 0 |

### Metriques Prometheus en Node.js

```typescript
// src/utils/metrics.ts
import { Registry, Counter, Histogram, Gauge } from 'prom-client';

export const registry = new Registry();

// Metriques HTTP standard
export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [registry],
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [registry],
});

// Metrique metier personnalisee
export const ordersCreatedTotal = new Counter({
  name: 'orders_created_total',
  help: 'Total number of orders created',
  labelNames: ['payment_method', 'status'],
  registers: [registry],
});

export const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active database connections',
  registers: [registry],
});
```

```typescript
// Middleware Express : collecter les metriques automatiquement
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const labels = {
      method: req.method,
      route: req.route?.path ?? 'unknown',
      status_code: String(res.statusCode),
    };
    httpRequestsTotal.inc(labels);
    end(labels);
  });
  next();
});

// Endpoint scraping Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.end(await registry.metrics());
});
```

```typescript
// Metriques metier personnalisees dans le service
export class OrderService {
  async create(data: OrderCreateInput): Promise<Order> {
    const order = await this.repo.create(data);

    ordersCreatedTotal.inc({
      payment_method: data.paymentMethod,
      status: order.status,
    });

    return order;
  }
}
```

### Metriques cles a surveiller

| Metrique | Type | Seuil alerte | Priorite |
|----------|------|-------------|---------|
| Latence p95 requete HTTP | Histogram | > 500ms | P1 |
| Latence p99 requete HTTP | Histogram | > 2000ms | P0 |
| Taux d'erreur 5xx | Counter ratio | > 1% | P0 |
| Taux d'erreur 4xx | Counter ratio | > 5% | P2 |
| Throughput (req/s) | Counter | Baisse > 30% | P1 |
| Connexions DB actives | Gauge | > 80% pool | P1 |
| Memoire heap utilisee | Gauge | > 85% | P1 |
| Saturation CPU | Gauge | > 80% sur 5min | P1 |

## Tracing Distribue

### Concepts fondamentaux

- **Trace** : representation complete du chemin d'une requete, de l'entree jusqu'a la reponse finale
- **Span** : unite de travail elementaire dans une trace (appel DB, appel HTTP sortant, traitement metier)
- **Context propagation** : mecanisme de transmission du `trace_id` et `span_id` entre services via headers HTTP (`traceparent` W3C)

### Propagation entre services

```
Client HTTP
    |
    | traceparent: 00-4bf92f3577b34da6-00f067aa0ba902b7-01
    v
[API Gateway]          span_id: 00f067aa0ba902b7  (span racine)
    |
    | traceparent: 00-4bf92f3577b34da6-b7ad6b7169203331-01
    v
[Order Service]        span_id: b7ad6b7169203331  (span enfant)
    |
    +----> [DB Postgres]   span: db.query  (span enfant)
    |
    | traceparent: 00-4bf92f3577b34da6-a2fb4a1d1a96d312-01
    v
[Payment Service]      span_id: a2fb4a1d1a96d312  (span enfant)
    |
    +----> [Stripe API]    span: http.client  (span enfant)
```

### OpenTelemetry auto-instrumentation Node.js

```typescript
// src/instrumentation.ts  (charger AVANT tout autre import)
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: process.env.SERVICE_NAME ?? 'api',
    [SemanticResourceAttributes.SERVICE_VERSION]: process.env.npm_package_version,
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
  }),
  traceExporter: new OTLPTraceExporter({
    url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ?? 'http://otel-collector:4318/v1/traces',
  }),
  instrumentations: [
    getNodeAutoInstrumentations({
      '@opentelemetry/instrumentation-fs': { enabled: false },
    }),
  ],
});

sdk.start();
process.on('SIGTERM', () => sdk.shutdown());
```

```typescript
// Span manuel pour code metier
import { trace, SpanStatusCode } from '@opentelemetry/api';

const tracer = trace.getTracer('order-service');

export async function processOrder(orderId: string): Promise<void> {
  return tracer.startActiveSpan('order.process', async (span) => {
    span.setAttribute('order.id', orderId);

    try {
      await validateInventory(orderId);
      await chargePayment(orderId);
      await sendConfirmationEmail(orderId);

      span.setStatus({ code: SpanStatusCode.OK });
    } catch (err) {
      span.recordException(err as Error);
      span.setStatus({ code: SpanStatusCode.ERROR, message: (err as Error).message });
      throw err;
    } finally {
      span.end();
    }
  });
}
```

## Alerting

### Principes de conception des alertes

Une bonne alerte est :
- **Actionnable** : l'on-call sait quoi faire immediatement
- **Symptom-based** : alerte sur l'impact utilisateur, pas sur la cause interne
- **Non bruyante** : chaque alerte recue doit necessiter une action
- **Documentee** : chaque alerte a un runbook associe

### Niveaux de severite

| Severite | Declenchement | Notification | Exemple |
|----------|--------------|-------------|---------|
| **P0** | Immediatement | Page (SMS/appel) 24/7 | Site down, taux erreur > 5%, paiements bloques |
| **P1** | < 5 minutes | Slack + page si no-ack | Latence p99 > 2s, DB connexions epuisees |
| **P2** | < 30 minutes | Slack uniquement | Taux erreur 4xx eleve, saturation CPU > 80% |
| **P3** | Prochaine iteration | Ticket backlog | Tendance degrade, dette technique observable |

### SLI, SLO et SLA

| Concept | Definition | Exemple |
|---------|------------|---------|
| **SLI** (Indicator) | Metrique mesuree | `% requetes avec latence < 200ms` |
| **SLO** (Objective) | Cible interne | `99.5% des requetes sous 200ms sur 30 jours` |
| **SLA** (Agreement) | Engagement contractuel | `99% de disponibilite, penalites si non-respecte` |
| **Error budget** | Marge avant violation SLO | `0.5% = ~3.6h/mois de degradation autorisee` |

### Regles d'alerte Prometheus

```yaml
# alerting-rules.yml
groups:
  - name: api.rules
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: |
          (
            sum(rate(http_requests_total{status_code=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
          ) > 0.01
        for: 2m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "Taux d'erreur HTTP 5xx eleve ({{ $value | humanizePercentage }})"
          description: "Le service {{ $labels.service }} depasse 1% d'erreurs 5xx depuis 2 minutes."
          runbook: "https://wiki.example.com/runbooks/high-error-rate"

      - alert: HighLatency
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le, route)
          ) > 2.0
        for: 5m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "Latence p99 elevee sur {{ $labels.route }}"
          description: "P99 = {{ $value | humanizeDuration }} sur la route {{ $labels.route }}."
          runbook: "https://wiki.example.com/runbooks/high-latency"

      - alert: DatabaseConnectionPoolExhausted
        expr: active_connections / max_connections > 0.85
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Pool de connexions DB proche de la saturation ({{ $value | humanizePercentage }})"
          runbook: "https://wiki.example.com/runbooks/db-pool"
```

### Bonnes pratiques on-call

- Chaque alerte pointe vers un **runbook** : contexte, diagnostic, actions correctives
- Revoir les alertes non-actionnees toutes les 2 semaines (supprimer ou ajuster)
- Mesurer le **mean time to acknowledge (MTTA)** et le **mean time to resolve (MTTR)**
- Faire un **post-mortem blameless** pour chaque incident P0/P1

## Stack Recommandee

| Taille projet | Logs | Metriques | Traces | Cout |
|---------------|------|-----------|--------|------|
| **Petit** (hobby, startup early) | stdout + Papertrail | Uptime Robot | Aucun | Quasi zero |
| **Moyen** (< 10 services) | Loki + Grafana | Prometheus + Grafana | Tempo (sampling 10%) | ~50-200 EUR/mois self-hosted |
| **Grand** (> 10 services) | Datadog Logs ou Grafana Cloud | Datadog Metrics ou Grafana Cloud | Datadog APM ou Grafana Tempo | ~500-5000 EUR/mois |
| **Self-hosted complet** | Loki | Prometheus | Tempo | OpenTelemetry Collector |

### Architecture self-hosted (Grafana Stack)

```
Applications
    |
    | OTLP (gRPC/HTTP)
    v
[OpenTelemetry Collector]
    |           |           |
    v           v           v
 [Loki]   [Prometheus]  [Tempo]
    \           |           /
     \          |          /
      \         v         /
       \    [Grafana]    /
        \_______________/
                |
            Dashboards
            Alerting
            On-call
```

## Dashboards

### Les 4 golden signals (layout recommande)

```
+----------------------------+----------------------------+
|  Rate (req/s)              |  Error Rate (%)            |
|  [graph sur 1h]            |  [graph sur 1h, rouge >1%] |
+----------------------------+----------------------------+
|  Latency p50 / p95 / p99   |  Saturation (CPU/Mem %)    |
|  [graph multi-line sur 1h] |  [gauge + graph sur 1h]    |
+----------------------------+----------------------------+
```

### Checklist dashboard service

- [ ] Rate : requetes/seconde par endpoint principal
- [ ] Error rate : 4xx et 5xx separes
- [ ] Latence : p50, p95, p99 (pas seulement la moyenne)
- [ ] Saturation : CPU, memoire, connexions DB
- [ ] SLO burn rate : consommation de l'error budget
- [ ] Logs recents : panel lien vers Loki pour le service
- [ ] Traces recentes : lien vers Tempo

### Exemple configuration Grafana (dashboard JSON abrege)

```json
{
  "title": "Order Service - Overview",
  "uid": "order-service-overview",
  "time": { "from": "now-1h", "to": "now" },
  "refresh": "30s",
  "panels": [
    {
      "title": "Request Rate",
      "type": "timeseries",
      "gridPos": { "x": 0, "y": 0, "w": 12, "h": 8 },
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{service='order-api'}[1m])) by (route)",
          "legendFormat": "{{ route }}"
        }
      ]
    },
    {
      "title": "Error Rate",
      "type": "timeseries",
      "gridPos": { "x": 12, "y": 0, "w": 12, "h": 8 },
      "fieldConfig": {
        "defaults": {
          "thresholds": {
            "steps": [
              { "color": "green", "value": 0 },
              { "color": "red", "value": 0.01 }
            ]
          }
        }
      },
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{service='order-api',status_code=~'5..'}[1m])) / sum(rate(http_requests_total{service='order-api'}[1m]))",
          "legendFormat": "5xx rate"
        }
      ]
    },
    {
      "title": "Latency p50 / p95 / p99",
      "type": "timeseries",
      "gridPos": { "x": 0, "y": 8, "w": 12, "h": 8 },
      "targets": [
        {
          "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{service='order-api'}[1m])) by (le))",
          "legendFormat": "p50"
        },
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service='order-api'}[1m])) by (le))",
          "legendFormat": "p95"
        },
        {
          "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service='order-api'}[1m])) by (le))",
          "legendFormat": "p99"
        }
      ]
    }
  ]
}
```

## Commandes Socle

```bash
# Mettre en place le monitoring complet
/ops:ops-monitoring

# Deployer la stack observabilite (Prometheus + Loki + Grafana + Tempo)
/ops:ops-observability-stack

# Generer un dashboard Grafana pour un service
/ops:ops-grafana-dashboard "order-service"

# Verifier l'etat de sante des services
/ops:ops-health
```

## Anti-patterns a Eviter

| Anti-pattern | Consequence | Solution |
|-------------|-------------|---------|
| Logger tout sans discernement | Cout explosif, signal noye dans le bruit | Choisir les evenements metier significatifs |
| Logs non structures (texte brut) | Impossible a filtrer ou agreger | Passer a JSON avec pino ou structlog |
| Pas de correlation ID | Debug impossible en multi-service | Propager `request_id` et `trace_id` systematiquement |
| Alertes trop nombreuses | Fatigue d'alerte, ignorer les vraies alertes | Une alerte = une action ; supprimer le reste |
| Pas de runbook par alerte | L'on-call ne sait pas quoi faire a 3h du matin | Chaque alerte reference un runbook |
| Metriques sans dashboard | Donnees inutilisables, blind spots | Dashboard avant de deployer en production |
| Sampling traces a 100% | Cout prohibitif en production | Sampling adaptatif : 100% erreurs, 1-10% normal |
| Alertes sur des causes internes | Faux positifs, over-engineering | Alerter sur les symptomes utilisateur (latence, erreurs) |
| Moyenne de latence uniquement | Masque les queues de distribution | Toujours monitorer p95 et p99 |

## Ressources

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Loki](https://grafana.com/oss/loki/)
- [The RED Method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/)
- [Google SRE Book - Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
