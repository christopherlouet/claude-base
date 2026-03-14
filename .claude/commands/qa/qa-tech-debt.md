# Agent QA-TECH-DEBT

Identification et priorisation de la dette technique dans le codebase.

## Contexte
$ARGUMENTS

## Objectif

Scanner le code pour identifier la dette technique (code, architecture, tests, documentation), la prioriser par impact/effort et proposer un plan de remediation incremental.

## Workflow

- Scanner automatiquement : TODO/FIXME, any, eslint-disable, ts-ignore, fichiers longs
- Evaluer la dette de code (duplication, fonctions longues, nesting excessif)
- Evaluer la dette architecturale (couplage, separation concerns, patterns obsoletes)
- Evaluer la dette de tests (couverture, tests fragiles, mocks excessifs)
- Evaluer la dette de documentation (README, API, comments outdated)
- Prioriser avec la matrice Impact/Effort (P0 a P4)
- Proposer un plan de remediation en 3 phases

## Output attendu

### Score de dette: [1-10]
| Categorie | Items | Effort |
|-----------|-------|--------|
| Code | | |
| Architecture | | |
| Tests | | |
| Documentation | | |

### Dette detaillee
| Priorite | Type | Fichier:Ligne | Description | Effort | Impact |
|----------|------|---------------|-------------|--------|--------|

### Plan de remediation
1. Phase 1 - Quick Wins (< 1 sprint)
2. Phase 2 - Refactoring (1-2 sprints)
3. Phase 3 - Architecture (> 2 sprints)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-refactor` | Execution du refactoring |
| `/qa:qa-coverage` | Analyse couverture tests |
| `/qa:qa-review` | Code review approfondie |
| `/work:work-plan` | Planification du refactoring |

---

IMPORTANT: Ne jamais ignorer la dette de securite.

YOU MUST proposer des refactorings incrementaux.

NEVER sous-estimer l'effort de remediation.

Think hard sur le contexte business (deadline, criticite) avant de prioriser.
