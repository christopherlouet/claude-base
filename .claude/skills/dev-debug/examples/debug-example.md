# Debugging example

## Reported issue
"Users can no longer log in since this morning. 500 error on /api/login"

## Diagnostic

### 1. Reproduction
```bash
curl -X POST https://api.example.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Result:**
```json
{
  "error": "Internal Server Error",
  "statusCode": 500
}
```

Bug reproduced 100%.

### 2. Information gathering

```bash
# Recent logs
tail -100 /var/log/app/error.log
```

**Logs found:**
```
2024-01-15 09:23:45 ERROR [AuthService] Connection refused: Redis
2024-01-15 09:23:45 ERROR [AuthService] Failed to get session: ECONNREFUSED
2024-01-15 09:23:46 ERROR [AuthController] Login failed: Redis connection error
```

```bash
# Latest commits
git log --oneline -5
```

**Result:**
```
a1b2c3d (HEAD) chore: update dependencies
f4e5d6c feat: add rate limiting
9g8h7i6 fix: typo in README
```

### 3. Hypothesis

The commit `f4e5d6c feat: add rate limiting` likely added a Redis dependency that is not configured in production.

### 4. Verification

```bash
# Check the suspect commit
git show f4e5d6c --stat
```

**Modified files:**
```
src/middleware/rate-limit.ts | 45 +++++
src/config/redis.ts          | 12 ++
package.json                 |  1 +
```

```bash
# Check Redis config in prod
echo $REDIS_URL
# (empty)
```

**Cause confirmed**: `REDIS_URL` variable not defined in production.

### 5. Root cause identified

| Element | Value |
|---------|--------|
| **File** | `src/config/redis.ts:8` |
| **Problem** | Redis connection without configured URL |
| **Why** | Deployment without the environment variable |
| **Faulty commit** | `f4e5d6c` |

```typescript
// src/config/redis.ts:8
const redis = new Redis(process.env.REDIS_URL); // REDIS_URL is undefined
```

## Solution

### Option 1: Configure Redis (recommended)
```bash
# Add the variable in production
heroku config:set REDIS_URL=redis://...
```

### Option 2: Graceful fallback (temporary)
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

## Applied resolution

```bash
# 1. Configure Redis in prod
heroku config:set REDIS_URL="redis://..."

# 2. Restart the application
heroku restart

# 3. Verify the fix
curl -X POST https://api.example.com/api/login ...
# ✅ 200 OK
```

## Post-mortem

### Impact
- **Duration**: 2h15 (09:00 - 11:15)
- **Affected users**: ~500
- **Severity**: P1 (major feature broken)

### Preventive actions
1. [ ] Add environment variable checks at startup
2. [ ] Add integration test for rate limiting
3. [ ] Document required variables in the README

### Non-regression test added
```typescript
describe('Rate Limiting', () => {
  it('should work without Redis configured', () => {
    delete process.env.REDIS_URL;
    // The middleware must not crash
    expect(() => rateLimitMiddleware(req, res, next)).not.toThrow();
  });
});
```
