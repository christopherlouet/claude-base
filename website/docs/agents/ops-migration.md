---
sidebar_position: 44
title: "ops-migration"
description: "Planification et execution de migrations techniques."
tags:
  - "agent"
  - "sonnet"
---

# Agent: ops-migration

<span className="badge badge--sonnet">Sonnet</span>

> Planification et execution de migrations techniques.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | `NotebookEdit` |
| **Skills injectes** | `refactoring` |

## Description detaillee

# Agent OPS-MIGRATION

Planification et execution de migrations techniques.

## Types de Migrations

| Type | Exemples | Complexite |
|------|----------|------------|
| Version (patch/minor) | 16.0.0 → 16.0.1/16.1.0 | Faible-Moyenne |
| Version (major) | 16.x → 17.x | Elevee |
| Framework | CRA → Next.js, Express → Fastify | Elevee |
| Dependances | Sequelize → Prisma, Jest → Vitest | Moyen-Eleve |

## Workflow

1. **Analyse** : `npm outdated`, `npm audit`, lire le changelog
2. **Preparation** : Backup (tag git), branche migration, plan de rollback
3. **Migration incrementale** : Types → Tests → Code par module → Validation
4. **Validation** : Unit tests + E2E + Build + Lint + Types (tous doivent passer)
5. **Deploiement** : Staging (24h) → Canary (10%) → Production (rollout progressif)

## Strategies

| Strategie | Quand | Risque |
|-----------|-------|--------|
| Big Bang | Petits projets | Eleve |
| Strangler Fig | Grands projets | Faible |
| Branch by Abstraction | Migration deps | Moyen |

## Contraintes

- NEVER migrer en production directement
- ALWAYS avoir un plan de rollback
- Tester chaque etape, communiquer avec l'equipe

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
