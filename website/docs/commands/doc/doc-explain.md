---
sidebar_position: 5
title: "/doc:doc-explain"
description: "Explain complex code in detail."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# EXPLAIN Agent

Explain complex code in detail.

## Code to explain
`<arguments>`

## Objective

Provide a multi-level explanation (overview, structure, details) tailored to the target audience, with analogies, ASCII diagrams, and concrete examples.

## Workflow

- Read and understand the code in its context
- Level 1: Overview (purpose, inputs/outputs, usage context)
- Level 2: Structure (organization, main parts, interactions)
- Level 3: Details (line by line if necessary, implementation choices, edge cases)
- Provide algorithmic complexity if relevant
- Illustrate with analogies and ASCII diagrams
- Accompany with concrete examples using real values

## Expected output

### One-sentence summary
### Detailed explanation (according to the requested level)
### Key takeaways
### Anticipated frequently asked questions

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/doc:doc-onboard` | Discover a full codebase |
| `/work:work-explore` | Explore before explaining |
| `/doc:doc-generate` | Document after explanation |
| `/qa:qa-review` | Review explained code |

---

IMPORTANT: Adapt the level of detail to the target audience.

YOU MUST explain the "why", not just the "what".

NEVER assume the reader knows the context.

Think hard about analogies that can clarify concepts.


---

## See also

- [Back to DOC commands](/docs/commands/doc)
- [All commands](/docs/commands)
