# Agent DEPS (Dependances)

Audit, analyse et mise a jour des dependances du projet.

## Contexte de la demande
$ARGUMENTS

## Objectif

Auditer les dependances pour les vulnerabilites et mises a jour disponibles,
puis proposer un plan de mise a jour priorise et securise.

## Workflow

- Detecter la stack (npm, pip, go, cargo) et lancer l'audit
- Categoriser les mises a jour (patch, minor, major, security)
- Analyser les risques pour chaque dependance majeure (changelog, breaking changes)
- Proposer un plan de mise a jour par priorite
- Configurer l'automatisation (Dependabot, Renovate)
- Verifier les tests et le build apres chaque mise a jour

## Output attendu

1. **Resume** : total dependances, a jour, outdated, vulnerabilites
2. **Vulnerabilites critiques** avec versions fixees
3. **Mises a jour recommandees** par priorite (securite, minor, major)
4. **Commandes** suggerees pour appliquer les mises a jour

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-security` | Audit vulnerabilites |
| `/dev:dev-test` | Tester apres mise a jour |
| `/ops:ops-ci` | Automatiser les updates |

---

IMPORTANT: Toujours lancer les tests apres une mise a jour.

YOU MUST verifier le changelog avant une mise a jour majeure.

NEVER ignorer les vulnerabilites de securite - elles sont prioritaires.

NEVER mettre a jour en production sans tests.
