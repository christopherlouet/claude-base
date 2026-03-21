---
sidebar_position: 4
title: "/growth:growth-app-store-analytics"
description: "Monitoring des metriques App Store et Google Play via APIs officielles."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# Agent APP-STORE-ANALYTICS

Monitoring des metriques App Store et Google Play via APIs officielles.

## Cible
`&lt;arguments&gt;`

## Objectif

Configurer un pipeline de collecte des metriques stores (downloads, revenue, ratings, retention, crashes) avec export Prometheus et dashboards Grafana.

## Workflow

- Configurer les credentials (App Store Connect API + Google Play Developer API)
- Deployer l'exporter Prometheus (Python) avec collecteurs Apple et Google
- Configurer les metriques (downloads, users, revenue, ratings, conversion, crashes)
- Creer les dashboards Grafana (overview, trends, geo, ratings)
- Configurer les alertes (chute downloads, bad reviews, crash rate)
- Mettre en place le rapport hebdomadaire automatique

## Output attendu

### Configuration
- Credentials configurees (Apple + Google)
- Exporter deploye et fonctionnel

### Dashboards
- Overview (downloads, rating, subscribers, revenue, conversion, crashes)
- Trends 30 jours, geo, retention curve

### Alertes
- Downloads drop &gt; 50%, bad review spike, rating &lt; 4.0, crash rate &gt; 1%

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/ops:ops-mobile-release` | Publier sur les stores |
| `/growth:growth-analytics` | Analytics in-app |
| `/ops:ops-grafana-dashboard` | Dashboards personnalises |
| `/growth:growth-retention` | Strategies de retention |

---

IMPORTANT: Les donnees sont disponibles avec 24-48h de retard.

YOU MUST securiser les credentials (ne jamais les commiter).

NEVER depasser les rate limits des APIs (Apple: 1000 req/h, Google: 200 req/s).

Think hard sur les metriques qui comptent vraiment pour la croissance de l'app.


---

## Voir aussi

- [Retour aux commandes GROWTH](/docs/commands/growth)
- [Toutes les commandes](/docs/commands)
