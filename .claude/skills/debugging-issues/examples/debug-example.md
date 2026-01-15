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
