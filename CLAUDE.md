# claude-base Project

> Claude Code configuration template for an optimal workflow: Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit

## Verification and effort — the two things that change the work

- **Give yourself a way to verify.** Every change ships with the cheapest check that can fail:
  a command (`npm run lint`, `typecheck`) for simple work, the test suite for moderate, a browser or
  simulator for complex. A change nobody can check is not finished.
- **Match reasoning depth to the task**: `low` to read code · `medium` for a standard feature ·
  `high` to design, audit or debug deeply · `xhigh` for critical architecture and security ·
  `max` for the single hardest problem of a session, never as a default. Set it with `/effort`.

Everything else about working with Claude Code — model tiers and prices, memory, worktrees,
`/rewind`, `/recap`, prompt caching — is reference, and lives in
[`docs/reference/best-practices.md`](docs/reference/best-practices.md); project layouts by stack live
in [`docs/reference/project-structures.md`](docs/reference/project-structures.md). Both are consulted
on demand rather than carried into every session.

## Mandatory Workflow: Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit

1. **EXPLORE** (`/work:work-explore`) - Read and understand the code BEFORE modifying
1b. **BRAINSTORM** (`/work:work-brainstorm`) - _(optional)_ Structured ideation, explore alternatives before specifying
2. **SPECIFY** (`/work:work-specify`) - Prioritized User Stories (P1=MVP), acceptance criteria (Given/When/Then)
3. **PLAN** (`/work:work-plan`) - Architecture, files, tasks per User Story, risks
4. **TDD** (`/dev:dev-tdd`) - Tests BEFORE code, Red-Green-Refactor cycle, 80%+ coverage
5. **AUDIT** (`/qa:qa-loop "score 90"`) - Adaptive audit + fix loop until score 90
6. **COMMIT** (`/work:work-commit` or `/work:work-pr`) - Conventional Commits, reference issues

## Code Conventions

- **TypeScript**: strict mode, no `any`, interfaces for complex objects. Details in `.claude/rules/typescript.md`
- **Naming**: camelCase (vars/functions), PascalCase (classes/components), SCREAMING_SNAKE (constants), kebab-case (files)
- **Tests**: 80%+ coverage, no mocks except external deps, edge cases mandatory. Details in `.claude/rules/testing.md`
- **Security**: validate inputs, escape outputs, parameterized queries. Details in `.claude/rules/security.md`
- **Design**: art direction via `Style:` in the project's CLAUDE.md (terminal, cockpit, vitality, editorial, glass, signal). Details in `.claude/rules/design-style.md`
- **When several rules apply** they all apply at once; on conflict the order is `security` → `verification` → `tdd-enforcement` → language → framework → `testing` → perf/a11y/design → interface conventions → process guardrails. The full catalogue lives in `.claude/rules/README.md`, scoped to that directory.

### Secrets management
- IMPORTANT: Never commit secrets (.env, credentials, API keys)
- Use environment variables, placeholders in examples
- MCP servers off by default: `.mcp.json` ships empty (`{}`) — enable one by copying its block from `.mcp.json.example` (there is no per-server `enabled` flag)
- Avoid `curl URL | sh`, prefer download + verify + execute

## Documentation and References

| Reference | Path |
|-----------|------|
| Available commands (the 106 slash commands) | `docs/CHEATSHEET.md` — by intent; `README.md` has the by-domain overview |
| Shell commands per stack (npm, flutter, pytest…) | `docs/reference/commands.md` |
| Agents/commands catalog | `docs/reference/agents-catalog.md` |
| Configured hooks | `docs/reference/hooks-reference.md` |
| Available skills | `docs/reference/skills-catalog.md` |
| Advanced features | `docs/reference/advanced-features.md` |
| Quick decision by intent | `docs/CHEATSHEET.md` (dedicated section) |
| Recipes by stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, AI/LLM, Business) | `docs/STACK-RECIPES.md` |
| Team Guide | `docs/guides/TEAM-GUIDE.md` |
| Prompting Guide | `docs/guides/PROMPTING-GUIDE.md` |
| Troubleshooting Guide | `docs/guides/TROUBLESHOOTING-GUIDE.md` |
| Foundation Extension Guide | `docs/guides/EXTENDING-GUIDE.md` |
| Novice to Pro Path | `website/docs/guides/learning-path.md` |

Setup: `./bin/claude-base init --simple .`

## Default Happy Path (Semantic Routing)

Any request **without an explicit slash command** automatically benefits from the repo context (branch, modified files, LOC diff, personal memory) injected by the `UserPromptSubmit` hook (`scripts/hooks/prompt-context.sh`). This context includes a routing hint to `/assistant-auto` which semantically picks the right workflow based on the detected intent + size.

- Trivial intent + diff < 50 LOC + 1-3 files -> `/work:work-quick`
- Standard feature / bugfix -> `/work:work-flow-feature` or `/work:work-flow-bugfix`
- Pre-prod audit -> `/qa:qa-loop "score 90"` or `/qa:qa-security`
- Multi-stories backlog -> `/work:work-batch`

Disable: `SKIP_PROMPT_CONTEXT=1`. An explicit slash command always short-circuits routing.

## Recommended Workflows

| Situation | Command |
|-----------|---------|
| Ideation / brainstorm | `/work:work-brainstorm "idea"` |
| New feature | `/work:work-flow-feature "description"` |
| Bug fix | `/work:work-flow-bugfix "description"` |
| New release | `/work:work-flow-release "v2.0.0"` |
| Product launch | `/work:work-flow-launch "my SaaS"` |
| Full audit | `/qa:qa-audit` |
| Audit + fix loop | `/qa:qa-loop` (score 90 by default) |
| Safe deployment | `/ops:ops-deploy` |
| Agent team | `/work:work-team "description"` |
| Trivial change | `/work:work-quick "description"` |
| Batch of stories | `/work:work-batch "prd.json"` |
| Cost tracking | `/ops:ops-cost` |
| Morning standup | `/ops:ops-standup` |
| Broken CI | `/ops:ops-ci-fix` |
| Cloud review (large PR) | `/code-review ultra` |
| Autonomously converge a PR (auto-fix CI + nits) | `/autofix-pr` |
| Session recap | `/recap` |
| Reduce permission prompts | `/fewer-permission-prompts` |

Manual workflow: `/work:work-explore` → (`/work:work-brainstorm`) → `/work:work-specify` → `/work:work-plan` → `/dev:dev-tdd` → `/qa:qa-loop "score 90"` → `/work:work-pr`

## Anti-patterns to Avoid

One home, one list: `.claude/rules/workflow.md` — a global rule, so it is already here. Keeping a
second copy in this file bought nothing and the two had already drifted apart (measured: 7 of 13
bullets duplicated, 3 more only here).
