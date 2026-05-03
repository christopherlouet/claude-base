---
name: qa-security
description: Perform a security audit based on OWASP. Use when the user wants to verify security, look for vulnerabilities, or before a production deployment.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
model: sonnet
argument-hint: "[scope-or-module]"
---

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
