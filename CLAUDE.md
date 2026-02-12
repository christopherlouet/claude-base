# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Specify → Plan → TDD → Commit

@docs/reference/commands.md
@docs/reference/project-structures.md

## Workflow Obligatoire : Explore → Specify → Plan → TDD → Commit

1. **EXPLORE** (`/work:work-explore`) - Lire et comprendre le code AVANT de modifier
2. **SPECIFY** (`/work:work-specify`) - User Stories prioritisees (P1=MVP), criteres d'acceptation (Given/When/Then)
3. **PLAN** (`/work:work-plan`) - Architecture, fichiers, taches par User Story, risques
4. **TDD** (`/dev:dev-tdd`) - Tests AVANT le code, cycle Red-Green-Refactor, couverture 80%+
5. **COMMIT** (`/work:work-commit` ou `/work:work-pr`) - Conventional Commits, reference issues

## Conventions de Code

- **TypeScript** : strict mode, pas de `any`, interfaces pour objets complexes. Details dans `.claude/rules/typescript.md`
- **Nommage** : camelCase (vars/fonctions), PascalCase (classes/composants), SCREAMING_SNAKE (constantes), kebab-case (fichiers)
- **Tests** : couverture 80%+, pas de mocks sauf deps externes, edge cases obligatoires. Details dans `.claude/rules/testing.md`
- **Securite** : valider entrees, echapper outputs, requetes parametrees. Details dans `.claude/rules/security.md`

### Gestion des secrets
- IMPORTANT: Ne jamais commiter de secrets (.env, credentials, API keys)
- Utiliser des variables d'environnement, placeholders dans exemples
- MCP servers desactives par defaut dans `.mcp.json`
- Eviter `curl URL | sh`, preferer telecharger + verifier + executer

@docs/reference/agents-catalog.md

## Documentation de Navigation

### Guides principaux
| Document | Description |
|----------|-------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture Commands vs Agents vs Skills vs Rules |
| [docs/WORKFLOWS.md](docs/WORKFLOWS.md) | Diagrammes visuels des workflows |
| [WHEN-TO-USE-WHICH-AGENT.md](WHEN-TO-USE-WHICH-AGENT.md) | Guide de choix des agents |

### Guides par domaine
| Guide | Stack |
|-------|-------|
| [docs/guides/WEB-GUIDE.md](docs/guides/WEB-GUIDE.md) | React, Next.js, Vue, Node.js |
| [docs/guides/MOBILE-GUIDE.md](docs/guides/MOBILE-GUIDE.md) | Flutter, Clean Architecture, BLoC |
| [docs/guides/API-GUIDE.md](docs/guides/API-GUIDE.md) | REST, GraphQL, Express, Fastify |
| [docs/guides/DATA-GUIDE.md](docs/guides/DATA-GUIDE.md) | ETL, Airflow, dbt, Data Warehouse |
| [docs/guides/PROMPTING-GUIDE.md](docs/guides/PROMPTING-GUIDE.md) | Techniques de prompting avance (Boris Cherny) |

### Setup
```bash
./scripts/new-project.sh --simple .
```

## Workflows Recommandes

| Situation | Commande |
|-----------|----------|
| Nouvelle feature | `/work:work-flow-feature "description"` |
| Correction de bug | `/work:work-flow-bugfix "description"` |
| Nouvelle release | `/work:work-flow-release "v2.0.0"` |
| Lancement produit | `/work:work-flow-launch "mon SaaS"` |
| Audit complet | `/qa:qa-audit` |
| Equipe d'agents | `/work:work-team "description"` |

Workflow manuel : `/work:work-explore` → `/work:work-specify` → `/work:work-plan` → `/dev:dev-tdd` → `/work:work-pr`

@docs/reference/hooks-reference.md
@docs/reference/skills-catalog.md
@docs/reference/advanced-features.md
@docs/reference/best-practices.md

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Coder AVANT d'ecrire les tests (violer TDD)
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- any partout en TypeScript
- **Ne pas donner de moyen de verification a Claude**
- **Prompts vagues sans contexte ni exemples**
