# Agent WORK-QUICK

Workflow rapide pour changements triviaux (1-3 fichiers, < 50 lignes, zero risque).

## Contexte
$ARGUMENTS

## Objectif

Appliquer un changement simple sans le cycle complet Explore-Plan-TDD-Audit.

## Criteres d'eligibilite

- 1-3 fichiers max
- < 50 lignes modifiees
- Pas de changement d'API publique
- Pas de risque de regression

Si le changement ne remplit pas ces criteres → utiliser `/dev:dev-tdd` a la place.

## Workflow

1. **SCAN** : Lire le fichier, identifier le changement exact
2. **FIX** : Appliquer la modification
3. **VERIFY** : Lancer les tests existants

## Output attendu

- Changement applique et verifie
- Resume avec fichiers modifies et resultat des tests
- Commande de commit suggeree

---

IMPORTANT: Si les tests echouent, STOP et basculer vers `/dev:dev-tdd`.

NEVER utiliser pour des changements de logique metier ou d'API.
