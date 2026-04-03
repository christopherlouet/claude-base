# Guide Authentification et Autorisation

> Patterns complets pour implementer auth securisee dans vos applications

## Methodes d'authentification

| Methode | Cas d'usage | Complexite | Stateless |
|---------|-------------|------------|-----------|
| Session-based | Apps web classiques, SSR | Faible | Non |
| JWT | APIs, SPAs, microservices | Moyenne | Oui |
| OAuth2/OIDC | Login social, delegation | Elevee | Oui |
| API Keys | B2B, integrations machine | Faible | Oui |
| Magic Links | Onboarding simplifie, sans mot de passe | Moyenne | Non |
| Passkeys | Applications grand public modernes | Elevee | Oui |

### Quand utiliser chaque methode

| Situation | Methode recommandee |
|-----------|---------------------|
| App web avec serveur et sessions utilisateur | Session-based |
| API consommee par une SPA ou mobile | JWT avec refresh token |
| Login via Google/GitHub/Apple | OAuth2/OIDC |
| Acces machine-to-machine ou partenaire B2B | API Keys |
| Reduire friction d'inscription (pas de mot de passe) | Magic Links |
| App grand public, securite maximale sans mot de passe | Passkeys (WebAuthn) |

### Avantages et inconvenients

| Methode | Avantages | Inconvenients |
|---------|-----------|---------------|
| Session-based | Simple, revocation immediate, etat serveur | Ne scale pas horizontalement sans Redis/sticky sessions |
| JWT | Stateless, performant, interoperable | Revocation complexe, taille du token, secret a proteger |
| OAuth2/OIDC | Standard, delègue la responsabilite, SSO | Complexite implementatoin, dependance externe |
| API Keys | Simple, long-lived, audit facile | Pas d'expiration par defaut, rotation manuelle |
| Magic Links | UX sans friction, pas de mot de passe a oublier | Requiert email fiable, lien a usage unique |
| Passkeys | Phishing-resistant, biometrie, UX moderne | Support navigateur a verifier, recuperation complexe |

## Architecture auth

```
src/
├── auth/
│   ├── strategies/          # JWT, OAuth, Passkeys, API Keys
│   ├── middleware/           # Verification token, session
│   ├── guards/               # Role/permission guards
│   └── providers/            # Google, GitHub, Auth0, etc.
├── users/
│   ├── models/               # User, Role, Permission
│   └── repositories/         # Acces donnees utilisateur
└── config/
    └── auth.ts               # Configuration JWT, sessions, providers
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-tdd → /qa:qa-security → /work:work-pr
```

## JWT en detail

### Access token vs refresh token

```
Client                    Serveur                   Base de donnees
  |                          |                              |
  |-- POST /auth/login ------>|                              |
  |   { email, password }    |-- verifier credentials ----->|
  |                          |<-- user found ----------------|
  |<-- 200 OK ---------------|                              |
  |   access_token (15min)   |                              |
  |   refresh_token (7j)     |                              |
  |                          |                              |
  |-- GET /api/resource ----->|                              |
  |   Authorization: Bearer  |-- valider access_token       |
  |                          |   (en memoire, pas de BDD)   |
  |<-- 200 OK ---------------|                              |
  |                          |                              |
  |   [access_token expire]  |                              |
  |                          |                              |
  |-- POST /auth/refresh ---->|                              |
  |   { refresh_token }      |-- verifier refresh_token --->|
  |                          |<-- token valide --------------|
  |<-- 200 OK ---------------|                              |
  |   nouveau access_token   |-- invalider ancien refresh -->|
  |   nouveau refresh_token  |-- sauvegarder nouveau ------->|
```

### Structure du token JWT

Un token JWT est compose de trois parties separees par des points :

```
header.payload.signature

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.eyJzdWIiOiJ1c2VyXzEyMyIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzA5MDAwMDAwLCJleHAiOjE3MDkwMDA5MDB9
.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

| Partie | Contenu | Exemple |
|--------|---------|---------|
| Header | Algorithme de signature | `{ "alg": "HS256", "typ": "JWT" }` |
| Payload | Claims (sub, role, exp, iat) | `{ "sub": "user_123", "role": "admin" }` |
| Signature | HMAC ou RSA du header+payload | Verifiable sans BDD |

### Stockage : httpOnly cookie vs localStorage

| Critere | httpOnly Cookie | localStorage |
|---------|----------------|--------------|
| XSS | Protege (inaccessible JS) | Vulnerable |
| CSRF | Vulnerable sans SameSite | Protege |
| HTTPS only | Oui avec `Secure` flag | Non |
| Acces JS | Non | Oui |
| Recommendation | **Prefere** | A eviter pour tokens sensibles |

Configurer les cookies correctement :

```typescript
res.cookie('access_token', token, {
  httpOnly: true,     // Inaccessible depuis JS
  secure: true,       // HTTPS uniquement
  sameSite: 'strict', // Protege contre CSRF
  maxAge: 15 * 60 * 1000, // 15 minutes
  path: '/',
});
```

### Middleware JWT (Node.js / Express)

```typescript
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

export interface AuthRequest extends Request {
  user?: { sub: string; role: string };
}

export const authenticateJWT = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  // Lire depuis cookie httpOnly ou header Authorization
  const token =
    req.cookies?.access_token ||
    req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Token manquant' } });
    return;
  }

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as {
      sub: string;
      role: string;
    };
    req.user = payload;
    next();
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      res.status(401).json({ error: { code: 'TOKEN_EXPIRED', message: 'Token expire' } });
      return;
    }
    res.status(401).json({ error: { code: 'INVALID_TOKEN', message: 'Token invalide' } });
  }
};
```

### Rotation du refresh token

```typescript
export const refreshTokens = async (req: Request, res: Response): Promise<void> => {
  const { refresh_token } = req.cookies;

  if (!refresh_token) {
    res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Refresh token manquant' } });
    return;
  }

  // Verifier le token et son existence en BDD (detection de reutilisation)
  const stored = await tokenRepository.findByValue(refresh_token);
  if (!stored || stored.revoked) {
    // Reutilisation detectee : revoquer tous les tokens de la famille
    if (stored) await tokenRepository.revokeFamily(stored.familyId);
    res.status(401).json({ error: { code: 'TOKEN_REUSE', message: 'Reutilisation detectee' } });
    return;
  }

  // Invalider l'ancien token
  await tokenRepository.revoke(stored.id);

  // Emettre une nouvelle paire
  const newAccessToken = jwt.sign(
    { sub: stored.userId, role: stored.role },
    process.env.JWT_SECRET!,
    { expiresIn: '15m' }
  );
  const newRefreshToken = crypto.randomBytes(64).toString('hex');
  await tokenRepository.create({
    userId: stored.userId,
    value: newRefreshToken,
    familyId: stored.familyId,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
  });

  res.cookie('access_token', newAccessToken, { httpOnly: true, secure: true, sameSite: 'strict', maxAge: 900_000 });
  res.cookie('refresh_token', newRefreshToken, { httpOnly: true, secure: true, sameSite: 'strict', maxAge: 604_800_000 });
  res.json({ ok: true });
};
```

## OAuth2/OIDC

### Authorization Code Flow avec PKCE

```
Browser                  Votre App                Provider (Google)
  |                          |                          |
  |-- clic "Login Google" -->|                          |
  |                          |-- generer code_verifier  |
  |                          |   + code_challenge       |
  |<-- redirect vers Google--|                          |
  |                                                     |
  |-- GET /authorize?                                   |
  |   client_id&redirect_uri                           |
  |   &code_challenge&state --------------------------->|
  |<-- page de consentement Google ---------------------|
  |-- utilisateur autorise --------------------------->|
  |<-- redirect vers votre app ?code=AUTH_CODE --------|
  |                          |                          |
  |-- GET /callback?code --->|                          |
  |                          |-- POST /token            |
  |                          |   code + code_verifier ->|
  |                          |<-- access_token + id_token|
  |                          |-- decoder id_token       |
  |                          |-- creer/mettre a jour user|
  |<-- session creee --------|                          |
```

PKCE (Proof Key for Code Exchange) est obligatoire pour les SPAs et applications mobiles car elles ne peuvent pas stocker un `client_secret` de facon securisee.

### Configuration providers (Node.js)

```typescript
// config/auth.ts
export const oauthProviders = {
  google: {
    clientId: process.env.GOOGLE_CLIENT_ID!,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    redirectUri: `${process.env.APP_URL}/auth/callback/google`,
    scopes: ['openid', 'email', 'profile'],
    authUrl: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenUrl: 'https://oauth2.googleapis.com/token',
  },
  github: {
    clientId: process.env.GITHUB_CLIENT_ID!,
    clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    redirectUri: `${process.env.APP_URL}/auth/callback/github`,
    scopes: ['user:email'],
    authUrl: 'https://github.com/login/oauth/authorize',
    tokenUrl: 'https://github.com/login/oauth/access_token',
  },
};
```

### Handler de callback OAuth

```typescript
export const handleOAuthCallback = async (
  req: Request,
  res: Response
): Promise<void> => {
  const { code, state } = req.query as { code: string; state: string };

  // Verifier le state pour prevenir CSRF
  if (state !== req.session.oauthState) {
    res.status(400).json({ error: { code: 'INVALID_STATE', message: 'State invalide' } });
    return;
  }

  const provider = oauthProviders[req.params.provider as 'google' | 'github'];

  // Echanger le code contre des tokens
  const tokenResponse = await fetch(provider.tokenUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      code,
      client_id: provider.clientId,
      client_secret: provider.clientSecret,
      redirect_uri: provider.redirectUri,
      grant_type: 'authorization_code',
      code_verifier: req.session.codeVerifier, // PKCE
    }),
  });

  const { id_token, access_token } = await tokenResponse.json();

  // Decoder l'id_token pour obtenir les infos utilisateur
  const userInfo = jwt.decode(id_token) as { sub: string; email: string; name: string };

  // Upsert utilisateur
  const user = await userRepository.upsertByEmail({
    email: userInfo.email,
    name: userInfo.name,
    provider: req.params.provider,
    providerId: userInfo.sub,
  });

  // Creer session applicative
  req.session.userId = user.id;
  res.redirect('/dashboard');
};
```

## Patterns d'autorisation

### RBAC vs ABAC vs ReBAC

| Modele | Principe | Cas d'usage | Complexite |
|--------|----------|-------------|------------|
| RBAC | Roles attribues a un utilisateur | SaaS avec niveaux (free/pro/admin) | Faible |
| ABAC | Attributs de l'utilisateur ET de la ressource | Regles metier complexes | Elevee |
| ReBAC | Relations entre entites (Zanzibar/OpenFGA) | Multi-tenant, partage de fichiers | Tres elevee |

### Matrice de permissions RBAC

| Permission | guest | user | moderator | admin |
|------------|-------|------|-----------|-------|
| Lire articles | oui | oui | oui | oui |
| Creer article | non | oui | oui | oui |
| Modifier tout article | non | non | oui | oui |
| Supprimer utilisateur | non | non | non | oui |
| Acceder admin panel | non | non | non | oui |

### Middleware role-based

```typescript
export const requireRole = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Non authentifie' } });
      return;
    }
    if (!roles.includes(req.user.role)) {
      res.status(403).json({ error: { code: 'FORBIDDEN', message: 'Permissions insuffisantes' } });
      return;
    }
    next();
  };
};

// Usage
router.delete('/users/:id', authenticateJWT, requireRole('admin'), deleteUser);
router.patch('/articles/:id', authenticateJWT, requireRole('moderator', 'admin'), updateArticle);
```

### Guard de permissions fines

```typescript
export const requirePermission = (resource: string, action: string) => {
  return async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
    if (!req.user) {
      res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Non authentifie' } });
      return;
    }

    const allowed = await permissionService.check({
      userId: req.user.sub,
      resource,
      action,
      resourceId: req.params.id,
    });

    if (!allowed) {
      res.status(403).json({ error: { code: 'FORBIDDEN', message: `Action ${action} non autorisee sur ${resource}` } });
      return;
    }

    next();
  };
};

// Usage
router.get('/documents/:id', authenticateJWT, requirePermission('document', 'read'), getDocument);
router.delete('/documents/:id', authenticateJWT, requirePermission('document', 'delete'), deleteDocument);
```

## Solutions managees

| Solution | Type | Avantages | Inconvenients | Prix |
|----------|------|-----------|---------------|------|
| Supabase Auth | Open-source / Cloud | Integre BDD, RLS natif, self-hostable | Ecosysteme Supabase | Gratuit / 25$/mois |
| Auth0 | SaaS | Tres complet, nombreux providers, MFA | Cher a grande echelle, vendor lock-in | Gratuit / 240$/mois |
| Clerk | SaaS | UX exceptionnelle, Next.js natif | Vendor lock-in | Gratuit / 25$/mois |
| Firebase Auth | SaaS | Integre ecosysteme Google, gratuit genereux | Vendor lock-in Google | Gratuit / PAYG |
| Keycloak | Open-source | Entreprise, self-hosted, LDAP/AD | Complexite operationnelle | Gratuit (infra) |
| Better Auth | Open-source | TypeScript natif, zero config | Jeune ecosysteme | Gratuit |

### Matrice build vs buy

| Critere | Build (JWT custom) | Buy (Auth0/Clerk) |
|---------|--------------------|-------------------|
| Controle total | Oui | Non |
| Time to market | Lent (semaines) | Rapide (heures) |
| Maintenance securite | A votre charge | Incluse |
| Cout < 10k users | Plus econome | Comparable |
| Cout > 100k users | Plus econome | Peut etre prohibitif |
| MFA, SSO, SAML | A implementer | Inclus |
| Conformite (SOC2, GDPR) | A prouver | Certifications incluses |

**Recommandation** : utiliser une solution managee pour les projets SaaS jusqu'a trouver des raisons metier ou economiques suffisantes pour internaliser.

## Checklist de securite

### Hachage des mots de passe

```typescript
import argon2 from 'argon2';

// Hachage (a la creation / modification du mot de passe)
const hash = await argon2.hash(plainPassword, {
  type: argon2.argon2id,
  memoryCost: 65536,   // 64 MB
  timeCost: 3,
  parallelism: 4,
});

// Verification
const valid = await argon2.verify(hash, plainPassword);
```

Algorithmes recommandes par ordre de preference : **argon2id** > bcrypt (cost 12+) > scrypt. Ne jamais utiliser MD5, SHA-1, SHA-256 seul pour les mots de passe.

### Rate limiting sur les endpoints auth

```typescript
import rateLimit from 'express-rate-limit';

// Endpoint de login : 5 tentatives par 15 minutes par IP
export const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true, // Ne compter que les echecs
  message: { error: { code: 'TOO_MANY_ATTEMPTS', message: 'Trop de tentatives, reessayez dans 15 minutes' } },
  standardHeaders: true,
  legacyHeaders: false,
});

// Endpoint refresh token : 20 par heure
export const refreshLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
});

app.post('/auth/login', loginLimiter, handleLogin);
app.post('/auth/refresh', refreshLimiter, refreshTokens);
```

### Verrouillage de compte

```typescript
const MAX_FAILURES = 5;
const LOCKOUT_DURATION_MS = 15 * 60 * 1000;

export const handleLogin = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;
  const user = await userRepository.findByEmail(email);

  if (!user) {
    // Reponse identique pour eviter l'enumeration d'emails
    res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Identifiants incorrects' } });
    return;
  }

  if (user.lockedUntil && user.lockedUntil > new Date()) {
    res.status(423).json({ error: { code: 'ACCOUNT_LOCKED', message: 'Compte verrouille temporairement' } });
    return;
  }

  const valid = await argon2.verify(user.passwordHash, password);
  if (!valid) {
    const failures = user.failedAttempts + 1;
    await userRepository.update(user.id, {
      failedAttempts: failures,
      lockedUntil: failures >= MAX_FAILURES
        ? new Date(Date.now() + LOCKOUT_DURATION_MS)
        : null,
    });
    res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Identifiants incorrects' } });
    return;
  }

  // Reset compteur d'echecs apres succes
  await userRepository.update(user.id, { failedAttempts: 0, lockedUntil: null });
  // ... creer session ou emettre tokens
};
```

### Expiration des tokens

| Type de token | TTL recommande | Justification |
|---------------|---------------|---------------|
| Access token (JWT) | 15 minutes | Limite la fenetre d'exposition |
| Refresh token (web) | 7 jours | Balance UX / securite |
| Refresh token (mobile) | 90 jours | Confort mobile, rotation obligatoire |
| Magic link | 15 minutes | Usage unique, courte duree |
| API Key | Pas d'expiration | Rotation manuelle periodique |
| Session cookie | 24 heures (idle) | Re-auth reguliere |
| Password reset token | 1 heure | Fenetre d'action courte |

### Protection CSRF

```typescript
import csrf from 'csurf';

// Pour les routes avec cookies de session
const csrfProtection = csrf({ cookie: { httpOnly: true, secure: true } });

app.get('/auth/csrf-token', csrfProtection, (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

app.post('/auth/login', csrfProtection, handleLogin);
```

Pour les APIs JSON-only avec JWT dans les headers (pas de cookies), CSRF n'est pas necessaire.

## Commandes socle par use case

### Mise en place auth from scratch

```bash
1. /work:work-plan "authentification JWT avec refresh token rotation"
2. /dev:dev-tdd "service auth: login, register, refresh, logout"
3. /qa:qa-security         # Audit OWASP auth
4. /work:work-pr            # Pull Request
```

### Ajouter un provider OAuth

```bash
1. /work:work-explore       # Comprendre l'existant
2. /dev:dev-tdd "OAuth callback Google avec upsert utilisateur"
3. /qa:qa-security         # Verifier CSRF state, PKCE
4. /work:work-commit        # Commit atomique
```

### Audit securite auth

```bash
/qa:qa-security
# Couvre: injection, tokens exposes, rate limiting manquant,
#         cookies mal configures, secrets dans les logs
```

### Ajouter RBAC

```bash
1. /work:work-plan "systeme de roles: user, moderator, admin"
2. /dev:dev-tdd "middleware requireRole et requirePermission"
3. /dev:dev-tdd "matrice de permissions par ressource"
4. /qa:qa-security
5. /work:work-pr
```

## Agents automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Implemente le login JWT" | dev-tdd | Access + refresh token avec rotation |
| "Ajoute login Google" | dev-tdd | OAuth2 PKCE + callback + upsert user |
| "Audit la securite auth" | qa-security | OWASP, rate limiting, cookies, tokens |
| "Ajoute des roles" | dev-tdd | RBAC middleware + permission guards |

## Anti-patterns a Eviter

- **JWT dans localStorage** : vulnerable XSS, preferer httpOnly cookie
- **Pas de rotation du refresh token** : un token vole est valable indefiniment
- **Mots de passe dans les logs** : masquer tous les champs sensibles (`password`, `token`, `secret`)
- **Pas de rate limiting** : attaques brute force possibles sur login
- **CORS wildcard (`*`)** avec `credentials: true` : interdit par les navigateurs, indique une mauvaise config
- **Tokens longue duree sans revocation** : compromission durable
- **Reponses d'erreur distinctes** : `"email inconnu"` vs `"mot de passe incorrect"` facilite l'enumeration d'emails
- **Secret JWT code en dur** : toujours via variable d'environnement, rotation periodique

## Ressources

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP JWT Security](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)
- [RFC 6749 - OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc6749)
- [WebAuthn / Passkeys Guide](https://webauthn.guide)
- [Auth0 - Refresh Token Rotation](https://auth0.com/docs/secure/tokens/refresh-tokens/refresh-token-rotation)
