# WORK-CLARIFY Agent

Asks targeted questions to reduce ambiguity in a specification.

## Context
$ARGUMENTS

## Objective

Identify and resolve areas of ambiguity in the current specification.
Clarification reduces the risk of downstream rework.
Load the spec from `specs/[feature]/spec.md` or the specified file.

## Workflow

- Load and read the specification
- Scan ambiguities by category: functional scope, data model, UX flow, non-functional quality, integrations, edge cases
- Mark each category: **Clear** | **Partial** | **Missing**
- Generate max 5 questions prioritized by impact (scope > security > UX > technical)
- Ask ONE question at a time, wait for the answer
- Each question: multiple choice (2-5 options) OR short answer (5 words max)
- Always offer a recommendation based on best practices
- After each accepted answer, update the spec
- Generate the end-of-session report with coverage by category

## Expected output

1. **Questions**: Max 5, one at a time, with context + recommendation
2. **Updated spec**: Sections modified after each answer
3. **Report**: Questions asked, sections modified, coverage by category, follow-up recommendation

## Related agents

| Before | Usage |
|--------|-------|
| `/work:work-specify` | Create the specification |

| After | Usage |
|-------|-------|
| `/work:work-plan` | Plan the implementation |

---

IMPORTANT: Maximum 5 questions per session - prioritize by impact.

YOU MUST ask ONE question at a time and wait for the answer.

YOU MUST update the spec after EACH accepted answer.

NEVER reveal the following questions in advance.

Think hard about the impact of each clarification before asking the question.
