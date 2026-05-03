---
sidebar_position: 16
title: "dev-prompt-engineering"
description: "Prompt optimization for LLMs. Trigger when the user wants to improve a prompt, add examples, or structure instructions."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-prompt-engineering

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Prompt optimization for LLMs. Trigger when the user wants to improve a prompt, add examples, or structure instructions.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Keywords** | `dev`, `prompt`, `engineering`, `instruction`, `system message`, `few-shot`, `examples` |

## Detailed description

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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to prompt..."_
- _"I want to engineering..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Prompt Engineering Example: Optimizing a code review prompt

# Prompt Engineering Example: Optimizing a code review prompt

## User request
> "Improve this code review prompt to get more consistent results"

---

## Original prompt (to optimize)

```
Do a code review.
```

---

## Prompt analysis

### Initial score: 6/30

| Criterion | Score | Comment |
|-----------|-------|---------|
| Clarity | 1/5 | No precise instruction |
| Structure | 1/5 | No structure |
| Context | 1/5 | No context provided |
| Examples | 1/5 | No examples |
| Constraints | 1/5 | No defined limits |
| Format | 1/5 | Output not specified |

### Identified weaknesses

1. **Too vague**: "Do a code review" doesn't specify what to look for
2. **No context**: Project type, language, standards unknown
3. **No examples**: The model doesn't know what format to use
4. **Unpredictable output**: Different results on every run

---

## Optimized prompt

```markdown
# Role
You are a code review expert with 10 years of experience in software development.
You master clean code patterns, SOLID, and security best practices.

# Context
- Project: TypeScript/React web application
- Standards: ESLint strict, mandatory tests, coverage > 80%
- Team: 5 senior developers

# Task
Analyze the provided code and produce a structured and actionable code review.

# Instructions
1. Identify critical issues (bugs, security)
2. Verify compliance with project conventions
3. Evaluate readability and maintainability
4. Suggest concrete improvements
5. Acknowledge positive points

# Constraints
- Prioritize issues by severity (Critical > High > Medium > Low)
- DO NOT suggest major refactoring without justification
- DO NOT criticize style if it follows conventions
- Limit to 10 comments maximum to remain actionable

# Examples

## Example 1 - Security issue
Input:
```typescript
const query = `SELECT * FROM users WHERE id = ${userId}`;
```

Output:
```
[CRITICAL] Potential SQL injection (line X)
- Issue: Direct variable concatenation in a SQL query
- Risk: SQL injection allowing data access/modification
- Solution: Use parameterized queries
```typescript
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```
```

## Example 2 - Readability improvement
Input:
```typescript
const x = users.filter(u => u.a && u.b > 18 && !u.c);
```

Output:
```
[MEDIUM] Unclear naming (line X)
- Issue: Variables a, b, c are not descriptive
- Impact: Difficulty in understanding and maintenance
- Solution: Use explicit names
```typescript
const adultActiveUsers = users.filter(user =>
  user.isActive &&
  user.age > 18 &&
  !user.isDeleted
);
```
```

# Output format

```markdown
## Summary
- Total: X comments (Y critical, Z high, W medium)
- Overall grade: [A-F]

## Comments

### [SEVERITY] Short title (line X)
- **Issue**: Description
- **Impact**: Consequence
- **Solution**: Corrected code

## Positive points
- [List of observed best practices]

## Conclusion
[Final recommendation: approve, request changes, or block]
```

---

# Code to analyze

[CODE_TO_ANALYZE]
```

---

## Score after optimization: 28/30

| Criterion | Score | Comment |
|-----------|-------|---------|
| Clarity | 5/5 | Precise and detailed instructions |
| Structure | 5/5 | Well-defined logical sections |
| Context | 4/5 | Project context provided |
| Examples | 5/5 | 2 concrete examples with format |
| Constraints | 5/5 | Clear limits, defined priorities |
| Format | 4/5 | Detailed output template |

---

## Changes made

1. **Added a role**: Code review expert with specific experience
2. **Project context**: TypeScript/React, team standards
3. **Structured instructions**: 5 clear and ordered steps
4. **Explicit constraints**: Priorities, limits, exclusions
5. **Few-shot examples**: 2 examples showing the expected format
6. **Output template**: Exact structure of the result

---

## Techniques used

| Technique | Application |
|-----------|-------------|
| **Role prompting** | "Code review expert with 10 years of experience" |
| **Few-shot learning** | 2 examples with input/output |
| **Structured output** | Detailed markdown template |
| **Negative prompting** | "DO NOT suggest...", "DO NOT criticize..." |
| **Delimiters** | Sections separated by headers |

---

## Possible variations

### Short version (for quick reviews)

```markdown
Role: TypeScript code review expert.

Analyze this code and return as JSON:
{
  "severity": "critical|high|medium|low",
  "issues": [{"line": N, "type": "...", "fix": "..."}],
  "approved": true|false
}

Code:
[CODE]
```

### Security-focus version

```markdown
Role: OWASP security expert.

Look ONLY for vulnerabilities:
- Injection (SQL, XSS, Command)
- Authentication/Authorization
- Sensitive data exposure
- Security misconfiguration

Format: CVSS score + remediation for each issue.
```

---

## Best practices

1. **Adapt to context**: Adjust the prompt based on the language/framework
2. **Iterate**: Test and refine on multiple examples
3. **Version**: Keep a history of prompts
4. **Measure**: Evaluate the consistency of results
5. **Document**: Explain choices for the team



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
