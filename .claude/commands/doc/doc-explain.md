# Agent EXPLAIN

Expliquer du code complexe en détail.

## Code à expliquer
$ARGUMENTS

## Niveaux d'explication

### Niveau 1 : Vue d'ensemble
- Quel est le but de ce code ?
- Dans quel contexte est-il utilisé ?
- Quelles sont ses entrées/sorties ?

### Niveau 2 : Structure
- Comment est-il organisé ?
- Quelles sont les parties principales ?
- Comment les parties interagissent-elles ?

### Niveau 3 : Détails
- Ligne par ligne si nécessaire
- Pourquoi ces choix d'implémentation ?
- Quels sont les edge cases gérés ?

## Format d'explication

### Pour une fonction
```
## [Nom de la fonction]

### But
[Ce que fait la fonction en une phrase]

### Signature
[Paramètres et retour expliqués]

### Algorithme
1. [Étape 1]
2. [Étape 2]
...

### Complexité
- Temps: O(?)
- Espace: O(?)

### Edge cases
- [Cas 1]: [Comment géré]
- [Cas 2]: [Comment géré]

### Exemple d'utilisation
[Code exemple avec résultat]
```

### Pour une classe/module
```
## [Nom du module]

### Responsabilité
[Single responsibility de ce module]

### Interface publique
- `method1()` - [description]
- `method2()` - [description]

### Dépendances
- [Dep 1] - [pourquoi]
- [Dep 2] - [pourquoi]

### État interne
- [Propriété 1] - [rôle]
- [Propriété 2] - [rôle]

### Cycle de vie
1. Création: [comment]
2. Utilisation: [pattern]
3. Destruction: [cleanup si applicable]
```

### Pour un algorithme
```
## [Nom de l'algorithme]

### Problème résolu
[Description du problème]

### Intuition
[Idée de base en termes simples]

### Étapes
1. [Étape avec explication du "pourquoi"]
2. [Étape avec explication du "pourquoi"]

### Visualisation
[Schéma ASCII si utile]

### Preuve de correction (si pertinent)
[Invariants, cas de base, etc.]

### Optimisations appliquées
- [Optimisation 1]
- [Optimisation 2]
```

## Techniques d'explication

### Analogies
Utiliser des analogies du monde réel quand possible :
- "C'est comme un serveur de restaurant qui..."
- "Imagine une file d'attente où..."

### Diagrammes ASCII
```
┌─────────┐     ┌─────────┐
│ Input   │────▶│ Process │────▶ Output
└─────────┘     └─────────┘
                     │
                     ▼
               ┌─────────┐
               │  Side   │
               │ Effect  │
               └─────────┘
```

### Exemples concrets
Toujours accompagner d'exemples avec des valeurs réelles.

## Output attendu

### Résumé en une phrase
[Ce que fait ce code]

### Explication détaillée
[Selon le niveau demandé]

### Points clés à retenir
- [Point 1]
- [Point 2]
- [Point 3]

### Questions fréquentes
- Q: [Question anticipée] ?
- R: [Réponse]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/onboard` | Découvrir un codebase complet |
| `/explore` | Explorer avant d'expliquer |
| `/doc` | Documenter après explication |
| `/review` | Reviewer du code expliqué |

---

IMPORTANT: Adapter le niveau de détail au public cible.

YOU MUST expliquer le "pourquoi", pas seulement le "quoi".

NEVER supposer que le lecteur connaît le contexte.

Think hard sur les analogies qui peuvent clarifier les concepts.
