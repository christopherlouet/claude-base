---
sidebar_position: 43
title: "qa-security"
description: "Perform a security audit based on OWASP. Use when the user wants to verify security, look for vulnerabilities, or before a production deployment."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-security

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Perform a security audit based on OWASP. Use when the user wants to verify security, look for vulnerabilities, or before a production deployment.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Keywords** | `security` |

## Detailed description

# Security Audit

## Objective

Identify security vulnerabilities based on OWASP Top 10.

## Instructions

### 1. Automated scan

```bash
# npm dependency audit
npm audit --audit-level=moderate

# Secret search
npx secretlint "**/*"

# Static security analysis
npx eslint --plugin security src/
```

### 2. OWASP Top 10 Checklist

#### A01 - Broken Access Control
- [ ] Authorization checks on every endpoint
- [ ] No IDOR (direct access via predictable IDs)
- [ ] CORS correctly configured
- [ ] Principle of least privilege

#### A02 - Cryptographic Failures
- [ ] Sensitive data encrypted (at rest + in transit)
- [ ] No secrets in code
- [ ] Secure hash algorithms (bcrypt, argon2)
- [ ] TLS/HTTPS enforced

#### A03 - Injection
- [ ] SQL: Parameterized queries / ORM
- [ ] XSS: HTML output escaping
- [ ] Command injection: No shell with user input
- [ ] NoSQL: Query validation

#### A04 - Insecure Design
- [ ] Server-side validation (not just client)
- [ ] Rate limiting on sensitive endpoints
- [ ] Environment separation

#### A05 - Security Misconfiguration
- [ ] Security headers (CSP, X-Frame-Options)
- [ ] No stack traces in production
- [ ] Correct file permissions

#### A06 - Vulnerable Components
- [ ] `npm audit` with no critical vulnerabilities
- [ ] Dependencies maintained and up to date

#### A07 - Authentication Failures
- [ ] Passwords hashed correctly
- [ ] Protection against brute force
- [ ] Secure sessions (httpOnly, secure, sameSite)

#### A08 - Data Integrity Failures
- [ ] Validation of incoming data
- [ ] Secure deserialization

#### A09 - Logging Failures
- [ ] Logs of security events
- [ ] No sensitive data in logs

#### A10 - SSRF
- [ ] Validation of user URLs
- [ ] Whitelist of allowed domains

### 3. Search patterns

```bash
# Potential secrets
grep -rn "password\s*=" --include="*.ts"
grep -rn "api_key\s*=" --include="*.ts"
grep -rn "secret\s*=" --include="*.ts"

# Potential SQL Injection
grep -rn "query.*\$\{" --include="*.ts"
grep -rn "execute.*\+" --include="*.ts"

# Potential XSS
grep -rn "innerHTML" --include="*.tsx"
grep -rn "dangerouslySetInnerHTML" --include="*.tsx"

# Dangerous eval
grep -rn "eval(" --include="*.ts"
grep -rn "new Function(" --include="*.ts"
```

### 4. Recommended security headers

```typescript
// Express with Helmet
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  },
  hsts: { maxAge: 31536000, includeSubDomains: true }
}));
```

## Expected output

```markdown
## Security Report

### Summary
- **Overall risk level**: [Critical/High/Medium/Low]
- **Vulnerabilities found**: X
- **Vulnerable dependencies**: Y

### Critical vulnerabilities
| Severity | Category | File:Line | Description | Remediation |
|----------|----------|-----------|-------------|-------------|
| CRITICAL | A03 | auth.ts:45 | SQL injection | Parameterized query |

### Important vulnerabilities
[...]

### Priority recommendations
1. [Immediate action]
2. [Short term]
3. [Medium term]

### Dependencies to update
| Package | Version | Vulnerability | Severity |
|---------|---------|---------------|----------|
| lodash | 4.17.19 | Prototype pollution | High |
```

## Rules

- IMPORTANT: Check all 10 OWASP categories
- IMPORTANT: Prioritize by severity
- YOU MUST propose concrete remediations
- NEVER ignore critical vulnerabilities

Think hard about every potential attack vector.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to security..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Security audit example

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



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
