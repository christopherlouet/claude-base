---
name: dev-debug
description: Deboguer et resoudre des problemes. Utiliser quand l'utilisateur a un bug, une erreur, un comportement inattendu, ou veut comprendre pourquoi quelque chose ne fonctionne pas.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
context: fork
---

# Deboguer un Probleme

## Objectif

Identifier la cause racine d'un bug de maniere methodique via une approche systematique en 4 phases.

## Methodologie Systematique (4 Phases)

```
┌──────────────────────────────────────────────────────────────────┐
│                   SYSTEMATIC DEBUGGING                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PHASE 1: OBSERVATION          Collecter sans interpreter         │
│  ═══════════════════                                              │
│  - Reproduire le symptome exact                                   │
│  - Documenter l'environnement                                     │
│  - Capturer logs, stack traces, etats                             │
│  - NE PAS sauter aux conclusions                                  │
│                                                                   │
│  PHASE 2: HYPOTHESES           Raisonner systematiquement         │
│  ════════════════════                                             │
│  - Lister TOUTES les causes possibles                             │
│  - Classer par probabilite (haute/moyenne/basse)                  │
│  - Definir un test de validation pour chaque hypothese            │
│  - Utiliser la technique des 5 Whys                               │
│                                                                   │
│  PHASE 3: INVESTIGATION        Prouver, ne pas supposer           │
│  ══════════════════════                                           │
│  - Tester UNE hypothese a la fois                                 │
│  - Utiliser tracing et logging strategique                        │
│  - Isoler avec binary search (code ou git bisect)                 │
│  - Documenter chaque hypothese testee (confirmee/infirmee)        │
│                                                                   │
│  PHASE 4: VERIFICATION         Confirmer que le fix est reel      │
│  ════════════════════                                             │
│  - Reproduire le bug original (doit echouer sans le fix)          │
│  - Appliquer le fix minimal                                       │
│  - Prouver que le bug est corrige                                 │
│  - Verifier l'absence d'effets de bord                            │
│  - Ajouter un test de non-regression                              │
│  - Defense en profondeur : assertions sur invariants              │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## Phase 1 : Observation

**Questions cles:**
- Que se passe-t-il exactement ?
- Que devrait-il se passer ?
- Quand ca a commence ?
- Est-ce reproductible a 100% ?
- Quels sont les facteurs aggravants/attenuants ?

```bash
# Logs recents
tail -100 logs/app.log 2>/dev/null

# Derniers commits
git log --oneline -10

# Changements recents dans la zone suspecte
git log --oneline -5 -- src/chemin/suspect/
```

## Phase 2 : Hypotheses

### Matrice d'hypotheses

| # | Hypothese | Probabilite | Test de validation |
|---|-----------|-------------|-------------------|
| 1 | [Plus probable] | Haute | [Comment verifier] |
| 2 | [Secondaire] | Moyenne | [Comment verifier] |
| 3 | [Moins probable] | Basse | [Comment verifier] |

### Technique des 5 Whys

```
Probleme: L'application crash au login

1. Pourquoi ? -> Le token JWT est invalide
2. Pourquoi ? -> Le token a expire
3. Pourquoi ? -> Le refresh token n'a pas ete appele
4. Pourquoi ? -> L'interceptor n'a pas detecte l'expiration
5. Pourquoi ? -> Bug de timezone dans la comparaison

Root cause: Bug de timezone dans la logique de refresh
```

### Causes courantes par type

| Type de bug | Causes frequentes |
|-------------|-------------------|
| **Null/Undefined** | Donnees manquantes, race condition, API changed |
| **Type error** | Mauvais type, parsing JSON, conversion implicite |
| **Off-by-one** | Index array, boucle, comparaison `<` vs `<=` |
| **Race condition** | Async non await, state partage, timing |
| **Memory leak** | Event listeners, closures, references circulaires |
| **Regression** | Changement recent, effet de bord, dependance MAJ |

## Phase 3 : Investigation

### Techniques de tracing

```typescript
// Tracing strategique (pas du console.log partout)
function trace(label: string, data: unknown) {
  console.log(`[TRACE:${label}]`, JSON.stringify(data, null, 2));
}

// Points de trace aux frontieres
trace('INPUT', { args });       // Entree de fonction
trace('STATE', { variables });  // Etat intermediaire
trace('OUTPUT', { result });    // Sortie de fonction
trace('BRANCH', { condition }); // Decision prise
```

### Binary search dans le code

```
1. Commenter la moitie du code suspect
2. Le bug persiste ?
   - Oui -> Le bug est dans la moitie restante
   - Non -> Le bug est dans la moitie commentee
3. Repeter jusqu'a isoler la ligne exacte
```

### Git bisect (trouver le commit fautif)

```bash
git bisect start
git bisect bad                 # Version actuelle cassee
git bisect good <commit>       # Derniere version OK
# Tester et marquer good/bad jusqu'a trouver le commit
git bisect reset
```

## Phase 4 : Verification (OBLIGATOIRE)

### Prouver que le fix fonctionne

```
1. SANS le fix : reproduire le bug -> echec confirme
2. AVEC le fix : meme scenario     -> succes confirme
3. Tests existants                  -> tous passent
4. Test de non-regression           -> ecrit et passe
5. Effets de bord                   -> verifies absents
```

### Defense en profondeur

```typescript
// Ajouter des assertions sur les invariants critiques
function processPayment(amount: number, userId: string) {
  assert(amount > 0, 'Payment amount must be positive');
  assert(userId, 'User ID is required');
  // ...code metier...
}
```

### Checklist de completion

```
[ ] Bug reproduit de maniere fiable
[ ] Root cause identifiee (pas juste le symptome)
[ ] Fix minimal applique (pas de refactoring opportuniste)
[ ] Test de non-regression ajoute
[ ] Tests existants passent
[ ] Pas d'effets de bord
[ ] Documentation du fix (commit message descriptif)
```

## Output attendu

```markdown
## Diagnostic : [Description du bug]

### Phase 1 - Observation
**Symptome:** [Ce qui se passe]
**Comportement attendu:** [Ce qui devrait se passer]
**Reproduction:** [Etapes 1, 2, 3...]

### Phase 2 - Hypotheses
| # | Hypothese | Probabilite | Resultat |
|---|-----------|-------------|----------|
| 1 | [...] | Haute | Confirmee/Infirmee |

### Phase 3 - Investigation
**Root cause:** `src/xxx.ts:42` - [Explication technique]
**5 Whys:** [Chaine causale]

### Phase 4 - Verification
- [x] Bug reproduit
- [x] Fix applique
- [x] Test de non-regression ajoute
- [x] Tous les tests passent
- [x] Pas d'effets de bord
```

## Regles

- Ne pas supposer - verifier (Phase 4 obligatoire)
- Un bug a la fois
- Comprendre AVANT de corriger
- Toujours ajouter un test de non-regression
- Documenter chaque hypothese testee, meme celles infirmees
- Le fix doit etre MINIMAL - pas de refactoring opportuniste
