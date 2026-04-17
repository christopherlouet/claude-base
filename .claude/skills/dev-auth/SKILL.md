---
name: dev-auth
description: Implementation auth web moderne (better-auth, Lucia, NextAuth/Auth.js, Clerk, Supabase Auth). Declencher quand l'utilisateur veut ajouter login, signup, sessions, OAuth, magic links, 2FA, ou quand on detecte du code d'auth existant a auditer ou migrer.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Auth Web Moderne

## Choisir sa stack auth

| Solution | Quand choisir | A eviter quand |
|----------|--------------|----------------|
| **better-auth** | Control total, TS-first, extensible (plugins), 2FA/passkeys natifs | Projet < 1 semaine MVP |
| **Lucia v3+** | Approche minimaliste, code source-available, tu controles tout | Pas de temps pour plomberie |
| **NextAuth/Auth.js** | Ecosysteme Next.js, OAuth easy, beaucoup d'adapters | Besoin de control fin sur sessions |
| **Clerk** | MVP rapide, UI pre-faite, SaaS paid | Budget limite, control data souverain |
| **Supabase Auth** | Deja sur Supabase, RLS pour autorisation | Stack non-Postgres, auth complexe custom |
| **Auth0 / Okta** | Entreprise, compliance SAML/SCIM | Apps indie, cout eleve |

IMPORTANT: **Ne jamais rouler sa propre auth** (JWT maison, password hashing custom). Utiliser une lib maintenue.

## better-auth (recommande 2026)

Framework-agnostic (Next, Remix, SvelteKit, Nuxt, vanilla). TypeScript-first.

### Install

```bash
npm install better-auth
```

### Setup minimal (Next.js)

```ts
// lib/auth.ts
import { betterAuth } from "better-auth";
import { Pool } from "pg";

export const auth = betterAuth({
  database: new Pool({ connectionString: process.env.DATABASE_URL }),
  emailAndPassword: { enabled: true },
  socialProviders: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
});
```

```ts
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";

export const { GET, POST } = toNextJsHandler(auth);
```

### Client

```tsx
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient();

// Usage
const { data: session } = authClient.useSession();
await authClient.signIn.email({ email, password });
await authClient.signUp.email({ email, password, name });
await authClient.signOut();
```

### Plugins utiles

```ts
import { twoFactor, magicLink, passkey } from "better-auth/plugins";

betterAuth({
  plugins: [
    twoFactor(),                              // TOTP
    magicLink({ sendMagicLink: ... }),        // Email magic link
    passkey(),                                // WebAuthn/passkeys
  ],
});
```

## Lucia v3+ (si besoin de minimalisme)

Depuis v3, Lucia est livree **source-available** (tu copies le code, pas un paquet). Approche similaire a shadcn/ui pour l'auth.

```bash
npx create-lucia@latest
```

Tu obtiens `auth.ts`, `session.ts` copies dans ton codebase. Tu modifies selon tes besoins.

## NextAuth / Auth.js

```bash
npm install next-auth@beta
```

```ts
// auth.ts
import NextAuth from "next-auth";
import GitHub from "next-auth/providers/github";

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [GitHub],
});
```

```ts
// app/api/auth/[...nextauth]/route.ts
export { GET, POST } from "@/auth";
```

```ts
// middleware.ts
export { auth as middleware } from "@/auth";
```

## Sessions : cookie vs JWT

| Approche | Pour | Contre |
|----------|------|--------|
| **Cookie de session** (id → DB) | Revocation immediate, taille cookie small | Requete DB a chaque check |
| **JWT stateless** | Pas de DB check, scale horizontal | Revocation complexe, taille cookie grande |
| **Cookie session + JWT refresh** | Meilleur des deux | Complexite |

**Defaut recommande** : cookie de session opaque stocke en DB. Plus simple, plus sur.

### Attributs cookie obligatoires

```ts
{
  httpOnly: true,       // JS ne peut pas lire le cookie (anti-XSS)
  secure: true,         // HTTPS uniquement en prod
  sameSite: "lax",      // CSRF protection (strict si pas de OAuth)
  path: "/",
  maxAge: 60 * 60 * 24 * 7,  // 7 jours
}
```

## Password hashing

**Jamais MD5, SHA-1, bcrypt < cost 12**.

Recommandations 2026 :
- **argon2id** (defaut moderne) — OWASP recommande. `argon2` package sur npm.
- **bcrypt cost 12+** (acceptable, legacy)
- **scrypt** (acceptable, Node natif)

```ts
import argon2 from "argon2";

const hash = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 19456,    // 19 MB
  timeCost: 2,
  parallelism: 1,
});

const valid = await argon2.verify(hash, password);
```

IMPORTANT: les libs comme better-auth / Lucia / NextAuth hashent deja correctement. Ne reimplementer que si tu fais de l'auth custom (et tu ne devrais pas).

## OAuth : config correcte

### Redirect URL

Toujours en HTTPS en prod. Ajouter `http://localhost:3000/...` pour dev.

```
https://app.example.com/api/auth/callback/github
```

### Scopes minimum

Demander uniquement ce dont tu as besoin :
- GitHub : `read:user user:email` (pas `repo` si tu ne lis pas les repos)
- Google : `openid email profile`

### State parameter obligatoire

Protege contre CSRF OAuth. Les libs modernes le font automatiquement.

## Authorization (apres authentication)

L'auth ne fait que verifier **qui** est l'utilisateur. Pour **quoi** il peut faire, il faut des roles/permissions.

### Patterns

| Pattern | Usage |
|---------|-------|
| **RBAC** (Role-Based) | Roles fixes : admin, user, viewer |
| **ABAC** (Attribute-Based) | Regles dynamiques : "user peut edit si owner" |
| **RLS** (Row-Level Security) | Postgres/Supabase : SQL policies par utilisateur |
| **CASL** / **access-js** | Lib JS pour exprimer les permissions |

### Middleware Next.js

```ts
// middleware.ts
import { NextResponse } from "next/server";
import { auth } from "@/lib/auth";

export async function middleware(request: NextRequest) {
  const session = await auth.api.getSession({ headers: request.headers });

  if (!session && request.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  if (session?.user.role !== "admin" && request.nextUrl.pathname.startsWith("/admin")) {
    return NextResponse.redirect(new URL("/403", request.url));
  }
}
```

## 2FA / MFA

**TOTP** (Google Authenticator) est le defaut.

```ts
// better-auth example
await authClient.twoFactor.enable({ password });
// Retourne un QR code a scanner
await authClient.twoFactor.verify({ code: "123456" });
```

**Passkeys** (WebAuthn) est le futur. Passwordless natif.

## Pieges de securite

| Piege | Prevention |
|-------|-----------|
| Timing attack sur comparaison password | Utiliser `argon2.verify` / constant-time compare |
| User enumeration via login | Meme message erreur pour "email inconnu" et "password incorrect" |
| Session fixation | Regenerer session ID apres login |
| CSRF | SameSite cookie + state OAuth + Origin check sur mutations |
| XSS sur token | httpOnly cookie (JS ne peut pas lire) |
| Brute force | Rate limit par IP + par compte, captcha apres N echecs |
| Password reset leaks info | Meme reponse "email envoye" meme si email inexistant |
| OAuth open redirect | Valider le redirect_uri contre une whitelist |

## Checklist audit auth

- [ ] Cookie : `httpOnly`, `secure`, `sameSite` correct
- [ ] Password hashe avec argon2id ou bcrypt 12+
- [ ] Rate limiting sur `/login`, `/register`, `/reset-password`
- [ ] Session regeneree apres login et password change
- [ ] Messages d'erreur neutres (pas de user enumeration)
- [ ] 2FA optionnel (obligatoire pour admins)
- [ ] Logout cote client + server (invalider session DB)
- [ ] Tokens de reset password : courte duree (15-30 min), usage unique
- [ ] Email verification obligatoire avant features sensibles
- [ ] Audit log des actions auth (login, logout, password change)

## Migration entre solutions

| De → Vers | Strategie |
|-----------|-----------|
| NextAuth → better-auth | Dual-write sessions pendant la transition, migration users en batch |
| Supabase Auth → better-auth | Export users + password hashes si compatible, sinon forcer reset |
| Custom JWT → Lucia | Invalider tous les JWT, forcer re-login |

IMPORTANT: Ne jamais migrer sans backup DB prealable et plan de rollback.

## Complement avec le socle

- Guide `docs/guides/AUTH-GUIDE.md` : vue d'ensemble
- Rule `.claude/rules/security.md` : OWASP Top 10
- Skill `qa-security` : audit securite complet
- Skill `dev-supabase` : si stack Supabase

## Output attendu

1. **Solution choisie** justifiee (pas de "rolling your own")
2. **Config serveur et client** avec cookies securises
3. **Middleware d'autorisation** si routes protegees
4. **2FA optionnel** pour features sensibles
5. **Rate limiting** sur endpoints d'auth

## Regles

IMPORTANT: NEVER roll your own auth (JWT maison, password hashing custom).

IMPORTANT: Cookie de session OBLIGATOIREMENT `httpOnly + secure + sameSite`.

IMPORTANT: Hashing password = argon2id (defaut) ou bcrypt cost 12+ (legacy).

YOU MUST rate-limiter `/login`, `/register`, `/reset-password` (5-10 tentatives/15min).

YOU MUST retourner les memes messages d'erreur pour "user inconnu" et "password incorrect" (anti-enumeration).

NEVER exposer les tokens de reset/verification dans les logs ou URL partagee.

NEVER stocker de password en clair, meme temporairement.
