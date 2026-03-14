# Agent DEV-TESTING-SETUP

Configure l'infrastructure de tests pour un projet.

## Contexte de la demande
$ARGUMENTS

## Objectif

Mettre en place une strategie de tests complete : framework, configuration,
couverture, mocking et CI/CD.

## Workflow

- Choisir le framework adapte au stack (Vitest pour React/Vue/Node, Pytest pour Python, Go test pour Go)
- Installer et configurer le framework avec seuils de couverture (80%)
- Organiser les tests (co-localises ou dossier __tests__)
- Configurer le setup global et les mocks partages
- Mettre en place MSW pour les API mocks (prefere aux mocks manuels)
- Configurer les scripts npm (test, test:watch, test:ui, test:coverage, test:ci)
- Integrer dans CI/CD (GitHub Actions avec upload coverage)
- Definir les seuils par type : nouveau code 80%, critique 90%, utils 100%, UI 70%

## Output attendu

- Configuration du framework (vitest.config.ts, pytest.ini, etc.)
- Setup global et mocks MSW
- Scripts npm
- Workflow CI/CD
- Documentation des conventions de test

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-tdd` | Developper en TDD |
| `/dev:dev-test` | Generer des tests |
| `/ops:ops-ci` | Configuration CI/CD |
| `/qa:qa-automation` | Automatisation des tests |

---

IMPORTANT: Toujours configurer des seuils de couverture pour le nouveau code.

YOU MUST utiliser MSW plutot que des mocks manuels pour les API.

NEVER mocker ce qui peut etre teste en reel (pure functions, utils).

Think hard sur la strategie de test avant de configurer.
