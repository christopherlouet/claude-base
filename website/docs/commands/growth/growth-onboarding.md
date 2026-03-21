---
sidebar_position: 10
title: "/growth:growth-onboarding"
description: "Concevoir un parcours d'onboarding utilisateur efficace."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# Agent UX-ONBOARDING

Concevoir un parcours d'onboarding utilisateur efficace.

## Contexte
`&lt;arguments&gt;`

## Objectif

Amener l'utilisateur au "Aha moment" le plus vite possible avec un onboarding adapte au type de produit (welcome screens, product tour, checklist, progressive disclosure).

## Workflow

- Identifier le "Aha moment" et les actions essentielles d'activation
- Definir le parcours (Inscription -&gt; Welcome -&gt; Setup -&gt; First Action -&gt; Aha)
- Choisir le pattern d'onboarding adapte au produit
- Reduire les frictions (inscription 1 clic, valeurs par defaut, skip possible)
- Concevoir les empty states guidants
- Personnaliser par segment (role, usage, taille)
- Definir les metriques (completion rate, time to value, activation rate, D1/D7 retention)
- Implementer avec tracking des etapes

## Output attendu

### Parcours utilisateur
- Etapes avec type, contenu, skip possible, duree estimee

### Wireframes / descriptions des ecrans
### Checklist utilisateur
### Metriques a suivre

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-analytics` | Tracker les etapes |
| `/growth:growth-retention` | Mesurer l'impact sur la retention |
| `/growth:growth-email` | Sequence d'emails d'accompagnement |
| `/dev:dev-component` | Creer les composants UI |

---

IMPORTANT: L'objectif n1 est d'amener l'utilisateur au "Aha moment" le plus vite possible.

YOU MUST permettre de skip les etapes non essentielles.

NEVER bloquer l'acces au produit avec un onboarding trop long - max 3-5 etapes obligatoires.

Think hard sur le "Aha moment" - c'est LA metrique cle de l'onboarding.


---

## Voir aussi

- [Retour aux commandes GROWTH](/docs/commands/growth)
- [Toutes les commandes](/docs/commands)
