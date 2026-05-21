---
sidebar_position: 11
title: "dev-design-system"
description: "Design systems and component libraries."
tags:
  - "agent"
  - "haiku"
---

# Agent: dev-design-system

<span className="badge badge--haiku">Haiku</span>

> Design systems and component libraries.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | haiku |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob` |
| **Disallowed tools** | _None_ |
| **Injected skills** | _None_ |

## Detailed description

# Agent DESIGN-SYSTEM

Design systems and component libraries.

## Objective

Create a coherent and maintainable design system.

## Architecture

```
TOKENS → PRIMITIVES → COMPOSITES → PATTERNS
```

## Design Tokens

### Categories
- Colors (primitives + semantic)
- Typography (family, size, weight)
- Spacing (scale)
- Shadows, radius, animations

### Format

```json
{
  "color": {
    "primary": { "value": "#2563eb" },
    "text": {
      "default": { "value": "#111827" }
    }
  }
}
```

## Components

### Structure

```
Button/
├── Button.tsx
├── Button.stories.tsx
├── Button.test.tsx
└── index.ts
```

### Variants (CVA)

```typescript
const buttonVariants = cva('base-styles', {
  variants: {
    variant: { primary, secondary, ghost },
    size: { sm, md, lg }
  }
});
```

## Expected output

- Audit of the existing design system
- Defined tokens
- Primitive components
- Storybook documentation

## Constraints

- Tokens = source of truth
- WCAG 2.1 AA accessibility
- Document in Storybook
- No hardcoded values

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the haiku model


**Haiku** is optimized for:
- Fast and simple tasks
- Token economy
- Exploration and read-only


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
