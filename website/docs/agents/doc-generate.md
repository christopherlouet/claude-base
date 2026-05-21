---
sidebar_position: 22
title: "doc-generate"
description: "Generation of complete and maintainable documentation."
tags:
  - "agent"
  - "sonnet"
---

# Agent: doc-generate

<span className="badge badge--sonnet">Sonnet</span>

> Generation of complete and maintainable documentation.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | plan |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write` |
| **Disallowed tools** | `["Bash"]` |
| **Injected skills** | _None_ |

## Detailed description

# Agent DOC-GENERATE

Generation of complete and maintainable documentation.

## Workflow

1. **Analyze** the project: structure, stack, features, API
2. **README**: description, features, quick start, doc links, CI/coverage badges
3. **API documentation**: endpoints with request/response, params, errors
4. **Architecture**: ASCII diagrams, components, technologies
5. **Guides**: getting-started, deployment, development per audience

## Recommended structure

- `/docs/README.md` - Introduction
- `/docs/getting-started.md` - Getting started guide
- `/docs/architecture.md` - Technical architecture
- `/docs/api/` - API reference by domain
- `/docs/guides/` - Deployment, development guides
- `CHANGELOG.md` - Version history

## Expected output

1. Complete README.md with badges and quick start
2. Structured API documentation (endpoints, params, errors)
3. Guides per audience (dev, ops, user)
4. CHANGELOG.md if necessary

## Directives

- IMPORTANT: Include code examples in the docs
- IMPORTANT: Use tables for API parameters
- IMPORTANT: ASCII diagrams for architecture (no external dependency)
- NEVER generate empty or placeholder documentation

Think hard about clarity for each target audience.

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
