# Exemple de revue de code

## PR analysée
**Titre**: feat(auth): Ajouter authentification OAuth Google
**Fichiers modifiés**: 8 fichiers, +245 lignes, -12 lignes

## Résumé de la review

- **Fichiers modifiés**: 8
- **Lignes ajoutées**: +245
- **Lignes supprimées**: -12
- **Verdict**: Request Changes

## Points positifs

- Bonne séparation des responsabilités (service/controller)
- Types TypeScript bien définis
- Tests unitaires présents pour le service
- Gestion des erreurs cohérente

## Problèmes identifiés

### Critiques (bloquants)

**[CRITICAL] `src/services/auth.ts:45`**
```typescript
// ❌ Problème: Secret exposé dans le code
const GOOGLE_CLIENT_SECRET = "GOCSPX-xxxxx";

// ✅ Solution: Utiliser variable d'environnement
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
```
> Les secrets ne doivent jamais être hardcodés. Utiliser les variables d'environnement.

---

**[CRITICAL] `src/controllers/auth.ts:23`**
```typescript
// ❌ Problème: Pas de validation de l'input
const { code } = req.body;
const tokens = await googleAuth.getTokens(code);

// ✅ Solution: Valider avec Zod
const schema = z.object({ code: z.string().min(1) });
const { code } = schema.parse(req.body);
```
> Toujours valider les entrées utilisateur pour éviter les injections.

### Importants (à corriger)

**[IMPORTANT] `src/services/auth.ts:67`**
```typescript
// ❌ Problème: Pas de gestion du cas d'erreur
const user = await db.user.findUnique({ where: { email } });
return user.id; // Crash si user est null

// ✅ Solution: Gérer le cas null
const user = await db.user.findUnique({ where: { email } });
if (!user) {
  throw new NotFoundError(`User not found: ${email}`);
}
return user.id;
```

---

**[IMPORTANT] `src/middleware/auth.ts:15`**
```typescript
// ❌ Problème: Token stocké en localStorage (XSS vulnérable)
localStorage.setItem('token', accessToken);

// ✅ Solution: Utiliser httpOnly cookie
res.cookie('token', accessToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict'
});
```

### Suggestions (optionnelles)

**[SUGGESTION] `src/services/auth.ts:89`**
```typescript
// Actuel: Logs verbeux
console.log('User authenticated:', user);
console.log('Tokens:', tokens);

// Suggestion: Logger structuré
logger.info('User authenticated', { userId: user.id });
```

---

**[NITPICK] `src/types/auth.ts:5`**
```typescript
// Préférer interface pour les objets extensibles
type AuthUser = { ... }  // ❌
interface AuthUser { ... }  // ✅
```

## Checklist finale

- [ ] Code lisible et maintenable
- [x] Tests suffisants
- [ ] **Pas de problème de sécurité** ← 2 critiques
- [x] Performance acceptable

## Résumé pour l'auteur

Bonne implémentation globale, mais **2 problèmes de sécurité critiques** à corriger avant merge:

1. Secret hardcodé → utiliser env var
2. Pas de validation input → ajouter Zod

Une fois corrigés, approuvé pour merge.
