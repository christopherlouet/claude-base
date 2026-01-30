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
│  │    (111)    │  │    (52)     │  │    (32)     │             │
│  │             │  │             │  │             │             │
│  │ Invocation  │  │ Delegation  │  │ Activation  │             │
│  │  manuelle   │  │ automatique │  │ automatique │             │
│  │   /xxx      │  │  par Claude │  │ par contexte│             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  TEMPLATES  │  │    RULES    │  │   HOOKS     │             │
│  │    (3)      │  │    (17)     │  │    (4)      │             │
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
# → Workflow recommande: /work-flow-feature
# → "Voulez-vous que je lance ce workflow ?"
# → Attend votre confirmation
```

### Mode Automatique (`/assistant-auto`)

Pour les **utilisateurs avances** qui veulent une **execution immediate** :

```bash
/assistant-auto "Ajouter une feature d'authentification"

# Claude analyse et execute directement :
# → Detecte: nouvelle feature
# → Lance: /work-flow-feature "Ajouter une feature d'authentification"
```

## Detection automatique du contexte

L'orchestrateur detecte automatiquement votre environnement :

| Indicateur | Type de projet | Commandes recommandees |
|------------|----------------|------------------------|
| `package.json` + React/Next/Vue | **Web Frontend** | `/dev-component`, `/dev-hook`, `/dev-react-perf` |
| `pubspec.yaml` + Flutter | **Mobile** | `/dev-flutter`, `/dev-supabase`, `/qa-mobile` |
| `package.json` + Express/Fastify/NestJS | **API Node** | `/dev-api`, `/dev-graphql`, `/dev-trpc` |
| `requirements.txt` / `pyproject.toml` | **Python** | `/dev-api`, `/dev-tdd` |
| `go.mod` | **Go** | `/dev-api`, `/dev-tdd` |
| `init.lua` / `.config/nvim` | **Neovim** | `/dev-neovim`, `/qa-neovim` |
| Airflow/dbt/Spark | **Data** | `/data-pipeline`, `/data-modeling` |
| `Dockerfile` / `docker-compose.yml` | **DevOps** | `/ops-docker`, `/ops-k8s` |
| Proxmox / `bpg/proxmox` provider | **Infrastructure** | `/ops-proxmox`, `/ops-infra-code` |

## Guide de decision rapide

```
┌────────────────────────────────────────────────────────────────────────┐
│ JE VEUX...                              →  UTILISE                     │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│ COMPRENDRE                                                             │
│ Explorer un codebase                    →  /work-explore               │
│ Decouvrir un nouveau projet             →  /doc-onboard                │
│ Comprendre du code complexe             →  /doc-explain                │
│                                                                        │
│ PLANIFIER                                                              │
│ Creer une specification                 →  /work-specify               │
│ Planifier une implementation            →  /work-plan                  │
│ Definir un MVP                          →  /biz-mvp                    │
│                                                                        │
│ DEVELOPPER                                                             │
│ Ecrire du code avec tests               →  /dev-tdd                    │
│ Creer un composant React/Vue            →  /dev-component              │
│ Creer une API REST                      →  /dev-api                    │
│ Creer un screen Flutter                 →  /dev-flutter                │
│ Corriger un bug                         →  /dev-debug                  │
│                                                                        │
│ VERIFIER                                                               │
│ Code review                             →  /qa-review                  │
│ Audit de securite                       →  /qa-security                │
│ Audit complet                           →  /qa-audit                   │
│                                                                        │
│ LIVRER                                                                 │
│ Creer un commit                         →  /work-commit                │
│ Creer une PR                            →  /work-pr                    │
│ Publier une release                     →  /ops-release                │
│                                                                        │
│ DEPLOYER                                                               │
│ Dockeriser                              →  /ops-docker                 │
│ Infrastructure as Code                  →  /ops-infra-code             │
│ CI/CD                                   →  /ops-ci                     │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Workflows par type de projet

### Web (React/Next.js/Vue)

```
/work-explore → /work-specify → /work-plan → /dev-component → /dev-tdd → /qa-review → /work-pr
```

### Mobile (Flutter)

```
/work-explore → /work-specify → /work-plan → /dev-flutter + /dev-supabase → /qa-mobile → /work-pr
```

### API Backend (Node/Python/Go)

```
/work-explore → /work-specify → /work-plan → /dev-api → /dev-tdd → /qa-security → /doc-api-spec → /work-pr
```

### Infrastructure Proxmox

```
/work-explore → /ops-proxmox → /ops-monitoring → /ops-backup
```

## Sub-Agents actives automatiquement

L'orchestrateur connait les 57 agents specialises et les active selon le contexte :

| Contexte detecte | Agent active | Modele |
|------------------|--------------|--------|
| "Explorer le code" | `work-explore` | haiku |
| "Audit securite", "OWASP" | `qa-security` | sonnet |
| "Performance", "Core Web Vitals" | `qa-perf` | sonnet |
| "Accessibilite", "WCAG" | `qa-a11y` | haiku |
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
| "TDD", "test first" | `test-driven-development` | Cycle Red-Green-Refactor |
| "commit", "message" | `generating-commit-messages` | Conventional Commits |
| "review", "code review" | `reviewing-code` | Revue approfondie |
| "PR", "pull request" | `creating-pull-requests` | PR structuree |
| "Terraform", "IaC" | `infrastructure-as-code` | Infrastructure as Code |
| "Proxmox", "PVE" | `proxmox-infrastructure` | Gestion Proxmox |
| "Docker", "Dockerfile" | `docker-containerization` | Containerisation |

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
    │    - Workflow: /work-flow-bugfix    │
    │    - Ou etapes manuelles:           │
    │      /work-explore → /dev-debug     │
    │      → /dev-test → /work-pr         │
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
| feature, ajouter, creer | `/work-flow-feature` |
| bug, fix, corriger, erreur | `/work-flow-bugfix` |
| release, version, tag | `/work-flow-release` |
| lancement, MVP, produit | `/work-flow-launch` |
| audit securite, OWASP | `/qa-security` |
| audit complet, qualite | `/qa-audit` |
| explorer, comprendre | `/work-explore` |
| commit | `/work-commit` |
| PR, pull request | `/work-pr` |
| tests, TDD | `/dev-tdd` |
| refactoring, nettoyer | `/dev-refactor` |
| debug, deboguer | `/dev-debug` |
| Docker, container | `/ops-docker` |
| CI/CD, pipeline | `/ops-ci` |

## Exemples d'utilisation

### Nouvelle feature

```bash
/assistant "Je veux ajouter un systeme de notifications push"

# Reponse de l'orchestrateur :
# Type de projet: Mobile (Flutter detecte)
# Workflow recommande:
# 1. /work-explore - Comprendre l'architecture actuelle
# 2. /work-specify - Specifier les User Stories
# 3. /work-plan - Planifier l'implementation
# 4. /dev-flutter - Creer les widgets
# 5. /dev-supabase - Configurer le backend
# 6. /qa-mobile - Tester sur devices
# 7. /work-pr - Creer la PR
```

### Correction de bug

```bash
/assistant "L'application crash au login"

# Reponse de l'orchestrateur :
# Situation detectee: Bug critique
# Commande recommandee: /work-flow-bugfix
# Ou workflow manuel:
# 1. /work-explore - Localiser le probleme
# 2. /dev-debug - Investiguer la cause
# 3. /dev-test - Ecrire un test de regression
# 4. /work-commit - Commiter le fix
```

### Question generale

```bash
/assistant "Comment fonctionne l'authentification dans ce projet ?"

# Reponse de l'orchestrateur :
# Type de demande: Exploration/Comprehension
# Commande recommandee: /work-explore ou /doc-explain
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
- [Reference /assistant](/docs/commands/assistant) - Mode guide (avec confirmation)
- [Reference /assistant-auto](/docs/commands/assistant-auto) - Mode automatique (execution directe)
