# MONITORING Agent

Code instrumentation for monitoring/logging/alerting **and** deploying the observability stack.

## Request context
$ARGUMENTS

## Objective

Set up the 3 pillars of observability (logs, metrics, traces) with error tracking,
health checks and alerting rules — then, when needed, deploy the backing stack
(Prometheus, Grafana, Loki, Alertmanager).

## Workflow — instrument the code

- Analyze the technical stack and existing tools
- Configure error tracking (Sentry)
- Implement structured logging (Pino, structlog, zap)
- Expose Prometheus metrics (/metrics)
- Configure OpenTelemetry for distributed tracing (optional)
- Add health checks (/health/live, /health/ready)
- Define alerting rules (error rate, latency, CPU, memory)
- Mask sensitive data in logs (GDPR)

## Workflow — deploy the observability stack

- Identify the deployment mode (Docker Compose for dev/staging, Kubernetes + Helm for prod, Victoria Metrics, managed)
- Configure Prometheus (scrape configs, alert rules) and Alertmanager (routes, Slack/PagerDuty/email receivers)
- Configure Grafana (provisioning datasources + dashboards) and Loki + Promtail (log aggregation)
- Add node-exporter and cAdvisor for system metrics
- Document the deployment and verification commands
- Persistent storage for metrics; never expose Prometheus/Alertmanager without auth in production

## Expected output

1. **Error tracking** configured (Sentry or equivalent)
2. **Logger** structured with sensitive data redaction
3. **Prometheus metrics** exposed, **health checks** (liveness/readiness), **alert rules**
4. **Stack deployment** (when requested): docker-compose.yml or Helm values, prometheus.yml + alert.rules.yml, alertmanager.yml, Loki/Promtail configs, Grafana provisioning

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-k8s` | Deploy the stack on Kubernetes |
| `/ops:ops-docker` | Containerize the services |
| `/ops:ops-health` | Quick health check |
| `/qa:qa-perf` | Performance analysis |

## See also

For Grafana-specific depth, pair this with [`grafana/skills`](https://github.com/grafana/skills) — install per [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Grafana Labs — `grafana/skills`". The vendor covers the Grafana surface; this command keeps the **multi-tool wiring** it orchestrates (Prometheus + Loki + Alertmanager + Promtail + exporters), which no single vendor skill replaces.

---

IMPORTANT: Do not log personal data (GDPR) - use redaction.

IMPORTANT: Configure alerts BEFORE deploying to production; test the stack in staging first.

YOU MUST have health checks for Kubernetes/load balancers.

NEVER ignore alerts - every alert must be actionable.

NEVER expose Prometheus/Alertmanager without authentication in production.
