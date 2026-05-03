# Output Styles Guide

## Overview

**Output Styles** allow you to customize the format of Claude Code responses based on the context and user preferences.

## Available Styles

| Style | Command | Description | Use case |
|-------|---------|-------------|----------|
| **teaching** | `/output-style teaching` | Pedagogical mode | Learning, training, explanations |
| **explanatory** | `/output-style explanatory` | Detailed reasoning | Understanding the why, onboarding, debug |
| **concise** | `/output-style concise` | Brief and direct | Experienced devs, speed |
| **technical** | `/output-style technical` | In-depth technical | Architecture, technical decisions |
| **review** | `/output-style review` | Code review | Code review, PR, audits |
| **emoji** | `/output-style emoji` | Enriched with emojis | Presentations, documentation |
| **minimal** | `/output-style minimal` | Stripped down, no decoration | Terminal, logs, CI/CD |
| **structured** | `/output-style structured` | ASCII structure | Reports, analyses |
| **debug** | `/output-style debug` | Methodical diagnosis | Debugging, troubleshooting |
| **metrics** | `/output-style metrics` | Numbers and benchmarks | Performance, reports |

## Choice Matrix

### By experience level

| Level | Recommended style |
|-------|-------------------|
| Beginner | teaching |
| Intermediate | technical |
| Expert | concise or minimal |

### By task type

| Task | Recommended style |
|------|-------------------|
| Learning a concept | teaching |
| Understanding existing code | explanatory |
| Quick fix | concise |
| Architecture decisions | technical |
| Code review | review |
| README documentation | emoji |
| Audit report | structured |
| CI/CD script | minimal |
| Complex debug | debug |
| Performance report | metrics |
| Onboarding new dev | explanatory |

### By context

| Context | Recommended style |
|---------|-------------------|
| Pair programming | teaching |
| Tight deadline | concise |
| Technical planning | technical |
| Pull Request | review |
| Client demo | emoji |
| Server logs | minimal |
| Sprint report | structured |
| Troubleshooting | debug |
| Benchmarks | metrics |

## Comparative Examples

### Question: "How to implement pagination?"

---

#### Teaching Mode
```markdown
## Concept: Pagination

### What is it?
Pagination splits large lists of data into smaller pages
to improve performance and UX.

### Why is it useful?
- Reduces server load (less data per request)
- Improves loading time
- Lets the user navigate easily

### How does it work?
We use two parameters: `page` (page number) and `limit`
(items per page). The server computes the `offset` like this:
offset = (page - 1) * limit

### Practical example
[Detailed code with comments...]

### Key points to remember
- Always define a default limit
- Validate parameters server-side
- Return the total for page calculation
```

---

#### Concise Mode
```typescript
const paginate = <T>(items: T[], page = 1, limit = 10) =>
  items.slice((page - 1) * limit, page * limit);
```

---

#### Technical Mode
```markdown
## Implementation: Pagination

### Analysis
Offset-based vs cursor-based pagination. Offset is simple but inefficient
on large tables. Cursor is stable but complex.

### Implementation
[TypeScript code with full types]

### Complexity
- Time: O(n) offset / O(1) cursor
- Space: O(limit)

### Trade-offs
| Approach | Pros | Cons |
|----------|------|------|
| Offset | Simple, page number | Slow on large datasets |
| Cursor | Performant, stable | No page jump |
```

---

#### Structured Mode
```
════════════════════════════════════════
PAGINATION
════════════════════════════════════════

────────────────────────────────────────
Approaches
────────────────────────────────────────

┌─────────────┬──────────────┬──────────┐
│ Type        │ Performance  │ Usage    │
├─────────────┼──────────────┼──────────┤
│ Offset      │ O(n)         │ Simple   │
│ Cursor      │ O(1)         │ Scale    │
│ Keyset      │ O(log n)     │ Mixed    │
└─────────────┴──────────────┴──────────┘

[OK]   Offset for < 10k items
[WARN] Cursor recommended > 10k items
```

---

## Configuration

### Required frontmatter

Each style file must have:

```yaml
---
name: Style Name
description: Short description
keep-coding-instructions: true
---
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Displayed name of the style |
| `description` | string | Short description |
| `keep-coding-instructions` | boolean | Keep coding instructions |

## Create a Custom Style

1. Create a `.md` file in `.claude/output-styles/`
2. Add the YAML frontmatter
3. Document the format and examples

### Template

```markdown
---
name: My Style
description: Description of my custom style
keep-coding-instructions: true
---

# My Style

## Principles
- Principle 1
- Principle 2

## Format
[Format description]

## Examples
[Usage examples]
```

## Recommended Combinations

| Workflow | Styles |
|----------|--------|
| Onboarding | teaching → technical |
| Bug fix | concise → review |
| Feature | technical → review |
| Release | structured → emoji |
| Audit | technical → structured |
