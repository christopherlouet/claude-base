---
name: dev-prompt-engineering
description: Prompt optimization for LLMs. Trigger when the user wants to improve a prompt, add examples, or structure instructions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Prompt Engineering Skill

## Triggers

This skill activates when the user mentions:
- "prompt", "instruction", "system message"
- "few-shot", "examples"
- "improve the prompt", "optimize"
- "LLM", "GPT", "Claude"

## Methodology

### 1. Analyze the existing prompt

Evaluate on 6 criteria (score 1-5):

| Criterion | Question |
|-----------|----------|
| Clarity | Are the instructions precise? |
| Structure | Logical organization? |
| Context | Sufficient information? |
| Examples | Few-shot learning present? |
| Constraints | Limits defined? |
| Format | Output specified? |

### 2. Apply the techniques

| Technique | When to use |
|-----------|-------------|
| **Few-shot** | Complex tasks, specific format |
| **Chain-of-thought** | Reasoning, calculations, logic |
| **Role prompting** | Specific expertise required |
| **Structured output** | API integration, parsing |
| **Negative prompting** | Avoid common errors |
| **Delimiters** | Separate sections clearly |

### 3. Optimal structure

```markdown
# Role
You are a [ROLE] expert in [DOMAIN].

# Context
[Description of the situation]

# Task
[What the model must accomplish]

# Instructions
1. [Step 1]
2. [Step 2]
3. [Step 3]

# Constraints
- [What must be done]
- DO NOT [What must not be done]

# Examples

## Example 1
Input: [example]
Output: [expected result]

# Output format
[Specify the exact format]
```

## Advanced patterns

### Chain-of-thought

```
Solve this problem step by step:
1. Identify the key elements
2. Analyze the relationships
3. Formulate a hypothesis
4. Draw a conclusion

Show your reasoning.
```

### Self-consistency

```
Generate 3 different approaches,
then synthesize the best answer.
```

### ReAct

```
Alternate between:
- THOUGHT: Reflect
- ACTION: Execute
- OBSERVATION: Analyze
```

## Anti-patterns

| To avoid | Why | Solution |
|----------|-----|----------|
| Vague prompts | Inconsistent results | Be specific |
| Too long | Loss of focus | Simplify |
| No examples | Poor understanding | Few-shot |
| No constraints | Unpredictable output | Define limits |
| Contradictions | Confusion | Re-read |

## Output

For each optimization, provide:

1. **Score before**: X/30
2. **Identified weaknesses**
3. **Optimized prompt**
4. **Score after**: Y/30
5. **Changes made**

## Rules

IMPORTANT: A good prompt produces consistent results across multiple runs.

IMPORTANT: Always include examples for complex tasks.

YOU MUST specify the expected output format.

NEVER write ambiguous or overly generic prompts.
