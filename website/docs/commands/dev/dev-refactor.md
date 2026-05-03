---
sidebar_position: 19
title: "/dev:dev-refactor"
description: "Code refactoring with behavior preservation and quality improvement."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-REFACTOR

Code refactoring with behavior preservation and quality improvement.

## Request context
`&lt;arguments&gt;`

## Objective

Improve the structure, readability and maintainability of the code
WITHOUT changing its external behavior. Atomic commits at each transformation.

## Workflow

- **Prepare**: Run tests, check coverage (&gt;80% = safe, 60-80% = add tests, &lt;60% = tests first)
- **Analyze**: Identify code smells (Long Method, Large Class, Duplicate Code, Deep Nesting, Magic Numbers, Feature Envy, etc.)
- **Plan**: List transformations by priority and risk
- **Execute**: For each transformation: apply ONE transformation, run tests, if OK commit, if KO revert
- **Validate**: Final tests, coverage &gt;= initial, lint and typecheck OK

## Main techniques

- Extract Method, Extract Class
- Replace Conditional with Polymorphism
- Introduce Parameter Object
- Replace Magic Numbers with Constants
- Simplify Conditionals (early returns)

## Expected output

Initial analysis (code smells, coverage), ordered transformation plan,
transformations performed with atomic commits, result (tests, coverage, complexity).

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/work:work-explore` | Understand the code before refactoring |
| `/dev:dev-test` | Add missing tests |
| `/qa:qa-review` | Post-refactoring review |
| `/work:work-commit` | Atomic commits |

---

IMPORTANT: External behavior MUST NOT change.

IMPORTANT: Small steps. One change at a time. Test after each change.

YOU MUST have sufficient test coverage BEFORE refactoring.

NEVER refactor and add features at the same time.

Think hard about the order of transformations to minimize risks.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
