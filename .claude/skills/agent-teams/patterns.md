# Pre-configured Agent Teams Patterns

4 ready-to-use patterns for the most common use cases of the foundation.

---

## Pattern 1: Parallel Audit

**Teammates**: 3-4 agents
**Typical duration**: 5-15 minutes
**Use case**: Full quality audit before release or deployment

### Roles

| Role | Focus | Recommended spawn prompt |
|------|-------|---------------------------|
| **security-reviewer** | OWASP Top 10, injections, auth, sensitive data | "Audit the code for OWASP Top 10 vulnerabilities. Focus on authentication, SQL/XSS injections, and sensitive data. Produce a report with severity (critical/high/medium/low)." |
| **perf-analyst** | Core Web Vitals, slow queries, bundle size | "Analyze the application's performance. Focus on slow queries, bundle size, lazy loading, and Core Web Vitals. Measure the metrics if possible." |
| **a11y-checker** | WCAG 2.1 AA, keyboard navigation, screen readers | "Check WCAG 2.1 level AA accessibility. Focus on contrast, keyboard navigation, ARIA attributes, and screen reader compatibility." |
| **design-reviewer** (optional) | UI/UX, visual consistency, responsive | "Audit the UI/UX design. Check visual consistency, responsive behavior, spacing, and web best practices." |

### Coordination

- The 3-4 agents work **independently** (no dependencies)
- Each agent produces its own report
- The lead **synthesizes** the reports into a single document with priorities

### Launch prompt

```
Create a team to audit this project:
- security-reviewer: OWASP Top 10 audit
- perf-analyst: performance analysis and Core Web Vitals
- a11y-checker: WCAG 2.1 AA accessibility
Each produces a report. Synthesize the results when all are done.
```

**Complement**: for Enterprise/Team plans, Claude Code Security can complete this audit with an in-depth vulnerability scan (reasoning over data flows and architectural patterns).

---

## Pattern 2: Team Feature

**Teammates**: 2-3 agents
**Typical duration**: 15-45 minutes
**Use case**: Development of a multi-layered feature (frontend + backend + tests)

### Roles

| Role | Focus | Recommended spawn prompt |
|------|-------|---------------------------|
| **backend-dev** | API, services, models, database | "Implement the backend part of [feature]. Create the services in `src/services/`, the models, and the API endpoints. Do NOT touch the frontend files." |
| **frontend-dev** | UI components, hooks, pages | "Implement the frontend part of [feature]. Create the components in `src/components/`, the hooks, and the pages. Wait for the backend to define the types before consuming the API." |
| **test-writer** | Unit, integration, e2e tests | "Write the tests for [feature]. Start with unit tests (TDD), then integration tests. Cover edge cases and error scenarios." |

### Coordination

- **backend-dev** starts first (defines the shared types/interfaces)
- **frontend-dev** waits for the types then works in parallel
- **test-writer** can start unit tests (TDD) immediately
- The lead manages dependencies via the task list

### Launch prompt

```
Create a team to implement [feature]:
- backend-dev: services and API in src/services/ and src/api/
- frontend-dev: components and hooks in src/components/ and src/hooks/
- test-writer: tests in tests/
Make sure the backend defines the types first.
The test-writer starts the tests in TDD from the beginning.
```

### Dependency management

```
Task 1: [backend-dev] Define the types/interfaces  → No blocker
Task 2: [test-writer] Write the unit tests          → No blocker
Task 3: [backend-dev] Implement the service          → Depends on Task 1
Task 4: [frontend-dev] Create the components         → Depends on Task 1
Task 5: [test-writer] Integration tests              → Depends on Task 3, Task 4
```

---

## Pattern 3: Collaborative Debug

**Teammates**: 3-5 agents
**Typical duration**: 10-30 minutes
**Use case**: Investigation of complex bugs with competing hypotheses

### Roles

| Role | Focus | Recommended spawn prompt |
|------|-------|---------------------------|
| **investigator-1** | Hypothesis A (e.g., data issue) | "Investigate the hypothesis that the bug comes from [hypothesis A]. Look for evidence in [code area]. Share your findings with the other agents." |
| **investigator-2** | Hypothesis B (e.g., logic issue) | "Investigate the hypothesis that the bug comes from [hypothesis B]. Look for evidence in [code area]. Challenge the others' findings." |
| **investigator-3** | Hypothesis C (e.g., environment issue) | "Investigate the hypothesis that the bug comes from [hypothesis C]. Check the configuration and the environment. Share your evidence." |

### Coordination

- Each agent explores a **different hypothesis** in parallel
- The agents **share their findings** via messaging
- **Adversarial** mode: each agent tries to **refute** the others' hypotheses
- The lead facilitates the **debate** and synthesizes the **consensus**

### Launch prompt

```
Create a team to investigate this bug: [bug description]
Spawn 3 agents with different hypotheses:
- investigator-1: hypothesis that it's a [A] issue
- investigator-2: hypothesis that it's a [B] issue
- investigator-3: hypothesis that it's a [C] issue
Ask them to share their evidence and to challenge the others' hypotheses.
Synthesize the consensus when a pattern emerges.
```

---

## Pattern 4: Parallel Review

**Teammates**: 3 agents
**Typical duration**: 5-15 minutes
**Use case**: In-depth multi-criteria code review

### Roles

| Role | Focus | Recommended spawn prompt |
|------|-------|---------------------------|
| **security-reviewer** | Vulnerabilities, auth, sensitive data | "Review the code for security issues. Focus on injections, authentication, and sensitive data. Assign a severity to each finding." |
| **perf-reviewer** | Algorithmic complexity, memory leaks, N+1 | "Review the code for performance issues. Focus on algorithmic complexity, N+1 queries, and potential memory leaks." |
| **quality-reviewer** | Test coverage, readability, patterns | "Review the code for overall quality. Check test coverage, readability, adherence to the project's patterns, and identify technical debt." |

### Coordination

- The 3 agents review **simultaneously** the same files (read-only)
- Each agent produces a **list of findings** with severity
- The lead **consolidates** the reviews into a single report

### Launch prompt

```
Create a team to review the current branch's changes:
- security-reviewer: focus on vulnerabilities and security
- perf-reviewer: focus on performance and complexity
- quality-reviewer: focus on quality, tests and patterns
Each produces a list of findings. Consolidate into a single report.
```

---

## Create a custom pattern

For uncovered cases, describe the structure in natural language:

```
Create a team of [N] agents for [objective]:
- [role-1]: [focus and specific instructions]
- [role-2]: [focus and specific instructions]
- [role-3]: [focus and specific instructions]
[Coordination and synthesis instructions]
```

### Best practices for custom patterns

- Each agent must have a **clear and distinct scope**
- Specify the **files/areas** that each agent must examine
- Define the **dependencies** if order matters
- Indicate how the lead must **synthesize** the results
- Limit to **2-5 agents** to maintain coordination
