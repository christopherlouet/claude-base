# Index de la Documentation

> Navigation rapide dans la documentation claude-socle.

## Par Niveau d'Experience

| Niveau | Document | Description |
|--------|----------|-------------|
| Debutant | [QUICKSTART.md](./QUICKSTART.md) | Demarrage rapide en 5 minutes |
| Debutant | [Documentation Docusaurus](https://christopherlouet.github.io/claude-socle/) | Guide utilisateur complet (site web) |
| Intermediaire | [CHEATSHEET.md](./CHEATSHEET.md) | Reference rapide des commandes |
| Avance | [ARCHITECTURE.md](./ARCHITECTURE.md) | Architecture Commands/Agents/Skills |
| Avance | [CUSTOMIZATION.md](./CUSTOMIZATION.md) | Guide de personnalisation |
| Avance | [WORKFLOWS.md](./WORKFLOWS.md) | Diagrammes visuels des workflows |

## Par Domaine

### Stack Recipes

[STACK-RECIPES.md](./STACK-RECIPES.md) — pour chaque stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, IA/LLM, Business, etc.), liste les commandes / agents / skills / rules du socle qui s'activent + des liens externes pour les best practices.

### Guides spécifiques (4)

| Guide | Description |
|-------|-------------|
| [EXTENDING-GUIDE.md](./guides/EXTENDING-GUIDE.md) | Ajouter ses propres commands, skills, agents, rules au socle |
| [TEAM-GUIDE.md](./guides/TEAM-GUIDE.md) | Adoption en équipe, conventions partagées |
| [PROMPTING-GUIDE.md](./guides/PROMPTING-GUIDE.md) | Techniques de prompting Claude Code (Boris Cherny) |
| [TROUBLESHOOTING-GUIDE.md](./guides/TROUBLESHOOTING-GUIDE.md) | Problèmes courants et solutions |

## Par Type de Tache

### Je veux comprendre le projet

1. [QUICKSTART.md](./QUICKSTART.md) - Installer et configurer
2. [ARCHITECTURE.md](./ARCHITECTURE.md) - Comprendre la structure
3. [CHEATSHEET.md](./CHEATSHEET.md) - Voir les commandes disponibles

### Je veux personnaliser le socle

1. [CUSTOMIZATION.md](./CUSTOMIZATION.md) - Options de personnalisation
2. [guides/EXTENDING-GUIDE.md](./guides/EXTENDING-GUIDE.md) - Ajouter commands/skills/rules custom
3. [ARCHITECTURE.md](./ARCHITECTURE.md) - Comprendre Commands vs Agents vs Skills

### Je veux developper avec le socle

1. [STACK-RECIPES.md](./STACK-RECIPES.md) - Voir ce que le socle apporte pour ma stack
2. [WORKFLOWS.md](./WORKFLOWS.md) - Suivre les workflows recommandes

### Je cherche une commande specifique

1. [CHEATSHEET.md](./CHEATSHEET.md) - Reference rapide
2. [Catalogue des commandes](https://christopherlouet.github.io/claude-socle/docs/commands) - Liste exhaustive (Docusaurus)

## Structure de la Documentation

```
docs/
├── README.md              # Cet index de navigation
├── QUICKSTART.md          # Demarrage rapide
├── CHEATSHEET.md          # Reference rapide
├── STACK-RECIPES.md       # Recettes par stack (Web, Mobile, API, etc.)
├── ARCHITECTURE.md        # Architecture technique
├── CUSTOMIZATION.md       # Personnalisation
├── WORKFLOWS.md           # Diagrammes de workflows
├── reference/             # Documentation de reference
└── guides/                # 4 guides specifiques
    ├── EXTENDING-GUIDE.md
    ├── TEAM-GUIDE.md
    ├── PROMPTING-GUIDE.md
    └── TROUBLESHOOTING-GUIDE.md
```

> Pour la documentation complete (commands, agents, skills, rules), voir le [site Docusaurus](https://christopherlouet.github.io/claude-socle/).

## Documentation Externe

- [Documentation Docusaurus](https://christopherlouet.github.io/claude-socle/) - Site de documentation complet
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Bonnes pratiques Anthropic
- [Claude Code Documentation](https://code.claude.com/docs/en/overview) - Documentation officielle

## Voir Aussi

- [../CLAUDE.md](../CLAUDE.md) - Instructions principales du projet
- [../WHEN-TO-USE-WHICH-AGENT.md](../WHEN-TO-USE-WHICH-AGENT.md) - Guide de choix des agents
- [../README.md](../README.md) - README principal du projet
