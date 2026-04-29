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

### Guides Specifiques

| Guide | Stack | Description |
|-------|-------|-------------|
| [WEB-GUIDE.md](./guides/WEB-GUIDE.md) | React, Next.js, Vue | Applications web frontend |
| [MOBILE-GUIDE.md](./guides/MOBILE-GUIDE.md) | Flutter, BLoC | Applications mobiles |
| [API-GUIDE.md](./guides/API-GUIDE.md) | REST, GraphQL, tRPC | Developpement d'APIs |
| [DATA-GUIDE.md](./guides/DATA-GUIDE.md) | Airflow, dbt, ETL | Data engineering |

## Par Type de Tache

### Je veux comprendre le projet

1. [QUICKSTART.md](./QUICKSTART.md) - Installer et configurer
2. [ARCHITECTURE.md](./ARCHITECTURE.md) - Comprendre la structure
3. [CHEATSHEET.md](./CHEATSHEET.md) - Voir les commandes disponibles

### Je veux personnaliser le socle

1. [CUSTOMIZATION.md](./CUSTOMIZATION.md) - Options de personnalisation
2. [ARCHITECTURE.md](./ARCHITECTURE.md) - Comprendre Commands vs Agents vs Skills

### Je veux developper avec le socle

1. Choisir le guide adapte :
   - Web → [WEB-GUIDE.md](./guides/WEB-GUIDE.md)
   - Mobile → [MOBILE-GUIDE.md](./guides/MOBILE-GUIDE.md)
   - API → [API-GUIDE.md](./guides/API-GUIDE.md)
   - Data → [DATA-GUIDE.md](./guides/DATA-GUIDE.md)
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
├── ARCHITECTURE.md        # Architecture technique
├── CUSTOMIZATION.md       # Personnalisation
├── WORKFLOWS.md           # Diagrammes de workflows
├── reference/             # Documentation de reference (best-practices, etc.)
└── guides/
    ├── WEB-GUIDE.md       # Developpement web
    ├── MOBILE-GUIDE.md    # Developpement mobile
    ├── API-GUIDE.md       # Developpement API
    ├── DATA-GUIDE.md      # Data engineering
    └── ...                # 13 autres guides specialises
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
