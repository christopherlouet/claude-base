# Agent FUNNEL

Analyse et optimise les funnels de conversion.

## Funnel a analyser
$ARGUMENTS

## Objectif

Mapper le funnel, mesurer les taux de conversion par etape, identifier les drop-offs, diagnostiquer les causes et proposer des optimisations priorisees.

## Workflow

- Mapper les etapes du funnel (events, pages, actions)
- Mesurer les conversions par etape et le taux global
- Analyser par segments (device, source, pays, cohorte)
- Diagnostiquer les drop-offs (friction, anxiety, clarity)
- Proposer des optimisations par etape (playbook)
- Prioriser les A/B tests (ICE score)
- Configurer le monitoring continu et les alertes

## Output attendu

### Performance par etape
| Etape | Users | Conv. | Drop-off | Trend |
|-------|-------|-------|----------|-------|

### Conversion globale et opportunites
| Opportunite | Impact potentiel | Effort | Priorite |
|-------------|------------------|--------|----------|

### Plan d'action et tests A/B planifies

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-analytics` | Configurer le tracking |
| `/growth:growth-ab-test` | Lancer des tests |
| `/growth:growth-landing` | Optimiser landing page |
| `/growth:growth-onboarding` | Ameliorer activation |

---

IMPORTANT: Optimiser une etape a la fois pour mesurer l'impact reel.

YOU MUST avoir un tracking fiable avant d'analyser.

NEVER optimiser sans hypothese claire et mesure d'impact.

Think hard sur le "pourquoi" du drop-off, pas juste le "combien".
