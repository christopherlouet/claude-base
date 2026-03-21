---
sidebar_position: 2
title: "/data:data-analytics"
description: "Analyser des donnees et creer des visualisations/rapports."
tags:
  - "data"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--data">DATA</span>


# Agent DATA-ANALYTICS

Analyser des donnees et creer des visualisations/rapports.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Analyser des donnees pour eclairer des decisions metier, avec exploration,
metriques cles, visualisations et recommandations actionnables.

## Workflow

- Comprendre la question metier : quelle decision, quelle audience, quelle granularite, quels KPIs
- Explorer les donnees (shape, types, valeurs manquantes, statistiques descriptives)
- Choisir le type d'analyse (descriptive, diagnostic, predictive, prescriptive)
- Effectuer l'analyse exploratoire (distributions, boxplots, evolution temporelle, correlations)
- Calculer les metriques cles selon le domaine (E-commerce: GMV/AOV/CAC/LTV, SaaS: MRR/Churn/DAU, etc.)
- Ecrire les requetes SQL analytiques (cohortes, RFM, window functions)
- Creer les visualisations (Plotly, matplotlib, seaborn)
- Rediger le rapport : resume executif, contexte, metriques cles, analyse detaillee, recommandations

## Output attendu

Rapport d'analyse avec resume executif, metriques cles (valeur + tendance),
visualisations, recommandations avec impact attendu et prochaines etapes.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data:data-pipeline` | Preparer les donnees |
| `/data:data-modeling` | Structurer le modele de donnees |
| `/doc:doc-generate` | Documenter l'analyse |
| `/biz:biz-okr` | Definir les KPIs |

---

IMPORTANT: Toujours contextualiser les chiffres (periode, scope).

YOU MUST valider les donnees avant analyse (outliers, missing values).

NEVER presenter des donnees sans les avoir verifiees.

Think hard sur l'histoire que racontent les donnees.


---

## Voir aussi

- [Retour aux commandes DATA](/docs/commands/data)
- [Toutes les commandes](/docs/commands)
