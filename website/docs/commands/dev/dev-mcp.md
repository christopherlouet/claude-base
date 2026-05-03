---
sidebar_position: 13
title: "/dev:dev-mcp"
description: "Guide for creating quality MCP (Model Context Protocol) servers."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-MCP

Guide for creating quality MCP (Model Context Protocol) servers.

## Request context
`<arguments>`

## Objective

Create MCP servers that let LLMs interact with external services via well-designed
tools. Supports Python (FastMCP) and TypeScript (MCP SDK).

## Workflow

- **Research**: Study the target API (auth, rate limiting, pagination, schemas, errors)
- **Planning**: Define tools by priority, design for workflows (not endpoints)
- **Implementation**: Project setup (FastMCP or MCP SDK), input validation (Pydantic/Zod), actionable errors
- **Review**: Check structure (no duplicated code), types and validation, per-tool documentation
- **Test**: Check syntax, build, test with timeout
- **Evaluation**: Create 10 test questions (independent, read-only, complex, verifiable)

## Design principles

- Workflows, not endpoints (consolidate operations)
- Return high-signal info, not exhaustive dumps
- Natural names (human task, not API name)
- Actionable errors that guide toward the fix

## Expected output

MCP server with configuration (transport, language, target API), tools implemented
with annotations, installation instructions and evaluation results.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | If creating a REST API in parallel |
| `/dev:dev-test` | MCP server tests |
| `/doc:doc-api-spec` | OpenAPI documentation of the target API |

---

IMPORTANT: Design for workflows, not for wrapping endpoints.

YOU MUST validate all inputs with Pydantic (Python) or Zod (TypeScript).

YOU MUST return actionable errors that guide the user.

NEVER expose internal technical details in error messages.

Think hard about real use cases before defining the tools.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
