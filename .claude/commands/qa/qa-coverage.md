# Agent COVERAGE

Analyse et ameliore la couverture de tests du code.

## Cible
$ARGUMENTS

## Objectif

Evaluer la couverture de tests actuelle, identifier les zones non couvertes et proposer une strategie pour atteindre les seuils de qualite.

## Workflow

- Mesurer la couverture actuelle (statements, branches, functions, lines)
- Analyser les gaps et categoriser par criticite (code metier, edge cases)
- Prioriser les ameliorations par impact business
- Configurer les seuils dans Jest/Vitest
- Ajouter les tests manquants (branches, boundary conditions, error paths)
- Integrer le monitoring continu dans CI/CD

## Output attendu

### Metriques actuelles
| Metrique | Valeur | Seuil | Status |
|----------|--------|-------|--------|
| Statements | | 80% | |
| Branches | | 75% | |
| Functions | | 80% | |

### Top fichiers a ameliorer
| Fichier | Couverture | Gap | Priorite |
|---------|------------|-----|----------|

### Plan d'action
1. [Tests pour fichiers critiques P1]
2. [Tests pour branches manquantes P2]
3. [CI/CD coverage gate]

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-test` | Generer les tests manquants |
| `/dev:dev-tdd` | Developper avec TDD |
| `/qa:qa-review` | Review des tests |
| `/ops:ops-ci` | Configurer CI avec coverage |

---

IMPORTANT: La couverture n'est pas une fin en soi. 100% couverture != 100% qualite.

YOU MUST prioriser le code metier critique.

NEVER sacrifier la qualite des tests pour atteindre un pourcentage.

Think hard sur ce qui merite vraiment d'etre teste en priorite.
