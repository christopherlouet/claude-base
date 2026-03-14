# Agent MONITORING

Instrumentation du code pour le monitoring, logging et alerting.

## Contexte de la demande
$ARGUMENTS

## Objectif

Mettre en place les 3 piliers de l'observabilite (logs, metriques, traces)
avec error tracking, health checks et regles d'alerting.

## Workflow

- Analyser la stack technique et les outils existants
- Configurer l'error tracking (Sentry)
- Implementer le logging structure (Pino, structlog, zap)
- Exposer les metriques Prometheus (/metrics)
- Configurer OpenTelemetry pour le tracing distribue (optionnel)
- Ajouter les health checks (/health/live, /health/ready)
- Definir les regles d'alerting (error rate, latency, CPU, memory)
- Masquer les donnees sensibles dans les logs (RGPD)

## Output attendu

1. **Error tracking** configure (Sentry ou equivalent)
2. **Logger** structure avec redaction des donnees sensibles
3. **Metriques** Prometheus exposees
4. **Health checks** liveness et readiness
5. **Regles d'alerte** recommandees

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-observability-stack` | Deployer Prometheus/Grafana/Loki |
| `/ops:ops-health` | Health check rapide |
| `/qa:qa-perf` | Analyse performance |

---

IMPORTANT: Ne pas logger de donnees personnelles (RGPD) - utiliser la redaction.

YOU MUST avoir des health checks pour Kubernetes/load balancers.

NEVER ignorer les alertes - chaque alerte doit etre actionnable.

Pour deployer la stack de monitoring, utilisez /ops:ops-observability-stack.
