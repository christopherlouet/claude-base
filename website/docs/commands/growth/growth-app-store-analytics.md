---
sidebar_position: 4
title: "/growth:growth-app-store-analytics"
description: "Monitoring of App Store and Google Play metrics via official APIs."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# APP-STORE-ANALYTICS Agent

Monitoring of App Store and Google Play metrics via official APIs.

## Target
`&lt;arguments&gt;`

## Goal

Set up a pipeline to collect store metrics (downloads, revenue, ratings, retention, crashes) with Prometheus export and Grafana dashboards.

## Workflow

- Configure credentials (App Store Connect API + Google Play Developer API)
- Deploy the Prometheus exporter (Python) with Apple and Google collectors
- Configure the metrics (downloads, users, revenue, ratings, conversion, crashes)
- Create the Grafana dashboards (overview, trends, geo, ratings)
- Configure the alerts (downloads drop, bad reviews, crash rate)
- Set up the automatic weekly report

## Expected output

### Configuration
- Credentials configured (Apple + Google)
- Exporter deployed and operational

### Dashboards
- Overview (downloads, rating, subscribers, revenue, conversion, crashes)
- 30-day trends, geo, retention curve

### Alerts
- Downloads drop &gt; 50%, bad review spike, rating &lt; 4.0, crash rate &gt; 1%

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/ops:ops-mobile-release` | Publish to the stores |
| `/growth:growth-analytics` | In-app analytics |
| `/ops:ops-grafana-dashboard` | Custom dashboards |
| `/growth:growth-retention` | Retention strategies |

---

IMPORTANT: Data is available with a 24-48h delay.

YOU MUST secure the credentials (never commit them).

NEVER exceed the API rate limits (Apple: 1000 req/h, Google: 200 req/s).

Think hard about the metrics that really matter for the app's growth.


---

## See also

- [Back to GROWTH commands](/docs/commands/growth)
- [All commands](/docs/commands)
