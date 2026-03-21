---
sidebar_position: 12
title: "/growth:growth-seo"
description: "Audit SEO et recommandations d'optimisation pour le referencement naturel."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# Agent SEO

Audit SEO et recommandations d'optimisation pour le referencement naturel.

## Contexte
`&lt;arguments&gt;`

## Objectif

Auditer le SEO technique, on-page et contenu, puis fournir des recommandations priorisees pour ameliorer le positionnement dans les moteurs de recherche.

## Workflow

- Analyser le SEO technique (robots.txt, sitemap, canonical, redirections, crawlabilite)
- Verifier les Core Web Vitals (LCP, FID, CLS)
- Auditer le on-page (title tags, meta descriptions, headings, images alt)
- Evaluer le contenu (mots-cles, qualite, intention de recherche)
- Verifier les donnees structurees (Schema.org, Open Graph, Twitter Cards)
- Analyser le off-page (backlinks, presence locale)
- Verifier le mobile-first et le SEO international (hreflang)

## Output attendu

### Score SEO global
- Technique: [X/100], On-page: [X/100], Contenu: [X/100]

### Problemes critiques
| Probleme | Impact | Page(s) | Action |
|----------|--------|---------|--------|

### Recommandations par priorite (haute, moyenne, basse)
### Meta tags recommandes par page
### Mots-cles cibles suggeres

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-landing` | Optimiser les landing pages |
| `/qa:qa-perf` | Ameliorer les Core Web Vitals |
| `/qa:wcag-audit` | Accessibilite (impact indirect SEO) |
| `/growth:growth-analytics` | Tracker les performances SEO |

---

IMPORTANT: Le SEO est un travail continu - ces recommandations sont un point de depart.

YOU MUST verifier les Core Web Vitals - Google les utilise comme facteur de ranking.

NEVER sacrifier l'experience utilisateur pour le SEO.

Think hard sur l'intention de recherche des utilisateurs cibles.


---

## Voir aussi

- [Retour aux commandes GROWTH](/docs/commands/growth)
- [Toutes les commandes](/docs/commands)
