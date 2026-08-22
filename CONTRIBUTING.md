# Contributing to claude-base

Thanks for considering a contribution. This guide explains how to participate effectively.

## Language Policy

**All contributions must be in English** — pull requests, issues, commit messages, code comments, and documentation.

If you've started drafting a PR or issue in French, we'll politely ask you to re-submit in English. We know this adds friction; the goal is a coherent, internationally accessible repository. If translation is a barrier, use a translator and we'll polish on review.

## Prerequisites

- Node.js >= 20
- npm >= 10
- Git
- [Bats](https://github.com/bats-core/bats-core) (for tests)
- [ShellCheck](https://www.shellcheck.net/) (for shell script linting)

## Setting up your environment

```bash
# Clone the repo
git clone https://github.com/christopherlouet/claude-base.git
cd claude-base

# Install the documentation site dependencies
cd website && npm install && cd ..

# Smoke-check that everything works
./scripts/doctor.sh
```

## Project structure

```
.claude/
  commands/    # 106 commands (source of truth)
  agents/      # 44 sub-agents
  skills/      # 53 skills
  rules/       # 32 contextual rules
  templates/   # Specification templates
  settings.json # Hooks and permissions
website/       # Docusaurus site (generated docs)
scripts/       # Utility scripts and CI
tests/         # Bats tests
```

The files under `.claude/` are the **source of truth**. The docs under `website/docs/` are **generated** from those files.

## Contribution workflow

### 1. Create a branch

```bash
git checkout -b feature/my-feature
# or
git checkout -b fix/my-fix
```

Branches follow the convention: `feature/xxx`, `fix/xxx`, `refactor/xxx`.

### 2. Make your changes

- **New command**: create under `.claude/commands/[category]/`
- **New agent**: create under `.claude/agents/`
- **New skill**: create under `.claude/skills/[name]/SKILL.md`
- **New rule**: create under `.claude/rules/`

### 3. Regenerate the documentation

```bash
cd website
npm run generate
```

### 4. Run the tests

```bash
# Full test suite
./scripts/test.sh

# Counter validation
./scripts/validate-counts.sh

# Shell script linting
./scripts/lint.sh
```

### 5. Commit

Commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(commands): add dev-xxx command
fix(agents): correct qa-security model
docs(rules): update typescript rule
chore(deps): bump docusaurus to 3.8
test(scripts): add validate-counts tests
```

Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`.

### 6. Open a Pull Request

```bash
# Push the branch
git push -u origin feature/my-feature
```

A PR should include:
- A short title (< 70 characters)
- A description that covers context and changes
- Passing tests (green CI)

## Conventions

### File naming

| Type | Convention | Example |
|------|------------|---------|
| Commands | `kebab-case.md` | `dev-tdd.md` |
| Agents | `kebab-case.md` | `qa-security.md` |
| Skills | `kebab-case/SKILL.md` | `dev-tdd/SKILL.md` |
| Rules | `kebab-case.md` | `typescript.md` |

### Agent frontmatter

```yaml
---
name: agent-name
description: Description (French or English)
tools: Read, Grep, Glob
model: haiku  # or sonnet for complex tasks
permissionMode: plan
disallowedTools: Edit, Write, NotebookEdit
skills:
  - associated-skill
---
```

### Skill frontmatter

```yaml
---
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash
context: fork
---
```

### Choosing the model for an agent

- **haiku**: exploration, read-only audits, documentation
- **sonnet**: debugging, code writing, complex analysis

## Pre-submission checklist

- [ ] Tests pass (`./scripts/test.sh`)
- [ ] Counters are consistent (`./scripts/validate-counts.sh`)
- [ ] Docs are regenerated (`cd website && npm run generate`)
- [ ] Commit message follows Conventional Commits
- [ ] No secrets in code (gitleaks)
- [ ] ShellCheck passes on bash scripts (`./scripts/lint.sh`)

## Automated hooks

The project uses Claude Code hooks that run automatically:

- **Main branch protection**: direct edits on `main`/`master` are blocked
- **Gitleaks**: secret detection before any write
- **Pre-commit tests**: tests run before each commit
- **Auto-format**: automatic formatting after edits (TS, Python, Go, Rust, Dart, Lua)
- **Private names**: a commit that would add an end user's private project name to
  this public repo is blocked. The list of protected names lives outside the repo
  (`~/.claude/private-names`), so this gate is a silent no-op unless you keep one —
  see [`docs/GUARDRAILS.md`](docs/GUARDRAILS.md) §6.
