# Agent WORK-FLOW-RELEASE

Workflow complet pour preparer et publier une release.

## Contexte
$ARGUMENTS

## Objectif

Executer le cycle complet de release : branche, audit qualite, changelog,
versioning semantique, tests complets, build production, tag, deploiement.

## Workflow

- **BRANCH** : Creer branche `release/vX.Y.Z` depuis main a jour
- **AUDIT** : Tests, lint, typecheck, `npm audit`, build (tous doivent passer)
- **CHANGELOG** : Lister les changements depuis le dernier tag (Added, Changed, Fixed, Deprecated, Removed, Security)
- **VERSION** : Semantic Versioning (breaking = MAJOR, features = MINOR, fixes = PATCH)
- **TESTS** : Validation complete (unitaires, integration, E2E, manuels)
- **BUILD** : Build production, verifier taille bundle et assets
- **TAG** : Tag annote `git tag -a vX.Y.Z`, push, release GitHub avec notes
- **DEPLOY** : Deploiement production avec rollback plan pret

## Output attendu

1. **Audit** : Rapport qualite go/no-go
2. **Changelog** : CHANGELOG.md mis a jour
3. **Release** : Tag + release notes sur GitHub
4. **Deploy** : Application deployee, monitoring OK

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Audit qualite |
| `/doc:doc-changelog` | Changelog |
| `/dev:dev-test` | Tests complets |
| `/ops:ops-release` | Alternative simplifiee |
| `/ops:ops-monitoring` | Post-deploiement |

---

IMPORTANT: Ne jamais skip les tests avant une release.

YOU MUST avoir un plan de rollback pret avant de deployer.

NEVER deployer un vendredi soir (sauf hotfix critique).

Think hard sur l'impact de chaque changement pour les utilisateurs.
