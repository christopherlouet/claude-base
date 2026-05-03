---
sidebar_position: 16
title: "Skills (Claude Code 2.1+)"
description: "In addition to commands, the project includes **54 Skills** in `.claude/skills/`:"
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Skills (Claude Code 2.1+)

In addition to commands, the project includes **<!-- count:skills -->54<!-- /count --> Skills** in `.claude/skills/`:

## Core skills
| Skill | Automatic trigger | Context |
|-------|-------------------|---------|
| `dev-tdd` | "TDD", "test first", "write the tests" | fork |
| `work-commit` | "commit", "commit message" | fork |
| `dev-debug` | "bug", "error", "debug" | fork |
| `qa-review` | "review", "code review" | fork |
| `qa-security` | "security audit", "OWASP" | fork |
| `work-plan` | "plan", "architecture" | fork |
| `work-explore` | "explore", "understand the code" | fork |
| `work-brainstorm` | "brainstorm", "ideation", "alternatives" | fork |
| `work-pr` | "PR", "pull request" | fork |
| `dev-api` | "API", "endpoint", "REST" | fork |

## Additional skills
| Skill | Automatic trigger | Context |
|-------|-------------------|---------|
| `dev-flutter` | "Flutter", "widget", "BLoC" | fork |
| `dev-supabase` | "Supabase", "auth", "RLS" | fork |
| `dev-react-perf` | "React perf", "re-render", "memo" | fork |
| `ops-docker` | "Docker", "container", "Dockerfile" | fork |
| `ops-ci` | "CI/CD", "GitHub Actions", "pipeline" | fork |
| `ops-database` | "schema", "migration", "index" | fork |
| `ops-monitoring` | "logs", "metrics", "traces" | fork |
| `doc-generate` | "document", "README", "JSDoc" | fork |
| `doc-changelog` | "changelog", "release notes" | fork |
| `dev-refactor` | "refactor", "clean code", "restructure" | fork |
| `dev-error-handling` | "error handling", "exceptions", "error boundary" | fork |
| `dev-graphql` | "GraphQL", "resolver", "schema" | fork |
| `ops-mobile-release` | "App Store", "Play Store", "Fastlane" | fork |
| `data-pipeline` | "ETL", "Airflow", "dbt" | fork |
| `qa-perf` | "optimize", "latency", "TTFB" | fork |
| `dev-prompt-engineering` | "prompt", "instruction", "few-shot", "LLM" | fork |
| `qa-e2e` | "E2E", "Playwright", "Cypress", "user journey" | fork |
| `feature-flags` | "feature flag", "A/B test", "progressive deployment" | fork |
| `ops-infra-code` | "Terraform", "IaC", "OpenTofu", "module", "state" | fork |
| `ops-proxmox` | "Proxmox", "PVE", "Proxmox VM", "LXC", "PBS" | fork |
| `ops-opnsense` | "OPNsense", "firewall", "NAT", "DHCP", "Unbound" | fork |
| `qa-tech-debt` | "technical debt", "tech debt", "refactoring priority" | fork |
| `ops-standup` | "standup", "briefing", "what happened" | fork |
| `ops-ci-fix` | "ci broken", "fix ci", "workflows failing" | fork |
| `qa-design` | "design audit", "UI/UX", "user interface" | fork |
| `api-mocking` | "mock API", "MSW", "test without backend" | fork |
| `state-management` | "state", "Redux", "Zustand", "store" | fork |
| `dev-document` | "PDF", "DOCX", "XLSX", "PPTX", "document", "report" | fork |
| `growth-cro` | "conversion", "CRO", "signup flow", "onboarding", "paywall" | fork |
| `parallel-agents` | "parallel", "concurrent", "fan-out", "multi-agents" | fork |
| `agent-teams` | "agent team", "swarm", "agent team", "parallel agents" | fork |
| `session-handoff` | "handoff", "resume", "session transfer", "context" | fork |
| `git-worktrees` | "worktree", "parallel dev", "simultaneous branches" | fork |
| `qa-chrome` | "Chrome", "visual test", "DOM debugging", "capture" | fork |
| `dev-frontend-design` | "UI design", "landing page", "art direction", "fonts" | fork |
| `dev-shadcn` | "shadcn", "shadcn/ui", "Radix", "React components" | fork |
| `dev-nextjs` | "Next.js", "App Router", "Server Components", "RSC", "Server Actions" | fork |
| `dev-auth` | "auth", "login", "signup", "OAuth", "better-auth", "NextAuth", "Lucia", "2FA" | fork |
| `dev-prisma` | "Prisma", "schema.prisma", "migrate", "ORM", "Accelerate" | fork |
| `dev-i18n` | "i18n", "l10n", "translation", "locale", "next-intl", "react-i18next", "vue-i18n", "flutter_localizations" | fork |
| `writing-skills` | "create skill", "new skill", "write a skill" | fork |
| `web-scraping` | "scrape", "crawl", "extract web", "Firecrawl", "structured data" | fork |
| `work-quick` | "quick", "fast", "rapid" — trivial change (&lt; 50 LOC, 1-3 files) | fork |
| `work-batch` | "batch", "backlog", "PRD", "user stories in series" — sequential execution | fork |

## Skills Configuration

Each skill defines:
- **allowed-tools**: Tools authorized for the skill
- **context: fork**: Execution in an isolated context (recommended)

Skills are triggered automatically by Claude based on context.

## Skills Best Practices

### Size and Budget
- SKILL.md &lt; 500 lines (offload bulky content into reference files)
- Description budget: 15k characters max (`SLASH_COMMAND_TOOL_CHAR_BUDGET`)
- Use support files: `examples/`, `scripts/`, `reference.md`

### Complete frontmatter
```yaml
---
name: my-skill
description: Short description of the skill
allowed-tools: Read, Grep, Glob, Bash
context: fork
disable-model-invocation: true   # Do not trigger automatically
user-invocable: false             # Background-only skill
argument-hint: "[description]"    # Hint for arguments
model: sonnet                     # Preferred model (haiku, sonnet, opus)
agent: my-agent                   # Associated agent
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo validation"
---
```

### Variable substitutions
| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[N]` | Argument at index N (0-based) |
| `$N` | Shortcut for `$ARGUMENTS[N]` |
| `$\{CLAUDE_SESSION_ID\}` | ID of the current session |

### Dynamic Context Injection
Inject dynamic content into a skill with the syntax:
```
!`command`
```
Example: `` !`cat package.json | jq .scripts` `` injects the npm scripts into the skill's context.
