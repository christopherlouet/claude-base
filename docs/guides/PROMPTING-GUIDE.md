# Advanced Prompting Guide

> Prompting techniques recommended by Boris Cherny (creator of Claude Code) to maximize the quality of results.

## Fundamental Principle

> "The more specific and detailed the specification, the better the output."

The more precise your request, the better the result. Claude Code excels when it has clear context and well-defined expectations.

## Prompting Techniques

### 1. Challenge Claude ("Grill Me")

Ask Claude to challenge you before proceeding:

```
"Grill me on these changes and don't make a PR until I pass your test."
```

**Result**: Claude asks critical questions about your understanding, identifies edge cases, and ensures you have thought of everything before implementing.

**When to use it**:
- Before merging an important PR
- To validate your understanding of a complex system
- To identify risks you have not anticipated

### 2. Demand Proof ("Prove It")

Force Claude to justify its choices with concrete evidence:

```
"Prove to me this works. Show me the diff and explain why it solves the problem."
```

**Result**: Claude provides detailed justifications, shows the exact changes, and explains the reasoning.

**When to use it**:
- For critical changes (security, performance)
- When you want to understand the "why" in depth
- To document the decision for future developers

### 3. Iterate Toward Elegance ("Scrap and Redo")

After a first implementation, ask for a more elegant version:

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```

**Result**: Claude uses the learnings from the first iteration to produce a cleaner, better-structured solution.

**When to use it**:
- When the first solution works but feels "hacky"
- For code that will be maintained for a long time
- Before finalizing a public API

### 4. Detailed Specifications

The more detailed the specification, the better the result:

#### Bad prompt
```
"Add error handling"
```

#### Good prompt
```
"Add error handling for the getUserById function:
- If user doesn't exist, throw UserNotFoundError with user ID
- If database connection fails, retry 3 times with exponential backoff (1s, 2s, 4s)
- If all retries fail, throw DatabaseConnectionError with last error message
- Log each retry attempt with warn level
- Log final failure with error level including stack trace"
```

### 5. Concrete Examples (Few-Shot)

Provide examples of the expected result:

```
"Generate error messages following this pattern:

Input: { field: 'email', value: 'invalid' }
Output: 'Email address is not valid. Please enter a valid email like user@example.com'

Input: { field: 'password', value: '123' }
Output: 'Password is too short. Please use at least 8 characters including a number and symbol'

Now generate messages for: { field: 'phone', value: 'abc' }"
```

### 6. Explicit Constraints

Specify what you do NOT want:

```
"Implement user authentication:
- DO use bcrypt for password hashing
- DO NOT use MD5 or SHA1
- DO NOT store passwords in plain text
- DO NOT log passwords even in debug mode
- DO use constant-time comparison for password verification"
```

### 7. Context Loading (Prior Reading)

Ask Claude to read before acting:

```
"Before making any changes:
1. Read src/services/auth.ts to understand the current auth flow
2. Read src/middleware/authenticate.ts to see how tokens are validated
3. Read src/types/user.ts for the User interface
Then implement the password reset feature following existing patterns."
```

### 8. Explicit Verification

Request verification after implementation:

```
"After implementing the feature:
1. Run npm test and show me the results
2. Run npm run lint and fix any issues
3. Explain what could go wrong in production
4. List the edge cases you've handled"
```

## Prompting Anti-Patterns

| Avoid | Prefer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer exception in getUserById when the user ID doesn't exist in the database" |
| "Make it better" | "Reduce the time complexity from O(n²) to O(n log n) by using a hash map instead of nested loops" |
| "Add tests" | "Add unit tests for the calculateDiscount function covering: empty cart, single item, multiple items, discount codes, and negative quantities" |
| "Refactor this" | "Extract the validation logic into a separate UserValidator class with methods for email, password, and phone validation" |
| "It doesn't work" | "The function returns undefined instead of the expected User object when I call getUserById(123). Here's the error log: [log]" |

## Prompts by Context

### For Debugging

```
"I'm seeing this error: [paste error]
Context:
- This started happening after [change]
- It happens when [condition]
- I've already tried [attempts]

Help me debug this step by step."
```

### For Code Review

```
"Review this PR as if you were a senior engineer. Focus on:
1. Security vulnerabilities (especially auth and input validation)
2. Performance issues (N+1 queries, unnecessary renders)
3. Code maintainability (naming, structure, DRY)
4. Edge cases not handled
5. Missing tests

Be critical - I want honest feedback, not validation."
```

### For Architecture

```
"I need to design a system for [requirement].

Constraints:
- [constraint 1]
- [constraint 2]

Quality attributes (in order of priority):
1. [e.g., Security]
2. [e.g., Scalability]
3. [e.g., Maintainability]

Show me 2-3 options with trade-offs before recommending one."
```

### For Learning

```
"Explain [concept] as if I'm a developer who knows [related tech] but has never used [new tech].

Include:
- Why it exists (the problem it solves)
- How it compares to [similar thing I know]
- A minimal working example
- Common pitfalls beginners hit
- When NOT to use it"
```

## Combination with Foundation Skills

| Skill | Recommended prompt |
|-------|-------------------|
| `/dev:dev-tdd` | "Write failing tests first for [feature], then implement the minimal code to pass" |
| `/qa:qa-security` | "Audit this code as if you're a penetration tester. Find vulnerabilities." |
| `/work:work-plan` | "Create a detailed implementation plan. I want to review it before you code." |
| `/dev:dev-debug` | "Debug this systematically. Show me your hypothesis at each step." |

## Voice Dictation for Better Prompts

Boris recommends using voice dictation (fn x2 on macOS) for more detailed prompts:

> "When I dictate prompts, I tend to be much more detailed than when I type. The extra context always improves results."

### Benefits
- More natural = more details
- Faster than typing
- Less self-censorship on length

## Resources

- [How Boris Uses Claude Code](https://howborisusesclaudecode.com/)
- [10 Claude Code Tips from Boris](https://ykdojo.github.io/claude-code-tips/content/boris-claude-code-tips)
- [Claude Code Best Practices (Anthropic)](https://docs.anthropic.com/en/docs/claude-code)

---

## Advanced Techniques

### Iterative Prompting

Effective prompting rarely follows a direct path. The recommended pattern is: broad first, then progressive narrowing.

**Pattern: Broad -> Precise -> Refined**

**Turn 1 - Broad (exploration)**
```
"I want to improve the API performance. What are the classic
bottlenecks in a Node.js/PostgreSQL API?"
```

**Turn 2 - Precise (focusing)**
```
"For the N+1 queries you identified, show me how to detect
them in this file: src/services/userService.ts"
```

**Turn 3 - Refined (implementation)**
```
"Knowing everything you know now, implement the fix using DataLoader.
Constraints: do NOT change the public API, keep TypeScript strict mode."
```

**When to restart vs continue refining**

| Signal | Action |
|--------|--------|
| Claude drifts from the main subject | New reframing turn |
| The proposed solution does not match the context | `/clear` and restart with more initial context |
| The conversation exceeds 30 turns | Compact (`/compact`) or restart |
| A baseline assumption was wrong | Correct explicitly: "Actually, contrary to what I said earlier..." |

**"Knowing everything you know now" technique**

After several turns of exchange, Claude accumulates implicit context. Leverage this context:

```
"Knowing everything you know now about this codebase and the constraints
we've discussed, implement the cleanest possible solution. Forget the
intermediate versions."
```

This phrasing pushes Claude to synthesize the learnings from the conversation rather than continuing on the incremental trajectory.

---

### Prompting by Complexity Level

Adapting the prompt structure to the complexity of the task reduces unnecessary iterations.

| Complexity | Lines | Recommended structure | Example |
|------------|--------|-----------------------|---------|
| Simple | 1 line | Direct instruction | `"Rename variable userId to accountId in auth.ts"` |
| Medium | 2-3 lines | Context + instruction + constraint | `"In the payment module, add input validation for the amount field. Reject negative values and values above 10000."` |
| Complex | 5+ lines | Context + examples + constraints + verification criteria | See template below |

**Template for complex tasks**

```
Context: [what exists, what the system does, relevant constraints]

Task: [precise instruction, single verb, single outcome]

Examples:
  Input:  [input example]
  Output: [expected output example]

Constraints:
  - DO: [what is mandatory]
  - DO NOT: [what is forbidden]

Verification: after implementing, run [command] and show me the output.
```

---

### Multi-Agent Prompting

When a workflow delegates work to sub-agents (via `/work:work-team` or an orchestrator), the briefing of each sub-agent must be self-contained: the agent does not see the parent conversation.

**Sub-agent briefing principles**

1. Include the minimum sufficient context (not the entire conversation)
2. Specify the expected deliverable unambiguously
3. Indicate the files to read before acting
4. Define the verification command to execute
5. Specify the output format if the result is consumed by another agent

**Context handoff template**

```
You are working on [project], a [short description].

Relevant files:
  - [file A]: [its role]
  - [file B]: [its role]

Your task: [precise instruction]

Constraints: [technical constraints]

When done: run [verification command] and report the result.
Output format: [format if consumed by another agent]
```

**When to use Agent Teams vs sequential**

| Situation | Approach |
|-----------|----------|
| Independent tasks (no dependency between them) | Agent Teams (parallelism) |
| Task B depends on the deliverable of task A | Sequential |
| Same code domain, order matters | Sequential to avoid conflicts |
| Audit + implementation on distinct modules | Agent Teams |

---

### Advanced Patterns

**"Grill Me" Pattern (challenger)**

Used before an irreversible decision or an important merge. Claude takes the role of a hostile reviewer.

```
"Before we proceed, grill me on this architecture decision.
Ask me the hardest questions a skeptical senior engineer would ask.
Do not let me move forward until I've answered convincingly."
```

Variant for code:
```
"Grill me on this implementation. Find every assumption I'm making
that could be wrong in production."
```

**"Prove It Works" Pattern (justification by proof)**

Claude cannot just claim that a solution works - it must demonstrate it.

```
"Prove to me this fix works. Show me:
1. The exact lines changed (diff)
2. The test that was failing and now passes
3. Why the root cause is eliminated, not just masked"
```

**"Scrap and Redo" Pattern (start fresh)**

When a first iteration works but is too complex to be maintained:

```
"This works but it's too complex. Scrap it. Knowing everything you
know now about the requirements and edge cases, implement the
simplest possible version that still handles all cases correctly."
```

To use after a first Red-Green cycle, before committing, when the code "smells bad".

**Chain-of-Verification Pattern**

Force Claude to verify its own work step by step before delivering:

```
"After implementing, verify your work in this order:
1. Does it compile / pass type-check ?
2. Do all existing tests still pass ?
3. Does the new test I described pass ?
4. Is there any input that could cause a crash ?
Only report completion after all four checks are green."
```

**Negative Prompting ("DO NOT")**

Negative constraints are often more effective than positive constraints for avoiding repeated errors:

```
"DO NOT:
- Introduce new dependencies without asking
- Change the public API surface
- Use any (TypeScript strict mode is required)
- Leave console.log statements
- Modify test files unless explicitly asked"
```

To place at the beginning of the prompt for critical constraints, at the end of the prompt for preferences.

---

### Detailed Anti-Patterns

| Anti-pattern | Why it fails | Alternative |
|---|---|---|
| Vague prompt without context ("fix it", "make it better") | Claude invents the missing context and solves the wrong problem | Describe the observed behavior, the expected behavior, and the file concerned |
| Over-constraining every detail ("use exactly 4 spaces, name the variable x, add a comment every 3 lines") | Claude spends time respecting arbitrary constraints instead of solving the problem | Constrain the interface and the behavior, not the internal implementation |
| Asking for confirmation at every step ("tell me before you do anything", "ask me before each file") | Multiplies conversation turns, fragments the context, slows down without adding value | Define the constraints upfront in a single prompt, let Claude execute |
| Not providing a means of verification | Claude cannot detect its own silent errors | Always include a verification command: `npm test`, `npm run typecheck`, `claude-base validate` |
| Correcting Claude on the fly without reformulating | Ad-hoc corrections accumulate and the context becomes inconsistent | If more than 2 corrections are needed, restart with a reformulated prompt integrating the corrections |
