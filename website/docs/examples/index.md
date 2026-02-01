---
sidebar_position: 1
title: Exemples de Code
description: Exemples pratiques pour chaque domaine avec claude-socle
---

# Exemples de Code

Exemples pratiques et prêts à l'emploi pour démarrer rapidement avec claude-socle.

## Web (React/Next.js)

| Exemple | Commande | Description |
|---------|----------|-------------|
| [Composant React](/docs/examples/web/react-component) | `/dev:dev-component` | Composant complet avec tests et stories |
| [Hook personnalisé](/docs/examples/web/react-hook) | `/dev:dev-hook` | Custom hook avec gestion d'état |
| [API Next.js](/docs/examples/web/nextjs-api) | `/dev:dev-api` | Route API avec validation |

## Mobile (Flutter)

| Exemple | Commande | Description |
|---------|----------|-------------|
| [Screen Flutter](/docs/examples/mobile/flutter-screen) | `/dev:dev-flutter` | Screen avec Clean Architecture |
| [BLoC Pattern](/docs/examples/mobile/flutter-bloc) | `/dev:dev-flutter` | State management avec BLoC |

## API (REST/GraphQL/tRPC)

| Exemple | Commande | Description |
|---------|----------|-------------|
| [Endpoint REST](/docs/examples/api/rest-endpoint) | `/dev:dev-api` | Endpoint CRUD complet |
| [Resolver GraphQL](/docs/examples/api/graphql-resolver) | `/dev:dev-graphql` | Query et Mutation |
| [Procedure tRPC](/docs/examples/api/trpc-procedure) | `/dev:dev-trpc` | Procedure type-safe |

## Ops (Docker/CI/Terraform/Proxmox/OPNsense)

| Exemple | Commande | Description |
|---------|----------|-------------|
| [Setup Docker](/docs/examples/ops/docker-setup) | `/ops:ops-docker` | Dockerfile multi-stage |
| [Pipeline CI](/docs/examples/ops/ci-pipeline) | `/ops:ops-ci` | GitHub Actions workflow |
| [Module Terraform](/docs/examples/ops/terraform-module) | `/ops:ops-infra-code` | Module réutilisable |
| [VM Proxmox](/docs/examples/ops/proxmox-vm) | `/ops:ops-proxmox` | VM avec cloud-init |
| [Firewall OPNsense](/docs/examples/ops/opnsense-config) | `/ops:ops-opnsense` | OPNsense derrière box Orange |

---

## Comment utiliser ces exemples

1. **Copier** le code dans votre projet
2. **Adapter** les noms et la logique métier
3. **Générer les tests** avec `/dev:dev-test`
4. **Commiter** avec `/work:work-commit`

:::tip Générer du code similaire
Utilisez la commande associée à chaque exemple pour générer du code adapté à votre contexte :
```bash
/dev:dev-component "Créer un composant UserProfile avec avatar et bio"
```
:::
