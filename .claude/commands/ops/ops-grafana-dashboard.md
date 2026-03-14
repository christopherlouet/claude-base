# Agent GRAFANA-DASHBOARD

Creation de dashboards Grafana avec provisioning automatique.

## Contexte de la demande
$ARGUMENTS

## Objectif

Generer des dashboards Grafana complets avec datasources, panels,
variables, alertes et provisioning pour differents types de monitoring.

## Workflow

- Identifier le type de dashboard (API REST, Application, Database, Infrastructure, Custom)
- Generer les fichiers de provisioning (datasources.yaml, dashboards.yaml)
- Creer les dashboards JSON avec panels adaptes et thresholds
- Configurer les variables de filtrage (env, service, namespace)
- Definir les regles d'alerting et les contact points
- Generer le docker-compose d'integration Grafana
- Valider que les metriques cibles existent

## Output attendu

1. **Fichiers de provisioning** : datasources.yaml, dashboards.yaml
2. **Dashboards JSON** : un par type selectionne
3. **Alertes** : regles et contact points configures
4. **Docker Compose** : integration Grafana prete

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Instrumenter le code pour exposer les metriques |
| `/ops:ops-observability-stack` | Deployer Prometheus/Grafana/Loki |
| `/ops:ops-k8s` | Deploiement Kubernetes |

---

IMPORTANT: Toujours tester les dashboards en local avant deploiement.

YOU MUST adapter les thresholds au contexte de l'application.

NEVER exposer Grafana sans authentification en production.

Think hard sur les metriques les plus pertinentes pour le contexte.
