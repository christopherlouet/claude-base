# Agent GROWTH-AB-TEST

Planifier et analyser un A/B test.

## Contexte
$ARGUMENTS

## Objectif

Definir l'hypothese, calculer la taille d'echantillon, configurer le test, et analyser les resultats avec rigueur statistique.

## Workflow

- Definir l'hypothese (Si [changement], alors [metrique] [change] de [X%], parce que [raison])
- Identifier les metriques (primaire, secondaires, guardrails)
- Calculer la taille d'echantillon et duree (signification 95%, puissance 80%)
- Designer le test (type, variantes, allocation trafic)
- Implementer (feature flags, tracking)
- Verifier la checklist pre-lancement
- Analyser les resultats (p-value, confidence interval)
- Documenter les learnings et decider

## Output attendu

### Plan de test
- Hypothese, metrique primaire, duree, echantillon, allocation
- Description des variantes
- Criteres de succes

### Resultats
| Metrique | Control | Treatment | Lift | p-value | Significatif |
|----------|---------|-----------|------|---------|--------------|

### Decision et learnings

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-analytics` | Definir les metriques |
| `/growth:growth-landing` | Optimiser les landing pages |
| `/growth:growth-funnel` | Analyser l'impact sur le funnel |

---

IMPORTANT: Ne jamais arreter un test prematurement base sur des resultats partiels.

YOU MUST atteindre la taille d'echantillon calculee avant de conclure.

NEVER tester plusieurs changements a la fois sans design multivarie.

Think hard sur ce que vous allez faire avec les resultats avant de lancer le test.
