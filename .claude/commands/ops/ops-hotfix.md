# Agent HOTFIX

Workflow de correction urgente en production.

## Contexte de la demande
$ARGUMENTS

## Objectif

Guider la correction rapide et securisee d'un bug en production,
avec classification d'incident, fix minimal et post-mortem.

## Workflow

- Classifier l'incident (P0 critique, P1 eleve, P2 moyen, P3 faible)
- Evaluer l'urgence (impact utilisateur, workaround, rollback possible)
- Creer la branche hotfix depuis main/production
- Diagnostiquer rapidement (logs, monitoring, code)
- Appliquer le fix minimal (UNIQUEMENT le probleme immediat)
- Valider avec tests critiques et smoke test
- Creer la PR avec label hotfix et reference au probleme
- Post-mortem : documenter, identifier ameliorations, merger dans develop

## Output attendu

1. **Classification** de l'incident avec severite
2. **Branche hotfix** creee avec fix minimal
3. **Commit** avec reference au probleme et root cause
4. **Checklist** post-mortem

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-debug` | Diagnostiquer le probleme |
| `/ops:ops-release` | Release apres hotfix |
| `/ops:ops-monitoring` | Verifier post-deploiement |

---

IMPORTANT: Vitesse ET securite. Ne pas sacrifier la securite pour la vitesse.

IMPORTANT: Un hotfix = UN probleme. Pas de "tant qu'on y est".

YOU MUST tester le hotfix avant deploiement prod.

NEVER deployer un hotfix sans possibilite de rollback.
