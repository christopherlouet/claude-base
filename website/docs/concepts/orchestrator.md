---
sidebar_position: 2
title: Orchestrator (/assistant)
description: Single entry point that orchestrates commands, agents and skills
---

# Orchestrator (/assistant)

> The intelligent entry point that guides you to the right resources

## What is the Orchestrator?

The **orchestrator** is the single entry point of claude-base. It analyzes your request, detects your project context, and points you to the most appropriate commands, agents and skills.

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLAUDE-BASE FOUNDATION                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  COMMANDS   │  │   AGENTS    │  │   SKILLS    │             │
│  │    (123)    │  │    (59)     │  │    (42)     │             │
│  │             │  │             │  │             │             │
│  │ Invocation  │  │ Delegation  │  │ Activation  │             │
│  │   manual    │  │  automatic  │  │  automatic  │             │
│  │   /xxx      │  │  by Claude  │  │ by context  │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  TEMPLATES  │  │    RULES    │  │   HOOKS     │             │
│  │    (3)      │  │    (24)     │  │    (26)     │             │
│  │             │  │             │  │             │             │
│  │   File      │  │ Conventions │  │ Automation  │             │
│  │ structures  │  │   by path   │  │  pre/post   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Two available modes

| Command | Mode | Behavior |
|---------|------|----------|
| `/assistant` | **Guide** | Analyze → Recommend → Wait for confirmation |
| `/assistant-auto` | **Automatic** | Analyze → Execute the workflow directly |

### Guide mode (`/assistant`)

For **new users** or when you want to **validate** before executing:

```bash
/assistant "Add an authentication feature"

# Claude analyzes and proposes:
# → Recommended workflow: /work:work-flow-feature
# → "Do you want me to launch this workflow?"
# → Waits for your confirmation
```

### Automatic mode (`/assistant-auto`)

For **advanced users** who want **immediate execution**:

```bash
/assistant-auto "Add an authentication feature"

# Claude analyzes and executes directly:
# → Detects: new feature
# → Launches: /work:work-flow-feature "Add an authentication feature"
```

## Automatic context detection

The orchestrator automatically detects your environment:

| Indicator | Project type | Recommended commands |
|-----------|--------------|----------------------|
| `package.json` + React/Next/Vue | **Web Frontend** | `/dev:dev-component`, `/dev:dev-hook`, `/dev:dev-react-perf` |
| `pubspec.yaml` + Flutter | **Mobile** | `/dev:dev-flutter`, `/dev:dev-supabase`, `/qa:qa-mobile` |
| `package.json` + Express/Fastify/NestJS | **Node API** | `/dev:dev-api`, `/dev:dev-graphql`, `/dev:dev-trpc` |
| `requirements.txt` / `pyproject.toml` | **Python** | `/dev:dev-api`, `/dev:dev-tdd` |
| `go.mod` | **Go** | `/dev:dev-api`, `/dev:dev-tdd` |
| `init.lua` / `.config/nvim` | **Neovim** | `/dev:dev-neovim`, `/qa:qa-neovim` |
| Airflow/dbt/Spark | **Data** | `/data:data-pipeline`, `/data:data-modeling` |
| `Dockerfile` / `docker-compose.yml` | **DevOps** | `/ops:ops-docker`, `/ops:ops-k8s` |
| Proxmox / `bpg/proxmox` provider | **Infrastructure** | `/ops:ops-proxmox`, `/ops:ops-infra-code` |

## Quick decision guide

```
┌────────────────────────────────────────────────────────────────────────┐
│ I WANT TO...                            →  USE                         │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│ UNDERSTAND                                                             │
│ Explore a codebase                      →  /work:work-explore          │
│ Discover a new project                  →  /doc:doc-onboard            │
│ Understand complex code                 →  /doc:doc-explain            │
│                                                                        │
│ PLAN                                                                   │
│ Create a specification                  →  /work:work-specify          │
│ Plan an implementation                  →  /work:work-plan             │
│ Define an MVP                           →  /biz:biz-mvp                │
│                                                                        │
│ DEVELOP                                                                │
│ Write code with tests                   →  /dev:dev-tdd                │
│ Create a React/Vue component            →  /dev:dev-component          │
│ Create a REST API                       →  /dev:dev-api                │
│ Create a Flutter screen                 →  /dev:dev-flutter            │
│ Fix a bug                               →  /dev:dev-debug              │
│                                                                        │
│ VERIFY                                                                 │
│ Code review                             →  /qa:qa-review               │
│ Security audit                          →  /qa:qa-security             │
│ Full audit                              →  /qa:qa-audit                │
│                                                                        │
│ DELIVER                                                                │
│ Create a commit                         →  /work:work-commit           │
│ Create a PR                             →  /work:work-pr               │
│ Publish a release                       →  /ops:ops-release            │
│                                                                        │
│ DEPLOY                                                                 │
│ Dockerize                               →  /ops:ops-docker             │
│ Infrastructure as Code                  →  /ops:ops-infra-code         │
│ CI/CD                                   →  /ops:ops-ci                 │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Workflows by project type

### Web (React/Next.js/Vue)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-component → /dev:dev-tdd → /qa:qa-review → /work:work-pr
```

### Mobile (Flutter)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
```

### Backend API (Node/Python/Go)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-api → /dev:dev-tdd → /qa:qa-security → /doc:doc-api-spec → /work:work-pr
```

### Proxmox infrastructure

```
/work:work-explore → /ops:ops-proxmox → /ops:ops-monitoring → /ops:ops-backup
```

## Sub-Agents activated automatically

The orchestrator knows the <!-- count:agents -->45<!-- /count --> specialized agents and activates them based on context:

| Detected context | Activated agent | Model |
|------------------|-----------------|-------|
| "Explore the code" | `work-explore` | haiku |
| "Security audit", "OWASP" | `qa-security` | sonnet |
| "Performance", "Core Web Vitals" | `qa-perf` | sonnet |
| "Accessibility", "WCAG" | `wcag-audit` | haiku |
| "Bug", "Debug" | `dev-debug` | sonnet |
| "Flutter", "Widget" | `dev-flutter` | sonnet |
| "Terraform", "IaC" | `ops-infra-code` | sonnet |
| "Proxmox", "VM", "LXC" | `ops-proxmox` | sonnet |
| "Docker", "Container" | `ops-docker` | haiku |

```
User: "Run a security audit"
     │
     ▼
Claude detects: security → delegates to qa-security agent
     │
     ▼
qa-security agent (isolated context, read-only)
     │
     ▼
Result returned to the main conversation
```

## Skills triggered automatically

The <!-- count:skills -->53<!-- /count --> skills activate based on keywords in the conversation:

| Keywords | Activated skill | Action |
|----------|-----------------|--------|
| "TDD", "test first" | `dev-tdd` | Red-Green-Refactor cycle |
| "commit", "message" | `work-commit` | Conventional Commits |
| "review", "code review" | `qa-review` | In-depth review |
| "PR", "pull request" | `work-pr` | Structured PR |
| "Terraform", "IaC" | `ops-infra-code` | Infrastructure as Code |
| "Proxmox", "PVE" | `ops-proxmox` | Proxmox management |
| "Docker", "Dockerfile" | `ops-docker` | Containerization |

## Decision flow

```
User: "/assistant I want to fix a login bug"
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 1. REQUEST ANALYSIS                 │
    │    - Keywords: "fix", "bug"         │
    │    - Domain: authentication         │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 2. PROJECT DETECTION                │
    │    - package.json detected → Web    │
    │    - React detected → Frontend      │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 3. RECOMMENDATION                   │
    │    - Workflow: /work:work-flow-bugfix │
    │    - Or manual steps:               │
    │      /work:work-explore → /dev:dev-debug │
    │      → /dev:dev-test → /work:work-pr │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 4. PROPOSAL TO THE USER             │
    │    With explanations and options    │
    └─────────────────────────────────────┘
```

## When to use the Orchestrator?

### Use `/assistant` (guide mode) when:

- You are **new** to claude-base
- You don't know **which command** to use
- You want to **validate** the workflow before execution
- You are switching **project type** (Web → Mobile for example)
- You want an **overview** of the available options

### Use `/assistant-auto` (automatic mode) when:

- You are **familiar** with claude-base
- You want **immediate execution** without confirmation
- You are doing **repetitive** tasks (features, bugfixes)
- You prefer **speed** over validation

### Use direct commands when:

- You already know the exact command
- You want a fast, precise action
- You are in the middle of a workflow

## Automatic mapping (`/assistant-auto`)

| Your request contains... | Executed workflow |
|--------------------------|-------------------|
| feature, add, create | `/work:work-flow-feature` |
| bug, fix, error | `/work:work-flow-bugfix` |
| release, version, tag | `/work:work-flow-release` |
| launch, MVP, product | `/work:work-flow-launch` |
| security audit, OWASP | `/qa:qa-security` |
| full audit, quality | `/qa:qa-audit` |
| explore, understand | `/work:work-explore` |
| commit | `/work:work-commit` |
| PR, pull request | `/work:work-pr` |
| tests, TDD | `/dev:dev-tdd` |
| refactoring, clean up | `/dev:dev-refactor` |
| debug | `/dev:dev-debug` |
| Docker, container | `/ops:ops-docker` |
| CI/CD, pipeline | `/ops:ops-ci` |

## Usage examples

### New feature

```bash
/assistant "I want to add a push notification system"

# Orchestrator response:
# Project type: Mobile (Flutter detected)
# Recommended workflow:
# 1. /work:work-explore - Understand the current architecture
# 2. /work:work-specify - Specify the User Stories
# 3. /work:work-plan - Plan the implementation
# 4. /dev:dev-flutter - Create the widgets
# 5. /dev:dev-supabase - Configure the backend
# 6. /qa:qa-mobile - Test on devices
# 7. /work:work-pr - Create the PR
```

### Bug fix

```bash
/assistant "The application crashes at login"

# Orchestrator response:
# Detected situation: Critical bug
# Recommended command: /work:work-flow-bugfix
# Or manual workflow:
# 1. /work:work-explore - Locate the problem
# 2. /dev:dev-debug - Investigate the cause
# 3. /dev:dev-test - Write a regression test
# 4. /work:work-commit - Commit the fix
```

### General question

```bash
/assistant "How does authentication work in this project?"

# Orchestrator response:
# Request type: Exploration/Understanding
# Recommended command: /work:work-explore or /doc:doc-explain
# Automatically activated agent: work-explore (haiku)
```

## Relationship with other concepts

```
                    /assistant (Orchestrator)
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
      ┌─────────┐    ┌─────────┐    ┌─────────┐
      │COMMANDS │    │ AGENTS  │    │ SKILLS  │
      │         │    │         │    │         │
      │ Manual  │    │  Auto   │    │  Auto   │
      │  /xxx   │    │ delegate│    │ keyword │
      └─────────┘    └─────────┘    └─────────┘
           │               │               │
           └───────────────┴───────────────┘
                           │
                    ┌──────┴──────┐
                    │   RULES     │
                    │   HOOKS     │
                    │  TEMPLATES  │
                    └─────────────┘
```

The orchestrator is the **conductor** that:
- **Understands** your request
- **Picks** the right instruments (commands, agents, skills)
- **Directs** the workflow consistently

## Best practices

1. **Start with `/assistant`** if you are new (guide mode)
2. **Switch to `/assistant-auto`** once familiar with the workflows
3. **Be descriptive** in your requests ("I want to..." rather than just "auth")
4. **Mention the context** if relevant ("for the mobile app", "in production")
5. **Follow the proposed workflows** for optimal results

---

## See also

- [Commands](/docs/concepts/commands) - Manual commands
- [Agents](/docs/concepts/agents) - Autonomous sub-agents
- [Skills](/docs/concepts/skills) - Auto-triggered skills
- [Reference /assistant](/docs/commands/other/assistant) - Guide mode (with confirmation)
- [Reference /assistant-auto](/docs/commands/other/assistant-auto) - Automatic mode (direct execution)
