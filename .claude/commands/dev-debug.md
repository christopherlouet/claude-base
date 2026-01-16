# Agent DEBUG

Diagnostic et résolution de bugs de manière méthodique et systématique.

## Problème à analyser
$ARGUMENTS

## Objectif

Identifier la cause racine d'un bug et le corriger de manière définitive,
en ajoutant des protections pour éviter sa réapparition.

## Méthodologie de débogage

```
┌─────────────────────────────────────────────────────────────┐
│                    DEBUG WORKFLOW                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. REPRODUIRE   → Confirmer et isoler le problème         │
│  ════════════                                               │
│                                                             │
│  2. ANALYSER     → Examiner logs, stack traces, code       │
│  ══════════                                                 │
│                                                             │
│  3. HYPOTHÉSER   → Lister les causes possibles             │
│  ═══════════                                                │
│                                                             │
│  4. INVESTIGUER  → Vérifier chaque hypothèse               │
│  ════════════                                               │
│                                                             │
│  5. CORRIGER     → Implémenter le fix minimal              │
│  ══════════                                                 │
│                                                             │
│  6. PRÉVENIR     → Ajouter test de non-régression          │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Reproduction

### Collecter les informations

```markdown
## Bug Report

**Symptôme:** [Description exacte du comportement]

**Comportement attendu:** [Ce qui devrait se passer]

**Environnement:**
- OS: [version]
- Node/Runtime: [version]
- Browser: [si applicable]
- Dépendances: [versions clés]

**Étapes de reproduction:**
1. [Étape 1]
2. [Étape 2]
3. [Bug apparaît]

**Fréquence:** [Toujours / Parfois / Rare]

**Dernière fois que ça fonctionnait:** [Date ou commit]
```

### Isolation du problème

```bash
# Identifier le commit qui a introduit le bug
git bisect start
git bisect bad HEAD
git bisect good <commit-qui-fonctionnait>
# Tester à chaque étape jusqu'à trouver le commit coupable

# Voir les changements récents dans un fichier
git log -p --follow -S "texte_recherché" -- fichier.ts

# Voir qui a modifié une ligne spécifique
git blame fichier.ts -L 10,20
```

## Étape 2 : Analyse

### Sources d'information

| Source | Commande/Outil | Information |
|--------|----------------|-------------|
| **Logs applicatifs** | `tail -f logs/app.log` | Erreurs runtime |
| **Console browser** | DevTools > Console | Erreurs frontend |
| **Network** | DevTools > Network | Requêtes échouées |
| **Stack trace** | Exception message | Chemin d'exécution |
| **Git history** | `git log --oneline` | Changements récents |

### Analyse du stack trace

```javascript
// Exemple de stack trace
Error: Cannot read property 'name' of undefined
    at getUserName (src/services/user.ts:45:12)     // ← Point d'erreur
    at processUser (src/services/user.ts:23:5)      // ← Appelant
    at handleRequest (src/api/handlers.ts:89:3)     // ← Origine
```

**Questions à se poser :**
1. Quelle est la ligne exacte de l'erreur ?
2. Quelle valeur est `undefined` et pourquoi ?
3. D'où vient cette valeur ?
4. Quelles conditions mènent à cet état ?

### Techniques de traçage

```typescript
// Logging temporaire stratégique
console.log('[DEBUG] Variable state:', { var1, var2, var3 });
console.log('[DEBUG] Function entry:', functionName, args);
console.log('[DEBUG] Condition result:', condition, 'value:', value);

// Breakpoints conditionnels (dans DevTools)
// Clic droit sur breakpoint > "Edit breakpoint"
// Condition: user.id === undefined

// Debugger statement
debugger; // S'arrête ici si DevTools ouvert
```

## Étape 3 : Hypothèses

### Matrice d'hypothèses

| # | Hypothèse | Probabilité | Test de validation |
|---|-----------|-------------|-------------------|
| 1 | [Hypothèse la plus probable] | Haute | [Comment vérifier] |
| 2 | [Hypothèse secondaire] | Moyenne | [Comment vérifier] |
| 3 | [Hypothèse moins probable] | Basse | [Comment vérifier] |

### Causes courantes par type de bug

| Type de bug | Causes fréquentes |
|-------------|-------------------|
| **Null/Undefined** | Données manquantes, race condition, API changed |
| **Type error** | Mauvais type, parsing JSON, conversion implicite |
| **Off-by-one** | Index array, boucle, comparaison < vs <= |
| **Race condition** | Async non await, state partagé, timing |
| **Memory leak** | Event listeners, closures, références circulaires |
| **Régression** | Changement récent, effet de bord, dépendance MAJ |

## Techniques avancées de Root-Cause Analysis

### 5 Whys (Technique Toyota)

Poser "Pourquoi ?" 5 fois pour remonter à la cause racine.

```markdown
**Problème:** L'application crash au login

1. **Pourquoi ?** → Le token JWT est invalide
2. **Pourquoi ?** → Le token a expiré
3. **Pourquoi ?** → Le refresh token n'a pas été appelé
4. **Pourquoi ?** → L'interceptor HTTP n'a pas détecté l'expiration
5. **Pourquoi ?** → La comparaison de date utilise le mauvais timezone

**Root cause:** Bug de timezone dans la logique de refresh token
```

### Fishbone Diagram (Ishikawa)

Catégoriser les causes possibles par domaine.

```
                           ┌─────────────────────┐
        Code               │                     │  Environnement
          │                │      PROBLÈME       │        │
    ┌─────┴─────┐          │                     │  ┌─────┴─────┐
    │ Logic bug │          │   Application       │  │ Config    │
    │ Type error│          │   crash au          │  │ Réseau    │
    │ Race cond │          │   démarrage         │  │ Resources │
    └───────────┘          │                     │  └───────────┘
                           └─────────────────────┘
    ┌───────────┐                                   ┌───────────┐
    │ Version   │          Dépendances              │ Données   │
    │ Compat.   │              │                    │ corrupted │
    │ Missing   │              │                    │ Format    │
    └─────┬─────┘              │                    └─────┬─────┘
          │              Données                          │
       Dépendances                                    Input
```

**Catégories à analyser :**
| Catégorie | Questions |
|-----------|-----------|
| **Code** | Logic error? Type mismatch? Race condition? |
| **Données** | Input invalide? Format changé? Encoding? |
| **Dépendances** | Version incompatible? API changée? |
| **Environnement** | Config manquante? Permissions? Réseau? |
| **Infrastructure** | Mémoire? CPU? Disk? Timeout? |

### Fault Tree Analysis (FTA)

Arbre logique des causes (AND/OR).

```
                    [Application Crash]
                           │
              ┌────────────┴────────────┐
              │           OR            │
       ┌──────┴──────┐          ┌───────┴───────┐
   [Memory Issue]          [Unhandled Exception]
        │                         │
   ┌────┴────┐               ┌────┴────┐
   │   AND   │               │   OR    │
┌──┴──┐  ┌───┴───┐     ┌─────┴─────┐  ┌────┴────┐
[Leak] [High Load]  [Null Ref]  [Network Error]
```

### Timeline Analysis

Reconstruire la séquence d'événements.

```markdown
| Timestamp | Event | État système | Notes |
|-----------|-------|--------------|-------|
| 10:23:01 | User login | OK | Token généré |
| 10:23:15 | API call /users | OK | 200 response |
| 10:23:45 | API call /data | SLOW | 5s response time |
| 10:24:02 | Memory spike | WARNING | 85% RAM |
| 10:24:15 | API call /export | FAIL | OOM Error ← BUG |
```

**Questions clés :**
- Qu'est-ce qui a changé entre "ça marchait" et "ça ne marche plus" ?
- Y a-t-il un pattern temporel (heure, jour, charge) ?
- Quel événement précède systématiquement le bug ?

### Rubber Duck Debugging

Expliquer le problème à haute voix (ou par écrit) force à structurer sa pensée.

```markdown
## Explication du bug (Rubber Duck)

Je cherche pourquoi [décrire le symptôme].

Le code fait ceci :
1. [Étape 1]
2. [Étape 2]
3. [Étape 3] ← Attends, ici je m'attends à X mais...

💡 En expliquant, j'ai réalisé que [insight].
```

## Étape 4 : Investigation

### Techniques d'investigation

```typescript
// 1. Vérifier les valeurs entrantes
function processUser(user: User) {
  console.assert(user != null, 'User should not be null');
  console.assert(user.id != null, 'User.id should not be null');
  // ...
}

// 2. Tracer le flux de données
function debugDataFlow(data: any, step: string) {
  console.log(`[${step}]`, JSON.stringify(data, null, 2));
  return data;
}

// 3. Vérifier les conditions
if (condition) {
  console.log('[DEBUG] Condition TRUE because:', { /* variables */ });
} else {
  console.log('[DEBUG] Condition FALSE because:', { /* variables */ });
}
```

### Outils de débogage

| Outil | Usage |
|-------|-------|
| **Chrome DevTools** | Frontend, Network, Performance |
| **VS Code Debugger** | Breakpoints, Step through |
| **Node --inspect** | Debug Node.js |
| **Redux DevTools** | State management |
| **React DevTools** | Component tree, props |

## Étape 5 : Correction

### Principes du fix

```
┌─────────────────────────────────────────────────────────────┐
│                    PRINCIPES DU FIX                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✓ Fix MINIMAL     → Ne corriger que le bug                │
│  ✓ Fix la CAUSE    → Pas les symptômes                     │
│  ✓ PRÉSERVER       → Ne pas casser l'existant              │
│  ✓ DOCUMENTER      → Expliquer pourquoi ce fix             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Patterns de correction

```typescript
// ❌ Fix superficiel (symptôme)
function getUser(id) {
  const user = users.find(u => u.id === id);
  return user || {}; // Cache le problème
}

// ✅ Fix en profondeur (cause)
function getUser(id) {
  if (!id) {
    throw new Error('User ID is required');
  }
  const user = users.find(u => u.id === id);
  if (!user) {
    throw new UserNotFoundError(id);
  }
  return user;
}
```

## Étape 6 : Prévention

### Test de non-régression

```typescript
describe('Bug #123 - User name undefined', () => {
  it('should handle missing user gracefully', () => {
    // Arrange: reproduire les conditions du bug
    const invalidUserId = 'non-existent-id';

    // Act & Assert: vérifier que le bug est corrigé
    expect(() => getUser(invalidUserId))
      .toThrow(UserNotFoundError);
  });

  it('should handle null user id', () => {
    expect(() => getUser(null))
      .toThrow('User ID is required');
  });
});
```

### Documentation du fix

```markdown
## Fix: Bug #123 - User name undefined

### Cause racine
L'API externe retournait parfois `null` au lieu d'un objet user vide,
causant une erreur lors de l'accès à `user.name`.

### Solution
Ajout d'une validation en entrée de `getUser()` et gestion explicite
du cas où l'utilisateur n'est pas trouvé.

### Fichiers modifiés
- `src/services/user.ts` - Validation ajoutée
- `src/services/user.test.ts` - Tests de régression

### Comment ça aurait pu être évité
- Validation des données entrantes
- Types plus stricts (User | null vs User)
- Tests des cas d'erreur API
```

## Output attendu

### Diagnostic

```markdown
## Diagnostic Bug

**Symptôme:** [description du comportement observé]

**Root cause:** [cause fondamentale identifiée]

**Fichiers impactés:**
- `[fichier1]` - [description]
- `[fichier2]` - [description]

**Commit coupable:** [hash] (si trouvé via bisect)
```

### Solution

```markdown
## Solution

**Fix appliqué:**
- [Description de la correction]
- [Changements effectués]

**Test ajouté:**
- [Description du test de non-régression]

**Vérification:**
- [ ] Bug corrigé (reproduction impossible)
- [ ] Tests existants passent
- [ ] Nouveau test de régression ajouté
- [ ] Pas d'effets de bord
```

## Checklist de débogage

- [ ] Bug reproduit de manière fiable
- [ ] Environnement documenté
- [ ] Stack trace analysé
- [ ] Hypothèses listées et testées
- [ ] Root cause identifiée
- [ ] Fix minimal implémenté
- [ ] Test de régression ajouté
- [ ] Documentation mise à jour

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Comprendre le contexte du code |
| `/test` | Ajouter tests de régression |
| `/commit` | Commiter le fix |
| `/hotfix` | Si correction urgente en prod |
| `/explain` | Comprendre du code complexe |

---

IMPORTANT: Ne jamais corriger les symptômes. Toujours trouver la cause racine.

YOU MUST ajouter un test qui aurait détecté ce bug.

YOU MUST documenter la root cause pour éviter la récurrence.

NEVER supprimer du code de debug sans vérifier qu'il n'est plus nécessaire.

Think hard sur pourquoi ce bug n'a pas été détecté plus tôt.
