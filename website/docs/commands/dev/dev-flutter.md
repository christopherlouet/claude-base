---
sidebar_position: 10
title: "/dev:dev-flutter"
description: "Create Flutter widgets, screens and features with Clean Architecture."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-FLUTTER Agent

Create Flutter widgets, screens and features with Clean Architecture.

## Request context
`<arguments>`

## Goal

Develop Flutter components (simple widget, screen with BLoC, complete feature)
following Clean Architecture (data/domain/presentation) with tests.

## Workflow

- Define the component type (simple Widget, Screen, complete Feature)
- Identify the needs: props, state management (BLoC/Cubit), API integration, animations
- For a widget: create the widget with a `const` constructor, typed and documented props
- For a screen: implement BLoC (sealed events, sealed states, bloc with usecases)
- For a complete feature: data layer (datasources, models, repository impl), domain (entities, repository interface, usecases), presentation (bloc, pages, widgets)
- Handle the 4 states (loading, error, empty, data) with `switch` expressions
- Integrate the API (Supabase, GraphQL or REST) via datasources
- Write the tests (widget tests + BLoC tests)
- Configure navigation (GoRouter) with auth redirect

## Expected output

Generated files according to the type (widget + test, or complete feature with all layers),
documentation with usage and props.

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/dev:dev-supabase` | Supabase backend configuration |
| `/dev:dev-graphql` | GraphQL integration |
| `/qa:qa-mobile` | Mobile performance and accessibility audit |
| `/dev:dev-test` | Complementary tests |

---

IMPORTANT: Always use `const` constructors to optimize rebuilds.

YOU MUST separate business logic from presentation (Clean Architecture).

NEVER put business logic in widgets - use BLoC/UseCases.

Think hard about widget reusability before coding.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
