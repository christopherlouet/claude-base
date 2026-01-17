---
sidebar_position: 8
title: "debugging-issues"
description: "Déboguer et résoudre des problèmes. Utiliser quand l'utilisateur a un bug, une erreur, un comportement inattendu, ou veut comprendre pourquoi quelque chose ne fonctionne pas."
tags:
  - "skill"
  - "fork"
---

# Skill: debugging-issues

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Déboguer et résoudre des problèmes. Utiliser quand l'utilisateur a un bug, une erreur, un comportement inattendu, ou veut comprendre pourquoi quelque chose ne fonctionne pas.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Bash` |
| **Mots-cles** | `debugging`, `issues` |

## Description detaillee

# Déboguer un Problème

## Objectif

Identifier la cause racine d'un bug de manière méthodique.

## Instructions

### 1. Reproduire le problème

**Questions clés:**
- Que se passe-t-il exactement ?
- Que devrait-il se passer ?
- Quand ça a commencé ?
- Est-ce reproductible à 100% ?

### 2. Collecter les informations

```bash
# Logs récents
tail -100 logs/app.log 2>/dev/null

# Derniers commits
git log --oneline -10

# Changements récents dans la zone suspecte
git log --oneline -5 -- src/chemin/suspect/
```

### 3. Méthode de diagnostic

```
1. Reproduire le bug
        ↓
2. Isoler le problème (binary search)
        ↓
3. Formuler une hypothèse
        ↓
4. Vérifier l'hypothèse
        ↓
5. Identifier la cause racine
```

### 4. Techniques de debug

| Technique | Quand l'utiliser |
|-----------|------------------|
| **Logs** | Tracer le flux d'exécution |
| **Breakpoints** | Inspecter l'état à un point précis |
| **Binary search** | Bug dans un grand volume de code |
| **Git bisect** | Trouver le commit fautif |
| **Rubber duck** | Expliquer le problème à voix haute |

### 5. Git bisect (trouver le commit fautif)

```bash
git bisect start
git bisect bad                 # Version actuelle cassée
git bisect good <commit>       # Dernière version OK
# Tester et marquer good/bad jusqu'à trouver le commit
git bisect reset
```

## Output attendu

```markdown
## Diagnostic : [Description du bug]

### Symptôme
[Ce qui se passe]

### Comportement attendu
[Ce qui devrait se passer]

### Reproduction
1. [Étape 1]
2. [Étape 2]
3. Bug apparaît

### Cause racine
**Fichier**: `src/xxx.ts:42`
**Problème**: [Explication technique]
**Pourquoi**: [Raison du bug]

### Solution proposée
```typescript
// Avant
code_bugué();

// Après
code_corrigé();
```

### Vérification
- [ ] Bug reproduit
- [ ] Cause identifiée
- [ ] Fix testé
- [ ] Non-régression vérifiée
```

## Règles

- Ne pas supposer - vérifier
- Un bug à la fois
- Comprendre AVANT de corriger
- Toujours ajouter un test de non-régression

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux debugging..."_
- _"Je veux issues..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
