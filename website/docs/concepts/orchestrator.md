---
sidebar_position: 2
title: Orchestrateur (/assistant)
description: Point d'entree unique qui orchestre commandes, agents et skills
---

# Orchestrateur (/assistant)

> Le point d'entree intelligent qui vous guide vers les bonnes ressources

## Qu'est-ce que l'Orchestrateur ?

L'**orchestrateur** est le point d'entree unique de claude-socle. Il analyse votre demande, detecte le contexte de votre projet, et vous oriente vers les commandes, agents et skills les plus adaptes.

```
┌─────────────────────────────────────────────────────────────────┐
│                        SOCLE CLAUDE CODE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  COMMANDS   │  │   AGENTS    │  │   SKILLS    │             │
│  │    (120)    │  │    (57)     │  │    (41)     │             │
│  │             │  │             │  │             │             │
│  │ Invocation  │  │ Delegation  │  │ Activation  │             │
│  │  manuelle   │  │ automatique │  │ automatique │             │
│  │   /xxx      │  │  par Claude │  │ par contexte│             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  TEMPLATES  │  │    RULES    │  │   HOOKS     │             │
│  │    (3)      │  │    (21)     │  │    (26)     │             │
│  │             │  │             │  │             │             │
│  │ Structures  │  │ Conventions │  │ Automation  │             │
│  │ de fichiers │  │  par path   │  │ pre/post    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Deux modes disponibles

| Commande | Mode | Comportement |
|----------|------|--------------|
| `/assistant` | **Guide** | Analyse → Recommande → Attend confirmation |
| `/assistant-auto` | **Automatique** | Analyse → Execute directement le workflow |

### Mode Guide (`/assistant`)

Pour les **nouveaux utilisateurs** ou quand vous voulez **valider** avant d'executer :

```bash
/assistant "Ajouter une feature d'authentification"

# Claude analyse et propose :
# → Workflow recommande: /work:work-flow-feature
# → "Voulez-vous que je lance ce workflow ?"
# → Attend votre confirmation
```

### Mode Automatique (`/assistant-auto`)

Pour les **utilisateurs avances** qui veulent une **execution immediate** :

```bash
/assistant-auto "Ajouter une feature d'authentification"

# Claude analyse et execute directement :
# → Detecte: nouvelle feature
# → Lance: /work:work-flow-feature "Ajouter une feature d'authentification"
```

## Detection automatique du contexte

L'orchestrateur detecte automatiquement votre environnement :

| Indicateur | Type de projet | Commandes recommandees |
|------------|----------------|------------------------|
| `package.json` + React/Next/Vue | **Web Frontend** | `/dev:dev-component`, `/dev:dev-hook`, `/dev:dev-react-perf` |
| `pubspec.yaml` + Flutter | **Mobile** | `/dev:dev-flutter`, `/dev:dev-supabase`, `/qa:qa-mobile` |
| `package.json` + Express/Fastify/NestJS | **API Node** | `/dev:dev-api`, `/dev:dev-graphql`, `/dev:dev-trpc` |
| `requirements.txt` / `pyproject.toml` | **Python** | `/dev:dev-api`, `/dev:dev-tdd` |
| `go.mod` | **Go** | `/dev:dev-api`, `/dev:dev-tdd` |
| `init.lua` / `.config/nvim` | **Neovim** | `/dev:dev-neovim`, `/qa:qa-neovim` |
| Airflow/dbt/Spark | **Data** | `/data:data-pipeline`, `/data:data-modeling` |
| `Dockerfile` / `docker-compose.yml` | **DevOps** | `/ops:ops-docker`, `/ops:ops-k8s` |
| Proxmox / `bpg/proxmox` provider | **Infrastructure** | `/ops:ops-proxmox`, `/ops:ops-infra-code` |

## Guide de decision rapide

```
┌────────────────────────────────────────────────────────────────────────┐
│ JE VEUX...                              →  UTILISE                     │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│ COMPRENDRE                                                             │
│ Explorer un codebase                    →  /work:work-explore               │
│ Decouvrir un nouveau projet             →  /doc:doc-onboard                │
│ Comprendre du code complexe             →  /doc:doc-explain                │
│                                                                        │
│ PLANIFIER                                                              │
│ Creer une specification                 →  /work:work-specify               │
│ Planifier une implementation            →  /work:work-plan                  │
│ Definir un MVP                          →  /biz:biz-mvp                    │
│                                                                        │
│ DEVELOPPER                                                             │
│ Ecrire du code avec tests               →  /dev:dev-tdd                    │
│ Creer un composant React/Vue            →  /dev:dev-component              │
│ Creer une API REST                      →  /dev:dev-api                    │
│ Creer un screen Flutter                 →  /dev:dev-flutter                │
│ Corriger un bug                         →  /dev:dev-debug                  │
│                                                                        │
│ VERIFIER                                                               │
│ Code review                             →  /qa:qa-review                  │
│ Audit de securite                       →  /qa:qa-security                │
│ Audit complet                           →  /qa:qa-audit                   │
│                                                                        │
│ LIVRER                                                                 │
│ Creer un commit                         →  /work:work-commit                │
│ Creer une PR                            →  /work:work-pr                    │
│ Publier une release                     →  /ops:ops-release                │
│                                                                        │
│ DEPLOYER                                                               │
│ Dockeriser                              →  /ops:ops-docker                 │
│ Infrastructure as Code                  →  /ops:ops-infra-code             │
│ CI/CD                                   →  /ops:ops-ci                     │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Workflows par type de projet

### Web (React/Next.js/Vue)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-component → /dev:dev-tdd → /qa:qa-review → /work:work-pr
```

### Mobile (Flutter)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
```

### API Backend (Node/Python/Go)

```
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-api → /dev:dev-tdd → /qa:qa-security → /doc:doc-api-spec → /work:work-pr
```

### Infrastructure Proxmox

```
/work:work-explore → /ops:ops-proxmox → /ops:ops-monitoring → /ops:ops-backup
```

## Sub-Agents actives automatiquement

L'orchestrateur connait les 57 agents specialises et les active selon le contexte :

| Contexte detecte | Agent active | Modele |
|------------------|--------------|--------|
| "Explorer le code" | `work-explore` | haiku |
| "Audit securite", "OWASP" | `qa-security` | sonnet |
| "Performance", "Core Web Vitals" | `qa-perf` | sonnet |
| "Accessibilite", "WCAG" | `wcag-audit` | haiku |
| "Bug", "Deboguer" | `dev-debug` | sonnet |
| "Flutter", "Widget" | `dev-flutter` | sonnet |
| "Terraform", "IaC" | `ops-infra-code` | sonnet |
| "Proxmox", "VM", "LXC" | `ops-proxmox` | sonnet |
| "Docker", "Container" | `ops-docker` | haiku |

```
Utilisateur: "Fais un audit de securite"
     │
     ▼
Claude detecte: securite → delegue a qa-security agent
     │
     ▼
Agent qa-security (contexte isole, lecture seule)
     │
     ▼
Resultat renvoye a la conversation principale
```

## Skills declenches automatiquement

Les 41 skills s'activent selon les mots-cles dans la conversation :

| Mots-cles | Skill active | Action |
|-----------|--------------|--------|
| "TDD", "test first" | `dev-tdd` | Cycle Red-Green-Refactor |
| "commit", "message" | `work-commit` | Conventional Commits |
| "review", "code review" | `qa-review` | Revue approfondie |
| "PR", "pull request" | `work-pr` | PR structuree |
| "Terraform", "IaC" | `ops-infra-code` | Infrastructure as Code |
| "Proxmox", "PVE" | `ops-proxmox` | Gestion Proxmox |
| "Docker", "Dockerfile" | `ops-docker` | Containerisation |

## Flux de decision

```
Utilisateur: "/assistant Je veux corriger un bug de login"
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 1. ANALYSE DE LA DEMANDE            │
    │    - Mots-cles: "corriger", "bug"   │
    │    - Domaine: authentification      │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 2. DETECTION DU PROJET              │
    │    - package.json detecte → Web     │
    │    - React detecte → Frontend       │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 3. RECOMMANDATION                   │
    │    - Workflow: /work:work-flow-bugfix    │
    │    - Ou etapes manuelles:           │
    │      /work:work-explore → /dev:dev-debug     │
    │      → /dev:dev-test → /work:work-pr         │
    └─────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────┐
    │ 4. PROPOSITION A L'UTILISATEUR      │
    │    Avec explications et options     │
    └─────────────────────────────────────┘
```

## Quand utiliser l'Orchestrateur ?

### Utilisez `/assistant` (mode guide) quand :

- Vous etes **nouveau** sur claude-socle
- Vous ne savez pas **quelle commande** utiliser
- Vous voulez **valider** le workflow avant execution
- Vous changez de **type de projet** (Web → Mobile par exemple)
- Vous voulez une **vue d'ensemble** des options disponibles

### Utilisez `/assistant-auto` (mode automatique) quand :

- Vous etes **familier** avec claude-socle
- Vous voulez une **execution immediate** sans confirmation
- Vous faites des taches **repetitives** (features, bugfixes)
- Vous preferez la **rapidite** a la validation

### Utilisez les commandes directes quand :

- Vous connaissez deja la commande exacte
- Vous voulez une action rapide et precise
- Vous etes en milieu de workflow

## Mapping automatique (`/assistant-auto`)

| Votre demande contient... | Workflow execute |
|---------------------------|------------------|
| feature, ajouter, creer | `/work:work-flow-feature` |
| bug, fix, corriger, erreur | `/work:work-flow-bugfix` |
| release, version, tag | `/work:work-flow-release` |
| lancement, MVP, produit | `/work:work-flow-launch` |
| audit securite, OWASP | `/qa:qa-security` |
| audit complet, qualite | `/qa:qa-audit` |
| explorer, comprendre | `/work:work-explore` |
| commit | `/work:work-commit` |
| PR, pull request | `/work:work-pr` |
| tests, TDD | `/dev:dev-tdd` |
| refactoring, nettoyer | `/dev:dev-refactor` |
| debug, deboguer | `/dev:dev-debug` |
| Docker, container | `/ops:ops-docker` |
| CI/CD, pipeline | `/ops:ops-ci` |

## Exemples d'utilisation

### Nouvelle feature

```bash
/assistant "Je veux ajouter un systeme de notifications push"

# Reponse de l'orchestrateur :
# Type de projet: Mobile (Flutter detecte)
# Workflow recommande:
# 1. /work:work-explore - Comprendre l'architecture actuelle
# 2. /work:work-specify - Specifier les User Stories
# 3. /work:work-plan - Planifier l'implementation
# 4. /dev:dev-flutter - Creer les widgets
# 5. /dev:dev-supabase - Configurer le backend
# 6. /qa:qa-mobile - Tester sur devices
# 7. /work:work-pr - Creer la PR
```

### Correction de bug

```bash
/assistant "L'application crash au login"

# Reponse de l'orchestrateur :
# Situation detectee: Bug critique
# Commande recommandee: /work:work-flow-bugfix
# Ou workflow manuel:
# 1. /work:work-explore - Localiser le probleme
# 2. /dev:dev-debug - Investiguer la cause
# 3. /dev:dev-test - Ecrire un test de regression
# 4. /work:work-commit - Commiter le fix
```

### Question generale

```bash
/assistant "Comment fonctionne l'authentification dans ce projet ?"

# Reponse de l'orchestrateur :
# Type de demande: Exploration/Comprehension
# Commande recommandee: /work:work-explore ou /doc:doc-explain
# Agent active automatiquement: work-explore (haiku)
```

## Relation avec les autres concepts

```
                    /assistant (Orchestrateur)
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
      ┌─────────┐    ┌─────────┐    ┌─────────┐
      │COMMANDS │    │ AGENTS  │    │ SKILLS  │
      │         │    │         │    │         │
      │ Manuel  │    │ Auto    │    │ Auto    │
      │ /xxx    │    │ delegue │    │ mots-cle│
      └─────────┘    └─────────┘    └─────────┘
           │               │               │
           └───────────────┴───────────────┘
                           │
                    ┌──────┴──────┐
                    │   RULES     │
                    │   HOOKS     │
                    │   TEMPLATES │
                    └─────────────┘
```

L'orchestrateur est le **chef d'orchestre** qui :
- **Comprend** votre demande
- **Choisit** les bons instruments (commands, agents, skills)
- **Dirige** le workflow de maniere coherente

## Bonnes pratiques

1. **Commencez par `/assistant`** si vous etes nouveau (mode guide)
2. **Passez a `/assistant-auto`** une fois familier avec les workflows
3. **Soyez descriptif** dans vos demandes ("Je veux..." plutot que juste "auth")
4. **Mentionnez le contexte** si pertinent ("pour l'app mobile", "en production")
5. **Suivez les workflows proposes** pour des resultats optimaux

---

## Voir aussi

- [Commands](/docs/concepts/commands) - Commandes manuelles
- [Agents](/docs/concepts/agents) - Sub-agents autonomes
- [Skills](/docs/concepts/skills) - Skills auto-declenches
- [Reference /assistant](/docs/commands/other/assistant) - Mode guide (avec confirmation)
- [Reference /assistant-auto](/docs/commands/other/assistant-auto) - Mode automatique (execution directe)
