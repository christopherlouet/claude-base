---
sidebar_position: 4
title: "/dev:dev-api-versioning"
description: "Set up a robust API versioning strategy."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-API-VERSIONING

Set up a robust API versioning strategy.

## Request context
`&lt;arguments&gt;`

## Goal

Define and implement an API versioning strategy that allows evolution
while maintaining compatibility with existing clients.
URL Path versioning recommended for most cases.

## Workflow

- Choose the strategy (URL Path, Query Param, Header, Content Negotiation)
- Structure the code: versioned API layer, non-versioned Service layer
- Identify the types of changes (additive = safe, breaking = new version)
- Implement routing by version
- Define the deprecation timeline (Active &gt; Deprecated &gt; Sunset &gt; Off)
- Add deprecation headers (Deprecation, Sunset, Link successor-version)
- Document breaking changes and the migration guide
- Configure monitoring by version (requests, clients, errors, latency)

## Expected output

Versioning architecture, migration guide, OpenAPI documentation by version,
deprecation timeline and configured monitoring.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | Create endpoints |
| `/doc:doc-api-spec` | Document the API |
| `/doc:doc-changelog` | Version changelog |

---

IMPORTANT: Never remove a version without a deprecation period.

YOU MUST document all breaking changes.

YOU MUST provide a migration guide for each new major version.

NEVER make breaking changes in a minor version.

Think hard about the impact of changes before creating a new version.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
