---
name: dev-auth
description: Modern web auth implementation (better-auth, Lucia, NextAuth/Auth.js, Clerk, Supabase Auth). Trigger when the user wants to add login, signup, sessions, OAuth, magic links, 2FA, or when existing auth code is detected to audit or migrate.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Modern Web Auth

## Choosing your auth stack

| Solution | When to choose | Avoid when |
|----------|--------------|----------------|
| **better-auth** | Total control, TS-first, extensible (plugins), native 2FA/passkeys | Project < 1 week MVP |
| **Lucia v3+** | Minimalist approach, source-available code, you control everything | No time for plumbing |
| **NextAuth/Auth.js** | Next.js ecosystem, easy OAuth, lots of adapters | Need fine control over sessions |
| **Clerk** | Fast MVP, pre-built UI, paid SaaS | Limited budget, sovereign data control |
| **Supabase Auth** | Already on Supabase, RLS for authorization | Non-Postgres stack, complex custom auth |
| **Auth0 / Okta** | Enterprise, SAML/SCIM compliance | Indie apps, high cost |

IMPORTANT: **Never roll your own auth** (homemade JWT, custom password hashing). Use a maintained lib.

## better-auth (recommended 2026)

Framework-agnostic (Next, Remix, SvelteKit, Nuxt, vanilla). TypeScript-first.

### Install

```bash
npm install better-auth
```

### Minimal setup (Next.js)

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

### Useful plugins

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

## Lucia v3+ (if you need minimalism)

Since v3, Lucia ships **source-available** (you copy the code, not a package). Approach similar to shadcn/ui for auth.

```bash
npx create-lucia@latest
```

You get `auth.ts`, `session.ts` copied into your codebase. You modify them as needed.

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

## Sessions: cookie vs JWT

| Approach | Pro | Con |
|----------|------|--------|
| **Session cookie** (id → DB) | Immediate revocation, small cookie size | DB query on every check |
| **Stateless JWT** | No DB check, horizontal scale | Complex revocation, large cookie size |
| **Session cookie + JWT refresh** | Best of both | Complexity |

**Recommended default**: opaque session cookie stored in DB. Simpler, safer.

### Mandatory cookie attributes

```ts
{
  httpOnly: true,       // JS cannot read the cookie (anti-XSS)
  secure: true,         // HTTPS only in prod
  sameSite: "lax",      // CSRF protection (strict if no OAuth)
  path: "/",
  maxAge: 60 * 60 * 24 * 7,  // 7 days
}
```

## Password hashing

**Never MD5, SHA-1, bcrypt < cost 12**.

2026 recommendations:
- **argon2id** (modern default) — OWASP recommends. `argon2` package on npm.
- **bcrypt cost 12+** (acceptable, legacy)
- **scrypt** (acceptable, native Node)

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

IMPORTANT: libs like better-auth / Lucia / NextAuth already hash correctly. Only reimplement if you're doing custom auth (and you shouldn't).

## OAuth: correct config

### Redirect URL

Always HTTPS in prod. Add `http://localhost:3000/...` for dev.

```
https://app.example.com/api/auth/callback/github
```

### Minimum scopes

Request only what you need:
- GitHub: `read:user user:email` (not `repo` if you don't read repos)
- Google: `openid email profile`

### Mandatory state parameter

Protects against OAuth CSRF. Modern libs do this automatically.

## Authorization (after authentication)

Auth only verifies **who** the user is. For **what** they can do, you need roles/permissions.

### Patterns

| Pattern | Usage |
|---------|-------|
| **RBAC** (Role-Based) | Fixed roles: admin, user, viewer |
| **ABAC** (Attribute-Based) | Dynamic rules: "user can edit if owner" |
| **RLS** (Row-Level Security) | Postgres/Supabase: SQL policies per user |
| **CASL** / **access-js** | JS lib to express permissions |

### Next.js middleware

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

**TOTP** (Google Authenticator) is the default.

```ts
// better-auth example
await authClient.twoFactor.enable({ password });
// Returns a QR code to scan
await authClient.twoFactor.verify({ code: "123456" });
```

**Passkeys** (WebAuthn) is the future. Native passwordless.

## Security pitfalls

| Pitfall | Prevention |
|-------|-----------|
| Timing attack on password comparison | Use `argon2.verify` / constant-time compare |
| User enumeration via login | Same error message for "unknown email" and "incorrect password" |
| Session fixation | Regenerate session ID after login |
| CSRF | SameSite cookie + OAuth state + Origin check on mutations |
| XSS on token | httpOnly cookie (JS cannot read) |
| Brute force | Rate limit per IP + per account, captcha after N failures |
| Password reset leaks info | Same response "email sent" even if email doesn't exist |
| OAuth open redirect | Validate the redirect_uri against a whitelist |

## Auth audit checklist

- [ ] Cookie: `httpOnly`, `secure`, `sameSite` correct
- [ ] Password hashed with argon2id or bcrypt 12+
- [ ] Rate limiting on `/login`, `/register`, `/reset-password`
- [ ] Session regenerated after login and password change
- [ ] Neutral error messages (no user enumeration)
- [ ] Optional 2FA (mandatory for admins)
- [ ] Logout client-side + server-side (invalidate DB session)
- [ ] Password reset tokens: short duration (15-30 min), single use
- [ ] Mandatory email verification before sensitive features
- [ ] Audit log of auth actions (login, logout, password change)

## Migration between solutions

| From → To | Strategy |
|-----------|-----------|
| NextAuth → better-auth | Dual-write sessions during the transition, batch user migration |
| Supabase Auth → better-auth | Export users + password hashes if compatible, otherwise force reset |
| Custom JWT → Lucia | Invalidate all JWTs, force re-login |

IMPORTANT: Never migrate without a prior DB backup and rollback plan.

## Complement with the foundation

- "Auth" section in `docs/STACK-RECIPES.md`
- Rule `.claude/rules/security.md`: OWASP Top 10
- Skill `qa-security`: full security audit
- Skill `dev-supabase`: if Supabase stack

## Expected output

1. **Chosen solution** justified (no "rolling your own")
2. **Server and client config** with secure cookies
3. **Authorization middleware** if protected routes
4. **Optional 2FA** for sensitive features
5. **Rate limiting** on auth endpoints

## Rules

IMPORTANT: NEVER roll your own auth (homemade JWT, custom password hashing).

IMPORTANT: Session cookie MUST BE `httpOnly + secure + sameSite`.

IMPORTANT: Password hashing = argon2id (default) or bcrypt cost 12+ (legacy).

YOU MUST rate-limit `/login`, `/register`, `/reset-password` (5-10 attempts/15min).

YOU MUST return the same error messages for "unknown user" and "incorrect password" (anti-enumeration).

NEVER expose reset/verification tokens in logs or shared URLs.

NEVER store passwords in clear text, even temporarily.
