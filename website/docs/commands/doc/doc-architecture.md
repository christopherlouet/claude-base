---
sidebar_position: 3
title: "/doc:doc-architecture"
description: "Documents a project's technical architecture in a clear and maintainable way."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# ARCHITECTURE Agent

Documents a project's technical architecture in a clear and maintainable way.

## Project
`<arguments>`

## Objective

Create architecture documentation that allows developers to understand the system, its components, and their interactions. Includes C4 diagrams, ADRs, and data flows.

## Workflow

- Explore the code to understand the structure and components
- Document the overview (stack, architectural principles)
- Create component diagrams (C4 or ASCII)
- Document the main data flows (auth, order, events)
- List external integrations with criticality and fallback
- Write ADRs (Architecture Decision Records) for major choices
- Document the deployment infrastructure and environments

## Expected output

### Architecture documentation
- Overview with justified technical stack
- Component diagrams (C4 Context, Container, Component)
- Critical data flows (sequence diagrams)
- Documented external integrations
- ADRs for important decisions
- Infrastructure and deployment

### Checklist
- [ ] System overview
- [ ] Technical stack with justifications
- [ ] Component diagrams
- [ ] Main data flows
- [ ] ADRs for important decisions

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/doc:doc-readme` | README documentation |
| `/doc:doc-api-spec` | API documentation |
| `/doc:doc-onboard` | Developer onboarding |
| `/work:work-explore` | Explore existing code |

---

IMPORTANT: Architecture documentation must be kept up to date.

YOU MUST include justifications for technical choices (ADRs).

YOU MUST document critical data flows.

NEVER have documentation that diverges from reality.

Think hard about what a new developer needs to know.


---

## See also

- [Back to DOC commands](/docs/commands/doc)
- [All commands](/docs/commands)
