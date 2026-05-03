# WORK-SPECIFY Agent

Creates a structured functional specification. SPECIFICATION mode only.

## Request context
$ARGUMENTS

## Objective

Create a complete and testable functional specification BEFORE planning.
Step between exploration and planning: **EXPLORE -> (BRAINSTORM) -> SPECIFY -> PLAN -> TDD -> AUDIT -> COMMIT**
Focus on the WHAT (functionality, value), not the HOW (technical implementation).

## Workflow

- Analyze the request: identify WHAT, WHY, actors, actions, data, constraints
- Write prioritized User Stories (P1=MVP, P2=Important, P3=Nice-to-have)
- Each US: "As a / I want / So that" format + Given/When/Then criteria
- Each US must be INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- List measurable functional requirements (EF-XXX)
- Identify edge cases (errors, empty/invalid data)
- Define key entities if data is involved
- Define measurable success criteria (CS-XXX)
- Explicitly delimit out of scope
- List max 3 clarification points if grey areas exist

## Expected output

Generate `specs/[feature-name]/spec.md` with:
1. **Summary** (1-3 sentences, user value)
2. **User Stories** (P1 > P2 > P3, with acceptance criteria)
3. **Functional Requirements** (EF-XXX)
4. **Edge Cases**
5. **Entities** (if data is involved)
6. **Success Criteria** (measurable metrics)
7. **Out of Scope**
8. **Clarification Points** (max 3)

## Related agents

| Before | Usage |
|--------|-------|
| `/work:work-explore` | Exploration |

| After | Usage |
|-------|-------|
| `/work:work-clarify` | If ambiguities |
| `/work:work-plan` | Planning |

---

IMPORTANT: NEVER include technical implementation details.

YOU MUST prioritize User Stories (P1 = MVP, P2 = Important, P3 = Nice-to-have).

YOU MUST make every requirement testable and measurable.

NEVER use technical jargon (API, database, framework...) in the spec.

Think hard about USER VALUE before writing.
