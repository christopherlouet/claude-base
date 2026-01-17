# Agent OBSERVABILITY STACK

Deploiement d'une stack d'observabilite complete (Prometheus, Grafana, Loki, Alertmanager).

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Stack de developpement (Docker Compose)
Deploie une stack locale pour tester le monitoring.

### Mode 2 : Stack de production (Kubernetes)
Deploie une stack production-ready avec Helm.

### Mode 3 : Stack legere (Victoria Metrics)
Alternative performante a Prometheus pour gros volumes.

### Mode 4 : Solutions managees
Configure les integrations avec Grafana Cloud, Datadog, etc.

---

## Architecture de la Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                      OBSERVABILITY STACK                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐                                                    │
│  │ Applications│                                                    │
│  │  /metrics   │                                                    │
│  │  (logs)     │                                                    │
│  └──────┬──────┘                                                    │
│         │                                                            │
│    ┌────┴────┬─────────────┬─────────────┐                         │
│    ▼         ▼             ▼             ▼                          │
│ ┌──────┐ ┌──────┐    ┌─────────┐  ┌───────────┐                    │
│ │Prom- │ │ Loki │    │ Tempo/  │  │ Promtail/ │                    │
│ │etheus│ │(logs)│    │ Jaeger  │  │ Fluent Bit│                    │
│ │      │ │      │    │(traces) │  │ (collect) │                    │
│ └──┬───┘ └──┬───┘    └────┬────┘  └───────────┘                    │
│    │        │             │                                         │
│    └────────┴──────┬──────┘                                         │
│                    ▼                                                 │
│            ┌─────────────┐      ┌──────────────┐                    │
│            │   Grafana   │─────>│    Users     │                    │
│            │ (visualize) │      │ (dashboards) │                    │
│            └─────────────┘      └──────────────┘                    │
│                    │                                                 │
│            ┌───────▼───────┐                                        │
│            │ Alertmanager  │──> Slack, PagerDuty, Email            │
│            └───────────────┘                                        │
│                                                                      │
│  Long-term: Thanos / Victoria Metrics / Mimir / Cortex             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Stack Docker Compose (Dev/Staging)

### Structure des fichiers
```
monitoring/
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml
│   ├── alert.rules.yml
│   └── targets/
│       └── targets.yml
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasources.yml
│   │   └── dashboards/
│   │       ├── dashboards.yml
│   │       └── json/
│   │           ├── node-exporter.json
│   │           └── application.json
│   └── grafana.ini
├── alertmanager/
│   └── alertmanager.yml
├── loki/
│   └── loki-config.yml
└── promtail/
    └── promtail-config.yml
```

### docker-compose.yml
```yaml
version: '3.8'

services:
  # ==========================================================================
  # PROMETHEUS - Collecte des metriques
  # ==========================================================================
  prometheus:
    image: prom/prometheus:v2.50.1
    container_name: prometheus
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring

  # ==========================================================================
  # GRAFANA - Visualisation
  # ==========================================================================
  grafana:
    image: grafana/grafana:10.3.3
    container_name: grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_ROOT_URL=${GRAFANA_ROOT_URL:-http://localhost:3000}
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel
    ports:
      - "3001:3000"
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
      - loki
    networks:
      - monitoring

  # ==========================================================================
  # ALERTMANAGER - Gestion des alertes
  # ==========================================================================
  alertmanager:
    image: prom/alertmanager:v0.27.0
    container_name: alertmanager
    restart: unless-stopped
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
      - alertmanager_data:/alertmanager
    networks:
      - monitoring

  # ==========================================================================
  # LOKI - Agregation des logs
  # ==========================================================================
  loki:
    image: grafana/loki:2.9.4
    container_name: loki
    restart: unless-stopped
    command: -config.file=/etc/loki/loki-config.yml
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml:ro
      - loki_data:/loki
    networks:
      - monitoring

  # ==========================================================================
  # PROMTAIL - Collecteur de logs
  # ==========================================================================
  promtail:
    image: grafana/promtail:2.9.4
    container_name: promtail
    restart: unless-stopped
    command: -config.file=/etc/promtail/promtail-config.yml
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml:ro
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    networks:
      - monitoring

  # ==========================================================================
  # NODE EXPORTER - Metriques systeme
  # ==========================================================================
  node-exporter:
    image: prom/node-exporter:v1.7.0
    container_name: node-exporter
    restart: unless-stopped
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring

  # ==========================================================================
  # CADVISOR - Metriques containers
  # ==========================================================================
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.49.1
    container_name: cadvisor
    restart: unless-stopped
    privileged: true
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
  loki_data:

networks:
  monitoring:
    driver: bridge
```

### prometheus/prometheus.yml
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'monitoring-stack'

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

rule_files:
  - /etc/prometheus/alert.rules.yml

scrape_configs:
  # Prometheus lui-meme
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter (metriques systeme)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  # cAdvisor (metriques containers)
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Applications (a adapter)
  - job_name: 'applications'
    static_configs:
      - targets:
          - 'app:3000'
          - 'api:8080'
    metrics_path: /metrics
    scrape_interval: 10s

  # Service discovery Docker (optionnel)
  - job_name: 'docker-containers'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 30s
    relabel_configs:
      - source_labels: [__meta_docker_container_label_prometheus_scrape]
        action: keep
        regex: 'true'
      - source_labels: [__meta_docker_container_name]
        target_label: container_name
```

### prometheus/alert.rules.yml
```yaml
groups:
  - name: targets
    rules:
      - alert: TargetDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Target {{ $labels.instance }} is down"
          description: "{{ $labels.job }} target {{ $labels.instance }} has been down for more than 1 minute."

  - name: host
    rules:
      - alert: HighCpuUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is {{ $value | printf \"%.2f\" }}%"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is {{ $value | printf \"%.2f\" }}%"

      - alert: DiskSpaceLow
        expr: (1 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"})) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk usage is {{ $value | printf \"%.2f\" }}% on {{ $labels.mountpoint }}"

  - name: application
    rules:
      - alert: HighErrorRate
        expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: HighLatency
        expr: histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P99 latency is {{ $value | printf \"%.2f\" }}s"

      - alert: TooManyOpenConnections
        expr: sum(increase(http_requests_total[1m])) > 1000
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "High request rate"
          description: "{{ $value | printf \"%.0f\" }} requests in the last minute"
```

### alertmanager/alertmanager.yml
```yaml
global:
  resolve_timeout: 5m
  # SMTP pour emails
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alertmanager@example.com'
  smtp_auth_username: 'alertmanager@example.com'
  smtp_auth_password: '${SMTP_PASSWORD}'

  # Slack
  slack_api_url: '${SLACK_WEBHOOK_URL}'

route:
  group_by: ['alertname', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default-receiver'

  routes:
    # Alertes critiques -> PagerDuty + Slack
    - match:
        severity: critical
      receiver: 'critical-alerts'
      continue: true

    # Alertes warning -> Slack seulement
    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'default-receiver'
    slack_configs:
      - channel: '#alerts'
        send_resolved: true
        title: '{{ .Status | toUpper }}: {{ .CommonAnnotations.summary }}'
        text: '{{ .CommonAnnotations.description }}'

  - name: 'critical-alerts'
    slack_configs:
      - channel: '#alerts-critical'
        send_resolved: true
        color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
        title: '🚨 {{ .Status | toUpper }}: {{ .CommonAnnotations.summary }}'
        text: '{{ .CommonAnnotations.description }}'
    # PagerDuty (optionnel)
    # pagerduty_configs:
    #   - service_key: '${PAGERDUTY_SERVICE_KEY}'
    #     severity: critical

  - name: 'warning-alerts'
    slack_configs:
      - channel: '#alerts'
        send_resolved: true
        color: '{{ if eq .Status "firing" }}warning{{ else }}good{{ end }}'
        title: '⚠️ {{ .Status | toUpper }}: {{ .CommonAnnotations.summary }}'
        text: '{{ .CommonAnnotations.description }}'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
```

### loki/loki-config.yml
```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://alertmanager:9093

limits_config:
  retention_period: 744h  # 31 jours
```

### promtail/promtail-config.yml
```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  # Logs Docker containers
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'stream'
    pipeline_stages:
      - json:
          expressions:
            level: level
            message: msg
      - labels:
          level:

  # Logs systeme
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
```

### grafana/provisioning/datasources/datasources.yml
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false

  - name: Alertmanager
    type: alertmanager
    access: proxy
    url: http://alertmanager:9093
    editable: false
    jsonData:
      implementation: prometheus
```

---

## Stack Kubernetes (Production)

### Installation avec Helm (kube-prometheus-stack)
```bash
# Ajouter les repos Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Creer le namespace
kubectl create namespace monitoring

# Installer kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword='${GRAFANA_PASSWORD}' \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi

# Installer Loki
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set promtail.enabled=true \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=50Gi
```

### values-production.yaml (kube-prometheus-stack)
```yaml
prometheus:
  prometheusSpec:
    retention: 30d
    retentionSize: "45GB"

    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: fast-ssd
          resources:
            requests:
              storage: 50Gi

    resources:
      requests:
        memory: 2Gi
        cpu: 500m
      limits:
        memory: 4Gi
        cpu: 2000m

    # Scrape plus frequent en prod
    scrapeInterval: 15s
    evaluationInterval: 15s

grafana:
  adminPassword: "${GRAFANA_ADMIN_PASSWORD}"

  persistence:
    enabled: true
    size: 10Gi

  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - grafana.example.com
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.example.com

  # OAuth (optionnel)
  grafana.ini:
    server:
      root_url: https://grafana.example.com
    auth.github:
      enabled: true
      client_id: ${GITHUB_CLIENT_ID}
      client_secret: ${GITHUB_CLIENT_SECRET}
      allowed_organizations: my-org

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: fast-ssd
          resources:
            requests:
              storage: 10Gi

  config:
    global:
      slack_api_url: ${SLACK_WEBHOOK_URL}
    route:
      receiver: 'slack-notifications'
      group_by: ['alertname', 'namespace']
    receivers:
      - name: 'slack-notifications'
        slack_configs:
          - channel: '#alerts'
            send_resolved: true
```

---

## Victoria Metrics (Alternative legere)

Victoria Metrics est une alternative a Prometheus avec :
- Meilleure compression (10x moins de stockage)
- Plus rapide sur les grosses queries
- Compatible PromQL
- Moins de RAM

### docker-compose-victoria.yml
```yaml
version: '3.8'

services:
  victoria-metrics:
    image: victoriametrics/victoria-metrics:v1.96.0
    container_name: victoria-metrics
    restart: unless-stopped
    command:
      - '-storageDataPath=/victoria-metrics-data'
      - '-retentionPeriod=90d'
      - '-httpListenAddr=:8428'
    ports:
      - "8428:8428"
    volumes:
      - victoria_data:/victoria-metrics-data
    networks:
      - monitoring

  vmagent:
    image: victoriametrics/vmagent:v1.96.0
    container_name: vmagent
    restart: unless-stopped
    command:
      - '-promscrape.config=/etc/prometheus/prometheus.yml'
      - '-remoteWrite.url=http://victoria-metrics:8428/api/v1/write'
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    depends_on:
      - victoria-metrics
    networks:
      - monitoring

  vmalert:
    image: victoriametrics/vmalert:v1.96.0
    container_name: vmalert
    restart: unless-stopped
    command:
      - '-datasource.url=http://victoria-metrics:8428'
      - '-remoteRead.url=http://victoria-metrics:8428'
      - '-remoteWrite.url=http://victoria-metrics:8428'
      - '-notifier.url=http://alertmanager:9093'
      - '-rule=/etc/alerts/*.yml'
    volumes:
      - ./prometheus/alert.rules.yml:/etc/alerts/alert.rules.yml:ro
    depends_on:
      - victoria-metrics
      - alertmanager
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:10.3.3
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring

volumes:
  victoria_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

---

## Solutions Managees

### Grafana Cloud (Recommande)
```bash
# 1. Creer un compte sur grafana.com
# 2. Recuperer les credentials

# Configuration Prometheus remote write
# prometheus.yml
remote_write:
  - url: https://prometheus-prod-XX-prod-XX.grafana.net/api/prom/push
    basic_auth:
      username: ${GRAFANA_CLOUD_USER}
      password: ${GRAFANA_CLOUD_API_KEY}

# Configuration Loki (promtail)
clients:
  - url: https://logs-prod-XX.grafana.net/loki/api/v1/push
    basic_auth:
      username: ${GRAFANA_CLOUD_USER}
      password: ${GRAFANA_CLOUD_API_KEY}
```

### Datadog
```bash
# Installation agent Datadog
DD_API_KEY=${DD_API_KEY} DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"

# docker-compose
datadog:
  image: gcr.io/datadoghq/agent:7
  environment:
    - DD_API_KEY=${DD_API_KEY}
    - DD_SITE=datadoghq.eu
    - DD_LOGS_ENABLED=true
    - DD_APM_ENABLED=true
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - /proc/:/host/proc/:ro
    - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
```

---

## Commandes de deploiement

```bash
# === Dev/Staging (Docker Compose) ===
cd monitoring
docker compose up -d

# Verifier
docker compose ps
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3001/api/health  # Grafana
curl http://localhost:3100/ready       # Loki

# === Production (Kubernetes) ===
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -f values-production.yaml \
  --namespace monitoring

# Verifier
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

---

## Checklist Deploiement Production

### Infrastructure
- [ ] Stockage persistant configure
- [ ] Retention definie (30-90 jours)
- [ ] Resources (CPU/RAM) allouees
- [ ] Backup configure

### Securite
- [ ] HTTPS active (Ingress + cert-manager)
- [ ] Authentification configuree (OAuth/LDAP)
- [ ] Network policies en place
- [ ] Secrets dans Kubernetes Secrets ou Vault

### Alerting
- [ ] Alertmanager configure
- [ ] Receivers configures (Slack, PagerDuty, Email)
- [ ] Regles d'alerte definies
- [ ] Runbook documente

### Dashboards
- [ ] Dashboard infra (CPU, RAM, Disk)
- [ ] Dashboard application (requests, errors, latency)
- [ ] Dashboard business (KPIs metier)

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/monitoring` | Instrumenter le code applicatif |
| `/k8s` | Deployer sur Kubernetes |
| `/docker` | Containeriser les services |
| `/ci` | Integrer dans CI/CD |
| `/secrets-management` | Gerer les credentials |

---

IMPORTANT: Toujours tester la stack en staging avant production.

IMPORTANT: Configurer des alertes AVANT de deployer en production.

YOU MUST avoir du stockage persistant pour les donnees de metriques.

NEVER exposer Prometheus/Alertmanager sans authentification en production.
