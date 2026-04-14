# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit

@docs/reference/best-practices.md
@docs/reference/project-structures.md

## Workflow Obligatoire : Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit

1. **EXPLORE** (`/work:work-explore`) - Lire et comprendre le code AVANT de modifier
1b. **BRAINSTORM** (`/work:work-brainstorm`) - _(optionnel)_ Ideation structuree, explorer les alternatives avant de specifier
2. **SPECIFY** (`/work:work-specify`) - User Stories prioritisees (P1=MVP), criteres d'acceptation (Given/When/Then)
3. **PLAN** (`/work:work-plan`) - Architecture, fichiers, taches par User Story, risques
4. **TDD** (`/dev:dev-tdd`) - Tests AVANT le code, cycle Red-Green-Refactor, couverture 80%+
5. **AUDIT** (`/qa:qa-loop "score 90"`) - Audit adaptatif + correction en boucle jusqu'au score 90
6. **COMMIT** (`/work:work-commit` ou `/work:work-pr`) - Conventional Commits, reference issues

## Conventions de Code

- **TypeScript** : strict mode, pas de `any`, interfaces pour objets complexes. Details dans `.claude/rules/typescript.md`
- **Nommage** : camelCase (vars/fonctions), PascalCase (classes/composants), SCREAMING_SNAKE (constantes), kebab-case (fichiers)
- **Tests** : couverture 80%+, pas de mocks sauf deps externes, edge cases obligatoires. Details dans `.claude/rules/testing.md`
- **Securite** : valider entrees, echapper outputs, requetes parametrees. Details dans `.claude/rules/security.md`
- **Design** : direction artistique via `Style:` dans CLAUDE.md du projet (terminal, cockpit, vitality, editorial, glass, signal). Details dans `.claude/rules/design-style.md`

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
| Guide Python | `docs/guides/PYTHON-GUIDE.md` |
| Guide Go | `docs/guides/GO-GUIDE.md` |
| Guide Data | `docs/guides/DATA-GUIDE.md` |
| Guide Infra & Ops | `docs/guides/INFRA-GUIDE.md` |
| Guide Auth | `docs/guides/AUTH-GUIDE.md` |
| Guide Testing | `docs/guides/TESTING-GUIDE.md` |
| Guide Database | `docs/guides/DATABASE-GUIDE.md` |
| Guide Observabilite | `docs/guides/OBSERVABILITY-GUIDE.md` |
| Guide Business | `docs/guides/BIZ-GUIDE.md` |
| Guide Growth | `docs/guides/GROWTH-GUIDE.md` |
| Guide Equipe | `docs/guides/TEAM-GUIDE.md` |
| Guide Prompting | `docs/guides/PROMPTING-GUIDE.md` |
| Guide Troubleshooting | `docs/guides/TROUBLESHOOTING-GUIDE.md` |
| Guide Extension du socle | `docs/guides/EXTENDING-GUIDE.md` |
| Parcours Novice a Pro | `website/docs/guides/learning-path.md` |

Setup: `./scripts/new-project.sh --simple .`

## Workflows Recommandes

| Situation | Commande |
|-----------|----------|
| Ideation / brainstorm | `/work:work-brainstorm "idee"` |
| Nouvelle feature | `/work:work-flow-feature "description"` |
| Correction de bug | `/work:work-flow-bugfix "description"` |
| Nouvelle release | `/work:work-flow-release "v2.0.0"` |
| Lancement produit | `/work:work-flow-launch "mon SaaS"` |
| Audit complet | `/qa:qa-audit` |
| Audit + fix en boucle | `/qa:qa-loop` (score 90 par defaut) |
| Deploiement securise | `/ops:ops-deploy` |
| Equipe d'agents | `/work:work-team "description"` |
| Changement trivial | `/work:work-quick "description"` |
| Batch de stories | `/work:work-batch "prd.json"` |
| Suivi des couts | `/ops:ops-cost` |

Workflow manuel : `/work:work-explore` → (`/work:work-brainstorm`) → `/work:work-specify` → `/work:work-plan` → `/dev:dev-tdd` → `/qa:qa-loop "score 90"` → `/work:work-pr`

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Coder AVANT d'ecrire les tests (violer TDD)
- Commiter sans audit (sauter la phase Audit)
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- any partout en TypeScript
- **Ne pas donner de moyen de verification a Claude**
- **Prompts vagues sans contexte ni exemples**
