---
sidebar_position: 23
title: "security"
description: "3 attack vectors identified (Feb. 2026) when cloning untrusted repos:"
tags:
  - "rule"
  - "security"
---

# Rules: security

> 3 attack vectors identified (Feb. 2026) when cloning untrusted repos:

## Affected files

These rules apply to files matching the following patterns:

- `**/auth/**`
- `**/api/**`
- `**/routes/**`
- `**/controllers/**`
- `**/middleware/**`
- `**/services/**`

## Detailed rules

# Security Rules

## Input Validation

- IMPORTANT: Validate ALL user inputs
- Use validation schemas (Zod, Joi, class-validator)
- Reject invalid data as early as possible
- Sanitize inputs before processing

## Output Encoding

- IMPORTANT: Escape HTML outputs (XSS prevention)
- Use the framework's native escaping functions
- Never insert non-sanitized HTML into the DOM
- Avoid `innerHTML` and `dangerouslySetInnerHTML`

## Database Security

- IMPORTANT: Use parameterized queries (SQL injection prevention)
- Prefer ORMs with prepared statements
- Never concatenate user inputs into queries
- Limit the privileges of database accounts

## Secrets Management

- NEVER commit secrets (.env, credentials, API keys)
- Use environment variables
- Rotate secrets regularly
- Use a secrets manager in production

## Logging

- Never log sensitive data (passwords, tokens, PII)
- Mask sensitive information in logs
- Log security events (auth, access)

## Dependencies

- Run `npm audit` regularly
- Update dependencies with critical vulnerabilities
- Verify dependencies before installation
- Use lockfiles (package-lock.json)

## Authentication

- Hash passwords with bcrypt or argon2
- Implement brute-force protection
- Use secure sessions (httpOnly, secure, sameSite)
- Implement token expiration

## Claude Code Security (third-party repos)

3 attack vectors identified (Feb. 2026) when cloning untrusted repos:

- **Malicious hooks**: a `.claude/settings.json` from the repo can contain hooks executing arbitrary commands
- **Untrusted MCP**: a `.mcp.json` can configure MCP servers exfiltrating data
- **Environment variables**: hooks can read and transmit the contents of `.env` or system secrets

Best practices:
- Verify the contents of `.claude/settings.json` and `.mcp.json` before opening a third-party repo with Claude Code
- Keep MCP servers disabled by default
- Make sure `.env` is in `.gitignore`
- The foundation includes SessionStart hooks for automatic verification

## Bash Hardening (CLI 2.1.113+)

Hardening applied directly by the CLI. Worth knowing to write consistent `permissions` rules and avoid unintentional bypasses:

- **Extended dangerous paths**: `/private/{etc,var,tmp,home}` (macOS) are treated as dangerous removal targets just like `/etc`, `/var`, etc.
- **Deny rules resistant to execution wrappers**: a `deny: Bash(rm -rf *)` rule also matches when the command is wrapped in `env`, `sudo`, `watch`, `ionice` or `setsid`. No longer rely on these wrappers to bypass a deny rule.
- **`Bash(find:*)` no longer auto-approves `-exec`/`-delete`**: these sub-commands can modify or delete files, so they now trigger a separate permission prompt even if `find:*` is allowlisted.
- **Sandbox deniedDomains**: prefer `sandbox.network.deniedDomains` to explicitly exclude sensitive domains even under a wildcard `allowedDomains`.
- **UI-spoofing fix**: multiline comments in Bash commands now display the full command to prevent a comment from masking the actual intent.

To apply in `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": ["Bash(find:* -delete)", "Bash(find:* -exec *)"],
    "sandbox": {
      "network": {
        "allowedDomains": ["*.npmjs.org", "*.github.com"],
        "deniedDomains": ["pastebin.com", "transfer.sh"]
      },
      "failIfUnavailable": true
    }
  }
}
```

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
