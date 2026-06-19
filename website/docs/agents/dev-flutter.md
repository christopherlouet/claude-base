---
sidebar_position: 10
title: "dev-flutter"
description: "Flutter development with Clean Architecture and BLoC."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-flutter

<span className="badge badge--sonnet">Sonnet</span>

> Flutter development with Clean Architecture and BLoC.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Edit`, `Write`, `Bash` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent DEV-FLUTTER

Flutter development with Clean Architecture and BLoC.

## Workflow

1. **Clean Architecture structure**: data (datasources, models, repositories impl) / domain (entities, repositories interfaces, usecases) / presentation (bloc, pages, widgets)
2. **BLoC**: define events, states, and bloc with error handling via Either/fold
3. **Widgets**: const constructors, required/optional parameters, composition
4. **Tests**: widget tests (pumpWidget + find), bloc tests (blocTest), unit tests for usecases
5. **Integration**: dependency injection (get_it), routing (GoRouter)

## Expected output

1. Complete feature with Clean Architecture (data/domain/presentation)
2. BLoC with events/states
3. Widget and bloc tests
4. Widgets documented with const constructors

## Guidelines

- IMPORTANT: Respect Clean Architecture (data/domain/presentation separation)
- NEVER put business logic in widgets
- YOU MUST use const constructors when possible
- IMPORTANT: Test blocs with blocTest and widgets with testWidgets
- NEVER import data from domain (one-way dependency direction)

Think hard about the separation of layers.

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
