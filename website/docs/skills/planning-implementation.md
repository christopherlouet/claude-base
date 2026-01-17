---
sidebar_position: 19
title: "planning-implementation"
description: "Planifier l'implémentation d'une fonctionnalité. Utiliser quand l'utilisateur veut planifier, architecturer, définir une approche, ou avant de coder une feature complexe."
tags:
  - "skill"
  - "fork"
---

# Skill: planning-implementation

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Planifier l'implémentation d'une fonctionnalité. Utiliser quand l'utilisateur veut planifier, architecturer, définir une approche, ou avant de coder une feature complexe.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Bash` |
| **Mots-cles** | `planning`, `implementation`, `pattern_similaire`, `*.ts`, `dependencies` |

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

- _"Je veux planning..."_
- _"Je veux implementation..."_
- _"Je veux pattern_similaire..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
