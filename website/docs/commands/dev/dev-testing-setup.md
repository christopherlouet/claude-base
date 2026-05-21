---
sidebar_position: 22
title: "/dev:dev-testing-setup"
description: "Configures the testing infrastructure for a project."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-TESTING-SETUP

Configures the testing infrastructure for a project.

## Request context
`<arguments>`

## Objective

Set up a complete testing strategy: framework, configuration,
coverage, mocking and CI/CD.

## Workflow

- Choose the framework suited to the stack (Vitest for React/Vue/Node, Pytest for Python, Go test for Go)
- Install and configure the framework with coverage thresholds (80%)
- Organize the tests (co-located or __tests__ folder)
- Configure the global setup and shared mocks
- Set up MSW for API mocks (preferred over manual mocks)
- Configure the npm scripts (test, test:watch, test:ui, test:coverage, test:ci)
- Integrate into CI/CD (GitHub Actions with coverage upload)
- Define thresholds per type: new code 80%, critical 90%, utils 100%, UI 70%

## Expected output

- Framework configuration (vitest.config.ts, pytest.ini, etc.)
- Global setup and MSW mocks
- npm scripts
- CI/CD workflow
- Test conventions documentation

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-tdd` | Develop in TDD |
| `/dev:dev-test` | Generate tests |
| `/ops:ops-ci` | CI/CD configuration |
| `/qa:qa-automation` | Test automation |

---

IMPORTANT: Always configure coverage thresholds for new code.

YOU MUST use MSW rather than manual mocks for APIs.

NEVER mock what can be tested for real (pure functions, utils).

Think hard about the testing strategy before configuring.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
