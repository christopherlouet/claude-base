---
sidebar_position: 3
title: "/dev:dev-api"
description: "Create or document REST/GraphQL endpoints."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# API Agent

Create or document REST/GraphQL endpoints.

## Endpoint or API to process
`&lt;arguments&gt;`

## Goal

Develop well-structured, documented, and testable APIs following the TDD approach.

Use the `dev-api` skill for the detailed methodology (RESTful structure, validation, OpenAPI documentation, tests).

## TDD prerequisites

**Mandatory creation order:**
1. Define the API contract (OpenAPI spec/types)
2. Write the integration tests (RED)
3. Implement the handler (GREEN)
4. Refactor if necessary (REFACTOR)
5. Document (Swagger/OpenAPI)

## Expected output

### Endpoint specification
- Method and path
- Description
- Parameters and body
- Possible responses (success and errors)

### Implementation code
- Route with validation
- Handler
- Integration tests

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/doc:doc-api-spec` | Generate OpenAPI/Swagger spec |
| `/dev:dev-test` | Test the endpoints |
| `/qa:qa-security` | API security audit |
| `/qa:qa-review` | API code review |

---

IMPORTANT: An API is a contract. Document before implementing.

IMPORTANT: Version the API (/v1/, /v2/) to avoid breaking changes.

YOU MUST validate all user inputs.

NEVER expose sensitive data in API responses.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
