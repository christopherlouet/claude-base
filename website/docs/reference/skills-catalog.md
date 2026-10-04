---
sidebar_position: 16
title: "Skills (Claude Code 2.1+)"
description: "In addition to commands, the project includes **53 Skills** in `.claude/skills/`:"
tags:
  - "reference"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Skills (Claude Code 2.1+)

In addition to commands, the project includes **<!-- count:skills -->53<!-- /count --> Skills** in `.claude/skills/`:

**Trigger column.** A phrase list means the skill auto-loads when the conversation
matches it. **manual only** means the opposite: the skill carries
`disable-model-invocation: true`, so the model cannot load it — not on a phrase match, and
not from inside the same-named command either. Only you can start it, by running the slash
command shown. Pinned by `tests/skills-catalog-drift.bats`, so a row and its frontmatter
cannot drift apart.

## Core skills
| Skill | Trigger | Context |
|-------|-------------------|---------|
| `dev-tdd` | "TDD", "test first", "write the tests" | inline |
| `work-commit` | **manual only** — run `/work-commit` | inline |
| `dev-debug` | "bug", "error", "debug" | inline |
| `qa-review` | "review", "code review" | fork |
| `qa-security` | "security audit", "OWASP" | fork |
| `work-plan` | **manual only** — run `/work-plan` | inline |
| `work-explore` | **manual only** — run `/work-explore` | fork |
| `work-brainstorm` | **manual only** — run `/work-brainstorm` | inline |
| `work-pr` | **manual only** — run `/work-pr` | inline |
| `dev-api` | "API", "endpoint", "REST" | inline |

## Additional skills
| Skill | Trigger | Context |
|-------|-------------------|---------|
| `dev-flutter` | "Flutter", "widget", "BLoC" | inline |
| `dev-supabase` | "Supabase", "auth", "RLS" | inline |
| `dev-react-perf` | "React perf", "re-render", "memo" | inline |
| `ops-docker` | **manual only** — run `/ops-docker` | inline |
| `ops-ci` | **manual only** — run `/ops-ci` | inline |
| `ops-database` | **manual only** — run `/ops-database` | inline |
| `ops-monitoring` | **manual only** — run `/ops-monitoring` | inline |
| `doc-generate` | **manual only** — run `/doc-generate` | fork |
| `doc-changelog` | **manual only** — run `/doc-changelog` | fork |
| `dev-refactor` | "refactor", "clean code", "restructure" | inline |
| `dev-error-handling` | "error handling", "exceptions", "error boundary" | inline |
| `dev-graphql` | "GraphQL", "resolver", "schema" | inline |
| `ops-mobile-release` | "App Store", "Play Store", "Fastlane" | inline |
| `data-pipeline` | "ETL", "Airflow", "dbt" | inline |
| `qa-perf` | "optimize", "latency", "TTFB" | inline |
| `qa-e2e` | "E2E", "Playwright", "Cypress", "user journey" | inline |
| `feature-flags` | "feature flag", "A/B test", "progressive deployment" | inline |
| `ops-infra-code` | "Terraform", "IaC", "OpenTofu", "module", "state" | inline |
| `ops-proxmox` | "Proxmox", "PVE", "Proxmox VM", "LXC", "PBS" | inline |
| `ops-opnsense` | "OPNsense", "firewall", "NAT", "DHCP", "Unbound" | inline |
| `qa-tech-debt` | "technical debt", "tech debt", "refactoring priority" | fork |
| `ops-standup` | "standup", "briefing", "what happened" | fork |
| `ops-ci-fix` | "ci broken", "fix ci", "workflows failing" | inline |
| `qa-design` | "design audit", "UI/UX", "user interface" | fork |
| `api-mocking` | "mock API", "MSW", "test without backend" | inline |
| `state-management` | "state", "Redux", "Zustand", "store" | inline |
| `dev-document` | "PDF export", "invoice", "report job", "generate DOCX/XLSX/PPTX" from app code | inline |
| `growth-cro` | "conversion", "CRO", "signup flow", "onboarding", "paywall" | inline |
| `parallel-agents` | "parallel", "concurrent", "fan-out", "multi-agents" | inline |
| `agent-teams` | "agent team", "swarm", "agent team", "parallel agents" | inline |
| `session-handoff` | "handoff", "resume", "session transfer", "context" | inline |
| `git-worktrees` | "worktree", "parallel dev", "simultaneous branches" | inline |
| `qa-chrome` | **manual only** — run `/qa-chrome` | inline |
| `dev-frontend-design` | "UI design", "landing page", "art direction", "fonts" | inline |
| `dev-shadcn` | "shadcn", "shadcn/ui", "Radix", "React components" | inline |
| `dev-nextjs` | "Next.js", "App Router", "Server Components", "RSC", "Server Actions" | inline |
| `dev-auth` | "auth", "login", "signup", "OAuth", "better-auth", "NextAuth", "Lucia", "2FA" | inline |
| `dev-prisma` | "Prisma", "schema.prisma", "migrate", "ORM" — only while no `prisma-*` vendor skill is installed | inline |
| `dev-i18n` | "i18n", "l10n", "translation", "locale", "next-intl", "react-i18next", "vue-i18n", "flutter_localizations" | inline |
| `writing-skills` | "create skill", "new skill", "write a skill" | inline |
| `web-scraping` | "scrape", "crawl", "extract web", "Firecrawl", "structured data" | fork |
| `work-quick` | "quick", "fast", "rapid" — trivial change (&lt; 50 LOC, 1-3 files) | inline |
| `work-batch` | "batch", "backlog", "PRD", "user stories in series" — sequential execution | fork |

## Skills Configuration

Each skill's frontmatter may carry:
- **allowed-tools**: Tools pre-approved for the skill's turn (grants, never restricts). The foundation declares none — see [Pre-approving tools](/docs/concepts/customization#pre-approving-tools-allowed-tools)
- **context**: absent (the default) = the skill runs inline, in the conversation; `context: fork` = a sub-agent that sees none of it, for a self-contained job only (with `background: false`)

Skills are triggered automatically by Claude based on context — except those marked **manual only**
in the tables above, which carry `disable-model-invocation: true` and can be started by you alone.

## Skill overrides (CLI 2.1.129+)

Bundled skills can be selectively suppressed at the settings level via the `skillOverrides` key in `.claude/settings.json` or `.claude/settings.local.json`. Three modes are accepted:

| Mode | Effect |
|------|--------|
| `off` | The skill does not load and is not invocable. |
| `user-invocable-only` | Automatic triggering is disabled; the skill remains available via explicit `/skill-name` invocation. |
| `name-only` | The skill name is preserved in the catalog without loading its body — useful when the name is referenced elsewhere but a vendor alternative should take over the work. |

When to reach for it: a vendor-published skill duplicates the depth of a bundled one (e.g., a vendor framework's official skill replaces the foundation's general-purpose equivalent). Setting the bundled skill to `user-invocable-only` lets the vendor skill auto-trigger while keeping the bundled one as a manual fallback.

Note on the foundation's preset filter — each preset's `foundation.skills.drop[]` (blacklist) or `foundation.skills.keep[]` (whitelist, mutually exclusive with `drop[]`, enforced by `validate-presets.sh`) array operates at a different layer: it filters skills out at `claude-base init` time, before they are ever installed in the project. `skillOverrides` operates at session start on already-installed skills. The two mechanisms are complementary and can be combined.

Refer to the upstream Claude Code changelog for the canonical JSON shape and any future modes added to the setting; this section names the modes shipped at 2.1.129 and describes their intent, not their evolving syntax.

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
context: fork                     # only for a self-contained job; omit = inline
background: false                 # with fork: wait for the result in the same turn
disable-model-invocation: true   # Do not trigger automatically
user-invocable: false             # Background-only skill
argument-hint: "[description]"    # Hint for arguments
model: sonnet                     # forked skills only: inline, it switches the session model
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
| `${CLAUDE_SESSION_ID}` | ID of the current session |

### Dynamic Context Injection
Inject dynamic content into a skill with the syntax:
```
!`command`
```
Example: `` !`cat package.json | jq .scripts` `` injects the npm scripts into the skill's context.
