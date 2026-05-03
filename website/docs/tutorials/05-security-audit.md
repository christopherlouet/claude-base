---
sidebar_position: 6
title: "05 - Security Audit"
description: Run a complete OWASP security audit and fix vulnerabilities
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# OWASP Security Audit

<DifficultyBadge level="intermediate" /> **Estimated duration: 30 minutes**

This tutorial shows you how to run a complete security audit based on the OWASP Top 10 and fix the detected vulnerabilities.

## Goals

By the end of this tutorial, you will know how to:
- Use `/qa:qa-security` for an OWASP audit
- Identify common vulnerabilities
- Fix security issues
- Apply best practices

## Prerequisites

- An existing web project (Node.js, Python, or other)
- Basic web security knowledge

## The OWASP Top 10

The OWASP Top 10 lists the most critical web vulnerabilities:

| # | Vulnerability | Description |
|---|---------------|-------------|
| A01 | Broken Access Control | Failed access control |
| A02 | Cryptographic Failures | Cryptographic flaws |
| A03 | Injection | SQL, XSS, Command injection |
| A04 | Insecure Design | Insecure design |
| A05 | Security Misconfiguration | Misconfiguration |
| A06 | Vulnerable Components | Vulnerable dependencies |
| A07 | Auth Failures | Failed authentication |
| A08 | Data Integrity Failures | Data integrity |
| A09 | Logging Failures | Insufficient logging |
| A10 | SSRF | Server-Side Request Forgery |

## Step 1: Run the audit

```bash
/qa:qa-security
```

Claude will analyze your project and produce a detailed report.

## Step 2: Analyze the report

**Sample report:**

```markdown
## OWASP Security Audit

### 🔴 Critical (2)

#### A03 - SQL Injection
**File**: `src/routes/users.ts:45`
**Vulnerable code**:
```typescript
const user = await db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
```
**Risk**: An attacker can inject malicious SQL
**Fix**: Use parameterized queries

#### A03 - XSS (Cross-Site Scripting)
**File**: `src/views/profile.ejs:12`
**Vulnerable code**:
```html
<h1>Welcome <%- user.name %></h1>
```
**Risk**: Injection of malicious scripts
**Fix**: Use `<%= %>` to escape HTML

### 🟠 High (3)

#### A06 - Vulnerable dependencies
**Detail**: 3 dependencies with known CVEs
- lodash@4.17.15 → CVE-2021-23337 (Prototype Pollution)
- axios@0.21.0 → CVE-2021-3749 (ReDoS)
- express@4.17.0 → Update recommended

#### A02 - Plain-text secrets
**File**: `.env.example`
**Issue**: API keys visible in the repo
**Fix**: Use `.env.example` without real values

### 🟡 Medium (2)

#### A05 - Missing security headers
**Missing**:
- X-Content-Type-Options
- X-Frame-Options
- Content-Security-Policy

#### A09 - Insufficient logging
**Issue**: Failed login attempts are not logged
```

## Step 3: Fix critical vulnerabilities

### SQL Injection fix

**Before (vulnerable):**
```typescript
const user = await db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
```

**After (secure):**
```typescript
const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
```

Or with an ORM (Prisma):
```typescript
const user = await prisma.user.findUnique({
  where: { id: req.params.id }
});
```

### XSS fix

**Before (vulnerable):**
```html
<h1>Welcome <%- user.name %></h1>
```

**After (secure):**
```html
<h1>Welcome <%= user.name %></h1>
```

In React (automatically secure):
```tsx
<h1>Welcome {user.name}</h1>
```

:::warning dangerouslySetInnerHTML
In React, **never** use `dangerouslySetInnerHTML` with user data without sanitizing it with DOMPurify.
:::

## Step 4: Update dependencies

```bash
/ops:ops-deps
```

Claude will:
1. Identify vulnerable dependencies
2. Propose updates
3. Check compatibility

```bash
# Automatic update of security patches
npm audit fix

# View remaining vulnerabilities
npm audit
```

## Step 5: Add security headers

Use **helmet** for Express:

```bash
npm install helmet
```

```typescript
import helmet from 'helmet';

app.use(helmet());

// Custom configuration
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false,
}));
```

## Step 6: Improve logging

Add logging for security events:

```typescript
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' }),
  ],
});

// Log login attempts
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await authenticate(email, password);

    securityLogger.info('Login success', {
      userId: user.id,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
    });

    res.json({ token: generateToken(user) });
  } catch (error) {
    securityLogger.warn('Login failed', {
      email,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      reason: error.message,
    });

    res.status(401).json({ error: 'Invalid credentials' });
  }
});
```

## Step 7: Verify the fixes

Re-run the audit:

```bash
/qa:qa-security
```

The report should now show:

```markdown
## OWASP Security Audit

### ✅ Summary
- Critical: 0 (↓ from 2)
- High: 1 (↓ from 3)
- Medium: 0 (↓ from 2)

### 🟠 High (1)

#### A06 - Remaining vulnerable dependency
**Detail**: axios@0.21.0 requires a manual update
**Action**: `npm install axios@latest`
```

## Step 8: Commit

```bash
/work:work-commit
```

**Suggested message:**

```
fix(security): address OWASP vulnerabilities

- Fix SQL injection with parameterized queries
- Fix XSS by escaping user input
- Update vulnerable dependencies
- Add security headers with helmet
- Add security event logging
```

## Security checklist

Use this checklist for your projects:

### User input
- [ ] All inputs are validated
- [ ] Parameterized SQL queries
- [ ] HTML escaped in views
- [ ] Uploaded files validated (type, size)

### Authentication
- [ ] Passwords hashed (bcrypt, argon2)
- [ ] JWT tokens with short expiration
- [ ] Rate limiting on login
- [ ] Logout invalidates the token

### Configuration
- [ ] Environment variables for secrets
- [ ] HTTPS enabled in production
- [ ] Security headers configured
- [ ] CORS configured strictly

### Dependencies
- [ ] `npm audit` with no critical vulnerabilities
- [ ] Dependencies up to date
- [ ] Lockfile committed

### Logging
- [ ] Security events logged
- [ ] No sensitive data in logs
- [ ] Centralized logs in production

## Next steps

- [Tutorial 06: CI/CD Pipeline](/docs/tutorials/cicd-github) - Automate audits
- [API Guide](/docs/concepts/stack-recipes) - API security
- [Command /qa:qa-audit](/docs/commands/qa/qa-audit) - Full audit

---

:::tip Automation
Add `/qa:qa-security` to your CI/CD pipeline to detect vulnerabilities before deployment.
:::
