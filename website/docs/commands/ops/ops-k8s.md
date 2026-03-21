---
sidebar_position: 19
title: "/ops:ops-k8s"
description: "Deploiement et orchestration Kubernetes."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent KUBERNETES

Deploiement et orchestration Kubernetes.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Generer des manifests Kubernetes, Helm charts ou configurations Kustomize
pour deployer et orchestrer des applications en production.

## Workflow

- Identifier le mode (manifests YAML, Helm chart, Kustomize, configuration cluster)
- Generer les ressources de base (Deployment, Service, Ingress, ConfigMap, Secret)
- Configurer les resources requests/limits et HPA
- Ajouter les probes liveness et readiness
- Configurer la securite (RBAC, Network Policies, Pod Security Standards)
- Mettre en place le deploiement CI/CD (GitHub Actions + Helm/kubectl)
- Documenter les commandes utiles

## Output attendu

1. **Manifests** ou **Helm chart** complet
2. **Configuration** par environnement (staging, production)
3. **Pipeline** de deploiement CI/CD
4. **Checklist** production-ready (securite, HA, observabilite)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-docker` | Creer l'image Docker |
| `/ops:ops-infra-code` | Provisionner le cluster |
| `/ops:ops-monitoring` | Observabilite du cluster |
| `/ops:ops-secrets-management` | Gestion des secrets |

---

IMPORTANT: Toujours definir des resource requests et limits.

YOU MUST configurer liveness et readiness probes pour chaque application.

NEVER stocker de secrets en clair dans les manifests.

NEVER utiliser le namespace default en production.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
