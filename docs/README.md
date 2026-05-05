# Documentation Index

> Quick navigation in the claude-base documentation.

## By Experience Level

| Level | Document | Description |
|--------|----------|-------------|
| Beginner | [QUICKSTART.md](./QUICKSTART.md) | Quick start in 5 minutes |
| Beginner | [Docusaurus Documentation](https://christopherlouet.github.io/claude-base/) | Complete user guide (website) |
| Intermediate | [CHEATSHEET.md](./CHEATSHEET.md) | Quick command reference |
| Advanced | [ARCHITECTURE.md](./ARCHITECTURE.md) | Commands/Agents/Skills architecture |
| Advanced | [CUSTOMIZATION.md](./CUSTOMIZATION.md) | Customization guide |
| Advanced | [WORKFLOWS.md](./WORKFLOWS.md) | Visual workflow diagrams |

## By Domain

### Stack Recipes

[STACK-RECIPES.md](./STACK-RECIPES.md) — for each stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, AI/LLM, Business, etc.), lists the commands / agents / skills / rules of the foundation that get activated + external links for best practices.

### Specific guides (4)

| Guide | Description |
|-------|-------------|
| [EXTENDING-GUIDE.md](./guides/EXTENDING-GUIDE.md) | Add your own commands, skills, agents, rules to the foundation |
| [TEAM-GUIDE.md](./guides/TEAM-GUIDE.md) | Team adoption, shared conventions |
| [PROMPTING-GUIDE.md](./guides/PROMPTING-GUIDE.md) | Claude Code prompting techniques (Boris Cherny) |
| [TROUBLESHOOTING-GUIDE.md](./guides/TROUBLESHOOTING-GUIDE.md) | Common problems and solutions |

## By Task Type

### I want to understand the project

1. [QUICKSTART.md](./QUICKSTART.md) - Install and configure
2. [ARCHITECTURE.md](./ARCHITECTURE.md) - Understand the structure
3. [CHEATSHEET.md](./CHEATSHEET.md) - See available commands

### I want to customize the foundation

1. [CUSTOMIZATION.md](./CUSTOMIZATION.md) - Customization options
2. [guides/EXTENDING-GUIDE.md](./guides/EXTENDING-GUIDE.md) - Add custom commands/skills/rules
3. [ARCHITECTURE.md](./ARCHITECTURE.md) - Understand Commands vs Agents vs Skills

### I want to develop with the foundation

1. [STACK-RECIPES.md](./STACK-RECIPES.md) - See what the foundation brings for my stack
2. [WORKFLOWS.md](./WORKFLOWS.md) - Follow the recommended workflows

### I'm looking for a specific command

1. [CHEATSHEET.md](./CHEATSHEET.md) - Quick reference
2. [Commands catalog](https://christopherlouet.github.io/claude-base/docs/commands) - Exhaustive list (Docusaurus)

## Documentation Structure

```
docs/
├── README.md              # This navigation index
├── QUICKSTART.md          # Quick start
├── CHEATSHEET.md          # Quick reference
├── STACK-RECIPES.md       # Recipes per stack (Web, Mobile, API, etc.)
├── ARCHITECTURE.md        # Technical architecture
├── CUSTOMIZATION.md       # Customization
├── WORKFLOWS.md           # Workflow diagrams
├── reference/             # Reference documentation
└── guides/                # 4 specific guides
    ├── EXTENDING-GUIDE.md
    ├── TEAM-GUIDE.md
    ├── PROMPTING-GUIDE.md
    └── TROUBLESHOOTING-GUIDE.md
```

> For the complete documentation (commands, agents, skills, rules), see the [Docusaurus site](https://christopherlouet.github.io/claude-base/).

## External Documentation

- [Docusaurus Documentation](https://christopherlouet.github.io/claude-base/) - Complete documentation site
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic best practices
- [Claude Code Documentation](https://code.claude.com/docs/en/overview) - Official documentation

## See Also

- [../CLAUDE.md](../CLAUDE.md) - Main project instructions
- [../README.md](../README.md) - Main project README
