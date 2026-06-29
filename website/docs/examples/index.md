---
sidebar_position: 1
title: Code Examples
description: Practical examples for every domain with claude-base
---

# Code Examples

Practical, ready-to-use examples to get started quickly with claude-base.

## Web (React/Next.js)

| Example | Command | Description |
|---------|---------|-------------|
| [React Component](/docs/examples/web/react-component) | `/dev:dev-component` | Complete component with tests and stories |
| [Custom Hook](/docs/examples/web/react-hook) | `/dev:dev-component` | Custom hook with state management |
| [Next.js API](/docs/examples/web/nextjs-api) | `/dev:dev-api` | API route with validation |

## Mobile (Flutter)

| Example | Command | Description |
|---------|---------|-------------|
| [Flutter Screen](/docs/examples/mobile/flutter-screen) | `/dev:dev-flutter` | Screen with Clean Architecture |
| [BLoC Pattern](/docs/examples/mobile/flutter-bloc) | `/dev:dev-flutter` | State management with BLoC |

## API (REST/GraphQL/tRPC)

| Example | Command | Description |
|---------|---------|-------------|
| [REST Endpoint](/docs/examples/api/rest-endpoint) | `/dev:dev-api` | Complete CRUD endpoint |
| [GraphQL Resolver](/docs/examples/api/graphql-resolver) | `/dev:dev-api` | Query and Mutation |
| [tRPC Procedure](/docs/examples/api/trpc-procedure) | `/dev:dev-api` | Type-safe procedure |

## Ops (Docker/CI/Terraform/Proxmox/OPNsense)

| Example | Command | Description |
|---------|---------|-------------|
| [Docker Setup](/docs/examples/ops/docker-setup) | `/ops:ops-docker` | Multi-stage Dockerfile |
| [CI Pipeline](/docs/examples/ops/ci-pipeline) | `/ops:ops-ci` | GitHub Actions workflow |
| [Terraform Module](/docs/examples/ops/terraform-module) | `/ops:ops-infra-code` | Reusable module |
| [Proxmox VM](/docs/examples/ops/proxmox-vm) | `/ops:ops-proxmox` | VM with cloud-init |
| [OPNsense Firewall](/docs/examples/ops/opnsense-config) | `/ops:ops-opnsense` | OPNsense behind Orange box |

---

## How to use these examples

1. **Copy** the code into your project
2. **Adapt** the names and business logic
3. **Generate the tests** with `/dev:dev-tdd`
4. **Commit** with `/work:work-commit`

:::tip Generate similar code
Use the command associated with each example to generate code tailored to your context:
```bash
/dev:dev-component "Create a UserProfile component with avatar and bio"
```
:::
