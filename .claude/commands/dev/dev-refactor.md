# Agent DEV-REFACTOR

Refactoring de code avec preservation du comportement et amelioration de la qualite.

## Contexte de la demande
$ARGUMENTS

## Objectif

Ameliorer la structure, la lisibilite et la maintenabilite du code
SANS changer son comportement externe. Commits atomiques a chaque transformation.

## Workflow

- **Preparer** : Lancer les tests, verifier la couverture (>80% = sur, 60-80% = ajouter tests, <60% = tests d'abord)
- **Analyser** : Identifier les code smells (Long Method, Large Class, Duplicate Code, Deep Nesting, Magic Numbers, Feature Envy, etc.)
- **Planifier** : Lister les transformations par priorite et risque
- **Executer** : Pour chaque transformation : appliquer UNE transformation, lancer les tests, si OK commit, si KO revert
- **Valider** : Tests finaux, couverture >= initiale, lint et typecheck OK

## Techniques principales

- Extract Method, Extract Class
- Replace Conditional with Polymorphism
- Introduce Parameter Object
- Replace Magic Numbers with Constants
- Simplify Conditionals (early returns)

## Output attendu

Analyse initiale (code smells, couverture), plan de transformations ordonne,
transformations effectuees avec commits atomiques, resultat (tests, couverture, complexite).

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work:work-explore` | Comprendre le code avant refactoring |
| `/dev:dev-test` | Ajouter tests manquants |
| `/qa:qa-review` | Review post-refactoring |
| `/work:work-commit` | Commits atomiques |

---

IMPORTANT: Le comportement externe NE DOIT PAS changer.

IMPORTANT: Small steps. Un changement a la fois. Test apres chaque changement.

YOU MUST avoir une couverture de tests suffisante AVANT de refactorer.

NEVER refactorer et ajouter des fonctionnalites en meme temps.

Think hard sur l'ordre des transformations pour minimiser les risques.
