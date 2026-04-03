---
sidebar_position: 6
title: "/work:work-explore"
description: "Analyse le codebase sans ecrire de code. Mode EXPLORATION uniquement."
tags:
  - "work"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--work">WORK</span>


# Agent WORK-EXPLORE

Analyse le codebase sans ecrire de code. Mode EXPLORATION uniquement.

## Contexte
`&lt;arguments&gt;`

## Objectif

Comprendre en profondeur une partie du codebase avant toute modification.
L'exploration est la premiere etape obligatoire : **EXPLORE -&gt; PLAN -&gt; CODE -&gt; COMMIT**

## Workflow

- Identifier le perimetre : recherche par nom (glob), par contenu (grep), navigation arborescence
- Localiser les points d'entree (routes, App.tsx, index.ts, bin/, commands/)
- Analyser l'architecture : structure dossiers, separation responsabilites, patterns (MVC, Clean Arch...)
- Analyser le code : conventions de nommage, style (fonctionnel/OOP), gestion erreurs, typage
- Lister les dependances principales et internes
- Examiner les tests : framework, couverture, patterns (mocks, fixtures)
- Lire la documentation existante (README, docs/, JSDoc, types)
- Identifier les risques et la dette technique

## Output attendu

1. **Fichiers cles** : Tableau (fichier, role, lignes)
2. **Architecture** : Structure et patterns identifies
3. **Conventions** : Nommage, style, tests
4. **Dependances** : Packages et leurs usages
5. **Points d'attention** : Risques et dette technique
6. **Recommandations** : Suggestions pour la suite

## Agents lies

| Apres | Usage |
|-------|-------|
| `/work:work-plan` | Planifier les modifications |
| `/doc:doc-explain` | Expliquer du code complexe |
| `/doc:doc-onboard` | Decouverte complete d'un projet |

---

IMPORTANT: Ne jamais ecrire de code en mode exploration - analyse seulement.

YOU MUST lire le code source, pas seulement les noms de fichiers.

NEVER supposer le fonctionnement - verifier dans le code.

Think hard avant de repondre pour fournir une analyse complete et utile.


---

## Voir aussi

- [Retour aux commandes WORK](/docs/commands/work)
- [Toutes les commandes](/docs/commands)
