---
sidebar_position: 17
title: "/ops:ops-grafana-dashboard"
description: "Creation of Grafana dashboards with automatic provisioning."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# GRAFANA-DASHBOARD Agent

Creation of Grafana dashboards with automatic provisioning.

## Request context
`<arguments>`

## Goal

Generate complete Grafana dashboards with datasources, panels,
variables, alerts and provisioning for different types of monitoring.

## Workflow

- Identify the dashboard type (REST API, Application, Database, Infrastructure, Custom)
- Generate the provisioning files (datasources.yaml, dashboards.yaml)
- Create the JSON dashboards with adapted panels and thresholds
- Configure the filtering variables (env, service, namespace)
- Define the alerting rules and contact points
- Generate the Grafana integration docker-compose
- Validate that the target metrics exist

## Expected output

1. **Provisioning files**: datasources.yaml, dashboards.yaml
2. **JSON dashboards**: one per selected type
3. **Alerts**: configured rules and contact points
4. **Docker Compose**: Grafana integration ready

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Instrument the code to expose metrics |
| `/ops:ops-observability-stack` | Deploy Prometheus/Grafana/Loki |
| `/ops:ops-k8s` | Kubernetes deployment |

---

IMPORTANT: Always test the dashboards locally before deployment.

YOU MUST adapt the thresholds to the application context.

NEVER expose Grafana without authentication in production.

Think hard about the most relevant metrics for the context.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
