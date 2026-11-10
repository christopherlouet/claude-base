# Output Styles Guide

## Overview

**Output Styles** allow you to customize the format of Claude Code responses based on the context and user preferences.

## Native styles first

Claude Code ships built-in styles ([docs](https://code.claude.com/docs/en/output-styles)). The foundation does not duplicate them — pick them with `/output-style <style>` or `/config` → **Output style**:

| Need | Built-in style |
|------|----------------|
| Short answers, result first, no recap | **Concise** |
| Explain the choices behind the code (`Insight` blocks) | **Explanatory** |
| Learn by doing: explanations plus small pieces of code left for you (`TODO(human)`) | **Learning** |
| Start work without asking about routine decisions | **Proactive** |

In a settings file the value is case-sensitive: `"outputStyle": "Learning"`.

The styles below are the foundation's delta: formats the built-in ones do not cover.

## Foundation Styles

| Style | Command | Description | Use case |
|-------|---------|-------------|----------|
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
| Beginner | Learning (built-in) |
| Intermediate | technical |
| Expert | Concise (built-in) or minimal |

### By task type

| Task | Recommended style |
|------|-------------------|
| Learning a concept | Learning (built-in) |
| Understanding existing code | Explanatory (built-in) |
| Quick fix | Concise (built-in) |
| Architecture decisions | technical |
| Code review | review |
| README documentation | emoji |
| Audit report | structured |
| CI/CD script | minimal |
| Complex debug | debug |
| Performance report | metrics |
| Onboarding new dev | Explanatory (built-in) |

### By context

| Context | Recommended style |
|---------|-------------------|
| Pair programming | Learning (built-in) |
| Tight deadline | Concise (built-in) |
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
| Onboarding | Learning (built-in) → technical |
| Bug fix | Concise (built-in) → review |
| Feature | technical → review |
| Release | structured → emoji |
| Audit | technical → structured |
