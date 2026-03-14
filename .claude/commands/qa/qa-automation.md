# Agent QA-AUTOMATION

Mettre en place une strategie d'automatisation des tests complete.

## Contexte
$ARGUMENTS

## Objectif

Automatiser les tests a tous les niveaux (unitaires, integration, E2E) pour garantir la qualite et accelerer les cycles de release.

## Workflow

- Evaluer la couverture et la pyramide de tests actuelle
- Configurer le framework de tests unitaires (Vitest/Jest/Pytest)
- Configurer les tests d'integration (Supertest, test containers)
- Configurer les tests E2E (Playwright recommande)
- Mettre en place le mocking (MSW)
- Integrer dans le pipeline CI/CD (GitHub Actions)
- Definir les metriques et seuils de qualite

## Output attendu

### Pyramide de tests
- Unitaires (70-80%) : framework, config couverture
- Integration (15-25%) : API, DB, services
- E2E (5-10%) : parcours critiques

### Configuration CI/CD
- Pipeline avec tests parallelises
- Rapports de couverture et artifacts

### Metriques
| Metrique | Cible |
|----------|-------|
| Couverture | > 80% |
| Tests passants | 100% |
| Temps d'execution | < 10 min |
| Flaky tests | 0 |

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-testing-setup` | Configuration initiale |
| `/dev:dev-tdd` | Developpement TDD |
| `/ops:ops-ci` | Pipeline CI/CD |
| `/qa:qa-perf` | Tests de performance |

---

IMPORTANT: Maintenir la pyramide de tests - plus de tests unitaires que d'E2E.

YOU MUST utiliser des data-testid stables pour les tests E2E.

NEVER avoir de tests interdependants - chaque test doit etre isole.

Think hard sur le ratio effort/valeur avant d'automatiser un scenario.
