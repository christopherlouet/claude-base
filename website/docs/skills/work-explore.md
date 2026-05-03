---
sidebar_position: 51
title: "work-explore"
description: "Explore and understand an existing codebase. Use when the user wants to understand the code, explore a project, discover an architecture, or before modifying existing code."
tags:
  - "skill"
  - "fork"
---

# Skill: work-explore

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Explore and understand an existing codebase. Use when the user wants to understand the code, explore a project, discover an architecture, or before modifying existing code.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Glob`, `Grep` |
| **Keywords** | `work`, `explore` |

## Detailed description

# Explore a Codebase

## Goal

Understand a codebase BEFORE modifying it. Never code without having explored.

## Instructions

### 1. Overview (5 min)

```bash
# Project structure
ls -la
tree -L 2 -I 'node_modules|.git|dist|build' | head -40

# Configuration
cat package.json | head -30
cat README.md | head -50
```

**Questions to answer:**
- Project type (frontend, backend, fullstack, lib)?
- Tech stack (languages, frameworks)?
- How to run the project?

### 2. Architecture (10 min)

**Identify the layers:**
- Entry points (main, index, app)
- Routes / Controllers
- Services / Business logic
- Data access / Models
- Utilities

**Patterns to spot:**
- Architecture (MVC, Clean, Hexagonal)
- State management
- Error handling
- Configuration

### 3. Data flow

Trace a complete flow:
```
Request → Validation → Processing → DB → Response
```

### 4. Conventions

- Code style (linter config)
- Naming (camelCase, snake_case)
- Test structure
- Commit format

## Expected output

```markdown
## Project summary

**Type**: [frontend/backend/fullstack]
**Stack**: [languages and frameworks]
**Architecture**: [main pattern]

## Key structure
- `/src/xxx` - [description]
- `/src/yyy` - [description]

## Entry points
- `file.ts:line` - [role]

## Identified conventions
- [Convention 1]
- [Convention 2]

## Sensitive areas
- [Area 1] - [why]
```

## Rules

- ALWAYS explore before modifying
- Do not assume — verify in the code
- Note patterns to reuse them

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to work..."_
- _"I want to explore..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Codebase exploration example

# Codebase exploration example

## Context
New developer on a Next.js e-commerce project.

## Exploration performed

### 1. Overview
```bash
# Project structure
tree -L 2 -d src/
```

**Result:**
```
src/
├── app/           # Next.js 13+ routes (App Router)
├── components/    # React components
├── hooks/         # Custom hooks
├── lib/           # Utilities and configuration
├── services/      # API calls
└── types/         # TypeScript types
```

### 2. Entry points identified
- `src/app/layout.tsx` - Main layout
- `src/app/page.tsx` - Home page
- `src/lib/db.ts` - Database connection
- `src/services/api.ts` - API client

### 3. Patterns discovered

| Pattern | Location | Usage |
|---------|----------|-------|
| Server Components | `app/**/*.tsx` | Server-side rendering |
| Client Components | `components/**/*.tsx` | Interactivity |
| Custom Hooks | `hooks/use*.ts` | Reusable logic |
| Zod Validation | `lib/schemas/*.ts` | Data validation |

### 4. Key dependencies
```json
{
  "next": "14.x",
  "react": "18.x",
  "prisma": "5.x",
  "zod": "3.x",
  "tailwindcss": "3.x"
}
```

### 5. Conventions detected
- Naming: PascalCase for components, camelCase for hooks
- Tests: `__tests__/` next to files
- Styles: Tailwind CSS, no CSS modules

## Final output

```markdown
## Exploration summary

**Project type**: Next.js 14 e-commerce
**Architecture**: App Router + Server Components
**Database**: PostgreSQL via Prisma
**Styling**: Tailwind CSS

### Key files to know
1. `src/app/layout.tsx` - Entry point
2. `src/lib/db.ts` - Prisma configuration
3. `src/services/api.ts` - Backend calls

### Recommended next steps
- Read `src/app/api/` to understand the endpoints
- Explore `src/components/` for the UI components
```



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
