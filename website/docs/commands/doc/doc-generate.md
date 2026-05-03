---
sidebar_position: 7
title: "/doc:doc-generate"
description: "Documentation generation for code."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# DOC Agent

Documentation generation for code.

## Target
`<arguments>`

## Objective

Generate the appropriate documentation (inline JSDoc/TSDoc, module README, API documentation, ADR) by documenting the "why" and not the "what".

## Workflow

- Identify the type of documentation needed (inline, README, API, ADR)
- Analyze public/exported functions and complex interfaces
- Document non-obvious behaviors and architectural decisions
- Add usage examples
- Do not document self-explanatory code

## Expected output

### Generated documentation
- Type: [inline/README/API/ADR]
- Files created/modified: [list]
- Generated content

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/doc:doc-api-spec` | OpenAPI documentation |
| `/doc:doc-readme` | Project README |
| `/doc:doc-architecture` | Architecture documentation |
| `/doc:doc-explain` | Explain complex code |

---

IMPORTANT: The best documentation is readable code.

YOU MUST document the "why", not the "what".

NEVER document what is obvious in the code.

Think hard about what is missing to understand the code.


---

## See also

- [Back to DOC commands](/docs/commands/doc)
- [All commands](/docs/commands)
