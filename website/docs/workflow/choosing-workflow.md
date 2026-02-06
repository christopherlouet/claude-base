---
sidebar_position: 8
title: Choisir le bon workflow
description: Guide de decision pour choisir le workflow adapte
---

# Choisir le bon workflow

Guide pour selectionner le workflow adapte a votre situation.

## Arbre de decision

```mermaid
flowchart TD
    START((Besoin ?)) --> DEV{Développement ?}
    START --> OPS{Opérations ?}
    START --> QUALITY{Qualité ?}
    START --> BIZ{Business ?}

    %% Développement
    DEV -->|Nouvelle feature| FEAT["/work:work-flow-feature"]
    DEV -->|Corriger bug| BUG{Critique ?}
    BUG -->|Oui| HOTFIX["/ops:ops-hotfix"]
    BUG -->|Non| BUGFIX["/work:work-flow-bugfix"]
    DEV -->|Comprendre| EXPLORE["/work:work-explore"]
    DEV -->|TDD| TDD["/dev:dev-tdd"]

    %% Opérations
    OPS -->|Release| RELEASE["/work:work-flow-release"]
    OPS -->|Déploiement| DEPLOY{Type ?}
    DEPLOY -->|Docker| DOCKER["/ops:ops-docker"]
    DEPLOY -->|Kubernetes| K8S["/ops:ops-k8s"]
    DEPLOY -->|Vercel| VERCEL["/ops:ops-vercel"]

    %% Qualité
    QUALITY -->|Audit complet| AUDIT["/qa:qa-audit"]
    QUALITY -->|Sécurité| SEC["/qa:qa-security"]
    QUALITY -->|Performance| PERF["/qa:qa-perf"]
    QUALITY -->|Review| REVIEW["/qa:qa-review"]

    %% Business
    BIZ -->|Lancement| LAUNCH["/work:work-flow-launch"]
    BIZ -->|MVP| MVP["/biz:biz-mvp"]
    BIZ -->|Business model| MODEL["/biz:biz-model"]

    %% Styles
    style FEAT fill:#c8e6c9
    style HOTFIX fill:#ffcdd2
    style BUGFIX fill:#fff3e0
    style AUDIT fill:#e1f5fe
    style LAUNCH fill:#f3e5f5
```

## Guide rapide

| Situation | Workflow | Commande |
|-----------|----------|----------|
| Ajouter une fonctionnalite | Feature | `/work:work-flow-feature` |
| Corriger un bug | Bugfix | `/work:work-flow-bugfix` |
| Bug critique en prod | Hotfix | `/ops:ops-gitflow-hotfix` |
| Preparer une version | Release | `/work:work-flow-release` |
| Lancer un produit | Launch | `/work:work-flow-launch` |
| Comprendre le code | Explore | `/work:work-explore` |
| Planifier un changement | Plan | `/work:work-plan` |
| Developper avec tests | TDD | `/dev:dev-tdd` |
| Audit qualite | Audit | `/qa:qa-audit` |
| Review de code | Review | `/qa:qa-review` |

## Par type de projet

### Projet Web (React/Node)

```bash
# Nouvelle feature
/work:work-explore → /work:work-plan → /dev:dev-tdd → /work:work-pr

# Commandes recommandees
/dev:dev-component    # Creer des composants
/dev:dev-hook        # Creer des hooks
/dev:dev-react-perf  # Optimiser les performances
```

### Projet Mobile (Flutter)

```bash
# Nouvelle feature
/work:work-explore → /work:work-plan → /dev:dev-flutter → /work:work-pr

# Commandes recommandees
/dev:dev-flutter     # Widgets et screens
/dev:dev-supabase    # Backend Supabase
/qa:qa-mobile       # Audit mobile
```

### API Backend

```bash
# Nouvelle feature
/work:work-explore → /work:work-plan → /dev:dev-api → /work:work-pr

# Commandes recommandees
/dev:dev-api         # Endpoints REST
/dev:dev-graphql     # API GraphQL
/doc:doc-api-spec    # Documentation OpenAPI
```

### Startup / SaaS

```bash
# Lancement
/biz:biz-model → /biz:biz-mvp → /work:work-flow-launch

# Commandes recommandees
/biz:biz-*           # Business
/growth:growth-*        # Croissance
/legal:legal-*         # Legal
```

## FAQ

### Quelle est la difference entre /work:work-flow-feature et le workflow principal ?

`/work:work-flow-feature` est un **raccourci** qui enchaine automatiquement toutes les etapes du workflow principal (explore, plan, code, commit, PR).

### Quand utiliser /ops:ops-hotfix vs /work:work-flow-bugfix ?

- **hotfix** : Bug critique en production, besoin immediat
- **bugfix** : Bug normal, peut attendre la prochaine release

### Comment savoir si j'ai besoin d'un audit ?

Utilisez `/qa:qa-audit` :
- Avant une release majeure
- Avant un audit externe
- Apres des changements importants
- Regulierement (mensuel)

### Puis-je combiner plusieurs workflows ?

Oui ! Par exemple :
```bash
# Feature avec audit de securite
/work:work-flow-feature "Auth" → /qa:qa-security → /work:work-pr
```

---

## Voir aussi

- [Tous les workflows](/docs/workflow)
- [Commands](/docs/commands)
- [Assistant](/docs/commands/other/assistant)
