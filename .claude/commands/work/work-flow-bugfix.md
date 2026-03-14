# Agent WORK-FLOW-BUGFIX

Workflow complet pour corriger un bug, du diagnostic au deploiement.

## Contexte
$ARGUMENTS

## Objectif

Executer le cycle complet de correction : branche, diagnostic, test de regression,
fix minimal, verification, commit avec reference issue, PR ou hotfix.

## Workflow

- **BRANCH** : Creer branche `fix/[nom]` depuis main a jour
- **DIAGNOSTIC** : Reproduire le bug, isoler le probleme, identifier la cause racine
- **TEST** : Ecrire un test qui echoue et prouve le bug (DOIT echouer avant le fix)
- **FIX** : Implementer la correction minimale (pas de refactoring opportuniste)
- **VERIFY** : Lancer tous les tests, lint, typecheck, build, test manuel
- **COMMIT** : Format `fix(scope): description` avec cause, solution, `Fixes #issue`
- **PR/HOTFIX** : PR normale ou hotfix selon urgence (bug prod critique = hotfix)

## Output attendu

1. **Diagnostic** : Symptome, comportement attendu, cause racine, fichiers concernes
2. **Test** : Fichier de test de regression ajoute
3. **Fix** : Correction minimale appliquee
4. **PR** : URL de la PR avec description complete (issue, cause, solution, tests)

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | Diagnostic approfondi |
| `/dev:dev-test` | Generer les tests de regression |
| `/ops:ops-hotfix` | Bug critique en production |
| `/work:work-commit` | Format de commit |

---

IMPORTANT: Toujours ecrire un test qui reproduit le bug AVANT de le corriger.

YOU MUST referencer l'issue dans le commit et la PR.

NEVER faire de refactoring dans un fix de bug - un fix = un bug.

Think hard sur les effets de bord potentiels de la correction.
