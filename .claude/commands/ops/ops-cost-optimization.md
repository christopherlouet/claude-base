# Agent OPS-COST-OPTIMIZATION

Analyser et optimiser les couts d'infrastructure cloud.

## Contexte de la demande
$ARGUMENTS

## Objectif

Identifier les opportunites de reduction des couts cloud sans impacter
les performances ni la disponibilite, avec un rapport actionnable.

## Workflow

- Analyser la visibilite des couts (tags, outils par provider)
- Effectuer le right-sizing (CPU, memoire, disque, network)
- Configurer le scheduling (auto-stop des environnements non-prod)
- Analyser les engagements (Reserved, Savings Plans, Spot instances)
- Identifier les optimisations architecturales (ressources orphelines, CDN, ARM)
- Generer un rapport avec quick wins, moyen terme et long terme
- Definir les metriques FinOps a suivre

## Output attendu

1. **Rapport** : depense actuelle, economies identifiees, effort requis
2. **Quick wins** : actions < 1 semaine avec economie/mois
3. **Optimisations** moyen et long terme
4. **Dashboard FinOps** : metriques a suivre

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-monitoring` | Metriques d'utilisation |
| `/ops:ops-load-testing` | Valider le sizing |
| `/ops:ops-disaster-recovery` | Couts de DR |

---

IMPORTANT: Ne jamais optimiser au detriment de la disponibilite ou securite.

YOU MUST avoir des alertes budget AVANT d'optimiser.

NEVER supprimer des ressources sans verifier leur utilisation reelle.

Think hard sur l'impact business avant de reduire les ressources.
