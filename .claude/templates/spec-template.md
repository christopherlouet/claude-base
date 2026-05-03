# Specification: [FEATURE NAME]

**Branch**: `feature/[short-name]`
**Date**: [DATE]
**Status**: Draft | In review | Validated
**Input**: User description: "$ARGUMENTS"

---

## Summary

[1-3 sentences describing what the feature brings to the user, focused on VALUE]

---

## User Stories (prioritized)

<!--
  IMPORTANT: User Stories must be PRIORITIZED as user journeys.
  Each story must be INDEPENDENTLY TESTABLE - if you implement ONLY one,
  you must have a working MVP that delivers value.

  Priorities: P1 = essential MVP, P2 = Important, P3 = Nice-to-have

  Each story must be:
  - Independently developable
  - Independently testable
  - Independently deployable
  - Demonstrable to users
-->

### US1 - [Short title] (Priority: P1) 🎯 MVP

**As a** [type of user]
**I want** [action/feature]
**So that** [benefit/value]

**Why P1**: [Explanation of the value and why this priority]

**Independent test**: [How this story can be tested on its own]

**Acceptance criteria**:

1. **Given** [initial state], **When** [action], **Then** [expected result]
2. **Given** [initial state], **When** [action], **Then** [expected result]

---

### US2 - [Short title] (Priority: P2)

**As a** [type of user]
**I want** [action/feature]
**So that** [benefit/value]

**Why P2**: [Explanation]

**Independent test**: [Description]

**Acceptance criteria**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

### US3 - [Short title] (Priority: P3)

**As a** [type of user]
**I want** [action/feature]
**So that** [benefit/value]

**Why P3**: [Explanation]

**Independent test**: [Description]

**Acceptance criteria**:

1. **Given** [initial state], **When** [action], **Then** [expected result]

---

## Edge Cases

<!--
  ACTION REQUIRED: Replace these placeholders with the real edge cases.
-->

- What happens when [boundary condition]?
- How does the system handle [error scenario]?
- Behavior with [empty/invalid data]?

---

## Functional Requirements

<!--
  ACTION REQUIRED: Replace these placeholders with the real requirements.
  Each requirement must be TESTABLE and VERIFIABLE.
-->

- **FR-001**: The system MUST [specific capability, e.g., "allow account creation"]
- **FR-002**: The system MUST [specific capability, e.g., "validate email addresses"]
- **FR-003**: The user MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: The system MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: The system MUST [behavior, e.g., "log security events"]

*Example of marking unclear requirements:*

- **FR-006**: The system MUST authenticate users via [CLARIFICATION NEEDED: method not specified - email/password, SSO, OAuth?]

---

## Key Entities (if data involved)

<!--
  Include ONLY if the feature involves persisted data.
  Describe entities without implementation details (no column types, no SQL).
-->

| Entity | What it represents | Key attributes | Relations |
|--------|----------------------|----------------|-----------|
| [Entity 1] | [Description] | id, name, ... | [Link to Entity 2] |
| [Entity 2] | [Description] | ... | ... |

---

## Success Criteria (measurable)

<!--
  ACTION REQUIRED: Define MEASURABLE criteria.
  Must be technology-agnostic and verifiable.

  ✅ Good: "Users can complete signup in under 2 minutes"
  ❌ Bad: "Signup is fast" (vague)
  ❌ Bad: "API responds in < 200ms" (too technical, use user perspective)
-->

- **SC-001**: [Measurable metric, e.g., "Users can complete the main task in < 2 minutes"]
- **SC-002**: [System metric, e.g., "Support 1000 concurrent users without degradation"]
- **SC-003**: [Satisfaction metric, e.g., "90% of users succeed at the task on the first try"]
- **SC-004**: [Business metric, e.g., "50% reduction in support tickets related to [X]"]

---

## Out of Scope (explicitly excluded)

<!--
  List what is NOT included in this feature.
  Helps avoid scope creep.
-->

- [Feature X] - will be addressed in a future iteration
- [Use case Y] - out of scope for this version
- [Integration Z] - phase 2

---

## Assumptions and Dependencies

### Assumptions

- [Assumption 1 about context or users]
- [Assumption 2 about environment]

### Dependencies

- [Internal dependency: another feature/module]
- [External dependency: third-party service, API]

---

## Clarification Points

<!--
  Maximum 3 clarification points.
  Use ONLY for decisions that significantly impact scope or UX.
  For the rest, make informed choices based on best practices.
-->

- [CLARIFICATION NEEDED: specific question that impacts scope]
- [CLARIFICATION NEEDED: significant choice between multiple options]

---

## Validation checklist

### Completeness
- [ ] All user stories have acceptance criteria
- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focus on user value and business needs
- [ ] Understandable by a non-developer

### Requirements
- [ ] No unresolved [CLARIFICATION NEEDED] marker (max 3 allowed)
- [ ] Testable and unambiguous requirements
- [ ] Measurable success criteria
- [ ] Technology-agnostic criteria

### Ready for planning
- [ ] All functional requirements have clear criteria
- [ ] User stories cover the main flows
- [ ] The feature delivers measurable value

---

**Version**: 1.0 | **Created**: [DATE] | **Last modified**: [DATE]
