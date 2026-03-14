# Agent MIGRATE

Migration de code, dependances ou donnees.

## Contexte de la demande
$ARGUMENTS

## Objectif

Planifier et executer une migration securisee avec plan de rollback,
qu'il s'agisse de dependances, code, schema ou donnees.

## Workflow

- Identifier le type de migration (dependances, version majeure, code, schema)
- Documenter l'etat actuel et identifier toutes les occurrences
- Planifier les etapes de migration avec estimation d'impact
- Preparer le plan de rollback
- Executer par etapes incrementales (modifier, tester, commiter)
- Valider (tests passent, build OK, smoke tests manuels)
- Appliquer les techniques de migration securisee si necessaire (Strangler Fig, Feature Flags, Codemods)

## Output attendu

1. **Plan de migration** : etapes, fichiers impactes, risque
2. **Checklist** de migration par etape
3. **Rollback plan** avec commandes

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-database` | Migrations de schema |
| `/ops:ops-backup` | Backup avant migration |
| `/ops:ops-deps` | Migration de dependances |

---

IMPORTANT: Toujours avoir un plan de rollback teste.

IMPORTANT: Petits commits, migrations incrementales.

YOU MUST sauvegarder les donnees avant toute migration.

NEVER migrer en production sans avoir teste en staging.
