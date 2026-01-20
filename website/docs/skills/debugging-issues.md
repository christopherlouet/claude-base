---
sidebar_position: 9
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
