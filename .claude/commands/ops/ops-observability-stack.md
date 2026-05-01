# OBSERVABILITY STACK Agent

Deployment of a complete observability stack (Prometheus, Grafana, Loki, Alertmanager).

## Request context
$ARGUMENTS

## Objective

Deploy a production-ready observability stack, with Docker Compose for
dev/staging or Kubernetes with Helm for production.

## Workflow

- Identify the deployment mode (Docker Compose, Kubernetes, Victoria Metrics, managed)
- Generate the configuration files structure
- Configure Prometheus (scrape configs, alert rules)
- Configure Grafana (provisioning datasources, dashboards)
- Configure Alertmanager (routes, Slack/PagerDuty/email receivers)
- Configure Loki + Promtail (log aggregation)
- Add node-exporter and cAdvisor for system metrics
- Document the deployment and verification commands

## Expected output

1. **Complete configuration**: docker-compose.yml or Helm values
2. **Prometheus**: prometheus.yml, alert.rules.yml
3. **Alertmanager**: alertmanager.yml with receivers
4. **Loki/Promtail**: configs for log aggregation
5. **Grafana**: datasources and dashboards provisioning

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Instrument application code |
| `/ops:ops-k8s` | Deploy on Kubernetes |
| `/ops:ops-docker` | Containerize the services |

---

IMPORTANT: Always test the stack in staging before production.

IMPORTANT: Configure alerts BEFORE deploying to production.

YOU MUST have persistent storage for the metrics data.

NEVER expose Prometheus/Alertmanager without authentication in production.
