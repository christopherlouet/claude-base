---
sidebar_position: 21
title: "/ops:ops-k8s"
description: "Kubernetes deployment and orchestration."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# KUBERNETES Agent

Kubernetes deployment and orchestration.

## Request context
`<arguments>`

## Objective

Generate Kubernetes manifests, Helm charts or Kustomize configurations
to deploy and orchestrate applications in production.

## Workflow

- Identify the mode (YAML manifests, Helm chart, Kustomize, cluster configuration)
- Generate the base resources (Deployment, Service, Ingress, ConfigMap, Secret)
- Configure resource requests/limits and HPA
- Add liveness and readiness probes
- Configure security (RBAC, Network Policies, Pod Security Standards)
- Set up CI/CD deployment (GitHub Actions + Helm/kubectl)
- Document useful commands

## Expected output

1. Complete **manifests** or **Helm chart**
2. Per-environment **configuration** (staging, production)
3. CI/CD deployment **pipeline**
4. Production-ready **checklist** (security, HA, observability)

## Related agents

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Build the Docker image |
| `/ops:ops-infra-code` | Provision the cluster |
| `/ops:ops-monitoring` | Cluster observability |
| `/ops:ops-secrets-management` | Secrets management |

---

IMPORTANT: Always define resource requests and limits.

YOU MUST configure liveness and readiness probes for every application.

NEVER store plaintext secrets in manifests.

NEVER use the default namespace in production.


---

## See also

- [Back to OPS commands](/docs/commands/ops)
- [All commands](/docs/commands)
