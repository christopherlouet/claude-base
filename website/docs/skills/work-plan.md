---
sidebar_position: 41
title: "work-plan"
description: "Planifier l'implémentation d'une fonctionnalité. Utiliser quand l'utilisateur veut planifier, architecturer, définir une approche, ou avant de coder une feature complexe."
tags:
  - "skill"
  - "fork"
---

# Skill: work-plan

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Planifier l'implémentation d'une fonctionnalité. Utiliser quand l'utilisateur veut planifier, architecturer, définir une approche, ou avant de coder une feature complexe.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Bash` |
| **Mots-cles** | `work`, `plan`, `pattern_similaire`, `*.ts`, `dependencies` |

## Description detaillee

# Planifier une Implémentation

## Objectif

Définir un plan d'action AVANT de coder. Le plan doit être validé avant l'implémentation.

## Instructions

### 1. Comprendre la demande

**Questions à clarifier:**
- Quel est l'objectif métier ?
- Quels sont les critères d'acceptance ?
- Y a-t-il des contraintes techniques ?
- Quelle est la priorité/deadline ?

### 2. Analyser l'existant

```bash
# Chercher du code similaire
grep -rn "pattern_similaire" --include="*.ts" | head -20

# Identifier les dépendances
cat package.json | grep -A 20 '"dependencies"'
```

### 3. Définir l'architecture

**Décisions à prendre:**
- Où placer le nouveau code ?
- Quels patterns utiliser ?
- Quelles interfaces créer ?
- Comment gérer les erreurs ?

### 4. Lister les tâches

Décomposer en tâches atomiques de 1-2h max.

## Template de plan

```markdown
## Plan : [Nom de la feature]

### Objectif
[Description en 1-2 phrases]

### Fichiers à créer
| Fichier | Description |
|---------|-------------|
| `src/xxx.ts` | [Rôle] |

### Fichiers à modifier
| Fichier | Modifications |
|---------|---------------|
| `src/yyy.ts` | [Changements] |

### Tests à écrire
- [ ] Test cas nominal
- [ ] Test edge cases
- [ ] Test erreurs

### Étapes d'implémentation
1. [ ] [Tâche 1]
2. [ ] [Tâche 2]
3. [ ] [Tâche 3]

### Risques identifiés
| Risque | Mitigation |
|--------|------------|
| [Risque 1] | [Solution] |

### Dépendances
- [ ] [Prérequis 1]
```

## Règles

- JAMAIS coder sans plan validé
- Un plan = une feature
- Estimer la complexité, pas le temps
- Identifier les risques AVANT

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux work..."_
- _"Je veux plan..."_
- _"Je veux pattern_similaire..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple de planification d'implémentation

# Exemple de planification d'implémentation

## Contexte
Ajouter un système de notifications en temps réel à une application.

## Plan produit

### Objectif
Permettre aux utilisateurs de recevoir des notifications en temps réel (nouveaux messages, mentions, alertes système).

### Critères d'acceptance
- [ ] Notifications push en temps réel
- [ ] Badge de compteur non-lu
- [ ] Historique des notifications
- [ ] Marquer comme lu/non-lu
- [ ] Préférences utilisateur

## Plan technique

### Architecture choisie

```
┌─────────────┐     WebSocket      ┌─────────────┐
│   Client    │◄──────────────────►│   Server    │
│  (React)    │                    │  (Node.js)  │
└─────────────┘                    └──────┬──────┘
                                          │
                                   ┌──────▼──────┐
                                   │   Redis     │
                                   │  (Pub/Sub)  │
                                   └──────┬──────┘
                                          │
                                   ┌──────▼──────┐
                                   │ PostgreSQL  │
                                   │ (stockage)  │
                                   └─────────────┘
```

### Fichiers à créer

| Fichier | Description |
|---------|-------------|
| `src/services/websocket.ts` | Client WebSocket |
| `src/hooks/useNotifications.ts` | Hook React |
| `src/components/NotificationBell.tsx` | Composant UI |
| `src/components/NotificationList.tsx` | Liste déroulante |
| `server/ws/notification-handler.ts` | Handler serveur |
| `prisma/migrations/xxx_notifications.sql` | Schema DB |

### Fichiers à modifier

| Fichier | Modifications |
|---------|---------------|
| `src/app/layout.tsx` | Ajouter provider notifications |
| `src/components/Header.tsx` | Ajouter NotificationBell |
| `server/index.ts` | Initialiser WebSocket server |

### Étapes d'implémentation

1. **Backend (jour 1-2)**
   - [ ] Créer table `notifications` dans Prisma
   - [ ] Implémenter WebSocket server avec Socket.io
   - [ ] Configurer Redis Pub/Sub
   - [ ] Créer endpoints REST pour historique

2. **Frontend (jour 3-4)**
   - [ ] Créer hook `useNotifications`
   - [ ] Implémenter `NotificationBell` avec badge
   - [ ] Créer `NotificationList` avec infinite scroll
   - [ ] Ajouter animations (Framer Motion)

3. **Intégration (jour 5)**
   - [ ] Connecter frontend/backend
   - [ ] Tests E2E
   - [ ] Documentation

### Risques identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Déconnexions WebSocket | Moyenne | Élevé | Reconnexion auto + queue offline |
| Surcharge Redis | Faible | Élevé | Rate limiting + TTL |
| Performance liste | Moyenne | Moyen | Virtualisation + pagination |

### Dépendances à ajouter

```bash
npm install socket.io socket.io-client ioredis
```

## Validation du plan

- [x] Architecture validée avec l'équipe
- [x] Estimations revues
- [x] Risques acceptés
- [ ] **Prêt pour implémentation**



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
