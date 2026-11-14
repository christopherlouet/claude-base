---
name: work-explore
description: Explore and understand an existing codebase. Use when the user wants to understand the code, explore a project, discover an architecture, or before modifying existing code.
context: fork
background: false
disable-model-invocation: true
---

# Explore a Codebase

## Goal

Understand a codebase BEFORE modifying it. Never code without having explored.

## Native features first

Claude Code ships a built-in, read-only **Explore** sub-agent that Claude delegates codebase searches to, choosing a thoroughness level ("quick", "medium" or "very thorough"; you can ask for one). For a quick lookup, let it do the searching.

**This skill's delta is the shape of the result**: a guided first pass over a project (structure, configuration, entry points) ending in a fixed summary (key structure, entry points, conventions, sensitive areas). Use it when you want that full picture before a change, rather than the answer to one search.

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
