---
sidebar_position: 1
title: "Skills"
description: "Catalog of 53 auto-triggered skills"
---

import Stats from '@site/src/components/Stats';
import { SkillGrid } from '@site/src/components/SkillCard';
import SkillCard from '@site/src/components/SkillCard';

# Skills Catalog

> **53 skills** auto-triggered by keywords

<Stats items={[
  { number: 53, label: 'Fork Skills' },
  { number: 0, label: 'Shared Skills' },
  { number: 53, label: 'Total' },
]} />

## What is a Skill?

**Skills** are auto-triggered behaviors:

- **Automatic triggering**: Activated by keywords in the conversation
- **Configurable context**: Fork (isolated) or Shared (shared)
- **Restricted tools**: Limited access via `allowed-tools`
- **Transparency**: The user sees when a skill is activated

## Skills by context

### Fork (53 skills)

Skills with isolated context.

| Skill | Description | Keywords |
|-------|-------------|-----------|
| [`agent-teams`](/docs/skills/agent-teams) | Multi-agent team orchestration with native Agent T... | agent, teams, audit-team |
| [`api-mocking`](/docs/skills/api-mocking) | API mock configuration for tests. Trigger when the... | api, mocking, mock api |
| [`data-pipeline`](/docs/skills/data-pipeline) | ETL/ELT pipeline design. Trigger when the user wan... | data, pipeline |
| [`dev-api`](/docs/skills/dev-api) | Develop and document a REST or GraphQL API. Use wh... | dev, api, field1 |
| [`dev-auth`](/docs/skills/dev-auth) | Modern web auth implementation (better-auth, Lucia... | dev, auth, user can edit if owner |
| [`dev-debug`](/docs/skills/dev-debug) | Debug and resolve problems. Use when the user has ... | dev, debug, quick fix for now |
| [`dev-document`](/docs/skills/dev-document) | Document generation (PDF, DOCX, XLSX, PPTX). Trigg... | dev, document |
| [`dev-error-handling`](/docs/skills/dev-error-handling) | Error handling strategy. Trigger when the user wan... | dev, error, handling |
| [`dev-flutter`](/docs/skills/dev-flutter) | Flutter development with Clean Architecture and BL... | dev, flutter |
| [`dev-frontend-design`](/docs/skills/dev-frontend-design) | Distinctive UI design with strong art direction. T... | dev, frontend, design |
| [`dev-graphql`](/docs/skills/dev-graphql) | GraphQL API development. Trigger when the user wan... | dev, graphql |
| [`dev-i18n`](/docs/skills/dev-i18n) | Internationalization (i18n) and localization (l10n... | dev, i18n, d'accord |
| [`dev-nextjs`](/docs/skills/dev-nextjs) | Next.js development (App Router, Server Components... | dev, nextjs, use client |
| [`dev-prisma`](/docs/skills/dev-prisma) | Development with Prisma ORM (schema, migrations, t... | dev, prisma, prisma —  |
| [`dev-react-perf`](/docs/skills/dev-react-perf) | React/Next.js performance optimization. Trigger wh... | dev, react, perf |
| [`dev-refactor`](/docs/skills/dev-refactor) | Code refactoring to improve quality. Trigger when ... | dev, refactor |
| [`dev-shadcn`](/docs/skills/dev-shadcn) | Integration and customization of shadcn/ui (copy-p... | dev, shadcn |
| [`dev-supabase`](/docs/skills/dev-supabase) | Backend development with Supabase. Trigger when th... | dev, supabase, supabase —  |
| [`dev-tdd`](/docs/skills/dev-tdd) | TDD development with Red-Green-Refactor cycle. Use... | dev, tdd, as a reference |
| [`doc-changelog`](/docs/skills/doc-changelog) | CHANGELOG maintenance following Keep a Changelog. ... | doc, changelog |
| [`doc-generate`](/docs/skills/doc-generate) | Technical documentation generation. Trigger when t... | doc, generate |
| [`feature-flags`](/docs/skills/feature-flags) | Feature flags and toggles management. Trigger when... | feature, flags, feature flag |
| [`git-worktrees`](/docs/skills/git-worktrees) | Using git worktrees for parallel development. Trig... | git, worktrees, parallel sessions |
| [`growth-cro`](/docs/skills/growth-cro) | Conversion rate optimization (CRO). Trigger when t... | growth, cro, how |
| [`ops-ci`](/docs/skills/ops-ci) | CI/CD pipeline configuration. Trigger when the use... | ops |
| [`ops-ci-fix`](/docs/skills/ops-ci-fix) | Autonomous diagnosis and repair of failing CI/CD p... | ops, fix |
| [`ops-database`](/docs/skills/ops-database) | Database schema design. Trigger when the user want... | ops, database |
| [`ops-docker`](/docs/skills/ops-docker) | Docker and Docker Compose containerization. Trigge... | ops, docker |
| [`ops-infra-code`](/docs/skills/ops-infra-code) | Infrastructure as Code with Terraform/OpenTofu. Tr... | ops, infra, code |
| [`ops-mobile-release`](/docs/skills/ops-mobile-release) | Publishing apps to the App Store and Google Play. ... | ops, mobile, release |
| [`ops-monitoring`](/docs/skills/ops-monitoring) | Application instrumentation for monitoring. Trigge... | ops, monitoring |
| [`ops-opnsense`](/docs/skills/ops-opnsense) | OPNsense configuration via Terraform. Trigger for ... | ops, opnsense |
| [`ops-proxmox`](/docs/skills/ops-proxmox) | Proxmox VE infrastructure with Terraform (VMs, LXC... | ops, proxmox, pve |
| [`ops-standup`](/docs/skills/ops-standup) | Cross-repo morning briefing. Aggregation of recent... | ops, standup, no activity |
| [`parallel-agents`](/docs/skills/parallel-agents) | Orchestration of parallel agents to maximize effic... | parallel, agents |
| [`qa-chrome`](/docs/skills/qa-chrome) | Visual tests and browser debugging via Chrome. Use... | chrome, claude in chrome |
| [`qa-design`](/docs/skills/qa-design) | UI/UX design audit and verification of web best pr... | design, invalid field, image |
| [`qa-e2e`](/docs/skills/qa-e2e) | End-to-end tests with Playwright or Cypress. Trigg... | e2e, end-to-end, end-to-end test |
| [`qa-perf`](/docs/skills/qa-perf) | Application performance optimization. Trigger when... | perf |
| [`qa-review`](/docs/skills/qa-review) | Perform a thorough code review. Use when the user ... | review |
| [`qa-security`](/docs/skills/qa-security) | Perform a security audit based on OWASP. Use when ... | security |
| [`qa-tech-debt`](/docs/skills/qa-tech-debt) | Technical debt management and prioritization. Trig... | tech, debt, technical debt |
| [`session-handoff`](/docs/skills/session-handoff) | Context transfer between AI sessions. Trigger when... | session, handoff |
| [`state-management`](/docs/skills/state-management) | State management patterns and implementation. Trig... | state, management |
| [`web-scraping`](/docs/skills/web-scraping) | Clean LLM-ready web scraping via Firecrawl (scrape... | web, scraping, extract data from ... |
| [`work-batch`](/docs/skills/work-batch) | Sequential execution of user stories from a PRD fi... | work, batch |
| [`work-brainstorm`](/docs/skills/work-brainstorm) | Structured ideation before specification. Transfor... | work, brainstorm, i have a vague idea |
| [`work-commit`](/docs/skills/work-commit) | Generates clear commit messages following Conventi... | work, commit, add |
| [`work-explore`](/docs/skills/work-explore) | Explore and understand an existing codebase. Use w... | work, explore |
| [`work-plan`](/docs/skills/work-plan) | Plan the implementation of a feature. Use when the... | work, plan |
| [`work-pr`](/docs/skills/work-pr) | Create a complete and well-documented Pull Request... | work, fix bug |
| [`work-quick`](/docs/skills/work-quick) | Quick workflow for trivial changes (single-file fi... | work, quick |
| [`writing-skills`](/docs/skills/writing-skills) | Guide for creating new skills for the Claude Code ... | writing, skills |



## Card view

<SkillGrid>
  <SkillCard
    name="agent-teams"
    description="Multi-agent team orchestration with native Agent Teams. Trigger when the user wa"
    keywords={["agent","teams","audit-team"]}
    context="fork"
    href="/docs/skills/agent-teams"
  />
  <SkillCard
    name="api-mocking"
    description="API mock configuration for tests. Trigger when the user wants to mock APIs, use "
    keywords={["api","mocking","mock api","msw"]}
    context="fork"
    href="/docs/skills/api-mocking"
  />
  <SkillCard
    name="data-pipeline"
    description="ETL/ELT pipeline design. Trigger when the user wants to create data flows, trans"
    keywords={["data","pipeline"]}
    context="fork"
    href="/docs/skills/data-pipeline"
  />
  <SkillCard
    name="dev-api"
    description="Develop and document a REST or GraphQL API. Use when the user wants to create an"
    keywords={["dev","api","field1","string"]}
    context="fork"
    href="/docs/skills/dev-api"
  />
  <SkillCard
    name="dev-auth"
    description="Modern web auth implementation (better-auth, Lucia, NextAuth/Auth.js, Clerk, Sup"
    keywords={["dev","auth","user can edit if owner","unknown email"]}
    context="fork"
    href="/docs/skills/dev-auth"
  />
  <SkillCard
    name="dev-debug"
    description="Debug and resolve problems. Use when the user has a bug, an error, an unexpected"
    keywords={["dev","debug","quick fix for now","let's just try changing x"]}
    context="fork"
    href="/docs/skills/dev-debug"
  />
  <SkillCard
    name="dev-document"
    description="Document generation (PDF, DOCX, XLSX, PPTX). Trigger when the user wants to crea"
    keywords={["dev","document"]}
    context="fork"
    href="/docs/skills/dev-document"
  />
  <SkillCard
    name="dev-error-handling"
    description="Error handling strategy. Trigger when the user wants to implement error handling"
    keywords={["dev","error","handling"]}
    context="fork"
    href="/docs/skills/dev-error-handling"
  />
  <SkillCard
    name="dev-flutter"
    description="Flutter development with Clean Architecture and BLoC. Trigger when the user want"
    keywords={["dev","flutter"]}
    context="fork"
    href="/docs/skills/dev-flutter"
  />
  <SkillCard
    name="dev-frontend-design"
    description="Distinctive UI design with strong art direction. Trigger when the user wants to "
    keywords={["dev","frontend","design","because it looks nice"]}
    context="fork"
    href="/docs/skills/dev-frontend-design"
  />
  <SkillCard
    name="dev-graphql"
    description="GraphQL API development. Trigger when the user wants to create schemas, resolver"
    keywords={["dev","graphql"]}
    context="fork"
    href="/docs/skills/dev-graphql"
  />
  <SkillCard
    name="dev-i18n"
    description="Internationalization (i18n) and localization (l10n) for web and mobile applicati"
    keywords={["dev","i18n","d'accord"]}
    context="fork"
    href="/docs/skills/dev-i18n"
  />
</SkillGrid>

[See all skills...](#skills-by-context)

---

## See also

- [Architecture](/docs/intro/architecture) - Understand Commands vs Agents vs Skills
- [Commands](/docs/commands) - Manual commands
- [Agents](/docs/agents) - Autonomous sub-agents
