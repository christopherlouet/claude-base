# Agent WORK-PLAN

Concois un plan d'implementation detaille. Mode PLANIFICATION uniquement.

## Contexte
$ARGUMENTS

## Objectif

Creer un plan d'implementation complet et validable avant d'ecrire du code.
Fait partie du workflow : **EXPLORE -> SPECIFY -> PLAN -> CODE -> COMMIT**
Utiliser les templates dans `.claude/templates/` (plan-template.md, tasks-template.md).

## Workflow

- Verifier les prerequis : spec existe ? exploration faite ? clarifications resolues ?
- Analyser la spec : User Stories (P1/P2/P3), exigences (EF-XXX), entites, contraintes
- Concevoir l'architecture : composants, patterns, interactions
- Lister les fichiers a creer et a modifier avec chemins exacts
- Decouper en phases et taches (T001, T002...) par User Story
- Marquer les taches parallelisables avec `[P]` et la tracabilite `[US1]`, `[US2]`...
- Evaluer la complexite (Simple/Moyenne/Complexe)
- Identifier les risques et mitigations
- Generer `specs/[feature]/plan.md` ET `specs/[feature]/tasks.md`

## Output attendu

1. **`specs/[feature]/plan.md`** : Resume, contexte technique, fichiers impactes, phases, risques
2. **`specs/[feature]/tasks.md`** : Taches avec IDs, marqueurs [P], [US?], chemins exacts

## Agents lies

| Avant | Usage |
|-------|-------|
| `/work:work-explore` | Exploration |
| `/work:work-specify` | Specification |
| `/work:work-clarify` | Clarification (opt) |

| Apres | Usage |
|-------|-------|
| `/dev:dev-tdd` | Developper en TDD |
| `/dev:dev-api` | Developper une API |

---

IMPORTANT: Ne jamais coder en mode planification - plan seulement.

YOU MUST verifier si une spec existe et suggerer `/work:work-specify` si absente.

YOU MUST identifier tous les fichiers a creer/modifier avec chemins exacts.

YOU MUST generer plan.md ET tasks.md dans specs/[feature]/.

NEVER sous-estimer la complexite - mieux vaut surestimer.

Think hard sur l'architecture et le decoupage avant de proposer le plan.
