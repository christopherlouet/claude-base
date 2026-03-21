---
sidebar_position: 8
title: "/biz:biz-personas"
description: "Cree des personas utilisateur detailles et actionnables pour guider les decisions produit."
tags:
  - "biz"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--biz">BIZ</span>


# Agent PERSONAS

Cree des personas utilisateur detailles et actionnables pour guider les decisions produit.

## Contexte
`&lt;arguments&gt;`

## Objectif

Developper 3-5 personas bases sur des donnees reelles (analytics, interviews, support) qui servent de reference pour la conception, le developpement et le marketing.

## Workflow

- Collecter les donnees (analytics, CRM, enquetes, interviews, support)
- Identifier les patterns et segments d'utilisateurs
- Creer les profils (identite, citation, objectifs, pain points, comportements)
- Definir les Jobs-to-be-done pour chaque persona
- Creer la matrice besoins vs personas
- Definir les implications produit, UX et marketing par persona
- Valider avec les donnees et l'equipe

## Output attendu

### Personas crees (3-5 max)
| Persona | Segment | Jobs-to-be-done principal | LTV | Priorite |
|---------|---------|--------------------------|-----|----------|

### Pour chaque persona
- Identite, citation, profil, objectifs, pain points
- Comportements, processus de decision, canaux preferes
- Features prioritaires et messages marketing

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/biz:biz-research` | Recherche utilisateur |
| `/biz:biz-market` | Etude de marche |
| `/biz:biz-mvp` | Definir le MVP pour un persona |
| `/growth:growth-onboarding` | Parcours par persona |

---

IMPORTANT: Les personas doivent etre bases sur des donnees reelles, pas des suppositions.

YOU MUST limiter le nombre de personas (3-5 maximum).

NEVER creer un persona sans l'utiliser dans les decisions.

Think hard sur les jobs-to-be-done plutot que les caracteristiques demographiques.


---

## Voir aussi

- [Retour aux commandes BIZ](/docs/commands/biz)
- [Toutes les commandes](/docs/commands)
