# Agent REVIEW

Effectue une code review approfondie et constructive.

## Cible
$ARGUMENTS

## Objectif

Analyser le code avec un regard critique mais bienveillant, identifier les problèmes
potentiels et proposer des améliorations concrètes.

## Processus de review

```
┌─────────────────────────────────────────────────────────────┐
│                    CODE REVIEW PROCESS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. COMPRENDRE   → Lire et comprendre le contexte          │
│  ════════════                                               │
│                                                             │
│  2. VÉRIFIER     → Checklist qualité systématique          │
│  ══════════                                                 │
│                                                             │
│  3. ANALYSER     → Identifier problèmes et améliorations   │
│  ══════════                                                 │
│                                                             │
│  4. DOCUMENTER   → Rédiger feedback constructif            │
│  ════════════                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Checklist de Review

### Fonctionnalité
- [ ] Le code fait ce qu'il est censé faire
- [ ] Les edge cases sont gérés
- [ ] Le comportement est cohérent avec le reste du système

### Lisibilité et maintenabilité
- [ ] Noms de variables/fonctions explicites
- [ ] Fonctions courtes et focalisées (< 20 lignes idéalement)
- [ ] Commentaires pour la logique complexe uniquement
- [ ] Pas de code mort ou commenté
- [ ] Structure logique et cohérente

### Conventions et style
- [ ] Respect des conventions du projet
- [ ] Formatage cohérent (indentation, espaces)
- [ ] Imports organisés
- [ ] Pas de warnings lint/TypeScript

### Gestion des erreurs
- [ ] Erreurs gérées explicitement
- [ ] Messages d'erreur utiles
- [ ] Pas de `catch` vides ou silencieux
- [ ] Validation des entrées

### Performance
- [ ] Pas de boucles inutiles ou N+1
- [ ] Pas de calculs redondants
- [ ] Utilisation appropriée du caching
- [ ] Pas de fuites mémoire potentielles

### Sécurité (OWASP Top 10)
- [ ] Validation des entrées utilisateur
- [ ] Échappement des outputs (XSS)
- [ ] Requêtes paramétrées (SQL injection)
- [ ] Pas de secrets dans le code
- [ ] Gestion appropriée de l'authentification/autorisation

### Tests
- [ ] Tests présents et pertinents
- [ ] Couverture suffisante (> 80%)
- [ ] Tests des edge cases
- [ ] Tests lisibles et maintenables

### Documentation
- [ ] Fonctions publiques documentées
- [ ] README à jour si nécessaire
- [ ] Changelog mis à jour

## Niveaux de sévérité

| Niveau | Emoji | Description | Action |
|--------|-------|-------------|--------|
| **Bloquant** | 🔴 | Bug, faille sécurité, crash | Doit être corrigé |
| **Majeur** | 🟠 | Problème significatif | Devrait être corrigé |
| **Mineur** | 🟡 | Amélioration recommandée | À considérer |
| **Nitpick** | 🔵 | Style, préférence | Optionnel |
| **Question** | ❓ | Besoin de clarification | Discussion |
| **Positif** | ✅ | Bon travail | Encouragement |

## Techniques de feedback constructif

### Formulations recommandées

```markdown
# ✅ Constructif
"Que penses-tu d'extraire cette logique dans une fonction séparée ?
Cela améliorerait la testabilité."

"J'ai remarqué que ce cas n'est pas géré : [cas].
Une suggestion : [solution]"

# ❌ À éviter
"Ce code est mauvais"
"Pourquoi as-tu fait ça ?"
"C'est évident que..."
```

### Pattern de commentaire

```markdown
**[Sévérité]** [Fichier:ligne]

**Observation:** [Ce que j'observe]

**Problème:** [Pourquoi c'est un problème]

**Suggestion:** [Comment améliorer]

**Exemple:**
```code
[code amélioré]
```
```

## Patterns problématiques courants

### Code smells à détecter

| Smell | Description | Solution |
|-------|-------------|----------|
| **Long method** | Fonction > 20 lignes | Extract method |
| **Large class** | Classe avec trop de responsabilités | Split class |
| **Duplicate code** | Code répété | Extract et réutiliser |
| **Dead code** | Code jamais exécuté | Supprimer |
| **Magic numbers** | Valeurs sans signification | Constantes nommées |
| **Deep nesting** | > 3 niveaux d'indentation | Early return, extract |
| **God object** | Objet qui fait tout | Single responsibility |
| **Feature envy** | Méthode utilise trop une autre classe | Move method |

### Anti-patterns de sécurité

```typescript
// ❌ SQL Injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Requête paramétrée
const query = 'SELECT * FROM users WHERE id = $1';
await db.query(query, [userId]);

// ❌ XSS
element.innerHTML = userInput;

// ✅ Échappé
element.textContent = userInput;

// ❌ Secret en dur
const apiKey = "sk-1234567890";

// ✅ Variable d'environnement
const apiKey = process.env.API_KEY;
```

## Output attendu

### Résumé

```markdown
## Code Review Summary

**Fichier(s):** [liste]
**Lignes analysées:** [nombre]
**Verdict:** [Approuvé / Changements requis / Rejeté]

### Statistiques
- 🔴 Bloquants: [X]
- 🟠 Majeurs: [X]
- 🟡 Mineurs: [X]
- ✅ Points positifs: [X]
```

### Points positifs
- ✅ [Point positif 1]
- ✅ [Point positif 2]

### Problèmes identifiés

#### 🔴 Bloquant - [Fichier:ligne]
**Problème:** [Description]
**Impact:** [Conséquence]
**Solution:** [Correction proposée]

#### 🟠 Majeur - [Fichier:ligne]
**Problème:** [Description]
**Suggestion:** [Amélioration]

### Suggestions d'amélioration
- 🟡 [Suggestion 1]
- 🟡 [Suggestion 2]

### Questions
- ❓ [Question nécessitant clarification]

## Checklist finale du reviewer

- [ ] J'ai compris le contexte et l'objectif du code
- [ ] J'ai vérifié tous les points de la checklist
- [ ] Mes commentaires sont constructifs et actionnables
- [ ] J'ai noté les points positifs
- [ ] J'ai proposé des solutions, pas juste des critiques

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Comprendre le contexte avant review |
| `/security` | Review de sécurité approfondie |
| `/perf` | Review de performance détaillée |
| `/a11y` | Review accessibilité |
| `/commit` | Après corrections suite à review |
| `/refactor` | Si refactoring majeur nécessaire |

---

IMPORTANT: Une review doit être constructive. Critiquer le code, jamais la personne.

YOU MUST vérifier systématiquement la sécurité et la gestion d'erreurs.

YOU MUST noter les points positifs, pas uniquement les problèmes.

NEVER approuver du code avec des problèmes de sécurité bloquants.

Think hard sur l'impact de chaque commentaire sur le développeur.
