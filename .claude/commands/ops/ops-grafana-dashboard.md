# Agent GRAFANA-DASHBOARD

Creation de dashboards Grafana avec provisioning automatique.

## Cible
$ARGUMENTS

## Modes d'utilisation

### Mode 1 : Dashboard API REST
Metriques RED (Rate, Errors, Duration) pour endpoints HTTP.

### Mode 2 : Dashboard Application
Metriques applicatives (CPU, memoire, GC, connexions).

### Mode 3 : Dashboard Base de donnees
Metriques PostgreSQL, MySQL, Redis, MongoDB.

### Mode 4 : Dashboard Infrastructure
Metriques systeme (nodes, pods, containers).

### Mode 5 : Dashboard Custom
Dashboard personnalise selon les besoins.

---

## Structure de Provisioning

```
/grafana
├── /provisioning
│   ├── /dashboards
│   │   └── dashboards.yaml      # Configuration provisioning
│   └── /datasources
│       └── datasources.yaml     # Sources de donnees
└── /dashboards
    ├── api-overview.json        # Dashboard API
    ├── application.json         # Dashboard App
    ├── database.json            # Dashboard DB
    └── infrastructure.json      # Dashboard Infra
```

---

## Configuration Provisioning

### datasources.yaml
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

  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo:3200
    editable: false
    jsonData:
      tracesToLogsV2:
        datasourceUid: loki
        filterByTraceID: true
      serviceMap:
        datasourceUid: prometheus
      lokiSearch:
        datasourceUid: loki
```

### dashboards.yaml
```yaml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: 'Application'
    folderUid: 'app'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

---

## Dashboard API REST (RED Metrics)

### api-overview.json
```json
{
  "annotations": {
    "list": [
      {
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "enable": true,
        "expr": "ALERTS{alertstate=\"firing\"}",
        "iconColor": "red",
        "name": "Alerts",
        "titleFormat": "{{ alertname }}"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 1,
  "links": [],
  "panels": [
    {
      "title": "Request Rate",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 0, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{service=\"$service\", env=\"$env\"}[5m])) by (method, path)",
          "legendFormat": "{{ method }} {{ path }}"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "reqps",
          "custom": {
            "drawStyle": "line",
            "lineInterpolation": "smooth",
            "fillOpacity": 10
          }
        }
      }
    },
    {
      "title": "Error Rate",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 8, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{service=\"$service\", env=\"$env\", status=~\"5..\"}[5m])) / sum(rate(http_requests_total{service=\"$service\", env=\"$env\"}[5m])) * 100",
          "legendFormat": "Error %"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 1 },
              { "color": "red", "value": 5 }
            ]
          }
        }
      }
    },
    {
      "title": "Response Time (p95)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service=\"$service\", env=\"$env\"}[5m])) by (le, path))",
          "legendFormat": "p95 {{ path }}"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 0.5 },
              { "color": "red", "value": 1 }
            ]
          }
        }
      }
    },
    {
      "title": "Requests by Status Code",
      "type": "piechart",
      "gridPos": { "h": 8, "w": 6, "x": 0, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(increase(http_requests_total{service=\"$service\", env=\"$env\"}[$__range])) by (status)",
          "legendFormat": "{{ status }}"
        }
      ]
    },
    {
      "title": "Top Endpoints by Latency",
      "type": "table",
      "gridPos": { "h": 8, "w": 9, "x": 6, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "topk(10, histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{service=\"$service\", env=\"$env\"}[5m])) by (le, method, path)))",
          "format": "table",
          "instant": true
        }
      ],
      "transformations": [
        { "id": "organize", "options": { "excludeByName": { "Time": true } } }
      ]
    },
    {
      "title": "Active Connections",
      "type": "stat",
      "gridPos": { "h": 4, "w": 3, "x": 15, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(http_active_connections{service=\"$service\", env=\"$env\"})",
          "legendFormat": "Connections"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "short" }
      }
    },
    {
      "title": "Requests/min",
      "type": "stat",
      "gridPos": { "h": 4, "w": 3, "x": 18, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{service=\"$service\", env=\"$env\"}[1m])) * 60",
          "legendFormat": "RPM"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "short" }
      }
    },
    {
      "title": "Avg Response Time",
      "type": "stat",
      "gridPos": { "h": 4, "w": 3, "x": 21, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "sum(rate(http_request_duration_seconds_sum{service=\"$service\", env=\"$env\"}[5m])) / sum(rate(http_request_duration_seconds_count{service=\"$service\", env=\"$env\"}[5m]))",
          "legendFormat": "Avg"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "s" }
      }
    }
  ],
  "schemaVersion": 39,
  "tags": ["api", "red-metrics"],
  "templating": {
    "list": [
      {
        "name": "env",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(http_requests_total, env)",
        "refresh": 2,
        "current": { "text": "production", "value": "production" }
      },
      {
        "name": "service",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(http_requests_total{env=\"$env\"}, service)",
        "refresh": 2
      }
    ]
  },
  "time": { "from": "now-1h", "to": "now" },
  "title": "API Overview",
  "uid": "api-overview"
}
```

---

## Dashboard Application

### application.json
```json
{
  "panels": [
    {
      "title": "CPU Usage",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "rate(process_cpu_seconds_total{service=\"$service\", env=\"$env\"}[5m]) * 100",
          "legendFormat": "CPU %"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "max": 100,
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 70 },
              { "color": "red", "value": 90 }
            ]
          }
        }
      }
    },
    {
      "title": "Memory Usage",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "process_resident_memory_bytes{service=\"$service\", env=\"$env\"}",
          "legendFormat": "RSS"
        },
        {
          "expr": "process_virtual_memory_bytes{service=\"$service\", env=\"$env\"}",
          "legendFormat": "Virtual"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "bytes" }
      }
    },
    {
      "title": "Node.js Event Loop Lag",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 0, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "nodejs_eventloop_lag_seconds{service=\"$service\", env=\"$env\"}",
          "legendFormat": "Event Loop Lag"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 0.1 },
              { "color": "red", "value": 0.5 }
            ]
          }
        }
      }
    },
    {
      "title": "Go Goroutines",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 8, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "go_goroutines{service=\"$service\", env=\"$env\"}",
          "legendFormat": "Goroutines"
        }
      ]
    },
    {
      "title": "GC Duration",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 8 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "rate(go_gc_duration_seconds_sum{service=\"$service\", env=\"$env\"}[5m])",
          "legendFormat": "GC Time"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "s" }
      }
    },
    {
      "title": "Open File Descriptors",
      "type": "gauge",
      "gridPos": { "h": 6, "w": 6, "x": 0, "y": 16 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "process_open_fds{service=\"$service\", env=\"$env\"} / process_max_fds{service=\"$service\", env=\"$env\"} * 100"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "max": 100,
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 70 },
              { "color": "red", "value": 90 }
            ]
          }
        }
      }
    },
    {
      "title": "Uptime",
      "type": "stat",
      "gridPos": { "h": 6, "w": 6, "x": 6, "y": 16 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "time() - process_start_time_seconds{service=\"$service\", env=\"$env\"}"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "s" }
      }
    }
  ],
  "schemaVersion": 39,
  "tags": ["application", "runtime"],
  "templating": {
    "list": [
      {
        "name": "env",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(process_cpu_seconds_total, env)",
        "refresh": 2
      },
      {
        "name": "service",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(process_cpu_seconds_total{env=\"$env\"}, service)",
        "refresh": 2
      }
    ]
  },
  "title": "Application Metrics",
  "uid": "app-metrics"
}
```

---

## Dashboard Base de Donnees

### PostgreSQL
```json
{
  "panels": [
    {
      "title": "Active Connections",
      "type": "gauge",
      "gridPos": { "h": 6, "w": 6, "x": 0, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "pg_stat_activity_count{datname=\"$database\", state=\"active\"}"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "max": 100,
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 50 },
              { "color": "red", "value": 80 }
            ]
          }
        }
      }
    },
    {
      "title": "Transactions/sec",
      "type": "stat",
      "gridPos": { "h": 6, "w": 6, "x": 6, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "rate(pg_stat_database_xact_commit{datname=\"$database\"}[5m]) + rate(pg_stat_database_xact_rollback{datname=\"$database\"}[5m])"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "ops" }
      }
    },
    {
      "title": "Cache Hit Ratio",
      "type": "gauge",
      "gridPos": { "h": 6, "w": 6, "x": 12, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "pg_stat_database_blks_hit{datname=\"$database\"} / (pg_stat_database_blks_hit{datname=\"$database\"} + pg_stat_database_blks_read{datname=\"$database\"}) * 100"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "max": 100,
          "thresholds": {
            "steps": [
              { "color": "red", "value": null },
              { "color": "yellow", "value": 90 },
              { "color": "green", "value": 99 }
            ]
          }
        }
      }
    },
    {
      "title": "Database Size",
      "type": "stat",
      "gridPos": { "h": 6, "w": 6, "x": 18, "y": 0 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "pg_database_size_bytes{datname=\"$database\"}"
        }
      ],
      "fieldConfig": {
        "defaults": { "unit": "bytes" }
      }
    },
    {
      "title": "Slow Queries (>1s)",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 6 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "rate(pg_stat_statements_seconds_total{datname=\"$database\"}[5m])",
          "legendFormat": "{{ query }}"
        }
      ]
    },
    {
      "title": "Locks",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 6 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "pg_locks_count{datname=\"$database\"}",
          "legendFormat": "{{ mode }}"
        }
      ]
    },
    {
      "title": "Replication Lag",
      "type": "stat",
      "gridPos": { "h": 6, "w": 8, "x": 0, "y": 14 },
      "datasource": { "type": "prometheus", "uid": "prometheus" },
      "targets": [
        {
          "expr": "pg_replication_lag{}"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 10 },
              { "color": "red", "value": 60 }
            ]
          }
        }
      }
    }
  ],
  "schemaVersion": 39,
  "tags": ["database", "postgresql"],
  "templating": {
    "list": [
      {
        "name": "database",
        "type": "query",
        "datasource": { "type": "prometheus", "uid": "prometheus" },
        "query": "label_values(pg_database_size_bytes, datname)",
        "refresh": 2
      }
    ]
  },
  "title": "PostgreSQL Overview",
  "uid": "postgresql-overview"
}
```

### Redis
```json
{
  "panels": [
    {
      "title": "Connected Clients",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 0 },
      "targets": [{ "expr": "redis_connected_clients{}" }]
    },
    {
      "title": "Memory Used",
      "type": "gauge",
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 0 },
      "targets": [{ "expr": "redis_memory_used_bytes{} / redis_memory_max_bytes{} * 100" }],
      "fieldConfig": { "defaults": { "unit": "percent", "max": 100 } }
    },
    {
      "title": "Hit Rate",
      "type": "gauge",
      "gridPos": { "h": 4, "w": 4, "x": 8, "y": 0 },
      "targets": [{ "expr": "redis_keyspace_hits_total{} / (redis_keyspace_hits_total{} + redis_keyspace_misses_total{}) * 100" }],
      "fieldConfig": { "defaults": { "unit": "percent", "max": 100 } }
    },
    {
      "title": "Commands/sec",
      "type": "stat",
      "gridPos": { "h": 4, "w": 4, "x": 12, "y": 0 },
      "targets": [{ "expr": "rate(redis_commands_processed_total{}[5m])" }],
      "fieldConfig": { "defaults": { "unit": "ops" } }
    },
    {
      "title": "Operations",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 4 },
      "targets": [
        { "expr": "rate(redis_commands_total{}[5m])", "legendFormat": "{{ cmd }}" }
      ]
    },
    {
      "title": "Keys by DB",
      "type": "bargauge",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 4 },
      "targets": [{ "expr": "redis_db_keys{}", "legendFormat": "{{ db }}" }]
    }
  ],
  "tags": ["database", "redis"],
  "title": "Redis Overview",
  "uid": "redis-overview"
}
```

---

## Dashboard Kubernetes

### k8s-workloads.json
```json
{
  "panels": [
    {
      "title": "Pod Status",
      "type": "stat",
      "gridPos": { "h": 4, "w": 6, "x": 0, "y": 0 },
      "targets": [
        {
          "expr": "sum(kube_pod_status_phase{namespace=\"$namespace\", phase=\"Running\"})",
          "legendFormat": "Running"
        }
      ],
      "fieldConfig": { "defaults": { "color": { "mode": "fixed", "fixedColor": "green" } } }
    },
    {
      "title": "Pod Restarts (24h)",
      "type": "stat",
      "gridPos": { "h": 4, "w": 6, "x": 6, "y": 0 },
      "targets": [
        {
          "expr": "sum(increase(kube_pod_container_status_restarts_total{namespace=\"$namespace\"}[24h]))"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "thresholds": {
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 5 },
              { "color": "red", "value": 20 }
            ]
          }
        }
      }
    },
    {
      "title": "CPU Usage by Pod",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 4 },
      "targets": [
        {
          "expr": "sum(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\", pod=~\"$pod\"}[5m])) by (pod)",
          "legendFormat": "{{ pod }}"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "short" } }
    },
    {
      "title": "Memory Usage by Pod",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 4 },
      "targets": [
        {
          "expr": "sum(container_memory_usage_bytes{namespace=\"$namespace\", pod=~\"$pod\"}) by (pod)",
          "legendFormat": "{{ pod }}"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "bytes" } }
    },
    {
      "title": "Network I/O",
      "type": "timeseries",
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 12 },
      "targets": [
        {
          "expr": "sum(rate(container_network_receive_bytes_total{namespace=\"$namespace\"}[5m])) by (pod)",
          "legendFormat": "RX {{ pod }}"
        },
        {
          "expr": "sum(rate(container_network_transmit_bytes_total{namespace=\"$namespace\"}[5m])) by (pod)",
          "legendFormat": "TX {{ pod }}"
        }
      ],
      "fieldConfig": { "defaults": { "unit": "Bps" } }
    },
    {
      "title": "HPA Status",
      "type": "table",
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 12 },
      "targets": [
        {
          "expr": "kube_horizontalpodautoscaler_status_current_replicas{namespace=\"$namespace\"}",
          "format": "table",
          "instant": true
        }
      ]
    }
  ],
  "schemaVersion": 39,
  "tags": ["kubernetes", "workloads"],
  "templating": {
    "list": [
      {
        "name": "namespace",
        "type": "query",
        "query": "label_values(kube_pod_info, namespace)",
        "refresh": 2
      },
      {
        "name": "pod",
        "type": "query",
        "query": "label_values(kube_pod_info{namespace=\"$namespace\"}, pod)",
        "refresh": 2,
        "multi": true,
        "includeAll": true
      }
    ]
  },
  "title": "Kubernetes Workloads",
  "uid": "k8s-workloads"
}
```

---

## Alerting Rules

### alerts.yaml (Grafana Alerting)
```yaml
apiVersion: 1

groups:
  - name: API Alerts
    folder: Alerts
    interval: 1m
    rules:
      - title: High Error Rate
        condition: C
        data:
          - refId: A
            datasourceUid: prometheus
            model:
              expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100
          - refId: C
            datasourceUid: __expr__
            model:
              type: threshold
              expression: A
              conditions:
                - evaluator:
                    type: gt
                    params: [5]
        for: 5m
        annotations:
          summary: "Error rate above 5%"
          description: "Current error rate: {{ $values.A }}%"
        labels:
          severity: critical

      - title: High Latency
        condition: C
        data:
          - refId: A
            datasourceUid: prometheus
            model:
              expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
          - refId: C
            datasourceUid: __expr__
            model:
              type: threshold
              expression: A
              conditions:
                - evaluator:
                    type: gt
                    params: [1]
        for: 5m
        annotations:
          summary: "P95 latency above 1s"
        labels:
          severity: warning

      - title: Service Down
        condition: C
        data:
          - refId: A
            datasourceUid: prometheus
            model:
              expr: up{job="app"} == 0
          - refId: C
            datasourceUid: __expr__
            model:
              type: threshold
              expression: A
              conditions:
                - evaluator:
                    type: gt
                    params: [0]
        for: 1m
        annotations:
          summary: "Service is down"
        labels:
          severity: critical

  - name: Database Alerts
    folder: Alerts
    interval: 1m
    rules:
      - title: Low Cache Hit Ratio
        condition: C
        data:
          - refId: A
            datasourceUid: prometheus
            model:
              expr: pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read) * 100
          - refId: C
            datasourceUid: __expr__
            model:
              type: threshold
              expression: A
              conditions:
                - evaluator:
                    type: lt
                    params: [90]
        for: 10m
        labels:
          severity: warning

      - title: High Connection Count
        condition: C
        data:
          - refId: A
            datasourceUid: prometheus
            model:
              expr: pg_stat_activity_count / pg_settings_max_connections * 100
          - refId: C
            datasourceUid: __expr__
            model:
              type: threshold
              expression: A
              conditions:
                - evaluator:
                    type: gt
                    params: [80]
        for: 5m
        labels:
          severity: warning
```

---

## Contact Points (Notifications)

### contact-points.yaml
```yaml
apiVersion: 1

contactPoints:
  - name: slack-alerts
    receivers:
      - uid: slack-critical
        type: slack
        settings:
          url: "${SLACK_WEBHOOK_URL}"
          recipient: "#alerts-critical"
          title: |
            {{ `{{ .Status | toUpper }}` }} - {{ `{{ .CommonLabels.alertname }}` }}
          text: |
            {{ `{{ range .Alerts }}` }}
            *Summary:* {{ `{{ .Annotations.summary }}` }}
            *Description:* {{ `{{ .Annotations.description }}` }}
            *Severity:* {{ `{{ .Labels.severity }}` }}
            {{ `{{ end }}` }}

  - name: pagerduty
    receivers:
      - uid: pagerduty-critical
        type: pagerduty
        settings:
          integrationKey: "${PAGERDUTY_KEY}"
          severity: critical
          class: "{{ `{{ .CommonLabels.alertname }}` }}"

  - name: email
    receivers:
      - uid: email-team
        type: email
        settings:
          addresses: "team@example.com"
          singleEmail: true
```

---

## Scripts de Generation

### generate-dashboard.sh
```bash
#!/bin/bash
# Usage: ./generate-dashboard.sh <type> <service-name>

TYPE=$1
SERVICE=$2

case $TYPE in
  api)
    TEMPLATE="api-overview.json"
    ;;
  app)
    TEMPLATE="application.json"
    ;;
  db)
    TEMPLATE="database.json"
    ;;
  k8s)
    TEMPLATE="k8s-workloads.json"
    ;;
  *)
    echo "Usage: $0 <api|app|db|k8s> <service-name>"
    exit 1
    ;;
esac

# Generer le dashboard personnalise
sed "s/\$service/$SERVICE/g" templates/$TEMPLATE > dashboards/${SERVICE}-${TYPE}.json

echo "Dashboard generated: dashboards/${SERVICE}-${TYPE}.json"
```

---

## Docker Compose Integration

### docker-compose.grafana.yaml
```yaml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:11-alpine
    volumes:
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
      - GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/var/lib/grafana/dashboards/api-overview.json
    ports:
      - "3000:3000"

volumes:
  grafana_data:
```

---

## Checklist Dashboard

### Avant deploiement
- [ ] Variables definies (env, service, namespace)
- [ ] Datasources configurees
- [ ] Thresholds adaptes au contexte
- [ ] Alertes configurees
- [ ] Contact points testes

### Bonnes pratiques
- [ ] Utiliser des variables pour filtrer
- [ ] Grouper les panels par theme
- [ ] Limiter a 10-15 panels par dashboard
- [ ] Utiliser des couleurs coherentes
- [ ] Documenter les metriques utilisees

---

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops-monitoring` | Instrumenter le code pour exposer les metriques |
| `/ops-observability-stack` | Deployer Prometheus/Grafana/Loki |
| `/ops-k8s` | Deploiement Kubernetes |
| `/qa-perf` | Identifier les metriques a surveiller |

---

IMPORTANT: Toujours tester les dashboards en local avant deploiement.

IMPORTANT: Utiliser le provisioning pour versionner les dashboards (GitOps).

YOU MUST adapter les thresholds au contexte de l'application.

NEVER exposer Grafana sans authentification en production.
