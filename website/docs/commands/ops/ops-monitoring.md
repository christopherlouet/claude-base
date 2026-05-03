---
sidebar_position: 25
title: "/ops:ops-monitoring"
description: "Code instrumentation for monitoring, logging and alerting."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# MONITORING Agent

Code instrumentation for monitoring, logging and alerting.

## Request context
`<arguments>`

## Objective

Set up the 3 pillars of observability (logs, metrics, traces)
with error tracking, health checks and alerting rules.

## Workflow

- Analyze the technical stack and existing tools
- Configure error tracking (Sentry)
- Implement structured logging (Pino, structlog, zap)
- Expose Prometheus metrics (/metrics)
- Configure OpenTelemetry for distributed tracing (optional)
- Add health checks (/health/live, /health/ready)
- Define alerting rules (error rate, latency, CPU, memory)
- Mask sensitive data in logs (GDPR)

## Expected output

1. **Error tracking** configured (Sentry or equivalent)
2. **Logger** structured with sensitive data redaction
3. **Prometheus metrics** exposed
4. **Health checks** liveness and readiness
5. **Recommended alert rules**

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-observability-stack` | Deploy Prometheus/Grafana/Loki |
| `/ops:ops-health` | Quick health check |
| `/qa:qa-perf` | Performance analysis |

---

IMPORTANT: Do not log personal data (GDPR) - use redaction.

YOU MUST have health checks for Kubernetes/load balancers.

NEVER ignore alerts - every alert must be actionable.

To deploy the monitoring stack, use /ops:ops-observability-stack.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
