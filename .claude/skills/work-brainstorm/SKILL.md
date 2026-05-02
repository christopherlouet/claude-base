---
name: work-brainstorm
description: Structured ideation before specification. Transform a vague idea into a validated design via questioning and exploration of alternatives. Trigger when the user has a fuzzy idea, wants to explore approaches, or hesitates between several directions.
allowed-tools:
  - Read
  - Glob
  - Grep
context: fork
disable-model-invocation: true
argument-hint: "[idea-description]"
---

# Structured Brainstorming

## Goal

Transform a raw idea into an approved design BEFORE specifying or implementing.
Ideation phase between "I have a vague idea" and "here are the user stories".

```
Vague idea → BRAINSTORM → Validated design → /work:work-specify → /work:work-plan → /dev:dev-tdd
```

## Iron Rule

IMPORTANT: Do NOT invoke an implementation skill, write code, scaffold a project, or take any implementation action until the design has been presented AND approved by the user.

## Process

### 1. Explore the context

Before proposing anything:

- Read the relevant project files (architecture, existing code, CLAUDE.md)
- Check recent changes (`git log --oneline -10`)
- Identify existing technical constraints
- Understand the "why" behind the idea

### 2. Clarify through questioning

Ask clarification questions **one at a time** (not a block of 10 questions).

| Question type | Example |
|------------------|---------|
| **Goal** | "What problem does this solve for the user?" |
| **Scope** | "Should this work with X or is it independent?" |
| **Constraints** | "Are there time, budget, or tech limits?" |
| **Users** | "Who will use this? In what context?" |
| **Success** | "How will we know it works well?" |

Stop questioning when there is enough context to propose alternatives.

### 3. Propose 2-3 approaches

For each approach, present:

```markdown
### Approach A: [Descriptive name]

**Principle**: [1-2 sentences]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Complexity**: [Low / Medium / High]

**Risks**:
- [Risk 1]
```

### 4. Challenge the approaches

After presenting the alternatives:

- Apply YAGNI: "Do we really need X?"
- Look for the simplest solution that works
- Identify pieces that can be deferred (P2/P3)
- Check that a solution does not already exist in the codebase or dependencies

### 5. Converge on a design

Once the user has chosen a direction:

- Decompose the system into units with a single clear goal
- Define the interfaces between units
- Make sure each unit can be tested independently
- Present section by section, asking for validation at each step

### 6. Document the design

Write the design in a file:

```
docs/designs/YYYY-MM-DD-[topic]-design.md
```

Format:

```markdown
# Design: [Title]

**Date**: YYYY-MM-DD
**Status**: Approved / Under discussion

## Context
[Why this design is needed]

## Decision
[Chosen approach and why]

## Alternatives considered
[Rejected approaches and why]

## Detailed design
[Breakdown into components, interfaces, flows]

## Identified risks
[Risks and mitigations]

## Out of scope
[What is NOT included in this design]
```

### 7. Self-review

Before presenting the final design, check:

- [ ] No placeholders ("TBD", "to be defined", "TODO")
- [ ] No contradictions between sections
- [ ] No ambiguities (each term has a single interpretation)
- [ ] YAGNI applied (no speculative features)
- [ ] Each component is testable independently
- [ ] Interfaces between components are explicit

### 8. Handoff

Once the design is approved, propose:

```
Design approved. Next steps:
1. `/work:work-specify` — Transform this design into testable user stories
2. `/work:work-plan` — Plan the technical implementation
```

## Design principles

- **Decompose** into units that each have a clear goal
- **Explicit interfaces** between units
- **Independently testable**: each unit can be tested alone
- **YAGNI**: no speculative features, no premature generalization
- **Simplicity**: the simplest solution that works is the best
- **Reversibility**: prefer decisions that are easy to change

## Expected output

```markdown
## Brainstorm: [Title]

### Context
[What we have understood about the need]

### Approaches explored
| Approach | Strengths | Weaknesses | Complexity |
|----------|--------|------------|------------|
| A: [...] | [...] | [...] | Low |
| B: [...] | [...] | [...] | Medium |
| C: [...] | [...] | [...] | High |

### Decision
**Chosen approach**: [X]
**Reason**: [Why this approach]

### Design
[Breakdown, interfaces, flows]

### Next steps
1. `/work:work-specify` for the user stories
2. `/work:work-plan` for the technical plan
```

## Related agents

| Before | Usage |
|-------|-------|
| `/work:work-explore` | Understand the technical context |

| After | Usage |
|-------|-------|
| `/work:work-specify` | User stories and acceptance criteria |
| `/work:work-plan` | Technical implementation plan |

## Rules

- ALWAYS explore the context before proposing
- ALWAYS propose at least 2 approaches with trade-offs
- NEVER implement before explicit approval of the design
- Ask clarification questions ONE AT A TIME
- Apply YAGNI systematically
- Document rejected alternatives (not just the chosen one)
