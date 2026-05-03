---
sidebar_position: 10
title: "Learning Path - From Novice to Pro"
description: "Progressive guide to mastering Claude Code and claude-socle, from first launch to advanced usage"
---

# Learning Path: From Novice to Pro

This guide walks you step by step through mastering Claude Code and claude-socle, from first launch to building complex applications. It is structured into 5 progressive levels, each with practical exercises, common mistakes to avoid, and a checkpoint to know when to move on to the next.

| Level | Title | Duration | What you learn |
|--------|-------|-------|----------------------|
| 1 | Discovery | 30 min | Installation, first steps, orchestrator |
| 2 | Fundamentals | 2h | Full workflow, commands, agents, skills, rules |
| 3 | Productivity | 2h | TDD, audits, hooks, advanced prompting, parallelism |
| 4 | Mastery | 3h | Creating skills/agents/rules, hooks, MCP |
| 5 | Expert | 2h | Architecture, token optimization, teams, contribution |

**Total estimated duration: 9h30** (to spread across several days)

---

## Level 1 - Discovery (30 minutes)

**Goal:** Understand what Claude Code is, install claude-socle and complete your first interactions.

**Audience:** You have never opened Claude Code, or you have used it as a simple terminal chatbot without any particular configuration.

---

### 1.1 What is Claude Code?

Claude Code is a development agent that runs in your terminal. Unlike an assistant that simply answers your questions, Claude Code can read your source code, write files, execute shell commands, and chain complex operations autonomously.

The fundamental difference from a classic chatbot:

| Classic chatbot | Claude Code |
|-------------------|-------------|
| Answers questions | Acts in your project |
| Knows only what you tell it | Reads your files directly |
| One answer per message | Can chain dozens of operations |
| No persistence | Automatic memory between sessions |

### 1.2 What is claude-socle?

Claude Code on its own is powerful, but it requires that you know exactly what to ask it. claude-socle is a configuration template that turns Claude Code into a structured and reproducible system.

Concretely, claude-socle adds the following to the `.claude/` folder of your project:

- **131 commands**: pre-written instructions for common tasks (`/work:work-explore`, `/dev:dev-tdd`, `/qa:qa-security`, etc.)
- **63 agents**: specialized sub-processes that activate automatically for analysis or audit tasks
- **54 skills**: behaviors that trigger automatically based on your keywords
- **30 rules**: code conventions applied automatically based on the files you modify

Without claude-socle, you have to specify everything in every session. With claude-socle, best practices are integrated and activated automatically.

### 1.3 Installation

Follow the [full installation guide](/docs/intro/installation) for details. In summary:

```bash
# In your project's directory
git clone https://github.com/christopherlouet/claude-socle.git temp-socle
cp -r temp-socle/.claude .
cp temp-socle/CLAUDE.md .
rm -rf temp-socle
```

Verify the installation by launching Claude Code:

```bash
claude
```

At startup, you should see a message similar to:

```
=== Claude Code Session ===
Version socle: 1.30.0
Commandes: 131
Agents: 63
===========================
```

If this message does not appear, see the troubleshooting section of the [installation guide](/docs/intro/installation).

### 1.4 Understanding the terminal interface

Claude Code is used in your terminal. The interface is minimalist: you type your messages or commands, Claude responds and can execute actions.

A few important points to understand right from the start:

**Claude sees your current directory.** When you launch `claude` from `/home/user/my-project`, Claude can read and modify all files in that directory. Always launch Claude from the root of your project.

**Commands start with `/`.** Typing `/work:work-explore` runs the `work-explore` command in the `work` domain. The rest of the time, you write in natural language.

**Claude can make mistakes.** Re-read the proposed modifications before accepting them. The foundation's workflow is designed to minimize errors, but your vigilance is still required.

### 1.5 Basic commands

These four commands are the first to master. They work in any session, regardless of the project.

**`/help`** - Displays the list of commands available in your current session. Useful when you are looking for which command to use.

**`/clear`** - Completely clears the conversation context. To use when you change topics or start a new task unrelated to the previous one. Beware: Claude "forgets" everything that was said.

**`/compact`** - Intelligently summarizes the context while keeping the important decisions. Prefer `/compact` over `/clear` between the phases of a workflow (for example, after a long exploration before moving on to planning).

**`/effort`** - Controls the level of reasoning used. Four levels:

| Level | Command | When to use it |
|--------|----------|-----------------|
| Low | `/effort low` | Exploration, reading files, simple tasks |
| Medium | `/effort medium` | Standard development, fixes |
| High | `/effort high` | Architecture, audit, complex refactoring, debug |

By default, Claude Code adjusts its level automatically. Use `/effort` to force a specific level.

### 1.6 The `/assistant` orchestrator

`/assistant` is the recommended entry point when you do not know which command to use. Describe your need, and the orchestrator guides you to the right command or chain of commands.

```bash
# Guided mode: waits for your confirmation before acting
/assistant

# Example with context
/assistant "I want to add an email notification system to my Node.js API"
```

The orchestrator will analyze your request and propose an action plan. It is the ideal starting point for beginners.

For users who want direct execution without confirmation:

```bash
# Automatic mode: directly runs the appropriate workflow
/assistant-auto "Add regression tests for the auth module"
```

The difference between the two: `/assistant` lets you validate each step, `/assistant-auto` chains the actions automatically. Start with `/assistant` until you are comfortable with the system.

### 1.7 First interaction: exploring a project

The best way to discover Claude Code is to explore an existing project. The `/work:work-explore` command is specifically designed for this: it analyzes your code in read-only mode and produces a structured overview.

```bash
/work:work-explore
```

Claude will examine:
- The structure of folders and main files
- The dependencies and technologies used
- The patterns and conventions in place
- The potential points of attention

You can also explore a specific aspect:

```bash
/work:work-explore "Understand the authentication system"
```

---

### Level 1 Exercise

Choose an existing project on your machine (regardless of size or language).

1. Position yourself in the project directory: `cd /path/to/my-project`
2. Install claude-socle if it is not done
3. Launch Claude Code: `claude`
4. Run `/work:work-explore` and read the produced report
5. Ask two questions in natural language about the code (for example: "What are the main dependencies of this project?" or "Where is the main business logic?")
6. Try `/assistant "What should be done to improve this project?"` and observe the recommendations

**Estimated duration:** 15 to 30 minutes.

---

### Common mistakes at Level 1

**Launching Claude from the wrong directory.** If you launch `claude` from your home (`~`), Claude sees your personal directory, not your project. Always check with `pwd` that you are in the right place.

**Using Claude as a chatbot.** It is tempting to ask general questions ("How to do TDD in Python?"). Claude Code is optimized to work on your specific code. Anchor your requests in the context of your project.

**Accepting all modifications without reviewing.** Claude can make mistakes. Read the diffs before validating, especially at the beginning.

**Not using `/compact` in long sessions.** After 30 to 60 minutes of work, the context accumulates. Use `/compact` to keep sessions smooth.

**Confusing `/clear` and `/compact`.** `/clear` erases everything, `/compact` summarizes intelligently. In most cases, `/compact` is the right choice.

---

### Level 1 Checkpoint

You are ready for Level 2 when you can answer "yes" to these questions:

- [ ] Claude Code starts correctly and displays the foundation's welcome message
- [ ] You know how to run `/work:work-explore` and interpret the produced report
- [ ] You understand the difference between `/clear` and `/compact`
- [ ] You have used `/assistant` to get a recommendation
- [ ] You know that Claude sees the directory from which you launched it

---

## Level 2 - Fundamentals (2 hours)

**Goal:** Master the mandatory workflow Explore -> Specify -> Plan -> TDD -> Audit -> Commit, understand the four key concepts (Commands, Agents, Skills, Rules) and know how to choose the right command for each situation.

**Audience:** You have completed Level 1. You know how to start Claude Code and run simple commands.

---

### 2.1 The mandatory workflow

Claude-socle imposes a six-step workflow for any significant development. This is not a suggestion: skipping steps consistently produces lower-quality results and introduces regressions.

```
EXPLORE -> SPECIFY -> PLAN -> TDD -> AUDIT -> COMMIT
```

Here is why each step is necessary:

**EXPLORE** (`/work:work-explore`)

Read and understand the existing code before any modification. Claude Code does not know your project by default (except what is in the current context). Exploration establishes the knowledge base needed for the following steps to be relevant.

```bash
/work:work-explore
# or with a specific focus
/work:work-explore "Understand the user management module"
```

**SPECIFY** (`/work:work-specify`)

Translate your need into structured User Stories with acceptance criteria. This step forces ambiguities to be clarified before investing time in planning and code.

```bash
/work:work-specify "Add the password reset feature"
```

The command produces a document in `specs/[feature]/spec.md` with:
- Prioritized User Stories (P1=MVP, P2=Important, P3=Nice-to-have)
- Acceptance criteria in Given/When/Then format
- Identified technical constraints

**PLAN** (`/work:work-plan`)

Propose a technical architecture before implementing. This step lists the files to create or modify, the dependencies between tasks, and the potential risks. You validate the plan before the code is written.

```bash
/work:work-plan
```

The plan is stored in `specs/[feature]/plan.md`. Do not move to the TDD step without having validated this plan.

**TDD** (`/dev:dev-tdd`)

Implement following the Red-Green-Refactor cycle: write the failing test first, then write the minimal code to make it pass, then improve the code without breaking the tests. The expected minimum coverage is 80%.

```bash
/dev:dev-tdd "Implement the password reset service"
```

The order is strict: tests first, code next. This constraint may seem counter-intuitive at first, but it forces you to clarify the specifications before coding and produces more maintainable code.

**AUDIT** (`/qa:qa-loop "score 90"`)

Verify the overall quality after implementation: security, performance, accessibility, technical debt. The `qa-loop` command runs an audit and automatically fixes issues until reaching a score of 90.

```bash
/qa:qa-loop "score 90"
```

Do not commit without having reached the target score. The audit validates what the tests do not cover: security vulnerabilities, performance issues, technical debt.

**COMMIT** (`/work:work-commit` or `/work:work-pr`)

Create a clean commit with a Conventional Commits format message, or a complete Pull Request with a description.

```bash
# Simple commit
/work:work-commit

# Full Pull Request
/work:work-pr
```

#### Workflow overview

```
/work:work-explore
        |
        v
/work:work-specify
        |
        v
/work:work-plan -----> Plan validation
        |                      |
        |               Revise if needed
        |                      |
        v<---------------------+
/dev:dev-tdd
        |
        v
/qa:qa-loop "score 90" -----> Score < 90: fix and re-audit
        |                               |
        |                               |
        v<-----------------------------+
/work:work-pr
```

#### Shortcuts for common cases

For standard tasks, full workflow commands chain all the steps automatically:

```bash
# New feature: chains the entire workflow
/work:work-flow-feature "Add the search feature"

# Bug fix: adapted workflow
/work:work-flow-bugfix "Fix the crash when loading the profile"

# Trivial change (minor refactoring, typo fix):
/work:work-quick "Rename the variable userId to user_id in auth.ts"
```

---

### 2.2 Commands: manual triggering

A **command** is a Markdown file in `.claude/commands/` that contains instructions for Claude. You trigger it explicitly with the `/` prefix.

The naming convention is `domain:domain-action`:

```bash
/work:work-explore      # "work" domain, "explore" action
/dev:dev-tdd            # "dev" domain, "tdd" action
/qa:qa-security         # "qa" domain, "security" action
/ops:ops-deploy         # "ops" domain, "deploy" action
```

The 9 available domains:

| Domain | Commands | Usage |
|---------|-----------|-------|
| `work` | Main workflow (explore, specify, plan, commit, pr...) | Development orchestration |
| `dev` | Development (tdd, api, component, debug, refactor...) | Writing code |
| `qa` | Quality (audit, security, perf, wcag...) | Verification and tests |
| `ops` | Operations (deploy, docker, ci, database...) | Infrastructure |
| `doc` | Documentation (generate, changelog, explain...) | Documentation |
| `biz` | Business (model, mvp, competitor, personas...) | Product strategy |
| `growth` | Growth (seo, analytics, landing, funnel...) | Technical marketing |
| `data` | Data (pipeline, analytics, modeling...) | Data engineering |
| `legal` | Legal (rgpd, privacy, terms...) | Compliance |

The key characteristic of a command: it shares the context of your conversation. Claude sees the entire history of the session when running a command. This allows logical chaining: explore, then plan knowing the exploration, then code knowing the plan.

Commands accept arguments:

```bash
/dev:dev-tdd "Implement email validation in UserService"
/work:work-plan "Feature: push notification system"
/qa:qa-loop "score 95"
```

---

### 2.3 Agents: isolated autonomous processing

An **agent** is a sub-process launched by Claude to run a task autonomously, in an isolated context that does not pollute your main conversation.

The difference from a command:

| Aspect | Command | Agent |
|--------|---------|-------|
| Triggering | Manual (`/cmd`) | Automatic (delegation) |
| Context | Shared with the session | Isolated (does not see the session) |
| Tools | All available | Restricted depending on the agent |
| Model | Same as the session | Haiku or Sonnet depending on the agent |

Concrete example: when you type "Do a security audit", Claude automatically delegates to the `qa-security` agent. This agent:
- Runs with the Sonnet model (optimized for this type of analysis)
- Only has access to the Read, Grep and Glob tools (read-only, impossible to modify accidentally)
- Produces a report that is reintegrated into your main conversation

```
Your conversation
      |
      | "Do a security audit"
      v
 Claude delegates
      |
      v
 [qa-security agent - isolated context]
 - Model: sonnet
 - Tools: Read, Grep, Glob only
 - Analyzes the code...
      |
      v
 Audit report
      |
      v
Your conversation
(summary of results)
```

You can also invoke agents via commands:

```bash
/qa:qa-security     # Launches the qa-security agent
/qa:qa-perf         # Launches the qa-perf agent
/work:work-explore  # Launches the work-explore agent
```

The 63 agents are grouped into the same domains as the commands. Haiku agents (22) are used for fast and economical tasks (exploration, documentation, simple audits). Sonnet agents (35) for complex analyses (security, performance, debug, architecture).

---

### 2.4 Skills: automatic behavior

A **skill** is a set of instructions that activate automatically when certain keywords are detected in your messages.

You do not have to do anything: skills trigger in the background. For example:

- Mentioning "TDD" or "test first" activates the `test-driven-development` skill: Claude will automatically follow the Red-Green-Refactor cycle
- Mentioning "commit" or "git commit" activates the `generating-commit-messages` skill: Claude will use the Conventional Commits format
- Mentioning "docker" or "containerize" activates the `docker-containerization` skill: Claude will apply Docker best practices

```
You: "I want to do TDD for this new service"
                    |
                    v
         Detection: "TDD" detected
                    |
                    v
         test-driven-development skill active
                    |
                    v
         Claude automatically applies:
         - RED: write the failing test first
         - GREEN: minimal code to pass
         - REFACTOR: improve without breaking
```

The main skills to know:

| Skill | Trigger keywords | Induced behavior |
|-------|----------------------|---------------------|
| `test-driven-development` | TDD, test first, red green | Mandatory Red-Green-Refactor cycle |
| `generating-commit-messages` | commit, git commit | Conventional Commits format |
| `creating-pull-requests` | PR, pull request, merge | Complete PR structure |
| `debugging-issues` | bug, error, crash, debug | Systematic investigation |
| `security-audit` | security, OWASP, vulnerability | OWASP Top 10 audit |
| `exploring-codebase` | explore, understand, discover | Read-only analysis |

---

### 2.5 Rules: automatic conventions

A **rule** is a set of conventions automatically applied when you work on certain types of files.

The system is based on file paths. When Claude modifies `src/components/Button.tsx`, the rules corresponding to the patterns `**/*.tsx` and `**/components/**` activate automatically. Claude then applies the TypeScript and React conventions without you having to remind it.

```
Claude modifies src/api/auth.ts
          |
          v
  Detection: the file matches
  - "**/*.ts" -> typescript rule activated
  - "**/api/**" -> api rule activated
  - "**/auth/**" -> security rule activated
          |
          v
  Claude automatically applies:
  - TypeScript strict mode, no `any`
  - REST conventions, correct HTTP codes
  - Input validation, XSS protection
```

The 30 rules of the foundation cover:
- Languages: TypeScript, Python, Go, Java, C#, Ruby, PHP, Rust, Flutter/Dart
- Frameworks: React, Next.js
- Cross-cutting domains: Testing, Security, API, Git, Workflow, Performance, Accessibility

**Priority order when several rules apply simultaneously:**

| Priority | Rule | Reason |
|----------|------|--------|
| 1 (max) | `security` | Security takes precedence over everything |
| 2 | `verification` | Mandatory verification before completion |
| 3 | `tdd-enforcement` | TDD mandatory for all code |
| 4 | Language rules | Specific conventions |
| 5 | Framework rules | Framework conventions |
| 6 | `testing` | Test standards |
| 7+ | `performance`, `accessibility`, `api`... | Optimizations and best practices |

---

### 2.6 The 9 domains: overview

Claude-socle organizes its 131 commands into 9 domains. Each domain covers an aspect of software development.

```
.claude/commands/
├── work/      # Workflow: explore, specify, plan, commit, pr, flows...
├── dev/       # Code: tdd, api, component, debug, refactor, test...
├── qa/        # Quality: audit, security, perf, wcag, review, loop...
├── ops/       # Infra: deploy, docker, ci, database, monitoring...
├── doc/       # Docs: generate, changelog, explain, onboard...
├── biz/       # Business: model, mvp, competitor, personas, pricing...
├── growth/    # Growth: seo, analytics, landing, funnel, cro...
├── data/      # Data: pipeline, analytics, modeling...
└── legal/     # Legal: rgpd, privacy-policy, terms-of-service...
```

For developers, the domains most used on a daily basis are `work`, `dev`, `qa` and `ops`. The `biz`, `growth`, `data` and `legal` domains are relevant depending on the context of your project.

---

### 2.7 Practical exercise: implement a complete feature

This exercise takes you through the entire workflow on a concrete example. Choose a project you are working on, or create an empty project.

**Scenario:** Add an email address validation function in a utility module.

**Step 1 - Explore**
```bash
/work:work-explore "Understand existing utilities and validation conventions"
```
Read the report. Identify: is there already validation logic? What is the code style used?

**Step 2 - Specify**
```bash
/work:work-specify "Add a validateEmail function in the utils module"
```
Read the generated User Stories. Verify that the acceptance criteria match your intent. Adjust if needed.

**Step 3 - Plan**
```bash
/work:work-plan
```
Examine the plan: which files will be created or modified? Are there identified risks? Validate the plan explicitly (reply "ok" or "validate the plan").

**Step 4 - Implement in TDD**
```bash
/dev:dev-tdd "Implement validateEmail according to the validated plan"
```
Observe the cycle: Claude first writes the test (which fails), then the minimal code, then refactors if needed.

**Step 5 - Audit**
```bash
/qa:qa-loop "score 90"
```
Wait for the audit completion. If issues are identified, Claude fixes them automatically. Verify the final score.

**Step 6 - Commit**
```bash
/work:work-commit
```
Read the proposed commit message. Verify that it respects the Conventional Commits format (`feat:`, `fix:`, etc.).

---

### 2.8 Decision table: which command for which situation?

| I want to... | Command | Domain |
|------------|----------|---------|
| Understand a project or module | `/work:work-explore` | work |
| Create User Stories | `/work:work-specify` | work |
| Clarify spec ambiguities | `/work:work-clarify` | work |
| Plan an implementation | `/work:work-plan` | work |
| Develop in TDD | `/dev:dev-tdd` | dev |
| Generate tests for existing code | `/dev:dev-test` | dev |
| Debug a bug | `/dev:dev-debug` | dev |
| Refactor code | `/dev:dev-refactor` | dev |
| Create a UI component | `/dev:dev-component` | dev |
| Create an API endpoint | `/dev:dev-api` | dev |
| Full audit (security + perf + a11y) | `/qa:qa-audit` | qa |
| Audit + automatic fix | `/qa:qa-loop "score 90"` | qa |
| Security audit only | `/qa:qa-security` | qa |
| Performance audit | `/qa:qa-perf` | qa |
| WCAG accessibility audit | `/qa:wcag-audit` | qa |
| Code review | `/qa:qa-review` | qa |
| Create a clean commit | `/work:work-commit` | work |
| Create a Pull Request | `/work:work-pr` | work |
| Deploy to production | `/ops:ops-deploy` | ops |
| Dockerize an application | `/ops:ops-docker` | ops |
| Configure a CI/CD | `/ops:ops-ci` | ops |
| Project health check | `/ops:ops-health` | ops |
| Generate documentation | `/doc:doc-generate` | doc |
| Explain complex code | `/doc:doc-explain` | doc |
| Full feature workflow | `/work:work-flow-feature "..."` | work |
| Full bugfix workflow | `/work:work-flow-bugfix "..."` | work |
| I don't know which command to use | `/assistant` | - |

---

### Common mistakes at Level 2

**Skipping the SPECIFY step.** Many developers go directly from EXPLORE to PLAN. User Stories force you to clarify the "what" before defining the "how". Without this step, the plan rests on unvalidated assumptions.

**Validating the plan too quickly.** The plan produced by `/work:work-plan` is a proposal. Read it carefully. Ask questions if something is not clear. This is your last opportunity to reframe before implementation.

**Writing the code before the tests in TDD.** When you use `/dev:dev-tdd`, the temptation is to ask "write the code and the tests". TDD imposes an order: failing test first, code next. If you notice that Claude writes the code before the tests, remind it explicitly: "Write the failing test first, then the minimal code."

**Committing without auditing.** The audit is not optional. It detects issues that unit tests do not cover: security vulnerabilities, accessibility issues, technical debt. Code that passes all tests can still have an audit score of 40/100.

**Confusing agent and command.** Commands are invoked with `/`. Agents activate automatically by delegation. You do not invoke an agent directly (even if some commands launch agents). The distinction becomes important when you create your own tools.

**Ignoring activated rules.** When Claude applies TypeScript or security conventions, it is not arbitrary: the foundation's rules have been designed for a specific project. Do not ask Claude to ignore these conventions without good reason.

**Sessions that are too ambitious.** If your feature requires 15 tasks or more, split it into independent sub-features. Sessions that are too long accumulate context and generate regressions. The practical rule: more than 10 files modified without an intermediate commit is a warning signal.

---

### Level 2 Checkpoint

You are ready for Level 3 (Intermediate) when:

- [ ] You have run the full workflow Explore -> Specify -> Plan -> TDD -> Audit -> Commit on a feature, even a small one
- [ ] You can explain the difference between a command, an agent, a skill and a rule
- [ ] You use the `domain:domain-action` naming convention without having to look it up
- [ ] You know the 9 domains and know which domain to look in for a given task
- [ ] You use `/assistant` when you do not know which command to use
- [ ] You have run `/qa:qa-loop` at least once and verified the audit score
- [ ] You understand why tests are written before the code in TDD

---

## Level 3 - Productivity (2h)

This level transforms your usage of Claude Code into a professional workflow. You will learn to work with the discipline of TDD, automate quality through hooks, formulate precise prompts that multiply the quality of results, and parallelize your sessions to handle several features simultaneously.

---

### 3.1 TDD with Claude Code

Test-Driven Development is not optional in claude-socle: it is a workflow constraint. The `tdd-enforcement` rule triggers automatically when you ask Claude to implement, add, create or fix code. Understanding why TDD works better with an LLM than solo is the key to this level.

#### The Red-Green-Refactor cycle in practice

```
┌─────────┐     ┌─────────┐     ┌──────────┐
│   RED   │ --> │  GREEN  │ --> │ REFACTOR │
│  Test   │     │  Code   │     │  Clean   │
│  fail   │     │  pass   │     │   up     │
└─────────┘     └─────────┘     └──────────┘
      ^                              |
      └──────────────────────────────┘
```

**RED phase**: Claude writes the tests BEFORE having the code. This is the starting signal. A test that passes immediately is a bad test -- it proves nothing.

```typescript
// RED phase: the test fails because UserService does not exist yet
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid email', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User',
      });
      expect(user.id).toBeDefined();
      expect(user.email).toBe('test@example.com');
    });

    it('should throw InvalidEmailError when email has no @', async () => {
      await expect(
        userService.createUser({ email: 'invalid', name: 'Test' })
      ).rejects.toThrow(InvalidEmailError);
    });

    it('should throw when email is empty', async () => {
      await expect(
        userService.createUser({ email: '', name: 'Test' })
      ).rejects.toThrow();
    });
  });
});
```

**GREEN phase**: Minimal code to make the tests pass. No optimization, no generalization. YAGNI (You Aren't Gonna Need It).

```typescript
// GREEN phase: minimum viable for the tests
export class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    if (!data.email || !data.email.includes('@')) {
      throw new InvalidEmailError(data.email);
    }
    return { id: generateId(), email: data.email, name: data.name };
  }
}
```

**REFACTOR phase**: Improve without breaking. If refactoring breaks the tests, `/rewind` brings back to the previous stable state. Claude Code automatically saves a checkpoint before each modification.

```typescript
// REFACTOR phase: dependency injection, extracted validation
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async createUser(data: CreateUserDto): Promise<User> {
    this.validateEmail(data.email);
    return this.userRepository.create(data);
  }

  private validateEmail(email: string): void {
    if (!email || !email.includes('@')) {
      throw new InvalidEmailError(email);
    }
  }
}
```

#### Using `/dev:dev-tdd` effectively

The `/dev:dev-tdd` command orchestrates the full cycle. It works best when you give it a precise description of the feature, not just a file name.

```bash
# Vague - Claude will have to guess the intent
/dev:dev-tdd "user service"

# Precise - Claude understands the constraints and edge cases
/dev:dev-tdd "User creation service with email validation,
  duplicate handling, and password hashing via bcrypt"
```

Claude will systematically:
1. Identify the test cases (nominal, edge cases, errors)
2. Write the tests with the Arrange-Act-Assert structure
3. Commit the tests: `git commit -m "test(scope): add tests for [feature]"`
4. Implement the minimal code
5. Refactor
6. Commit the implementation: `git commit -m "feat(scope): implement [feature]"`

#### Writing good test descriptions for Claude

The structure `it('should [behavior] when [condition]')` is mandatory. It forces you to think in terms of observable behavior rather than implementation.

```typescript
// Bad - tests the implementation, not the behavior
it('calls hashPassword method', ...)

// Good - tests the observable behavior
it('should store hashed password when user is created', ...)
it('should reject login when password does not match hash', ...)
```

The edge cases to always include in your descriptions:

| Type | Examples to mention |
|------|-----------------------|
| Boundary values | 0, -1, maximum value |
| Null / Undefined | "including when X is null" |
| Empty strings | "including empty email" |
| Empty collections | "including empty cart" |
| Network errors | "including database timeout" |

#### Coverage and verification

Claude Code configures a PostToolUse hook that automatically checks coverage after modification of test files. The target is 80% on new code.

```bash
# Run the tests with coverage
npm run test:coverage

# Tests in watch mode during development
npm run test:watch

# A single test for quick debug
npm test -- --grep "should create a user"
```

#### Exercise 3.1

Implement a function `calculateDiscount(cart: CartItem[], code: string): number` in strict TDD:
1. Start by listing all the test cases (empty cart, invalid code, expired code, percentage discount, fixed discount)
2. Run `/dev:dev-tdd "calculateDiscount with promo codes, expiration handling, empty cart"`
3. Verify that the tests fail before the implementation
4. Verify the coverage after the full cycle

---

### 3.2 Audits and quality

TDD validates that the code does what it is supposed to do. The audit validates that the code is ready for production: security, performance, accessibility, maintainability. These are two orthogonal dimensions -- code with 100% coverage can have SQL injection vulnerabilities.

#### Understanding `/qa:qa-loop` and the scoring system

`/qa:qa-loop` is the central audit command. It works in a loop: audit, fix P0/P1 issues, re-audit, until reaching the target score.

```bash
/qa:qa-loop              # Target score 90 (default)
/qa:qa-loop "score 85"   # Custom target score
/qa:qa-loop "score 95"   # Strict audit before a major release
```

The score is calculated on several dimensions:
- Security (OWASP vulnerabilities, exposed secrets, injections)
- Performance (response time, N+1 queries, bundle size)
- Accessibility (WCAG 2.1, aria, contrast)
- Maintainability (cyclomatic complexity, duplication, coupling)

#### Available audit types

| Command | Usage | Model |
|----------|-------|--------|
| `/qa:qa-audit` | Full read-only audit (security + perf + a11y) | sonnet |
| `/qa:qa-loop` | Audit + autonomous fixes in a loop | sonnet |
| `/qa:qa-review` | Quick code review, feedback without fixes | sonnet |
| `/qa:qa-security` | OWASP Top 10 security audit only | sonnet |
| `/qa:qa-perf` | Performance and Core Web Vitals audit | sonnet |
| `/qa:wcag-audit` | WCAG 2.1 accessibility audit | haiku |
| `/qa:qa-design` | UI/UX audit (100+ web design rules) | haiku |
| `/qa:qa-tech-debt` | Technical debt identification and prioritization | haiku |

The important distinction between these three commands:

```
qa-review     --> Feedback only, no modification
qa-audit      --> Full report with priorities, no modification
qa-loop       --> Audit + automatic fixes in a loop until the target score
```

#### The audit-fix loop: how it works

`/qa:qa-loop` orchestrates several agents in parallel, consolidates the reports, then automatically fixes issues by priority:

```
qa-loop launch
      |
      v
[qa-security] [qa-perf] [wcag-audit]   <- Parallel agents
      |              |          |
      v              v          v
   Report       Report    Report
      |
      v
Consolidation + score calculation
      |
      v
Score >= 90 ?
   No --> Fix P0, P1 --> Re-audit
   Yes --> Final report
```

Issues are classified by priority:
- **P0 - Critical**: security vulnerabilities, exposed data -- fixed in absolute priority
- **P1 - Important**: significant performance regressions, major accessibility errors
- **P2 - Minor**: technical debt, minor optimizations

#### When to use which command

```bash
# Before merging a standard PR
/qa:qa-review

# Before a production deployment
/qa:qa-audit   # See the issues first
/qa:qa-loop    # Then fix automatically up to 90

# Feature with auth or payment (critical)
/qa:qa-loop "score 95"

# Suspicion of a specific vulnerability
/qa:qa-security

# After a UI refactoring
/qa:qa-design
/qa:wcag-audit
```

#### Exercise 3.2

On an existing project or the claude-socle starter:
1. Run `/qa:qa-audit` and read the report without fixing anything
2. Identify the 3 most important P0/P1 issues
3. Run `/qa:qa-loop "score 85"` and observe the fix loop
4. Compare the report before and after

---

### 3.3 Hooks - Invisible automation

Each time Claude modifies a file, a chain of hooks runs automatically. These hooks are the reason claude-socle guarantees consistent quality without conscious effort on your part.

#### What is a hook and why it matters

A hook is a shell script run automatically before (PreToolUse) or after (PostToolUse) a tool is used by Claude. They are configured in `.claude/settings.json`.

```
Claude wants to modify a file
          |
          v
  [PreToolUse Hook]
  Verifies we are not on main
  Detects secrets in the content
          |
          v (if the hook passes)
  File modified
          |
          v
  [PostToolUse Hook]
  Automatically formats the code
  Verifies TypeScript types
  Runs ESLint
```

Without hooks, you would have to think about formatting, type-checking and linting after each modification. With hooks, it is invisible and automatic.

#### PreToolUse hooks: protection and validation

These hooks run BEFORE the modification. If they fail (exit code != 0), the modification is blocked.

**Main branch protection**: blocks any modification on `main` or `master`. If you try to modify a file directly on main, Claude receives an explicit error message.

```bash
# To bypass exceptionally (urgent hotfix)
ALLOW_MAIN_EDIT=1 claude
```

**Secret detection (Gitleaks)**: scans the written content before saving it. If Claude generates a file containing what looks like an API key or password, the hook blocks the write and reports the issue.

**Pre-commit tests**: when Claude runs `git commit`, this hook runs the test suite before authorizing the commit. If the tests fail, the commit is blocked. The hook also detects and repairs Husky if necessary.

```bash
# To bypass pre-commit tests in an emergency (not recommended)
SKIP_PRE_COMMIT_TESTS=1
```

**Local pre-push CI**: before `git push`, runs lint + type-check + tests. Avoids pushing code that will break CI.

```bash
SKIP_PRE_PUSH_CI=1  # To bypass if CI is already failing
```

**Command validator**: validates Bash commands against 8 risk categories: fork bombs, pipe-to-shell (`curl URL | sh`), disk destruction, privilege escalation, etc.

```bash
SKIP_COMMAND_VALIDATOR=1  # To bypass (use with caution)
```

**Destructive ops guard**: blocks `DELETE`, `DROP`, `TRUNCATE`, `rm -rf` commands without explicit confirmation.

```bash
SKIP_DESTRUCTIVE_CHECK=1  # For approved migration scripts
```

#### PostToolUse hooks: automatic quality

These hooks run AFTER each successful modification. They do not block -- they improve.

**Auto-format by language**:

| Modified file | Automatic action |
|-----------------|--------------------|
| `*.ts`, `*.tsx`, `*.js`, `*.jsx` | Prettier |
| `*.py` | Ruff / Black |
| `*.go` | gofmt |
| `*.rs` | rustfmt |
| `*.dart` | dart format |
| `*.lua` | stylua |

**TypeScript type-check**: after modification of a `.ts` or `.tsx` file, `tsc --noEmit` runs and displays type errors.

**ESLint**: JS/TS lint after modification.

**Auto-install dependencies**: if `package.json` is modified, `npm install` (or yarn/pnpm/bun depending on the config) runs automatically. Same for `pyproject.toml` (uv sync), `pubspec.yaml` (flutter pub get), `go.mod` (go mod tidy), `Cargo.toml` (cargo check).

**Coverage check**: after modification of test files, verifies that coverage stays above the threshold.

#### SessionStart hooks: context and security

At the start of each session, several hooks run:

- **Session info**: displays the project information (current branch, last commits, git status)
- **Check node_modules**: warns if `package.json` exists but `node_modules` is absent
- **Check .env**: verifies that `.env` is properly in `.gitignore`
- **Third-party hooks warning**: warns if non-standard custom hooks are detected

#### Control environment variables

| Variable | Effect |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Authorize modifications on main |
| `SKIP_PRE_COMMIT_TESTS=1` | Skip pre-commit tests |
| `SKIP_PRE_PUSH_CI=1` | Skip local pre-push CI |
| `SKIP_COMMAND_VALIDATOR=1` | Disable command validation |
| `SKIP_DESTRUCTIVE_CHECK=1` | Disable destructive protection |
| `ENABLE_RTK=1` | Enable RTK token optimization (-60-90%) |

These variables can be defined in `.claude/settings.local.json` for a persistent session, or exported in the shell for one-off use.

#### The command validator in detail

The command validator (PreToolUse on Bash) is a new feature that analyzes each Bash command before execution. It detects:

- Fork bombs: `:(){ :|:& };:`
- Pipe-to-shell: `curl URL | sh` or `wget URL | bash`
- Disk destruction: `dd if=/dev/zero`, `mkfs` on a mounted disk
- Privilege escalation: `chmod 777 /etc/`, `sudo` in risky contexts
- Potential data exfiltration

When a command is blocked, Claude receives an explanation and can propose a safer alternative.

#### Exercise 3.3

Open a Claude Code session and modify a TypeScript file. Observe what happens:
1. The PreToolUse hook checks the branch (you should be on a feature branch)
2. The modification is applied
3. The PostToolUse hook automatically formats the file with Prettier
4. The PostToolUse hook runs `tsc --noEmit`

Then try to commit with an intentionally failing test. Observe the pre-commit hook blocking.

---

### 3.4 Advanced prompting

The quality of a prompt is directly proportional to the quality of the result. Boris Cherny (creator of Claude Code) puts it this way: "The more specific and detailed the specification, the better the output."

The difference between a mediocre prompt and an effective prompt can represent a 2 to 3 factor on the quality of the produced code.

#### Specific vs vague: concrete examples

| Vague (to avoid) | Specific (prefer) |
|------------------|-----------------------|
| "Fix this bug" | "Fix the null pointer exception in `getUserById` when the user ID doesn't exist in the database" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n) by replacing the nested loop with a hash map lookup" |
| "Add error handling" | "Add try/catch for network errors in `fetchUser` with retry logic: 3 attempts, exponential backoff (1s, 2s, 4s), log each retry at warn level" |
| "Add tests" | "Add unit tests for `calculateDiscount` covering: empty cart, single item, multiple items, expired discount code, and negative quantities" |
| "Refactor this" | "Extract the email validation logic into a separate `EmailValidator` class with `isValid(email)` and `normalize(email)` methods" |
| "It doesn't work" | "The function returns `undefined` instead of the expected `User` object when I call `getUserById(123)`. Error log: [log]" |

#### Context matters: provide enough information

Claude Code has no memory between sessions (except what is in `~/.claude/memory/`). Each session starts from the context of the CLAUDE.md file and the open files. Provide context explicitly:

```
"Before making changes:
1. Read src/services/auth.ts to understand the current authentication flow
2. Read src/middleware/authenticate.ts to see how tokens are validated
3. Read src/types/user.ts for the User interface

Then, implement the password reset feature
following the existing patterns."
```

This Context Loading pattern forces Claude to understand before acting, which corresponds to the EXPLORE phase of the workflow.

#### The "Grill Me" technique

Ask Claude to challenge you BEFORE proceeding. This is particularly useful before merging an important PR or deploying to production.

```
"Grill me on these changes and don't make a PR until I pass your test."
```

Claude will then ask critical questions about your understanding, identify edge cases you have not anticipated, and ensure that you have thought about the consequences of your changes. It is a Socratic code review.

#### The "Prove It" technique

Force Claude to justify its choices with concrete evidence:

```
"Prove to me this works. Show me the diff and explain why it solves
the problem. List the edge cases you've handled and the ones you haven't."
```

Useful for critical changes (security, performance) and to deeply understand the reasoning behind an implementation.

#### The "Scrap and Redo" technique

After a first functional implementation, ask for a more elegant version:

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```

The first implementation explores the problem. The second benefits from the learnings. The result is generally cleaner, better structured, and more maintainable.

#### Effort levels: adapting reasoning depth

Claude Code supports 3 effort levels that control reasoning depth:

```bash
/effort low      # Exploration, reading files, formatting
/effort medium   # Standard implementation, fixes
/effort high     # Architecture, audit, complex refactoring, debug
```

Guide by workflow phase:

| Phase | Recommended effort | Reason |
|-------|-------------------|--------|
| `/work:work-explore` | `low` | Read-only, no deep reasoning needed |
| `/work:work-specify`, `/work:work-plan` | `high` | Important architecture decisions |
| `/dev:dev-tdd` | `medium` | Standard implementation |
| `/qa:qa-audit`, `/qa:qa-security` | `high` | Critical audit |
| `/work:work-commit` | `low` | Simple operation |

The `high` effort activates deep reasoning. Reserve it for complex tasks (architecture, audit, debug). It is useless to use it to reformat code or write a commit message.

#### Explicit verification: the quality multiplier

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." -- Boris Cherny

Always add an explicit verification step in your prompts:

```
"After the implementation:
1. Run npm test and show me the results
2. Run npm run lint and fix the warnings
3. Explain what could go wrong in production
4. List the edge cases handled and those not handled"
```

#### Exercise 3.4

Take these 3 mediocre prompts and rephrase them as effective prompts:

1. "Add pagination"
2. "Login does not work"
3. "Optimize performance"

For each prompt, specify: the file concerned, the current behavior, the expected behavior, the technical constraints, and the edge cases to cover.

---

### 3.5 Parallelism and sessions

> "The single biggest productivity unlock." -- Boris Cherny

Working on a single feature at a time with a single Claude Code session is the slowest way to develop. Git worktrees allow you to run 5+ sessions in parallel on isolated branches.

#### Git worktrees for parallel work

A worktree is a working copy of the repository in a different directory, on a different branch. Each worktree has its own git index, but shares the history.

```bash
# Create a worktree for a feature
git worktree add ../myapp-auth -b feature/auth

# Open a Claude Code session in this worktree
cd ../myapp-auth && claude --name "auth-feature"

# Meanwhile, in the main directory
cd myapp && claude --name "main-session"
```

The `--name` (or `-n`) option names the session to find it easily. Combined with worktrees, each session is isolated and identifiable.

Typical structure with 3 features in parallel:

```
myapp/           <- Main session (review, merge)
myapp-auth/      <- "auth-feature" session (feature/auth)
myapp-payment/   <- "payment-feature" session (feature/payment)
myapp-perf/      <- "perf-fixes" session (fix/performance)
```

```bash
# List active worktrees
git worktree list

# Remove a worktree after merge
git worktree remove ../myapp-auth
```

#### Context management: /compact vs /clear

The context of a Claude Code session grows over the course of exchanges. Two commands allow you to manage it:

| Command | Effect | When to use |
|----------|-------|----------------|
| `/compact` | Summarizes the context, keeps the essential | Between long workflow phases |
| `/clear` | Erases all the context | Complete topic change, new unrelated task |

The rule: prefer `/compact` over `/clear`. Compaction keeps architecture decisions, learned conventions, and important contexts. `/clear` erases everything and you start over from scratch.

Recommended moments for `/compact`:
- After a long exploration (`/work:work-explore`), before moving on to the plan
- After a detailed plan, before starting TDD
- After a long TDD cycle, before the audit

#### Quick recovery with /rewind

Claude Code automatically saves the state of the code (checkpoint) before each modification. If a refactoring breaks everything:

```bash
/rewind          # Choose a checkpoint in the history
Esc x2           # Cancel the last modification only
```

It is faster than `git stash` or `git checkout` for recent errors. Recommended in the REFACTOR phase of TDD: if the tests break after a refactoring, `/rewind` brings back to the previous GREEN state in one command.

#### Handoff between sessions

When you close a session and open a new one on the same feature, the context is lost. To facilitate the handoff:

1. Always end with a commit with a descriptive message
2. Leave a `TODO` comment or a note in the spec file if the work is incomplete
3. The automatic memory (`~/.claude/memory/`) keeps preferences and architecture decisions between sessions -- it is consulted automatically

```bash
# Best practice: commit before closing
git commit -m "feat(auth): implement login flow - WIP: session refresh pending"
```

#### Exercise 3.5

1. Create two worktrees from your project: `feature/widget-a` and `feature/widget-b`
2. Open a named Claude session in each worktree
3. In each session, launch a different implementation
4. Observe that the two branches advance independently
5. Merge the two features into main

---

### 3.6 Shortcut workflows

The full workflow Explore → Specify → Plan → TDD → Audit → Commit is the reference. But not all changes justify 6 steps. claude-socle provides shortcuts adapted to the complexity of each situation.

#### `/work:work-quick` for trivial changes

`/work:work-quick` skips the full cycle for minor changes. It is strict on the eligibility criteria.

Eligibility criteria (ALL must be satisfied):

| Criterion | Threshold |
|---------|-------|
| Modified files | 1 to 3 maximum |
| Changed lines | Less than 50 lines |
| Impact | No public API change |
| Risk | No regression risk |
| Existing tests | Already pass |

```bash
/work:work-quick "Fix the typo in the login error message"
/work:work-quick "Rename the userList variable to users in ProfilePage"
/work:work-quick "Update react-query version in package.json"
```

If during execution the criteria are no longer respected (the change is more impactful than expected), `/work:work-quick` stops and recommends switching to `/dev:dev-tdd`.

NOT eligible to work-quick: new feature, refactoring, logic bug fix, interface change, new file (except test file).

#### `/work:work-batch` for story backlogs

`/work:work-batch` sequentially executes a backlog of user stories from a PRD file, with TDD and atomic commit per story.

PRD file format:

```json
{
  "project": "my-app",
  "stories": [
    {
      "id": "US-001",
      "title": "Email validation on creation",
      "description": "The email must be valid and unique",
      "priority": "P1",
      "acceptance_criteria": [
        "Given an invalid email, When I create a user, Then an error is returned",
        "Given an already used email, When I create a user, Then a duplicate error is returned"
      ],
      "files": ["src/services/user.service.ts", "src/services/user.service.spec.ts"]
    },
    {
      "id": "US-002",
      "title": "Password hashing",
      "priority": "P1",
      "description": "Passwords must be stored in bcrypt",
      "acceptance_criteria": [
        "Given a plain password, When I create a user, Then the password is stored hashed"
      ],
      "files": ["src/services/user.service.ts"]
    }
  ]
}
```

```bash
/work:work-batch "specs/user-features.json"
```

Claude will process the stories in P1 → P2 → P3 order, apply TDD on each, and commit with `feat(scope): US-XXX description`. Progress is saved in `.claude/output/batch/progress.json` -- if the session is interrupted, the resume starts from the last incomplete story.

Safeguards:
- Maximum 10 stories per batch (beyond, split)
- Stop if 2 consecutive stories fail
- Never commit without passing tests

#### `/work:work-flow-feature` vs manual workflow

`/work:work-flow-feature` is the full workflow in a single command. It automatically chains: `work-explore` → `work-specify` → `work-plan` → `dev-tdd` → `qa-loop` → `work-pr`.

```bash
# Automated workflow
/work:work-flow-feature "Push notification system with user preferences"

# Equivalent manual workflow
/work:work-explore
/work:work-specify
/work:work-plan
/dev:dev-tdd
/qa:qa-loop "score 90"
/work:work-pr
```

When to choose the manual workflow:
- When you want to validate the plan before coding (the automated workflow can chain without a pause)
- When a specific step requires your attention
- For learning (understand what each step does)

When to use the automated workflow:
- Features well defined in the specs
- After mastering the manual workflow
- For batch work with `/work:work-batch`

#### When to skip steps (and when not to)

| Situation | Steps to skip | Mandatory steps |
|-----------|----------------|---------------------|
| Typo / rename | All except fix + verify | Verification that tests pass |
| Simple bugfix | Explore, Specify | TDD (regression test), quick audit |
| Simple feature (< 100 lines) | Specify | Explore, Plan, TDD, Audit |
| Complex feature | Nothing | Full workflow |
| Production hotfix | Plan | Explore, TDD, minimal audit, Commit |

Absolute rules independent of context:
- Never commit without the tests passing
- Never modify `main` directly (except for an approved hotfix)
- Never skip the audit for critical code (auth, payment, sensitive data)

#### Quick choice matrix

```
How many files does the change touch?
      |
      v
   1-3 files, < 50 lines, no public API
      |                    |
     Yes                  No
      |                    |
      v                    v
/work:work-quick    Is it a complete feature?
                          |               |
                         Yes             No (bug)
                          |               |
                          v               v
                   Backlog?        /work:work-flow-bugfix
                    |       |
                   Yes     No
                    |       |
                    v       v
             /work:work-batch  /work:work-flow-feature
                               (or manual workflow)
```

---

### Level 3 Wrap-up

You now have the tools to work with Claude Code in a professional way:

- **TDD**: write tests before code, Red-Green-Refactor cycle with `/dev:dev-tdd`
- **Audits**: `/qa:qa-loop` to automatically reach the target score before each merge
- **Hooks**: understand the invisible automation that guarantees quality at each modification
- **Prompting**: formulate precise prompts that multiply the quality of results
- **Parallelism**: git worktrees + named sessions to work on several features simultaneously
- **Shortcuts**: choose the workflow adapted to the complexity of the change

Level 4 (Mastery) covers advanced patterns: agent teams, fine hook configuration, custom workflows, and integration into a team environment.

## Level 4: Mastery (3h)

At this stage, you use Claude Code with ease. It is time to step out of consumer mode and move to producer mode: create your own building blocks, adapt the foundation to your context, and automate your work environment.

---

### 4.1 Creating your own skills

A **skill** is a specialized block of instructions that Claude Code can trigger automatically based on context, or that you call manually. Unlike commands, a skill runs in an isolated context (`fork`) and can be linked to an agent or called from several commands.

#### Structure of a SKILL.md file

Each skill is a `SKILL.md` file in `.claude/skills/[skill-name]/` with a mandatory YAML frontmatter:

```yaml
---
name: my-skill
description: Analyzes and optimizes slow SQL queries. Trigger when
  the user mentions slow queries, N+1, or wants to optimize a DB.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
model: sonnet
argument-hint: "[file-or-description]"
---
```

The key fields of the frontmatter:

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Unique identifier of the skill | `sql-optimizer` |
| `description` | Description + automatic trigger keywords | See above |
| `allowed-tools` | Authorized tools (least privilege principle) | `Read, Grep, Bash` |
| `context` | `fork` (isolated, recommended) or `shared` (main context) | `fork` |
| `model` | Preferred model for this skill | `haiku`, `sonnet`, `opus` |
| `argument-hint` | Hint shown to the user about expected arguments | `"[description]"` |
| `disable-model-invocation` | Prevents automatic triggering | `true` |
| `user-invocable` | Makes the skill invisible to direct user | `false` |

#### Automatic triggering

The `description` field plays a dual role: documenting the skill AND serving as a basis for automatic triggering. Claude Code analyzes the keywords of the description to know when to propose the skill. For example, the foundation's `dev-tdd` skill triggers automatically when you mention "TDD", "test first", "write tests", or ask to implement a new feature.

Examples of effective keywords in a description:

```yaml
description: React performance optimization. Trigger automatically
  when the user mentions "re-render", "memo", "React perf", "useMemo",
  "useCallback", or wants to optimize a React component.
```

#### examples/ and references/ subdirectories

For complex skills, move detailed content to sub-files:

```
.claude/skills/my-skill/
  SKILL.md          # Main instructions (< 500 lines)
  examples/
    simple-example.md
    advanced-example.md
  references/
    checklists.md
    patterns.md
```

The `SKILL.md` file stays concise and references the sub-files. This avoids exceeding the 15,000 character budget (`SLASH_COMMAND_TOOL_CHAR_BUDGET`).

#### Variables available in a skill

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[0]` | First argument |
| `$1`, `$2` | Shortcuts for arguments |
| `${CLAUDE_SESSION_ID}` | ID of the current session |

#### Dynamic context injection

Inject dynamic content at runtime with the `` !`command` `` syntax:

```markdown
## Project context

Available scripts:
!`cat package.json | jq .scripts`

Current version:
!`cat VERSION 2>/dev/null || echo "unknown"`
```

#### Exercise: create a skill for your project

Create `.claude/skills/my-deploy-check/SKILL.md` that verifies preconditions before a deployment (tests pass, no `console.log`, environment variables present). Trigger it with the words "deploy", "production rollout", "release".

---

### 4.2 Creating your own agents

An **agent** is a separate Claude Code instance with its own tools, its own model, and its own permissions. It runs in isolation and can only access the tools that you explicitly authorize.

#### Structure of an agent file

Agents are `.md` files in `.claude/agents/` with a YAML frontmatter:

```yaml
---
name: my-audit-agent
description: Specialized GDPR compliance audit. Analyzes the code to
  detect privacy violations and propose corrections.
tools: Read, Grep, Glob
model: sonnet
permissionMode: default
skills:
  - qa-security
  - legal-rgpd
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo '[GDPR-AUDIT] Analysis in progress...'"
          timeout: 5000
---
```

Agent frontmatter fields:

| Field | Description | Values |
|-------|-------------|---------|
| `name` | Agent identifier | kebab-case |
| `description` | Description + auto-triggering | Free text |
| `tools` | Authorized tools (comma separated) | `Read, Grep, Glob, Bash` |
| `model` | Model to use | `haiku`, `sonnet`, `opus` |
| `permissionMode` | Permission level | `default`, `acceptEdits` |
| `disallowedTools` | Explicitly forbidden tools | `Bash, Write` |
| `skills` | Skills to load for this agent | List of names |

Here is the structure of the foundation's `dev-debug` agent as a real example:

```yaml
---
name: dev-debug
description: Bug diagnosis and investigation.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
skills:
  - dev-debug
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo '[DEV-DEBUG] Investigation in progress...'"
          timeout: 5000
---
```

The body of the agent file must be minimal (30-55 lines): it orchestrates, the skill provides the detail. This is the foundation's agent/skill pattern.

#### Choosing the right model for an agent

| Model | Agent use case | Number in the foundation |
|--------|-------------------|---------------------|
| `haiku` | Exploration, documentation, standard generation, simple audits | 22 agents |
| `sonnet` | Complex debug, security, architecture, integration | 35 agents |
| `opus` | Reserved for critical tasks with `/effort high` | On request |

Practical rule: if the agent reads without modifying, use `haiku`. If it analyzes to propose corrections or architectural decisions, use `sonnet`.

#### Linking an agent to skills

The `skills` property in an agent's frontmatter automatically loads the skill instructions into the agent's context. An agent can load several skills:

```yaml
skills:
  - qa-security
  - qa-perf
  - legal-rgpd
```

#### Hooks in the agent frontmatter

The hooks declared in an agent's frontmatter apply only during the execution of this agent. This is distinct from the global hooks in `settings.json`.

#### Exercise: create a specialized audit agent

Create `.claude/agents/qa-rgpd.md` with the tools `Read, Grep, Glob` (no `Bash`, no `Write`), the `haiku` model, linked to the existing `legal-rgpd` skill. The description must mention "GDPR", "RGPD", "privacy", "personal data" for automatic triggering.

---

### 4.3 Creating your own rules

**Rules** are code instructions that activate automatically when a file matching the declared paths is modified. They define the conventions specific to a language, a framework, or your business domain.

#### Structure of a rule

Rules are `.md` files in `.claude/rules/` with a `paths` frontmatter:

```yaml
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# TypeScript Rules

## Strict Mode

- IMPORTANT: Strict mode enabled (`"strict": true`)
- IMPORTANT: No `any` except documented exceptional cases
- YOU MUST define interfaces for complex objects
```

The `paths` frontmatter accepts glob patterns. A rule without `paths` applies to all files (global rule). See `.claude/rules/git.md` and `.claude/rules/workflow.md` in the foundation: these are global rules without paths.

#### Effective path patterns

| Pattern | Target |
|---------|-------|
| `**/*.ts` | All TypeScript files |
| `**/api/**` | Any `api/` subfolder |
| `**/components/**` | React components |
| `**/auth/**` | Authentication code |
| `**/migrations/**` | DB migration files |
| `**/docker-compose*` | Docker Compose files |

#### Priority system

When several rules match the same file, they all apply simultaneously according to this priority order:

| Priority | Rule | Reason |
|----------|------|--------|
| 1 (max) | `security` | Security takes precedence over everything |
| 2 | `verification` | Mandatory validation before completion |
| 3 | `tdd-enforcement` | TDD mandatory |
| 4 | Language (`typescript`, `python`...) | Language conventions |
| 5 | Framework (`react`, `nextjs`...) | Framework conventions |
| 6 | `testing` | Test standards |
| 7 | `performance`, `accessibility` | Optimizations |

Example: modifying `src/components/Button.tsx` simultaneously activates `typescript`, `react`, `accessibility`, `performance`, `verification`, and `tdd-enforcement`.

#### Writing effective directives

Claude Code pays more attention to certain keywords in rules:

| Keyword | Weight | Usage |
|---------|-------|-------|
| `IMPORTANT:` | High | Critical rules to respect |
| `YOU MUST` | Very high | Absolute obligation |
| `NEVER` | Very high | Prohibition |
| `ALWAYS` | High | To do systematically |
| `WARNING:` | Medium | Point of attention |

Use tables for conventions: they are more readable than bulleted lists and take fewer tokens.

#### Exercise: create a project rule

Create `.claude/rules/api-conventions.md` with the paths `**/api/**` and `**/routes/**`. Define your API conventions: error response format, input validation, HTTP codes used, endpoint naming.

---

### 4.4 Customizing hooks

Hooks allow you to automate actions before or after each Claude Code operation. The foundation includes 25+ preconfigured hooks; you can add or modify their behavior.

#### Anatomy of a hook in settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "description": "Slack notification after each commit",
        "matcher": "Bash(git commit:*)",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'curl -s -X POST $SLACK_WEBHOOK -d \"{\\\"text\\\":\\\"Commit done in $(basename $PWD)\\\"}\"'",
            "async": true,
            "onFailure": "ignore",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

#### Hook types

| Type | Description | Use case |
|------|-------------|-------------|
| `command` | Runs a bash script | Formatting, validation, notification |
| `prompt` | Evaluates via a Haiku LLM | Smart contextual decisions |
| `http` | Sends a JSON POST to a URL | Webhooks, external integrations |

#### Available events and when to use them

| Event | Trigger | Typical usage |
|-------|-------------|---------------|
| `PreToolUse` | Before a tool | Validation, protection, security |
| `PostToolUse` | After a tool | Formatting, type-check, notification |
| `SessionStart` | Session start | Display info, env verification |
| `SessionEnd` | Session end | Logging, cleanup |
| `PreCompact` | Before compaction | Save context |
| `PostCompact` | After compaction | Summary available |
| `TeammateIdle` | Idle agent (teams) | Re-assignment of tasks |

#### The matcher system

The `matcher` filters hooks by tool or by regex pattern:

```json
"matcher": "Edit|Write"           // File edit or creation
"matcher": "Bash"                  // Any bash command
"matcher": "Bash(git commit:*)"    // Only git commit
"matcher": "Bash(npm run:*)"       // Any npm run command
```

#### onFailure: block or ignore

| onFailure | Effect | When to use |
|-----------|-------|------------------|
| `"block"` | Blocks the action if the hook fails | Security, critical validation |
| `"ignore"` | Continues even if the hook fails | Logging, notification |
| (absent) | Continues by default | Non-critical actions |

IMPORTANT: security hooks (gitleaks, main protection, pre-commit tests) must use `"onFailure": "block"`. Logging and notification hooks must use `"async": true` and `"onFailure": "ignore"`.

#### Asynchronous hooks

The `"async": true` property runs the hook in the background without blocking Claude Code:

```json
{
  "type": "command",
  "command": "bash -c 'echo \"$(date) - Session ended\" >> /tmp/claude-sessions.log'",
  "async": true,
  "onFailure": "ignore"
}
```

Rule: security = synchronous, logging/notification = asynchronous.

#### Control environment variables

The foundation exposes variables to disable hooks if necessary:

| Variable | Disabled hook |
|----------|----------------|
| `ALLOW_MAIN_EDIT=1` | Main branch protection |
| `SKIP_PRE_COMMIT_TESTS=1` | Pre-commit tests |
| `SKIP_COMMAND_VALIDATOR=1` | Command security validation |
| `SKIP_PRE_PUSH_CI=1` | Local CI before push |
| `SKIP_DESTRUCTIVE_CHECK=1` | Destructive operation protection |
| `ENABLE_RTK=1` | Enable RTK token optimization |

Configure these variables in `settings.local.json` (gitignored) for your personal environment.

#### Exercise: add a custom hook

Add a `PostToolUse` hook that automatically checks test coverage after each modification of a source file (non-test). It must display a warning if coverage falls below 80% but not block.

---

### 4.5 MCP Servers

The **Model Context Protocol (MCP)** allows Claude Code to interact with external services: databases, APIs, project management tools. It is an extension of the available context for Claude.

#### Configuration in .mcp.json

All MCP servers are defined in `.mcp.json` at the root of the project. In the foundation, all are disabled by default (`"enabled": false`) for security:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "GitHub integration (issues, PRs, repos)",
      "enabled": false
    }
  }
}
```

To activate a server, set `"enabled": true` and configure the environment variables in your `.env` (never directly in `.mcp.json`).

#### Available servers in the foundation

| Server | Usage | Env token |
|---------|-------|-----------|
| `filesystem` | Advanced filesystem access | - |
| `memory` | Persistent memory between sessions | - |
| `fetch` | HTTP requests to external APIs | - |
| `github` | GitHub issues, PRs, repos | `GITHUB_TOKEN` |
| `postgres` | PostgreSQL queries and migrations | `DATABASE_URL` |
| `sqlite` | Local SQLite database | - |
| `puppeteer` | Browser automation, screenshots | - |
| `slack` | Bug search, team threads | `SLACK_BOT_TOKEN` |
| `sentry` | Error analysis and monitoring | `SENTRY_AUTH_TOKEN` |
| `bigquery` | Direct analytics queries | `GOOGLE_APPLICATION_CREDENTIALS` |
| `linear` | Project management and issues | `LINEAR_API_KEY` |
| `notion` | Documentation and knowledge bases | `NOTION_API_KEY` |

Boris Cherny particularly recommends Slack, Sentry and BigQuery to eliminate manual back-and-forth between Claude Code and these tools.

#### MCP Channels (Research Preview)

With `claude --channels`, compatible servers (Slack, Sentry, Linear) can push messages into your session in real time: Sentry alert during dev, Slack message from a colleague, Linear update.

#### Security considerations

- NEVER put credentials directly in `.mcp.json`
- Use `${VARIABLE}` to reference environment variables
- Add `.env` to `.gitignore`
- Only activate the servers you need
- The `.mcp.json` file is versioned in git: check its content before each commit

#### Exercise: configure and use an MCP server

Activate the `github` server in `.mcp.json`. Configure `GITHUB_TOKEN` in your `.env`. Test by asking Claude Code to list the open issues of your repository.

---

### 4.6 Output Styles

**Output Styles** allow you to adapt the format of Claude Code's responses to your context: learning, code review, report production, debugging.

#### The 10 available styles

| Style | Command | Use case |
|-------|----------|-------------|
| `teaching` | `/output-style teaching` | Learning, training, onboarding |
| `explanatory` | `/output-style explanatory` | Understand the why, deep debug |
| `concise` | `/output-style concise` | Experienced dev, quick fix |
| `technical` | `/output-style technical` | Architecture, technical decisions |
| `review` | `/output-style review` | Code review, PR, audits |
| `emoji` | `/output-style emoji` | Presentations, client documentation |
| `minimal` | `/output-style minimal` | Terminal, logs, CI/CD |
| `structured` | `/output-style structured` | Reports, formal analyses |
| `debug` | `/output-style debug` | Methodical debugging |
| `metrics` | `/output-style metrics` | Performance, benchmarks |

The `explanatory` style is recommended by Boris Cherny for learning phases: it forces Claude to explain the reasoning behind each decision.

#### Create a project-specific style

Create `.claude/output-styles/my-style.md`:

```markdown
---
name: My Team Style
description: Standardized format for team reports
keep-coding-instructions: true
---

# Team Report Style

## Principles
- Always start with a 3-line executive summary
- Use tables for comparisons
- End with the recommended concrete actions

## Format
[Description of the format with examples]
```

Activate with `/output-style my-style`.

---

## Level 5: Expert (2h)

This level is intended for users who want to understand the foundation's architecture decisions, optimize their costs, master experimental features, and contribute to the project.

---

### 5.1 Architecture decisions

#### Why claude-socle is designed this way

The foundation addresses a concrete problem: by default, Claude Code starts without context, without conventions, and without workflow. Each session starts from scratch. The foundation solves this by providing a complete and maintainable configuration.

The three design constraints:

1. **Minimalism of the base context**: the `CLAUDE.md` file only loads 175 lines per session (before optimization: 1,322 lines). Everything else is loaded on demand via `@imports`.

2. **Modularity**: each building block (command, agent, skill, rule, hook) is independent and replaceable. You can remove all `growth-*` agents if you do not need them.

3. **Security by default**: `.mcp.json` disables everything, hooks block `git push --force`, secret detection is enabled on each write.

#### Commands vs Agents vs Skills: design principles

| Concept | Context | Tools | Triggering | When to use it |
|---------|----------|--------|---------------|------------------|
| **Command** | Shared | All | Manual (`/cmd`) | Interactive workflow, direct modifications |
| **Agent** | Isolated | Restricted | Automatic or manual | Analysis, repetitive task, isolation |
| **Skill** | Fork or shared | Defined | Automatic | Specialized instructions, detailed content |

An agent must have a minimal body (30-55 lines) and delegate to the skill. A skill can go up to 500 lines but must move bulky content into `examples/` and `references/`.

#### The ratio and its importance

The foundation currently contains: 131 commands, 54 skills, 63 agents, 30 rules (indicative numbers, verify with `.claude/`). This ratio reflects a philosophy: commands are the main entry point, agents are specialized and constrained, skills provide the substance.

#### CLAUDE.md and @imports

The foundation's `CLAUDE.md` only includes two always-loaded imports:

```
@docs/reference/best-practices.md
@docs/reference/project-structures.md
```

The other references (commands, agents-catalog, hooks, skills, advanced-features) are documented in the `## Documentation and References` table but are NOT auto-imported. Claude reads them on demand. This distinction is fundamental to mastering costs.

To see the active imports in a session: `/memory`.

---

### 5.2 Token optimization

Tokens are the main cost source with Claude Code. Optimization has two dimensions: reduce consumption per session, and choose the right model for each task.

#### Understanding consumption

Each Claude Code session consumes tokens for:
- The initial context (CLAUDE.md + imports + active rules)
- Each exchange (prompt + response)
- File reads (each `Read` adds tokens to the context)
- Bash command outputs

The context grows over the course of the session and never decreases (except with `/compact` or `/clear`).

#### RTK: 60-90% reduction on command outputs

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) is a CLI proxy that compresses command outputs before they reach the LLM context.

Installation:
```bash
brew install rtk
# or
cargo install --git https://github.com/rtk-ai/rtk
```

Activation in the foundation (disabled by default):

```json
{
  "env": {
    "ENABLE_RTK": "1"
  }
}
```

The foundation's `PreToolUse` hook automatically rewrites commands if RTK is installed:
- `git status` becomes `rtk git status` (~10 tokens instead of ~200)
- `cargo test` becomes `rtk cargo test` (-90% on test outputs)

Measurement commands:
```bash
rtk gain       # See the savings achieved
rtk discover   # Identify unoptimized commands
```

#### /compact and /clear strategies

| Command | Effect | When to use |
|----------|-------|----------------|
| `/compact` | Summarizes the context, keeps decisions and conventions | Between long phases (Explore → Plan → TDD) |
| `/clear` | Erases all the context | Complete topic change, new unrelated task |

Prefer `/compact` over `/clear`: compaction keeps the essential (decisions made, detected patterns) while `/clear` erases everything and makes you start over from scratch.

#### Effort levels for cost management

| Level | Command | Approximate tokens | When |
|--------|----------|---------------------|-------|
| `low` | `/effort low` | Minimum | Exploration, reading, commits |
| `medium` | `/effort medium` | Standard | Standard dev, fixes |
| `high` | `/effort high` | High | Architecture, audit, refactoring, debug |

#### Choosing the right model

| Model | Optimal usage | Cost impact |
|--------|---------------|-------------|
| Haiku | Simple tasks, standard generation, documentation | Very low |
| Sonnet | Analysis, debug, decisions | Medium |
| Opus 4.7 | Critical audit, complex architecture, `/effort high` | High |

Best practice: use Haiku for the 70% of routine tasks (test generation, documentation, standard components), Sonnet for the 25% that require reasoning, and reserve Opus for the 5% critical.

#### Measuring your costs

```bash
/ops:ops-cost    # Token consumption report of the session
ccusage          # Consumption history (external CLI tool)
```

---

### 5.3 Agent Teams

Agent Teams is an experimental feature that allows you to coordinate several Claude Code instances working in parallel, with inter-agent communication.

#### Activation

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Prerequisites: Claude Code >= 2.1.19, and optionally `tmux` for split-panes mode.

#### Operating modes

| Mode | Description | When |
|------|-------------|-------|
| `auto` (default) | Automatic choice based on the task | Standard usage |
| `in-process` | Agents in the same process | Local dev, debugging |
| `tmux` | Agents in separate tmux panes | Visualization, long work |

#### Usage

```bash
/work:work-team "Implement JWT authentication:
- Agent 1: API routes (POST /auth/login, POST /auth/refresh)
- Agent 2: validation middleware
- Agent 3: integration tests"
```

#### Inter-agent communication

Agents in the same team can send each other messages via the `TeammateIdle` hook. When an agent finishes its task and becomes idle, the orchestrator can assign it a new task or consolidate the results.

#### When teams help vs when they hurt

Agent Teams is beneficial for:
- Independent parallelizable tasks (frontend + backend + tests in parallel)
- Cross-reviews (one agent codes, another critiques)
- Batch processing (analyze 20 files simultaneously)

Agent Teams hurts if:
- Tasks are sequential and dependent
- The cost of coordination exceeds the gain in parallelism
- The task is simple and quick (overhead not justified)

For parallelizable tasks without inter-agent communication, prefer classic sub-agents via the `parallel-agents` or `git-worktrees` skill.

---

### 5.4 Full automated workflows

The foundation provides workflow commands that automatically chain several phases of the cycle Explore → Specify → Plan → TDD → Audit → Commit.

#### /work:work-flow-feature end-to-end

```bash
/work:work-flow-feature "Add a push notification system"
```

This workflow automatically runs:
1. Exploration of existing code (work-explore)
2. Specification creation (work-specify)
3. Planning (work-plan, with validation before coding)
4. TDD (dev-tdd, Red-Green-Refactor cycle)
5. Quality audit (qa-loop "score 90")
6. Commit and PR (work-pr)

#### /work:work-flow-bugfix

```bash
/work:work-flow-bugfix "500 error on /api/users when the email contains uppercase letters"
```

Pipeline: debug (dev-debug) → regression test (dev-test) → fix → quick audit (qa-review) → commit (work-commit with issue reference).

#### /work:work-flow-release

```bash
/work:work-flow-release "v2.1.0"
```

Handles semantic versioning, CHANGELOG update, git tags, and creation of the GitHub release. Includes a verification that all tests pass before tagging.

#### /work:work-batch

```bash
/work:work-batch "backlog.json"
```

Processes a backlog of User Stories in batch. Each story goes through the full workflow. Useful for sprints with many small tasks.

#### Build a custom workflow

Create `.claude/commands/my-workflow.md` by chaining the instructions:

```markdown
# My Project Workflow

Custom workflow for the X project's features.

## Steps

1. Explore the code with focus on $ARGUMENTS
2. Verify the conventions in `docs/conventions.md`
3. Implement in TDD with minimum 85% coverage
4. Verify GDPR compliance if processing personal data
5. Create the PR with the team's template

IMPORTANT: Never skip the GDPR step for user profile features.
```

---

### 5.5 Contributing to the foundation

#### Understanding the validation system

The `scripts/validate.sh` script verifies the integrity of the configuration. It validates:
- The presence of mandatory files
- The format of YAML frontmatters
- The consistency of counts (commands, agents, skills)
- Basic security (no secrets in committed files)

```bash
./scripts/validate.sh .              # Validate the current directory
./scripts/validate.sh --format json  # JSON output for CI
./scripts/validate.sh --format score # Score output only
```

#### Adding a command

1. Create `.claude/commands/[category]/my-command.md`
2. Follow the standard structure (title, description, `$ARGUMENTS` context, instructions, expected output)
3. Update the count in `docs/reference/commands.md`
4. Test with `/[category]:my-command "test"`

#### Adding an agent

1. Create `.claude/agents/my-agent.md` with a complete frontmatter
2. Keep the body minimal (30-55 lines), create a skill if needed
3. Choose `haiku` or `sonnet` depending on complexity
4. Update `docs/reference/agents-catalog.md` (entry + count)
5. Verify the synchronized counters via `./scripts/validate-counts.sh`

#### Adding a skill

1. Create `.claude/skills/my-skill/SKILL.md`
2. Stay under 500 lines; move into `examples/` if needed
3. Define precise trigger keywords in `description`
4. Update `docs/reference/skills-catalog.md`

#### The CI pipeline

The foundation's CI pipeline runs in order:
1. **Lint**: shellcheck on bash scripts, yamllint on YAML files
2. **Security**: gitleaks to detect accidentally committed secrets
3. **Validate-counts**: verifies that the counts in the documentation match the real files

If `validate-counts` fails, update the reference files before pushing.

#### Contribution workflow

```bash
# 1. Create a branch
git checkout -b feature/my-specialized-agent

# 2. Develop in TDD
/dev:dev-tdd "add the my-specialized-agent agent"

# 3. Validate
./scripts/validate.sh .

# 4. Audit
/qa:qa-loop "score 90"

# 5. PR
/work:work-pr
```

---

### 5.6 Pro Checklist

You have completed the 5 levels. Here is the operational summary.

#### Recommended daily workflow

**Start of day:**
```bash
claude -n "sprint-$(date +%Y%m%d)"  # Named session
/ops:ops-health                       # Quick health check
```

**New task:**
```
1. /work:work-explore    (understand before touching)
2. /work:work-specify    (clarify before planning)
3. /work:work-plan       (plan before coding)
4. /dev:dev-tdd          (tests before code)
5. /qa:qa-loop "score 90"  (audit before committing)
6. /work:work-pr         (commit + push + PR)
```

**End of session:**
```bash
/compact    # Between long phases
/clear      # New unrelated task
```

#### Settings to configure once

In `.claude/settings.local.json` (gitignored, personal):

```json
{
  "env": {
    "ENABLE_RTK": "1",
    "SKIP_PRE_PUSH_CI": "0"
  }
}
```

In `~/.claude/settings.json` (global, all projects):
- Default model preferences
- Personal hooks (notifications, logging)

#### When to deviate from the workflow

The Explore → Specify → Plan → TDD → Audit → Commit workflow is optimal for medium-sized features. There are legitimate exceptions:

| Situation | Adaptation |
|-----------|------------|
| Typo fix, comment correction | `/work:work-quick` directly |
| Critical production bug | `/work:work-flow-bugfix` without Specify or Plan |
| Throwaway prototype | TDD optional, but audit always |
| Pure refactoring (no logic) | No need for Specify, lighter TDD |

The fundamental rule: never skip the **Audit** before a commit on main, and never code without having **read** the existing code first.

#### Continuous improvement

```bash
/qa:qa-kaizen    # Identifies improvement patterns in your workflow
/qa:qa-audit     # Periodic full audit (security + GDPR + a11y + perf)
/ops:ops-deps    # Vulnerabilities in dependencies
```

Revisit your `CLAUDE.md` after each sprint: add the emerging conventions, the discovered pitfalls, the team patterns. A good `CLAUDE.md` is a living document that reflects the team's collective intelligence.

#### The 10 principles of the Pro

1. Read before writing (`/work:work-explore` first)
2. Specify before planning, plan before coding
3. Tests before code, always (TDD)
4. Give Claude a way to verify its work (hooks, test suites)
5. Audit before committing (`/qa:qa-loop "score 90"`)
6. Atomic commits: 1 commit = 1 logical change
7. Never commit secrets (gitleaks is there for that)
8. Be specific in prompts (anti-pattern: "fix this bug")
9. Adapt the model to the task (Haiku for routine, Sonnet for complex)
10. Iterate in short loops rather than in giant sessions (max 10 files per session)

---

## Next steps

You have completed the learning path. Move on to practice:

| Next step | Description |
|----------------|-------------|
| [Hands-on tutorials](/docs/tutorials) | 10 progressive tutorials to practice (15 min to 4h) |
| [TaskFlow capstone project](/docs/tutorials/complete-project) | Build a mini-SaaS from A to Z with the full workflow |
| [Guides by technology](/docs/guides) | Deepen your stack (Web, Mobile, API, Python, Go, Infra) |
| [Extending the foundation](/docs/guides/extending-guide) | Create your own rules, skills and agents |
