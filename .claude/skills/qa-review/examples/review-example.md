# Code review example

## PR analyzed
**Title**: feat(auth): Add Google OAuth authentication
**Modified files**: 8 files, +245 lines, -12 lines

## Review summary

- **Modified files**: 8
- **Added lines**: +245
- **Removed lines**: -12
- **Verdict**: Request Changes

## Positive points

- Good separation of concerns (service/controller)
- Well-defined TypeScript types
- Unit tests present for the service
- Consistent error handling

## Issues identified

### Critical (blocking)

**[CRITICAL] `src/services/auth.ts:45`**
```typescript
// ❌ Issue: Secret exposed in the code
const GOOGLE_CLIENT_SECRET = "GOCSPX-xxxxx";

// ✅ Solution: Use an environment variable
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
```
> Secrets must never be hardcoded. Use environment variables.

---

**[CRITICAL] `src/controllers/auth.ts:23`**
```typescript
// ❌ Issue: No input validation
const { code } = req.body;
const tokens = await googleAuth.getTokens(code);

// ✅ Solution: Validate with Zod
const schema = z.object({ code: z.string().min(1) });
const { code } = schema.parse(req.body);
```
> Always validate user input to prevent injections.

### Important (to fix)

**[IMPORTANT] `src/services/auth.ts:67`**
```typescript
// ❌ Issue: No handling of the error case
const user = await db.user.findUnique({ where: { email } });
return user.id; // Crashes if user is null

// ✅ Solution: Handle the null case
const user = await db.user.findUnique({ where: { email } });
if (!user) {
  throw new NotFoundError(`User not found: ${email}`);
}
return user.id;
```

---

**[IMPORTANT] `src/middleware/auth.ts:15`**
```typescript
// ❌ Issue: Token stored in localStorage (XSS vulnerable)
localStorage.setItem('token', accessToken);

// ✅ Solution: Use an httpOnly cookie
res.cookie('token', accessToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict'
});
```

### Suggestions (optional)

**[SUGGESTION] `src/services/auth.ts:89`**
```typescript
// Current: Verbose logs
console.log('User authenticated:', user);
console.log('Tokens:', tokens);

// Suggestion: Structured logger
logger.info('User authenticated', { userId: user.id });
```

---

**[NITPICK] `src/types/auth.ts:5`**
```typescript
// Prefer interface for extensible objects
type AuthUser = { ... }  // ❌
interface AuthUser { ... }  // ✅
```

## Final checklist

- [ ] Code readable and maintainable
- [x] Sufficient tests
- [ ] **No security issues** ← 2 critical
- [x] Acceptable performance

## Summary for the author

Good overall implementation, but **2 critical security issues** to fix before merge:

1. Hardcoded secret → use env var
2. No input validation → add Zod

Once fixed, approved for merge.
