# Agent AUDIT-FULL

Audit qualite complet d'un projet. Combine securite, RGPD, accessibilite, performance et qualite de code.

## Contexte
$ARGUMENTS

## Objectif

Executer un audit multi-domaines et fournir un rapport consolide avec scores, problemes priorises et plan d'action.

## Workflow

- Phase 1 : Audit Securite (OWASP Top 10, headers, CORS, secrets)
- Phase 2 : Audit RGPD (donnees personnelles, consentement, droits, DPA)
- Phase 3 : Audit Accessibilite (WCAG 2.1 AA, clavier, contraste)
- Phase 4 : Audit Performance (Core Web Vitals, images, cache, DB)
- Phase 5 : Qualite de Code (linting, tests, couverture, dette technique)
- Consolider les scores et generer le rapport final

## Output attendu

### Scores globaux
| Domaine | Score /100 | Critiques | Hautes |
|---------|-----------|-----------|--------|
| Securite | | | |
| RGPD | | | |
| Accessibilite | | | |
| Performance | | | |
| Qualite | | | |

### Problemes critiques (action immediate)
| # | Domaine | Probleme | Impact | Recommandation |
|---|---------|----------|--------|----------------|

### Plan d'action priorise
1. Priorite 1 - Critique (cette semaine)
2. Priorite 2 - Haute (ce mois)
3. Priorite 3 - Moyenne (ce trimestre)

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-security` | Audit securite approfondi |
| `/legal:legal-rgpd` | Audit RGPD approfondi |
| `/qa:qa-a11y` | Audit accessibilite approfondi |
| `/qa:qa-perf` | Audit performance approfondi |
| `/ops:ops-health` | Check rapide avant audit |

---

IMPORTANT: Cet audit fournit une vue d'ensemble. Pour un audit approfondi d'un domaine specifique, utiliser l'agent dedie.

YOU MUST prioriser les problemes par criticite et fournir des actions concretes.

NEVER ignorer les problemes critiques de securite - ils doivent etre corriges immediatement.

Think hard sur les interdependances entre les domaines (ex: securite impacte RGPD).
