---
sidebar_position: 2
title: Orchestrateur (/assistant)
description: Point d'entree unique qui orchestre commandes, agents et skills
---

# Orchestrateur (/assistant)

> Le point d'entree intelligent qui vous guide vers les bonnes ressources

## Qu'est-ce que l'Orchestrateur ?

L'**orchestrateur** (commande `/assistant`) est le point d'entree unique de claude-socle. Il analyse votre demande, detecte le contexte de votre projet, et vous oriente vers les commandes, agents et skills les plus adaptes.

```
┌─────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATEUR                               │
│                       /assistant                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    ┌─────────┐     ┌─────────┐     ┌─────────┐                 │
│    │ Analyse │ ──▶ │ Detecte │ ──▶ │ Oriente │                 │
│    │ demande │     │ contexte│     │  vers   │                 │
│    └─────────┘     └─────────┘     └─────────┘                 │
│                                         │                       │
│         ┌───────────────────────────────┼───────────────────┐  │
│         │                               │                   │  │
│         ▼                               ▼                   ▼  │
│    ┌─────────┐                    ┌─────────┐         ┌───────┐│
│    │COMMANDS │                    │ AGENTS  │         │SKILLS ││
│    │  (110)  │                    │  (51)   │         │ (32)  ││
│    └─────────┘                    └─────────┘         └───────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Pourquoi utiliser l'Orchestrateur ?

### 1. Simplification

Au lieu de memoriser 110 commandes, demandez simplement ce que vous voulez faire :

```bash
# Au lieu de chercher la bonne commande...
/assistant "Je veux ajouter une feature d'authentification"

# L'orchestrateur propose le workflow adapte :
# 1. /work-explore - Comprendre le code existant
# 2. /work-specify - Creer la specification
# 3. /work-plan - Planifier l'implementation
# 4. /dev-tdd - Developper avec tests
# 5. /qa-security - Auditer la securite
# 6. /work-pr - Creer la PR
```

### 2. Detection automatique du contexte

L'orchestrateur detecte automatiquement :

| Detection | Indicateurs | Actions proposees |
|-----------|-------------|-------------------|
| **Type de projet** | package.json, pubspec.yaml, go.mod... | Commandes adaptees au stack |
| **Technologies** | React, Flutter, Python, Go... | Skills et agents specialises |
| **Situation** | Bug, feature, release... | Workflow complet |

### 3. Recommandations intelligentes

```
┌────────────────────────────────────────────────────────────────────────┐
│ DETECTION                           RECOMMANDATION                      │
├────────────────────────────────────────────────────────────────────────┤
│                                                                        │
│ package.json + React          ──▶   /dev-component, /dev-hook          │
│ pubspec.yaml + Flutter        ──▶   /dev-flutter, /dev-supabase        │
│ "bug" dans la demande         ──▶   /work-flow-bugfix                  │
│ "release" dans la demande     ──▶   /work-flow-release                 │
│ "audit" dans la demande       ──▶   /qa-audit                          │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

## Comment fonctionne l'Orchestrateur ?

### Flux de decision

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

### Integration avec l'ecosysteme

L'orchestrateur connait et utilise tous les composants :

| Composant | Utilisation par l'orchestrateur |
|-----------|--------------------------------|
| **Commands** | Propose les commandes adaptees au contexte |
| **Agents** | Mentionne les agents qui seront actives automatiquement |
| **Skills** | Indique les skills qui se declencheront |
| **Templates** | Guide vers les templates pour les taches complexes |
| **Workflows** | Recommande les workflows complets quand pertinent |

## Quand utiliser l'Orchestrateur ?

### Utilisez `/assistant` quand :

- Vous etes **nouveau** sur claude-socle
- Vous ne savez pas **quelle commande** utiliser
- Vous voulez un **workflow complet** pour une tache
- Vous changez de **type de projet** (Web → Mobile par exemple)
- Vous voulez une **vue d'ensemble** des options disponibles

### Utilisez les commandes directes quand :

- Vous connaissez deja la commande exacte
- Vous voulez une action rapide et precise
- Vous etes en milieu de workflow

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

1. **Commencez par l'orchestrateur** si vous etes nouveau
2. **Soyez descriptif** dans vos demandes ("Je veux..." plutot que juste "auth")
3. **Mentionnez le contexte** si pertinent ("pour l'app mobile", "en production")
4. **Suivez les workflows proposes** pour des resultats optimaux

---

## Voir aussi

- [Commands](/docs/concepts/commands) - Commandes manuelles
- [Agents](/docs/concepts/agents) - Sub-agents autonomes
- [Skills](/docs/concepts/skills) - Skills auto-declenches
- [Reference /assistant](/docs/commands/assistant) - Documentation complete de la commande
