# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Specify → Plan → TDD → Commit

@docs/reference/best-practices.md
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

## Documentation et References

| Reference | Chemin |
|-----------|--------|
| Commandes disponibles | `docs/reference/commands.md` |
| Catalogue agents/commands | `docs/reference/agents-catalog.md` |
| Hooks configures | `docs/reference/hooks-reference.md` |
| Skills disponibles | `docs/reference/skills-catalog.md` |
| Features avancees | `docs/reference/advanced-features.md` |
| Architecture | `docs/ARCHITECTURE.md` |
| Workflows visuels | `docs/WORKFLOWS.md` |
| Guide choix agents | `WHEN-TO-USE-WHICH-AGENT.md` |
| Guide Web | `docs/guides/WEB-GUIDE.md` |
| Guide Mobile | `docs/guides/MOBILE-GUIDE.md` |
| Guide API | `docs/guides/API-GUIDE.md` |
| Guide Data | `docs/guides/DATA-GUIDE.md` |
| Guide Prompting | `docs/guides/PROMPTING-GUIDE.md` |

Setup: `./scripts/new-project.sh --simple .`

## Workflows Recommandes

| Situation | Commande |
|-----------|----------|
| Nouvelle feature | `/work:work-flow-feature "description"` |
| Correction de bug | `/work:work-flow-bugfix "description"` |
| Nouvelle release | `/work:work-flow-release "v2.0.0"` |
| Lancement produit | `/work:work-flow-launch "mon SaaS"` |
| Audit complet | `/qa:qa-audit` |
| Audit + fix en boucle | `/qa:qa-loop` ou `/qa:qa-loop "score 90"` |
| Deploiement securise | `/ops:ops-deploy` |
| Equipe d'agents | `/work:work-team "description"` |

Workflow manuel : `/work:work-explore` → `/work:work-specify` → `/work:work-plan` → `/dev:dev-tdd` → `/work:work-pr`

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Coder AVANT d'ecrire les tests (violer TDD)
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- any partout en TypeScript
- **Ne pas donner de moyen de verification a Claude**
- **Prompts vagues sans contexte ni exemples**
