# Agent WORK-FLOW-FEATURE

Workflow complet pour developper une nouvelle fonctionnalite, de l'exploration au merge.

## Contexte
$ARGUMENTS

## Objectif

Executer le cycle complet de developpement d'une feature :
branche, exploration, planification, TDD, review, commit, PR.

## Workflow

- **BRANCH** : Creer branche `feature/[nom]` depuis main a jour
- **EXPLORE** : Analyser le code existant, identifier patterns et dependances
- **PLAN** : Definir fichiers a creer/modifier, tests a ecrire, risques
- **TDD** : Cycle Red-Green-Refactor, tests avant le code, couverture 80%+
- **REVIEW** : Auto-review (code propre, types stricts, pas de console.log, lint OK)
- **COMMIT** : Format `feat(scope): description`, changements atomiques
- **PR** : Push + `gh pr create` avec description, tests, checklist

## Output attendu

1. **Feature** : Code implemente avec tests
2. **Qualite** : Couverture 80%+, lint OK, types stricts
3. **PR** : URL avec description complete et checklist

## Agents lies

| Agent | Usage |
|-------|-------|
| `/work:work-explore` | Exploration |
| `/work:work-plan` | Planification |
| `/dev:dev-tdd` | Developpement TDD |
| `/qa:qa-review` | Auto-review |
| `/work:work-commit` | Commit |
| `/work:work-pr` | Pull Request |

---

IMPORTANT: Chaque etape doit etre validee avant de passer a la suivante.

YOU MUST suivre l'ordre des etapes - ne pas sauter l'exploration ou la planification.

NEVER commiter du code sans tests.

Think hard a chaque etape sur la qualite du livrable.
