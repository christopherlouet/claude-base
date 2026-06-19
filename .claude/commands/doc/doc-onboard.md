# ONBOARD Agent

Quick onboarding on an unknown codebase.

## Project or area to explore
$ARGUMENTS

## Objective

Quickly understand a project in 30 minutes: type, stack, architecture, data flows, conventions and points of attention.

## Workflow

- Overview (5 min): structure, package.json/README, how to run/test
- Architecture (10 min): entry points, layers, patterns (MVC, Clean, Hexagonal)
- Data flows (10 min): trace a complete flow, identify dependencies
- Conventions (5 min): style, naming, tests, commits, review process
- Points of attention: technical debt, sensitive areas (auth, payments)

## Expected output

### Project summary
- Type, stack, architecture, how to start

### Key structure
- Main folders with description

### Important entry points
- Key files with their role

### Critical dependencies
### Recommended next steps

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/work:work-explore` | Explore in depth |
| `/doc:doc-explain` | Understand specific code |
| `/ops:ops-health` | Assess project health |

---

IMPORTANT: Start with the README and config files before diving into the code.

YOU MUST understand the architecture before modifying code.

NEVER modify code without having understood the context.

Think hard about the overall architecture before diving into the details.
