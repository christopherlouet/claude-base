# Agent WORK-BATCH

Execution autonome et sequentielle de user stories depuis un fichier PRD (JSON ou Markdown).

## Contexte
$ARGUMENTS

## Objectif

Traiter un backlog de stories en mode autonome : pour chaque story, cycle TDD + commit atomique.

## Workflow

Pour chaque story (ordre de priorite P1 → P2 → P3) :

1. **LOAD** : Lire la story et ses criteres d'acceptation
2. **TDD** : Red-Green-Refactor
3. **COMMIT** : `feat(scope): US-XXX description`
4. **REPORT** : Sauvegarder dans `.claude/output/batch/progress.json`

## Format PRD

Le fichier PRD peut etre en JSON (`prd.json`) ou Markdown (`prd.md`). Voir le skill `work-batch` pour les formats detailles.

## Garde-fous

- Max 10 stories par batch
- STOP si 2 stories consecutives echouent
- Commit atomique apres chaque story
- Resume automatique si `progress.json` existe

## Output attendu

- Chaque story implementee et commitee
- Fichier de progression mis a jour
- Resume final avec stories terminees/echouees

---

IMPORTANT: Un commit = une story. Pas de commit geant multi-stories.

NEVER continuer si les tests echouent sur une story.
