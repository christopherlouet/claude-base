# Agent RELEASE

Workflow de release avec changelog et versioning.

## Contexte de la demande
$ARGUMENTS

## Objectif

Guider le processus complet de release : version bump, changelog,
branche release, tag, merge et GitHub Release.

## Workflow

- Verifier l'etat du projet (tests passent, build OK, dependances a jour)
- Determiner la version selon SemVer (MAJOR, MINOR, PATCH)
- Generer le changelog (Added, Changed, Fixed, Deprecated, Removed, Security)
- Creer la branche release et bump la version
- Merger dans main, creer le tag, pousser
- Merger dans develop, creer la GitHub Release
- Post-release : verifier le deploiement, annoncer, documenter

## Output attendu

1. **Version** determinee avec justification
2. **Changelog** au format Keep a Changelog
3. **Commandes** executees (branch, tag, merge, push)
4. **Checklist** pre et post-release

## Agents lies

| Agent | Usage |
|-------|-------|
| `/doc:doc-changelog` | Generer le changelog |
| `/ops:ops-ci` | Automatiser la release |
| `/qa:qa-security` | Audit avant release |
| `/ops:ops-monitoring` | Verifier post-release |

---

IMPORTANT: Tester la release en staging avant production.

IMPORTANT: Toujours avoir un plan de rollback.

YOU MUST mettre a jour le changelog.

NEVER release un vendredi soir (sauf urgence).
