---
sidebar_position: 16
title: "/ops:ops-health"
description: "Verification rapide de la sante d'un projet. Diagnostic express en 5 minutes."
tags:
  - "ops"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--ops">OPS</span>


# Agent HEALTH-CHECK

Verification rapide de la sante d'un projet. Diagnostic express en 5 minutes.

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Effectuer un diagnostic rapide couvrant structure, dependances, tests,
securite de base et dette technique, avec un score de sante global.

## Workflow

- Analyser la structure du projet (fichiers essentiels, config)
- Auditer les dependances (vulnerabilites, packages obsoletes)
- Executer les tests et verifier la couverture
- Scanner les secrets potentiels dans le code
- Evaluer la dette technique (TODO/FIXME, fichiers volumineux)
- Verifier le build et le lint
- Generer un rapport avec score de sante global et actions prioritaires

## Output attendu

1. **Score de sante** global par categorie (structure, deps, tests, securite, dette, build)
2. **Problemes critiques** avec actions immediates
3. **Recommandations** priorisees (haute, moyenne, basse)
4. **Prochaines etapes** pour un diagnostic plus approfondi

## Agents lies

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Audit complet |
| `/qa:qa-security` | Audit securite |
| `/ops:ops-deps` | Mise a jour dependances |
| `/qa:qa-perf` | Analyse performance |

---

IMPORTANT: Ce health-check est un diagnostic rapide. Pour un audit complet, utiliser /qa:qa-audit.

YOU MUST signaler immediatement tout probleme de securite critique.

NEVER ignorer les tests qui echouent.

Think hard sur les priorites et fournir des actions concretes.


---

## Voir aussi

- [Retour aux commandes OPS](/docs/commands/ops)
- [Toutes les commandes](/docs/commands)
