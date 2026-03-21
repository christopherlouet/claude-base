---
sidebar_position: 11
title: "Guide Business & Strategie"
description: " Workflow complet de l'idee au lancement produit"
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Guide Business & Strategie

&gt; Workflow complet de l'idee au lancement produit

## Contexte

Les commandes `/biz:biz-*` accompagnent chaque phase de la strategie produit : etude de marche, modelisation business, definition du MVP et lancement.

## Workflow Recommande

```
/biz:biz-research → /biz:biz-personas → /biz:biz-competitor → /biz:biz-model → /biz:biz-pricing → /biz:biz-mvp → /biz:biz-roadmap → /biz:biz-launch
```

## Phase 1: Recherche et Analyse

| Commande | Description |
|----------|-------------|
| `/biz:biz-research` | Etude de marche, tendances, opportunites |
| `/biz:biz-market` | Analyse de la taille du marche (TAM/SAM/SOM) |
| `/biz:biz-personas` | Definition des personas utilisateurs |
| `/biz:biz-competitor` | Analyse concurrentielle (forces, faiblesses, positionnement) |

### Livrables attendus

- Synthese du marche cible
- 3-5 personas detailles (besoins, frustrations, objectifs)
- Matrice concurrentielle avec positionnement

## Phase 2: Modelisation Business

| Commande | Description |
|----------|-------------|
| `/biz:biz-model` | Business Model Canvas (proposition de valeur, canaux, revenus) |
| `/biz:biz-pricing` | Strategie de pricing (freemium, tiers, usage-based) |
| `/biz:biz-okr` | Objectifs et resultats cles (OKR) par trimestre |

### Livrables attendus

- Business Model Canvas complet
- Grille tarifaire avec justification
- OKRs pour les 2 premiers trimestres

## Phase 3: MVP et Roadmap

| Commande | Description |
|----------|-------------|
| `/biz:biz-mvp` | Definition du MVP (features P1, scope minimal) |
| `/biz:biz-roadmap` | Roadmap produit (phases, jalons, priorites) |

### Livrables attendus

- Liste de features P1 (MVP) vs P2/P3
- Roadmap trimestrielle avec jalons

## Phase 4: Pitch et Lancement

| Commande | Description |
|----------|-------------|
| `/biz:biz-pitch` | Pitch deck (probleme, solution, marche, traction) |
| `/biz:biz-launch` | Plan de lancement (pre-launch, launch day, post-launch) |

### Livrables attendus

- Pitch deck 10-12 slides
- Checklist de lancement par phase

## Commandes par Use Case

### Nouveau produit SaaS

```bash
1. /biz:biz-research           # Etude de marche
2. /biz:biz-personas           # Personas cibles
3. /biz:biz-competitor          # Analyse concurrence
4. /biz:biz-model              # Business model
5. /biz:biz-pricing            # Strategie tarifaire
6. /biz:biz-mvp                # Definition MVP
7. /biz:biz-roadmap            # Roadmap
```

### Lever des fonds

```bash
1. /biz:biz-market             # Taille du marche
2. /biz:biz-model              # Business model
3. /biz:biz-okr                # OKRs
4. /biz:biz-pitch              # Pitch deck
```

### Lancement produit

```bash
1. /biz:biz-launch             # Plan de lancement
2. /biz:biz-pricing            # Pricing final
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Analyse le marche" | biz-research | Etude de marche |
| "Cree un business model" | biz-model | Business Model Canvas |
| "Definis le MVP" | biz-mvp | Scope MVP et priorites |
| "Prepare le pitch" | biz-pitch | Pitch deck structure |

## Anti-patterns a Eviter

- Construire sans valider le marche → `/biz:biz-research` d'abord
- MVP trop ambitieux → Limiter aux features P1 strictement
- Pricing au feeling → Analyser la concurrence et la valeur percue
- Pas de personas → Decisions produit sans direction claire
- Roadmap sans OKRs → Pas de criteres de succes mesurables
- Lancement sans plan → Preparer pre-launch, launch day et post-launch
