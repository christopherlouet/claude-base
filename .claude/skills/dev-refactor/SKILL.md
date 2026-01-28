---
name: dev-refactor
description: Refactoring de code pour ameliorer la qualite. Declencher quand l'utilisateur veut nettoyer, restructurer, ou ameliorer du code existant.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

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

## Reducing Entropy (Reduction de complexite)

### Metriques de complexite

| Metrique | Seuil d'alerte | Comment mesurer |
|----------|---------------|-----------------|
| **Complexite cyclomatique** | > 10 par fonction | Nombre de branches (if/else/switch) |
| **Profondeur d'imbrication** | > 3 niveaux | Nesting de if/for/while |
| **Longueur de fonction** | > 50 lignes | Nombre de lignes |
| **Nombre de parametres** | > 4 | Parametres de fonction |
| **Couplage afferent/efferent** | Ratio instable | Dependances entrantes/sortantes |
| **Taille de fichier** | > 300 lignes | Lignes de code |

### Techniques de reduction

#### Early Return (eliminer l'imbrication)

```typescript
// AVANT: imbrication profonde (entropie haute)
function process(user) {
  if (user) {
    if (user.isActive) {
      if (user.hasPermission) {
        return doWork(user);
      }
    }
  }
  return null;
}

// APRES: early returns (entropie basse)
function process(user) {
  if (!user) return null;
  if (!user.isActive) return null;
  if (!user.hasPermission) return null;
  return doWork(user);
}
```

#### Decomposer les conditions complexes

```typescript
// AVANT
if (user.age >= 18 && user.country === 'FR' && !user.banned && user.email.includes('@')) { }

// APRES
const isEligible = user.age >= 18
  && user.country === 'FR'
  && !user.banned
  && isValidEmail(user.email);
if (isEligible) { }
```

#### Eliminer le code mort

```bash
# Trouver les exports non utilises
# Trouver les fonctions jamais appelees
# Supprimer les imports inutiles
# Retirer les commentaires obsoletes
# Enlever les fichiers orphelins
```

#### Consolider les duplications

```
Regle des 3 : refactorer a la 3eme duplication, pas avant.
- 1ere occurrence : ecrire le code
- 2eme occurrence : noter la duplication (commentaire)
- 3eme occurrence : extraire dans une fonction/module
```

## Workflow

1. MESURER la complexite actuelle (metriques)
2. Identifier le code smell
3. Ecrire/verifier les tests
4. Appliquer le refactoring
5. MESURER la complexite apres (doit diminuer)
6. Verifier les tests
7. Commit
8. Repeter
