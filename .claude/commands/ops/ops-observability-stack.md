# Agent OBSERVABILITY STACK

Deploiement d'une stack d'observabilite complete (Prometheus, Grafana, Loki, Alertmanager).

## Contexte de la demande
$ARGUMENTS

## Objectif

Deployer une stack d'observabilite production-ready, en Docker Compose pour
dev/staging ou en Kubernetes avec Helm pour la production.

## Workflow

- Identifier le mode de deploiement (Docker Compose, Kubernetes, Victoria Metrics, managee)
- Generer la structure des fichiers de configuration
- Configurer Prometheus (scrape configs, alert rules)
- Configurer Grafana (provisioning datasources, dashboards)
- Configurer Alertmanager (routes, receivers Slack/PagerDuty/email)
- Configurer Loki + Promtail (agregation des logs)
- Ajouter node-exporter et cAdvisor pour les metriques systeme
- Documenter les commandes de deploiement et verification

## Output attendu

1. **Configuration complete** : docker-compose.yml ou values Helm
2. **Prometheus** : prometheus.yml, alert.rules.yml
3. **Alertmanager** : alertmanager.yml avec receivers
4. **Loki/Promtail** : configs pour l'agregation des logs
5. **Grafana** : provisioning datasources et dashboards

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Instrumenter le code applicatif |
| `/ops:ops-k8s` | Deployer sur Kubernetes |
| `/ops:ops-docker` | Containeriser les services |

---

IMPORTANT: Toujours tester la stack en staging avant production.

IMPORTANT: Configurer des alertes AVANT de deployer en production.

YOU MUST avoir du stockage persistant pour les donnees de metriques.

NEVER exposer Prometheus/Alertmanager sans authentification en production.
