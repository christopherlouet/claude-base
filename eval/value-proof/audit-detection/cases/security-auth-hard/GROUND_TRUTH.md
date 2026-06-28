# Ground truth — security-auth-hard

`auth.js` is mostly hardened (helmet, rate limiting, bcrypt, parameterized
queries, an auth middleware). The planted flaws are **subtle and buried** —
the kind a generic "review this" pass tends to miss. Recall target = 6.

## Planted vulnerabilities

| ID | Class | Location | What |
|----|-------|----------|------|
| H1 | JWT algorithm confusion | `requireAuth` | `jwt.verify(token, JWT_SECRET)` does not pin `algorithms: ['HS256']` — accepts `alg:none` / algorithm-confusion tokens. |
| H2 | IDOR / broken object-level authz | `GET /account/billing` | authenticated, but reads `req.query.accountId` instead of `req.user.id` — any logged-in user reads any account's billing. |
| H3 | Non-constant-time secret compare | `POST /account/rotate-key` | `currentKey !== rows[0].api_key` compares a secret with `!==` — timing side-channel; needs `crypto.timingSafeEqual`. |
| H4 | Open redirect | `GET /login/continue` | `res.redirect(req.query.next ...)` with no allowlist — attacker-controlled `next` enables phishing redirects. |
| H5 | SSRF | `POST /integrations/webhook-test` | server-side `fetch(url)` on a user-supplied URL — reaches internal services / cloud metadata (admin-gating ≠ SSRF fix). |
| H6 | ReDoS (catastrophic backtracking) | `POST /reset/confirm` | token validated with `/^([a-zA-Z0-9]+)+$/` — nested quantifier; a long non-matching input hangs the event loop. |

## Decoys (benign — must NOT be flagged)

| ID | Location | Why it's safe |
|----|----------|---------------|
| D1 | `bcrypt.compare` / `bcrypt.hash(.., 12)` | correct, modern password hashing — not a crypto weakness. |
| D2 | all `db.query(.., [..])` calls | parameterized — not SQL injection. |
| D3 | `loginLimiter` + `helmet()` | rate limiting and security headers ARE present — claiming they're missing is a false positive. |
