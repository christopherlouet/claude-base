# Security audit example

## Context
Security audit of a Node.js/Express application before production release.

## Automated scan

### npm audit
```bash
$ npm audit

found 3 vulnerabilities (1 moderate, 2 high)

┌───────────────┬──────────────────────────────────────────────────────┐
│ High          │ Prototype Pollution in lodash                        │
├───────────────┼──────────────────────────────────────────────────────┤
│ Package       │ lodash                                               │
│ Patched in    │ >=4.17.21                                           │
│ Path          │ lodash                                               │
└───────────────┴──────────────────────────────────────────────────────┘
```

### Secret scanning
```bash
$ npx secretlint "**/*"

src/config/database.ts:5
  5:1  error  Found AWS Access Key ID pattern  secretlint/aws

src/services/payment.ts:12
  12:1  error  Found Stripe Secret Key pattern  secretlint/stripe

✖ 2 problems (2 errors, 0 warnings)
```

## Manual analysis

### A01 - Broken Access Control

**[CRITICAL] `src/routes/users.ts:34`**
```typescript
// ❌ IDOR - Direct access without verification
router.get('/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user); // Anyone can access any user
});

// ✅ Fix
router.get('/users/:id', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const user = await User.findById(req.params.id);
  res.json(user);
});
```

### A02 - Cryptographic Failures

**[CRITICAL] `src/config/database.ts:5`**
```typescript
// ❌ Hardcoded secret
const DB_PASSWORD = "SuperSecret123!";

// ✅ Fix
const DB_PASSWORD = process.env.DB_PASSWORD;
```

### A03 - Injection

**[CRITICAL] `src/services/search.ts:23`**
```typescript
// ❌ SQL Injection
const query = `SELECT * FROM products WHERE name LIKE '%${searchTerm}%'`;

// ✅ Fix
const query = 'SELECT * FROM products WHERE name LIKE ?';
db.query(query, [`%${searchTerm}%`]);
```

**[HIGH] `src/components/Comment.tsx:15`**
```typescript
// ❌ XSS via dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: comment.content }} />

// ✅ Fix
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(comment.content) }} />
```

### A05 - Security Misconfiguration

**[MEDIUM] Missing security headers**
```typescript
// ❌ No security headers
app.use(express.json());

// ✅ Fix
import helmet from 'helmet';
app.use(helmet());
```

### A07 - Authentication Failures

**[HIGH] `src/services/auth.ts:45`**
```typescript
// ❌ MD5 hash (obsolete)
const hash = crypto.createHash('md5').update(password).digest('hex');

// ✅ Fix
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);
```

## Final report

### Summary
- **Overall risk level**: CRITICAL
- **Vulnerabilities found**: 8
- **Vulnerable dependencies**: 3

### Vulnerabilities by severity

| Severity | Count | Categories |
|----------|----------|------------|
| Critical | 3 | A01, A02, A03 |
| High | 3 | A03, A07 |
| Medium | 2 | A05, A06 |

### Immediate actions (P0)

1. **Remove secrets from code**
   - `src/config/database.ts:5`
   - `src/services/payment.ts:12`
   - Use environment variables

2. **Fix SQL injection**
   - `src/services/search.ts:23`
   - Use parameterized queries

3. **Fix the IDOR**
   - `src/routes/users.ts:34`
   - Add authorization checks

### Short-term actions (P1)

4. **Update dependencies**
   ```bash
   npm update lodash
   npm audit fix
   ```

5. **Improve password hashing**
   - Migrate from MD5 to bcrypt

6. **Add Helmet for headers**

### Medium-term actions (P2)

7. **Implement rate limiting**
8. **Add strict CSP**
9. **Log audit (no sensitive data)**

## Remediation commands

```bash
# Update vulnerable dependencies
npm update lodash
npm audit fix --force

# Install security dependencies
npm install helmet bcrypt dompurify

# Scan after fixes
npm audit
npx secretlint "**/*"
```
