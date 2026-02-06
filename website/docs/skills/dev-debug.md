---
sidebar_position: 6
title: "dev-debug"
description: "Deboguer et resoudre des problemes. Utiliser quand l'utilisateur a un bug, une erreur, un comportement inattendu, ou veut comprendre pourquoi quelque chose ne fonctionne pas."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-debug

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Deboguer et resoudre des problemes. Utiliser quand l'utilisateur a un bug, une erreur, un comportement inattendu, ou veut comprendre pourquoi quelque chose ne fonctionne pas.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep`, `Bash` |
| **Mots-cles** | `dev`, `debug` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux debug..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple de débogage

# Exemple de débogage

## Problème signalé
"Les utilisateurs ne peuvent plus se connecter depuis ce matin. Erreur 500 sur /api/login"

## Diagnostic

### 1. Reproduction
```bash
curl -X POST https://api.example.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Résultat:**
```json
{
  "error": "Internal Server Error",
  "statusCode": 500
}
```

Bug reproduit à 100%.

### 2. Collecte d'informations

```bash
# Logs récents
tail -100 /var/log/app/error.log
```

**Logs trouvés:**
```
2024-01-15 09:23:45 ERROR [AuthService] Connection refused: Redis
2024-01-15 09:23:45 ERROR [AuthService] Failed to get session: ECONNREFUSED
2024-01-15 09:23:46 ERROR [AuthController] Login failed: Redis connection error
```

```bash
# Derniers commits
git log --oneline -5
```

**Résultat:**
```
a1b2c3d (HEAD) chore: update dependencies
f4e5d6c feat: add rate limiting
9g8h7i6 fix: typo in README
```

### 3. Hypothèse

Le commit `f4e5d6c feat: add rate limiting` a probablement ajouté une dépendance Redis qui n'est pas configurée en production.

### 4. Vérification

```bash
# Vérifier le commit suspect
git show f4e5d6c --stat
```

**Fichiers modifiés:**
```
src/middleware/rate-limit.ts | 45 +++++
src/config/redis.ts          | 12 ++
package.json                 |  1 +
```

```bash
# Vérifier la config Redis en prod
echo $REDIS_URL
# (vide)
```

**Cause confirmée**: Variable `REDIS_URL` non définie en production.

### 5. Cause racine identifiée

| Élément | Valeur |
|---------|--------|
| **Fichier** | `src/config/redis.ts:8` |
| **Problème** | Connexion Redis sans URL configurée |
| **Pourquoi** | Déploiement sans la variable d'environnement |
| **Commit fautif** | `f4e5d6c` |

```typescript
// src/config/redis.ts:8
const redis = new Redis(process.env.REDIS_URL); // REDIS_URL est undefined
```

## Solution

### Option 1: Configurer Redis (recommandé)
```bash
# Ajouter la variable en production
heroku config:set REDIS_URL=redis://...
```

### Option 2: Fallback gracieux (temporaire)
```typescript
// src/config/redis.ts
const redis = process.env.REDIS_URL
  ? new Redis(process.env.REDIS_URL)
  : null;

// src/middleware/rate-limit.ts
if (!redis) {
  console.warn('Rate limiting disabled: Redis not configured');
  return next();
}
```

## Résolution appliquée

```bash
# 1. Configurer Redis en prod
heroku config:set REDIS_URL="redis://..."

# 2. Redémarrer l'application
heroku restart

# 3. Vérifier le fix
curl -X POST https://api.example.com/api/login ...
# ✅ 200 OK
```

## Post-mortem

### Impact
- **Durée**: 2h15 (09:00 - 11:15)
- **Utilisateurs affectés**: ~500
- **Sévérité**: P1 (fonctionnalité majeure cassée)

### Actions préventives
1. [ ] Ajouter check des variables d'environnement au démarrage
2. [ ] Ajouter test d'intégration pour le rate limiting
3. [ ] Documenter les variables requises dans le README

### Test de non-régression ajouté
```typescript
describe('Rate Limiting', () => {
  it('should work without Redis configured', () => {
    delete process.env.REDIS_URL;
    // Le middleware ne doit pas crasher
    expect(() => rateLimitMiddleware(req, res, next)).not.toThrow();
  });
});
```



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
