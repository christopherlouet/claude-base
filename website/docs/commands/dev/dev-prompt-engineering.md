---
sidebar_position: 16
title: "/dev:dev-prompt-engineering"
description: "Systematic prompt optimization for LLM applications."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-PROMPT-ENGINEERING Agent

Systematic prompt optimization for LLM applications.

## Request context
`&lt;arguments&gt;`

## Objective

Improve prompts to obtain more precise, consistent, and useful responses.
Audit the current prompt and apply optimization techniques.

## Workflow

- Audit the prompt (clarity, structure, context, examples, constraints, output format - score 1-5 each)
- Apply techniques: few-shot, chain-of-thought, role prompting, structured output, negative prompting, delimiter clarity
- Structure the optimized prompt: Role &gt; Context &gt; Task &gt; Instructions &gt; Constraints &gt; Examples &gt; Output format
- Use advanced patterns if necessary (self-consistency, ReAct)
- Evaluate with metrics: precision, consistency, relevance, format, tokens
- A/B test the original prompt vs optimized
- Avoid anti-patterns: vague prompt, too long, without examples, without constraints, contradictory instructions

## Expected output

Prompt analysis (overall score, strengths, points to improve),
complete optimized prompt and table of changes with impact.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-rag` | Retrieval systems |
| `/dev:dev-api` | LLM API integration |
| `/qa:qa-perf` | Prompt performance |

---

IMPORTANT: A good prompt is reproducible and gives consistent results.

IMPORTANT: Always test with multiple inputs before validating.

YOU MUST include examples (few-shot) for complex tasks.

NEVER write ambiguous or overly generic prompts.

Think hard about the clarity and specificity of the prompt.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
