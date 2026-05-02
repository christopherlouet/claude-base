---
sidebar_position: 8
title: Output Styles
description: Understanding Claude Code output styles
---

# Output Styles

> Customize the format and tone of Claude's responses

## What is an Output Style?

An **output style** defines how Claude formats its responses. It allows you to adapt the tone, structure, and level of detail according to context.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Without style (default)          With "concise" style         │
│  ─────────────────────            ─────────────────────        │
│                                                                │
│  "Here is a detailed              "The function computes       │
│  explanation of the               the sum. Returns int."       │
│  function. This function                                       │
│  takes two parameters and                                      │
│  performs a computation..."                                    │
│                                                                │
│  With "teaching" style            With "technical" style       │
│  ─────────────────────            ──────────────────────       │
│                                                                │
│  "Let's start by understanding   "O(n) implementation.         │
│  the concept. A function is      Space complexity O(1).        │
│  like a cooking recipe..."       Pattern: fold/reduce."        │
│                                                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## File structure

Output styles live in `.claude/output-styles/`:

```
.claude/output-styles/
├── README.md           # Documentation
├── teaching.md         # Teaching mode
├── explanatory.md      # Detailed reasoning (recommended by Boris)
├── concise.md          # Brief responses
├── technical.md        # Technical details
├── review.md           # Code review
├── emoji.md            # With emojis
├── minimal.md          # Ultra minimal
├── structured.md       # ASCII structure
├── debug.md            # Diagnostic and investigation
└── metrics.md          # Metrics and dashboards
```

## Usage

### Activate a style

```bash
# In Claude Code
/output-style teaching
```

### Return to the default style

```bash
/output-style default
```

## Available styles

### Teaching

**When to use:** Learning, explanations, onboarding

```markdown
## Characteristics

- Step-by-step explanations
- Analogies and metaphors
- Questions to verify understanding
- Progressive examples

## Example response

"Let's start by understanding what a Promise is.

Imagine you order a coffee. The server gives you a
ticket (the Promise) that represents your future coffee.

The ticket can be:
- Pending — the coffee is being prepared
- Fulfilled — your coffee is ready
- Rejected — no more coffee available

Now, let's look at the code..."
```

### Explanatory (Detailed reasoning)

**When to use:** Understanding the reasoning, learning, onboarding

> Recommended by Boris Cherny: "Enable 'Explanatory' output style in /config for understanding rationale behind changes."

```markdown
## Characteristics

- Explains the WHY before the HOW
- Shows the reasoning step by step
- Compares alternatives and justifies the choice
- Anticipates "but why not X?" questions

## Example response

"## Problem analysis

This component recomputes filteredItems on every render, even when
the inputs have not changed.

## Options considered

### Option A: useMemo
Memoize the result. Recomputes only if deps change.

### Option B: Move into the parent
Simpler but couples the parent to the logic.

## Chosen option: useMemo

**Main reason**: Simplest solution for our case (1-5k items).

## Key takeaways

1. useMemo avoids expensive recomputations, not renders
2. Always measure BEFORE optimizing
3. The dependency list must be exhaustive"
```

### Concise (Brief)

**When to use:** Quick responses, experienced users

```markdown
## Characteristics

- Direct answers
- No introduction
- Minimum words
- Code without verbose comments

## Example response

"Use `useMemo`:

\`\`\`tsx
const value = useMemo(() => compute(data), [data]);
\`\`\`

Deps: dependency array. Recomputes on change."
```

### Technical

**When to use:** Architecture discussions, performance, advanced debug

```markdown
## Characteristics

- Technical jargon
- Algorithmic complexity
- References to specs
- Metrics and benchmarks

## Example response

"Optimal implementation: O(n log n) with merge sort.

Complexity:
- Time: O(n log n) worst case
- Space: O(n) for the buffer

Alternative: quicksort O(n^2) worst case but O(n log n)
average with better cache locality.

Benchmark on 10^6 elements:
- Merge sort: 234ms
- Quick sort: 189ms"
```

### Review (Code review)

**When to use:** Code reviews, audits, pull requests

```markdown
## Characteristics

- Structured by severity
- Concrete suggestions
- Links to documentation
- Positive points included

## Example response

"## Code Review

### Critical
- **L42**: Potential SQL injection

### High
- **L23**: No input validation

### Medium
- **L56**: Magic number (use a constant)

### Positive
- Good separation of concerns
- Unit tests present

### Conclusion
Block until L42 is fixed."
```

### Emoji

**When to use:** Casual communication, visual feedback

```markdown
## Characteristics

- Emojis to illustrate
- Casual tone
- Lists with icons
- Visual feedback

## Example response

"## Summary

✅ Tests pass
⚠️ 2 eslint warnings
❌ Type error on line 42

### To do
- 🔧 Fix the type error
- 📝 Add JSDoc
- 🧪 Cover edge case

🎉 Otherwise it's good!"
```

### Minimal

**When to use:** Scripts, logs, machine-readable output

```markdown
## Characteristics

- No decoration
- No intro/conclusion
- Facts only
- Parseable

## Example response

"error: L42 type mismatch
fix: cast to string
file: src/utils.ts"
```

### Structured (ASCII structure)

**When to use:** Documentation, reports, terminal presentations

```markdown
## Characteristics

- ASCII separators
- Clear sections
- Formatted tables
- Visual hierarchy

## Example response

"═══════════════════════════════════════
           AUDIT REPORT
═══════════════════════════════════════

┌─────────────────────────────────────┐
│ Files analyzed       │          42 │
│ Critical issues      │           2 │
│ Warnings             │          15 │
└─────────────────────────────────────┘

───────────────────────────────────────
Section 1: Security
───────────────────────────────────────
..."
```

## Anatomy of an output style

### File structure

```markdown
# Style Name

Description of the style and when to use it.

## Instructions

Detailed instructions for Claude on how to
format its responses.

## Characteristics

- Point 1
- Point 2
- Point 3

## Example

Example response in this style.
```

### Full example

```markdown
# Teaching Style

Teaching style for learning and explanations.

## Instructions

When this style is active:

1. Start by placing the concept in a familiar context
2. Use everyday analogies
3. Proceed in incremental steps
4. Ask rhetorical questions to engage
5. Provide concrete examples
6. Summarize the key takeaways at the end

## Tone

- Patient and encouraging
- Avoids unexplained jargon
- Celebrates progress

## Typical structure

1. Accessible introduction
2. Analogy or metaphor
3. Progressive explanation
4. Practical example
5. Summary / Key takeaways
6. Verification question

## Example

"Great question! Let's look at it together.

You know storage boxes, right? Well, an array
in programming is exactly that..."
```

## Create a new style

### 1. Create the file

```bash
touch .claude/output-styles/my-style.md
```

### 2. Define the style

```markdown
# My Style

Description of my custom style.

## Instructions

1. Rule 1
2. Rule 2
3. Rule 3

## Characteristics

- Characteristic 1
- Characteristic 2

## Example

Example response with this style.
```

### 3. Use it

```bash
/output-style my-style
```

## Best practices

1. **Style suited to context**: Teaching to learn, Concise to produce
2. **Consistency**: Keep the same style within a session
3. **Don't overuse**: The default style is often enough
4. **Document**: Explain when to use each style

## Recommended use cases

| Situation | Style |
|-----------|-------|
| Onboarding new dev | `teaching` |
| Understanding a technical choice | `explanatory` |
| PR code review | `review` |
| Quick debug | `concise` |
| Architecture discussion | `technical` |
| Audit report | `structured` |
| Team communication | `emoji` |
| Script/automation | `minimal` |

---

## See also

- [Commands](./commands) - Manual instructions
- [Architecture](/docs/intro/architecture) - Overview
