# Quick Start - claude-base

> Get started with claude-base in 5 minutes

## Installation (30 seconds)

**Requires** `bash` 4.0+, `git` and `jq` on your PATH — `claude-base init` stops without them, and
macOS ships bash 3.2, so `brew install bash` first. Full prerequisites in the repository's `README.md`,
under "Try it (30 seconds)".

```bash
# After installing the foundation (curl | bash — see README)
claude-base init --simple /path/to/your-project

# Or from your project, current directory
claude-base init --simple .
```

A default install is **core-only** (work, dev, qa, ops, doc). The horizontal
domains (biz, growth, legal), data engineering (the `data` domain, via the
`data-eng` module) and platform/stack tooling are **opt-in modules**:

```bash
claude-base modules            # list available modules + what's installed
claude-base add biz .          # opt into a module
claude-base remove biz .       # opt back out
```

## First usage

The foundation's mandatory workflow, step by step:

### 1. Explore the project

```bash
/work:work-explore "Understand the architecture"
```

### 2. (optional) Brainstorm alternatives

```bash
/work:work-brainstorm "To add OAuth, which approaches?"
```

### 3. Specify the feature

```bash
/work:work-specify "Add OAuth authentication"
```

### 4. Plan the implementation

```bash
/work:work-plan "Implement Google OAuth"
```

### 5. Develop with TDD

```bash
/dev:dev-tdd "OAuth authentication flow"
```

### 6. Audit (mandatory before commit)

```bash
/qa:qa-loop "score 90"   # Audit + fix loop until target score
```

### 7. Commit

```bash
/work:work-commit
```

## Full workflow

```
┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────┐  ┌─────┐  ┌───────┐  ┌────────┐
│ EXPLORE │→│BRAINSTORM│→│ SPECIFY │→│ PLAN │→│ TDD │→│ AUDIT │→│ COMMIT │
│         │  │ (option) │  │         │  │      │  │     │  │ ≥ 90  │  │  + PR  │
└─────────┘  └──────────┘  └─────────┘  └──────┘  └─────┘  └───────┘  └────────┘
```

> **Skip for trivial changes**: `/work:work-quick` (< 50 LOC, 1-3 files).

## Most used commands

| Command | Usage |
|---------|-------|
| `/work:work-explore` | Understand existing code |
| `/work:work-specify` | Create a functional specification |
| `/work:work-plan` | Plan an implementation |
| `/dev:dev-tdd` | Develop with tests |
| `/work:work-commit` | Create a clean commit |
| `/work:work-pr` | Create a Pull Request |
| `/qa:qa-loop` | **Audit + fix loop (score 90 by default)** — recommended before commit |
| `/qa:qa-security` | OWASP security audit |
| `/qa:qa-audit` | Full audit (security + GDPR + a11y + perf) read-only |

## Shortcut workflows

| Command | Description |
|---------|-------------|
| `/work:work-flow-feature` | Full workflow for a new feature |
| `/work:work-flow-bugfix` | Full workflow for a bug fix |
| `/work:work-flow-release` | Full workflow for a release |
| `/work:work-flow-launch` | Full workflow for a product launch |
| `/work:work-quick` | Trivial change (< 50 LOC, 1-3 files) — skip full cycle |

## Help

- `/assistant` - Smart entry point that guides you to the right commands (guide mode)
- `/assistant-auto` - Automatic execution of the adapted workflow (auto mode)
- See [CLAUDE.md](../CLAUDE.md) for full documentation
- See [ARCHITECTURE.md](./ARCHITECTURE.md) to understand Commands vs Agents vs Skills

## Resources

- [Cheatsheet](./CHEATSHEET.md) - Quick reference
- [Customization](./CUSTOMIZATION.md) - Customization
- [Docusaurus documentation](https://christopherlouet.github.io/claude-base/) - Full documentation
