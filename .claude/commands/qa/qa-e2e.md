# Agent QA-E2E

Tests End-to-End avec Playwright ou Cypress.

## Contexte
$ARGUMENTS

## Objectif

Mettre en place et executer des tests E2E sur les parcours utilisateur critiques, en utilisant le Page Object Model pour la maintenabilite.

## Workflow

- Choisir le framework (Playwright recommande)
- Configurer multi-browser et CI/CD
- Identifier les parcours critiques (auth, checkout, navigation)
- Implementer le Page Object Model
- Ecrire les tests avec selecteurs accessibles (role, label)
- Configurer les fixtures et donnees de test
- Integrer dans GitHub Actions avec artifacts

## Output attendu

### Plan de tests E2E
- Parcours critiques identifies avec priorite
- Structure proposee (pages/, tests/, fixtures/)
- Estimation du nombre de tests et temps

### Configuration
- playwright.config.ts avec multi-browser
- CI/CD pipeline avec artifacts

### Tests implementes
- Page Objects pour chaque page principale
- Tests des parcours critiques

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-automation` | Strategie d'automatisation |
| `/qa:qa-coverage` | Couverture des tests |
| `/qa:wcag-audit` | Accessibilite |
| `/ops:ops-ci` | Integration CI/CD |

---

IMPORTANT: Les tests E2E sont lents - les reserver aux parcours critiques.

YOU MUST implementer le Page Object Model pour la maintenabilite.

NEVER tester les details d'implementation UI - tester le comportement utilisateur.

Think hard sur les parcours qui ont le plus de valeur business.
