---
sidebar_position: 21
title: "refactoring"
description: "Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur veut nettoyer, restructurer, ou ameliorer du code existant."
tags:
  - "skill"
  - "fork"
---

# Skill: refactoring

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur veut nettoyer, restructurer, ou ameliorer du code existant.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `refactoring` |

## Description detaillee

# Code Refactoring

## Principes

1. **Les tests passent AVANT et APRES**
2. **Petites modifications incrementales**
3. **Un seul type de changement a la fois**
4. **Commit apres chaque refactoring**

## Techniques courantes

### Extract Function

```typescript
// Avant
function processOrder(order) {
  // 20 lignes de validation
  // 30 lignes de calcul
  // 10 lignes d'envoi
}

// Apres
function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order);
  sendConfirmation(order, total);
}
```

### Extract Variable

```typescript
// Avant
if (user.age >= 18 && user.country === 'FR' && !user.banned) { }

// Apres
const isAdult = user.age >= 18;
const isFrench = user.country === 'FR';
const isActive = !user.banned;
if (isAdult && isFrench && isActive) { }
```

### Replace Conditional with Polymorphism

```typescript
// Avant
function getPrice(type) {
  switch(type) {
    case 'basic': return 10;
    case 'premium': return 20;
  }
}

// Apres
interface Plan { getPrice(): number }
class BasicPlan implements Plan { getPrice() { return 10; } }
class PremiumPlan implements Plan { getPrice() { return 20; } }
```

## Code Smells a detecter

| Smell | Refactoring |
|-------|-------------|
| Long method | Extract Method |
| Large class | Extract Class |
| Duplicate code | Extract + Reuse |
| Long parameter list | Parameter Object |
| Feature envy | Move Method |
| Primitive obsession | Value Object |

## Workflow

1. Identifier le code smell
2. Ecrire/verifier les tests
3. Appliquer le refactoring
4. Verifier les tests
5. Commit
6. Repeter

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux refactoring..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
